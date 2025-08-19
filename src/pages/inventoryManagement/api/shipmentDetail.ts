import { shipmentDetailPrefix } from "../api";
import { Post, Get, Delete } from "@/http/axios";

export interface ShipmentDetail {
  id?: string | number;
  shipmentId?: string | number;
  productId: string | number;
  categoryId: string | number;
  warehouseId: string | number;
  shelfId: string | number;
  areaId: string | number;
  quantity: number;
  orderQuantity?: number;
  price: number;
  amount: number;
  batchNumber: number;
}

export const createShipmentDetail = (data: ShipmentDetail[]) =>
  Post(shipmentDetailPrefix, data);
export const getShipmentDetailList = (shipmentId: string) =>
  Get(`${shipmentDetailPrefix}/${shipmentId}`, null);
export const deleteShipmentDetail = (shipmentId: string) =>
  Delete(shipmentDetailPrefix + `/${shipmentId}`);
