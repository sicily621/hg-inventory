<template>
  <div class="flex flex-col">
    <div class="w-full h-full flex flex-col">
      <el-card>
        <div class="zc-header-title">
          <div class="zc-header-icon"></div>
          <div class="zc-header-word">入库信息</div>
        </div>
      </el-card>
      <div class="flex flex-1">
        <el-card shadow="never">
          <el-form
            ref="formRef"
            :model="form"
            :rules="rules"
            label-position="top"
            class="flex flex-col relative"
            label-width="120px"
            require-asterisk-position="right"
          >
            <div class="d-flex width-250">
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
            </div>
            <div class="d-flex width-250">
              <el-form-item label="描述" prop="description">
                <el-input
                  v-model="form.description"
                  class="flex-1"
                  placeholder="请输入描述"
                  maxlength="32"
                  required
                >
                </el-input>
              </el-form-item></div
          ></el-form>
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
                {{ getName(scope.scope.row.categoryId, categoryMap) }}
              </template>
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
              <template #status="scope">
                <el-tag v-if="scope.scope.row.quantity === 0">未入库</el-tag>
                <el-tag
                  v-else-if="
                    scope.scope.row.quantity < scope.scope.row.orderQuantity
                  "
                  >部分入库</el-tag
                >
                <el-tag
                  v-else="
                    scope.scope.row.quantity === scope.scope.row.orderQuantity
                  "
                  >全部入库</el-tag
                >
              </template>
              <template #specification="scope">
                {{
                  getItem(scope.scope.row.productId, productMap)?.specification
                }}
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
                </div>
              </template>
            </baseTable>
          </div>
        </el-card>
      </div>
    </div>
    <el-dialog
      v-model="dialogFormVisible"
      title="商品入库"
      width="500"
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
        <div class="flex width-400">
          <el-form-item label="仓库" prop="warehouseId" class="flex-1">
            <el-select
              v-model="productForm.warehouseId"
              placeholder="请选择仓库"
              class="flex-1"
              @change="changeWarehouse()"
            >
              <el-option
                v-for="item in warehouseOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item class="flex-1 m-l-4" label="商品分类" prop="categoryId">
            <el-tree-select
              class="w-full"
              v-model="productForm.categoryId"
              placeholder="请选择商品分类"
              :data="categoryOptions"
              receipt-strictly
              :render-after-expand="false"
              :props="selectProps"
              @change="queryProductOptions"
              disabled
            />
          </el-form-item>
        </div>

        <div class="flex width-400">
          <el-form-item class="flex-1" label="区域" prop="areaId">
            <el-select
              v-model="productForm.areaId"
              placeholder="请选择区域"
              class="flex-1"
              @change="queryShelfOptions"
            >
              <el-option
                v-for="item in areaOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item class="flex-1 m-l-4" label="商品" prop="productId">
            <el-select
              v-model="productForm.productId"
              placeholder="请选择商品"
              class="flex-1"
              disabled
            >
              <el-option
                v-for="item in productOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
        </div>
        <div class="flex width-400">
          <el-form-item class="flex-1" label="货架" prop="shelfId">
            <el-select
              v-model="productForm.shelfId"
              placeholder="请选择货架"
              class="flex-1"
            >
              <el-option
                v-for="item in shelfOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item class="flex-1 m-l-4" label="入库数量" prop="quantity">
            <el-input-number
              v-model="productForm.quantity"
              :min="0"
              :max="productForm.orderQuantity"
              @change="changeQuantity"
              class="flex-1"
            />
          </el-form-item>
        </div>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="time"
            class="width-100"
            type="daterange"
            start-placeholder="生产日期"
            end-placeholder="过期日期"
            format="YYYY/MM/DD"
            value-format="YYYY-MM-DD"
            @change="changeTime"
          />
        </el-form-item>
        <div class="flex width-400">
          <div class="flex justify-end flex-1 items-center">
            <el-button
              v-if="editIndex > -1"
              type="primary"
              class="m-t-2"
              @click="addProduct"
              >确定</el-button
            >
          </div>
        </div>
      </el-form>
    </el-dialog>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import {
  Receipt,
  createReceipt,
  editReceipt,
  getReceiptList,
} from "../api/receipt";
import {
  ReceiptDetail,
  createReceiptDetail,
  deleteReceiptDetail,
  getReceiptDetailList,
} from "../api/receiptDetail";
import { getProductList } from "@/pages/productManagement/api/product";
import {
  Category,
  getCategoryList,
} from "@/pages/productManagement/api/category";
import { getWarehouseList } from "@/pages/warehouseManagement/api/warehouse";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import { getAreaList } from "@/pages/warehouseManagement/api/area";
import { getShelfList } from "@/pages/warehouseManagement/api/shelf";
import baseTable from "@@/components/baseTable/baseTable.vue";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/pinia/stores/user";
import { indexMethod } from "@@/utils/page";
import { OrderStatus, editOrder } from "@/pages/purchaseManagement/api/order";
import { getOrderDetailList } from "@/pages/purchaseManagement/api/orderDetail";
import { ReturnStatus, editReturn } from "@/pages/saleManagement/api/return";
import { getReturnDetailList } from "@/pages/saleManagement/api/returnDetail";
const userStore = useUserStore();
const pageSize = ref(1000);
const currentPage = ref(0);
const props = defineProps<{ data: any; type: number }>();
const formRef = ref();
const productFormRef = ref();
const selectProps = { value: "id", label: "name" };
const productOptions = ref<any[]>([]);
const dialogFormVisible = ref(false);
const closeModal = () => {
  dialogFormVisible.value = false;
  productForm.value = defaultProduct;
};
const openModal = () => {
  dialogFormVisible.value = true;
};
//表单
const form = ref<Receipt>({
  code: "",
  orderId: props.type === 1 ? props.data.id : props.data.orderId,
  employeeId: userStore.getInfo().id,
  description: "",
});

