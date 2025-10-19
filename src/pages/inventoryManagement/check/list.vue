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
            <el-form-item prop="warehouseId" label="仓库">
              <el-select
                v-model="searchData.warehouseId"
                placeholder="请选择仓库"
                @change="refreshTable()"
                class="w-40"
              >
                <el-option
                  v-for="item in warehouseOptions"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
            <el-form-item prop="code" label="编码">
              <el-input v-model="searchData.code" placeholder="请输入" />
            </el-form-item>
            <el-form-item prop="employeeId" label="操作人">
              <el-select
                v-model="searchData.employeeId"
                placeholder="请选择操作人"
                @change="refreshTable()"
                class="w-40"
              >
                <el-option
                  v-for="item in employeeOptions"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
            <el-form-item prop="status" label="状态">
              <el-select
                v-model="searchData.status"
                placeholder="请选择状态"
                @change="refreshTable()"
                class="w-40"
              >
                <el-option
                  v-for="item in allCheckStatusList"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
          </el-form>
          <el-button type="primary" @click="create" v-if="enableCreate"
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
            <template #warehouseId="scope">
              {{ getItem(scope.scope.row.warehouseId, warehouseMap)?.name }}
            </template>
            <template #employeeId="scope">
              {{ getItem(scope.scope.row.employeeId, employeeMap) }}
            </template>
            <template #status="scope">
              <el-tag type="primary">
                {{ getStatus(scope.scope.row.status, CheckStatusList) }}
              </el-tag></template
            >
            <template #operate="scope">
              <div class="flex">
                <el-icon
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  v-if="enableEdit"
                  @click="edit(scope.scope.row)"
                >
                  <View
                    v-if="scope.scope.row.status === CheckStatus.Completed"
                  />
                  <Edit v-else />
                </el-icon>
                <el-icon
                  class="fz16 cursor-pointer"
                  text
                  v-if="
                    scope.scope.row.status !== CheckStatus.Completed &&
                    enableDelete
                  "
                  @click="remove(scope.scope.row.id)"
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
        <el-button
          type="primary"
          v-if="currentData?.status !== CheckStatus.Completed"
          @click="save"
          class="p-l-6 p-r-6 m-r-3"
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
  queryCheckConditions,
  deleteCheck,
  findCheckPage,
  Check,
  CheckStatusList,
  CheckStatus,
} from "../api/check";
import { getWarehouseList } from "@/pages/warehouseManagement/api/warehouse";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import {
  Category,
  getCategoryList,
} from "@/pages/productManagement/api/category";
import { indexMethod } from "@@/utils/page";
import Create from "./create.vue";
import { watchDebounced } from "@vueuse/core";
import { ElMessage } from "element-plus";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();
const enableDelete = permissionStore.hasPermission(
  ModuleCode.InventoryCheck,
  PermissionAction.Delete,
);
const enableCreate = permissionStore.hasPermission(
  ModuleCode.InventoryCheck,
  PermissionAction.Add,
);
const enableEdit = permissionStore.hasPermission(
  ModuleCode.InventoryCheck,
  PermissionAction.Edit,
);
const allCheckStatusList = [{ id: 0, name: "全部" }, ...CheckStatusList];
const createRef = ref();
const categoryOptions = ref([{ name: "全部", id: 0 }]);
const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "code", label: "编码" },
  { prop: "warehouseId", label: "仓库" },
  { prop: "employeeId", label: "操作人" },
  { prop: "status", label: "状态" },
  { prop: "description", label: "描述" },
  { prop: "operate", label: "操作", width: 100 },
]);

//分页
const pageSize = ref(10);
const currentPage = ref(0);
const totalItems = ref(0);
const pageChange = (page: any) => {
  currentPage.value = page - 1;
  refreshTable();
};
const currentData = ref<Check | null>(null);
const edit = (row: Check) => {
  currentData.value = row;
  processFlag.value = 1;
};

const tableData = ref<Check[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryCheckConditions>({
  code: "",
  warehouseId: "",
  employeeId: "",
  status: 0,
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
  const params: PaginatedRequest<queryCheckConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.code.length) params.code = searchData.code;
  if (searchData.warehouseId) params.warehouseId = searchData.warehouseId;
  if (searchData.employeeId) params.employeeId = searchData.employeeId;
  if (searchData.status) params.status = searchData.status;
  findCheckPage(params)
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
const getItem = (id: string, mapData: Map<string, any>) => {
  return mapData.get(id);
};
const getStatus = (id: string, list: any[]) => {
  return list.find((item) => item.id === id)?.name ?? "无";
};
const warehouseOptions = ref<any[]>([]);
const warehouseMap = ref(new Map());
const queryWarehouseOptions = async () => {
  const res = await getWarehouseList({});
  const { data } = res as any;
  warehouseOptions.value = data;
  searchData.warehouseId = data?.[0]?.id || 0;
  warehouseOptions.value.unshift({ name: "全部", id: 0 });
  data.forEach((item: any) => {
    const { id } = item;
    warehouseMap.value.set(id, item);
  });
};
const employeeMap = ref(new Map());
const employeeOptions = ref<any[]>([]);
const queryEmployeeOptions = async () => {
  const res = await getEmployeeList({});
  employeeMap.value.clear();
  employeeOptions.value = [];
  if ((res as any)?.data?.length) {
    (res as any)?.data.map((item: any) => {
      const { id, username: name } = item;
      employeeMap.value.set(id, name);
      employeeOptions.value.push({ id, name });
    });
  }
  const all = { id: 0, name: "全部" };
  employeeOptions.value.unshift(all);
  searchData.employeeId = 0;
};
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
  await deleteCheck(id);
  ElMessage({
    type: "success",
    message: "删除成功",
  });
  refreshTable();
};
function buildCategoryTree(categorys: Category[]) {
  const map = new Map();
  categoryMap.value.clear();
  // 第一步：创建所有部门的映射并初始化children
  categorys.forEach((dept: Category) => {
    categoryMap.value.set(dept.id, dept.name);
    map.set(dept.id, {
      ...dept,
      children: [],
    });
  });
  // 第二步：建立所有层级的父子关系
  categorys.forEach((dept: Category) => {
    const current = map.get(dept.id);
    if (dept.parentId !== 0) {
      const parent = map.get(dept.parentId);
      if (parent) {
        parent.children.push(current);
      }
    }
  });

  // 第三步：收集顶级部门
  return categorys
    .filter((dept: Category) => dept.parentId === 0)
    .map((dept: Category) => map.get(dept.id));
}
const categoryMap = ref(new Map());
const queryCategoryOptions = async () => {
  const res = await getCategoryList();
  if ((res as any)?.data?.length) {
    categoryOptions.value = buildCategoryTree((res as any)?.data || []);
    const all = { id: 0, name: "全部", children: [] };
    categoryOptions.value.unshift(all);
  }
};

onMounted(async () => {
  await queryWarehouseOptions();
  await queryEmployeeOptions();
  await queryCategoryOptions();
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
