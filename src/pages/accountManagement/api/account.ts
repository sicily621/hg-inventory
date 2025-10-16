import { accountPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Account {
  id?: string | number;
  orderId: string | number;
  type: AccountType;
  relatedCode: string;
  relatedEntityType: RelatedEntityType;
  relatedEntityId: string | number;
  amount: number;
  cost: number;
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
  Receipt = 3,
  Paid = 4,
}

export const AccountStatusList = [
  { id: 1, name: "待审批" },
  { id: 2, name: "已审批" },
  { id: 3, name: "已收款" },
  { id: 4, name: "已付款" },
];

export interface queryAccountConditions {
  orderId?: string | number;
  type: AccountType | 0;
  relatedEntityId: string | number;
  employeeId: string | number;
  status: AccountStatus | 0;
  startTime: string;
  endTime: string;
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

//查询多个时间类型统计
export const getListSalesStatisticsByTimeType = (data: { timeType: number; startTime: string }) =>
  Get(`${accountPrefix}/statistics/listSalesStatisticsByTimeType`, data);
//查询单个时间类型统计
export const getSalesStatisticsByTimeType = (data: { timeType: number; startTime: string }) =>
  Get(`${accountPrefix}/statistics/getSalesStatisticsByTimeType`, data);
