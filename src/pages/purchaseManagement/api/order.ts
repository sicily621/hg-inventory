import { orderPrefix } from "../api";
import { Post, Get, Put, Delete, PutForm } from "@/http/axios";

export interface Order {
  id?: string | number;
  demandId: string | number;
  code: string;

  employeeId: string | number;
  expectedDate: number;
  actualDate: number;
  status: OrderStatus;
  totalAmount: number;
  description: string;
  approverId?: string | number;
  approvalTime?: number;
}

export enum OrderStatus {
  Pending = 1,
  Approved = 2,
  Rejected = 3,
  Confirmed = 4,
  PartiallyReceived = 5,
  FullyReceived = 6,
  PartiallyReturned = 7,
  Returned = 8,
  Finished = 9,
}

export const OrderStatusList = [
  { id: 1, name: "待审批" },
  { id: 2, name: "已审批" },
  { id: 3, name: "已驳回" },
  { id: 4, name: "供应商已确认" },
  { id: 5, name: "部分入库" },
  { id: 6, name: "全部入库" },
  { id: 7, name: "部分退单" },
  { id: 8, name: "全部退单" },
  { id: 9, name: "已完成" },
];

export interface queryOrderConditions {
  code: string;
  employeeId: string | number;
  startTime: string;
  endTime: string;
  status: OrderStatus | 0;
  startStatus?: OrderStatus;
  endStatus?: OrderStatus;
}

export const createOrder = (data: Order) => Post(orderPrefix, data);
export const editOrder = (data: any) => Put(orderPrefix, data);
export const deleteOrder = (id: string | number) =>
  Delete(orderPrefix + `/${id}`);
export const findOrderPage = (data: any) => Get(orderPrefix + "/page", data);
export const getOrderList = (data: any) => Get(`${orderPrefix}/list`, data);
