import { demandPrefix } from "../api";
import { Post, Get, Put, Delete } from "@/http/axios";

export interface Demand {
  id?: string | number;
  departmentId: string | number;
  applicantId: string | number;
  applyDate: number;
  expectedArrivalDate: number;
  description: string;
  status: DemandStatus;
  approverId: string | number;
  approverTime: number;
}

export enum DemandStatus {
  Pending = 1,
  Processing = 2,
  Approved = 3,
  Rejected = 4,
}

export const DemandStatusList = [
  { id: 1, name: "待审批" },
  { id: 2, name: "审批中" },
  { id: 3, name: "已通过" },
  { id: 4, name: "已驳回" },
];
export interface queryDemandConditions {
  departmentId: string | number;
  applyDate: number;
  status: DemandStatus;
}
export const createDemand = (data: Demand) => Post(demandPrefix, data);
export const editDemand = (data: Demand) => Put(demandPrefix, data);
export const deleteDemand = (id: string | number) =>
  Delete(demandPrefix + `/${id}`);
export const findDemandPage = (data: any) => Get(demandPrefix + "/page", data);
export const getDemandList = () => Get(`${demandPrefix}/list`, null);
