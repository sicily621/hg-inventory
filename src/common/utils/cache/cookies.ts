// 统一处理 Cookie

import { CacheKey } from "@@/constants/cache-key";
import Cookies from "js-cookie";

export function getToken() {
  return Cookies.get(CacheKey.TOKEN);
}

export function setToken(token: string, value: number) {
  const expiresDate = new Date();
  expiresDate.setTime(expiresDate.getTime() + value * 1000);
  Cookies.set(CacheKey.TOKEN, token, { expires: expiresDate });
}

export function removeToken() {
  Cookies.remove(CacheKey.TOKEN);
}

export function getUserInfo() {
  return Cookies.get(CacheKey.USER_INFO);
}

export function setUserInfo(userInfo: any, value: number) {
  const expiresDate = new Date();
  expiresDate.setTime(expiresDate.getTime() + value * 1000);
  Cookies.set(CacheKey.USER_INFO, userInfo, { expires: expiresDate });
}

export function removeUserInfo() {
  Cookies.remove(CacheKey.USER_INFO);
}

export function getPermission() {
  return sessionStorage.getItem(CacheKey.PERMISSION);
}

export function setPermission(permisson: any, value: number) {
  sessionStorage.setItem(CacheKey.PERMISSION, permisson);
}

export function removePermission() {
  sessionStorage.removeItem(CacheKey.PERMISSION);
}
