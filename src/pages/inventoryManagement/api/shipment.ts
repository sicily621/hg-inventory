import { shipmentPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Shipment {
  id?: string | number;
  code: string;
  orderId: string | number;
  employeeId: string | number;
  warehouseId: string | number;
  status: ShipmentStatus;
  description: string;
}
//状态(1-待审核,2-已完成)
export enum ShipmentStatus {
  PendingReview = 1,
  Completed = 2,
}
export const ShipmentStatusList = [
  { id: 1, name: "待审核" },
  { id: 2, name: "已完成" },
];

export interface queryShipmentConditions {
  code: string;
  orderId: string | number;
  employeeId: string | number;
  warehouseId: string | number;
  status: ShipmentStatus;
}

export const createShipment = (data: Shipment) => Post(shipmentPrefix, data);
export const editShipment = (data: Shipment) => Put(shipmentPrefix, data);
export const deleteShipment = (id: string | number) =>
  Delete(shipmentPrefix + `/${id}`);
export const findShipmentPage = (data: any) =>
  Get(shipmentPrefix + "/page", data);
export const getShipmentList = (data: any) =>
  Get(`${shipmentPrefix}/list`, data);
