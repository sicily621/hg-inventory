// 统一处理 Cookie

import { CacheKey } from "@@/constants/cache-key";
import Cookies from "js-cookie";

export function getToken() {
  return Cookies.get(CacheKey.TOKEN);
}

export function setToken(token: string) {
  Cookies.set(CacheKey.TOKEN, token);
}

export function removeToken() {
  Cookies.remove(CacheKey.TOKEN);
}

export function getUserInfo() {
  return Cookies.get(CacheKey.USER_INFO);
}

export function setUserInfo(userInfo: any) {
  Cookies.set(CacheKey.USER_INFO, userInfo);
}

export function removeUserInfo() {
  Cookies.remove(CacheKey.USER_INFO);
}

export function getPermission() {
  return Cookies.get(CacheKey.PERMISSION);
}

export function setPermission(permisson: any) {
  Cookies.set(CacheKey.PERMISSION, permisson);
}

export function removePermission() {
  Cookies.remove(CacheKey.PERMISSION);
}
