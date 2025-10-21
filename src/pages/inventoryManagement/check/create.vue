<template>
  <div class="flex flex-col">
    <div class="w-full h-full flex flex-col">
      <el-card>
        <div class="zc-header-title">
          <div class="zc-header-icon"></div>
          <div class="zc-header-word">库存盘点信息</div>
        </div>
        <el-divider />
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
                :disabled="form.status === CheckStatus.Completed"
              >
              </el-input>
            </el-form-item>
          </div>
          <div class="d-flex width-300 m-l-8">
            <el-form-item label="仓库" prop="warehouseId">
              <el-select
                v-model="form.warehouseId"
                placeholder="请选择仓库"
                class="flex-1"
                @change="changeWarehouse()"
                :disabled="
                  form.status === CheckStatus.Completed || tableData.length > 0
                "
              >
                <el-option
                  v-for="item in warehouseOptions"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
          </div>
          <div class="d-flex width-300 m-l-8">
            <el-form-item label="状态" prop="status">
              <el-select
                v-model="form.status"
                placeholder="请选择状态"
                class="flex-1"
                :disabled="form.status === CheckStatus.Completed"
              >
                <el-option
                  v-for="item in CheckStatusList"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
          </div>
          <div class="d-flex width-300 m-l-8">
            <el-form-item label="描述" prop="description">
              <el-input
                v-model="form.description"
                class="flex-1"
                placeholder="请输入描述"
                maxlength="32"
                required
                :disabled="form.status === CheckStatus.Completed"
              >
              </el-input>
            </el-form-item></div></el-form
      ></el-card>
      <div class="flex flex-1">
        <el-card shadow="never" v-if="form.status !== CheckStatus.Completed">
          <div class="zc-header-title">
            <div class="zc-header-word">商品列表</div>
          </div>
          <el-divider />
          <el-form
            ref="productFormRef"
            :model="productForm"
            :rules="productRules"
            label-position="top"
            class="relative"
            label-width="120px"
            require-asterisk-position="right"
          >
            <div class="flex width-300">
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
              <el-form-item class="flex-1 m-l-4" label="货架" prop="shelfId">
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
            </div>
            <div class="flex width-300">
              <el-form-item class="flex-1" label="商品分类" prop="categoryId">
                <el-tree-select
                  class="w-full"
                  v-model="productForm.categoryId"
                  placeholder="请选择商品分类"
                  :data="categoryOptions"
                  check-strictly
                  :render-after-expand="false"
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
            </div>
            <div class="flex width-300">
              <el-form-item label="系统库存" class="flex-1">
                <el-input-number
                  v-model="productForm.systemQuantity"
                  :min="0"
                  disabled
                  class="flex-1"
                />
              </el-form-item>
              <el-form-item label="实际库存" class="flex-1 m-l-4">
                <el-input-number
                  v-model="productForm.actualQuantity"
                  :min="0"
                  class="flex-1"
                />
              </el-form-item>
            </div>

            <div class="flex width-300">
              <div class="flex justify-end flex-1 items-center">
                <el-button
                  type="primary"
                  class="m-t-2"
                  size="small"
                  :disabled="form.status === CheckStatus.Completed"
                  @click="addProduct"
                  >{{ editIndex > -1 ? "修改商品" : "添加商品" }}</el-button
                >
              </div>
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
              <template #operate="scope">
                <div class="flex" v-if="form.status !== CheckStatus.Completed">
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
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import {
  Check,
  createCheck,
  editCheck,
  CheckStatus,
  CheckStatusList,
} from "../api/check";
import {
  CheckDetail,
  createCheckDetail,
  getCheckDetailList,
  deleteCheckDetail,
} from "../api/checkDetail";
import { getProductList } from "@/pages/productManagement/api/product";
import {
  Category,
  getCategoryList,
} from "@/pages/productManagement/api/category";
import { getWarehouseList } from "@/pages/warehouseManagement/api/warehouse";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import { getAreaList } from "@/pages/warehouseManagement/api/area";
import { getShelfList } from "@/pages/warehouseManagement/api/shelf";
import {
  getInventoryList,
  batchUpdateInventory,
  Inventory,
} from "../api/inventory";
import { batchSaveHistory, HistoryType, History } from "../api/history";
import baseTable from "@@/components/baseTable/baseTable.vue";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/pinia/stores/user";
import { indexMethod } from "@@/utils/page";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
const userStore = useUserStore();
const pageSize = ref(1000);
const currentPage = ref(0);
const props = defineProps<{ data: Check | null }>();
const formRef = ref();
const productFormRef = ref();
const selectProps = { value: "id", label: "name" };
const productOptions = ref<any[]>([]);
//表单
const form = ref<Check>({
  code: `${ModuleCode.InventoryCheck}${formatTimeToString()}`,
  warehouseId: "",
  employeeId: userStore.getInfo().id,
  status: CheckStatus.InProgress,
  description: "",
});
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "productId", label: "商品" },
  { prop: "areaId", label: "区域" },
  { prop: "shelfId", label: "货架" },
  { prop: "systemQuantity", label: "系统库存数量" },
  { prop: "actualQuantity", label: "实际盘点数量" },
  { prop: "difference", label: "差异数量" },
  { prop: "description", label: "描述" },
  { prop: "operate", label: "操作", width: 80 },
]);
const changeWarehouse = async () => {
  await queryAreaOptions();
  await queryShelfOptions();
};
const tableData = ref<any[]>([]);
//合并props
if (props.data) {
  Object.assign(form.value, props.data);
}
const defaultProduct: CheckDetail = {
  productId: "",
  categoryId: "",
  shelfId: "",
  areaId: "",
  systemQuantity: 0,
  actualQuantity: 0,
  difference: 0,
  description: "",
};
const productForm = ref<CheckDetail>(defaultProduct);

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
  if (form.value.warehouseId) parmas.warehouseId = form.value.warehouseId;
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
    warehouseMap.value.set(id, item);
    if (i == 0) {
      form.value.warehouseId = id;
    }
  });
};
const inventoryMap = ref<Map<string, any>>(new Map());
const getInventoryByProductId = (key: string) => {
  return inventoryMap.value.get(key);
};
const queryInventory = async () => {
  const params: any = {};
  // if (productForm.value.productId)
  //   params.productId = productForm.value.productId;
  if (form.value.warehouseId) params.warehouseId = form.value.warehouseId;
  // if (productForm.value.shelfId) params.shelfId = productForm.value.shelfId;
  // if (productForm.value.areaId) params.areaId = productForm.value.areaId;
  const res: any = await getInventoryList(params);
  inventoryMap.value.clear();
  res.data.map((item: any) => {
    const { productId, quantity, areaId, shelfId } = item;
    if (
      productForm.value.productId == productId &&
      productForm.value.areaId == areaId &&
      productForm.value.shelfId == shelfId
    ) {
      productForm.value.actualQuantity = +quantity;
      productForm.value.systemQuantity = +quantity;
    }
    inventoryMap.value.set(`${shelfId}_${productId}`, item);
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
    const { systemQuantity, actualQuantity, productId, shelfId } =
      productForm.value;
    const inventory = getInventoryByProductId(`${shelfId}_${productId}`);
    const row: any = {
      ...productForm.value,
      difference: actualQuantity - systemQuantity,
    };
    if (inventory) {
      row.inventoryId = inventory.id; //库存ID
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
  }
};
const getName = (id: string, mapData: Map<string, string>) => {
  return mapData.get(id) ?? "无";
};
const getItem = (id: string, mapData: Map<string, any>) => {
  return mapData.get(id);
};
const confirmSave = async (cb?: Function) => {
  if (tableData.value.length == 0) {
    ElMessage({
      type: "error",
      message: "库存盘点商品列表不能为空",
    });
    return;
  }
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value };
    const api = params.id ? editCheck : createCheck;
    const res = await api(params);
    const detailList = tableData.value.map((item: any) => {
      const result = {
        ...item,
        checkId: (res as any).data.id,
      };
      delete result["id"];
      return result;
    });
    const needUpdateInventoryList: Inventory[] = tableData.value
      .filter((item) => item.inventoryId && +item.difference != 0)
      .map((item: any) => {
        const {
          productId,
          shelfId,
          areaId,
          actualQuantity: quantity,
          inventoryId,
        } = item;
        const data = {
          id: inventoryId,
          productId,
          warehouseId: form.value.warehouseId,
          shelfId,
          areaId,
          quantity,
        };
        return data;
      });
    const historyList = needUpdateInventoryList.map((item: any) => {
      item.type = HistoryType.InventoryAdjust;
      item.employeeId = userStore.getInfo().id;
      delete item["id"];
      return item;
    });
    await deleteCheckDetail((res as any).data.id);
    await createCheckDetail(detailList);
    //如果已经完成盘点，修改库存
    debugger;
    if (
      needUpdateInventoryList.length &&
      form.value.status === CheckStatus.Completed
    ) {
      await batchUpdateInventory(needUpdateInventoryList);
      await batchSaveHistory(historyList);
    }
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};
const edit = (row: any) => {
  editIndex.value = row.index - 1;
  productForm.value = { ...row };
};
const remove = (row: any) => {
  const index = tableData.value.findIndex((item) => item === row);
  if (index > -1) {
    tableData.value.splice(index, 1);
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
  await queryInventory();
  if (props?.data?.id) {
    const res = await getCheckDetailList((props as any).data.id);
    const list = (res as any)?.data || [];
    tableData.value = list.map((item: any, i: number) => {
      const { shelfId, productId } = item;
      //根据货架-商品找到库存ID
      const inventory = getInventoryByProductId(`${shelfId}_${productId}`);
      if (inventory) {
        item.inventoryId = inventory.id; //库存ID
      }
      item.index = i + 1;
      return item;
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
