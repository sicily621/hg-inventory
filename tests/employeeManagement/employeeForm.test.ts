// src/components/EmployeeForm.test.ts
import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount } from "@vue/test-utils";
import EmployeeForm from "@/pages/employeeManagement/employee/create.vue";

// 模拟 API 调用
vi.mock("@/pages/employeeManagement/api/employee", () => ({
    createEmployee: vi.fn().mockResolvedValue({}),
    editEmployee: vi.fn().mockResolvedValue({}),
}));
vi.mock("@/pages/employeeManagement/api/department", () => ({
    getDepartmentList: vi.fn().mockResolvedValue({
        data: [
            { id: 1, name: "技术部", parentId: 0 },
            { id: 2, name: "前端组", parentId: 1 },
        ],
    }),
}));
vi.mock("@/pages/employeeManagement/api/role", () => ({
    getRoleList: vi.fn().mockResolvedValue({
        data: [
            { id: 1, name: "管理员" },
            { id: 2, name: "普通员工" },
        ],
    }),
}));
vi.mock("js-md5", () => ({
    default: vi.fn((str) => `hashed_${str}`),
}));
const waitForUpdates = () => new Promise((resolve) => setTimeout(resolve, 0));
const waitForTicks = (n = 1) =>
    new Promise((resolve) => setTimeout(resolve, n * 30));

describe("员工信息表单组件", () => {
    let wrapper: any;

    beforeEach(() => {
        vi.clearAllMocks();
    });

    it("应该正确渲染表单标题和字段", async () => {
        wrapper = mount(EmployeeForm);

        await waitForUpdates();
        expect(wrapper.find(".zc-header-word").text()).toBe("员工信息");
        expect(wrapper.findAll(".el-form-item").length).toBeGreaterThan(5);
        expect(wrapper.find('input[placeholder="请输入用户名"]').exists()).toBe(
            true,
        );
        expect(wrapper.find('input[placeholder="请输入真实姓名"]').exists()).toBe(
            true,
        );
    });

    it("应该正确绑定表单输入值", async () => {
        const usernameInput = wrapper.find('input[placeholder="请输入用户名"]');
        await usernameInput.setValue("zhangsan");
        expect(wrapper.vm.form.username).toBe("zhangsan");

        const realNameInput = wrapper.find('input[placeholder="请输入真实姓名"]');
        await realNameInput.setValue("张三");
        expect(wrapper.vm.form.realName).toBe("张三");

        const phoneInput = wrapper.find('input[placeholder="请输入电话"]');
        await phoneInput.setValue("13812345678");
        expect(wrapper.vm.form.phone).toBe("13812345678");
    });

    it("手机号验证应该生效，错误格式会提示", async () => {
        const wrapper = mount(EmployeeForm, {
            attachTo: document.body, // 更真实地渲染到 DOM
        });
        const phoneInput = wrapper.find('input[placeholder="请输入电话"]');
        await phoneInput.setValue("123456789"); // 不符合 1 开头 11 位规则
        await waitForTicks(2); // 等待 mounted 和数据加载

        const confirmSave = (wrapper.vm as any).confirmSave;
        await confirmSave();

        // 等待 Element Plus 表单校验完成并渲染错误信息
        await wrapper.vm.$nextTick();
        await waitForTicks(5);

        await waitForUpdates();
        const phoneItem = wrapper.findAll(".el-form-item__error")[4]; // 电话是第5个字段（索引4）
        expect(phoneItem.text()).toContain("请输入正确手机号");
    });

    it("邮箱验证应该生效，错误格式会提示", async () => {
        const wrapper = mount(EmployeeForm, {
            attachTo: document.body, // 更真实地渲染到 DOM
        });
        const emailInput = wrapper.find('input[placeholder="请输入邮箱"]');
        await emailInput.setValue("not-an-email");
        const confirmSave = (wrapper.vm as any).confirmSave;
        await confirmSave();

        // 等待 Element Plus 表单校验完成并渲染错误信息
        await wrapper.vm.$nextTick();
        await waitForTicks(5);
        const emailItem = wrapper.findAll(".el-form-item__error")[5];
        expect(emailItem.text()).toContain("请输入正确邮箱");
    });

    it("应该正确加载并显示部门树形选项", async () => {
        expect(wrapper.vm.departmentOptions.length).toBe(1);
        expect(wrapper.vm.departmentOptions[0].name).toBe("技术部");
        expect(wrapper.vm.departmentOptions[0].children.length).toBe(1);
        expect(wrapper.vm.departmentOptions[0].children[0].name).toBe("前端组");
    });

    it("应该正确加载并显示角色下拉选项", () => {
        expect(wrapper.vm.roleOptions.length).toBe(2);
        expect(wrapper.vm.roleOptions[0].name).toBe("管理员");
        expect(wrapper.vm.roleOptions[1].name).toBe("普通员工");
    });

    it("应该通过 defineExpose 暴露 confirmSave 方法供父组件调用", () => {
        const instance = wrapper.vm;
        expect(typeof instance.confirmSave).toBe("function");
    });
});
