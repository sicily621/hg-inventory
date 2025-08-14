import { returnPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Return {
  id?: string | number;
  orderId: string | number;
  code: string;
  employeeId: string | number;
  customerId: string | number;
  status: ReturnStatus;
  totalAmount: number;
  description: string;
  approverId?: string | number;
  approvalTime?: number;
}

export enum ReturnStatus {
  Pending = 1,
  Approved = 2,
  Rejected = 3,
  Finished = 4,
}

export const ReturnStatusList = [
  { id: 1, name: "待审核" },
  { id: 2, name: "已审核" },
  { id: 3, name: "已驳回" },
  { id: 4, name: "已完成" },
];

export interface queryReturnConditions {
  code: string;
  employeeId: string | number;
  startTime: string;
  endTime: string;
  status: ReturnStatus | 0;
}

export const createReturn = (data: Return) => Post(returnPrefix, data);
export const editReturn = (data: Return) => Put(returnPrefix, data);
export const deleteReturn = (id: string | number) =>
  Delete(returnPrefix + `/${id}`);
export const findReturnPage = (data: any) => Get(returnPrefix + "/page", data);
export const getReturnList = () => Get(`${returnPrefix}/list`, null);
