<template>
  <div class="flex flex-col">
    <div class="w-full h-full flex flex-col">
      <el-card>
        <div class="zc-header-title">
          <div class="zc-header-icon"></div>
          <div class="zc-header-word">销售订单信息</div>
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
              <el-form-item prop="status" label="状态">
                <el-select
                  v-model="form.status"
                  placeholder="请选择状态"
                  class="w-full"
                  :disabled="true"
                >
                  <el-option
                    v-for="item in OrderStatusList"
                    :key="item.id"
                    :label="item.name"
                    :value="item.id"
                  />
                </el-select>
              </el-form-item>
              <el-form-item label="期望交货时间" prop="expectedDate">
                <el-date-picker
                  v-model="form.expectedDate"
                  type="datetime"
                  class="flex-1"
                  placeholder="请输入期望交货时间"
                  :default-time="defaultTime"
                  :disabled-date="isBefore"
                  :disabled="onlyView"
                />
              </el-form-item>
              <el-form-item label="客户" prop="customerId">
                <el-select
                  v-model="form.customerId"
                  placeholder="请选择客户"
                  class="w-full"
                  :disabled="onlyView"
                >
                  <el-option
                    v-for="item in customerOptions"
                    :key="item.id"
                    :label="item.name"
                    :value="item.id"
                  />
                </el-select>
              </el-form-item>

              <div class="flex">
                <el-form-item label="总金额" prop="totalAmount">
                  <el-tag class="fz22 p-5" type="primary"
                    >￥{{ totalAmount }}</el-tag
                  >
                </el-form-item>
              </div>

              <el-form-item label="备注" prop="description"
                ><el-input
                  v-model="form.description"
                  :disabled="onlyView"
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
          <div>
            <el-button
              type="primary"
              :icon="Plus"
              v-if="!onlyView"
              @click="dialogFormVisible = true"
              >新增商品</el-button
            >
          </div>
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
              <template #quantity="scope">
                <span v-if="onlyView">{{ scope.scope.row.quantity }}</span>
                <el-input-number
                  v-else
                  v-model="scope.scope.row.quantity"
                  :min="1"
                  @change="changeQuantity(scope.scope.row)"
                />
              </template>

              <template #price="scope">
                <el-input-number
                  v-model="scope.scope.row.price"
                  :step="0.1"
                  :disabled="onlyView"
                  @change="changeQuantity(scope.scope.row)"
                />
              </template>
              <template #cost="scope">
                <el-tag type="danger">￥{{ scope.scope.row.cost }}</el-tag>
              </template>
              <template #amount="scope">
                <el-tag type="danger">￥{{ scope.scope.row.amount }}</el-tag>
              </template>
              <template #operate="scope">
                <div class="flex" v-if="form.status === OrderStatus.Pending">
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
                    @click="remove(scope.scope.row)"
                  >
                    <Delete />
                  </el-icon>
                </div>
              </template>
            </baseTable>
          </div>
        </el-card>
      </div>
    </div>
    <el-dialog
      v-model="dialogFormVisible"
      :title="editIndex > -1 ? '编辑商品' : '添加商品'"
      width="600"
      @close="closeModal()"
    >
      <el-form
        ref="productFormRef"
        :model="productForm"
        :rules="productRules"
        label-position="top"
        class="relative"
        label-width="120px"
        require-asterisk-position="right"
      >
        <div class="flex width-full">
          <el-form-item class="flex-1" label="商品分类" prop="categoryId">
            <el-tree-select
              class="w-full"
              v-model="productForm.categoryId"
              placeholder="请选择商品分类"
              :data="categoryOptions"
              check-strictly
              :render-after-expand="true"
              :default-expand-all="true"
              :props="selectProps"
              @change="queryProductOptions"
            />
          </el-form-item>
          <el-form-item class="flex-1 m-l-4" label="商品" prop="productId">
            <el-select
              v-model="productForm.productId"
              placeholder="请选择商品"
              class="flex-1"
            >
              <el-option
                v-for="item in productOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="需求数量" class="flex-1 m-l-4" prop="quantity">
            <el-input-number
              v-model="productForm.quantity"
              :min="1"
              class="flex-1 m-r-2"
            />
          </el-form-item>
        </div>
        <div class="flex width-full">
          <el-form-item label="商品规格" class="flex-1">
            <el-input
              v-model="specification"
              class="flex-1"
              placeholder="请输入商品规格"
              maxlength="32"
              disabled
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="计量单位" class="flex-1 m-l-4">
            <el-input
              v-model="unit"
              class="flex-1"
              placeholder="请输入商品规格"
              maxlength="32"
              disabled
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="成本价" class="flex-1 m-l-4">
            <el-tag type="danger" class="fz18 p-t-5 p-b-5"
              >￥{{ selectedProduct.purchasePrice }}</el-tag
            >
          </el-form-item>

          <div class="flex-1 m-l-4"></div>
        </div>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closeModal()">取消</el-button>
          <el-button
            type="primary"
            :disabled="form.status !== OrderStatus.Pending"
            @click="addProduct"
            >确定</el-button
          >
        </div>
      </template>
    </el-dialog>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive, computed, onMounted } from "vue";
