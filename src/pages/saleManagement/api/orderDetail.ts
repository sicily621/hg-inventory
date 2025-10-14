import { orderDetailPrefix } from "../api";
import { Post, Get, Delete } from "@/http/axios";
export interface OrderDetail {
  id?: string | number;
  orderId?: string | number;
  productId: string | number;
  categoryId: string | number;
  quantity: number;
  price: number;
  cost: number;
  amount: number;
}
export const createOrderDetail = (data: OrderDetail[]) =>
  Post(orderDetailPrefix, data);
export const getOrderDetailList = (orderId: string) =>
  Get(`${orderDetailPrefix}/${orderId}`, null);
export const deleteOrderDetail = (orderId: string) =>
  Delete(orderDetailPrefix + `/${orderId}`);
