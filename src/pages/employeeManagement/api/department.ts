import { departmentPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Department {
  id?: string | number;
  name: string;
  parentId: string | number;
  managerId: string | number;
}
//新增部门
export const createDepartment = (data: Department) =>
  Post(departmentPrefix, data);
//编辑部门
export const editDepartment = (data: Department) => Put(departmentPrefix, data);
//删除部门
export const deleteDepartment = (id: string | number) =>
  Delete(`${departmentPrefix}/${id}`);
//查询部门列表
export const getDepartmentList = () => Get(`${departmentPrefix}/list`, null);
//根据部门Ids查询部门列表
export const getDepartmentListByIds = (ids: string[] | number[]) =>
  Get(`${departmentPrefix}/getByIds/${ids}`, null);
