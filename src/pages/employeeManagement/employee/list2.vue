<template>
  <div class="d-flex h-full w-full">
    <div class="flex-1 flex-column w-full" v-if="!processFlag">
      <div class="zc-header d-flex align-items-center justify-content-between">
        <div class="d-flex m-r-20">
          <template v-if="projectOptions.length > 1">
            <el-text default class="m-r-8">{{
              i18nM("space.label.project")
            }}</el-text>
            <el-select
              v-model="projectId"
              :placeholder="i18nM('space.placeholder.selectProject')"
              class="w-200"
              @change="projectChange"
            >
              <el-option
                v-for="item in projectOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </template>
          <template v-else>
            <div class="zc-header-title">
              <div class="zc-header-icon"></div>
              <div class="zc-header-word">
                {{ i18nM("space.title.buildingConfig") }}
              </div>
            </div>
          </template>
        </div>
        <div class="m-r-20">
          <el-button
            :type="'primary'"
            @click="openCreateModal"
            v-if="hasPermission(PermissionType.Create, permissions)"
          >
            <img :src="AddIcon" width="16" height="16" class="el-icon" />
            <span>{{ i18nM("space.button.add") }}</span>
          </el-button>
        </div>
      </div>
      <div class="d-flex zc-content">
        <div class="left">
          <tree
            :data="treeData"
            :expandedKeys="parkExpandedKeys"
            :currentNodeKey="parkCurrentNodeKey"
            ref="treeRef"
            @changeNode="changeNode($event)"
            @changeFilter="parkFilter($event)"
            :placeholder="i18nM('space.placeholder.inputParkName')"
            :propsObj="defaultProps"
            :searchFlag="true"
          >
          </tree>
        </div>
        <div class="right flex-1 flex-column h-full">
          <div class="table-right flex-column flex-1 h-full">
            <div class="zc-base p-r-20 p-l-20 flex-column flex-1">
              <div ref="tableRef" class="flex-1 table-wrap">
                <baseTable
                  :columns="columns"
                  :table-data="tableData"
                  :indexMethod="indexMethod(currentPage, pageSize)"
                >
                  <template #operate="scope">
                    <el-icon
                      class="fz20 m-r-20 pointer"
                      v-if="hasPermission(PermissionType.Update, permissions)"
                      @click="editEvent(scope.scope)"
                    >
                      <Edit />
                    </el-icon>
                    <el-icon
                      class="fz20 pointer"
                      v-if="hasPermission(PermissionType.Delete, permissions)"
                      @click="deleteEvent(scope.scope)"
                    >
                      <Delete />
                    </el-icon>
                  </template>
                  <template
                    v-for="col in columns"
                    v-slot:[`${col.prop}Header`]="{ scope }"
                  >
                    <div>{{ i18nM(scope.label) }}</div>
                    <div class="fz12">{{ scope.unit }}</div>
                  </template>
                </baseTable>
              </div>
            </div>
            <div
              class="zc-footer d-flex align-items-center justify-content-end"
              v-if="totalItems > 0"
            >
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
    </div>
    <div
      class="flex-1 flex-column h-full create-wrap fill-bg"
      v-if="processFlag"
    >
      <create ref="createRef" :data="currentData" :park-id="parkCurrentNodeKey">
      </create>
      <div
        class="zc-footer p-r-20 p-l-20 d-flex align-items-center"
        style="justify-content: flex-end"
      >
        <div>
          <el-button :type="'primary'" class="m-r-16 w-80" @click="save()">{{
            i18nM("space.button.save")
          }}</el-button>
          <el-button class="w-80" plain @click="back()">{{
            i18nM("space.button.back")
          }}</el-button>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import tree from "@static/elementUI/tree/tree.vue";
import { ref, onMounted, computed } from "vue";
import baseTable from "@static/table/baseTable/baseTable.vue";
import pagination from "@static/elementUI/pagination/pagination.vue";
import Create from "@functions/serviceCenter/space-management/buildingManagement/create.vue";
import { getNameMapByIds } from "@functions/serviceCenter/tenant-management/api/projects";
import {
  Building,
  BuildingTableItem,
  getBuildingPage,
  deleteBuilding,
  getBuildingListParams,
} from "@functions/serviceCenter/space-management/api/building";
import {
  getParkGetByProjectId,
  ParkTreeNode,
} from "@functions/serviceCenter/space-management/api/park";
import { ElMessage, ElMessageBox } from "element-plus";
import { getPageSizeCount, getPageCount } from "@static/js/page/utils";
import AddIcon from "@static/images/add.png";
import useMenuStore from "@static/js/store/menu";
import { ComponentPropsType } from "@static/js/page/props";
import {
  PermissionType,
  hasPermission,
  getPermissionCount,
} from "@static/js/page/permission";
import { indexMethod } from "@static/js/common/utils";
const i18nM = window.$i18nM;

