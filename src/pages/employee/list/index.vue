<template>
  <div class="app-container flex flex-col">
    <el-card v-loading="loading" shadow="never" class="search-wrapper">
      <el-form ref="searchFormRef" :inline="true" :model="searchData">
        <el-form-item prop="code" label="编码">
          <el-input v-model="searchData.code" placeholder="请输入" />
        </el-form-item>
        <el-form-item prop="realName" label="姓名">
          <el-input v-model="searchData.realName" placeholder="请输入" />
        </el-form-item>
        <el-form-item prop="departmentId" label="部门">
          <el-select
            v-model="searchData.departmentId"
            placeholder="请选择部门"
            class="w-40"
          >
            <el-option
              v-for="item in departmentOptions"
              :key="item.value"
              :label="item.name"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item prop="roleId" label="角色">
          <el-select
            v-model="searchData.roleId"
            placeholder="请选择角色"
            class="w-40"
          >
            <el-option
              v-for="item in roleOptions"
              :key="item.value"
              :label="item.name"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleSearch">
            查询
          </el-button>
          <el-button :icon="Refresh" @click="resetSearch"> 重置 </el-button>
        </el-form-item>
      </el-form>
    </el-card>
    <div
      v-loading="loading"
      class="flex-grow-1 flex flex-col el-card"
      shadow="never"
    >
      <!-- <div class="toolbar-wrapper">
        <div>
          <el-button
            type="primary"
            :icon="CirclePlus"
            @click="dialogVisible = true"
          >
            新增用户
          </el-button>
          <el-button type="danger" :icon="Delete"> 批量删除 </el-button>
        </div>
        <div>
          <el-tooltip content="下载">
            <el-button type="primary" :icon="Download" circle />
          </el-tooltip>
          <el-tooltip content="刷新当前页">
            <el-button
              type="primary"
              :icon="RefreshRight"
              circle
              @click="getTableData"
            />
          </el-tooltip>
        </div>
      </div> -->
      <div class="flex-grow-1">
        <baseTable :columns="columns" :table-data="tableData">
          <template #status="scope">
            <el-tag :type="scope.scope.row.status ? 'primary' : 'warning'">{{
              scope.scope.row.status ? "在职" : "离职"
            }}</el-tag>
          </template>
          <template #operate="scope">
            <el-icon class="fz20 pointer m-r-5" text>
              <Edit />
            </el-icon>
            <el-icon class="fz20 pointer" text>
              <Delete />
            </el-icon>
          </template>
        </baseTable>
      </div>
      <div class="pager-wrapper h-12 p-r-4">
        <el-pagination
          background
          :layout="paginationData.layout"
          :page-sizes="paginationData.pageSizes"
          :total="paginationData.total"
          :page-size="paginationData.pageSize"
          :current-page="paginationData.currentPage"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </div>
    <!-- 新增/修改 -->
    <!-- <el-dialog
      v-model="dialogVisible"
      :title="formData.id === undefined ? '新增用户' : '修改用户'"
      width="30%"
      @closed="resetForm"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
        label-position="left"
      >
        <el-form-item prop="username" label="用户名">
          <el-input v-model="formData.username" placeholder="请输入" />
        </el-form-item>
        <el-form-item
          v-if="formData.id === undefined"
          prop="password"
          label="密码"
        >
          <el-input v-model="formData.password" placeholder="请输入" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false"> 取消 </el-button>
        <el-button
          type="primary"
          :loading="loading"
          @click="handleCreateOrUpdate"
        >
          确认
        </el-button>
      </template>
    </el-dialog> -->
  </div>
</template>
<script lang="ts" setup>
import baseTable from "@/common/components/baseTable/baseTable.vue";
import type { PaginatedRequest, TableData } from "@@/apis/tables/type";
import {
  queryEmployeeConditions,
  createEmployee,
  editEmployee,
  deleteEmployee,
  findEmployeePage,
} from "../api/employee";
import type { FormRules } from "element-plus";
import {
  createTableDataApi,
  deleteTableDataApi,
  getTableDataApi,
  updateTableDataApi,
} from "@@/apis/tables";
import { usePagination } from "@@/composables/usePagination";
import {
  CirclePlus,
  Delete,
  Download,
  Refresh,
  RefreshRight,
  Search,
} from "@element-plus/icons-vue";
import { cloneDeep } from "lodash-es";

