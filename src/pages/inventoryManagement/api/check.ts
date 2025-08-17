import { checkPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Check {
  id?: string | number;
  code: string;
  warehouseId: string | number;
  employeeId: string | number;
  status: number;
  description: string;
}

//操作类型状态(1-进行中,2-已完成)
export enum CheckStatus {
  InProgress = 1,
  Completed = 2,
}
export const CheckStatusList = [
  { id: 1, name: "进行中" },
  { id: 2, name: "已完成" },
];
export interface queryCheckConditions {
  code: string;
  warehouseId: string | number;
  employeeId: string | number;
  status: CheckStatus | 0;
}

export const createCheck = (data: Check) => Post(checkPrefix, data);
export const editCheck = (data: Check) => Put(checkPrefix, data);
export const deleteCheck = (id: string | number) =>
  Delete(checkPrefix + `/${id}`);
export const findCheckPage = (data: any) => Get(checkPrefix + "/page", data);
export const getCheckList = (data: any) => Get(`${checkPrefix}/list`, data);
