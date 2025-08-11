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
            <el-form-item prop="moduleCode" label="模块编码">
              <el-input v-model="searchData.moduleCode" placeholder="请输入" />
            </el-form-item>
          </el-form>
          <el-button type="primary" @click="create">新增</el-button>
        </div>
      </el-card>
      <div
        v-loading="loading"
        class="flex-grow-1 flex flex-col el-card table-card"
        shadow="never"
      >
        <div class="table-wrap">
          <div class="table-wrap">
            <el-table
              :data="tableData"
              row-key="id"
              default-expand-all
              highlight-current-row
              stripe
            >
              <el-table-column prop="name" label="名称" />
              <el-table-column prop="moduleCode" label="模块编码" />
              <el-table-column prop="url" label="模块路径" :width="300" />
              <el-table-column prop="action" label="操作类型">
                <template #default="scope">
                  {{ getName(scope.row.action, PermissionActionList) }}
                </template>
              </el-table-column>
              <el-table-column prop="type" label="权限类型">
                <template #default="scope">
                  {{ getName(scope.row.type, PermissionTypeList) }}
                </template>
              </el-table-column>
              <el-table-column prop="description" label="描述" />
              <el-table-column prop="operate" label="操作" :width="150">
                <template #default="scope">
                  <div class="flex">
                    <el-icon
                      class="fz16 pointer m-r-5 cursor-pointer"
                      text
                      @click="edit(scope.row)"
                    >
                      <Edit />
                    </el-icon>
                    <el-icon
                      class="fz16 pointer m-r-5 cursor-pointer"
                      text
                      @click="addSubPermission(scope.row)"
                    >
                      <Plus />
                    </el-icon>
                    <el-icon
                      class="fz16 cursor-pointer"
                      text
                      @click="remove(scope.row.id)"
                    >
                      <Delete />
                    </el-icon>
                  </div>
                </template>
              </el-table-column>
            </el-table>
          </div>
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
import pagination from "@@/components/pagination/pagination.vue";
import type { PaginatedRequest } from "@@/apis/tables/type";
import {
  queryPermissionConditions,
  deletePermission,
  findPermissionPage,
  Permission,
  PermissionActionList,
  PermissionTypeList,
} from "../api/permission";
import Create from "./create.vue";
import { watchDebounced } from "@vueuse/core";
import { ElMessage } from "element-plus";

const createRef = ref();
const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const getName = (value: number, list: any[]) => {
  const result = list.find((item) => item.id == value);
  return result?.name ?? "";
};
//分页
const pageSize = ref(1000);
const currentPage = ref(0);
const totalItems = ref(0);
const pageChange = (page: any) => {
  currentPage.value = page - 1;
  refreshTable();
};
const currentData = ref<Permission | null>(null);
const edit = (row: Permission) => {
  currentData.value = row;
  processFlag.value = 1;
};

const tableData = ref<Permission[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryPermissionConditions>({
  moduleCode: "",
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
  const params: PaginatedRequest<queryPermissionConditions> = {
    currentPage: currentPage.value,
    size: pageSize.value,
  };
  if (searchData.moduleCode.length) params.moduleCode = searchData.moduleCode;
  findPermissionPage(params)
    .then((res: any) => {
      const { total, list } = res.data;
      totalItems.value = total;
      tableData.value = buildPermissionTree(list);
    })
    .catch(() => {
      tableData.value = [];
    })
    .finally(() => {
      loading.value = false;
    });
}
function buildPermissionTree(permissions: Permission[]) {
  const map = new Map();

  // 第一步：创建所有部门的映射并初始化children
  permissions.forEach((dept: Permission) => {
    map.set(dept.id, {
      ...dept,
      children: [],
    });
  });

  // 第二步：建立所有层级的父子关系
  permissions.forEach((dept: Permission) => {
    const current = map.get(dept.id);
    if (dept.parentId !== 0) {
      const parent = map.get(dept.parentId);
      if (parent) {
        parent.children.push(current);
      }
    }
  });

  // 第三步：收集顶级部门
  return permissions
    .filter((dept: Permission) => dept.parentId === 0)
    .map((dept: Permission) => map.get(dept.id));
}
const create = () => {
  currentData.value = null;
  processFlag.value = 1;
};
const save = () => {
  currentData.value = null;
  createRef.value.confirmSave(() => {
    back();
  });
};
const addSubPermission = (row: any) => {
  currentData.value = {
    name: "",
    moduleCode: "",
    parentId: row.id,
    url: "",
    description: "",
    action: 1,
    type: 1,
  };
  processFlag.value = 1;
};
const back = () => {
  processFlag.value = 0;
  currentData.value = null;
  refreshTable();
};
const remove = async (id: string) => {
  await deletePermission(id);
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
  height: 100%;
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