import { getOrderDetailList } from "../api/orderDetail";
import { getProductList } from "@/pages/productManagement/api/product";
import {
  Category,
  getCategoryList,
} from "@/pages/productManagement/api/category";
import {
  Order,
  OrderStatus,
  createOrder,
  editOrder,
  OrderStatusList,
} from "../api/order";
import {
  OrderDetail,
  createOrderDetail,
  deleteOrderDetail,
} from "../api/orderDetail";
import { getCustomerList } from "../api/customer";
import baseTable from "@@/components/baseTable/baseTable.vue";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/pinia/stores/user";
import { indexMethod } from "@@/utils/page";
import { Plus } from "@element-plus/icons-vue";
import { ModuleCode } from "@/router/moduleCode";
import { formatTimeToString } from "@@/utils/datetime";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();
const enableApprove = permissionStore.hasPermission(
  ModuleCode.SalesOrder,
  PermissionAction.Approve,
);
// const disabledApprove = computed(() => {
//   return !enableApprove;
// });

const pageSize = ref(1000);
const currentPage = ref(0);
const props = defineProps<{ data: Order | null; isApprove: boolean }>();
const onlyView = computed(() => {
  return form.value.status !== OrderStatus.Pending || props.isApprove;
});
const formRef = ref();
const defaultTime = new Date();
const userStore = useUserStore();
const categoryOptions = ref([{ name: "全部", id: 0 }]);
const selectProps = { value: "id", label: "name" };
const productOptions = ref<any[]>([]);
const isBefore = (date: Date) => {
  return date.getTime() - Date.now() <= 0;
};
const changeQuantity = (row: any) => {
  const { quantity, price } = row;
  row.amount = Number(Number(+quantity * +price).toFixed(1));
};
const productFormRef = ref();
const defaultProduct = {
  productId: "",
  categoryId: 0,
  quantity: 0,
  price: 0,
  amount: 0,
  cost: 0,
};
const productForm = ref<OrderDetail>(defaultProduct);
const productRules = reactive({
  productId: [{ required: true, message: "不能为空" }],
  categoryId: [{ required: true, message: "不能为空" }],
  quantity: [{ required: true, message: "不能为空" }],
});
const selectedProduct = computed(() => {
  return productOptions.value.find(
    (item: any) => item.id === productForm.value.productId,
  );
});
const specification = computed(() => {
  return selectedProduct.value?.specification;
});
const unit = computed(() => {
  return selectedProduct.value?.unit;
});

const editIndex = ref(-1);
const addProduct = async () => {
  const valid = await productFormRef.value.validate();
  if (valid) {
    productForm.value.price = getItem(
      String(productForm.value.productId),
      productMap.value,
    )?.retailPrice;
    const { price, quantity } = productForm.value;
    const row: any = {
      ...productForm.value,
      specification: specification.value,
      unit: unit.value,
      amount: +quantity * +price,
      cost: selectedProduct.value.purchasePrice,
    };
    const hasAdd = tableData.value.find((item: any, i: number) => {
      if (editIndex.value > -1) {
        return item.productId === row.productId && i != editIndex.value;
      } else {
        return item.productId === row.productId;
      }
    });
    if (hasAdd) {
      ElMessage.error("商品列表中的商品不能重复");
      return;
    }
    if (editIndex.value > -1) {
      row.index = editIndex.value + 1;
      tableData.value[editIndex.value] = row;
      editIndex.value = -1;
    } else {
      row.index = tableData.value.length + 1;
      tableData.value.push(row);
    }

    productForm.value = defaultProduct;
    closeModal();
  }
};

