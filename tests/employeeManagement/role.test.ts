import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, shallowMount } from "@vue/test-utils";
import RoleOrderForm from "@/pages/employeeManagement/role/create.vue"; // 替换为你的路径
import {
    ElMessage,
    ElCard,
    ElForm,
    ElFormItem,
    ElInput,
    ElButton,
    ElDialog,
} from "element-plus";

const defaultRole =
{
    "createTime": "2025-07-17 17:30:15",
    "updateTime": "2025-10-20 22:58:24",
    "delFlag": 0,
    "id": 1,
    "name": "财务主管",
    "code": "account_manager",
    "description": "审批账单、出入帐",
    "status": 1
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
vi.mock("@/pages/employeeManagement/api/permission", () => ({
    getPermissionList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/employeeManagement/api/permission", () => ({
    getPermissionList: vi.fn(() => Promise.resolve({ data: [] })),
}));
vi.mock("@/pages/employeeManagement/api/rolePermissionRelations", () => ({
    getRolePermissionRelationsByRoleId: vi.fn(() => Promise.resolve({ data: [] })),
}));

describe("RoleOrderForm - Form Only 测试", () => {
    let wrapper: ReturnType<typeof shallowMount<typeof RoleOrderForm>> | null =
        null;
    beforeEach(async () => {
        try {
            // ② 挂载组件：移除重复注册（stubs 与 components 不重复）
            wrapper = mount(RoleOrderForm, {
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
        const wrapper = mount(RoleOrderForm, {
            props: {
                data: defaultRole
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
        expect(wrapper.find(".zc-header-word").text()).toBe("角色信息");

        // 检查输入框
        const codeInput = wrapper.find(
            '.el-input__inner[placeholder="请输入编码"]',
        );
        expect(codeInput.exists()).toBe(true);
        await wrapper.unmount();
    });

    it("表单数据应能正确绑定", async () => {
        const wrapper = mount(RoleOrderForm, {
            props: {
                data: defaultRole,
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
        expect((inputs[0].element as any).value).toBe(defaultRole.name);
        expect((inputs[1].element as any).value).toBe(defaultRole.code);
        expect((inputs[2].element as any).value).toBe(defaultRole.description);
    });
});
