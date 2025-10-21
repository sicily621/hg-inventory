<template>
  <div class="flex flex-col">
    <div class="w-full h-full flex flex-col">
      <el-card>
        <div class="zc-header-title">
          <div class="zc-header-icon"></div>
          <div class="zc-header-word">出库信息</div>
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
                  :disabled="disabled"
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
                  :disabled="disabled"
                >
                </el-input>
              </el-form-item></div
          ></el-form>
        </el-card>
        <el-card class="flex-1" shadow="never">
          <el-tabs v-model="tabActiveIndex">
            <el-tab-pane
              :label="props.type === 1 ? '订单详情' : '退单详情'"
              :name="1"
            ></el-tab-pane>
            <el-tab-pane label="出库详情" :name="2"></el-tab-pane>
          </el-tabs>
          <div class="table-wrap">
            <baseTable
              :columns="columns"
              :table-data="tableData"
              class="h-full"
              :indexMethod="indexMethod(currentPage, pageSize)"
              v-if="tabActiveIndex === 1"
            >
              <template #categoryId="scope">
                {{ getName(scope.scope.row.categoryId, categoryMap) }}
              </template>
              <template #supplierId="scope">
                {{ getItem(scope.scope.row.supplierId, supplierMap) }}
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
                <el-tag v-if="scope.scope.row.quantity === 0">未出库</el-tag>
                <el-tag
                  v-else-if="
                    scope.scope.row.quantity < scope.scope.row.orderQuantity
                  "
                  >部分出库</el-tag
                >
                <el-tag
                  v-else="
                    scope.scope.row.quantity === scope.scope.row.orderQuantity
                  "
                  >全部出库</el-tag
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
                    v-if="
                      scope.scope.row.quantity < scope.scope.row.orderQuantity
                    "
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    @click="create(scope.scope.row)"
                  >
                    <Edit />
                  </el-icon>
                </div>
              </template>
            </baseTable>
            <baseTable
              v-if="tabActiveIndex === 2"
              :columns="columns2"
              :table-data="tableData2"
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
              <template #supplierId="scope">
                {{ getItem(scope.scope.row.supplierId, supplierMap) }}
              </template>
              <template #specification="scope">
                {{
                  getItem(scope.scope.row.productId, productMap)?.specification
                }}
              </template>
              <template #operate="scope">
                <div class="flex" v-if="!scope.scope.row?.id">
                  <el-icon
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    @click="edit(scope.scope.row)"
                  >
                    <Edit />
                  </el-icon>
                  <el-icon
                    class="fz16 pointer m-r-5 cursor-pointer"
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
      title="商品出库"
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
              shipment-strictly
              :render-after-expand="false"
              :props="selectProps"
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
          <el-form-item class="flex-1 m-l-4" label="出库数量" prop="quantity">
            <el-input-number
              v-model="productForm.quantity"
              :min="0"
              :max="max"
              @change="changeQuantity"
              class="flex-1"
            />
          </el-form-item>
        </div>
        <div class="flex width-400">
          <el-form-item class="flex-1 m-l-4" label="库存数量">
            <div class="flex flex-center w-full">
              <el-tag class="fz20 p-5">{{ inventory }}</el-tag>
            </div>
          </el-form-item>
        </div>
        <div class="flex width-400">
          <div class="flex justify-end flex-1 items-center">
            <el-button type="primary" class="m-t-2" @click="addProduct"
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
  Shipment,
  createShipment,
  editShipment,
  getShipmentList,
} from "../api/shipment";
import {
  ShipmentDetail,
  createShipmentDetail,
  deleteShipmentDetail,
  getShipmentDetailList,
} from "../api/shipmentDetail";
import { getReceiptList } from "../api/receipt";
import { getReceiptDetailList } from "../api/receiptDetail";
import {
  findProductListByIds,
  batchEditProduct,
} from "@/pages/productManagement/api/product";
import {
  Category,
  getCategoryList,
} from "@/pages/productManagement/api/category";
import { getWarehouseList } from "@/pages/warehouseManagement/api/warehouse";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import { getAreaList } from "@/pages/warehouseManagement/api/area";
import { getShelfList } from "@/pages/warehouseManagement/api/shelf";
import baseTable from "@@/components/baseTable/baseTable.vue";
import mergeRowTable from "@@/components/mergeRowTable/mergeRowTable.vue";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/pinia/stores/user";
import { indexMethod } from "@@/utils/page";
import { OrderStatus, editOrder } from "@/pages/saleManagement/api/order";
import { getOrderDetailList } from "@/pages/saleManagement/api/orderDetail";
import {
  ReturnStatus,
  editReturn,
} from "@/pages/purchaseManagement/api/return";
import { getReturnDetailList } from "@/pages/purchaseManagement/api/returnDetail";
import {
  shipment,
  getInventoryList,
  getInventoryByProductIds,
} from "@/pages/inventoryManagement/api/inventory";
import { batchSaveHistory, History, HistoryType } from "../api/history";
import {
  RelatedEntityType,
  AccountType,
  createAccount,
  AccountStatus,
  getAccountByOrderId,
  batchAccount,
} from "@/pages/accountManagement/api/account";
import { getSupplierList } from "@/pages/purchaseManagement/api/supplier";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
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
  max.value = getMax();
  dialogFormVisible.value = true;
};
const disabled = computed(() => {
  return props.type === 1
    ? props?.data?.status >= OrderStatus.FullyReceived
    : props?.data?.status === ReturnStatus.FullyReceived;
});
const tabActiveIndex = ref(1);
//表单
const form = ref<Shipment>({
  code: `${ModuleCode.InventoryShipment}${formatTimeToString()}`,
  orderId: props.type === 1 ? props?.data?.id : props?.data?.orderId,
  employeeId: userStore.getInfo().id,
  description: "",
});

