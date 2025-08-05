<template>
  <div class="flex flex-col">
    <el-card class="w-full h-full">
      <div class="zc-header-title">
        <div class="zc-header-icon"></div>
        <div class="zc-header-word">仓库信息</div>
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
          <el-form-item label="面积" prop="area">
            <el-input
              v-model.number="form.area"
              class="flex-1"
              placeholder="请输入面积"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="负责人" prop="managerId"> </el-form-item>
        </div>
      </el-form>
    </el-card>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import { Warehouse, createWarehouse, editWarehouse } from "../api/warehouse";
import { ElMessage } from "element-plus";
const props = defineProps<{ data: Warehouse | null }>();
const formRef = ref();
//表单
const form = ref<Warehouse>({
  code: "",
  name: "",
  area: 0,
  managerId: 0,
});
//合并props
if (props.data) {
  Object.assign(form.value, props.data);
}

const rules = reactive({
  code: [{ required: true, message: "不能为空" }],
  name: [{ required: true, message: "不能为空" }],
});

const confirmSave = async (cb?: Function) => {
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value };
    const api = params.id ? editWarehouse : createWarehouse;
    await api(params);
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};
// const queryEmployeeOptions = async () => {
//   const res = await getCategoryList();
//   if ((res as any)?.data?.length) {
//     categoryOptions.value = buildCategoryTree((res as any)?.data || []);
//   }
// };
onMounted(() => {
  //queryCategoryOptions();
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
