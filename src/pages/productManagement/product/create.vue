<template>
  <div class="flex flex-col">
    <el-card class="w-full h-full">
      <div class="zc-header-title">
        <div class="zc-header-icon"></div>
        <div class="zc-header-word">商品信息</div>
      </div>
      <el-divider />
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
        class="flex relative flex-1"
        label-width="120px"
        require-asterisk-position="right"
      >
        <div class="width-300 d-flex">
          <el-form-item label="名称" prop="name">
            <el-input
              v-model="form.name"
              class="flex-1"
              placeholder="请输入名称"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
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
          <el-form-item label="采购价" prop="purchasePrice">
            <el-input
              v-model.number="form.purchasePrice"
              class="flex-1"
              placeholder="请输入采购价"
              maxlength="32"
              required
              :disabled="disabled"
            >
            </el-input>
          </el-form-item>
          <el-form-item label="零售价" prop="retailPrice">
            <el-input
              v-model.number="form.retailPrice"
              class="flex-1"
              placeholder="请输入零售价"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
        </div>
        <div class="width-300 d-flex m-l-16">
          <el-form-item label="商品分类" prop="categoryId">
            <el-tree-select
              v-model="form.categoryId"
              placeholder="请选择商品分类"
              :data="categoryOptions"
              check-strictly
              :render-after-expand="false"
              :props="selectProps"
            />
          </el-form-item>

          <el-form-item label="规格" prop="specification">
            <el-input
              v-model="form.specification"
              class="flex-1"
              placeholder="请输入规格"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="单位" prop="unit">
            <el-input
              v-model="form.unit"
              class="flex-1"
              placeholder="请输入单位"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
        </div>
        <div class="width-300 d-flex m-l-16">
          <el-form-item label="品牌" prop="brand">
            <el-input
              v-model="form.brand"
              class="flex-1"
              placeholder="请输入品牌"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="条形码" prop="barcode">
            <el-input
              v-model="form.barcode"
              class="flex-1"
              placeholder="请输入条形码"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
        </div>
      </el-form>
    </el-card>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import { Product, createProduct, editProduct } from "../api/product";
import { getInventoryByProductIds } from "@/pages/inventoryManagement/api/inventory";
import { Category, getCategoryList } from "../api/category";
import { ElMessage } from "element-plus";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
const props = defineProps<{ data: Product | null }>();
const formRef = ref();
const selectProps = { value: "id", label: "name" };
//表单
const form = ref<Product>({
  code: `${ModuleCode.Product}${formatTimeToString()}`,
  name: "",
  categoryId: "",
  purchasePrice: 0,
  retailPrice: 0,
  specification: "",
  unit: "",
  brand: "",
  barcode: "",
});
//合并props
if (props.data) {
  Object.assign(form.value, props.data);
}

const rules = reactive({
  code: [{ required: true, message: "不能为空" }],
  name: [{ required: true, message: "不能为空" }],
  categoryId: [{ required: true, message: "不能为空" }],
  purchasePrice: [{ required: true, message: "不能为空" }],
  retailPrice: [{ required: true, message: "不能为空" }],
});

function buildCategoryTree(categorys: Category[]) {
  const map = new Map();

  // 第一步：创建所有部门的映射并初始化children
  categorys.forEach((dept: Category) => {
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
const categoryOptions = ref<any[]>([{ name: "无", id: 0 }]);

const confirmSave = async (cb?: Function) => {
  try {
    const valid = await formRef.value.validate();
    if (valid) {
      const params = { ...form.value };
      const api = params.id ? editProduct : createProduct;
      await api(params);
      ElMessage({
        type: "success",
        message: "保存成功",
      });
      cb && cb();
    }
  } catch (error) {
    return false;
  }
};
const queryCategoryOptions = async () => {
  const res = await getCategoryList();
  if ((res as any)?.data?.length) {
    categoryOptions.value = buildCategoryTree((res as any)?.data || []);
  }
};
//是否可以编辑商品采购价，有库存的商品不能修改采购价了，在入库已经计算了
const disabled = ref(false);
const queryInventory = async (id: string) => {
  const res: any = await getInventoryByProductIds(id);
  const quantity = res.data.reduce((prev: number, cur: any) => {
    return prev + Number(cur.quantity);
  }, 0);
  disabled.value = quantity > 0 ? true : false;
};
onMounted(async () => {
  await queryCategoryOptions();
  if (props?.data?.id) queryInventory(props.data.id as any as string);
});
defineExpose({ confirmSave });
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
