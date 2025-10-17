<template>
  <div class="flex flex-col">
    <el-card class="w-full h-full">
      <div class="zc-header-title">
        <div class="zc-header-icon"></div>
        <div class="zc-header-word">权限信息</div>
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
          <el-form-item label="模块编码" prop="moduleCode">
            <el-input
              v-model="form.moduleCode"
              class="flex-1"
              placeholder="请输入编码"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="模块路径" prop="url">
            <el-input
              v-model="form.url"
              class="flex-1"
              placeholder="请输入模块路径"
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
        </div>
        <div class="width-300 d-flex m-l-16">
          <el-form-item label="父权限" prop="parentId">
            <el-tree-select
              v-model="form.parentId"
              placeholder="请选择父权限"
              :data="permissionOptions"
              check-strictly
              :render-after-expand="false"
              :props="selectProps"
              :disabled="!!props.data"
            />
          </el-form-item>
          <el-form-item label="操作类型" prop="action">
            <el-select v-model="form.action" placeholder="请选择操作类型">
              <el-option
                v-for="item in PermissionActionList"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="权限类型" prop="type">
            <el-select v-model="form.type" placeholder="请选择权限类型">
              <el-option
                v-for="item in PermissionTypeList"
                :key="item.id"
                :label="item.name"
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
import {
  Permission,
  createPermission,
  editPermission,
  getPermissionList,
  PermissionActionList,
  PermissionTypeList,
} from "../api/permission";
import { ElMessage } from "element-plus";
import { disabled } from "happy-dom/lib/PropertySymbol.js";
const props = defineProps<{ data: Permission | null }>();
const formRef = ref();
const selectProps = { value: "id", label: "name" };
//表单
const form = ref<Permission>({
  name: "",
  moduleCode: "",
  parentId: 0,
  url: "",
  description: "",
  action: 1,
  type: 1,
});
//合并props
if (props.data) {
  Object.assign(form.value, props.data);
}

const rules = reactive({
  name: [{ required: true, message: "不能为空" }],
  moduleCode: [{ required: true, message: "不能为空" }],
  parentId: [{ required: true, message: "不能为空" }],
  url: [{ required: true, message: "不能为空" }],
  action: [{ required: true, message: "不能为空" }],
  type: [{ required: true, message: "不能为空" }],
});

const confirmSave = async (cb?: Function) => {
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value };
    const api = params.id ? editPermission : createPermission;
    await api(params);
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};
const permissionOptions = ref([{ id: 0, name: "无" }]);
const queryPermissionOptions = async () => {
  const res = await getPermissionList();
  if ((res as any)?.data?.length) {
    permissionOptions.value = buildPermissionTree((res as any)?.data || []);
    permissionOptions.value.unshift({ id: 0, name: "无" });
  }
};
function buildPermissionTree(permissions: Permission[]) {
  const map = new Map();

  // 第一步：创建所有部门的映射并初始化children
  permissions.forEach((dept: Permission) => {
    map.set(dept.id, {
      ...dept,
      children: [],
    });
  });

  // 第二步：建立所有层级的父子关系
  permissions.forEach((dept: Permission) => {
    const current = map.get(dept.id);
    if (dept.parentId !== 0) {
      const parent = map.get(dept.parentId);
      if (parent) {
        parent.children.push(current);
      }
    }
  });

  // 第三步：收集顶级部门
  return permissions
    .filter((dept: Permission) => dept.parentId === 0)
    .map((dept: Permission) => map.get(dept.id));
}
onMounted(() => {
  queryPermissionOptions();
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
