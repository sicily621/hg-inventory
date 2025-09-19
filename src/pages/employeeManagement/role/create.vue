<template>
  <div class="flex flex-col">
    <el-card class="w-full h-full">
      <div class="zc-header-title">
        <div class="zc-header-icon"></div>
        <div class="zc-header-word">角色信息</div>
      </div>
      <el-divider />
      <div class="flex">
        <el-form
          ref="formRef"
          :model="form"
          :rules="rules"
          label-position="top"
          class="flex relative"
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
        <div class="width-350 m-l-16">
          <div class="fz14">拥有权限</div>
          <el-tree-select
            class="w-full"
            v-model="relations"
            default-expand-all
            placeholder="请选择权限"
            :data="permissionOptions"
            check-strictly
            :render-after-expand="false"
            collapse-tags
            :max-collapse-tags="3"
            :props="selectProps"
            multiple
          >
          </el-tree-select>
        </div>
      </div>
    </el-card>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import { Role, createRole, editRole } from "../api/role";
import {
  RolePermissionRelations,
  createRolePermissionRelations,
  getRolePermissionRelationsByRoleId,
  deleteRolePermissionRelations,
} from "../api/rolePermissionRelations";
import { Permission, getPermissionList } from "../api/permission";
import { ElMessage } from "element-plus";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
const props = defineProps<{ data: Role | null }>();
const formRef = ref();
const selectProps = { value: "id", label: "name" };
//表单
const form = ref<Role>({
  name: "",
  code: `${ModuleCode.Role}${formatTimeToString()}`,
  description: "",
  status: 1,
});
const relations = ref<string[]>([]);
const permissionOptions = ref<Permission[]>([]);

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
    const res = await api(params);
    if (params.id) {
      await deleteRolePermissionRelations(String(params.id));
    }
    const relationsParams: RolePermissionRelations[] = relations.value.map(
      (permissionId) => {
        return {
          roleId: String((res as any).data.id),
          permissionId: String(permissionId),
        };
      },
    );
    await createRolePermissionRelations(relationsParams);
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
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
const queryPermissionOptions = async () => {
  const res = await getPermissionList();
  if ((res as any)?.data?.length) {
    permissionOptions.value = buildPermissionTree((res as any).data);
  }
};
const queryRelations = async () => {
  if (form.value.id) {
    const res = await getRolePermissionRelationsByRoleId(String(form.value.id));
    relations.value = (res as any).data.map(
      (item: RolePermissionRelations) => item.permissionId,
    );
  }
};
onMounted(async () => {
  await queryPermissionOptions();
  await queryRelations();
});
defineExpose({ confirmSave });
</script>
<style lang="scss" scoped>
@use "@@/assets/styles/size.scss" as *;
.width-300 {
  width: zrem(300);
}
.width-350 {
  width: zrem(350);
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
.fz14 {
  font-size: 14px;
  line-height: 22px;
  margin-bottom: 8px;
}
</style>
