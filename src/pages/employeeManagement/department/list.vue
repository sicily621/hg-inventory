<template>
  <div class="app-container flex flex-col h-full">
    <div class="h-full w-full flex flex-col">
      <el-card v-loading="loading" shadow="never" class="search-wrapper">
        <div class="flex justify-between">
          <div class="zc-header-title">
            <div class="zc-header-icon"></div>
            <div class="zc-header-word">部门管理</div>
          </div>
          <el-button type="primary" v-if="enableCreate" @click="create"
            >新增一级部门</el-button
          >
        </div>
      </el-card>
      <div
        v-loading="loading"
        class="flex-grow-1 flex flex-col el-card table-card"
        shadow="never"
      >
        <div class="table-wrap">
          <el-table
            :data="tableData"
            row-key="id"
            default-expand-all
            highlight-current-row
            stripe
            class="text-align-center"
          >
            <el-table-column prop="name" label="部门名称" />
            <el-table-column
              prop="operate"
              label="操作"
              v-if="enableDelete || enableEdit || enableCreate"
            >
              <template #default="scope">
                <div class="flex">
                  <el-icon
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    v-if="enableEdit"
                    @click="edit(scope.row)"
                  >
                    <Edit />
                  </el-icon>
                  <el-icon
                    class="fz16 pointer m-r-5 cursor-pointer"
                    v-if="enableCreate"
                    text
                    @click="addSubDepartment(scope.row)"
                  >
                    <Plus />
                  </el-icon>
                  <el-icon
                    class="fz16 cursor-pointer"
                    text
                    v-if="!hasChildren(scope.row) && enableDelete"
                    @click="remove(scope.row.id)"
                  >
                    <Delete />
                  </el-icon>
                </div>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </div>
    <el-dialog
      v-model="dialogFormVisible"
      :title="isEdit ? '编辑部门' : '添加部门'"
      width="500"
      @close="closeModal()"
    >
      <el-form :model="form" ref="formRef" :rules="rules">
        <el-form-item
          label="所属部门名称"
          :label-width="140"
          v-if="!isEdit && currentData"
        >
          {{ currentData.name }}
        </el-form-item>
        <el-form-item label="部门名称" :label-width="140" prop="name">
          <el-input v-model="form.name" autocomplete="off" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closeModal()">取消</el-button>
          <el-button type="primary" @click="add()">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>
<script lang="ts" setup>
import { onMounted, ref, reactive } from "vue";
import {
  Department,
  getDepartmentList,
  deleteDepartment,
  createDepartment,
  editDepartment,
} from "../api/department";
import { ElMessage } from "element-plus";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();
const enableDelete = permissionStore.hasPermission(
  ModuleCode.Department,
  PermissionAction.Delete,
);
const enableCreate = permissionStore.hasPermission(
  ModuleCode.Department,
  PermissionAction.Add,
);
const enableEdit = permissionStore.hasPermission(
  ModuleCode.Department,
  PermissionAction.Edit,
);
const dialogFormVisible = ref(false);
const form = reactive({
  name: "",
});
const loading = ref<boolean>(false);
const formRef = ref();
const currentData = ref<Department | null>(null);
const isEdit = ref(false);
const rules = reactive({
  name: [{ required: true, message: "不能为空" }],
});
const tableData = ref<Department[]>([]);
const hasChildren = (row: Department) => {
  return departmentMap.get(row?.id)?.children.length > 0;
};

function refreshTable() {
  loading.value = true;
  getDepartmentList()
    .then((res: any) => {
      const { data } = res;
      if (data.length > 0) tableData.value = buildDepartmentTree(data);
    })
    .catch(() => {
      tableData.value = [];
    })
    .finally(() => {
      loading.value = false;
    });
}
const create = () => {
  currentData.value = null;
  dialogFormVisible.value = true;
};

const remove = async (id: string) => {
  await deleteDepartment(id);
  ElMessage({
    type: "success",
    message: "删除成功",
  });
  refreshTable();
};
const departmentMap = new Map();
function buildDepartmentTree(departments: Department[]) {
  // 第一步：创建所有部门的映射并初始化children
  departments.forEach((dept: Department) => {
    departmentMap.set(dept.id, {
      ...dept,
      children: [],
    });
  });

  // 第二步：建立所有层级的父子关系
  departments.forEach((dept: Department) => {
    const current = departmentMap.get(dept.id);
    if (dept.parentId !== 0) {
      const parent = departmentMap.get(dept.parentId);
      if (parent) {
        parent.children.push(current);
      }
    }
  });

  // 第三步：收集顶级部门
  return departments
    .filter((dept: Department) => dept.parentId === 0)
    .map((dept: Department) => departmentMap.get(dept.id));
}
const closeModal = () => {
  form.name = "";
  dialogFormVisible.value = false;
  currentData.value = null;
  isEdit.value = false;
};

const add = async () => {
  const valid = await formRef.value.validate();
  if (valid) {
    if (isEdit.value) {
      const params: any = {
        ...currentData.value,
        name: form.name,
      };
      await editDepartment(params);
    } else {
      const params: Department = {
        name: form.name,
        parentId: currentData.value?.id ?? 0,
        managerId: 0,
      };
      await createDepartment(params);
    }

    closeModal();
    refreshTable();
  }
};
const addSubDepartment = (row: Department) => {
  currentData.value = { ...row };
  dialogFormVisible.value = true;
};
const edit = (row: Department) => {
  isEdit.value = true;
  currentData.value = { ...row };
  form.name = currentData.value.name;
  dialogFormVisible.value = true;
};
onMounted(async () => {
  refreshTable();
});
</script>

<style lang="scss" scoped>
@use "@@/assets/styles/size.scss" as *;
.table-card {
  height: calc(100% - zrem(110));
}
.table-wrap {
  height: calc(100% - zrem(45));
}

.search-wrapper {
  height: zrem(60);
  margin-bottom: zrem(10);
}

.pager-wrapper {
  display: flex;
  justify-content: flex-end;
}
.create-wrap {
  height: calc(100% - zrem(45));
}
.footer {
  height: zrem(45);
}
</style>
