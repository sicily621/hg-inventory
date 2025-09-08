// src/components/__tests__/ProductForm.test.ts
import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount } from "@vue/test-utils";
import ProductForm from "@/pages/productManagement/product/create.vue"; // 请根据你的实际路径调整

// Mock API 模块
vi.mock("@/pages/productManagement/api/category", () => ({
  getCategoryList: vi.fn(() =>
    Promise.resolve({
      data: [
        { id: 1, name: "电子产品", parentId: 0 },
        { id: 2, name: "手机", parentId: 1 },
        { id: 3, name: "电脑", parentId: 1 },
        { id: 4, name: "服饰", parentId: 0 },
        { id: 5, name: "男装", parentId: 4 },
      ],
    }),
  ),
}));

vi.mock("@/pages/productManagement/api/product", () => {
  return {
    createProduct: vi.fn().mockResolvedValue({}),
    editProduct: vi.fn().mockResolvedValue({}),
  };
});

// 类型定义（可根据实际情况补充）
interface Product {
  id?: string | number;
  name: string;
  code: string;
  categoryId: string | number;
  purchasePrice: number;
  retailPrice: number;
  specification: string;
  unit: string;
  brand: string;
  barcode: string;
}

const mockProduct: Product = {
  id: "1001",
  name: "iPhone 15",
  code: "IP15-256",
  categoryId: 2,
  purchasePrice: 5000,
  retailPrice: 6000,
  specification: "256GB",
  unit: "台",
  brand: "Apple",
  barcode: "6901234567890",
};

// 辅助函数：等待组件更新
const waitForUpdates = () => new Promise((resolve) => setTimeout(resolve, 0));

describe("ProductForm.vue", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should render form with default fields and load category options", async () => {
    const wrapper = mount(ProductForm);

    await waitForUpdates();

    // 检查标题和分割线
    expect(wrapper.find(".zc-header-word").text()).toBe("商品信息");

    // 检查输入框存在
    const inputs = wrapper.findAll(".el-input");
    expect(inputs).toHaveLength(8); // 名称、编码、采购价、零售价、规格、单位、品牌、条形码

    // 检查 tree-select 存在
    const treeSelect = wrapper.findComponent({ name: "ElTreeSelect" });
    expect(treeSelect.exists()).toBe(true);
  });
});
