import { categoryPrefix } from "../api";

import { Post, Get, Put, Delete } from "@/http/axios";

export interface Category {
  id?: string | number;
  name: string;
  parentId: string | number;
}
//新增商品分类
export const createCategory = (data: Category) => Post(categoryPrefix, data);
//编辑商品分类
export const editCategory = (data: Category) => Put(categoryPrefix, data);
//删除商品分类
export const deleteCategory = (id: string | number) =>
  Delete(`${categoryPrefix}/${id}`);
//查询商品分类列表
export const getCategoryList = () => Get(`${categoryPrefix}/list`, null);
//根据商品分类Ids查询商品分类列表
export const getCategoryListByIds = (ids: string[] | number[]) =>
  Get(`${categoryPrefix}/getByIds/${ids}`, null);
