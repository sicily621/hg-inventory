import { employeePrefix } from "../api";
import { Post, Get, Put, Delete,PostForm } from "@/http/axios";

export interface Employee {
  id?: string | number;
  code: string;
  username: string;
  password?: string;
  realName: string;
  departmentId: string | number;
  roleId: string | number;
  gender: number;
  avatar: string;
  avatarFile?: File | null;
  position: string;
  phone: string;
  email: string;
  status: number;
}
export interface queryEmployeeConditions {
  code: string;
  realName: string;
  departmentId: string | number;
  roleId: string | number;
}

export const createEmployee = (data: Employee) => Post(employeePrefix, data);
export const editEmployee = (data: Employee) => Put(employeePrefix, data);
export const deleteEmployee = (id: string | number) =>
  Delete(employeePrefix + `/${id}`);
export const findEmployeePage = (data: any) =>
  Get(employeePrefix + "/page", data);
export const getEmployeeList = (data: any) =>
  Get(`${employeePrefix}/list`, data);
export const uploadFile = (data:{file:File})=>PostForm("/file/upload",data)
