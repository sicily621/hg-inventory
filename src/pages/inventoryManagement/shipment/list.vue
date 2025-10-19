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
                <el-option :key="1" label="销售订单" :value="1" />
                <el-option :key="2" label="采购退单" :value="2" />
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
            <template #supplierId="scope">
              {{ getName(scope.scope.row.supplierId, supplierMap) }}
            </template>
            <template #customerId="scope">
              {{ getName(scope.scope.row.customerId, customerMap) }}
            </template>
            <template #employeeId="scope">
              {{ getName(scope.scope.row.employeeId, employeeMap) }}
            </template>
            <template #status="scope">
              <template v-if="searchData.type === 1">
                <el-tag
                  type="warning"
                  v-if="scope.scope.row.status === OrderStatus.Rejected"
                >
                  {{ getStatus(scope.scope.row.status, OrderStatusList) }}
                </el-tag>
                <el-tag
                  type="success"
                  v-else-if="scope.scope.row.status === OrderStatus.Approved"
                >
                  {{ getStatus(scope.scope.row.status, OrderStatusList) }}
                </el-tag>
                <el-tag v-else>
                  {{ getStatus(scope.scope.row.status, OrderStatusList) }}
                </el-tag>
              </template>
              <template v-if="searchData.type === 2">
                <el-tag
                  type="warning"
                  v-if="scope.scope.row.status === ReturnStatus.Rejected"
                >
                  {{ getStatus(scope.scope.row.status, ReturnStatusList) }}
                </el-tag>
                <el-tag
                  type="success"
                  v-else-if="scope.scope.row.status === ReturnStatus.Approved"
                >
                  {{ getStatus(scope.scope.row.status, ReturnStatusList) }}
                </el-tag>
                <el-tag v-else>
                  {{ getStatus(scope.scope.row.status, ReturnStatusList) }}
                </el-tag>
              </template>
            </template>
            <template #totalAmount="scope">
              <el-tag type="danger">￥{{ scope.scope.row.totalAmount }}</el-tag>
            </template>
            <template #operate="scope">
              <div class="flex">
                <el-icon
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  v-if="enableCreate"
                  @click="edit(scope.scope.row)"
                >
                  <Edit
                    v-if="
                      searchData.type === 1
                        ? scope.scope.row.status <=
                          OrderStatus.PartiallyReceived
                        : scope.scope.row.status < ReturnStatus.FullyReceived
                    "
                  />
                  <View v-else />
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
      <Create
        class="create-wrap"
        :type="searchData.type"
        ref="createRef"
        :data="currentData"
      ></Create>
      <el-card class="footer flex flex-justify-end flex-items-center">
        <el-button
          type="primary"
          v-if="editable"
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
import { onMounted, ref, reactive, computed } from "vue";
import baseTable from "@@/components/baseTable/baseTable.vue";
import pagination from "@@/components/pagination/pagination.vue";
import { getSupplierList } from "@/pages/purchaseManagement/api/supplier";
import { Receipt } from "../api/receipt";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import {
  findOrderPage,
  OrderStatus,
  OrderStatusList,
} from "@/pages/saleManagement/api/order";
import { getCustomerList } from "@/pages/saleManagement/api/customer";
import {
  findReturnPage,
  ReturnStatus,
  ReturnStatusList,
} from "@/pages/purchaseManagement/api/return";
import { indexMethod } from "@@/utils/page";
import Create from "./create.vue";
import { watchDebounced } from "@vueuse/core";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();
const enableCreate = permissionStore.hasPermission(
  ModuleCode.InventoryShipment,
  PermissionAction.Add,
);
const createRef = ref();
const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const searchData = reactive({
  type: 1, //1采购订单 2 销售退单
});
const columns = computed(() => {
  const list: any[] =
    searchData.type === 1
      ? [
          { prop: "expectedDate", label: "期望到货日期" },
          { prop: "actualDate", label: "实际出库日期" },
        ]
      : [{ prop: "createTime", label: "退单时间" }];
  const result = [
    { prop: "index", label: "序号", width: "100", type: 1 },
    { prop: "code", label: "编码" },

    {
      prop: "employeeId",
      label: searchData.type === 1 ? "销售员工" : "退单员工",
    },
    ...list,
    { prop: "status", label: "状态" },
    { prop: "totalAmount", label: "总金额" },
    { prop: "description", label: "备注" },
    { prop: "operate", label: "操作", width: 100 },
  ];
  if (searchData.type === 1) {
    result.splice(2, 0, {
      prop: "customerId",
      label: "客户",
    });
  }
  return result;
});

//分页
const pageSize = ref(10);
const currentPage = ref(0);
const totalItems = ref(0);
const pageChange = (page: any) => {
  currentPage.value = page - 1;
  refreshTable();
};
const currentData = ref<Receipt | null>(null);
const editable = computed(() => {
  const status = (currentData.value as any)?.status;
  return searchData.type === 1
    ? status <= OrderStatus.PartiallyReceived
    : status < ReturnStatus.FullyReceived;
});
const edit = (row: Receipt) => {
  currentData.value = row;
  processFlag.value = 1;
};

const tableData = ref<Receipt[]>([]);

const searchFormRef = ref("searchFormRef");

watchDebounced(
  searchData,
  () => {
    refreshTable();
  },
  { debounce: 500, maxWait: 1000 },
);
const queryOrder = async () => {
  return await findOrderPage({
    startStatus: OrderStatus.Confirmed,
    endStatus: OrderStatus.PartiallyReturned,
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  });
};
const queryReturn = async () => {
  return await findReturnPage({
    startStatus: ReturnStatus.Approved,
    endStatus: ReturnStatus.FullyReceived,
    currentPage: currentPage.value + 1,
    size: pageSize.value,
    receipt: 1,
  });
};
function refreshTable() {
  loading.value = true;
  const api = searchData.type === 1 ? queryOrder : queryReturn;
  tableData.value = [];
  api()
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
const employeeMap = ref(new Map());
const employeeOptions = ref<any[]>([]);
const queryEmployeeOptions = async () => {
  const params: any = {};
  const res = await getEmployeeList(params);
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

const getName = (id: string, mapData: Map<string, string>) => {
  return mapData.get(id) ?? "无";
};
const getStatus = (id: string, list: any[]) => {
  return list.find((item) => item.id === id)?.name ?? "无";
};
const save = () => {
  createRef.value.confirmSave(() => {
    currentData.value = null;
    back();
  });
};
const back = () => {
  processFlag.value = 0;
  currentData.value = null;
  refreshTable();
};

onMounted(async () => {
  await querySupplierOptions();
  await queryCustomerOptions();
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
