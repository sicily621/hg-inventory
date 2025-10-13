import { productPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";
export interface Product {
  id?: string | number;
  code: string;
  name: string;
  categoryId: string | number;
  purchasePrice: number;
  retailPrice: number;
  specification: string;
  unit: string;
  brand: string;
  barcode: string;
}
export interface queryProductConditions {
  code: string;
  name: string;
  categoryId: string | number;
}

export const createProduct = (data: Product) => Post(productPrefix, data);
export const editProduct = (data: Product) => Put(productPrefix, data);
export const batchEditProduct = (data: Partial<Product>[]) => Put(`${productPrefix}/batchUpdate`, data);
export const deleteProduct = (id: string | number) =>
  Delete(productPrefix + `/${id}`);
export const findProductPage = (data: any) =>
  Get(productPrefix + "/page", data);
export const getProductList = (data: any) => Get(`${productPrefix}/list`, data);
export const findProductListByIds = (ids: string) =>
  Get(productPrefix + `/getByIds/${ids}`, null);
