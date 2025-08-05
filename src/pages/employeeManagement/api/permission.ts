import { permissionPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Permission {
  id?: string | number;
  name: string;
  moduleCode: string;
  parentId: string | number;
  url: string;
  description: string;
  action: PermissionAction; //1 view、2 add、3 edit、4 delete、5 approve
  type: PermissionType; //1 菜单级 、2 按钮级
}
export enum PermissionAction {
  View = 1,
  Add = 2,
  Edit = 3,
  Delete = 4,
  Approve = 5,
}
export const PermissionActionList = [
  { id: 1, name: "查看" },
  { id: 2, name: "新增" },
  { id: 3, name: "编辑" },
  { id: 4, name: "删除" },
  { id: 5, name: "审批" },
];
export enum PermissionType {
  Menu = 1,
  Button = 2,
}
export const PermissionTypeList = [
  { id: 1, name: "菜单级" },
  { id: 2, name: "按钮级" },
];
export interface queryPermissionConditions {
  moduleCode: string;
}

export const createPermission = (data: Permission) =>
  Post(permissionPrefix, data);
export const editPermission = (data: Permission) => Put(permissionPrefix, data);
export const deletePermission = (id: string | number) =>
  Delete(permissionPrefix + `/${id}`);
export const findPermissionPage = (data: any) =>
  Get(permissionPrefix + "/page", data);
export const getPermissionList = () => Get(`${permissionPrefix}/list`, null);
export const getPermissionListByIds = (ids: string[]) =>
  Get(`${permissionPrefix}/getByIds/${ids}`, null);
