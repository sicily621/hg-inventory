import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount } from "@vue/test-utils";
import ProductForm from "@/pages/productManagement/product/create.vue";

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
  getInventoryByProductIds: vi.fn(() =>
    Promise.resolve({
      data: [],
    }),
  ),
}));
vi.mock("@/pages/inventoryManagement/api/inventory", () => ({
  getInventoryByProductIds: vi.fn(() =>
    Promise.resolve({
      data: [],
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
const waitForTicks = (n = 1) =>
  new Promise((resolve) => setTimeout(resolve, n * 30));
describe("ProductForm.vue", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("应渲染表单默认字段并加载分类选项", async () => {
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

    // 检查分类数据是否加载
    const treeData = treeSelect.props("data");
    expect(treeData).toHaveLength(2);
    expect(treeData[0].name).toBe("电子产品");
    expect(treeData[1].name).toBe("服饰");

    wrapper.unmount();
  });
  it("在传入 data 属性时应预填充表单数据（编辑模式）", async () => {
    const wrapper = mount(ProductForm, {
      props: {
        data: mockProduct,
      },
    });

    await waitForUpdates();

    const inputs = wrapper.findAll(".el-input__inner");

    // 检查字段是否正确回填
    expect((inputs[0].element as any).value).toBe(mockProduct.name);
    expect((inputs[1].element as any).value).toBe(mockProduct.code);
    expect((inputs[2].element as any).value).toBe(
      String(mockProduct.purchasePrice),
    );
    expect((inputs[3].element as any).value).toBe(
      String(mockProduct.retailPrice),
    );
    expect((inputs[4].element as any).value).toBe(mockProduct.specification);
    expect((inputs[5].element as any).value).toBe(mockProduct.unit);
    expect((inputs[6].element as any).value).toBe(mockProduct.brand);
    expect((inputs[7].element as any).value).toBe(mockProduct.barcode);

    const treeSelect = wrapper.findComponent({ name: "ElTreeSelect" });
    expect(treeSelect.props("modelValue")).toBe(mockProduct.categoryId);

    wrapper.unmount();
  });

  it("在提交有效数据时应调用 createProduct 创建商品", async () => {
    const wrapper = mount(ProductForm);

    await waitForUpdates();

    // 填写表单
    await wrapper.find('[placeholder="请输入名称"]').setValue("AirPods Pro");
    await wrapper.find('[placeholder="请输入编码"]').setValue("APP-001");
    await wrapper.find('[placeholder="请输入采购价"]').setValue("1500");
    await wrapper.find('[placeholder="请输入零售价"]').setValue("1999");

    const treeSelect = wrapper.findComponent({ name: "ElTreeSelect" });
    await treeSelect.setValue(1); // 选择 “电子产品”

    await wrapper.find('[placeholder="请输入规格"]').setValue("无线降噪耳机");
    await wrapper.find('[placeholder="请输入单位"]').setValue("个");
    await wrapper.find('[placeholder="请输入品牌"]').setValue("Apple");
    await wrapper
      .find('[placeholder="请输入条形码"]')
      .setValue("6901111111111");

    // 调用暴露的方法
    const confirmSave = (wrapper.vm as any).confirmSave;
    await confirmSave();

    const { createProduct } = await import(
      "@/pages/productManagement/api/product"
    );
    expect(createProduct).toHaveBeenCalledTimes(1);
    expect(createProduct).toHaveBeenCalledWith(
      expect.objectContaining({
        name: "AirPods Pro",
        code: "APP-001",
        categoryId: 1,
        purchasePrice: 1500,
        retailPrice: 1999,
        specification: "无线降噪耳机",
        unit: "个",
        brand: "Apple",
        barcode: "6901111111111",
      }),
    );

    wrapper.unmount();
  });

  it("在编辑已有商品时应调用 editProduct 方法", async () => {
    const wrapper = mount(ProductForm, {
      props: {
        data: mockProduct,
      },
    });

    await waitForUpdates();

    // 修改一个字段
    await wrapper.find('[placeholder="请输入品牌"]').setValue("Apple Inc.");

    const confirmSave = (wrapper.vm as any).confirmSave;
    await confirmSave();

    const { editProduct } = await import(
      "@/pages/productManagement/api/product"
    );
    expect(editProduct).toHaveBeenCalledTimes(1);
    expect(editProduct).toHaveBeenCalledWith(
      expect.objectContaining({
        id: "1001",
        name: "iPhone 15",
        brand: "Apple Inc.",
      }),
    );

    wrapper.unmount();
  });

  it("在提交空表单时应显示校验错误提示", async () => {
    const wrapper = mount(ProductForm, {
      attachTo: document.body, // 更真实地渲染到 DOM
    });

    await waitForTicks(2); // 等待 mounted 和数据加载

    const confirmSave = (wrapper.vm as any).confirmSave;
    await confirmSave();

    // 等待 Element Plus 表单校验完成并渲染错误信息
    await wrapper.vm.$nextTick();
    await waitForTicks(5);

    // 现在可以找到真实的 .el-form-item__error
    const errorMessages = wrapper.findAll(".el-form-item__error");
    expect(errorMessages.length).toBeGreaterThan(0);
    expect(errorMessages[0].text()).toBe("不能为空");

    // 确保 createProduct 没被调用
    const { createProduct } = await import(
      "@/pages/productManagement/api/product"
    );
    expect(createProduct).not.toHaveBeenCalled();

    wrapper.unmount();
  });

  it("当表单数据有效时应调用 createProduct 方法", async () => {
    const wrapper = mount(ProductForm, {
      attachTo: document.body,
    });

    await waitForTicks(2);

    await wrapper.find('[placeholder="请输入名称"]').setValue("MacBook Pro");
    await wrapper.find('[placeholder="请输入编码"]').setValue("MBP-2025");
    await wrapper.find('[placeholder="请输入采购价"]').setValue("15000");
    await wrapper.find('[placeholder="请输入零售价"]').setValue("18000");

    const treeSelect = wrapper.findComponent({ name: "ElTreeSelect" });
    await treeSelect.setValue(3); // 选择 “电脑”

    await wrapper.find('[placeholder="请输入规格"]').setValue("16GB");
    await wrapper.find('[placeholder="请输入单位"]').setValue("台");
    await wrapper.find('[placeholder="请输入品牌"]').setValue("Apple");
    await wrapper
      .find('[placeholder="请输入条形码"]')
      .setValue("6902222222222");

    const confirmSave = (wrapper.vm as any).confirmSave;
    await confirmSave();

    await waitForTicks(2);

    const { createProduct } = await import(
      "@/pages/productManagement/api/product"
    );
    expect(createProduct).toHaveBeenCalledTimes(1);
    expect(createProduct).toHaveBeenCalledWith(
      expect.objectContaining({
        name: "MacBook Pro",
        code: "MBP-2025",
        categoryId: 3,
      }),
    );

    wrapper.unmount();
  });
});
