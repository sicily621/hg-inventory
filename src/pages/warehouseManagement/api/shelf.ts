import { shelfPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Shelf {
  id?: string | number;
  code: string;
  name: string;
  areaId: string | number;
  layerCount: number;
  maxCapacity: number;
}
export interface queryShelfConditions {
  code: string;
  name: string;
  areaId: string | number;
}

export const createShelf = (data: Shelf) => Post(shelfPrefix, data);
export const editShelf = (data: Shelf) => Put(shelfPrefix, data);
export const deleteShelf = (id: string | number) =>
  Delete(shelfPrefix + `/${id}`);
export const findShelfPage = (data: any) => Get(shelfPrefix + "/page", data);
export const getShelfList = (data: any) => Get(`${shelfPrefix}/list`, data);
