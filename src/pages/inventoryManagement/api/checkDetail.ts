import { checkDetailPrefix } from "../api";
import { Post, Get, Delete } from "@/http/axios";

export interface CheckDetail {
  id?: string | number;
  checkId?: string | number;
  productId: string | number;
  categoryId: string | number;
  shelfId: string | number;
  areaId: string | number;
  systemQuantity: number;
  actualQuantity: number;
  difference: number;
  description: string;
}

export const createCheckDetail = (data: CheckDetail[]) =>
  Post(checkDetailPrefix, data);
export const getCheckDetailList = (checkId: string) =>
  Get(`${checkDetailPrefix}/${checkId}`, null);
export const deleteCheckDetail = (checkId: string) =>
  Delete(checkDetailPrefix + `/${checkId}`);
