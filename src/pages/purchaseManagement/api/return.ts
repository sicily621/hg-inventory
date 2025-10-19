import { returnPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Return {
  id?: string | number;
  orderId: string | number;
  code: string;
  employeeId: string | number;
  status: ReturnStatus;
  totalAmount: number;
  description: string;
  approverId?: string | number;
  approvalTime?: number;
  receipt: number;
}

export enum ReturnStatus {
  Pending = 1,
  Rejected = 2,
  Approved = 3,
  PartiallyReceived = 4,
  FullyReceived = 5,
}

export const ReturnStatusList = [
  { id: 1, name: "待审批" },
  { id: 2, name: "已驳回" },
  { id: 3, name: "已审批" },
  { id: 4, name: "部分出库" },
  { id: 5, name: "全部出库" },
];

export interface queryReturnConditions {
  code: string;
  orderId?: string | number;
  employeeId: string | number;
  startTime: string;
  endTime: string;
  status: ReturnStatus | 0;
  startStatus?: ReturnStatus;
  endStatus?: ReturnStatus;
}

export const createReturn = (data: Return) => Post(returnPrefix, data);
export const editReturn = (data: any) => Put(returnPrefix, data);
export const deleteReturn = (id: string | number) =>
  Delete(returnPrefix + `/${id}`);
export const findReturnPage = (data: any) => Get(returnPrefix + "/page", data);
export const getReturnList = (data: any = null) =>
  Get(`${returnPrefix}/list`, data);