if (props.type === 1) {
  form.value.orderId = props.data.id;
}
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "categoryId", label: "商品分类" },
  { prop: "productId", label: "商品名称" },
  { prop: "areaId", label: "区域" },
  { prop: "shelfId", label: "货架" },
  { prop: "specification", label: "规格" },
  { prop: "orderQuantity", label: "订单数量" },
  { prop: "quantity", label: "入库数量" },
  { prop: "status", label: "状态" },
  { prop: "price", label: "单价" },
  { prop: "amount", label: "金额" },
  { prop: "productionDate", label: "生产日期" },
  { prop: "expirationDate", label: "过期日期" },
  { prop: "operate", label: "操作", width: 80 },
]);
const changeWarehouse = async () => {
  await queryAreaOptions();
  await queryShelfOptions();
};
const tableData = ref<any[]>([]);
const defaultProduct: ReceiptDetail = {
  productId: "",
  categoryId: "",
  warehouseId: "",
  shelfId: "",
  areaId: "",
  orderQuantity: 0,
  quantity: 0,
  price: 0,
  amount: 0,
};
const changeQuantity = () => {
  productForm.value.amount =
    +productForm.value.quantity * +productForm.value.price;
};
const time = ref<any>("");
const changeTime = () => {
  if (time.value?.[0] && time.value?.[1]) {
    productForm.value.productionDate = `${time.value?.[0]} 00:00:00`;
    productForm.value.expirationDate = `${time.value?.[1]} 23:59:59`;
  }
};
const productForm = ref<ReceiptDetail>(defaultProduct);