const menuStore = useMenuStore();
const props = defineProps<ComponentPropsType>();
const permissions = computed(() =>
  menuStore.getComponentPermissions(props.configData?.operateTypes)
);
const permissionCount = getPermissionCount(
  [PermissionType.Update, PermissionType.Delete],
  permissions.value
);

//页面隐藏标识
const processFlag = ref(0); // 0列表 1新建 2编辑
const hiddenSave = ref(true);
const createRef = ref();
const treeRef = ref();
const tableRef = ref();
const projectId = ref<string>("");
const projectOptions = ref<any[]>([]);
const projectChange = () => {
  refreshTree();
};
const addDataFlag = ref(false);
//当前编辑建筑
let currentData = ref<Building>();

// 左侧园区树列表
const virtualRootId = "park-root";
const treeData: any = ref<ParkTreeNode[]>([
  {
    id: virtualRootId,
    name: i18nM("space.label.park"),
    children: [],
  },
]);

//为过滤保留源数据
const rawParkData = ref<ParkTreeNode[]>([]);

//左侧园区树列表props name当label
const defaultProps = {
  children: "children",
  label: "name",
};

//树列表默认展开建筑
const parkExpandedKeys = ref<Array<number | string>>([virtualRootId]);
//树列表当前选中建筑
const parkCurrentNodeKey = ref<number | string>("");

//右侧建筑表格
const columns = computed(() => [
  { prop: "index", label: i18nM("space.label.serialNumber"), width: 100 },
  { prop: "name", label: i18nM("space.label.name"), type: 2, width: 200 },
  { prop: "areaCovered", label: i18nM("space.label.areaCovered") },
  { prop: "buildUpArea", label: i18nM("space.label.buildUpArea"), type: 2 },
  { prop: "heatingArea", label: i18nM("space.label.heatingArea"), type: 2 },
  { prop: "floorNumber", label: i18nM("space.label.aboveGroundFloors") },
  { prop: "undergroundNumber", label: i18nM("space.label.undergroundFloors") },
  {
    prop: "description",
    label: i18nM("space.label.description"),
    type: 2,
    width: 200,
  },
  {
    prop: "operate",
    label: i18nM("space.label.operation"),
    type: 2,
    width: permissionCount * 40 + 24,
  },
]);
const tableData = ref<BuildingTableItem[]>([]);

//新建打开弹窗
const openCreateModal = () => {
  if (
    parkCurrentNodeKey.value === virtualRootId ||
    parkCurrentNodeKey.value === ""
  ) {
    ElMessage({
      type: "error",
      message: i18nM("space.error.pleaseSelectPark"),
    });
    return;
  }
  processFlag.value = 1;
  hiddenSave.value = false;
};
//保存
const save = () => {
  if (processFlag.value) {
    if (!currentData?.value?.id) {
      addDataFlag.value = true;
    }
    createRef.value.confirmSave(() => {
      processFlag.value = 0;
      currentData.value = undefined;
      refreshTable();
    });
  }
};
//返回
const back = () => {
  processFlag.value = 0;
  currentData.value = undefined;
  refreshTable();
};
//左侧园区树列表 过滤
const parkFilter = (text: string) => {
  treeData.value[0].children = rawParkData.value.filter((node: any) =>
    node.name.includes(text)
  );
  parkCurrentNodeKey.value = treeData?.value[0]?.children[0]?.id ?? 0;
  refreshTable();
};

//左侧园区树列表 选中节点变化触发
const changeNode = (data: any) => {
  if (data.id === virtualRootId) {
    if (data.children.length > 0) {
      parkCurrentNodeKey.value = data?.children[0]?.id;
      treeRef.value.setCurrentKey(parkCurrentNodeKey.value);
    } else {
      parkCurrentNodeKey.value = virtualRootId;
      return;
    }
  } else {
    parkCurrentNodeKey.value = data.id;
  }
  refreshTable();
};

//表格编辑事件
const editEvent = (scope: any) => {
  currentData.value = scope.row;
  processFlag.value = 2;
  hiddenSave.value = false;
};
// 表格删除事件
const deleteEvent = (scope: any) => {
  const params = {
    id: scope.row.id,
  };
  ElMessageBox.confirm(
    i18nM("space.modal.confirmDeleteBuilding"),
    i18nM("space.modal.deleteBuilding"),
    {
      confirmButtonText: i18nM("space.button.delete"),
      confirmButtonClass: "w-80",
      cancelButtonText: i18nM("space.button.cancel"),
      cancelButtonClass: "message-box-cancel-btn w-80",
      type: "warning",
    }
  )
    .then(() => {
      deleteBuilding(params, (res: any) => {
        if (res.code) {
          ElMessage({
            type: "success",
            message: i18nM("space.message.deleteSuccess"),
          });
          refreshTable();
        } else {
          ElMessage({
            type: "info",
            message: i18nM("space.message.deleteFailed"),
          });
        }
      });
    })
    .catch(() => {
      ElMessage({
        type: "info",
        message: i18nM("space.message.cancelDelete"),
      });
    });
};

