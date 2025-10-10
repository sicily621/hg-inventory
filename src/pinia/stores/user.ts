import { getRoleListByIds } from "@/pages/employeeManagement/api/role";
import {
  setToken as _setToken,
  getToken,
  removeToken,
  setUserInfo,
  getUserInfo,
  removeUserInfo,
  removePermission,
} from "@@/utils/cache/cookies";
import { pinia } from "@/pinia";
import { resetRouter } from "@/router";
import { routerConfig } from "@/router/config";
import { useSettingsStore } from "./settings";
import { useTagsViewStore } from "./tags-view";

export const useUserStore: any = defineStore("user", () => {
  const token = ref<string>(getToken() || "");
  interface userInfo {
    id: string;
    username: string;
    roleId: string;
    departmentId: string;
  }
  const cacheUserInfo = getUserInfo()
    ? JSON.parse(getUserInfo() || "{}")
    : null;
  const defaultUserInfo = {
    id: "",
    username: "",
    roleId: "",
    departmentId: "",
    avatar:""
  };
  const userInfo = ref<userInfo>(cacheUserInfo || defaultUserInfo);

  const roles = ref<any[]>([]);

  const username = ref<string>("");

  const tagsViewStore = useTagsViewStore();

  const settingsStore = useSettingsStore();

  // 设置 Token
  const setToken = (value: string, time: number) => {
    _setToken(value, time);
    token.value = value;
  };
  const setInfo = (value: userInfo, time: number) => {
    setUserInfo(JSON.stringify(value), time);
    userInfo.value = value;
    username.value = value.username;
  };

  // 获取用户详情
  const getInfo = () => {
    return userInfo.value;
  };

  const getRole = async () => {
    let res;
    if (userInfo.value?.roleId) {
      res = await getRoleListByIds(userInfo.value.roleId);
    }

    // 验证返回的 roles 是否为一个非空数组，否则塞入一个没有任何作用的默认角色，防止路由守卫逻辑进入无限循环
    roles.value = (res as any)?.data ?? routerConfig.defaultRoles;
  };

  // 模拟角色变化
  const changeRoles = (role: string) => {
    const newToken = `token-${role}`;
    token.value = newToken;
    //_setToken(newToken);
    // 用刷新页面代替重新登录
    location.reload();
  };

  // 登出
  const logout = () => {
    removeToken();
    removeUserInfo();
    removePermission();
    token.value = "";
    roles.value = [];
    resetRouter();
    resetTagsView();
  };

  // 重置 Token
  const resetToken = () => {
    removeToken();
    token.value = "";
    roles.value = [];
  };

  // 重置 Visited Views 和 Cached Views
  const resetTagsView = () => {
    if (!settingsStore.cacheTagsView) {
      tagsViewStore.delAllVisitedViews();
      tagsViewStore.delAllCachedViews();
    }
  };

  return {
    token,
    roles,
    username,
    setToken,
    setInfo,
    getInfo,
    getRole,
    changeRoles,
    logout,
    resetToken,
  };
});

/**
 * @description 在 SPA 应用中可用于在 pinia 实例被激活前使用 store
 * @description 在 SSR 应用中可用于在 setup 外使用 store
 */
export function useUserStoreOutside() {
  return useUserStore(pinia);
}
