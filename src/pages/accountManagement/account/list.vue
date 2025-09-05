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
            <el-form-item prop="type" label="类型">
              <el-select
                v-model="searchData.type"
                placeholder="请选择类型"
                class="w-40"
              >
                <el-option
                  v-for="item in allAccountTypeList"
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
                class="w-40"
              >
                <el-option
                  v-for="item in allAccountStatusList"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
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
          <baseTable
            :columns="columns"
            :table-data="tableData"
            :indexMethod="indexMethod(currentPage, pageSize)"
            class="h-full"
          >
            <template #type="scope">
              {{ getStatus(scope.scope.row.type, AccountActionList) }}
            </template>
            <template #relatedEntityType="scope">
              {{
                getStatus(scope.scope.row.relatedEntityType, AccountTypeList)
              }}
            </template>
            <template #employeeId="scope">
              {{ getName(scope.scope.row.employeeId, employeeMap) }}
            </template>
            <template #relatedEntityId="scope">
              {{
                getName(
                  scope.scope.row.relatedEntityId,
                  scope.scope.row.relatedEntityType === 1
                    ? supplierMap
                    : customerMap,
                )
              }}
            </template>
            <template #status="scope">
              <el-tag>
                {{ getStatus(scope.scope.row.status, AccountStatusList) }}
              </el-tag>
            </template>
            <template #operate="scope">
              <div class="flex">
                <el-icon
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  @click="edit(scope.scope.row)"
                >
                  <Edit />
                </el-icon>
                <el-icon
                  class="fz16 cursor-pointer"
                  text
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
  </div>
</template>
<script lang="ts" setup>
import { onMounted, ref, reactive } from "vue";
import baseTable from "@@/components/baseTable/baseTable.vue";
import pagination from "@@/components/pagination/pagination.vue";
import type { PaginatedRequest } from "@@/apis/tables/type";
import {
  queryAccountConditions,
  deleteAccount,
  findAccountPage,
  Account,
  AccountStatus,
  AccountStatusList,
  AccountTypeList,
  RelatedEntityType,
  AccountActionList,
} from "../api/account";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import { getCustomerList } from "@/pages/saleManagement/api/customer";
import { getSupplierList } from "@/pages/purchaseManagement/api/supplier";
import { indexMethod } from "@@/utils/page";
import { watchDebounced } from "@vueuse/core";
import { ElMessage } from "element-plus";
const allAccountTypeList = [{ id: 0, name: "全部" }, ...AccountTypeList];
const allAccountStatusList = [{ id: 0, name: "全部" }, ...AccountStatusList];
const createRef = ref();
const selectProps = { value: "id", label: "name" };
const categoryOptions = ref([{ name: "全部", id: 0 }]);
const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  // { prop: "orderId", label: "订单" },
  { prop: "createTime", label: "创建时间" },
  { prop: "type", label: "类型" },
  { prop: "relatedEntityType", label: "往来单位类型" },
  { prop: "relatedEntityId", label: "往来单位" },
  { prop: "amount", label: "金额" },
  { prop: "paymentMethod", label: "支付方式" },
  { prop: "bankName", label: "银行名称" },
  { prop: "employeeId", label: "收银员" },
  { prop: "status", label: "状态" },
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
const currentData = ref<Account | null>(null);
const edit = (row: Account) => {
  currentData.value = row;
  processFlag.value = 1;
};

const tableData = ref<Account[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryAccountConditions>({
  orderId: "",
  type: 0,
  relatedEntityId: "",
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
  const params: PaginatedRequest<queryAccountConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.orderId.length) params.orderId = searchData.orderId;
  if (searchData.type) params.type = searchData.type;
  if (searchData.relatedEntityId.length)
    params.relatedEntityId = searchData.relatedEntityId;
  if (searchData.employeeId.length) params.employeeId = searchData.employeeId;
  if (searchData.status) params.status = searchData.status;
  findAccountPage(params)
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
const getStatus = (id: string, list: any[]) => {
  return list.find((item) => item.id === id)?.name ?? "无";
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
  await deleteAccount(id);
  ElMessage({
    type: "success",
    message: "删除成功",
  });
  refreshTable();
};
const getName = (id: string, mapData: Map<string, string>) => {
  return mapData.get(id) ?? "无";
};
const employeeMap = ref(new Map());
const queryEmployeeOptions = async () => {
  const params: any = {};
  const res = await getEmployeeList(params);
  employeeMap.value.clear();
  if ((res as any)?.data?.length) {
    (res as any)?.data.map((item: any) => {
      const { id, username: name } = item;
      employeeMap.value.set(id, name);
    });
  }
  searchData.employeeId = 0;
};
const supplierMap = ref<Map<string, string>>(new Map());
const supplierOptions = ref<any[]>([]);
const querySupplierOptions = async () => {
  const res = await getSupplierList();
  if ((res as any)?.data?.length) {
    supplierOptions.value = (res as any).data;
    supplierMap.value.clear();
    supplierOptions.value.map((item: any) => {
      const { id, name } = item;
      supplierMap.value.set(id, name);
    });
  }
};
const customerMap = ref<Map<string, string>>(new Map());
const customerOptions = ref<any[]>([]);
const queryCustomerOptions = async () => {
  const res = await getCustomerList();
  if ((res as any)?.data?.length) {
    customerOptions.value = (res as any).data;
    customerMap.value.clear();
    customerOptions.value.map((item: any) => {
      const { id, name } = item;
      customerMap.value.set(id, name);
    });
  }
};
onMounted(async () => {
  queryEmployeeOptions();
  querySupplierOptions();
  queryCustomerOptions();
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
