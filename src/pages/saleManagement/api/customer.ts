import { customerPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Customer {
  id?: string | number;
  name: string;
  phone: string;
  email: string;
  address: string;
  creditLevel: number;
  contactPerson: string;
}
export interface queryCustomerConditions {
  name: string;
  creditLevel: number;
}

export const createCustomer = (data: Customer) => Post(customerPrefix, data);
export const editCustomer = (data: Customer) => Put(customerPrefix, data);
export const deleteCustomer = (id: string | number) =>
  Delete(customerPrefix + `/${id}`);
export const findCustomerPage = (data: any) =>
  Get(customerPrefix + "/page", data);
export const getCustomerList = () => Get(`${customerPrefix}/list`, null);
