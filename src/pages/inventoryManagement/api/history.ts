import { historyPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface History {
  id?: string | number;
  productId: string | number;
  warehouseId: string | number;
  shelfId: string | number;
  areaId: string | number;
  type: HistoryType;
  documentId?: string | number;
  quantity: number;
  employeeId: string | number;
  description: string;
}

//操作类型(1-采购入库,2-销售出库,3-采购退货,4-销售退货,5-库存调整)
export enum HistoryType {
  PurchaseIn = 1,
  SaleOut = 2,
  PurchaseReturn = 3,
  SaleReturn = 4,
  InventoryAdjust = 5,
}
export const HistoryTypeList = [
  { id: 1, name: "采购入库" },
  { id: 2, name: "销售出库" },
  { id: 3, name: "采购退货" },
  { id: 4, name: "销售退货" },
  { id: 5, name: "库存调整" },
];

export interface queryHistoryConditions {
  productId: string | number;
  warehouseId: string | number;
  type: HistoryType | 0;
  employeeId: string | number;
}

export const createHistory = (data: History) => Post(historyPrefix, data);
export const batchSaveHistory = (data: History[]) =>
  Post(historyPrefix + "/batchSave", data);
export const editHistory = (data: History) => Put(historyPrefix, data);
export const deleteHistory = (id: string | number) =>
  Delete(historyPrefix + `/${id}`);
export const findHistoryPage = (data: any) =>
  Get(historyPrefix + "/page", data);
export const getHistoryList = (data: any) => Get(`${historyPrefix}/list`, data);