const departmentOptions = ref([{ name: "全部", value: 0 }]);
const roleOptions = ref([{ name: "全部", value: 0 }]);
const loading = ref<boolean>(false);

const columns = ref([
  { prop: "index", label: "序号", width: "100" },
  { prop: "username", label: "用户名" },
  { prop: "code", label: "编码" },
  { prop: "realName", label: "真实姓名" },
  { prop: "departmentId", label: "部门" },
  { prop: "roleId", label: "角色" },
  { prop: "gender", label: "性别" },
  { prop: "phone", label: "电话" },
  { prop: "status", label: "状态" },
  { prop: "operate", label: "操作", width: 100 },
]);

const { paginationData, handleCurrentChange, handleSizeChange } =
  usePagination();

const DEFAULT_FORM_DATA: queryEmployeeConditions = {
  code: "",
  realName: "",
  departmentId: 0,
  roleId: 0,
};

const dialogVisible = ref<boolean>(false);

// const formRef = useTemplateRef("formRef");

const formData = ref<queryEmployeeConditions>(cloneDeep(DEFAULT_FORM_DATA));

const formRules: FormRules<queryEmployeeConditions> = {
  // username: [{ required: true, trigger: "blur", message: "请输入用户名" }],
  // password: [{ required: true, trigger: "blur", message: "请输入密码" }],
};

// function handleCreateOrUpdate() {
//   formRef.value?.validate((valid) => {
//     if (!valid) {
//       ElMessage.error("表单校验不通过");
//       return;
//     }
//     loading.value = true;
//     const api = formData.value.id === undefined ? createEmployee : editEmployee;
//     api(formData.value)
//       .then(() => {
//         ElMessage.success("操作成功");
//         dialogVisible.value = false;
//         getTableData();
//       })
//       .finally(() => {
//         loading.value = false;
//       });
//   });
// }

function resetForm() {
  // formRef.value?.clearValidate();
  formData.value = cloneDeep(DEFAULT_FORM_DATA);
}
// #endregion

// #region 删
function handleDelete(row: TableData) {
  ElMessageBox.confirm(`正在删除用户：${row.username}，确认删除？`, "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  }).then(() => {
    deleteTableDataApi(row.id).then(() => {
      ElMessage.success("删除成功");
      getTableData();
    });
  });
}
function handleUpdate(row: TableData) {
  dialogVisible.value = true;
  // formData.value = cloneDeep(row);
}

const tableData = ref<TableData[]>([]);

const searchFormRef = useTemplateRef("searchFormRef");

const searchData = reactive<queryEmployeeConditions>({
  code: "",
  realName: "",
  departmentId: 0,
  roleId: 0,
});

function getTableData() {
  loading.value = true;
  const params: PaginatedRequest<queryEmployeeConditions> = {
    currentPage: 1,
    size: 10,
  };
  if (searchData.code.length) params.code = searchData.code;
  if (searchData.realName.length) params.realName = searchData.realName;
  if (searchData.departmentId) params.departmentId = searchData.departmentId;
  if (searchData.roleId) params.roleId = searchData.roleId;
  findEmployeePage(params)
    .then((res: any) => {
      const { total, list } = res.data;
      paginationData.total = total;
      tableData.value = list;
    })
    .catch(() => {
      tableData.value = [];
    })
    .finally(() => {
      loading.value = false;
    });
}

function handleSearch() {
  paginationData.currentPage === 1
    ? getTableData()
    : (paginationData.currentPage = 1);
}

function resetSearch() {
  searchFormRef.value?.resetFields();
  handleSearch();
}
// #endregion

// 监听分页参数的变化
watch(
  [() => paginationData.currentPage, () => paginationData.pageSize],
  getTableData,
  { immediate: true }
);
</script>

<style lang="scss" scoped>
.el-alert {
  margin-bottom: 20px;
}

.search-wrapper {
  margin-bottom: 20px;
  :deep(.el-card__body) {
    padding-bottom: 2px;
  }
}

.toolbar-wrapper {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
}

.table-wrapper {
  margin-bottom: 20px;
}

.pager-wrapper {
  display: flex;
  justify-content: flex-end;
}
</style>
