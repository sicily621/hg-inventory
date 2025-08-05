import type * as Users from "./type";
import { request } from "@/http/axios";

/** 获取当前登录用户详情 */
export function getCurrentUserApi(ids: string) {
  return request<Users.CurrentUserResponseData>({
    url: `/role/getByIds/${ids}`,
    method: "get",
  });
}
