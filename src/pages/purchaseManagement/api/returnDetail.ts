import { returnDetailPrefix } from "../api";
import { Post, Get, Delete } from "@/http/axios";
export interface ReturnDetail {
  id?: string | number;
  detailId: string | number;
  productId: string | number;
  categoryId: string | number;
  quantity: number;
  price: number;
  amount: number;
}
export const createOrderDetail = (data: ReturnDetail[]) =>
  Post(returnDetailPrefix, data);
export const getOrderDetailList = (returnId: string) =>
  Get(`${returnDetailPrefix}/${returnId}`, null);
export const deleteOrderDetail = (returnId: string) =>
  Delete(returnDetailPrefix + `/${returnId}`);
