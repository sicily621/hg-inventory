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
            <template #status="scope">
              <el-tag :type="scope.scope.row.status ? 'primary' : 'warning'">{{
                scope.scope.row.status ? "启用" : "禁用"
              }}</el-tag>
            </template>
            <template #operate="scope">
              <div class="flex">
                <el-icon
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  @click="edit(scope.scope.row)"
                  v-if="enableEdit"
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
  queryRoleConditions,
  deleteRole,
  findRolePage,
  Role,
} from "../api/role";
import { indexMethod } from "@@/utils/page";
import Create from "./create.vue";
import { watchDebounced } from "@vueuse/core";
import { ElMessage } from "element-plus";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();

const enableDelete = permissionStore.hasPermission(
  ModuleCode.Role,
  PermissionAction.Delete,
);
const enableCreate = permissionStore.hasPermission(
  ModuleCode.Role,
  PermissionAction.Add,
);
const enableEdit = permissionStore.hasPermission(
  ModuleCode.Role,
  PermissionAction.Edit,
);
const createRef = ref();
const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const columns = ref<any[]>([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "name", label: "名称" },
  { prop: "code", label: "编码" },
  { prop: "description", label: "描述" },
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
const currentData = ref<Role | null>(null);
const edit = (row: Role) => {
  currentData.value = row;
  processFlag.value = 1;
};

const tableData = ref<Role[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryRoleConditions>({
  code: "",
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
  const params: PaginatedRequest<queryRoleConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.code.length) params.code = searchData.code;
  findRolePage(params)
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
  await deleteRole(id);
  ElMessage({
    type: "success",
    message: "删除成功",
  });
  refreshTable();
};

onMounted(async () => {
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
