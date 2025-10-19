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
              <el-form-item prop="code" label="编码">
                <el-input v-model="searchData.code" placeholder="请输入" />
              </el-form-item>
              <el-form-item prop="name" label="名称">
                <el-input v-model="searchData.name" placeholder="请输入" />
              </el-form-item>
            </el-form>
            <el-button type="primary" @click="create" v-if="enableCreate"
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
              <template #operate="scope">
                <div class="flex">
                  <el-icon
                    class="fz16 pointer m-r-5 cursor-pointer"
                    text
                    @click="edit(scope.scope.row)"
                    v-if="enableEdit"
                  >
                    <Edit />
                  </el-icon>
                  <el-icon
                    class="fz16 cursor-pointer"
                    text
                    @click="remove(scope.scope.row.id)"
                    v-if="enableDelete"
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
      :title="isEdit ? '编辑货架' : '添加货架'"
      width="500"
      @close="closeModal()"
    >
      <el-form :model="form" ref="formRef" :rules="rules">
        <el-form-item label="货架名称" :label-width="140" prop="name">
          <el-input v-model="form.name" autocomplete="off" />
        </el-form-item>
        <el-form-item label="货架编码" :label-width="140" prop="code">
          <el-input v-model="form.code" autocomplete="off" />
        </el-form-item>
        <el-form-item label="层数" :label-width="140" prop="layerCount">
          <el-input v-model.number="form.layerCount" autocomplete="off" />
        </el-form-item>
        <el-form-item label="最大容量" :label-width="140" prop="maxCapacity">
          <el-input v-model.number="form.maxCapacity" autocomplete="off" />
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
  queryShelfConditions,
  deleteShelf,
  findShelfPage,
  editShelf,
  createShelf,
  Shelf,
} from "../api/shelf";
import { findAreaPage, queryAreaConditions } from "../api/area";
import { getWarehouseList } from "../api/warehouse";
import { indexMethod } from "@@/utils/page";
import { watchDebounced } from "@vueuse/core";
import { ElMessage } from "element-plus";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
import { usePermissionStore } from "@/pinia/stores/permission";
import { PermissionAction } from "@/pages/employeeManagement/api/permission";
const permissionStore = usePermissionStore();

const enableDelete = permissionStore.hasPermission(
  ModuleCode.Shelf,
  PermissionAction.Delete,
);
const enableCreate = permissionStore.hasPermission(
  ModuleCode.Shelf,
  PermissionAction.Add,
);
const enableEdit = permissionStore.hasPermission(
  ModuleCode.Shelf,
  PermissionAction.Edit,
);
const dialogFormVisible = ref(false);
const isEdit = ref(false);
const form = reactive<Shelf>({
  name: "",
  code: `${ModuleCode.Shelf}${formatTimeToString()}`,
  areaId: "",
  layerCount: 0,
  maxCapacity: 0,
});
const formRef = ref();
const rules = reactive({
  name: [{ required: true, message: "不能为空" }],
  code: [{ required: true, message: "不能为空" }],
});
const closeModal = () => {
  delete form["id"];
  form.name = "";
  form.code = `${ModuleCode.Shelf}${formatTimeToString()}`;
  form.layerCount = 0;
  form.maxCapacity = 0;
  dialogFormVisible.value = false;
  currentData.value = null;
  isEdit.value = false;
};
const add = async () => {
  const valid = await formRef.value.validate();
  if (valid) {
    const params: Shelf = {
      ...form,
      areaId: String(currentNodeKey.value),
    };
    if (isEdit.value) {
      await editShelf(params);
    } else {
      await createShelf(params);
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

const currentNode = ref({ id: 0, name: "", level: 0 });
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
  tableData.value = [];
  treeRef.value.setCurrentKey(null);
  if (data.level == 1) {
    if (!expandedKeys.value.includes(data.id)) expandedKeys.value.push(data.id);
    if (data.children.length == 0) {
      queryAreaList(data.id, data);
    } else {
      currentNode.value = data.children[0];
      treeRef.value.setCurrentKey(data?.children[0]?.id);
      currentNodeKey.value = data?.children[0]?.id;
      refreshTable();
    }
  } else if (data.level == 2) {
    treeRef.value.setCurrentKey(data.id);
    currentNodeKey.value = data.id;
    currentNode.value = data;
    refreshTable();
  }
};

const loading = ref<boolean>(false);
const processFlag = ref(0); // 0列表 1新建 2编辑
const columns = ref([
  { prop: "index", label: "序号", width: "100", type: 1 },
  { prop: "name", label: "名称" },
  { prop: "code", label: "编码" },
  { prop: "layerCount", label: "最大层数" },
  { prop: "maxCapacity", label: "最大容量(KG)" },
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
const currentData = ref<Shelf | null>(null);
const edit = (row: Shelf) => {
  const { id, name, code, layerCount, maxCapacity, areaId } = row;
  form.id = id;
  form.name = name;
  form.code = code;
  form.layerCount = layerCount;
  form.maxCapacity = maxCapacity;
  form.areaId = areaId;
  dialogFormVisible.value = true;
};

const tableData = ref<Shelf[]>([]);

const searchFormRef = ref("searchFormRef");

const searchData = reactive<queryShelfConditions>({
  code: "",
  name: "",
  areaId: currentNodeKey.value,
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
  const params: PaginatedRequest<queryShelfConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
  };
  if (searchData.code) params.code = searchData.code;
  if (searchData.name) params.name = searchData.name;
  if (currentNodeKey.value) params.areaId = currentNodeKey.value;
  findShelfPage(params)
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
  await deleteShelf(id);
  ElMessage({
    type: "success",
    message: "删除成功",
  });
  refreshTable();
};
const queryWarehouseOptions = async () => {
  const res = await getWarehouseList({});
  if ((res as any)?.data?.length) {
    rawParkData.value = (res as any)?.data.map((node: any, index: number) => {
      const { id, name } = node;
      if (index == 0) currentNodeKey.value = id;
      return { id, name, level: 1 };
    });
    treeData.value = rawParkData.value;
    if (rawParkData.value.length > 0) {
      const firstNode = rawParkData.value[0];
      expandedKeys.value.push(firstNode.id);
      //查询建筑
      await queryAreaList(firstNode.id, firstNode);
    }
  }
};
const queryAreaList = async (warehouseId: string, parentNode: any) => {
  const params: PaginatedRequest<queryAreaConditions> = {
    currentPage: currentPage.value + 1,
    size: pageSize.value,
    warehouseId,
  };
  const res = await findAreaPage(params);
  const { total, list } = (res as any).data;
  totalItems.value = total;
  tableData.value = list;
  parentNode.children = list.map((item: any) => {
    const { id, name } = item;
    return {
      id,
      name,
      warehouseId,
      level: 2,
    };
  });
  treeRef.value.setCurrentKey(null);
  treeRef.value.setCurrentKey(parentNode.children[0].id);
  currentNode.value = parentNode.children[0];
  currentNodeKey.value = parentNode.children[0].id;
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