const rules = reactive({
  code: [{ required: true, message: "不能为空" }],
  warehouseId: [{ required: true, message: "不能为空" }],
  employeeId: [{ required: true, message: "不能为空" }],
});
const productRules = reactive({
  productId: [{ required: true, message: "不能为空" }],
  shelfId: [{ required: true, message: "不能为空" }],
  areaId: [{ required: true, message: "不能为空" }],
});
const areaOptions = ref<any[]>([]);
const shelfOptions = ref<any[]>([]);
const areaMap = ref(new Map());
const queryAreaOptions = async () => {
  const parmas: any = {};
  if (productForm.value.warehouseId)
    parmas.warehouseId = productForm.value.warehouseId;
  const res = await getAreaList(parmas);
  const { data } = res as any;
  areaOptions.value = data;
  productForm.value.areaId = 0;
  data.forEach((item: any, i: number) => {
    const { id } = item;
    if (i === 0) productForm.value.areaId = id;
    areaMap.value.set(id, item);
  });
  if (areaOptions.value.length == 0) {
    areaOptions.value = [{ name: "无", id: 0 }];
  }
};
const shelfMap = ref(new Map());
const queryShelfOptions = async () => {
  if (productForm.value.areaId == 0) {
    shelfOptions.value = [{ name: "无", id: 0 }];
    productForm.value.shelfId = 0;
    return;
  }
  const parmas: any = {};
  if (productForm.value.areaId) parmas.areaId = productForm.value.areaId;
  const res = await getShelfList(parmas);
  const { data } = res as any;
  productForm.value.shelfId = 0;
  shelfOptions.value = data;
  data.forEach((item: any, i: number) => {
    const { id } = item;
    if (i === 0) productForm.value.shelfId = id;
    shelfMap.value.set(id, item);
  });
  if (shelfOptions.value.length == 0) {
    shelfOptions.value = [{ name: "无", id: 0 }];
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
const categoryOptions = ref<any[]>([]);
const queryCategoryOptions = async () => {
  const res = await getCategoryList();
  if ((res as any)?.data?.length) {
    categoryOptions.value = buildCategoryTree((res as any)?.data || []);
    productForm.value.categoryId = categoryOptions.value[0].id;
  }
};
const productMap = ref(new Map());
const queryProductOptions = async () => {
  const params = {
    categoryId: productForm.value.categoryId,
  };
  const res = await getProductList(params);
  const { data } = res as any;
  productOptions.value = data;
  productForm.value.productId = "";
  data.forEach((item: any, index: number) => {
    const { id } = item;
    if (index === 0) productForm.value.productId = id;
    productMap.value.set(id, item);
  });
};

const warehouseOptions = ref<any[]>([]);
const warehouseMap = ref(new Map());
const queryWarehouseOptions = async () => {
  const res = await getWarehouseList({});
  const { data } = res as any;
  warehouseOptions.value = data;
  data.forEach((item: any, i: number) => {
    const { id } = item;
    if (i === 0) productForm.value.warehouseId = id;
    warehouseMap.value.set(id, item);
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
};
const editIndex = ref(-1);
const addProduct = async () => {
  const valid = await productFormRef.value.validate();
  if (valid) {
    const row: any = {
      ...productForm.value,
    };
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
const getName = (id: string, mapData: Map<string, string>) => {
  return mapData.get(id) ?? "无";
};
const getItem = (id: string, mapData: Map<string, any>) => {
  return mapData.get(id);
};
const confirmSave = async (cb?: Function) => {
  const status = checkStatus();
  if (!status) {
    ElMessage({
      type: "error",
      message: "入库商品列表不能为空",
    });
    return;
  }
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value };
    const api = params.id ? editReceipt : createReceipt;
    const res = await api(params);
    const detailList = tableData.value
      .filter((item: any) => item.quantity > 0)
      .map((item: any) => {
        const result = {
          ...item,
          receiptId: (res as any).data.id,
        };
        delete result["id"];
        return result;
      });
    await deleteReceiptDetail((res as any).data.id);
    await createReceiptDetail(detailList);
    if (props.type === 1) {
      await editOrder({ id: (props as any).data.id, status });
    } else {
      await editReturn({ id: (props as any).data.id, status });
    }
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};
const edit = (row: ReceiptDetail) => {
  editIndex.value = (row as any).index - 1;
  const { productionDate, expirationDate } = row;
  time.value = [productionDate, expirationDate];
  productForm.value = { ...row };
  openModal();
};
const checkStatus = () => {
  // 如果没有数据，视为未入库
  if (!tableData.value || tableData.value.length === 0) {
    return false;
  }
  // 检查是否所有quantity都为0
  const allZero = tableData.value.every((item) => +item.quantity === 0);
  if (allZero) {
    return false;
  }
  // 检查是否所有quantity都等于orderQuantity
  const allFull = tableData.value.every(
    (item) => +item.quantity === +item.orderQuantity,
  );
  if (allFull) {
    return props.type === 1
      ? OrderStatus.FullyReceived
      : ReturnStatus.FullyReceived;
  }
  // 其他情况都是部分入库
  return props.type === 1
    ? OrderStatus.PartiallyReceived
    : ReturnStatus.PartiallyReceived;
};
const receiptDetailsMap = ref<Map<any, any>>(new Map());
const queryReceipt = async () => {
  const params =
    props.type === 1
      ? { orderId: (props as any).data.id }
      : { orderId: (props as any).data.orderId };
  const receipt = await getReceiptList(params);
  if ((receipt as any)?.data?.[0]) {
    Object.assign(form.value, (receipt as any)?.data?.[0]);
    const receiptDetails = await getReceiptDetailList(String(form.value.id));
    if ((receiptDetails as any).data) {
      receiptDetailsMap.value.clear();
      (receiptDetails as any).data.map((item: any) => {
        receiptDetailsMap.value.set(item.productId, item);
      });
    }
  }
};
defineExpose({ confirmSave });
onMounted(async () => {
  await queryWarehouseOptions();
  await queryAreaOptions();
  await queryShelfOptions();
  await queryEmployeeOptions();
  await queryCategoryOptions();
  await queryProductOptions();
  await queryReceipt();
  const api = props.type === 1 ? getOrderDetailList : getReturnDetailList;
  const res = await api((props as any).data.id);
  tableData.value = (res as any)?.data.map((item: any, i: number) => {
    const { productId, categoryId, quantity, price, amount } = item;
    const receiptDetail = receiptDetailsMap.value.get(productId);
    const result = Object.assign({}, defaultProduct, {
      productId,
      categoryId,
      orderQuantity: quantity,
      quantity: 0,
      price,
      amount,
      index: i + 1,
    });
    if (receiptDetail) {
      Object.assign(result, receiptDetail);
    }
    return result;
  });
});
</script>
<style lang="scss" scoped>
@use "@@/assets/styles/size.scss" as *;
.width-300 {
  width: zrem(300);
}
.width-250 {
  width: zrem(250);
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
