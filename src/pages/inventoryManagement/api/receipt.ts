import { receiptPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Receipt {
  id?: string | number;
  code: string;
  orderId: string | number;
  employeeId: string | number;
  warehouseId: string | number;
  status: ReceiptStatus;
  description: string;
}
//状态(1未入库,2-部分入库,3-全部入库)
export enum ReceiptStatus {
  NotReceived = 1,
  PartiallyReceived = 2,
  FullyReceived = 3,
}
export const ReceiptStatusList = [
  { id: 1, name: "未入库" },
  { id: 2, name: "部分入库" },
  { id: 3, name: "全部入库" },
];

export interface queryReceiptConditions {
  code: string;
  orderId: string | number;
  employeeId: string | number;
  warehouseId: string | number;
  status: ReceiptStatus;
}

export const createReceipt = (data: Receipt) => Post(receiptPrefix, data);
export const editReceipt = (data: Receipt) => Put(receiptPrefix, data);
export const deleteReceipt = (id: string | number) =>
  Delete(receiptPrefix + `/${id}`);
export const findReceiptPage = (data: any) =>
  Get(receiptPrefix + "/page", data);
export const getReceiptList = (data: any) => Get(`${receiptPrefix}/list`, data);
