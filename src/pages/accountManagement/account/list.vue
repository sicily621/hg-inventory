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
            <el-form-item label="时间范围">
              <el-date-picker
                v-model="time"
                class="width-100"
                type="daterange"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                format="YYYY/MM/DD"
                value-format="YYYY-MM-DD"
                @change="refreshTable"
                :disabled-date="isAfter"
              />
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
            <template #cost="scope">
              <el-tag
                type="warning"
                v-if="
                  scope.scope.row.type == AccountType.SalesRevenue ||
                  scope.scope.row.type == AccountType.SalesRefund
                "
              >
                ￥{{ scope.scope.row.cost }}
              </el-tag>
              <span v-else>--</span>
            </template>
            <template #amount="scope">
              <el-tag type="danger"> ￥{{ scope.scope.row.amount }} </el-tag>
            </template>
            <template #operate="scope">
              <div class="flex">
                <el-icon
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  @click="view(scope.scope.row)"
                >
                  <View />
                </el-icon>
                <el-icon
                  v-if="
                    scope.scope.row.status == AccountStatus.Pending &&
                    enableApprove
                  "
                  @click="toApprove(scope.scope.row)"
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  title="审批"
                  ><DocumentChecked
                /></el-icon>
                <el-icon
                  v-else-if="
                    scope.scope.row.status == AccountStatus.Approved &&
                    enableCreate
                  "
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  :title="getIconTitle(scope.scope.row.type)"
                  @click="handleAccount(scope.scope.row)"
                  ><Coin
                /></el-icon>
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
      <SaleOrder
        class="create-wrap"
        ref="createRef"
        :code="currentData.relatedCode"
        v-if="currentData && currentType === AccountType.SalesRevenue"
      ></SaleOrder>
      <SaleReturn
        class="create-wrap"
        ref="createRef"
        :code="currentData.relatedCode"
        v-if="currentData && currentType === AccountType.SalesRefund"
      >
      </SaleReturn>
      <PurchaseOrder
        class="create-wrap"
        ref="createRef"
        :code="currentData.relatedCode"
        v-if="currentData && currentType === AccountType.PurchasePayMent"
      ></PurchaseOrder>
      <PurchaseReturn
        class="create-wrap"
        ref="createRef"
        :code="currentData.relatedCode"
        v-if="currentData && currentType === AccountType.PurchaseRefund"
      ></PurchaseReturn>
      <el-card class="footer flex flex-justify-end flex-items-center">
        <template v-if="isApprove">
          <el-button type="primary" @click="approve" class="p-l-6 p-r-6 m-r-3">
            审批
          </el-button>
        </template>
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
  queryAccountConditions,
  findAccountPage,
  Account,
  AccountStatus,
  AccountStatusList,
  AccountTypeList,
  AccountType,
  AccountActionList,
  editAccount,
} from "../api/account";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import { getCustomerList } from "@/pages/saleManagement/api/customer";
import { getSupplierList } from "@/pages/purchaseManagement/api/supplier";
import { indexMethod } from "@@/utils/page";
import { watchDebounced } from "@vueuse/core";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { ElMessage } from "element-plus";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
import { useUserStore } from "@/pinia/stores/user";
import { formatSecondsToDuration } from "@@/utils/datetime";
import SaleOrder from "./saleOrder.vue";
import SaleReturn from "./saleReturn.vue";
import PurchaseOrder from "./purchaseOrder.vue";
import PurchaseReturn from "./purchaseReturn.vue";
const permissionStore = usePermissionStore();
const enableCreate = permissionStore.hasPermission(
  ModuleCode.Account,
  PermissionAction.Add,
);
const enableApprove = permissionStore.hasPermission(
  ModuleCode.Account,
  PermissionAction.Approve,
);
const allAccountTypeList = [{ id: 0, name: "全部" }, ...AccountActionList];
const allAccountStatusList = [{ id: 0, name: "全部" }, ...AccountStatusList];
const time = ref("");
const isAfter = (date: Date) => {
  return date.getTime() - Date.now() >= 0;
};
const isApprove = ref(false);
const currentType = ref(-1);
const view = (row: Account) => {
  processFlag.value = 1;
  currentData.value = row;
  currentType.value = row.type;
};
const createRef = ref();
const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "relatedCode", label: "关联编码" },
  { prop: "createTime", label: "生成时间" },
  { prop: "type", label: "类型" },
  { prop: "relatedEntityType", label: "往来单位类型" },
  { prop: "relatedEntityId", label: "往来单位" },
  { prop: "amount", label: "金额" },
  { prop: "cost", label: "成本" },
  { prop: "time", label: "用时" },
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
const toApprove = (row: Account) => {
  isApprove.value = true;
  processFlag.value = 1;
  currentData.value = row;
  currentType.value = row.type;
};
const approve = async () => {
  const params: any = { ...currentData.value, status: AccountStatus.Approved };
  const res: any = await editAccount(params);
  if (res.code) {
    ElMessage({
      type: "success",
      message: "审批成功",
    });
    refreshTable();
  } else {
    ElMessage({
      type: "info",
      message: "审批失败",
    });
  }
  back();
};
const getIconTitle = (type: number) => {
  if (type == 1 || type == 4) {
    return "出账";
  } else {
    return "入账";
  }
};
const userStore = useUserStore();

