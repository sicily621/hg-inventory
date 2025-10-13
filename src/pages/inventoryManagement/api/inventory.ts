import { inventoryPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Inventory {
  id?: string | number;
  productId: string | number;
  warehouseId: string | number;
  shelfId: string | number;
  areaId: string | number;
  quantity: number;
}

export interface queryInventoryConditions {
  productId: string | number;
  warehouseId: string | number;
  shelfId: string | number;
  areaId: string | number;
}

export const createInventory = (data: Inventory) => Post(inventoryPrefix, data);
export const receipt = (data: Inventory[]) =>
  Post(inventoryPrefix + "/add", data);
export const shipment = (data: Inventory[]) =>
  Post(inventoryPrefix + "/subtract", data);
export const editInventory = (data: Inventory) => Put(inventoryPrefix, data);
export const batchUpdateInventory = (data: Inventory[]) =>
  Put(inventoryPrefix + "/batchUpdate", data);
export const deleteInventory = (id: string | number) =>
  Delete(inventoryPrefix + `/${id}`);
export const findInventoryPage = (data: any) =>
  Get(inventoryPrefix + "/page", data);
export const getInventoryList = (data: any) =>
  Get(`${inventoryPrefix}/list`, data);
export const getInventoryByProductIds = (ids: string) =>
  Get(`${inventoryPrefix}/getByProductIds/${ids}`, ids);
