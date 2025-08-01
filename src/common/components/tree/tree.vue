<!-- {{ $t('elementUI.tree.title') }} -->
<template>
  <div class="zc-tree-con">
    <div class="disabled-con" v-if="disabledFlag"></div>
    <div class="zc-tree-input-icon-con">
      <div class="zc-tree-input-con" v-if="!hiddenSearchFlag">
        <el-input v-model="filterText" :placeholder="placeholder">
          <template #append>
            <el-button :icon="Search" />
          </template>
        </el-input>
      </div>
      <el-icon class="fz16 pointer m-l-10" v-if="addIconFlag" @click="treeAdd">
        <DocumentAdd />
      </el-icon>
      <el-icon class="fz16 m-l-10 pointer" v-if="editIconFlag" @click="treeEdit">
        <Edit />
      </el-icon>
      <el-icon class="fz16 m-l-10 pointer" v-if="deleteIconFlag" @click="treeDelete">
        <Delete />
      </el-icon>
    </div>
    <div class="zc-tree-content">
      <el-scrollbar ref="treeScrollbar" style="width: 100%; height: 100%;padding-right: 10px;" @scroll="scrollFunc($event)">
        <el-tree
          class="zc-tree"
          :node-key="nodeKey || 'id'"
          ref="treeRef"
          :data="data"
          :show-checkbox="checkBoxFlag"
          @node-click="handleNodeClick"
          @check-change="handleCheckChange"
          @check="handleCheck"
          :default-expanded-keys="expandedKeys"
          :default-checked-keys="checkedKeys"
          :currentNodeKey="currentNodeKey"
          :default-expand-all="true"
          :filter-node-method="searchFlag ? filterNode : () => {}"
          :draggable="draggableFlag"
          :allow-drop="allowDrop"
          :allow-drag="allowDrag"
          @node-drop="nodeDrop"
          :props="propsObj"
          :style="style"
          :expand-on-click-node="true"
          :check-strictly="checkStrictly"
        >
        <!--  :accordion="accordion" -->
          <template v-if="slotFlag" #default="{ node, data }">
            <div class="custom-tree-node">
              <div v-if="node.label.length<=numLen" class="overflow-spot">{{ node.label }}</div>
              <div v-else>
                <el-tooltip
                    class="box-item"
                    effect="light"
                    :content="data.label"
                    placement="top"><span>{{ellipsis(node.label,numLen)}}</span>
                </el-tooltip>
              </div>
              <div class="overflow-spot">
                <slot :data="data" :node="node"></slot>
              </div>
            </div>
          </template>
        </el-tree>
      </el-scrollbar>
    </div>
  </div>
</template>

<script setup lang="ts">
import { NodeDropType } from "element-plus/es/components/tree/src/tree.type";
import { ref, watch } from "vue";
import { Search } from "@element-plus/icons-vue";

const numLen = 12; //限制字符长度
/** * 省略多余字符，用...显示 * @param {String} value * @param {number} len */
const ellipsis = (value: string, len: number) =>{
  if (!value) return ''
  if (value.length > len) {
    return value.slice(0, len) + '...'
  }
  return value
}
export interface TreeNode {
  id: number;
  label: string;
  [propname: string]: any; //与组件样式无关的数据 但业务逻辑会用到
  children?: TreeNode[];
}

// 定义 props 类型
interface TreeProps {
  data: TreeNode[];
  checkBoxFlag?: boolean; // 是否有单选框样式
  expandedKeys?: Array<number | string>; // 默认展开的节点
  checkedKeys?: Array<number | string>; // 有单选框时 默认选中的节点
  placeholder?: string;
  currentNodeKey?: number | string; // 当前选中节点
  searchFlag?: boolean;
  hiddenSearchFlag?: boolean;
  slotFlag?: boolean;
  defaultExpandAllFlag?: boolean;
  draggableFlag?: boolean;
  allowDrop?: Function;
  allowDrag?: Function;
  disabledFlag?: boolean; // 禁用全部
  propsObj?: any;
  nodeKey?: string;
  style?: any;
  accordion?: boolean;
  addIconFlag?: boolean;
  editIconFlag?: boolean;
  deleteIconFlag?: boolean;
  checkStrictly?: boolean;
}

const props = defineProps<TreeProps>();

