<template>
  <div class="app-container flex flex-col h-full p-4">
    <div class="flex-1 el-card p-4 m-b-2">
      <Line
        title="今年销售趋势"
        :x-axis-data="xAxisData"
        :series-data="yearData"
        :animation="true"
        :show-area="true"
        unit="元"
        @click="handleChartClick"
      />
    </div>
    <div class="flex-1 el-card p-4 m-b-2">
      <Line
        title="本月销售趋势"
        :x-axis-data="monthXAxisData"
        :series-data="monthData"
        :animation="true"
        :show-area="true"
        unit="元"
        @click="handleChartClick"
      />
    </div>
    <div class="flex-1 el-card p-4">
      <Bar
        title="今年销售对比"
        :x-axis-data="xAxisData"
        :series-data="seriesData"
        :animation="true"
        :is-stacked="false"
        :show-label="true"
        unit="元"
        @click="handleChartClick"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import Line from "@@/components/echarts/line.vue";
import Bar from "@@/components/echarts/bar.vue";
import { getListSalesStatisticsByTimeType } from "../api/account";
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
const date = new Date();
const month = date.getMonth();
date.setMonth(month + 1);
date.setDate(0);
const dayOfMonth = date.getDate();
const monthXAxisData = [];
for (let i = 1; i <= dayOfMonth; i++) {
  monthXAxisData.push(i + "日");
}
const seriesData = ref([
  {
    name: "销售额",
    data: [0],
  },
  {
    name: "利润",
    data: [0],
  },
]);
const yearData = ref([
  {
    name: "销售额",
    data: [0],
  },
  {
    name: "利润",
    data: [0],
  },
  {
    name: "成本",
    data: [0],
  },
]);
const monthData = ref([
  {
    name: "销售额",
    data: [0],
  },
  {
    name: "利润",
    data: [0],
  },
  {
    name: "成本",
    data: [0],
  },
]);
onMounted(async () => {
  const year = new Date().getFullYear();
  const res: any = await getListSalesStatisticsByTimeType({
    timeType: 2,
    startTime: `${year}-01-01`,
  });
  yearData.value[0].data = [];
  yearData.value[1].data = [];
  yearData.value[2].data = [];
  seriesData.value[0].data = [];
  seriesData.value[1].data = [];
  res.data.map((item: any) => {
    const { amount, profit, cost } = item;
    yearData.value[0].data.push(Number(amount));
    yearData.value[1].data.push(Number(profit));
    yearData.value[2].data.push(Number(cost));
    seriesData.value[0].data.push(Number(amount));
    seriesData.value[1].data.push(Number(profit));
  });
  monthData.value[0].data = [];
  monthData.value[1].data = [];
  monthData.value[2].data = [];
  const monthRes: any = await getListSalesStatisticsByTimeType({
    timeType: 1,
    startTime: `${year}-${month + 1}-01`,
  });
  monthRes.data.map((item: any) => {
    const { amount, profit, cost } = item;
    monthData.value[0].data.push(Number(amount));
    monthData.value[1].data.push(Number(profit));
    monthData.value[2].data.push(Number(cost));
  });
});
const handleChartClick = (params: any) => {
  console.log("点击了图表:", params);
};
</script>
