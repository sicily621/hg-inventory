<template>
  <el-pagination
    background
    class="zc-pagination"
    :total="props.total"
    :page-size="props.pageSize"
    :pager-count="props.pagerCount"
    :current-page="currentPage"
    layout="total, prev, pager, next,jumper"
    @current-change="handleCurrentChange"
  />
</template>
<script setup lang="ts">
const props = defineProps({
  currentPage: {
    type: Number,
    default: 1,
  },
  pageSize: {
    type: Number,
    required: true,
  },
  total: {
    type: Number,
    required: true,
  },
  pagerCount: {
    type: Number,
    default: 11,
  },
});

let emits = defineEmits(["pageChange"]);

const handleCurrentChange = (val: number) => {
  emits("pageChange", val);
};
</script>
