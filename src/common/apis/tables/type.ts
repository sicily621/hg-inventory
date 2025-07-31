export interface CreateOrUpdateTableRequestData {
  id?: number;
  username: string;
  password?: string;
}

export interface TableRequestData {
  currentPage: number;
  size: number;
}

export interface TableData {
  createTime: string;
  email: string;
  id: number;
  phone: string;
  roles: string;
  status: boolean;
  username: string;
}

export type PaginatedRequest<T> = TableRequestData & Partial<T>;

export type TableResponseData = ApiResponseData<{
  list: TableData[];
  total: number;
}>;
