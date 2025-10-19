<template>
  <div class="flex flex-col">
    <div class="el-card w-full h-full wrapper">
      <div class="zc-header-title">
        <div class="zc-header-icon"></div>
        <div class="zc-header-word">角色信息</div>
      </div>
      <el-divider />
      <div class="flex content-wrapper">
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
          <div class="tree-wrap">
            <tree
              :data="permissionOptions"
              :expandedKeys="expandedKeys"
              :currentNodeKey="currentNodeKey"
              ref="treeRef"
              @checkChange="checkChange"
              :checkBoxFlag="true"
              :checkedKeys="relations"
              placeholder="请输入权限名称"
              :propsObj="defaultProps"
              :searchFlag="true"
              check-strictly
            >
            </tree>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import { Role, createRole, editRole } from "../api/role";
import tree from "@@/components/tree/tree.vue";
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
//表单
const form = ref<Role>({
  name: "",
  code: `${ModuleCode.Role}${formatTimeToString()}`,
  description: "",
  status: 1,
});
const relations = ref<string[]>([]);
const permissionOptions = ref<any[]>([]);

//合并props
if (props.data) {
  Object.assign(form.value, props.data);
}

const rules = reactive({
  code: [{ required: true, message: "不能为空" }],
  name: [{ required: true, message: "不能为空" }],
});
// 左侧树列表
const virtualRootId = "root";
const treeRef = ref();

//左侧树列表props name当label
const defaultProps = {
  children: "children",
  label: "name",
};
const checkChange = (node: any) => {
  if (node.data.id == "checkAll") {
    const allIds: any[] = rawData.value.map((item: any) => item.id);
    const ids = node.checked ? [...allIds, "checkAll"] : [];
    treeRef.value.setCheckedKeys(ids);
  }
};
//树列表默认展开建筑
const expandedKeys = ref<Array<number | string>>([virtualRootId]);
//树列表当前选中建筑
const currentNodeKey = ref<number | string>("");
const confirmSave = async (cb?: Function) => {
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value };
    const api = params.id ? editRole : createRole;
    const res = await api(params);
    if (params.id) {
      await deleteRolePermissionRelations(String(params.id));
    }
    relations.value = treeRef.value
      .getCheckedNodes()
      .filter((item: any) => item.id != "checkAll")
      .map((item: any) => item.id);
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
const rawData = ref<any[]>([]);
const queryPermissionOptions = async () => {
  const res = await getPermissionList();
  if ((res as any)?.data?.length) {
    rawData.value = (res as any).data;
    permissionOptions.value = buildPermissionTree((res as any).data);
    permissionOptions.value.unshift({
      id: "checkAll",
      name: "全选",
      children: [],
    });
  }
};
const queryRelations = async () => {
  if (form.value.id) {
    const res = await getRolePermissionRelationsByRoleId(String(form.value.id));
    relations.value = (res as any).data.map(
      (item: RolePermissionRelations) => item.permissionId,
    );
    if (relations.value.length === rawData.value.length) {
      relations.value.unshift("checkAll");
    }
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
.wrapper {
  padding: zrem(20);
  height: calc(100% - zrem(40));
}
.content-wrapper {
  height: calc(100% - zrem(50));
}
.tree-wrap {
  height: calc(100% - zrem(30));
  border: zrem(1) solid var(--el-border-color);
}
</style>