if (props.type === 1) {
  form.value.orderId = props.data.id;
}
const columns = computed(() => {
  const result: any[] = [
    { prop: "index", label: "序号", width: "100", type: 1 },
    { prop: "categoryId", label: "商品分类" },
    { prop: "productId", label: "商品名称" },
    { prop: "specification", label: "规格" },
    {
      prop: "orderQuantity",
      label: props.type === 1 ? "订单数量" : "退单数量",
    },
    { prop: "quantity", label: "出库数量" },
    { prop: "status", label: "状态" },
    { prop: "price", label: "单价" },
    { prop: "amount", label: "金额" },
  ];
  if (props.type === 2) {
    result.splice(5, 0, { prop: "receiptQuantity", label: "已入库数量" });
    result.splice(3, 0, { prop: "supplierId", label: "供应商" });
  }
  if (!disabled.value) {
    result.push({ prop: "operate", label: "操作", width: 80 });
  }
  return result;
});
const columns2 = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "categoryId", label: "商品分类" },
  { prop: "productId", label: "商品名称" },
  { prop: "specification", label: "规格" },
  { prop: "batchNumber", label: "批次号" },
  { prop: "quantity", label: "出库数量" },
  { prop: "warehouseId", label: "仓库" },
  { prop: "areaId", label: "区域" },
  { prop: "shelfId", label: "货架" },
  { prop: "productionDate", label: "生产日期" },
  { prop: "expirationDate", label: "过期日期" },
  { prop: "createTime", label: "出库时间" },
  { prop: "operate", label: "操作", width: 80 },
]);
const changeWarehouse = async () => {
  await queryAreaOptions();
  await queryShelfOptions();
};
const tableData = ref<any[]>([]);
const tableData2 = ref<any[]>([]);
const defaultProduct: ShipmentDetail = {
  productId: "",
  categoryId: "",
  warehouseId: "",
  shelfId: "",
  areaId: "",
  orderQuantity: 0,
  quantity: 0,
  price: 0,
  amount: 0,
  batchNumber: 1,
};
const changeQuantity = () => {
  productForm.value.amount =
    +productForm.value.quantity * +productForm.value.price;
};

