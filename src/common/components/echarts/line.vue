<template>
  <div class="line-chart-wrapper" :style="{ height: height }">
    <div ref="chartRef" class="chart-container"></div>
  </div>
</template>

<script setup lang="ts">
import {
  ref,
  onMounted,
  onUnmounted,
  watch,
  defineProps,
  defineEmits,
} from "vue";
import * as echarts from "echarts";
import type { ECharts, EChartsOption } from "echarts";
import { hexToRgb } from "@@/utils/color";

// 定义组件属性
const props = defineProps({
  // 图表高度
  height: {
    type: String,
    default: "100%",
  },
  // 图表标题
  title: {
    type: String,
    default: "数据趋势图",
  },
  // x轴数据
  xAxisData: {
    type: Array as () => string[],
    required: true,
  },
  // 系列数据
  seriesData: {
    type: Array as () => Array<{
      name: string;
      data: number[];
      color?: string;
    }>,
    required: true,
  },
  // 是否开启动画
  animation: {
    type: Boolean,
    default: true,
  },
  // 是否显示区域填充
  showArea: {
    type: Boolean,
    default: false,
  },
  unit: {
    type: String,
    default: "",
  },
});

// 定义组件事件
const emit = defineEmits<{
  // 点击图表时触发
  (e: "click", params: any): void;
  // 图表初始化完成时触发
  (e: "init", instance: ECharts): void;
}>();

// 图表容器的引用
const chartRef = ref<HTMLDivElement | null>(null);
// ECharts实例
let chartInstance: ECharts | null = null;

// 初始化图表
const initChart = () => {
  if (!chartRef.value) return;

  // 销毁已存在的实例
  if (chartInstance) {
    chartInstance.dispose();
  }

  // 创建新实例
  chartInstance = echarts.init(chartRef.value);

  // 触发初始化完成事件
  emit("init", chartInstance);

  // 设置图表配置
  const option = getChartOption();
  chartInstance.setOption(option);

  // 绑定点击事件
  chartInstance.on("click", (params) => {
    emit("click", params);
  });

  // 监听窗口大小变化，自动调整图表大小
  const handleResize = () => {
    chartInstance?.resize();
  };

  window.addEventListener("resize", handleResize);

  // 组件卸载时移除事件监听
  onUnmounted(() => {
    window.removeEventListener("resize", handleResize);
  });
};

// 获取图表配置项
const getChartOption = (): any => {
  return {
    color: [
      "#3c52bf",
      "#fa8b16",
      "#4cc09e",
      "#ff4d4f",
      "#f6bb06",
      "#0271e3",
      "#957dc5",
      "#50c9d2",
      "#df58fd",
      "#37df48",
    ],
    // 图表标题
    title: {
      text: props.title,
      left: "center",
      top: 0,
      textStyle: {
        fontSize: 16,
      },
    },
    // 图例
    legend: {
      data: props.seriesData.map((item) => item.name),
      x: "right",
      y: "0%",
    },
    // 提示框
    tooltip: {
      trigger: "axis",
      backgroundColor: "rgba(255, 255, 255, 0.9)",
      borderColor: "#ddd",
      borderWidth: 1,
      textStyle: {
        color: "#333",
      },
      formatter: function (params: any) {
        let result = `${params[0].name}<br/>`;
        params.forEach((item: any) => {
          result += `${item.seriesName}: ${item.value}${props.unit}<br/>`;
        });
        return result;
      },
    },
    // 网格配置
    grid: {
      left: "0.5%",
      right: "2%",
      top: "35",
      bottom: "0%",
      containLabel: true,
    },
    // x轴配置
    xAxis: {
      type: "category",
      boundaryGap: false,
      data: props.xAxisData,
      axisLine: {
        lineStyle: {
          color: "#ddd",
        },
      },
    },
    // y轴配置
    yAxis: {
      type: "value",
      axisLine: {
        show: false,
      },
      splitLine: {
        lineStyle: {
          color: "#f5f5f5",
        },
      },
    },
    // 动画配置
    animation: props.animation,
    animationDuration: 1500,
    animationEasing: "cubicOut",

    // 系列数据配置
    series: props.seriesData.map((series, index) => ({
      name: series.name,
      type: "line",
      data: series.data,
      smooth: true,
      // 线条样式
      lineStyle: {
        width: 3,
        color: series.color, // 支持自定义线条颜色
      },
      // 区域填充
      areaStyle: props.showArea
        ? {
            opacity: 0.13,
            color: series.color
              ? {
                  type: "linear",
                  x: 0,
                  y: 0,
                  x2: 0,
                  y2: 1,
                  colorStops: [
                    {
                      offset: 0,
                      color: series.color,
                    },
                    {
                      offset: 1,
                      color: series.color + "00", // 透明度降低
                    },
                  ],
                }
              : undefined,
          }
        : undefined,
      // 标记点
      symbol: "circle",
      symbolSize: 6,
      // 高亮状态
      emphasis: {
        scale: true,
        symbolSize: 8,
        itemStyle: {
          shadowBlur: 10,
          shadowColor: "rgba(0, 0, 0, 0.3)",
        },
      },
    })),
  };
};

// 监听属性变化，更新图表
watch(
  () => [
    props.xAxisData,
    props.seriesData,
    props.title,
    props.animation,
    props.showArea,
  ],
  () => {
    if (chartInstance) {
      chartInstance.setOption(getChartOption());
    }
  },
  { deep: true },
);

// 组件挂载时初始化图表
onMounted(() => {
  initChart();
});

// 组件卸载时销毁图表实例
onUnmounted(() => {
  if (chartInstance) {
    chartInstance.dispose();
    chartInstance = null;
  }
});
</script>

<style scoped>
.line-chart-wrapper {
  width: 100%;
}

.chart-container {
  width: 100%;
  height: 100%;
  border-radius: 4px;
}
</style>
