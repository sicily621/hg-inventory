// tests/purchaseManagement/PurchaseOrderForm.form-only.test.ts
import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, shallowMount } from "@vue/test-utils";
import PurchaseOrderForm from "@/pages/purchaseManagement/order/detail.vue"; // 替换为你的路径
import {
    ElMessage,
    ElCard,
    ElForm,
    ElFormItem,
    ElInput,
    ElButton,
    ElDialog,
} from "element-plus";
const defaultOrder = {
    id: "1956551594762625026",
    code: "SO20250911001",
    demandId: "1953018819353198594",
    employeeId: "1950095792504283138",
    expectedDate: new Date("2025-08-16 00:00:00").getTime(),
    actualDate: new Date("1970-01-01 00:00:00").getTime(),
    status: 7,
    totalAmount: 50.0,
    description: "",
    approverId: "1950095792504283138",
    approvalTime: new Date("2025-08-16 00:00:00").getTime(),
};
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
vi.mock("@/pages/purchaseManagement/api/order", () => ({
    OrderStatus: {
        Pending: 1,
        Approved: 2,
        Rejected: 3,
        Confirmed: 4,
        PartiallyReceived: 5,
        FullyReceived: 6,
        PartiallyReturned: 7,
        Returned: 8,
        Finished: 9,
    },
    OrderStatusList: [
        { id: 1, name: "待审批" },
        { id: 2, name: "已审批" },
        { id: 3, name: "已驳回" },
        { id: 4, name: "客户已确认" },
        { id: 5, name: "部分出库" },
        { id: 6, name: "全部出库" },
        { id: 7, name: "部分退单" },
        { id: 8, name: "全部退单" },
        { id: 9, name: "已完成" },
    ],
}));
vi.mock("@/pages/purchaseManagement/api/orderDetail", () => ({
    getOrderDetailList: vi.fn().mockResolvedValue({
        data: [
            {
                id: "1956551594972340226",
                orderId: "1956551594762625026",
                categoryId: "1952678553081520129",
                productId: "1954455089243312130",
                quantity: "1.00",
                price: "50.00",
                amount: "50.00",
            },
        ],
    }),
}));
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

vi.mock("@/pages/purchaseManagement/api/supplier", () => ({
    getSupplierList: vi.fn(() => Promise.resolve({ data: [] })),
}));

vi.mock("@/pages/productManagement/api/category", () => ({
    getCategoryList: vi.fn(() => Promise.resolve({ data: [] })),
}));

vi.mock("@/pages/productManagement/api/product", () => ({
    getProductList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/employeeManagement/api/department", () => ({
    getDepartmentList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/employeeManagement/api/employee", () => ({
    getEmployeeList: vi.fn(() => Promise.resolve({ data: [] })),
}));

describe("PurchaseOrderForm - Form Only 测试", () => {
    let wrapper: ReturnType<typeof shallowMount<typeof PurchaseOrderForm>> | null =
        null;
    beforeEach(async () => {
        try {
            // ② 挂载组件：移除重复注册（stubs 与 components 不重复）
            wrapper = mount(PurchaseOrderForm, {
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
        const wrapper = mount(PurchaseOrderForm, {
            props: {
                data: defaultOrder,
                isApprove: false,
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
        expect(wrapper.find(".zc-header-word").text()).toBe("采购订单信息");

        // 检查输入框
        const codeInput = wrapper.find(
            '.el-input__inner[placeholder="请输入编码"]',
        );
        expect(codeInput.exists()).toBe(true);

        const customerInput = wrapper.find(".el-select__wrapper");
        expect(customerInput.exists()).toBe(true);

        const deliveryInput = wrapper.find(
            '.el-input__inner[placeholder="请输入期望到货时间"]',
        );
        expect(deliveryInput.exists()).toBe(true);

        await wrapper.unmount();
    });

    it("表单数据应能正确绑定", async () => {
        const wrapper = mount(PurchaseOrderForm, {
            props: {
                data: defaultOrder,
                isApprove: false,
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
        expect((inputs[0].element as any).value).toBe(defaultOrder.code);
    });
});