const productForm = ref<ShipmentDetail>(defaultProduct);
const max = ref(0);
const inventory = ref(0);
const queryInventory = async () => {
  const { productId, warehouseId, shelfId, areaId } = productForm.value;
  const params = { productId, warehouseId, shelfId, areaId };
  const res = await getInventoryList(params);
  if ((res as any)?.data?.[0]) {
    inventory.value = +(res as any)?.data?.[0].quantity;
  } else {
    inventory.value = 0;
  }
  max.value = getMax();
};
watch(
  [
    () => productForm.value.warehouseId,
    () => productForm.value.areaId,
    () => productForm.value.shelfId,
    () => productForm.value.productId,
  ],
  () => {
    queryInventory();
  },
);
const getMax = () => {
  const shipmentQuantity =
    shipmentDetailsMap.value.get(productForm.value.productId) ?? 0;
  const orderQuantity = orderQuantityMap.value.get(productForm.value.productId);
  if (editIndex.value > -1) {
    return Math.min(inventory.value, +orderQuantity);
  } else {
    if (productForm.value.orderQuantity) {
      return Math.min(
        inventory.value,
        +productForm.value.orderQuantity - shipmentQuantity,
      );
    } else {
      return 0;
    }
  }
};
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
  const ids = tableData.value.map((item: any) => item.productId).join(",");
  const res = await findProductListByIds(ids);
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
const editIndex0 = ref(-1);
const editIndex = ref(-1);
const addProduct = async () => {
  const valid = await productFormRef.value.validate();
  if (valid) {
    const row: any = {
      ...productForm.value,
    };
    if (row.quantity > 0) {
      if (editIndex.value > -1) {
        row.index = editIndex.value + 1;
        tableData2.value[editIndex.value] = row;
        editIndex.value = -1;
      } else {
        row.index = tableData2.value.length + 1;
        tableData2.value.push(row);
      }
    }
    if (editIndex0.value === -1) {
      const index = tableData.value.findIndex(
        (item: any) => item.productId === row.productId,
      );
      const cache = tableData2.value
        .filter((item) => item.productId === row.productId)
        .reduce((prev, cur) => {
          return prev + cur.quantity;
        }, 0);
      shipmentDetailsMap.value.set(row.productId, cache);
      tableData.value[index].quantity = cache;
    }
    if (editIndex0.value > -1) {
      const shipmentQuantity = shipmentDetailsMap.value.get(row.productId);
      const value = (shipmentQuantity ?? 0) + row.quantity;
      shipmentDetailsMap.value.set(row.productId, value);
      tableData.value[editIndex0.value].quantity += row.quantity;
      editIndex0.value = -1;
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

const create = (row: ShipmentDetail) => {
  editIndex0.value = (row as any).index - 1;
  productForm.value = { ...row };
  delete productForm.value["id"];
  openModal();
};
const edit = (row: ShipmentDetail) => {
  editIndex.value = (row as any).index - 1;
  productForm.value = { ...row };
  openModal();
};
const remove = (row: ShipmentDetail) => {
  const index = (row as any).index - 1;
  tableData2.value.splice(index, 1);
  tableData2.value.map((item, i) => {
    item.index = i + 1;
    return item;
  });
  const shipmentQuantity = shipmentDetailsMap.value.get(row.productId);
  shipmentDetailsMap.value.set(
    row.productId,
    (shipmentQuantity ?? 0) - Number(row.quantity),
  );
  const index0 = tableData.value.findIndex(
    (item) => item.productId === row.productId,
  );
  if (index0 > -1) {
    tableData.value[index0].quantity = shipmentDetailsMap.value.get(
      row.productId,
    );
  }
};
const checkStatus = () => {
  // 如果没有数据，视为未出库
  if (!tableData.value || tableData.value.length === 0) {
    return false;
  }
  // 检查是否所有quantity都为0
  const allZero = tableData.value.every((item) => +item.quantity === 0);
  if (allZero) {
    return false;
  }
  // 检查是否所有quantity都等于orderQuantity
  const allFull = tableData.value.every((item) => {
    if (props.type === 1) {
      return +item.quantity === +item.orderQuantity;
    } else {
      return +item.receiptQuantity === +item.quantity;
    }
  });
  if (allFull) {
    return props.type === 1
      ? OrderStatus.FullyReceived
      : ReturnStatus.FullyReceived;
  }
  // 其他情况都是部分出库
  return props.type === 1
    ? OrderStatus.PartiallyReceived
    : ReturnStatus.PartiallyReceived;
};
const shipmentDetailsMap = ref<Map<any, any>>(new Map());
const shipmentDetailsRawMap = ref<Map<any, any>>(new Map());
const queryShipment = async () => {
  const params =
    props.type === 1
      ? { orderId: (props as any)?.data?.id }
      : { orderId: (props as any)?.data?.orderId };
  const shipment = await getShipmentList(params);
  if ((shipment as any)?.data?.[0]) {
    Object.assign(form.value, (shipment as any)?.data?.[0]);
    const shipmentDetails = await getShipmentDetailList(String(form.value.id));
    if ((shipmentDetails as any).data) {
      shipmentDetailsMap.value.clear();
      shipmentDetailsRawMap.value.clear();
      (shipmentDetails as any).data.map((item: any) => {
        item.quantity = +item.quantity;
        const cache = shipmentDetailsMap.value.get(item.productId);
        if (cache) {
          shipmentDetailsMap.value.set(item.productId, cache + item.quantity);
        } else {
          shipmentDetailsMap.value.set(item.productId, item.quantity);
        }
        shipmentDetailsRawMap.value.set(
          item.productId,
          shipmentDetailsMap.value.get(item.productId),
        );
      });
      tableData2.value = (shipmentDetails as any).data.map(
        (item: any, i: number) => {
          item.index = i + 1;
          return item;
        },
      );
    }
  }
};
const confirmSave = async (cb?: Function) => {
  const status = checkStatus();
  if (!status) {
    ElMessage({
      type: "error",
      message: "出库商品列表不能为空",
    });
    return;
  }
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value };
    const api = params.id ? editShipment : createShipment;
    const res = await api(params);
    const detailList = tableData2.value
      .filter((item) => !item.id)
      .map((item: any) => {
        const result = {
          ...item,
          shipmentId: (res as any).data.id,
        };
        return result;
      });
    const list: any[] = detailList.map((item: any) => {
      const { productId, warehouseId, shelfId, areaId, quantity } = item;
      return {
        productId,
        warehouseId,
        shelfId,
        areaId,
        quantity,
      };
    });
    const accountMap = new Map();
    tableData.value
      .filter((item) => {
        const relatedEntityId =
          props.type === 2 ? item.supplierId : props.data.customerId;
        const index = accountList.value.findIndex((item) => {
          return (
            item.relatedEntityId === relatedEntityId &&
            item.type ===
              (props.type === 1
                ? AccountType.SalesRevenue
                : AccountType.PurchaseRefund)
          );
        });
        return (
          (props.type === 1
            ? item.orderQuantity == item.quantity && item.quantity > 0
            : item.receiptQuantity == item.quantity &&
              item.orderQuantity > 0) && index == -1
        );
      })
      .filter((item) => {
        if (props.type === 2) {
          const index = tableData.value.findIndex((otherItem) => {
            return (
              otherItem.supplierId === item.supplierId &&
              otherItem.receiptQuantity !== otherItem.quantity
            );
          });
          return index === -1;
        } else {
          return true;
        }
      })
      .map((item) => {
        const relatedEntityId =
          props.type === 2 ? item.supplierId : props.data.customerId;
        const prevAccount = accountMap.get(relatedEntityId)?.amount ?? 0;
        const prevCost = accountMap.get(relatedEntityId)?.cost ?? 0;
        const account = {
          orderId: props.type === 1 ? props.data.id : props.data.orderId,
          relatedCode: props.data.code,
          type:
            props.type === 1
              ? AccountType.SalesRevenue
              : AccountType.PurchaseRefund,
          relatedEntityType:
            props.type === 2
              ? RelatedEntityType.Suppiler
              : RelatedEntityType.Customer,
          relatedEntityId,
          amount: prevAccount + Number(item.amount),
          employeeId: userStore.getInfo().id,
          status: AccountStatus.Pending,
          description: "",
          cost:
            prevCost +
            Number(
              Number(Number(item.cost) * Number(item.quantity)).toFixed(2),
            ),
        };
        accountMap.set(relatedEntityId, account);
      });
    let accounts = [];
    for (const value of accountMap.values()) {
      accounts.push(value);
    }
    await shipment(list);
    await createShipmentDetail(detailList);
    if (props.type === 1) {
      await editOrder({
        id: (props as any).data.id,
        status,
        actualDate: Date.now(),
      });
    } else {
      await editReturn({ id: (props as any).data.id, status });
      if (status === ReturnStatus.FullyReceived) {
        //入库后重新计算采购平均成本
        const productIds = detailList
          .map((item: any) => item.productId)
          .join(",");
        const productInventoryRes: any =
          await getInventoryByProductIds(productIds);
        const productInventoryMap = new Map();
        productInventoryRes.data.map((item: any) => {
          const { productId, quantity } = item;
          if (productInventoryMap.has(productId)) {
            const { quantity: cache } = productInventoryMap.get(productId);
            productInventoryMap.set(productId, {
              productId,
              quantity: Number(cache) + Number(quantity),
            });
          } else {
            productInventoryMap.set(productId, {
              productId,
              quantity: Number(quantity),
            });
          }
        });
        const productNewPriceData = [...productInventoryMap.values()].map(
          (item: any) => {
            const { productId, quantity } = item;
            const orderQuantity = orderQuantityMap.value.get(productId);
            //原库存数量
            const oldReceiptQuantity = Number(quantity) - Number(orderQuantity);
            //订单采购价格
            const orderPrice = productPriceMap.value.get(productId);
            const { purchasePrice: oldPurchasePrice } =
              productMap.value.get(productId);
            const purchasePrice = +(
              (oldPurchasePrice * Number(quantity) -
                Number(orderQuantity) * Number(orderPrice)) /
              Number(oldReceiptQuantity)
            ).toFixed(2);
            return { id: productId, purchasePrice };
          },
        );
        await batchEditProduct(productNewPriceData);
      }
    }
    const historyList = list.map((item) => {
      item.type =
        props.type === 1 ? HistoryType.SaleOut : HistoryType.PurchaseReturn;
      item.employeeId = userStore.getInfo().id;
      return item;
    });
    await batchSaveHistory(historyList);
    //生成账单条件：一个订单下一个供应商所有商品都全部入库
    await batchAccount(accounts);
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};
const orderQuantityMap = ref<Map<any, any>>(new Map());
const productPriceMap = ref<Map<any, any>>(new Map());
const orderMap = ref<Map<any, any>>(new Map());
const accountList = ref<any[]>([]);
const queryAccount = async () => {
  const orderId = props.type === 1 ? props?.data?.id : props?.data?.orderId;
  const res = await getAccountByOrderId(orderId);
  accountList.value = (res as any).data;
};
defineExpose({ confirmSave });
const receiptDetailsMap = ref<Map<any, any>>(new Map());
onMounted(async () => {
  await querySupplierOptions();
  await queryWarehouseOptions();
  await queryAreaOptions();
  await queryShelfOptions();
  await queryEmployeeOptions();
  await queryCategoryOptions();
  await queryShipment();
  const api = props.type === 1 ? getOrderDetailList : getReturnDetailList;
  const res = await api((props as any)?.data?.id);
  if (props.type === 2) {
    const res = await getReceiptList({
      orderId: (props as any).data.orderId,
    });
    const receiptDetails = await getReceiptDetailList((res as any).data[0].id);
    if ((res as any).data[0]) {
      receiptDetailsMap.value.clear();
      (receiptDetails as any).data.map((item: any) => {
        item.quantity = +item.quantity;
        if (receiptDetailsMap.value.get(item.productId)) {
          const cache = receiptDetailsMap.value.get(item.productId);
          receiptDetailsMap.value.set(
            item.productId,
            Number(cache) + Number(item.quantity),
          );
        } else {
          receiptDetailsMap.value.set(item.productId, item.quantity);
        }
      });
    }
  }
  orderQuantityMap.value.clear();
  productPriceMap.value.clear();
  tableData.value = (res as any)?.data
    .map((item: any, i: number) => {
      const { productId, categoryId, quantity, price, amount } = item;
      const shipmentQuantity = shipmentDetailsMap.value.get(productId);
      const result: any = Object.assign({}, defaultProduct, {
        productId,
        categoryId,
        orderQuantity: Number(quantity),
        quantity: shipmentQuantity ?? 0,
        price,
        amount,
        cost: item.cost ?? 0,
        index: i + 1,
      });
      orderQuantityMap.value.set(productId, result.orderQuantity);
      if (props.type === 2) {
        result.supplierId = item.supplierId;
        result.receiptQuantity =
          receiptDetailsMap.value.get(item.productId) ?? 0;
      }
      orderQuantityMap.value.set(productId, result.orderQuantity);
      productPriceMap.value.set(productId, price);
      return result;
    })
    .filter((item: any) => item.orderQuantity > 0)
    .map((item: any, i: number) => {
      item.index = i + 1;
      return item;
    });
  await queryProductOptions();
  await queryAccount();
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
