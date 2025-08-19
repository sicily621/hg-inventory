import { receiptPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Receipt {
  id?: string | number;
  code: string;
  orderId: string | number;
  employeeId: string | number;
  description: string;
}

export interface queryReceiptConditions {
  code: string;
  orderId: string | number;
  employeeId: string | number;
}

export const createReceipt = (data: Receipt) => Post(receiptPrefix, data);
export const editReceipt = (data: Receipt) => Put(receiptPrefix, data);
export const deleteReceipt = (id: string | number) =>
  Delete(receiptPrefix + `/${id}`);
export const findReceiptPage = (data: any) =>
  Get(receiptPrefix + "/page", data);
export const getReceiptList = (data: any) => Get(`${receiptPrefix}/list`, data);
