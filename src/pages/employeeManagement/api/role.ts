import { rolePrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Role {
  id?: string | number;
  name: string;
  code: string;
  description: string;
  status: number;
}
export interface queryRoleConditions {
  code: string;
}
export const createRole = (data: Role) => Post(rolePrefix, data);
export const editRole = (data: Role) => Put(rolePrefix, data);
export const deleteRole = (id: string | number) =>
  Delete(rolePrefix + `/${id}`);
export const findRolePage = (data: any) => Get(rolePrefix + "/page", data);
export const getRoleList = () => Get(`${rolePrefix}/list`, null);
export const getRoleListByIds = (ids: string) =>
  Get(`${rolePrefix}/getByIds/${ids}`, null);
