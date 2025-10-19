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
            <el-form-item prop="name" label="名称">
              <el-input v-model="searchData.name" placeholder="请输入" />
            </el-form-item>
            <el-form-item prop="code" label="编码">
              <el-input v-model="searchData.code" placeholder="请输入" />
            </el-form-item>
            <el-form-item prop="categoryId" label="商品分类">
              <el-tree-select
                class="w-40"
                v-model="searchData.categoryId"
                placeholder="请选择部门"
                :data="categoryOptions"
                check-strictly
                :render-after-expand="false"
                :props="selectProps"
              />
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
            <template #categoryId="scope">
              {{ getName(scope.scope.row.categoryId, categoryMap) }}
            </template>
            <template #purchasePrice="scope">
              <el-tag type="primary"
                >￥{{ scope.scope.row.purchasePrice }}</el-tag
              >
            </template>
            <template #retailPrice="scope">
              <el-tag type="danger">￥{{ scope.scope.row.retailPrice }}</el-tag>
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
                  v-if="enableDelete"
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
  queryProductConditions,
  deleteProduct,
  findProductPage,
  Product,
} from "../api/product";
import { Category, getCategoryList } from "../api/category";
import { indexMethod } from "@@/utils/page";
import Create from "./create.vue";
import { watchDebounced } from "@vueuse/core";
import { ElMessage } from "element-plus";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();

const enableDelete = permissionStore.hasPermission(
  ModuleCode.Product,
  PermissionAction.Delete,
);
const enableCreate = permissionStore.hasPermission(
  ModuleCode.Product,
  PermissionAction.Add,
);
const enableEdit = permissionStore.hasPermission(
  ModuleCode.Product,
  PermissionAction.Edit,
);

const createRef = ref();
const selectProps = { value: "id", label: "name" };
const categoryOptions = ref([{ name: "全部", id: 0 }]);
const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const columns = ref<any[]>([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "name", label: "名称" },
  { prop: "code", label: "编码" },
  { prop: "categoryId", label: "商品分类" },
  { prop: "purchasePrice", label: "采购价" },
  { prop: "retailPrice", label: "零售价" },
  { prop: "specification", label: "规格" },
  { prop: "unit", label: "单位" },
  { prop: "brand", label: "品牌" },
  { prop: "barcode", label: "条形码" },
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
const currentData = ref<Product | null>(null);
const edit = (row: Product) => {
  currentData.value = row;
  processFlag.value = 1;
};

const tableData = ref<Product[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryProductConditions>({
  code: "",
  categoryId: 0,
  name: "",
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
  const params: PaginatedRequest<queryProductConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.code.length) params.code = searchData.code;
  if (searchData.name.length) params.name = searchData.name;
  if (searchData.categoryId) params.categoryId = searchData.categoryId;
  findProductPage(params)
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
  await deleteProduct(id);
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

const getName = (id: string, mapData: Map<string, string>) => {
  return mapData.get(id) ?? "无";
};
onMounted(async () => {
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
