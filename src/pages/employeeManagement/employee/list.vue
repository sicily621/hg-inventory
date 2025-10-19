<template>
  <div class="app-container flex flex-col h-full">
    <div class="h-full w-full flex flex-col" v-if="!processFlag">
      <el-card v-loading="loading" shadow="never" class="search-wrapper">
        <div class="flex">
          <el-form
            ref="searchFormRef"
            class="flex-grow-1"
            :inline="true"
            :model="searchData"
          >
            <el-form-item prop="code" label="编码">
              <el-input v-model="searchData.code" placeholder="请输入" />
            </el-form-item>
            <el-form-item prop="realName" label="姓名">
              <el-input v-model="searchData.realName" placeholder="请输入" />
            </el-form-item>
            <el-form-item prop="departmentId" label="部门">
              <el-tree-select
                class="w-40"
                v-model="searchData.departmentId"
                placeholder="请选择部门"
                :data="departmentOptions"
                check-strictly
                :render-after-expand="false"
                :props="selectProps"
              />
            </el-form-item>
            <el-form-item prop="roleId" label="角色">
              <el-select
                v-model="searchData.roleId"
                placeholder="请选择角色"
                class="w-40"
              >
                <el-option
                  v-for="item in roleOptions"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
          </el-form>
          <el-button type="primary" v-if="enableCreate" @click="create"
            >新增</el-button
          >
        </div>
      </el-card>
      <div
        v-loading="loading"
        class="flex-grow-1 flex flex-col el-card table-card"
        shadow="never"
      >
        <div class="table-wrap">
          <baseTable
            :columns="columns"
            :table-data="tableData"
            :indexMethod="indexMethod(currentPage, pageSize)"
            class="h-full"
          >
            <template #departmentId="scope">
              {{ getName(scope.scope.row.departmentId, departmentMap) }}
            </template>
            <template #roleId="scope">
              {{ getName(scope.scope.row.roleId, roleMap) }}
            </template>
            <template #gender="scope">
              {{ scope.scope.row.gender ? "男" : "女" }}
            </template>
            <template #status="scope">
              <el-tag :type="scope.scope.row.status ? 'primary' : 'warning'">{{
                scope.scope.row.status ? "在职" : "离职"
              }}</el-tag>
            </template>
            <template #operate="scope">
              <div class="flex">
                <el-icon
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  v-if="enableEdit"
                  @click="edit(scope.scope.row)"
                >
                  <Edit />
                </el-icon>
                <el-icon
                  class="fz16 cursor-pointer"
                  text
                  @click="remove(scope.scope.row.id)"
                  v-if="enableDelete"
                >
                  <Delete />
                </el-icon>
              </div>
            </template>
          </baseTable>
        </div>
        <div class="pager-wrapper h-12 p-r-4">
          <pagination
            :page-size="pageSize"
            :current-page="currentPage + 1"
            :total="totalItems"
            @pageChange="pageChange($event)"
            class="zc-page"
          ></pagination>
        </div>
      </div>
    </div>
    <div class="h-full w-full flex flex-col" v-if="processFlag">
      <Create class="create-wrap" ref="createRef" :data="currentData"></Create>
      <el-card class="footer flex flex-justify-end flex-items-center">
        <el-button type="primary" @click="save" class="p-l-6 p-r-6 m-r-3"
          >保存</el-button
        >
        <el-button @click="back" class="p-l-6 p-r-6">返回</el-button>
      </el-card>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { onMounted, ref, reactive } from "vue";
import baseTable from "@@/components/baseTable/baseTable.vue";
import pagination from "@@/components/pagination/pagination.vue";
import type { PaginatedRequest } from "@@/apis/tables/type";
import {
  queryEmployeeConditions,
  deleteEmployee,
  findEmployeePage,
  Employee,
} from "../api/employee";
import { Department, getDepartmentList } from "../api/department";
import { getRoleList } from "../api/role";
import { indexMethod } from "@@/utils/page";
import Create from "./create.vue";
import { ElMessage } from "element-plus";
import { watchDebounced } from "@vueuse/core";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();

