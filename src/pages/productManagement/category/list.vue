<template>
  <div class="app-container flex flex-col h-full">
    <div class="h-full w-full flex flex-col">
      <el-card v-loading="loading" shadow="never" class="search-wrapper">
        <div class="flex justify-between">
          <div class="zc-header-title">
            <div class="zc-header-icon"></div>
            <div class="zc-header-word">分类管理</div>
          </div>
          <el-button type="primary" v-if="enableCreate" @click="create"
            >新增一级分类</el-button
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
            <el-table-column prop="name" label="分类名称" />
            <el-table-column prop="operate" label="操作">
              <template #default="scope">
                <div class="flex">
                  <el-icon
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    @click="edit(scope.row)"
                    v-if="enableEdit"
                  >
                    <Edit />
                  </el-icon>
                  <el-icon
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    v-if="enableCreate"
                    @click="addSubCategory(scope.row)"
                  >
                    <Plus />
                  </el-icon>
                  <el-icon
                    class="fz16 cursor-pointer"
                    text
                    @click="remove(scope.row.id)"
                    v-if="!hasChildren(scope.row) && enableDelete"
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
      :title="isEdit ? '编辑分类' : '添加分类'"
      width="500"
      @close="closeModal()"
    >
      <el-form :model="form" ref="formRef" :rules="rules">
        <el-form-item
          label="所属分类名称"
          :label-width="140"
          v-if="!isEdit && currentData"
        >
          {{ currentData.name }}
        </el-form-item>
        <el-form-item label="分类名称" :label-width="140" prop="name">
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
  Category,
  getCategoryList,
  deleteCategory,
  createCategory,
  editCategory,
} from "../api/category";
import { ElMessage } from "element-plus";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();

const enableDelete = permissionStore.hasPermission(
  ModuleCode.Category,
  PermissionAction.Delete,
);
const enableCreate = permissionStore.hasPermission(
  ModuleCode.Category,
  PermissionAction.Add,
);
const enableEdit = permissionStore.hasPermission(
  ModuleCode.Category,
  PermissionAction.Edit,
);
const dialogFormVisible = ref(false);
const form = reactive({
  name: "",
});
const loading = ref<boolean>(false);
const formRef = ref();
const currentData = ref<Category | null>(null);
const isEdit = ref(false);
const rules = reactive({
  name: [{ required: true, message: "不能为空" }],
});
const tableData = ref<Category[]>([]);

function refreshTable() {
  loading.value = true;
  getCategoryList()
    .then((res: any) => {
      const { data } = res;
      if (data.length > 0) tableData.value = buildCategoryTree(data);
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
  await deleteCategory(id);
  ElMessage({
    type: "success",
    message: "删除成功",
  });
  refreshTable();
};
const categoryMap = new Map();
const hasChildren = (row: Category) => {
  return categoryMap.get(row?.id)?.children.length > 0;
};
function buildCategoryTree(categorys: Category[]) {
  // 第一步：创建所有分类的映射并初始化children
  categorys.forEach((dept: Category) => {
    categoryMap.set(dept.id, {
      ...dept,
      children: [],
    });
  });

  // 第二步：建立所有层级的父子关系
  categorys.forEach((dept: Category) => {
    const current = categoryMap.get(dept.id);
    if (dept.parentId !== 0) {
      const parent = categoryMap.get(dept.parentId);
      if (parent) {
        parent.children.push(current);
      }
    }
  });

  // 第三步：收集顶级分类
  return categorys
    .filter((dept: Category) => dept.parentId === 0)
    .map((dept: Category) => categoryMap.get(dept.id));
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
      await editCategory(params);
    } else {
      const params: Category = {
        name: form.name,
        parentId: currentData.value?.id ?? 0,
      };
      await createCategory(params);
    }

    closeModal();
    refreshTable();
  }
};
const addSubCategory = (row: Category) => {
  currentData.value = { ...row };
  dialogFormVisible.value = true;
};
const edit = (row: Category) => {
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
