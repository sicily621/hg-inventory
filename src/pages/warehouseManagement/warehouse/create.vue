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
            <span class="m-l-3">㎡</span>
          </el-form-item>
          <el-form-item label="负责人" prop="managerId">
            <el-select v-model="form.managerId" placeholder="请选择负责人">
              <el-option
                v-for="item in employeeOptions"
                :key="item.id"
                :label="item.username"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
        </div>
      </el-form>
    </el-card>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import { Warehouse, createWarehouse, editWarehouse } from "../api/warehouse";
import { ElMessage } from "element-plus";
import { getEmployeeList } from "@/pages/employeeManagement/api/employee";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
const props = defineProps<{ data: Warehouse | null }>();
const formRef = ref();
//表单
const form = ref<Warehouse>({
  code: `${ModuleCode.Warehouse}${formatTimeToString()}`,
  name: "",
  area: 0,
  managerId: "",
});
//合并props
if (props.data) {
  Object.assign(form.value, props.data);
}
const validateArea = (rule: any, value: any, callback: any) => {
  if (value <= 0) {
    callback(new Error("仓库面积应大于0"));
  } else {
    callback();
  }
};
const rules = reactive({
  code: [{ required: true, message: "不能为空" }],
  name: [{ required: true, message: "不能为空" }],
  managerId: [{ required: true, message: "不能为空" }],
  area: [{ required: true, validator: validateArea, trigger: "blur" }],
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
const employeeOptions = ref<any[]>([]);
const queryEmployeeOptions = async () => {
  const res = await getEmployeeList({});
  if ((res as any)?.data?.length) {
    employeeOptions.value = (res as any)?.data || [];
  }
};
onMounted(() => {
  queryEmployeeOptions();
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
