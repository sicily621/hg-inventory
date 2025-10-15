<template>
  <div class="flex flex-col">
    <div class="w-full h-full flex flex-col">
      <el-card>
        <div class="zc-header-title">
          <div class="zc-header-icon"></div>
          <div class="zc-header-word">销售退单信息</div>
        </div>
      </el-card>
      <div class="flex flex-1">
        <el-card shadow="never">
          <el-form
            ref="formRef"
            :model="form"
            label-position="top"
            class="flex relative"
            label-width="120px"
            require-asterisk-position="right"
          >
            <div class="d-flex width-300">
              <el-form-item label="编码" prop="code">
                <el-input
                  v-model="form.code"
                  class="flex-1"
                  placeholder="请输入编码"
                  maxlength="32"
                  required
                  disabled
                >
                </el-input>
              </el-form-item>
              <el-form-item label="客户" prop="customerId">
                <el-select
                  v-model="form.customerId"
                  placeholder="请选择客户"
                  class="w-full"
                  disabled
                >
                  <el-option
                    v-for="item in customerOptions"
                    :key="item.id"
                    :label="item.name"
                    :value="item.id"
                  />
                </el-select>
              </el-form-item>
              <el-form-item label="总金额" prop="totalAmount">
                <el-tag class="fz22 p-5" type="danger"
                  >￥{{ totalAmount }}</el-tag
                >
              </el-form-item>
              <el-form-item prop="status" label="状态">
                <el-select
                  v-model="form.status"
                  placeholder="请选择状态"
                  class="w-full"
                  disabled
                >
                  <el-option
                    v-for="item in ReturnStatusList"
                    :key="item.id"
                    :label="item.name"
                    :value="item.id"
                  />
                </el-select>
              </el-form-item>
              <el-form-item label="备注" prop="description"
                ><el-input
                  v-model="form.description"
                  class="flex-1"
                  disabled
                  placeholder="请输入备注"
                  maxlength="32"
                  required
                >
                </el-input>
              </el-form-item>
            </div>
          </el-form>
        </el-card>
        <el-card class="flex-1" shadow="never">
          <div class="table-wrap">
            <baseTable
              :columns="columns"
              :table-data="tableData"
              class="h-full"
              :indexMethod="indexMethod(currentPage, pageSize)"
            >
              <template #categoryId="scope">
                {{ getItem(scope.scope.row.categoryId, categoryMap) }}
              </template>
              <template #productId="scope">
                {{ getItem(scope.scope.row.productId, productMap)?.name }}
              </template>
              <template #unit="scope">
                {{ getItem(scope.scope.row.productId, productMap)?.unit }}
              </template>
              <template #specification="scope">
                {{
                  getItem(scope.scope.row.productId, productMap)?.specification
                }}
              </template>

              <template #price="scope">
                <el-tag type="primary"
                  >￥{{
                    getItem(scope.scope.row.productId, productMap)?.retailPrice
                  }}</el-tag
                >
              </template>
              <template #cost="scope">
                <el-tag type="warning">￥{{ scope.scope.row.cost }}</el-tag>
              </template>
              <template #amount="scope">
                <el-tag type="danger">￥{{ scope.scope.row.amount }}</el-tag>
              </template>
            </baseTable>
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { ref, computed, onMounted } from "vue";
import { getProductList } from "@/pages/productManagement/api/product";
import {
  Category,
  getCategoryList,
} from "@/pages/productManagement/api/category";
import {
  Return,
  ReturnStatus,
  editReturn,
  ReturnStatusList,
  getReturnList,
} from "@/pages/saleManagement/api/return";

import { getReturnDetailList } from "@/pages/saleManagement/api/returnDetail";
import { getCustomerList } from "@/pages/saleManagement/api/customer";
import baseTable from "@@/components/baseTable/baseTable.vue";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/pinia/stores/user";
import { indexMethod } from "@@/utils/page";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
import { ModuleCode } from "@/router/moduleCode";
const permissionStore = usePermissionStore();
const enableApprove = permissionStore.hasPermission(
  ModuleCode.SalesReturn,
  PermissionAction.Approve,
);
// const disabledApprove = computed(() => {
//   return !enableApprove;
// });
const pageSize = ref(1000);
const currentPage = ref(0);
const props = defineProps<{ code: string }>();
const formRef = ref();
const userStore = useUserStore();
const categoryOptions = ref([{ name: "全部", id: 0 }]);
const productOptions = ref<any[]>([]);

//表单
const form = ref<any>({});
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "categoryId", label: "分类" },
  { prop: "productId", label: "名称" },
  { prop: "specification", label: "规格" },
  { prop: "unit", label: "计量单位" },
  { prop: "quantity", label: "数量" },
  { prop: "price", label: "销售价" },
  { prop: "cost", label: "成本价" },
  { prop: "amount", label: "金额" },
]);

const tableData = ref<any[]>([]);
const totalAmount = computed(() => {
  let result = 0;
  tableData.value.map((item) => {
    result += +item.amount;
  });
  return result;
});

const customerOptions = ref<any[]>([]);
const queryCustomerOptions = async () => {
  const res = await getCustomerList();
  if ((res as any)?.data?.length) {
    customerOptions.value = (res as any).data;
  }
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
  }
};
const productMap = ref(new Map());
const queryProductOptions = async () => {
  const res = await getProductList({});
  const { data } = res as any;
  productOptions.value = data;
  data.forEach((item: any) => {
    const { id } = item;
    productMap.value.set(id, item);
  });
};

const getItem = (id: string, mapData: Map<string, any>) => {
  return mapData.get(id);
};

const confirmSave = async (cb?: Function) => {
  if (tableData.value.length == 0) {
    ElMessage({
      type: "error",
      message: "销售订单商品列表不能为空",
    });
    return;
  }
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value };
    if (
      enableApprove &&
      (params.status == ReturnStatus.Approved ||
        params.status == ReturnStatus.Rejected)
    ) {
      params.approverId = userStore.getInfo().id;
      params.approvalTime = Date.now();
    }
    await editReturn(params);
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};
const approve = async (cb?: Function) => {
  form.value.status = ReturnStatus.Approved;
  await confirmSave(cb);
};
const rejected = async (cb?: Function) => {
  form.value.status = ReturnStatus.Rejected;
  await confirmSave(cb);
};
defineExpose({ confirmSave, approve, rejected });
onMounted(async () => {
  await queryCustomerOptions();
  await queryCategoryOptions();
  await queryProductOptions();
  if (props.code) {
    const returnRes: any = await getReturnList({ code: props.code });
    form.value = Object.assign(form.value, returnRes?.data?.[0] ?? {});
    const res = await getReturnDetailList(returnRes?.data?.[0].id);
    tableData.value = (res as any)?.data;
  }
});
</script>
<style lang="scss" scoped>
@use "@@/assets/styles/size.scss" as *;
.width-300 {
  width: zrem(300);
}
.avatar-upload {
  font-size: zrem(20);
  breturn: zrem(1) solid var(--el-breturn-color-darker);
  breturn-radius: 50%;
  &,
  & img {
    width: zrem(60);
    height: zrem(60);
  }
}
</style>
