import type { RouteRecordRaw } from "vue-router";
import { pinia } from "@/pinia";
import { constantRoutes, dynamicRoutes } from "@/router";
import { routerConfig } from "@/router/config";
import { flatMultiLevelRoutes } from "@/router/helper";
import {
  Permission,
  PermissionAction,
} from "@/pages/employeeManagement/api/permission";
import {
  setPermission,
  getPermission,
  getUserInfo,
} from "@@/utils/cache/cookies";

export const usePermissionStore = defineStore("permission", () => {
  const cachePermission = getPermission()
    ? JSON.parse(getPermission() || "")
    : null;
  const permissions = ref<Permission[]>(cachePermission ?? []);
  // 可访问的路由
  const routes = ref<RouteRecordRaw[]>([]);

  // 有访问权限的动态路由
  const addRoutes = ref<RouteRecordRaw[]>([]);

  function hasPermissionMenu(route: RouteRecordRaw) {
    const userInfo = getUserInfo() ? JSON.parse(getUserInfo() || "") : null;
    if (userInfo.username === "admin") {
      return true;
    } else {
      const moduleCode = route.meta?.moduleCode;
      const includes = permissions.value.find(
        (data: any) => data.moduleCode === moduleCode,
      );
      return includes ? true : false;
    }
  }
  const hasPermission = (moduleCode: string, action: PermissionAction) => {
    const includes = permissions.value.find(
      (data: any) => data.moduleCode === moduleCode && data.action === action,
    );
    return includes ? true : false;
  };

  function filterDynamicRoutes(routes: RouteRecordRaw[]) {
    const res: RouteRecordRaw[] = [];
    routes.forEach((route) => {
      const tempRoute = { ...route };
      if (hasPermissionMenu(tempRoute)) {
        if (tempRoute.children) {
          tempRoute.children = filterDynamicRoutes(tempRoute.children);
        }
        res.push(tempRoute);
      }
    });
    return res;
  }

  // 根据角色生成可访问的 Routes（可访问的路由 = 常驻路由 + 有访问权限的动态路由）
  const setRoutes = () => {
    const accessedRoutes = filterDynamicRoutes(dynamicRoutes);
    set(accessedRoutes);
  };

  // 所有路由 = 所有常驻路由 + 所有动态路由
  const setAllRoutes = () => {
    set(dynamicRoutes);
  };
  const setPermissions = (data: Permission[]) => {
    setPermission(JSON.stringify(data));
    permissions.value = data;
  };
  const getPermissions = () => {
    return permissions.value;
  };

  // 统一设置
  const set = (accessedRoutes: RouteRecordRaw[]) => {
    routes.value = constantRoutes.concat(accessedRoutes);
    addRoutes.value = routerConfig.thirdLevelRouteCache
      ? flatMultiLevelRoutes(accessedRoutes)
      : accessedRoutes;
  };

  return {
    routes,
    addRoutes,
    setRoutes,
    setAllRoutes,
    setPermissions,
    getPermissions,
    hasPermission,
  };
});

/**
 * @description 在 SPA 应用中可用于在 pinia 实例被激活前使用 store
 * @description 在 SSR 应用中可用于在 setup 外使用 store
 */
export function usePermissionStoreOutside() {
  return usePermissionStore(pinia);
}
