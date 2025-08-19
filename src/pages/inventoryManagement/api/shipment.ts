import { shipmentPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Shipment {
  id?: string | number;
  code: string;
  orderId: string | number;
  employeeId: string | number;
  description: string;
}

export interface queryShipmentConditions {
  code: string;
  orderId: string | number;
  employeeId: string | number;
}

export const createShipment = (data: Shipment) => Post(shipmentPrefix, data);
export const editShipment = (data: Shipment) => Put(shipmentPrefix, data);
export const deleteShipment = (id: string | number) =>
  Delete(shipmentPrefix + `/${id}`);
export const findShipmentPage = (data: any) =>
  Get(shipmentPrefix + "/page", data);
export const getShipmentList = (data: any) =>
  Get(`${shipmentPrefix}/list`, data);
