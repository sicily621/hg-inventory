import { demandDetailPrefix } from "../api";
import { Post, Get, Delete } from "@/http/axios";

export interface DemandDetail {
  id?: string | number;
  productId: string | number;
  categoryId: string | number;
  quantity: number;
  demandId?: string | number;
}

export const createDemandDetail = (data: DemandDetail[]) =>
  Post(demandDetailPrefix, data);
export const getDemandDetailList = (demandId: string) =>
  Get(`${demandDetailPrefix}/${demandId}`, null);
export const deleteDemandDetail = (demandId: string) =>
  Delete(demandDetailPrefix + `/${demandId}`);
