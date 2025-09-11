// tests/saleManagement/salesOrderForm.form-only.test.ts
import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, shallowMount } from "@vue/test-utils";
import SalesOrderForm from "@/pages/saleManagement/order/create.vue"; // 替换为你的路径
import { OrderStatus } from "@/pages/saleManagement/api/order";
import {
  ElMessage,
  ElCard,
  ElForm,
  ElFormItem,
  ElInput,
  ElButton,
  ElDialog,
} from "element-plus";

// 🟩 Stub 所有复杂组件，尤其是 el-table 和 baseTable
const MockBaseTable = {
  template: '<div class="stubbed-base-table"></div>',
};

const MockTable = {
  template: '<div class="stubbed-el-table"></div>',
};

const MockInput = {
  props: ["modelValue"],
  emits: ["update:modelValue"],
  template:
    '<input :value="modelValue" @input="$emit(\'update:modelValue\', $event.target.value)" />',
};

const MockSelect = {
  props: ["modelValue", "placeholder"],
  emits: ["update:modelValue", "change"],
  template:
    '<input :value="modelValue" @input="$emit(\'update:modelValue\', $event.target.value); $emit(\'change\', $event.target.value)" :placeholder="placeholder" />',
};

const MockDatePicker = {
  props: ["modelValue"],
  emits: ["update:modelValue"],
  template:
    '<input type="datetime-local" :value="modelValue" @input="$emit(\'update:modelValue\', $event.target.value)" />',
};

const MockButton = {
  props: ["disabled"],
  emits: ["click"],
  template:
    '<button :disabled="disabled" @click="$emit(\'click\', $event)"><slot/></button>',
};
describe("SalesOrderForm - Form Only 测试", () => {
  let wrapper: ReturnType<typeof shallowMount<typeof SalesOrderForm>> | null =
    null;
  beforeEach(async () => {
    try {
      // 🟩 Mock 所有副作用：store 和 API
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

      vi.mock("@/pages/saleManagement/api/customer", () => ({
        getCustomerList: vi.fn(() => Promise.resolve({ data: [] })),
      }));

      vi.mock("@/pages/productManagement/api/category", () => ({
        getCategoryList: vi.fn(() => Promise.resolve({ data: [] })),
      }));

      vi.mock("@/pages/productManagement/api/product", () => ({
        getProductList: vi.fn(() => Promise.resolve({ data: [] })),
      }));
      // ② 挂载组件：移除重复注册（stubs 与 components 不重复）
      wrapper = mount(SalesOrderForm, {
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
            "el-table": MockBaseTable, // 双保险
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
    if (!wrapper) throw new Error("组件未挂载成功，wrapper 为 null");
    // console.log(wrapper.html());
    // 检查标题
    expect(wrapper.find(".zc-header-word").text()).toBe("销售订单信息");

    // 检查输入框
    const codeInput = wrapper.find(
      '.el-input__inner[placeholder="请输入编码"]',
    );
    expect(codeInput.exists()).toBe(true);

    const customerInput = wrapper.find(".el-select__wrapper");
    expect(customerInput.exists()).toBe(true);

    const deliveryInput = wrapper.find(
      '.el-input__inner[placeholder="请输入期望交货时间"]',
    );
    expect(deliveryInput.exists()).toBe(true);

    await wrapper.unmount();
  });

  // it("表单数据应能正确绑定", async () => {
  //   const wrapper = mount(SalesOrderForm, {
  //     props: {
  //       data: {
  //         code: "SO20250911001",
  //         customerId: "c1001",
  //         expectedDeliveryTime: "2025-09-20T10:00",
  //         discount: 100,
  //       },
  //     },
  //     global: {
  //       components: {
  //         baseTable: MockBaseTable,
  //         "el-table": MockTable,
  //         "el-input": MockInput,
  //         "el-select": MockSelect,
  //         "el-date-picker": MockDatePicker,
  //         // ... 其他 stubs
  //       },
  //     },
  //   });

  //   // 检查初始值绑定
  //   expect(wrapper.vm.form.code).toBe("SO20250911001");
  //   expect(wrapper.vm.form.customerId).toBe("c1001");
  //   expect(wrapper.vm.form.discount).toBe(100);

  //   // 修改输入
  //   const input = wrapper.find('input[placeholder="请输入编码"]');
  //   await input.setValue("NEW-CODE-001");

  //   expect(wrapper.vm.form.code).toBe("NEW-CODE-001");
  // });

  // it("当 status 不是 Pending 时，大部分字段应被禁用", async () => {
  //   const wrapper = mount(SalesOrderForm, {
  //     props: {
  //       data: { status: OrderStatus.Approved }, // 已审批
  //     },
  //     global: {
  //       components: {
  //         baseTable: MockBaseTable,
  //         "el-table": MockTable,
  //         "el-input": {
  //           template: `
  //             <input
  //               :value="modelValue"
  //               :disabled="$attrs.disabled"
  //               @input="$emit('update:modelValue', $event.target.value)"
  //             />
  //           `,
  //           props: ["modelValue"],
  //           emits: ["update:modelValue"],
  //         },
  //         "el-select": {
  //           template: `
  //             <input
  //               :value="modelValue"
  //               :disabled="$attrs.disabled"
  //               @input="$emit('update:modelValue', $event.target.value)"
  //             />
  //           `,
  //           props: ["modelValue"],
  //           emits: ["update:modelValue"],
  //         },
  //         "el-date-picker": {
  //           template: `
  //             <input
  //               type="datetime-local"
  //               :value="modelValue"
  //               :disabled="$attrs.disabled"
  //               @input="$emit('update:modelValue', $event.target.value)"
  //             />
  //           `,
  //           props: ["modelValue"],
  //           emits: ["update:modelValue"],
  //         },
  //         "el-button": MockButton,
  //       },
  //     },
  //   });

  //   // 查找所有输入项
  //   const inputs = wrapper.findAll("input");
  //   const disabledInputs = inputs.filter((i) => i.attributes("disabled"));

  //   // 大部分输入应该被禁用
  //   expect(disabledInputs.length).toBeGreaterThan(3);

  //   // “返回”按钮不应禁用
  //   const backBtn = wrapper.find('button:contains("返回")');
  //   expect(backBtn.attributes("disabled")).toBeUndefined();

  //   // “确定”按钮在非 Pending 状态下也应禁用（业务逻辑）
  //   const confirmBtn = wrapper.find('button:contains("确定")');
  //   expect(confirmBtn.attributes("disabled")).toBeDefined();
  // });

  // it("点击“返回”按钮应触发 cancel 事件", async () => {
  //   const wrapper = mount(SalesOrderForm, {
  //     props: { data: null },
  //     global: {
  //       components: {
  //         baseTable: MockBaseTable,
  //         "el-button": MockButton,
  //         // ... 其他 stubs
  //       },
  //     },
  //   });

  //   const backBtn = wrapper.find('button:contains("返回")');
  //   await backBtn.trigger("click");

  //   expect(wrapper.emitted("cancel")).toBeTruthy();
  //   expect(wrapper.emitted("cancel").length).toBe(1);
  // });
});
