<template>
  <div
    v-if="svgContent"
    v-html="svgContent"
    class="icon-container"
    :class="{ needUpdateColor: needUpdateColor }"
    :style="{
      width: zrem(width),
      height: zrem(height),
    }"
  ></div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import axios from "axios";
import { zrem } from "../../js/theme/zrem";

const props = defineProps({
  src: {
    type: String,
    required: true,
  },
  width: {
    type: Number,
    default: 20,
  },
  height: {
    type: Number,
    default: 20,
  },
  color: {
    type: String,
    default: "var(--el-text-color-primary)",
  },
  needUpdateColor: {
    type: Boolean,
    default: true,
  },
});

const svgContent = ref("");

onMounted(async () => {
  try {
    const response = await axios.get(props.src, {
      responseType: "text",
    });
    const parser = new DOMParser();
    const doc = parser.parseFromString(response.data, "image/svg+xml");
    const svgElement = doc.querySelector("svg");
    if (svgElement) {
      svgElement.removeAttribute("width");
      svgElement.removeAttribute("height");
      svgContent.value = svgElement.outerHTML;
    } else {
      svgContent.value = response.data;
    }
  } catch (error) {
    console.error("Error loading SVG:", error);
  }
});
</script>

<style lang="scss">
@use "@static/css/common/size.scss" as *;
.icon-container {
  display: inline-block;
  &.needUpdateColor {
    svg path {
      fill: v-bind(color);
    }
  }
}
</style>
