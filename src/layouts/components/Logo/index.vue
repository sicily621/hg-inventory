<script lang="ts" setup>
import logoText1 from "@@/assets/images/layouts/logo-text-1.png?url";
import logoText2 from "@@/assets/images/layouts/logo-text-2.png?url";
import logo from "@@/assets/images/layouts/logo.png?url";
import { useLayoutMode } from "@@/composables/useLayoutMode";

interface Props {
  collapse?: boolean;
}

const { collapse = true } = defineProps<Props>();

const { isLeft, isTop } = useLayoutMode();
</script>

<template>
  <div
    class="layout-logo-container"
    :class="{ collapse: collapse, 'layout-mode-top': isTop }"
  >
    <transition name="layout-logo-fade">
      <router-link v-if="collapse" key="collapse" to="/">
        <img :src="logo" class="layout-logo" />
      </router-link>
      <router-link v-else key="expand" to="/">
        <div class="flex flex-center">
          <img
            :src="!isLeft ? logoText2 : logoText1"
            class="layout-logo-text"
          />
          <span class="text m-l-3">慧谷进销存</span>
        </div>
      </router-link>
    </transition>
  </div>
</template>

<style lang="scss" scoped>
@use "@@/assets/styles/size.scss" as *;
.layout-logo-container {
  position: relative;
  width: 100%;
  height: var(--v3-header-height);
  line-height: var(--v3-header-height);
  text-align: center;
  overflow: hidden;
  .layout-logo {
    display: none;
  }
  .layout-logo-text {
    height: zrem(30);
    vertical-align: middle;
  }
  .text {
    color: #fff;
    font-size: zrem(16);
    font-weight: 600;
    background-clip: text;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-image: linear-gradient(to bottom, #fff, var(--el-color-primary));
  }
}

.layout-mode-top {
  height: var(--v3-navigationbar-height);
  line-height: var(--v3-navigationbar-height);
}

.collapse {
  .layout-logo {
    width: 32px;
    height: 32px;
    vertical-align: middle;
    display: inline-block;
  }
  .layout-logo-text {
    display: none;
  }
}
</style>