const enableDelete = permissionStore.hasPermission(
  ModuleCode.Employee,
  PermissionAction.Delete,
);
const enableCreate = permissionStore.hasPermission(
  ModuleCode.Employee,
  PermissionAction.Add,
);
const enableEdit = permissionStore.hasPermission(
  ModuleCode.Employee,
  PermissionAction.Edit,
);
const createRef = ref();
const selectProps = { value: "id", label: "name" };
const departmentOptions = ref([{ name: "全部", id: 0 }]);
const roleOptions = ref([{ name: "全部", id: 0 }]);
const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const columns = ref<any[]>([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "username", label: "用户名" },
  { prop: "code", label: "编码" },
  { prop: "realName", label: "真实姓名" },
  { prop: "departmentId", label: "部门" },
  { prop: "roleId", label: "角色" },
  { prop: "gender", label: "性别" },
  { prop: "phone", label: "电话" },
  { prop: "status", label: "状态" },
]);
if (enableDelete || enableCreate || enableEdit) {
  columns.value.push({ prop: "operate", label: "操作", width: 100 });
}

//分页
const pageSize = ref(10);
const currentPage = ref(0);
const totalItems = ref(0);
const pageChange = (page: any) => {
  currentPage.value = page - 1;
  refreshTable();
};
const currentData = ref<Employee | null>(null);
const edit = (row: Employee) => {
  currentData.value = row;
  processFlag.value = 1;
};

const tableData = ref<Employee[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryEmployeeConditions>({
  code: "",
  realName: "",
  departmentId: 0,
  roleId: 0,
});

watchDebounced(
  searchData,
  () => {
    refreshTable();
  },
  { debounce: 500, maxWait: 1000 },
);
function refreshTable() {
  loading.value = true;
  const params: PaginatedRequest<queryEmployeeConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.code.length) params.code = searchData.code;
  if (searchData.realName.length) params.realName = searchData.realName;
  if (searchData.departmentId) params.departmentId = searchData.departmentId;
  if (searchData.roleId) params.roleId = searchData.roleId;
  findEmployeePage(params)
    .then((res: any) => {
      const { total, list } = res.data;
      totalItems.value = total;
      tableData.value = list;
    })
    .catch(() => {
      tableData.value = [];
    })
    .finally(() => {
      loading.value = false;
    });
}
const create = () => {
  processFlag.value = 1;
};
const save = () => {
  currentData.value = null;
  createRef.value.confirmSave(() => {
    back();
  });
};
const back = () => {
  processFlag.value = 0;
  currentData.value = null;
  refreshTable();
};
const remove = async (id: string) => {
  await deleteEmployee(id);
  ElMessage({
    type: "success",
    message: "删除成功",
  });
  refreshTable();
};
function buildDepartmentTree(departments: Department[]) {
  const map = new Map();

  // 第一步：创建所有部门的映射并初始化children
  departments.forEach((dept: Department) => {
    map.set(dept.id, {
      ...dept,
      children: [],
    });
  });

  // 第二步：建立所有层级的父子关系
  departments.forEach((dept: Department) => {
    const current = map.get(dept.id);
    if (dept.parentId !== 0) {
      const parent = map.get(dept.parentId);
      if (parent) {
        parent.children.push(current);
      }
    }
  });

  // 第三步：收集顶级部门
  return departments
    .filter((dept: Department) => dept.parentId === 0)
    .map((dept: Department) => map.get(dept.id));
}
const departmentMap = ref(new Map());
const queryDepartmentOptions = async () => {
  const res = await getDepartmentList();
  if ((res as any)?.data?.length) {
    departmentOptions.value = buildDepartmentTree((res as any)?.data || []);
    const all = { id: 0, name: "全部", children: [] };
    departmentOptions.value.unshift(all);
    departmentMap.value.clear();
    (res as any)?.data.map((item: any) => {
      departmentMap.value.set(item.id, item.name);
    });
  }
};
const roleMap = ref(new Map());
const queryRoleOptions = async () => {
  const res = await getRoleList();
  if ((res as any)?.data?.length) {
    roleMap.value.clear();
    (res as any)?.data.map((item: any) => {
      roleOptions.value.push(item);
      roleMap.value.set(item.id, item.name);
    });
  }
};
const getName = (id: string, mapData: Map<string, string>) => {
  return mapData.get(id) ?? "无";
};
onMounted(async () => {
  await queryDepartmentOptions();
  await queryRoleOptions();
  refreshTable();
});
</script>

<style lang="scss" scoped>
@use "@@/assets/styles/size.scss" as *;
.table-card {
  height: calc(100% - zrem(110));
}
.table-wrap {
  height: calc(100% - zrem(45));
}

.search-wrapper {
  height: zrem(60);
  margin-bottom: zrem(10);
}

.pager-wrapper {
  display: flex;
  justify-content: flex-end;
}
.create-wrap {
  height: calc(100% - zrem(45));
}
.footer {
  height: zrem(45);
}
</style>
