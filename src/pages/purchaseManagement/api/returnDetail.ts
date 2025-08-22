import { returnDetailPrefix } from "../api";
import { Post, Get, Delete } from "@/http/axios";
export interface ReturnDetail {
  id?: string | number;
  returnId: string | number;
  supplierId: string | number;
  productId: string | number;
  categoryId: string | number;
  quantity: number;
  price: number;
  amount: number;
}
export const createReturnDetail = (data: ReturnDetail[]) =>
  Post(returnDetailPrefix, data);
export const getReturnDetailList = (returnId: string) =>
  Get(`${returnDetailPrefix}/${returnId}`, null);
export const deleteReturnDetail = (returnId: string) =>
  Delete(returnDetailPrefix + `/${returnId}`);