//分页
const pageSize = ref(0);
const currentPage = ref(0);
const totalItems = ref(0);
const pageChange = (page: any) => {
  currentPage.value = page - 1;
  refreshTable();
};
//刷新右侧建筑表格
const refreshTable = () => {
  const params: getBuildingListParams = {
    projectId: projectId.value as unknown as number,
    parkId: Number(parkCurrentNodeKey.value),
    page: currentPage.value,
    size: pageSize.value,
  };
  if (!parkCurrentNodeKey.value) return;
  const parks = window.$HyGlobal.getCurrentProject()?.projects?.[0]?.parks;
  const buildingIds: number[] = [];
  if (parks && parks.length > 0) {
    parks.map((park: any) => {
      park.buildings.map((building: any) => {
        buildingIds.push(building.buildingId);
      });
    });
  }
  if (buildingIds.length > 0) params.buildingIds = JSON.stringify(buildingIds);
  getBuildingPage(params, (res: any) => {
    const { content, totalElements } = res.data;
    totalItems.value = totalElements;
    tableData.value = content.map((item: any, i: number) => {
      return {
        ...item,
        index: currentPage.value * pageSize.value + i + 1,
      };
    });
  });
};

//重新计算表格每页条数
const changeRightTable = () => {
  if (tableRef.value) {
    getPageSizeCount(
      tableRef.value,
      (count: number) => {
        pageSize.value = count;
        if (addDataFlag.value) {
          const pageCount = getPageCount(totalItems.value + 1, pageSize.value);
          currentPage.value = pageCount;
          addDataFlag.value = false;
        } else {
          const pageCount = getPageCount(totalItems.value, pageSize.value);
          if (currentPage.value > pageCount) currentPage.value = pageCount;
        }
        refreshTable();
      },
      { header: 62 }
    );
  }
};

//刷新左侧园区树
const refreshTree = () => {
  const params = {
    projectId: projectId.value,
    page: 0,
    size: 10000,
  };
  getParkGetByProjectId(params, (res: any) => {
    const { content, totalElements } = res.data;
    totalItems.value = totalElements;
    rawParkData.value = content.map((node: any, index: number) => {
      const { id, name } = node;
      if (index == 0) parkCurrentNodeKey.value = id;
      return { id, name };
    });
    treeData.value[0].children = rawParkData.value;
    if (parkCurrentNodeKey.value) {
      changeRightTable();
    }
  });
};
const queryProject = (projects: any[] = [], cb?: Function) => {
  const ids = projects.map((project: any) => project.projectId) ?? [];
  getNameMapByIds(ids, (res: any) => {
    const { data } = res;
    projectOptions.value = projects.map((project: any, i: number) => {
      const { projectId: id } = project;
      if (i === 0) projectId.value = id;
      const result = {
        id,
        name: data[id],
      };
      return result;
    });
    cb && cb();
  });
};
onMounted(() => {
  const project = window.$HyGlobal.getCurrentProject();
  if (project?.projects?.length) {
    queryProject(project.projects, () => {
      refreshTree();
    });
  } else {
    ElMessage({
      type: "error",
      message: i18nM("space.error.noProjectInfo"),
    });
    projectId.value = "";
  }
});
</script>
<style lang="scss" scoped>
@use "@static/css/common/size.scss" as *;
@use "@static/css/theme/update-element.scss" as *;
.zc-content {
  height: calc(100% - zrem(66));
}
.building-wrap {
  height: 100%;

  .version {
    display: flex;
    font-size: zrem(14);
    height: 91%;

    .left {
      width: 20%;
      border: zrem(1) solid var(--el-border-color);

      .depart-left-con {
        height: 100%;

        .depart-left-item {
          height: 50%;
          min-height: 50%;
        }
      }
    }

    .right {
      width: calc(80% - zrem(40));
      height: 100%;

      .table-right {
        height: 100%;
        display: flex;
        flex-direction: column;
        margin-left: zrem(20);

        .zc-base {
          border: zrem(1) solid var(--el-border-color);
          max-height: calc(100% - zrem(52));
          height: calc(100% - zrem(52));
        }

        .zc-footer {
          margin: zrem(10) 0;
        }
      }

      .new-create {
        height: 100%;
        display: flex;
        flex-direction: column;
        margin-left: zrem(20);
      }
    }

    .dp-users {
      flex: 1;
    }
  }
}
</style>
