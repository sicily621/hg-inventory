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
                @change="changeWarehouse()"
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
            <el-form-item label="商品分类">
              <el-tree-select
                class="w-40"
                v-model="categoryId"
                placeholder="请选择商品分类"
                :data="categoryOptions"
                check-strictly
                :render-after-expand="false"
                :props="selectProps"
                @change="queryProductOptions"
              />
            </el-form-item>
            <el-form-item prop="productId" label="商品">
              <el-select
                v-model="searchData.productId"
                placeholder="请选择商品"
                @change="refreshTable()"
                class="w-40"
              >
                <el-option
                  v-for="item in productOptions"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
            <el-form-item prop="type" label="类型">
              <el-select
                v-model="searchData.type"
                placeholder="请选择类型"
                @change="refreshTable()"
                class="w-40"
              >
                <el-option
                  v-for="item in allHistoryTypeList"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
          </el-form>
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
            <template #productId="scope">
              {{ getItem(scope.scope.row.productId, productMap)?.name }}
            </template>
            <template #warehouseId="scope">
              {{ getItem(scope.scope.row.warehouseId, warehouseMap)?.name }}
            </template>
            <template #shelfId="scope">
              {{ getItem(scope.scope.row.shelfId, shelfMap)?.name }}
            </template>
            <template #areaId="scope">
              {{ getItem(scope.scope.row.areaId, areaMap)?.name }}
            </template>
            <template #employeeId="scope">
              {{ getItem(scope.scope.row.employeeId, employeeMap) }}
            </template>
            <template #type="scope">
              <el-tag type="primary">
                {{ getStatus(scope.scope.row.type, HistoryTypeList) }}
              </el-tag></template
            >
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
  </div>
</template>
<script lang="ts" setup>
import { onMounted, ref, reactive } from "vue";
import baseTable from "@@/components/baseTable/baseTable.vue";
import pagination from "@@/components/pagination/pagination.vue";
import type { PaginatedRequest } from "@@/apis/tables/type";
import {
  queryHistoryConditions,
  findHistoryPage,
  History,
  HistoryTypeList,
} from "../api/history";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import { getProductList } from "@/pages/productManagement/api/product";
import { getWarehouseList } from "@/pages/warehouseManagement/api/warehouse";
import { getAreaList } from "@/pages/warehouseManagement/api/area";
import { getShelfList } from "@/pages/warehouseManagement/api/shelf";
import {
  Category,
  getCategoryList,
} from "@/pages/productManagement/api/category";
import { indexMethod } from "@@/utils/page";
const allHistoryTypeList = [{ id: 0, name: "全部" }, ...HistoryTypeList];
const selectProps = { value: "id", label: "name" };
const loading = ref<boolean>(false);
const processFlag = ref(0);
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "productId", label: "商品" },
  { prop: "warehouseId", label: "仓库" },
  { prop: "shelfId", label: "货架" },
  { prop: "areaId", label: "区域" },
  { prop: "type", label: "操作类型" },
  { prop: "quantity", label: "变动数量" },
  { prop: "createTime", label: "操作时间" },
  { prop: "employeeId", label: "操作人" },
]);

//分页
const pageSize = ref(10);
const currentPage = ref(0);
const totalItems = ref(0);
const pageChange = (page: any) => {
  currentPage.value = page - 1;
  refreshTable();
};
const tableData = ref<History[]>([]);
const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryHistoryConditions>({
  productId: "",
  warehouseId: "",
  employeeId: "",
  type: 0,
});
function refreshTable() {
  loading.value = true;
  const params: PaginatedRequest<queryHistoryConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.productId) params.productId = searchData.productId;
  if (searchData.warehouseId) params.warehouseId = searchData.warehouseId;
  if (searchData.employeeId) params.employeeId = searchData.employeeId;
  if (searchData.type) params.type = searchData.type;
  findHistoryPage(params)
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
const categoryId = ref(0);
const categoryOptions = ref([{ name: "全部", id: 0 }]);
const productOptions = ref<any[]>([]);
const shelfOptions = ref<any[]>([]);
const categoryMap = ref(new Map());
const queryCategoryOptions = async () => {
  const res = await getCategoryList();
  if ((res as any)?.data?.length) {
    categoryOptions.value = buildCategoryTree((res as any)?.data || []);
    categoryOptions.value.unshift({ name: "全部", id: 0 });
  }
};
const productMap = ref(new Map());
const queryProductOptions = async () => {
  const parmas: any = {};
  if (categoryId.value) parmas.categoryId = categoryId.value;
  const res = await getProductList(parmas);
  const { data } = res as any;
  productOptions.value = data;
  productOptions.value.unshift({ name: "全部", id: 0 });
  searchData.productId = 0;
  data.forEach((item: any) => {
    const { id } = item;
    productMap.value.set(id, item);
  });
};
const warehouseOptions = ref<any[]>([]);
const changeWarehouse = async () => {
  await queryAreaOptions();
  await queryShelfOptions();
};
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
const areaOptions = ref<any[]>([]);
const areaMap = ref(new Map());
const queryAreaOptions = async () => {
  const parmas: any = {};
  if (searchData.warehouseId) parmas.warehouseId = searchData.warehouseId;
  const res = await getAreaList(parmas);
  const { data } = res as any;
  areaOptions.value = data;
  areaOptions.value.unshift({ name: "全部", id: 0 });
  shelfOptions.value = [{ name: "全部", id: 0 }];
  data.forEach((item: any) => {
    const { id } = item;
    areaMap.value.set(id, item);
  });
};
const shelfMap = ref(new Map());
const queryShelfOptions = async () => {
  const parmas: any = {};
  const res = await getShelfList(parmas);
  const { data } = res as any;
  shelfOptions.value = data;
  shelfOptions.value.unshift({ name: "全部", id: 0 });
  data.forEach((item: any) => {
    const { id } = item;
    shelfMap.value.set(id, item);
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
const getItem = (id: string, mapData: Map<string, any>) => {
  return mapData.get(id);
};
const getStatus = (id: string, list: any[]) => {
  return list.find((item) => item.id === id)?.name ?? "无";
};
onMounted(async () => {
  await queryCategoryOptions();
  await queryProductOptions();
  await queryWarehouseOptions();
  await queryAreaOptions();
  await queryShelfOptions();
  await queryEmployeeOptions();
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
