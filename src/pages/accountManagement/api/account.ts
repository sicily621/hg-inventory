import { accountPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Account {
  id?: string | number;
  orderId: string | number;
  type: AccountType;
  relatedEntityType: RelatedEntityType;
  relatedEntityId: string | number;
  amount: number;
  paymentMethod?: any;
  bankName?: string;
  employeeId: string | number;
  status: AccountStatus;
  description: string;
}

export enum AccountType {
  PurchasePayMent = 1,
  PurchaseRefund = 2,
  SalesRevenue = 3,
  SalesRefund = 4,
}

export const AccountActionList = [
  { id: 1, name: "采购支付" },
  { id: 2, name: "采购退款" },
  { id: 3, name: "销售收入" },
  { id: 4, name: "销售退款" },
];

export enum RelatedEntityType {
  Suppiler = 1,
  Customer = 2,
}

export const AccountTypeList = [
  { id: 1, name: "供应商" },
  { id: 2, name: "客户" },
];

export enum AccountStatus {
  Pending = 1,
  Approved = 2,
  Paid = 3,
}

export const AccountStatusList = [
  { id: 1, name: "待审核" },
  { id: 2, name: "已审核" },
  { id: 3, name: "已支付" },
];

export interface queryAccountConditions {
  orderId?: string | number;
  type: AccountType;
  relatedEntityId: string | number;
  employeeId: string | number;
  status: AccountStatus;
}

export const createAccount = (data: Account) => Post(accountPrefix, data);
export const editAccount = (data: Account) => Put(accountPrefix, data);
export const deleteAccount = (id: string | number) =>
  Delete(accountPrefix + `/${id}`);
export const findAccountPage = (data: any) =>
  Get(accountPrefix + "/page", data);
export const getAccountList = () => Get(`${accountPrefix}/list`, null);
export const getAccountListByIds = (ids: string[]) =>
  Get(`${accountPrefix}/getByIds/${ids}`, null);
export const getAccountByOrderId = (orderId: any) =>
  Get(`${accountPrefix}/getByOrderId/${orderId}`, null);
export const batchAccount = (data: Account[]) =>
  Post(`${accountPrefix}/batchSave`, data);
