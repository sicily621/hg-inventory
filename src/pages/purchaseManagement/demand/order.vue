<template>
  <div class="flex flex-col">
    <div class="w-full h-full flex flex-col">
      <el-card>
        <div class="zc-header-title">
          <div class="zc-header-icon"></div>
          <div class="zc-header-word">采购需求转订单信息</div>
        </div>
      </el-card>
      <div class="flex flex-1">
        <el-card shadow="never">
          <el-form
            ref="formRef"
            :model="form"
            :rules="rules"
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
                >
                </el-input>
              </el-form-item>
              <el-form-item label="期望到货时间" prop="expectedDate">
                <el-date-picker
                  v-model="form.expectedDate"
                  type="datetime"
                  class="flex-1"
                  placeholder="请输入期望到货时间"
                  :default-time="defaultTime"
                  :disabled-date="isBefore"
                />
              </el-form-item>
              <el-form-item label="总金额" prop="totalAmount">
                <el-tag class="fz22 p-5" type="danger"
                  >￥{{ totalAmount }}</el-tag
                >
              </el-form-item>
              <el-form-item label="备注" prop="description"
                ><el-input
                  v-model="form.description"
                  class="flex-1"
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
              <template #supplierId="scope">
                <el-select
                  v-model="scope.scope.row.supplierId"
                  placeholder="请选择供应商"
                  class="w-full"
                >
                  <el-option
                    v-for="item in supplierOptions"
                    :key="item.id"
                    :label="item.name"
                    :value="item.id"
                  />
                </el-select>
              </template>

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
              <template #quantity="scope">
                <el-input-number
                  v-model="scope.scope.row.quantity"
                  :min="1"
                  @change="changeQuantity(scope.scope.row)"
                />
              </template>
              <template #price="scope">
                <el-input-number
                  v-model="scope.scope.row.price"
                  :min="1"
                  @change="changeQuantity(scope.scope.row)"
                />
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
import { ref, reactive, computed, onMounted } from "vue";
import { Demand, editDemand, DemandStatus } from "../api/demand";
import { getDemandDetailList } from "../api/demandDetail";
import { getProductList } from "@/pages/productManagement/api/product";
import {
  Category,
  getCategoryList,
} from "@/pages/productManagement/api/category";
import { Order, OrderStatus, createOrder } from "../api/order";
import {
  OrderDetail,
  createOrderDetail,
  deleteOrderDetail,
} from "../api/orderDetail";
import { getSupplierList } from "../api/supplier";
import baseTable from "@@/components/baseTable/baseTable.vue";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/pinia/stores/user";
import { indexMethod } from "@@/utils/page";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
const pageSize = ref(1000);
const currentPage = ref(0);
const props = defineProps<{ data: Demand }>();
const formRef = ref();
const defaultTime = new Date();
const userStore = useUserStore();
const categoryOptions = ref([{ name: "全部", id: 0 }]);
const productOptions = ref<any[]>([]);
const isBefore = (date: Date) => {
  return date.getTime() - Date.now() <= 0;
};
const changeQuantity = (row: any) => {
  const { quantity, price } = row;
  row.amount = Number(Number(+quantity * +price).toFixed(2));
};
//表单
const form = ref<Order>({
  demandId: "",
  code: `${ModuleCode.PurchaseOrder}${formatTimeToString()}`,
  employeeId: userStore.getInfo().id,
  expectedDate: Date.now(),
  actualDate: 0,
  status: OrderStatus.Pending,
  totalAmount: 0,
  description: "",
  approverId: "",
});
const rules = reactive({
  code: [{ required: true, message: "不能为空" }],
  supplierId: [{ required: true, message: "不能为空" }],
  expectedDate: [{ required: true, message: "不能为空" }],
  totalAmount: [{ required: true, message: "不能为空" }],
});
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "supplierId", label: "供应商", width: "200" },
  { prop: "categoryId", label: "分类" },
  { prop: "productId", label: "名称" },
  { prop: "specification", label: "规格" },
  { prop: "unit", label: "计量单位" },
  { prop: "quantity", label: "数量" },
  { prop: "price", label: "采购价" },
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
//合并props
if (props.data) {
  form.value.demandId = String(props.data.id);
}

const supplierOptions = ref<any[]>([]);
const querySupplierOptions = async () => {
  const res = await getSupplierList();
  if ((res as any)?.data?.length) {
    supplierOptions.value = (res as any).data;
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
      message: "采购订单商品列表不能为空",
    });
    return;
  }
  const valid = await formRef.value.validate();
  if (valid) {
    const params: any = { ...form.value, totalAmount: totalAmount.value };
    if (params.approvalTime == 0) delete params["approvalTime"];
    if (params.actualDate == 0) delete params["actualDate"];
    const res = await createOrder(params);
    const detailList: OrderDetail[] = tableData.value.map((item: any) => {
      const { productId, categoryId, price, quantity, amount, supplierId } =
        item;
      return {
        productId,
        categoryId,
        price,
        quantity,
        orderId: (res as any).data.id,
        amount,
        supplierId,
      };
    });
    await deleteOrderDetail((res as any).data.id);
    await createOrderDetail(detailList);
    const demand = { ...props.data, status: DemandStatus.WorkOrder };
    await editDemand(demand);
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};

defineExpose({ confirmSave });
onMounted(async () => {
  await querySupplierOptions();
  await queryCategoryOptions();
  await queryProductOptions();
  if (props?.data?.id) {
    const res = await getDemandDetailList((props as any).data.id);
    tableData.value = (res as any)?.data.map((item: any) => {
      const { quantity, productId } = item;
      const price = getItem(productId, productMap.value)?.purchasePrice;
      return {
        ...item,
        amount: Number(Number(+quantity * +price).toFixed(2)),
        price,
        supplierId: supplierOptions.value[0]?.id,
      };
    });
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
  border: zrem(1) solid var(--el-border-color-darker);
  border-radius: 50%;
  &,
  & img {
    width: zrem(60);
    height: zrem(60);
  }
}
</style>
