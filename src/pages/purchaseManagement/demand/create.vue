<template>
  <div class="flex flex-col">
    <div class="w-full h-full flex flex-col">
      <el-card>
        <div class="zc-header-title">
          <div class="zc-header-icon"></div>
          <div class="zc-header-word">采购需求信息</div>
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
            <el-form-item label="需求说明" prop="description">
              <el-input
                v-model="form.description"
                class="flex-1"
                placeholder="请输入需求说明"
                maxlength="32"
                required
                :disabled="onlyView"
              >
              </el-input>
            </el-form-item>
          </div>
          <div class="d-flex width-300 m-l-16">
            <el-form-item label="期望到货时间" prop="expectedArrivalDate">
              <el-date-picker
                v-model="form.expectedArrivalDate"
                type="datetime"
                class="flex-1"
                placeholder="请输入期望到货时间"
                :default-time="defaultTime"
                :disabled-date="isBefore"
                :disabled="onlyView"
              />
            </el-form-item>
          </div>
          <div class="d-flex width-300 m-l-16">
            <el-form-item label="状态" prop="status">
              <el-select
                v-model="form.status"
                placeholder="请选择状态"
                class="flex-1"
                disabled
              >
                <el-option
                  v-for="item in DemandStatusList"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
          </div> </el-form
      ></el-card>
      <div class="flex flex-1">
        <el-card shadow="never" v-if="!onlyView">
          <div class="zc-header-title">
            <div class="zc-header-word">商品信息</div>
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
            </div>
            <div class="flex width-300">
              <el-form-item label="需求数量" class="flex-1" prop="quantity">
                <el-input-number
                  v-model="productForm.quantity"
                  :min="1"
                  class="flex-1 m-r-2"
                />
              </el-form-item>
              <div class="flex justify-end flex-1 items-center">
                <el-button
                  type="primary"
                  class="m-t-2"
                  size="small"
                  :disabled="form.status === DemandStatus.WorkOrder"
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
              <template #unit="scope">
                {{ getItem(scope.scope.row.productId, productMap)?.unit }}
              </template>
              <template #specification="scope">
                {{
                  getItem(scope.scope.row.productId, productMap)?.specification
                }}
              </template>
              <template #operate="scope">
                <div class="flex" v-if="form.status === DemandStatus.Pending">
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
import { ref, reactive, computed, onMounted } from "vue";
import {
  Demand,
  createDemand,
  editDemand,
  DemandStatus,
  DemandStatusList,
} from "../api/demand";
import {
  DemandDetail,
  createDemandDetail,
  getDemandDetailList,
  deleteDemandDetail,
} from "../api/demandDetail";
import { getProductList } from "@/pages/productManagement/api/product";
import {
  Category,
  getCategoryList,
} from "@/pages/productManagement/api/category";

import baseTable from "@@/components/baseTable/baseTable.vue";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/pinia/stores/user";
import { indexMethod } from "@@/utils/page";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
import { ModuleCode } from "@/router/moduleCode";
const permissionStore = usePermissionStore();
const enableApprove = permissionStore.hasPermission(
  ModuleCode.PurchaseDemand,
  PermissionAction.Approve,
);
const pageSize = ref(1000);
const currentPage = ref(0);
const props = defineProps<{ data: Demand | null; isApprove: boolean }>();
const onlyView = computed(() => {
  return form.value.status !== DemandStatus.Pending || props.isApprove;
});
const formRef = ref();
const productFormRef = ref();
const defaultTime = new Date();
const userStore = useUserStore();
const selectProps = { value: "id", label: "name" };
const categoryOptions = ref([{ name: "全部", id: 0 }]);
const productOptions = ref<any[]>([]);
const isBefore = (date: Date) => {
  return date.getTime() - Date.now() <= 0;
};
//表单
const form = ref<Demand>({
  departmentId: userStore.getInfo().departmentId,
  applicantId: userStore.getInfo().id,
  expectedArrivalDate: Date.now(),
  description: "",
  status: DemandStatus.Pending,
  approverId: "",
  approvalTime: 0,
});
const columns = computed(() => {
  const result: any[] = [
    { prop: "index", label: "序号", width: "100", type: 1 },
    { prop: "categoryId", label: "分类" },
    { prop: "productId", label: "名称" },
    { prop: "specification", label: "规格" },
    { prop: "unit", label: "计量单位" },
    { prop: "quantity", label: "数量" },
  ];
  if (!onlyView.value)
    result.push({ prop: "operate", label: "操作", width: 80 });
  return result;
});
const tableData = ref<any[]>([]);
//合并props
if (props.data) {
  Object.assign(form.value, props.data);
}
const defaultProduct = {
  productId: "",
  categoryId: 0,
  quantity: 0,
};
const productForm = ref<DemandDetail>(defaultProduct);

const rules = reactive({
  expectedArrivalDate: [{ required: true, message: "不能为空" }],
});
const productRules = reactive({
  productId: [{ required: true, message: "不能为空" }],
  categoryId: [{ required: true, message: "不能为空" }],
  quantity: [{ required: true, message: "不能为空" }],
});

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
const seletedProduct = computed(() => {
  return productOptions.value.find(
    (item: any) => item.id === productForm.value.productId,
  );
});
const specification = computed(() => {
  return seletedProduct.value?.specification;
});
const unit = computed(() => {
  return seletedProduct.value?.unit;
});
const editIndex = ref(-1);
const addProduct = async () => {
  const valid = await productFormRef.value.validate();
  if (valid) {
    const row: any = {
      ...productForm.value,
      specification: specification.value,
      unit: unit.value,
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
      message: "采购需求商品列表不能为空",
    });
    return;
  }
  const valid = await formRef.value.validate();
  if (valid) {
    const params: any = { ...form.value };
    const api = params.id ? editDemand : createDemand;

    if (
      params.id &&
      enableApprove &&
      (params.status == DemandStatus.Approved ||
        params.status == DemandStatus.Rejected)
    ) {
      params.approverId = userStore.getInfo().id;
      params.approvalTime = Date.now();
    }
    if (params.approvalTime == 0) delete params["approvalTime"];
    const res = await api(params);
    const detailList = tableData.value.map((item: any) => {
      const { productId, categoryId, quantity } = item;
      return {
        productId,
        categoryId,
        quantity,
        demandId: (res as any).data.id,
      };
    });
    await deleteDemandDetail((res as any).data.id);
    await createDemandDetail(detailList);
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
const approve = async (cb?: Function) => {
  form.value.status = DemandStatus.Approved;
  await confirmSave(cb);
};
const rejected = async (cb?: Function) => {
  form.value.status = DemandStatus.Rejected;
  await confirmSave(cb);
};
defineExpose({ confirmSave, approve, rejected });
onMounted(async () => {
  await queryCategoryOptions();
  await queryProductOptions();
  if (props?.data?.id) {
    const res = await getDemandDetailList((props as any).data.id);
    tableData.value = (res as any)?.data || [];
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
