import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, shallowMount } from "@vue/test-utils";
import EmployeeList from "@/pages/employeeManagement/employee/list.vue";
import EmployeeForm from "@/pages/employeeManagement/employee/create.vue";
import {
    ElMessage,
    ElCard,
    ElForm,
    ElFormItem,
    ElInput,
    ElButton,
    ElDialog,
    ElTable,
} from "element-plus";
import { Edit, Plus, Delete } from "@element-plus/icons-vue";
import baseTable from "@@/components/baseTable/baseTable.vue";
// --- 模拟依赖 ---
vi.mock("@/pages/employeeManagement/api/employee", () => ({
    findEmployeePage: vi.fn().mockResolvedValue({
        data: {
            total: 1,
            list: [
                {
                    id: "1950095792504283138",
                    code: "001",
                    username: "admin",
                    password: "0f2797f2182804d0cc7f0b85d254c146",
                    realName: "zm",
                    departmentId: 0,
                    roleId: "1952303554671882242",
                    gender: 0,
                    avatar: "",
                    position: "",
                    phone: "17312124545",
                    email: "123@163.com",
                    status: 0,
                },
            ],
        },
    }),
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
vi.mock("@@/utils/page", () => ({
    indexMethod: vi.fn((currentPage, pageSize) => currentPage * pageSize + 1), // 简单实现
}));
// 直接 mock store 模块
vi.mock('@/pinia/stores/permission', () => {
    return {
        usePermissionStore: vi.fn(() => ({
            hasPermission: vi.fn(() => true),
        })),
    }
})
const waitForUpdates = () => new Promise((resolve) => setTimeout(resolve, 0));
const waitForTicks = (n = 1) =>
    new Promise((resolve) => setTimeout(resolve, n * 30));

describe("员工管理列表组件 - 业务逻辑单元测试", () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });
    let wrapper: any;
    // --- 测试 refreshTable 函数逻辑 ---
    describe("数据刷新功能", () => {
        it("更新表格数据和总数", async () => {
            wrapper = shallowMount(EmployeeList);
            await waitForUpdates();
            expect((wrapper.vm as any).tableData.length).toBe(1);
        });
    });
});
