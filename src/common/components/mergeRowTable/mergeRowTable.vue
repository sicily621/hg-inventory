<template>
  <div class="relative h-full">
    <el-table
      class="zc-table h-full relative merge-table"
      highlight-current-row
      stripe
      v-bind="props.tableProps"
      :data="props.tableData"
      :header-row-style="{ height: '55px' }"
      :row-style="{ height: rowHeight ? `${rowHeight}px` : '46px' }"
      @select="select"
      @selectAll="selectAll"
      @current-change="currentChange"
      @selection-change="selectChange"
      @row-click="rowClick"
      @cell-mouse-enter="handleRowMouseEnter"
      @cell-mouse-leave="handleRowMouseLeave"
      ref="baseTableRef"
      empty-text="&nbsp"
      table-layout="auto"
      :height="props.height"
      :header-cell-style="headerCellStyle"
      :span-method="arraySpanMethod"
      :row-class-name="tableRowClassName"
    >
      <el-table-column
        v-if="
          checkboxFlag && (checkboxPosition === 'left' || !checkboxPosition)
        "
        type="selection"
        width="55"
        class-name="checkbox-column"
      />

      <template v-for="col in props.columns" :key="col.prop">
        <el-table-column
          v-if="col.type === 1"
          :label="col.label"
          width="80"
          type="index"
        >
          <template #default="scope">{{
            scope.row?.["index"] ?? "-"
          }}</template>
        </el-table-column>

        <el-table-column v-if="!col.type" :label="col.label" :width="col.width">
          <template #default="scope">
            <slot :scope="scope" :name="col.prop">
              <div
                class="text-overflow"
                :style="{ width: `${col.width}px`, maxWidth: `${col.width}px` }"
              >
                {{ scope.row[col.prop] ?? "-" }}
              </div>
            </slot>
          </template>
        </el-table-column>

        <el-table-column
          v-if="col.type === 2 && (col?.width ?? true)"
          :label="col.label"
          :width="col.width"
        >
          <template #default="scope">
            <slot :scope="scope" :name="col.prop">
              <el-tooltip
                v-if="(scope.row[col.prop]?.length ?? 0) * 14 > col.width"
                :content="scope.row[col.prop]"
                placement="top"
              >
                <div
                  class="text-overflow"
                  :style="{
                    width: `${col.width}px`,
                    maxWidth: `${col.width}px`,
                  }"
                >
                  {{ scope.row[col.prop] }}
                </div>
              </el-tooltip>
              <div
                v-else
                class="text-overflow"
                :style="{ width: `${col.width}px`, maxWidth: `${col.width}px` }"
              >
                {{ scope.row[col.prop] }}
              </div>
            </slot>
          </template>
          <template #header>
            <slot :scope="col" :name="`${col.prop}Header`">{{
              col.label
            }}</slot>
          </template>
        </el-table-column>
        <el-table-column
          v-if="col.type === 3"
          :render-header="(data) => renderHeaderCheckbox(data, col)"
          :width="col.width"
        >
          <template #default="scope">
            <slot :scope="scope" :name="col.prop">{{
              scope.row[col.prop]
            }}</slot>
          </template>
        </el-table-column>
        <el-table-column
          v-if="col.type === 4"
          :label="col.label"
          :width="col.width"
        >
          <template #default="scope">
            <slot :scope="scope" :name="col.prop">{{
              scope.row[col.prop] ?? "-"
            }}</slot>
          </template>
          <template #header>
            <span>{{ col.label }}</span>
            <el-icon class="pointer m-r-10 editIcon">
              <Edit v-if="col.icon === 'edit'" />
              <Delete v-if="col.icon === 'delete'" />
              <Search v-if="col.icon === 'search'" />
              <Share v-if="col.icon === 'share'" />
              <Loading v-if="col.icon === 'loading'" />
            </el-icon>
          </template>
        </el-table-column>
        <el-table-column
          v-if="col.type === 5"
          :label="col.label"
          fixed
          :prop="col.prop"
          :width="col.width"
        >
          <template #default="scope">
            <slot :scope="scope" :name="col.prop">{{
              scope.row[col.prop] ?? "-"
            }}</slot>
          </template>
        </el-table-column>
        <el-table-column
          v-if="col.type === 6"
          :label="col.label"
          :prop="col.prop"
        ></el-table-column>

        <!-- {{ $t('table.mergeRowTable.showImage') }} -->
        <el-table-column
          v-if="col.type === 7"
          :label="col.label"
          :prop="col.prop"
        >
          <template #default="scope">
            <slot :scope="scope" :name="col.prop">
              <el-image
                :preview-teleported="true"
                style="width: 50px; height: 50px"
                :src="scope.row[col.prop]"
                :preview-src-list="[scope.row[col.prop]]"
                title="点击放大"
              />
            </slot>
          </template>
        </el-table-column>

        <el-table-column
          v-if="col.type === 8"
          :render-header="(data) => renderHeaderIconEdit(data, col)"
          :width="col.width"
        >
          <template #default="scope">
            <slot :scope="scope" :name="col.prop">{{
              scope.row[col.prop]
            }}</slot>
          </template>
        </el-table-column>
      </template>
      <el-table-column
        v-if="checkboxFlag && checkboxPosition === 'right'"
        type="selection"
        width="55"
        class-name="checkbox-column"
      />
    </el-table>
    <div
      class="empty-img absolute flex-column flex-center"
      v-if="!props.tableData?.length"
    >
      <div class="m-t-10">暂无数据</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, h, watch } from "vue";
