import { warehousePrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Warehouse {
  id?: string | number;
  code: string;
  name: string;
  area: number;
  managerId: string | number;
}
export interface queryWarehouseConditions {
  code: string;
  name: string;
}

export const createWarehouse = (data: Warehouse) => Post(warehousePrefix, data);
export const editWarehouse = (data: Warehouse) => Put(warehousePrefix, data);
export const deleteWarehouse = (id: string | number) =>
  Delete(warehousePrefix + `/${id}`);
export const findWarehousePage = (data: any) =>
  Get(warehousePrefix + "/page", data);
export const getWarehouseList = (data: any) =>
  Get(`${warehousePrefix}/list`, data);
