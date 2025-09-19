<template>
  <div class="flex flex-col">
    <el-card class="w-full h-full">
      <div class="zc-header-title">
        <div class="zc-header-icon"></div>
        <div class="zc-header-word">供应商信息</div>
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
          <el-form-item label="地址" prop="address">
            <el-input
              v-model="form.address"
              class="flex-1"
              placeholder="请输入地址"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="联系人" prop="contactPerson">
            <el-input
              v-model="form.contactPerson"
              class="flex-1"
              placeholder="请输入联系人"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
        </div>
        <div class="width-300 d-flex m-l-16">
          <el-form-item label="电话" prop="phone">
            <el-input
              v-model="form.phone"
              class="flex-1"
              placeholder="请输入电话"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="邮箱" prop="email">
            <el-input
              v-model="form.email"
              class="flex-1"
              placeholder="请输入邮箱"
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
        </div>
      </el-form>
    </el-card>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import { Supplier, createSupplier, editSupplier } from "../api/supplier";
import { ElMessage } from "element-plus";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
const props = defineProps<{ data: Supplier | null }>();
const formRef = ref();
//表单
const form = ref<Supplier>({
  name: "",
  phone: "",
  email: "",
  address: "",
  code: `${ModuleCode.Supplier}${formatTimeToString()}`,
  contactPerson: "",
});
//合并props
if (props.data) {
  Object.assign(form.value, props.data);
}
const validatePhone = (rule: any, value: any, callback: any) => {
  const phoneReg = /^1[3-9]\d{9}$/;
  if (value === "") {
    callback(new Error("不能为空"));
  } else if (!phoneReg.test(value)) {
    callback(new Error("请输入正确手机号"));
  } else {
    callback();
  }
};
const validateEmail = (rule: any, value: any, callback: any) => {
  const emailReg = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (value === "") {
    callback(new Error("不能为空"));
  } else if (!emailReg.test(value)) {
    callback(new Error("请输入正确邮箱"));
  } else {
    callback();
  }
};
const rules = reactive({
  name: [{ required: true, message: "不能为空" }],
  code: [{ required: true, message: "不能为空" }],
  contactPerson: [{ required: true, message: "不能为空" }],
  phone: [{ required: true, validator: validatePhone, trigger: "blur" }],
  email: [{ required: true, validator: validateEmail, trigger: "blur" }],
});

const confirmSave = async (cb?: Function) => {
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value };
    const api = params.id ? editSupplier : createSupplier;
    await api(params);
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};

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
