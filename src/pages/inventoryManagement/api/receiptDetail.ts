import { receiptDetailPrefix } from "../api";
import { Post, Get, Delete } from "@/http/axios";

export interface ReceiptDetail {
  id?: string | number;
  receiptId?: string | number;
  productId: string | number;
  categoryId: string | number;
  shelfId: string | number;
  warehouseId: string | number;
  areaId: string | number;
  quantity: number;
  orderQuantity?: number;
  price: number;
  amount: number;
  productionDate?: string;
  expirationDate?: string;
  batchNumber: number;
}

export const createReceiptDetail = (data: ReceiptDetail[]) =>
  Post(receiptDetailPrefix, data);
export const getReceiptDetailList = (receiptId: string) =>
  Get(`${receiptDetailPrefix}/${receiptId}`, null);
export const deleteReceiptDetail = (receiptId: string) =>
  Delete(receiptDetailPrefix + `/${receiptId}`);
