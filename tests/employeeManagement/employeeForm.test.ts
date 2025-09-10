// src/components/EmployeeForm.test.ts
import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount } from "@vue/test-utils";
import EmployeeForm from "@/pages/employeeManagement/employee/create.vue"; // 请替换为你的实际路径
import { nextTick } from "vue";

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
const defaultData = {
  id: 1,
  username: "lisi",
  realName: "李四",
  phone: "13800138000",
  email: "lisi@example.com",
  password: "", // 空表示不修改原密码
};
const waitForUpdates = () => new Promise((resolve) => setTimeout(resolve, 0));
const waitForTicks = (n = 1) =>
  new Promise((resolve) => setTimeout(resolve, n * 30));

// 创建模拟图片文件
const createFile = () =>
  new File(["dummy content"], "avatar.png", { type: "image/png" });

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
    const phoneInput = wrapper.find('input[placeholder="请输入电话"]');
    await phoneInput.setValue("123456789"); // 不符合 1 开头 11 位规则
    await wrapper.find(".el-form").trigger("submit");

    await waitForUpdates();
    const phoneItem = wrapper.findAll(".el-form-item__error")[6]; // 电话是第9个字段（索引8）
    expect(phoneItem.text()).toContain("请输入正确手机号");
  });

  // it("邮箱验证应该生效，错误格式会提示", async () => {
  //   const emailInput = wrapper.find('input[placeholder="请输入邮箱"]');
  //   await emailInput.setValue("not-an-email");
  //   await wrapper.find("el-form").trigger("submit");

  //   await nextTick();
  //   const emailItem = wrapper.findAll(".el-form-item")[9];
  //   expect(emailItem.text()).toContain("请输入正确邮箱");
  // });

  // it("应该正确加载并显示部门树形选项", async () => {
  //   expect(wrapper.vm.departmentOptions.length).toBe(2); // “无” + 技术部
  //   expect(wrapper.vm.departmentOptions[1].name).toBe("技术部");
  //   expect(wrapper.vm.departmentOptions[1].children.length).toBe(1);
  //   expect(wrapper.vm.departmentOptions[1].children[0].name).toBe("前端组");
  // });

  // it("应该正确加载并显示角色下拉选项", () => {
  //   expect(wrapper.vm.roleOptions.length).toBe(3); // “无” + 两个角色
  //   expect(wrapper.vm.roleOptions[1].name).toBe("管理员");
  //   expect(wrapper.vm.roleOptions[2].name).toBe("普通员工");
  // });

  // it("头像上传应该能预览图片并绑定文件", async () => {
  //   const file = createFile();
  //   const upload = wrapper.findComponent({ name: "el-upload" });

  //   await upload.vm.$emit("change", { raw: file });

  //   await nextTick();
  //   expect(wrapper.vm.imageUrl).toBeTruthy();
  //   expect(wrapper.find("img").exists()).toBe(true);
  //   expect(wrapper.vm.form.avatarFile).toBe(file);
  // });

  // it("新增员工时应使用默认密码并进行加密", async () => {
  //   await wrapper.vm.confirmSave();

  //   const createEmployee = await import(
  //     "@/pages/employeeManagement/api/employee"
  //   ).then((m) => m.createEmployee);
  //   expect(createEmployee).toHaveBeenCalled();
  //   const args = (createEmployee as vi.Mock).mock.calls[0][0];
  //   expect(args.password).toBe("hashed_Admin@123456");
  // });

  // it("编辑员工时若未修改密码，则不应提交密码字段", async () => {
  //   // 重新挂载为编辑模式
  //   wrapper = mount(EmployeeForm, {
  //     props: {
  //       data: {
  //         id: 1,
  //         username: "lisi",
  //         realName: "李四",
  //         phone: "13800138000",
  //         email: "lisi@example.com",
  //         password: "", // 空表示不修改原密码
  //       },
  //     },
  //   });
  //   await nextTick();
  //   await nextTick();

  //   const mockEditEmployee = vi.spyOn(
  //     await import("@/pages/employeeManagement/api/employee"),
  //     "editEmployee",
  //   );
  //   await wrapper.vm.confirmSave();

  //   const args = mockEditEmployee.mock.calls[0][0];
  //   expect(args).not.toHaveProperty("password");
  // });

  // it("保存成功后应弹出成功提示消息", async () => {
  //   const ElMessage = (await import("element-plus")).ElMessage as vi.Mock;
  //   ElMessage.mockClear();

  //   await wrapper.vm.confirmSave();

  //   expect(ElMessage).toHaveBeenCalledWith({
  //     type: "success",
  //     message: "保存成功",
  //   });
  // });

  // it("应该通过 defineExpose 暴露 confirmSave 方法供父组件调用", () => {
  //   const instance = wrapper.vm;
  //   expect(typeof instance.confirmSave).toBe("function");
  // });
});
