import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, shallowMount } from "@vue/test-utils";
import ShipmentOrderForm from "@/pages/inventoryManagement/shipment/create.vue"; // 替换为你的路径
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
    "createTime": "2025-10-20 22:08:13",
    "updateTime": "2025-10-20 22:10:13",
    "delFlag": 0,
    "id": "1980274859473391617",
    "code": "salesOrder20251020220802642",
    "customerId": "1953018819353198594",
    "employeeId": "1950095792504283138",
    "expectedDate": "2025-10-20 22:08:03",
    "actualDate": "2025-10-20 22:10:13",
    "status": 6,
    "totalAmount": "300.00",
    "discount": "0.00",
    "tax": "0.00",
    "finalAmount": "300.00",
    "description": "",
    "approverId": "1980217833198645250",
    "approvalTime": "2025-10-20 22:08:54"
};
const defaultShipment = {
    "createTime": "2025-10-20 22:10:13",
    "updateTime": "2025-10-20 22:10:13",
    "delFlag": 0,
    "id": "1980275364526313474",
    "code": "inventoryShipment20251020221006311",
    "orderId": "1980274859473391617",
    "employeeId": "1952309334494097410",
    "description": ""
}
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
vi.mock("@/pages/saleManagement/api/orderDetail", () => ({
    getOrderDetailList: vi.fn().mockResolvedValue({
        data: [
            {
                "createTime": "2025-10-20 22:49:21",
                "updateTime": "2025-10-20 22:49:21",
                "delFlag": 0,
                "id": "1980285212265566209",
                "code": "inventoryShipment20251020224913771",
                "orderId": "1980284871721635842",
                "employeeId": "1952309334494097410",
                "description": ""
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
vi.mock("@/pages/warehouseManagement/api/warehouse", () => ({
    getWarehouseList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/warehouseManagement/api/area", () => ({
    getAreaList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/warehouseManagement/api/shelf", () => ({
    getShelfList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/warehouseManagement/api/shelf", () => ({
    getShelfList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/inventoryManagement/api/shipment", () => ({
    getShipmentList: vi.fn(() => Promise.resolve({
        data: [defaultShipment]
    })),

}));
vi.mock("@/pages/inventoryManagement/api/inventory", () => ({
    getInventoryList: vi.fn(() => Promise.resolve({
        data: [defaultShipment]
    })),

}));
vi.mock("@/pages/inventoryManagement/api/shipmentDetail", () => ({
    getShipmentDetailList: vi.fn(() => Promise.resolve({
        data: [{
            "createTime": "2025-10-20 22:49:21",
            "updateTime": "2025-10-20 22:49:21",
            "delFlag": 0,
            "id": "1980285212265566209",
            "code": "inventoryShipment20251020224913771",
            "orderId": "1980284871721635842",
            "employeeId": "1952309334494097410",
            "description": ""
        },]
    })),
}));
vi.mock("@/pages/productManagement/api/product", () => ({
    getProductList: vi.fn(() => Promise.resolve({ data: [] })),
    findProductListByIds: vi.fn(() => Promise.resolve({
        data: []
    })),
}));
vi.mock("@/pages/accountManagement/api/account", () => ({
    getAccountByOrderId: vi.fn(() => Promise.resolve({
        data: []
    })),
}));

vi.mock("@/pages/productManagement/api/category", () => ({
    getCategoryList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/employeeManagement/api/department", () => ({
    getDepartmentList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/employeeManagement/api/employee", () => ({
    getEmployeeList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/purchaseManagement/api/orderDetail", () => ({
    getOrderDetailList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/purchaseManagement/api/returnDetail", () => ({
    getReturnDetailList: vi.fn(() => Promise.resolve({ data: [] })),
}));

describe("ShipmentOrderForm - Form Only 测试", () => {
    let wrapper: ReturnType<typeof shallowMount<typeof ShipmentOrderForm>> | null =
        null;
    beforeEach(async () => {
        try {
            // ② 挂载组件：移除重复注册（stubs 与 components 不重复）
            wrapper = mount(ShipmentOrderForm, {
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
        const wrapper = mount(ShipmentOrderForm, {
            props: {
                data: defaultOrder,
                type: 1
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
        expect(wrapper.find(".zc-header-word").text()).toBe("出库信息");

        // 检查输入框
        const codeInput = wrapper.find(
            '.el-input__inner[placeholder="请输入编码"]',
        );
        expect(codeInput.exists()).toBe(true);
        await wrapper.unmount();
    });

    it("表单数据应能正确绑定", async () => {
        const wrapper = mount(ShipmentOrderForm, {
            props: {
                data: defaultOrder,
                type: 1
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
        expect((inputs[0].element as any).value).toBe(defaultShipment.code);
    });
});
