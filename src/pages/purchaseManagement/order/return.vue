<template>
  <div class="flex flex-col">
    <div class="w-full h-full flex flex-col">
      <el-card>
        <div class="zc-header-title">
          <div class="zc-header-icon"></div>
          <div class="zc-header-word">采购退单信息</div>
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
                  :disabled="onlyView"
                >
                </el-input>
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
                  :disabled="onlyView"
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
                {{ getItem(scope.scope.row.supplierId, supplierMap) }}
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
                  :min="0"
                  :max="scope.scope.row.quantityOrder"
                  step-strictly
                  class="flex-1"
                  @change="changeQuantity(scope.scope.row)"
                  :disabled="onlyView"
                />
              </template>

              <template #price="scope">
                <el-tag type="primary">￥{{ scope.scope.row.price }}</el-tag>
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
import { Order, OrderStatus, editOrder } from "../api/order";
import {
  Return,
  ReturnStatus,
  createReturn,
  getReturnList,
} from "../api/return";
import {
  getReturnDetailList,
  ReturnDetail,
  createReturnDetail,
  deleteReturnDetail,
} from "../api/returnDetail";
import { getOrderDetailList } from "../api/orderDetail";
import { getSupplierList } from "../api/supplier";
import baseTable from "@@/components/baseTable/baseTable.vue";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/pinia/stores/user";
import { indexMethod } from "@@/utils/page";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
const pageSize = ref(1000);
const currentPage = ref(0);
const props = defineProps<{ data: Order }>();
const formRef = ref();
const categoryOptions = ref([{ name: "全部", id: 0 }]);
const productOptions = ref<any[]>([]);
const onlyView = computed(() => {
  return (
    props.data.status == OrderStatus.PartiallyReturned ||
    props.data.status == OrderStatus.Returned
  );
});
const changeQuantity = (row: any) => {
  const { quantity, price } = row;
  row.amount = +quantity * +price;
};
const userStore = useUserStore();
//表单
const form = ref<Return>({
  orderId: String(props.data.id),
  code: `${ModuleCode.PurchaseReturn}${formatTimeToString()}`,
  employeeId: userStore.getInfo().id,
  status: ReturnStatus.Pending,
  description: "",
  approverId: "",
  totalAmount: 0,
  receipt:
    props.data.status == OrderStatus.PartiallyReceived ||
    props.data.status == OrderStatus.FullyReceived
      ? 1
      : 0,
});
const rules = reactive({
  code: [{ required: true, message: "不能为空" }],
  supplierId: [{ required: true, message: "不能为空" }],
});
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "supplierId", label: "供应商" },
  { prop: "categoryId", label: "分类" },
  { prop: "productId", label: "名称" },
  { prop: "specification", label: "规格" },
  { prop: "unit", label: "计量单位" },
  { prop: "quantityOrder", label: "订单数量" },
  { prop: "quantity", label: "退单数量" },
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
const getStatus = () => {
  const allReturn = tableData.value.every((item) => {
    return +item.quantity == +item.quantityOrder;
  });
  return allReturn ? OrderStatus.Returned : OrderStatus.PartiallyReturned;
};
const confirmSave = async (cb?: Function) => {
  if (totalAmount.value == 0) {
    ElMessage({
      type: "error",
      message: "采购退单商品列表不能为空",
    });
    return;
  }
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value, totalAmount: totalAmount.value };
    const res = await createReturn(params);
    const detailList: ReturnDetail[] = tableData.value.map((item: any) => {
      const { productId, categoryId, price, quantity, amount, supplierId } =
        item;
      return {
        productId,
        categoryId,
        price,
        quantity,
        returnId: (res as any).data.id,
        amount,
        supplierId,
      };
    });
    await deleteReturnDetail((res as any).data.id);
    await createReturnDetail(detailList);
    const order = { ...props.data, status: getStatus() };
    await editOrder(order);
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
    const returnRes: any = await getReturnList({ orderId: props?.data?.id });
    let returnListRes: any;
    if (returnRes?.data?.[0]) {
      form.value = Object.assign(form.value, returnRes?.data?.[0] || {});
      returnListRes = await getReturnDetailList(returnRes?.data?.[0].id);
    }

    const orderDetailRes: any = await getOrderDetailList(
      (props as any).data.id,
    );
    const quantityOrderMap = ref(new Map());
    orderDetailRes.data.map((item: any) => {
      const { productId, quantity } = item;
      quantityOrderMap.value.set(productId, quantity);
    });
    if (returnListRes?.data.length) {
      tableData.value = returnListRes.data.map((item: any) => {
        return {
          ...item,
          quantityOrder: quantityOrderMap.value.get(item.productId),
        };
      });
    } else {
      tableData.value = (orderDetailRes as any)?.data.map((item: any) => {
        return { ...item, quantityOrder: item.quantity };
      });
    }
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
