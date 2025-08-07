import { demandDetailPrefix } from "../api";
import { Post, Get, Delete } from "@/http/axios";

export interface DemandDetail {
  detailId?: string | number;
  productId: string | number;
  productName: string;
  productSpec: string;
  unit: string;
  quantity: number;
  suggestedPrice: number;
  remarks: string;
  demandId: string | number;
}

export const createDemandDetail = (data: DemandDetail[]) =>
  Post(demandDetailPrefix, data);
export const getDemandList = (demandId: string) =>
  Get(`${demandDetailPrefix}/${demandId}`, null);
export const deleteDemand = (demandId: string) =>
  Delete(demandDetailPrefix + `/${demandId}`);
