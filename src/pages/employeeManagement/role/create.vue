<template>
  <div class="flex flex-col">
    <el-card class="w-full h-full">
      <div class="zc-header-title">
        <div class="zc-header-icon"></div>
        <div class="zc-header-word">角色信息</div>
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
          <el-form-item label="描述" prop="description">
            <el-input
              v-model="form.description"
              class="flex-1"
              placeholder="请输入描述"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :value="1">在职</el-radio>
              <el-radio :value="0">离职</el-radio>
            </el-radio-group>
          </el-form-item>
        </div>
      </el-form>
    </el-card>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive } from "vue";
import { Role, createRole, editRole } from "../api/role";
const props = defineProps<{ data: Role | null }>();
const formRef = ref();
//表单
const form = ref<Role>({
  name: "",
  code: "",
  description: "",
  status: 1,
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
    const api = params.id ? editRole : createRole;
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
