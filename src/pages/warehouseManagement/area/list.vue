<template>
  <div class="app-container flex h-full">
    <div class="left el-card">
      <tree
        :data="treeData"
        :expandedKeys="expandedKeys"
        :currentNodeKey="currentNodeKey"
        ref="treeRef"
        @changeNode="changeNode($event)"
        @changeFilter="filter($event)"
        placeholder="请输入名称"
        :propsObj="defaultProps"
        :searchFlag="true"
      >
      </tree>
    </div>
    <div class="flex-1 flex flex-col h-full">
      <div class="h-full w-full flex flex-col" v-if="!processFlag">
        <el-card v-loading="loading" shadow="never" class="search-wrapper">
          <div class="flex">
            <el-form
              ref="searchFormRef"
              class="flex-grow-1"
              :inline="true"
              :model="searchData"
            >
              <el-form-item prop="type" label="类型">
                <el-select
                  class="w-40"
                  v-model="searchData.type"
                  placeholder="请选择区域类型"
                >
                  <el-option
                    v-for="item in searchAreaTypeList"
                    :key="item.id"
                    :label="item.name"
                    :value="item.id"
                  />
                </el-select>
              </el-form-item>
            </el-form>
            <el-button type="primary" v-if="enableCreate" @click="create"
              >新增</el-button
            >
          </div>
        </el-card>
        <div
          v-loading="loading"
          class="flex-grow-1 flex flex-col el-card table-card"
          shadow="never"
        >
          <div class="table-wrap">
            <baseTable
              :columns="columns"
              :table-data="tableData"
              :indexMethod="indexMethod(currentPage, pageSize)"
              class="h-full"
            >
              <template #type="scope">
                <el-tag
                  type="primary"
                  v-if="scope.scope.row.type === AreaType.Save"
                  >存货区
                </el-tag>
                <el-tag
                  type="primary"
                  v-if="scope.scope.row.type === AreaType.Receive"
                  >收货区
                </el-tag>
                <el-tag
                  type="primary"
                  v-if="scope.scope.row.type === AreaType.Send"
                  >发货区
                </el-tag>
              </template>
              <template #operate="scope">
                <div class="flex">
                  <el-icon
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    v-if="enableEdit"
                    @click="edit(scope.scope.row)"
                  >
                    <Edit />
                  </el-icon>
                  <el-icon
                    class="fz16 cursor-pointer"
                    text
                    v-if="enableDelete"
                    @click="remove(scope.scope.row.id)"
                  >
                    <Delete />
                  </el-icon>
                </div>
              </template>
            </baseTable>
          </div>
          <div class="pager-wrapper h-12 p-r-4">
            <pagination
              :page-size="pageSize"
              :current-page="currentPage + 1"
              :total="totalItems"
              @pageChange="pageChange($event)"
              class="zc-page"
            ></pagination>
          </div>
        </div>
      </div>
    </div>
    <el-dialog
      v-model="dialogFormVisible"
      :title="isEdit ? '编辑区域' : '添加区域'"
      width="500"
      @close="closeModal()"
    >
      <el-form :model="form" ref="formRef" :rules="rules">
        <el-form-item label="区域名称" :label-width="140" prop="name">
          <el-input v-model="form.name" autocomplete="off" />
        </el-form-item>
        <el-form-item label="区域类型" :label-width="140" prop="type">
          <el-select v-model="form.type" placeholder="请选择区域类型">
            <el-option
              v-for="item in AreaTypeList"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
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
import tree from "@@/components/tree/tree.vue";
import baseTable from "@@/components/baseTable/baseTable.vue";
import pagination from "@@/components/pagination/pagination.vue";
import type { PaginatedRequest } from "@@/apis/tables/type";
import {
  queryAreaConditions,
  deleteArea,
  findAreaPage,
  editArea,
  createArea,
  Area,
  AreaType,
  AreaTypeList,
} from "../api/area";
import { getWarehouseList } from "../api/warehouse";
import { indexMethod } from "@@/utils/page";
import { watchDebounced } from "@vueuse/core";
import { ElMessage } from "element-plus";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();

