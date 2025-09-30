<template>
  <div class="app-container flex flex-col h-full p-4">
    <div class="flex-1 el-card p-4 m-b-2">
      <Line
        title="年度销售趋势"
        :x-axis-data="xAxisData"
        :series-data="seriesData"
        :animation="true"
        :show-area="false"
        @click="handleChartClick"
      />
    </div>
    <div class="flex-1 el-card p-4 m-b-2">
      <Line
        title="年度销售趋势"
        :x-axis-data="xAxisData"
        :series-data="seriesData"
        :animation="true"
        :show-area="false"
        @click="handleChartClick"
      />
    </div>
    <div class="flex-1 el-card p-4">
      <Bar
        title="各产品季度销量对比"
        :x-axis-data="xAxisData"
        :series-data="seriesData"
        :animation="true"
        :is-stacked="false"
        :show-label="true"
        @click="handleChartClick"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import Line from "@@/components/echarts/line.vue";
import Bar from "@@/components/echarts/bar.vue";
const xAxisData = [
  "1月",
  "2月",
  "3月",
  "4月",
  "5月",
  "6月",
  "7月",
  "8月",
  "9月",
  "10月",
  "11月",
  "12月",
];

const seriesData = [
  {
    name: "产品A",
    data: [120, 132, 101, 134, 90, 230, 210, 230, 190, 230, 210, 180],
    color: "#42b983",
  },
  {
    name: "产品B",
    data: [220, 182, 191, 234, 290, 330, 310, 330, 320, 330, 310, 340],
    color: "#3598db",
  },
];

const handleChartClick = (params: any) => {
  console.log("点击了图表:", params);
};
</script>
