import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, shallowMount } from "@vue/test-utils";
import WarehouseOrderForm from "@/pages/warehouseManagement/warehouse/create.vue"; // 替换为你的路径
import {
    ElMessage,
    ElCard,
    ElForm,
    ElFormItem,
    ElInput,
    ElButton,
    ElDialog,
} from "element-plus";

const defaultWarehouse = {
    "createTime": "2025-08-06 10:23:47",
    "updateTime": "2025-08-06 10:23:47",
    "delFlag": 0,
    "id": "1952918491823816705",
    "name": "仓库1",
    "code": "001",
    "area": 100.00,
    "managerId": "1950095792504283138"
}
// 🟩 Stub 所有复杂组件，尤其是 el-table 和 baseTable
const MockBaseTable = {
    template: '<div class="stubbed-base-table"></div>',
};


vi.mock("@/pinia/stores/user", () => ({
    useUserStore: vi.fn(() => ({
        getInfo: () => ({ id: "u1001", name: "Test User" }),
    })),
}));

vi.mock("@/pinia/stores/permission", () => ({
    usePermissionStore: vi.fn(() => ({
        hasPermission: () => true,
    })),
}));


vi.mock("@/pages/employeeManagement/api/employee", () => ({
    getEmployeeList: vi.fn(() => Promise.resolve({ data: [] })),
}));

describe("WarehouseOrderForm - Form Only 测试", () => {
    let wrapper: ReturnType<typeof shallowMount<typeof WarehouseOrderForm>> | null =
        null;
    beforeEach(async () => {
        try {
            // ② 挂载组件：移除重复注册（stubs 与 components 不重复）
            wrapper = mount(WarehouseOrderForm, {
                global: {
                    components: {
                        // 只注册非 stub 组件：基础组件 + 图标（避免与 stubs 冲突）
                        ElCard,
                        ElForm,
                        ElFormItem,
                        ElInput,
                        ElButton,
                    },
                    stubs: {
                        // Stub 复杂组件（覆盖 Element 组件，避免深层渲染）
                        baseTable: MockBaseTable,
                        "el-table": MockBaseTable,
                        "el-form": ElForm,
                        "el-input": ElInput,
                    },
                },
            });
            await new Promise((resolve) => setTimeout(resolve, 300));
            await wrapper.vm.$nextTick();
        } catch (error) {
            console.error("组件挂载失败（beforeEach）：", error);
            throw error;
        }
    });
    it("应该正确渲染基础表单字段", async () => {
        const wrapper = mount(WarehouseOrderForm, {
            props: {
                data: defaultWarehouse
            },
            global: {
                components: {
                    // 只注册非 stub 组件：基础组件 + 图标（避免与 stubs 冲突）
                    ElCard,
                    ElForm,
                    ElFormItem,
                    ElInput,
                    ElButton,
                },
                stubs: {
                    // Stub 复杂组件（覆盖 Element 组件，避免深层渲染）
                    baseTable: MockBaseTable,
                    "el-table": MockBaseTable,
                    "el-form": ElForm,
                    "el-input": ElInput,
                },
            },
        });
        // 检查标题
        expect(wrapper.find(".zc-header-word").text()).toBe("仓库信息");

        // 检查输入框
        const codeInput = wrapper.find(
            '.el-input__inner[placeholder="请输入编码"]',
        );
        expect(codeInput.exists()).toBe(true);
        await wrapper.unmount();
    });

    it("表单数据应能正确绑定", async () => {
        const wrapper = mount(WarehouseOrderForm, {
            props: {
                data: defaultWarehouse,
            },
            global: {
                components: {
                    // 只注册非 stub 组件：基础组件 + 图标（避免与 stubs 冲突）
                    ElCard,
                    ElForm,
                    ElFormItem,
                    ElInput,
                    ElButton,
                },
                stubs: {
                    // Stub 复杂组件（覆盖 Element 组件，避免深层渲染）
                    baseTable: MockBaseTable,
                    "el-table": MockBaseTable,
                    "el-form": ElForm,
                    "el-input": ElInput,
                },
            },
        });
        await wrapper.vm.$nextTick();
        await new Promise((resolve) => setTimeout(resolve, 500));
        const inputs = wrapper.findAll(".el-input__inner");
        // 检查初始值绑定
        expect((inputs[0].element as any).value).toBe(defaultWarehouse.name);
        expect((inputs[1].element as any).value).toBe(defaultWarehouse.code);
    });
});
