import { permissionPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Permission {
  id?: string | number;
  name: string;
  moduleCode: string;
  parentId: string | number;
  url: string;
  description: string;
}
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