const enableDelete = permissionStore.hasPermission(
  ModuleCode.Area,
  PermissionAction.Delete,
);
const enableCreate = permissionStore.hasPermission(
  ModuleCode.Area,
  PermissionAction.Add,
);
const enableEdit = permissionStore.hasPermission(
  ModuleCode.Area,
  PermissionAction.Edit,
);
const searchAreaTypeList = [{ id: 0, name: "全部" }, ...AreaTypeList];
const dialogFormVisible = ref(false);
const isEdit = ref(false);
const form = reactive<Area>({
  name: "",
  type: 1,
  warehouseId: 0,
});
const formRef = ref();
const rules = reactive({
  name: [{ required: true, message: "不能为空" }],
  type: [{ required: true, message: "不能为空" }],
});
const closeModal = () => {
  delete form["id"];
  form.name = "";
  dialogFormVisible.value = false;
  currentData.value = null;
  isEdit.value = false;
};
const add = async () => {
  const valid = await formRef.value.validate();
  if (valid) {
    const params: Area = {
      ...form,
      warehouseId: String(currentNodeKey.value),
    };
    if (isEdit.value) {
      await editArea(params);
    } else {
      await createArea(params);
    }

    closeModal();
    refreshTable();
  }
};
const treeRef = ref();

// 左侧树列表
const virtualRootId = "root";
const treeData: any = ref<any[]>([
  {
    id: virtualRootId,
    name: "仓库",
    children: [],
  },
]);

//为过滤保留源数据
const rawParkData = ref<any[]>([]);

//左侧树列表props name当label
const defaultProps = {
  children: "children",
  label: "name",
};

//树列表默认展开建筑
const expandedKeys = ref<Array<number | string>>([virtualRootId]);
//树列表当前选中建筑
const currentNodeKey = ref<number | string>("");

//左侧树列表 过滤
const filter = (text: string) => {
  treeData.value[0].children = rawParkData.value.filter((node: any) =>
    node.name.includes(text),
  );
  currentNodeKey.value = treeData?.value[0]?.children[0]?.id ?? 0;
  refreshTable();
};

//左侧树列表 选中节点变化触发
const changeNode = (data: any) => {
  if (data.id === virtualRootId) {
    if (data.children.length > 0) {
      currentNodeKey.value = data?.children[0]?.id;
      treeRef.value.setCurrentKey(currentNodeKey.value);
    } else {
      currentNodeKey.value = virtualRootId;
      return;
    }
  } else {
    currentNodeKey.value = data.id;
  }
  refreshTable();
};

const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "name", label: "名称" },
  { prop: "type", label: "区域类型" },
  { prop: "operate", label: "操作", width: 100 },
]);

//分页
const pageSize = ref(10);
const currentPage = ref(0);
const totalItems = ref(0);
const pageChange = (page: any) => {
  currentPage.value = page - 1;
  refreshTable();
};
const currentData = ref<Area | null>(null);
const edit = (row: Area) => {
  const { id, name, type, warehouseId } = row;
  form.id = id;
  form.name = name;
  form.type = type;
  form.warehouseId = warehouseId;
  dialogFormVisible.value = true;
};

const tableData = ref<Area[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryAreaConditions>({
  type: 0,
  warehouseId: currentNodeKey.value,
});

watchDebounced(
  searchData,
  () => {
    refreshTable();
  },
  { debounce: 500, maxWait: 1000 },
);
function refreshTable() {
  loading.value = true;
  const params: PaginatedRequest<queryAreaConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.type) params.type = searchData.type;
  if (currentNodeKey.value) params.warehouseId = currentNodeKey.value;
  findAreaPage(params)
    .then((res: any) => {
      const { total, list } = res.data;
      totalItems.value = total;
      tableData.value = list;
    })
    .catch(() => {
      tableData.value = [];
    })
    .finally(() => {
      loading.value = false;
    });
}
const create = () => {
  dialogFormVisible.value = true;
};
const remove = async (id: string) => {
  await deleteArea(id);
  ElMessage({
    type: "success",
    message: "删除成功",
  });
  refreshTable();
};
const warehouseOptions = ref<any[]>([]);
const queryWarehouseOptions = async () => {
  const res = await getWarehouseList({});
  if ((res as any)?.data?.length) {
    warehouseOptions.value = (res as any)?.data || [];
    rawParkData.value = (res as any)?.data.map((node: any, index: number) => {
      const { id, name } = node;
      if (index == 0) currentNodeKey.value = id;
      return { id, name };
    });
    treeData.value[0].children = rawParkData.value;
  }
};

onMounted(async () => {
  await queryWarehouseOptions();
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
.left {
  width: zrem(220);
  margin-right: zrem(8);
  padding: zrem(16) zrem(10);
}
</style>
