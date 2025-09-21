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
            <el-form-item prop="employeeId" label="采购人">
              <el-select
                v-model="searchData.employeeId"
                placeholder="请选择采购人"
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
                  v-for="item in ReturnStatusListWithAll"
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
            <template #supplierId="scope">
              {{ getName(scope.scope.row.supplierId, supplierMap) }}
            </template>
            <template #employeeId="scope">
              {{ getName(scope.scope.row.employeeId, employeeMap) }}
            </template>
            <template #status="scope">
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
            <template #receipt="scope">
              {{ scope.scope.row.receipt ? "是" : "否" }}
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
                    scope.scope.row.status == ReturnStatus.Pending &&
                    enableApprove
                  "
                  @click="toApprove(scope.scope.row)"
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  title="审批"
                  ><DocumentChecked
                /></el-icon>
                <el-icon
                  v-if="scope.scope.row.status !== ReturnStatus.Pending"
                  @click="edit(scope.scope.row)"
                  class="fz16 pointer m-r-5 cursor-pointer"
                  text
                  title="查看"
                  ><View
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
      <Detail
        class="create-wrap"
        ref="createRef"
        :data="currentData"
        v-if="currentData && processFlag === 1"
      ></Detail>
      <el-card class="footer flex flex-justify-end flex-items-center">
        <template v-if="isApprove">
          <el-button type="primary" @click="approve" class="p-l-6 p-r-6 m-r-3">
            审批
          </el-button>
          <el-button type="warning" @click="rejected" class="p-l-6 p-r-6 m-r-3">
            驳回
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
import { getSupplierList } from "../api/supplier";
import {
  queryReturnConditions,
  findReturnPage,
  Return,
  ReturnStatus,
  ReturnStatusList,
} from "../api/return";
import {
  Department,
  getDepartmentList,
} from "@/pages/employeeManagement/api/department";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import { indexMethod } from "@@/utils/page";
import Detail from "./detail.vue";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();
const enableApprove = permissionStore.hasPermission(
  ModuleCode.PurchaseReturn,
  PermissionAction.Approve,
);
const ReturnStatusListWithAll = [{ id: 0, name: "全部" }, ...ReturnStatusList];
const createRef = ref();
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
  { prop: "employeeId", label: "退单人" },
  { prop: "status", label: "状态" },
  { prop: "totalAmount", label: "总金额" },
  { prop: "description", label: "备注" },
  { prop: "approverId", label: "审批人" },
  { prop: "approvalTime", label: "审批时间" },
  { prop: "receipt", label: "是否入库" },
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
const currentData = ref<Return | null>(null);
const edit = (row: Return) => {
  currentData.value = row;
  processFlag.value = 1;
};
const isApprove = ref(false);
const toApprove = (row: Return) => {
  isApprove.value = true;
  currentData.value = row;
  processFlag.value = 1;
};
const tableData = ref<Return[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryReturnConditions>({
  code: "",
  employeeId: "",
  startTime: "",
  endTime: "",
  status: 0,
});
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

function refreshTable() {
  loading.value = true;
  const params: PaginatedRequest<queryReturnConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.code) params.code = searchData.code;
  if (searchData.employeeId) params.employeeId = searchData.employeeId;
  if (searchData.status) params.status = searchData.status;
  if (time.value?.[0] && time.value?.[1]) {
    params.startTime = `${time.value?.[0]} 00:00:00`;
    params.endTime = `${time.value?.[1]} 23:59:59`;
  }
  findReturnPage(params)
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
const back = () => {
  isApprove.value = false;
  processFlag.value = 0;
  currentData.value = null;
  refreshTable();
};
const approve = () => {
  createRef.value.approve(() => {
    back();
  });
};
const rejected = () => {
  createRef.value.rejected(() => {
    back();
  });
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
  await querySupplierOptions();
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
