import { supplierPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Supplier {
  id?: string | number;
  code: string;
  name: string;
  phone: string;
  email: string;
  address: string;
  contactPerson: string;
}
export interface querySupplierConditions {
  name: string;
  code: string;
}

export const createSupplier = (data: Supplier) => Post(supplierPrefix, data);
export const editSupplier = (data: Supplier) => Put(supplierPrefix, data);
export const deleteSupplier = (id: string | number) =>
  Delete(supplierPrefix + `/${id}`);
export const findSupplierPage = (data: any) =>
  Get(supplierPrefix + "/page", data);
export const getSupplierList = () => Get(`${supplierPrefix}/list`, null);