import { ElCheckbox, CheckboxValueType, ElIcon } from "element-plus";
import { Edit } from "@element-plus/icons-vue";
interface Props {
  tableProps?: any;
  columns: any[];
  tableData: any[];
  checkboxFlag?: boolean;
  checkboxPosition?: string;
  type?: 0 | 1; //0后台传的数据 1
  indexMethod?: Function;
  rowHeight?: number;
  hideTableEmptyImg?: boolean;
  height?: string;
  fixedColumnMore?: boolean;
  spanMethod?: (data: {
    row: any;
    column: any;
    rowIndex: number;
    columnIndex: number;
  }) => number[] | { rowspan: number; colspan: number };
}
const baseTableRef = ref();
const props = defineProps<Props>();
const emits = defineEmits([
  "select",
  "selectAll",
  "currentChange",
  "selectChange",
  "rowClick",
  "customSelectAll",
]);
const selectedRealRowIndex = ref(-1);
const select = (selection: any, row: any) => emits("select", selection, row);
const selectAll = (selection: any) => emits("selectAll", selection);
const toggleRowSelection = (row: any, selected?: any) =>
  baseTableRef.value.toggleRowSelection(row, selected);
const sort = (sortObj: any) => baseTableRef.value.sort(sortObj);
const currentChange = (row: any) => emits("currentChange", row);
const selectChange = (selection: any) => emits("selectChange", selection);
const rowClick = (row: any, e: any) => {
  const realIndex = row.index || 0;
  if (realIndex === selectedRealRowIndex.value) {
    selectedRealRowIndex.value = -1;
  } else {
    selectedRealRowIndex.value = realIndex;
  }
  baseTableRef.value!.setCurrentRow();
  emits("rowClick", row, e);
};

const setCurrentRow = (row: any) => baseTableRef.value.setCurrentRow(row);
const indexMethod = (index: number) => props.indexMethod?.(index) ?? index + 1;
const renderHeaderCheckbox = (data: any, col: any) => {
  if (isCheckedObj.value[col.prop] == undefined)
    isCheckedObj.value[col.prop] = false;
  return h("div", {}, [
    h(ElCheckbox, {
      modelValue: isCheckedObj.value[col.prop],
      "onUpdate:modelValue": (e: CheckboxValueType) => {
        isCheckedObj.value[col.prop] = e as boolean;
        emits("customSelectAll", { col, checkbox: e as boolean });
      },
      label: col.label,
    }),
  ]);
};
const renderHeaderIconEdit = (data: any, col: any) => {
  return h(
    "div",
    {
      style: {
        display: "flex",
        alignItems: "center",
      },
    },
    [
      h("span", {}, col.label),
      h(
        ElIcon,
        {
          style: {
            fontSize: "18px",
            marginLeft: "2px",
          },
        },
        [h(Edit, {})],
      ),
    ],
  );
};
const isCheckedObj = ref<any>({});
const setIsCheckedObj = (key: string, checkbox: boolean) => {
  isCheckedObj.value[key] = checkbox;
};
const arraySpanMethod = ({
  row,
  column,
  rowIndex,
  columnIndex,
}: {
  row: any;
  column: any;
  rowIndex: number;
  columnIndex: number;
}): { rowspan: number; colspan: number } | number[] => {
  if (props.spanMethod) {
    return props.spanMethod({ row, column, rowIndex, columnIndex });
  }

  return [1, 1];
};
const tableRowClassName = ({ row }: { row: any }) => {
  const classes = [row.index % 2 ? "odd" : "even"];
  // 添加鼠标悬停类
  if (row.index === hoverRealRowIndex.value) {
    classes.push("hover");
  }
  // 添加选中类
  if (row.index === selectedRealRowIndex.value) {
    classes.push("selected-row");
  }
  return classes;
};

// 当前鼠标悬停的真实行号
const hoverRealRowIndex = ref(-1);
// 鼠标进入行
const handleRowMouseEnter = (row: any) => {
  hoverRealRowIndex.value = row.index;
};

// 鼠标离开行
const handleRowMouseLeave = () => {
  hoverRealRowIndex.value = -1;
};

const headerCellStyle = ({ column }: { column: any }) => {
  if (column.property === "searchDate") {
    return { "background-color": "var(--el-table-header-bg-color)" };
  }
};
defineExpose({
  toggleRowSelection,
  sort,
  setCurrentRow,
  setIsCheckedObj,
});
</script>
<style scoped lang="scss">
@use "@@/assets/styles/size.scss" as *;
.text-overflow {
  text-overflow: ellipsis;
  overflow: hidden;
  white-space: nowrap;
  padding-right: 20px;
}
.empty-img {
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  color: var(--el-text-color-placeholder);
}
.operator-column {
  width: auto;
}
.editIcon {
  margin-left: zrem(5);
  vertical-align: middle;
  width: zrem(16);
  height: zrem(16);
}
</style>