const handleAccount = async (row: Account) => {
  ElMessageBox.confirm(
    `确认要${getIconTitle(row.type)}吗`,
    getIconTitle(row.type),
    {
      confirmButtonText: "确认",
      confirmButtonClass: "w-80",
      cancelButtonText: "取消",
      cancelButtonClass: "message-box-cancel-btn w-80",
      type: "warning",
    },
  ).then(async () => {
    const params = {
      ...row,
      employeeId: userStore.getInfo().id,
      status:
        getIconTitle(row.type) === "出账"
          ? AccountStatus.Paid
          : AccountStatus.Receipt,
    };
    const res: any = await editAccount(params);
    if (res.code) {
      ElMessage({
        type: "success",
        message: `${getIconTitle(row.type)}成功`,
      });
      refreshTable();
    } else {
      ElMessage({
        type: "info",
        message: `${getIconTitle(row.type)}失败`,
      });
    }
  });
};

const tableData = ref<Account[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryAccountConditions>({
  orderId: "",
  type: 0,
  relatedEntityId: "",
  employeeId: "",
  status: 0,
  startTime: "",
  endTime: "",
});

watchDebounced(
  searchData,
  () => {
    refreshTable();
  },
  { debounce: 500, maxWait: 1000 },
);

const now = new Date();
function refreshTable() {
  loading.value = true;
  const params: PaginatedRequest<queryAccountConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData?.orderId) params.orderId = searchData.orderId;
  if (searchData.type) params.type = searchData.type;
  if (searchData?.relatedEntityId)
    params.relatedEntityId = searchData.relatedEntityId;
  if (searchData?.employeeId) params.employeeId = searchData.employeeId;
  if (searchData.status) params.status = searchData.status;
  if (time.value?.[0] && time.value?.[1]) {
    params.startTime = `${time.value?.[0]} 00:00:00`;
    params.endTime = `${time.value?.[1]} 23:59:59`;
  }
  findAccountPage(params)
    .then((res: any) => {
      const { total, list } = res.data;
      totalItems.value = total;
      tableData.value = list.map((item: any) => {
        const { createTime, updateTime, status } = item;
        if (
          status == AccountStatus.Pending ||
          status == AccountStatus.Approved
        ) {
          item.time = formatSecondsToDuration(
            (now.getTime() - new Date(createTime).getTime()) / 1000,
          );
        } else {
          item.time = formatSecondsToDuration(
            (new Date(updateTime).getTime() - new Date(createTime).getTime()) /
              1000,
          );
        }

        return item;
      });
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
const back = () => {
  processFlag.value = 0;
  currentData.value = null;
  isApprove.value = false;
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
