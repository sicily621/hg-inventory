import { rolePermissionRelationsPrefix } from "../api";
import { Post, Get, Delete } from "@/http/axios";

export interface RolePermissionRelations {
  id?: string | number;
  roleId: string | number;
  permissionId: string | number;
}

export const createRolePermissionRelations = (
  data: RolePermissionRelations[],
) => Post(rolePermissionRelationsPrefix, data);

export const getRolePermissionRelationsByRoleId = (roleId: string) =>
  Get(rolePermissionRelationsPrefix + `/${roleId}`, null);

export const deleteRolePermissionRelations = (roleId: string) =>
  Delete(rolePermissionRelationsPrefix + `/${roleId}`);
