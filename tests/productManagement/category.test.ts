import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { shallowMount, mount } from "@vue/test-utils";
import CategoryList from "@/pages/productManagement/category/list.vue";
// 1. 模拟外部依赖（API、组件、图标）
import * as categoryApi from "@/pages/productManagement/api/category";
import {
  ElMessage,
  ElCard,
  ElForm,
  ElFormItem,
  ElInput,
  ElButton,
  ElDialog,
} from "element-plus";
import { Edit, Plus, Delete } from "@element-plus/icons-vue";

// 关键：提前 Mock 整个 API 模块（自动转为 Mock 函数）
vi.mock("@/pages/productManagement/api/category");

// 直接 mock store 模块
vi.mock('@/pinia/stores/permission', () => {
  return {
    usePermissionStore: vi.fn(() => ({
      hasPermission: vi.fn(() => true),
    })),
  }
})
// -------------------------- 模拟数据定义 --------------------------
const mockRawCategoryData: categoryApi.Category[] = [
  { id: "1", name: "电子产品", parentId: 0 },
  { id: "2", name: "手机", parentId: 1 },
  { id: "3", name: "电脑", parentId: 0 },
  { id: "4", name: "笔记本", parentId: 3 },
];

// -------------------------- 测试套件 --------------------------
describe("分类管理组件（CategoryList.vue）", () => {
  let wrapper: ReturnType<typeof shallowMount<typeof CategoryList>> | null =
    null;

  beforeEach(async () => {
    try {
      vi.mocked(categoryApi.getCategoryList).mockResolvedValue({
        code: 200,
        data: mockRawCategoryData,
      });
      vi.mocked(categoryApi.deleteCategory).mockResolvedValue({
        success: true,
      });
      vi.mocked(categoryApi.createCategory).mockResolvedValue({
        success: true,
      });
      vi.mocked(categoryApi.editCategory).mockResolvedValue({ success: true });

      // ② 挂载组件：移除重复注册（stubs 与 components 不重复）
      wrapper = mount(CategoryList, {
        global: {
          components: {
            // 只注册非 stub 组件：基础组件 + 图标（避免与 stubs 冲突）
            ElCard,
            ElForm,
            ElFormItem,
            ElInput,
            ElButton,
            Edit,
            Plus,
            Delete,
          },
          stubs: {
            // Stub 复杂组件（覆盖 Element 组件，避免深层渲染）
            "el-table": {
              template: "<div class='el-table-stub'><slot /></div>",
            },
            "el-dialog": {
              template: "<div class='el-dialog-stub'><slot /></div>",
            },
            "el-table-column": {
              template: "<div class='el-table-column-stub'><slot /></div>",
            }, // 补充 stub，避免警告
          },
          config: { warnHandler: () => { } },
        },
      });
      await new Promise((resolve) => setTimeout(resolve, 100));
      await wrapper.vm.$nextTick();
    } catch (error) {
      console.error("组件挂载失败（beforeEach）：", error);
      throw error;
    }
  });
  it("初始化：显示标题，加载树形分类数据", async () => {
    if (!wrapper) throw new Error("组件未挂载成功，wrapper 为 null");
    const title = wrapper.find(".zc-header-word");
    expect(title.exists()).toBe(true);
    expect((wrapper.vm as any).tableData.length).toBe(2);
  });
  afterEach(() => {
    if (wrapper) {
      wrapper.unmount();
      wrapper = null;
    }
    vi.clearAllMocks();
  });
});
