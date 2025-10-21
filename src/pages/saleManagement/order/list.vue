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
            <el-form-item prop="departmentId" label="部门">
              <el-tree-select
                class="w-40"
                v-model="departmentId"
                placeholder="请选择部门"
                :data="departmentOptions"
                check-strictly
                :render-after-expand="false"
                :props="selectProps"
                @change="changeDept"
              />
            </el-form-item>
            <el-form-item prop="employeeId" label="销售人">
              <el-select
                v-model="searchData.employeeId"
                placeholder="请选择销售人"
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
            <el-form-item label="客户" prop="customerId">
              <el-select
                v-model="searchData.customerId"
                placeholder="请选择客户"
                class="w-40"
              >
                <el-option
                  v-for="item in customerOptions"
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
                  v-for="item in OrderStatusListWithAll"
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
            <template #customerId="scope">
              {{ getName(scope.scope.row.customerId, customerMap) }}
            </template>
            <template #employeeId="scope">
              {{ getName(scope.scope.row.employeeId, employeeMap) }}
            </template>
            <template #status="scope">
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
            <template #totalAmount="scope">
              <el-tag type="danger">￥{{ scope.scope.row.totalAmount }}</el-tag>
            </template>
            <template #approverId="scope">
              {{ getName(scope.scope.row.approverId, employeeMap) }}
            </template>
            <template #operate="scope">
              <div class="flex">
                <el-icon
                  v-if="
                    scope.scope.row.status === OrderStatus.FullyReceived &&
                    enableCreateReturn
                  "
                  @click="toReturn(scope.scope.row)"
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  title="退单"
                  ><DocumentDelete
                /></el-icon>
                <template
                  v-else-if="scope.scope.row.status == OrderStatus.Pending"
                >
                  <el-icon
                    v-if="enableApprove"
                    @click="toApprove(scope.scope.row)"
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    title="审批"
                    ><DocumentChecked
                  /></el-icon>
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
                    v-if="enableDelete"
                    @click="remove(scope.scope.row.id)"
                  >
                    <Delete />
                  </el-icon>
                </template>
                <el-icon
                  v-else-if="
                    scope.scope.row.status == OrderStatus.Approved && enableEdit
                  "
                  @click="toConfirm(scope.scope.row)"
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  title="客户已确认"
                  ><CircleCheck
                /></el-icon>

                <template v-else>
                  <el-icon
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    @click="view(scope.scope.row)"
                  >
                    <View />
                  </el-icon>
                  <el-icon
                    v-if="
                      scope.scope.row.status == OrderStatus.PartiallyReturned ||
                      scope.scope.row.status == OrderStatus.Returned
                    "
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    title="查看退单"
                    @click="viewReturn(scope.scope.row)"
                  >
                    <DocumentRemove />
                  </el-icon>
                </template>
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
        ref="createRef"
        :data="currentData"
        :is-approve="isApprove"
        v-if="processFlag === 1"
      ></Create>
      <Return
        class="create-wrap"
        ref="returnRef"
        :data="currentData"
        v-if="currentData && processFlag === 2"
      ></Return>
      <el-card class="footer flex flex-justify-end flex-items-center">
        <template v-if="isApprove">
          <el-button type="primary" @click="approve" class="p-l-6 p-r-6 m-r-3">
            审批
          </el-button>
          <el-button type="warning" @click="rejected" class="p-l-6 p-r-6 m-r-3">
            驳回
          </el-button>
        </template>
        <template v-else-if="isConfirmed"
          ><el-button type="primary" @click="confirm" class="p-l-6 p-r-6 m-r-3">
            客户已确认
          </el-button></template
        >
        <template v-if="!onlyView">
          <el-button type="primary" @click="save" class="p-l-6 p-r-6 m-r-3"
            >保存</el-button
          >
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
import { getCustomerList } from "../api/customer";
import {
  queryOrderConditions,
  deleteOrder,
  findOrderPage,
  Order,
  OrderStatus,
  OrderStatusList,
} from "../api/order";
import { deleteOrderDetail } from "../api/orderDetail";
import {
  Department,
  getDepartmentList,
} from "@/pages/employeeManagement/api/department";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import { indexMethod } from "@@/utils/page";
import Create from "./create.vue";
import Return from "./return.vue";
import { ElMessage } from "element-plus";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
import { formatSecondsToDuration } from "@@/utils/datetime";
const permissionStore = usePermissionStore();
const enableDelete = permissionStore.hasPermission(
  ModuleCode.SalesOrder,
  PermissionAction.Delete,
);
const enableCreate = permissionStore.hasPermission(
  ModuleCode.SalesOrder,
  PermissionAction.Add,
);
const enableCreateReturn = permissionStore.hasPermission(
  ModuleCode.SalesReturn,
  PermissionAction.Add,
);
const enableEdit = permissionStore.hasPermission(
  ModuleCode.SalesOrder,
  PermissionAction.Edit,
);
const enableApprove = permissionStore.hasPermission(
  ModuleCode.SalesOrder,
  PermissionAction.Approve,
);
const OrderStatusListWithAll = [{ id: 0, name: "全部" }, ...OrderStatusList];
const createRef = ref();
const returnRef = ref();
const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const selectProps = { value: "id", label: "name" };
const departmentOptions = ref([{ name: "全部", id: 0 }]);
const employeeOptions = ref([{ name: "全部", id: 0 }]);
const time = ref("");
const isAfter = (date: Date) => {
  return date.getTime() - Date.now() >= 0;
};
const departmentId = ref("");
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "code", label: "编码" },
  { prop: "customerId", label: "客户" },
  { prop: "employeeId", label: "销售人" },
  { prop: "expectedDate", label: "期望到货日期" },
  { prop: "actualDate", label: "实际发货日期" },
  { prop: "time", label: "用时" },
  { prop: "status", label: "状态" },
  { prop: "totalAmount", label: "总金额" },
  { prop: "description", label: "备注" },
  { prop: "approverId", label: "审批人" },
  { prop: "approvalTime", label: "审批时间" },
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
const currentData = ref<Order | null>(null);
const isApprove = ref(false);
const isConfirmed = ref(false);
const toConfirm = (row: Order) => {
  isConfirmed.value = true;
  onlyView.value = true;
  currentData.value = row;
  processFlag.value = 1;
};
const edit = (row: Order) => {
  currentData.value = row;
  processFlag.value = 1;
};
const toApprove = (row: Order) => {
  isApprove.value = true;
  onlyView.value = true;
  currentData.value = row;
  processFlag.value = 1;
};
const toReturn = (row: Order) => {
  currentData.value = row;
  processFlag.value = 2;
};
const viewReturn = (row: Order) => {
  onlyView.value = true;
  currentData.value = row;
  processFlag.value = 2;
};
const rejected = () => {
  createRef.value.rejected(() => {
    back();
  });
};
const approve = () => {
  createRef.value.approve(() => {
    back();
  });
};
const confirm = () => {
  createRef.value.confirm(() => {
    back();
  });
};
const onlyView = ref(false);
const view = (row: Order) => {
  onlyView.value = true;
  currentData.value = row;
  processFlag.value = 1;
};
const tableData = ref<Order[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryOrderConditions>({
  code: "",
  customerId: "",
  employeeId: "",
  startTime: "",
  endTime: "",
  status: 0,
});
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
const now = new Date();
function refreshTable() {
  loading.value = true;
  const params: PaginatedRequest<queryOrderConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.code) params.code = searchData.code;
  if (searchData.customerId) params.customerId = searchData.customerId;
  if (searchData.employeeId) params.employeeId = searchData.employeeId;
  if (searchData.status) params.status = searchData.status;
  if (time.value?.[0] && time.value?.[1]) {
    params.startTime = `${time.value?.[0]} 00:00:00`;
    params.endTime = `${time.value?.[1]} 23:59:59`;
  }
  findOrderPage(params)
    .then((res: any) => {
      const { total, list } = res.data;
      totalItems.value = total;
      tableData.value = list.map((item: any) => {
        const { createTime, updateTime, actualDate, status } = item;
        if (status < OrderStatus.FullyReceived) {
          if (status == OrderStatus.Rejected) {
            item.time = formatSecondsToDuration(
              (new Date(updateTime).getTime() -
                new Date(createTime).getTime()) /
                1000,
            );
          } else {
            item.time = formatSecondsToDuration(
              (now.getTime() - new Date(createTime).getTime()) / 1000,
            );
          }
        } else {
          item.time = formatSecondsToDuration(
            (new Date(actualDate).getTime() - new Date(createTime).getTime()) /
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
const save = () => {
  if (processFlag.value === 1) {
    createRef.value.confirmSave(() => {
      back();
    });
  }
  if (processFlag.value === 2) {
    returnRef.value.confirmSave(() => {
      back();
    });
  }
};
const back = () => {
  onlyView.value = false;
  isConfirmed.value = false;
  isApprove.value = false;
  processFlag.value = 0;
  currentData.value = null;
  refreshTable();
};
const create = () => {
  processFlag.value = 1;
};
const remove = async (id: string) => {
  await deleteOrderDetail(id);
  await deleteOrder(id);
  ElMessage({
    type: "success",
    message: "删除成功",
  });
  refreshTable();
};
const getName = (id: string, mapData: Map<string, string>) => {
  return mapData.get(id) ?? "无";
};
const getStatus = (id: string, list: any[]) => {
  return list.find((item) => item.id === id)?.name ?? "无";
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
const changeDept = async () => {
  await queryEmployeeOptions();
  refreshTable();
};
const employeeMap = ref(new Map());
const queryEmployeeOptions = async () => {
  const params: any = {};
  if (departmentId.value) params.departmentId = departmentId.value;
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
  searchData.employeeId = 0;
};
onMounted(async () => {
  await queryCustomerOptions();
  await queryDepartmentOptions();
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