const dialogFormVisible = ref(false);
const closeModal = () => {
  editIndex.value = -1;
  dialogFormVisible.value = false;
};
//表单
const form = ref<Order>({
  code: `${ModuleCode.SalesOrder}${formatTimeToString()}`,
  customerId: "",
  employeeId: userStore.getInfo().id,
  expectedDate: Date.now(),
  actualDate: 0,
  status: OrderStatus.Pending,
  totalAmount: 0,
  discount: 0,
  tax: 0,
  finalAmount: 0,
  description: "",
  approverId: "",
});
const rules = reactive({
  code: [{ required: true, message: "不能为空" }],
  customerId: [{ required: true, message: "不能为空" }],
  expectedDate: [{ required: true, message: "不能为空" }],
  totalAmount: [{ required: true, message: "不能为空" }],
});
const columns = computed(() => {
  const result: any[] = [
    { prop: "index", label: "序号", width: "100", type: 1 },
    { prop: "categoryId", label: "分类" },
    { prop: "productId", label: "名称" },
    { prop: "specification", label: "规格" },
    { prop: "unit", label: "计量单位" },
    { prop: "quantity", label: "数量" },
    { prop: "price", label: "销售价" },
    { prop: "cost", label: "成本价" },
    { prop: "amount", label: "金额" },
  ];
  if (!onlyView.value) {
    result.push({ prop: "operate", label: "操作", width: 80 });
  }
  return result;
});
const edit = (row: any) => {
  editIndex.value = row.index - 1;
  productForm.value = { ...row };
  dialogFormVisible.value = true;
};
const remove = (row: any) => {
  const index = tableData.value.findIndex((item) => item === row);
  if (index > -1) {
    tableData.value.splice(index, 1);
  }
};
const tableData = ref<any[]>([]);
const totalAmount = computed(() => {
  let result = 0;
  tableData.value.map((item) => {
    result += +item.amount;
  });
  return result || props.data?.totalAmount || 0;
});
const finalAmount = computed(() => {
  return totalAmount.value - form.value.discount;
});
//合并props
if (props.data) {
  const params = { ...props.data };
  params.discount = +params.discount;
  params.totalAmount = +params.totalAmount;
  form.value = Object.assign(form.value, params);
}

const customerOptions = ref<any[]>([]);
const queryCustomerOptions = async () => {
  const res = await getCustomerList();
  if ((res as any)?.data?.length) {
    customerOptions.value = (res as any).data;
    form.value.customerId = customerOptions.value?.[0]?.id;
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
function findDeepestFirstChildRecursive(deptTree: any[]) {
  // 边界：无树或无第一个根节点
  if (!Array.isArray(deptTree) || deptTree.length === 0) {
    return null;
  }

  const firstRoot = deptTree[0];
  // 递归终止条件：当前节点无children，就是最深层节点
  if (!firstRoot.children || firstRoot.children.length === 0) {
    return firstRoot;
  }

  // 递归：传入当前节点的第一个子节点（继续向下找）
  return findDeepestFirstChildRecursive([firstRoot.children[0]]);
}

const categoryMap = ref(new Map());
const queryCategoryOptions = async () => {
  const res = await getCategoryList();
  if ((res as any)?.data?.length) {
    categoryOptions.value = buildCategoryTree((res as any)?.data || []);
    const firstNode = findDeepestFirstChildRecursive(categoryOptions.value);
    productForm.value.categoryId = firstNode.id;
  }
};
const productMap = ref(new Map());
const queryProductOptions = async () => {
  const res = await getProductList({});
  const { data } = res as any;
  productOptions.value = data;
  data.forEach((item: any, i: number) => {
    const { id } = item;
    productMap.value.set(id, item);
    if (i === 0) {
      productForm.value.productId = id;
    }
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
    const params: any = {
      ...form.value,
      totalAmount: totalAmount.value,
      finalAmount: finalAmount.value,
    };
    if (
      enableApprove &&
      (params.status == OrderStatus.Approved ||
        params.status == OrderStatus.Rejected)
    ) {
      params.approverId = userStore.getInfo().id;
      params.approvalTime = Date.now();
    }
    if (params.approvalTime == 0) delete params["approvalTime"];
    if (params.actualDate == 0) delete params["actualDate"];
    const api = params.id ? editOrder : createOrder;
    const res = await api(params);
    const detailList: OrderDetail[] = tableData.value.map((item: any) => {
      const { productId, categoryId, price, quantity, amount, cost } = item;
      return {
        productId,
        categoryId,
        price,
        quantity,
        orderId: (res as any).data.id,
        amount,
        cost,
      };
    });
    await deleteOrderDetail((res as any).data.id);
    await createOrderDetail(detailList);
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};
const approve = async (cb?: Function) => {
  form.value.status = OrderStatus.Approved;
  await confirmSave(cb);
};
const rejected = async (cb?: Function) => {
  form.value.status = OrderStatus.Rejected;
  await confirmSave(cb);
};
const confirm = async (cb?: Function) => {
  form.value.status = OrderStatus.Confirmed;
  await confirmSave(cb);
};
defineExpose({ confirmSave, approve, rejected, confirm });
onMounted(async () => {
  await queryCustomerOptions();
  await queryCategoryOptions();
  await queryProductOptions();
  if (props?.data?.id) {
    const res = await getOrderDetailList((props as any).data.id);
    tableData.value = (res as any)?.data.map((item: any) => {
      const { quantity, productId } = item;
      const price = props.data
        ? +item.price
        : getItem(productId, productMap.value)?.retailPrice;
      return { ...item, amount: quantity * price, price };
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