const emits = defineEmits([
  "changeNode", "changeFilter", "scrollPage", "checkChange", "check", "nodeDrop", "setCurrentKey",
  "treeAdd", "treeEdit", "treeDelete"
]);
const filterText = ref("");
const treeRef = ref(); //当前dom元素
const currentNode = ref(); //当前选中的节点
const treeScrollbar = ref();
let timer: any = null;
watch(filterText, (val) => {
  clearTimeout(timer);
  timer = setTimeout(() => {
    emits("changeFilter", val);
    if (props.searchFlag) {
      treeRef.value.filter(val);
    }
  }, 500);
});
const filterNode = (value: string, data: any) => {
  const code = props?.propsObj?.label || "label";
  if (!value) return true;
  return data[code].includes(value);
};

const scrollFunc = (e: any) => {
  const scrollHeight: number = treeScrollbar.value.wrapRef.scrollHeight;
  const scrollTop: number = e.scrollTop;
  const clientHeight: number = treeScrollbar.value.wrapRef.clientHeight;
  if (clientHeight + scrollTop >= scrollHeight) {
    emits("scrollPage");
  }
};

/**
 * 赋值当前选中的节点
 * 通知父组件选中节点更换
 * @param data
 */
const handleNodeClick = (data: any) => {
  currentNode.value = data;
  emits("changeNode", data);
};

const handleCheckChange = (data: any, checked: boolean, indeterminate: boolean) => {
  emits("checkChange", { data, checked, indeterminate });
};

const handleCheck = (data: any, data2: any) => {
  emits("check", data, data2);
};

/**
 * 查找data内id节点
 * @param data
 * @param id
 */
const findNode = (data: any, id: any) => {
  if (data.id === id) return data;
  for (const child of data.children) {
    const found: any = findNode(child, id);
    if (found) return found;
  }
};

/**
 * 深层更改tree
 */
const updateChildrenData = (data: any, id: any, newData: any) => {
  if (data.id === id) return (data.children = newData);
  for (let i = 0; i < data.children.lengt; i++) {
    updateChildrenData(data.children[i], id, newData);
  }
};

/**
 * 获取选择框已选中的节点数组
 */
const getCheckedNodes = () => treeRef.value!.getCheckedNodes(false, true);

/**
 * 获取选择框选中的节点id数组
 */

const getCheckedKeys = () => treeRef.value!.getCheckedKeys(false);

/**
 * 获取当前选中的节点
 */
const getCurrentNode = () => treeRef.value!.getCurrentNode();

/**
 * 根据id获取node
 */
const getNode = (id: number) => treeRef.value!.getNode(id);

/**
 * 设置选中节点
 */
const setCheckedNodes = (arr: any[]) => treeRef.value!.setCheckedNodes(arr);

/**
 * 根据id设置选中节点
 */
const setCheckedKeys = (arr: Array<string | number>) => treeRef.value!.setCheckedKeys(arr);

/**
 * 根据id设置当前节点
 */
const setCurrentKey = (id: number) => treeRef.value!.setCurrentKey(id);


const append = (data: any, parentData: any) => treeRef.value!.append(data, parentData);

/**
 * 拖拽成功事件
 */
const nodeDrop = (draggingNode: Node, dropNode: Node, dropType: NodeDropType, ev: any) => {
  emits("nodeDrop", {
    draggingNode,
    dropNode,
    dropType,
    ev,
  });
};

/**
 * 删除节点
 */
const remove = (id: number) => treeRef.value!.remove(id);

const treeAdd = () => emits("treeAdd");

const treeEdit = () => emits("treeEdit");

const treeDelete = () => emits("treeDelete");

/**
 * 导出父组件用到的方法和变量
 */
defineExpose({
  currentNode,
  getCheckedNodes,
  getCurrentNode,
  findNode,
  getNode,
  setCheckedNodes,
  getCheckedKeys,
  setCheckedKeys,
  setCurrentKey,
  remove,
  append
});
</script>
<style scoped lang="scss">
@use "@static/css/common/size.scss" as *;
.zc-tree-con {
  width: 100%;
  height: 100%;
  position: relative;
  .disabled-con {
    width: 100%;
    height: 100%;
    position: absolute;
    left: 0;
    top: 0;
    background: none;
    opacity: 0;
    z-index: 2;
  }
  .zc-tree-input-icon-con {
    width: 100%;
    display: flex;
    align-items: center;
    margin-bottom: zrem(14);
    .zc-tree-input-con {
      flex: 1;
      height: zrem(32);
    }
  }
  .zc-tree-content {
    width: 100%;
    height: calc(100% - zrem(46));
  }
  .custom-tree-node {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: zrem(14);
    padding-right: zrem(8);
    overflow: hidden !important;
    text-overflow: ellipsis !important;
    white-space: nowrap !important;
  }
}
// .zc-tree {
//   width: 400px !important;
// }
</style>
