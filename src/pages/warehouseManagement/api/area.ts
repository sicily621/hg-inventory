import { areaPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Area {
  id?: string | number;
  warehouseId: string | number;
  name: string;
  type: number;
}
export enum AreaType {
  Save = 1,
  Receive = 2,
  Send = 3,
}
export const AreaTypeList = [
  { id: 1, name: "存货区" },
  { id: 2, name: "收货区" },
  { id: 3, name: "发货区" },
];
export interface queryAreaConditions {
  type: number;
  warehouseId: string | number;
}

export const createArea = (data: Area) => Post(areaPrefix, data);
export const editArea = (data: Area) => Put(areaPrefix, data);
export const deleteArea = (id: string | number) =>
  Delete(areaPrefix + `/${id}`);
export const findAreaPage = (data: any) => Get(areaPrefix + "/page", data);
export const getAreaList = (data: any) => Get(`${areaPrefix}/list`, data);
