import type { RouteRecordRaw } from "vue-router";
import { createRouter } from "vue-router";
import { routerConfig } from "@/router/config";
import { registerNavigationGuard } from "@/router/guard";
import { flatMultiLevelRoutes } from "./helper";
import { ModuleCode } from "./moduleCode";

const Layouts = () => import("@/layouts/index.vue");

/**
 * @name 常驻路由
 * @description 除了 redirect/403/404/login 等隐藏页面，其他页面建议设置唯一的 Name 属性
 */
export const constantRoutes: RouteRecordRaw[] = [
  {
    path: "/redirect",
    component: Layouts,
    meta: {
      hidden: true,
    },
    children: [
      {
        path: ":path(.*)",
        component: () => import("@/pages/redirect/index.vue"),
      },
    ],
  },
  {
    path: "/403",
    component: () => import("@/pages/error/403.vue"),
    meta: {
      hidden: true,
    },
  },
  {
    path: "/404",
    component: () => import("@/pages/error/404.vue"),
    meta: {
      hidden: true,
    },
    alias: "/:pathMatch(.*)*",
  },
  {
    path: "/login",
    component: () => import("@/pages/login/index.vue"),
    meta: {
      hidden: true,
    },
  },
  {
    path: "/",
    component: Layouts,
    redirect: "/home",
    children: [
      {
        path: "home",
        component: () => import("@/pages/home/index.vue"),
        name: "Home",
        meta: {
          title: "经营概览",
          elIcon: "DataAnalysis",
        },
      },
    ],
  },
];

/**
 * @name 动态路由
 * @description 用来放置有权限 (Roles 属性) 的路由
 * @description 必须带有唯一的 Name 属性
 */
export const dynamicRoutes: RouteRecordRaw[] = [
  {
    path: "/employeeManagement",
    component: Layouts,
    redirect: "/employeeManagement/employee",
    meta: {
      title: "组织权限",
      elIcon: "User",
      moduleCode: ModuleCode.EmployeeManagement,
    },
    children: [
      {
        path: "department",
        component: () =>
          import("@/pages/employeeManagement/department/list.vue"),
        name: "department",
        meta: {
          title: "部门管理",
          moduleCode: ModuleCode.Department,
        },
      },
      {
        path: "role",
        component: () => import("@/pages/employeeManagement/role/list.vue"),
        name: "role",
        meta: {
          title: "角色管理",
          moduleCode: ModuleCode.Role,
        },
      },
      {
        path: "employee",
        component: () => import("@/pages/employeeManagement/employee/list.vue"),
        name: "employee",
        meta: {
          title: "员工管理",
          moduleCode: ModuleCode.Employee,
        },
      },
      {
        path: "permission",
        component: () =>
          import("@/pages/employeeManagement/permission/list.vue"),
        name: "permission",
        meta: {
          title: "权限管理",
          moduleCode: ModuleCode.Permission,
        },
      },
    ],
  },
  {
    path: "/productManagement",
    component: Layouts,
    redirect: "/productManagement/category",
    meta: {
      title: "商品管理",
      elIcon: "Goods",
      moduleCode: ModuleCode.ProductManagement,
    },
    children: [
      {
        path: "category",
        component: () => import("@/pages/productManagement/category/list.vue"),
        name: "category",
        meta: {
          title: "商品分类",
          moduleCode: ModuleCode.Category,
        },
      },
      {
        path: "product",
        component: () => import("@/pages/productManagement/product/list.vue"),
        name: "product",
        meta: {
          title: "商品管理",
          moduleCode: ModuleCode.Product,
        },
      },
    ],
  },
  {
    path: "/warehouseManagement",
    component: Layouts,
    redirect: "/warehouseManagement/warehouse",
    meta: {
      title: "仓库管理",
      elIcon: "HomeFilled",
      moduleCode: ModuleCode.WarehouseManagement,
    },
    children: [
      {
        path: "warehouse",
        component: () =>
          import("@/pages/warehouseManagement/warehouse/list.vue"),
        name: "warehouse",
        meta: {
          title: "仓库管理",
          moduleCode: ModuleCode.Warehouse,
        },
      },
      {
        path: "area",
        component: () => import("@/pages/warehouseManagement/area/list.vue"),
        name: "area",
        meta: {
          title: "区域管理",
          moduleCode: ModuleCode.Area,
        },
      },
      {
        path: "shelf",
        component: () => import("@/pages/warehouseManagement/shelf/list.vue"),
        name: "shelf",
        meta: {
          title: "货架管理",
          moduleCode: ModuleCode.Shelf,
        },
      },
    ],
  },
  {
    path: "/saleManagement",
    component: Layouts,
    redirect: "/saleManagement/customer",
    meta: {
      title: "销售管理",
      elIcon: "DataLine",
      moduleCode: ModuleCode.SaleManagement,
    },
    children: [
      {
        path: "customer",
        component: () => import("@/pages/saleManagement/customer/list.vue"),
        name: ModuleCode.Customer,
        meta: {
          title: "客户管理",
          moduleCode: ModuleCode.Customer,
        },
      },
      {
        path: "order",
        component: () => import("@/pages/saleManagement/order/list.vue"),
        name: ModuleCode.SalesOrder,
        meta: {
          title: "销售订单",
          moduleCode: ModuleCode.SalesOrder,
        },
      },
      {
        path: "return",
        component: () => import("@/pages/saleManagement/return/list.vue"),
        name: ModuleCode.SalesReturn,
        meta: {
          title: "销售退单",
          moduleCode: ModuleCode.SalesReturn,
        },
      },
    ],
  },
  {
    path: "/purchaseManagement",
    component: Layouts,
    redirect: "/purchaseManagement/supplier",
    meta: {
      title: "采购管理",
      elIcon: "FirstAidKit",
      moduleCode: ModuleCode.PurchaseManagement,
    },
    children: [
      {
        path: "supplier",
        component: () => import("@/pages/purchaseManagement/supplier/list.vue"),
        name: ModuleCode.Supplier,
        meta: {
          title: "供应商管理",
          moduleCode: ModuleCode.Supplier,
        },
      },
      {
        path: "demand",
        component: () => import("@/pages/purchaseManagement/demand/list.vue"),
        name: ModuleCode.PurchaseDemand,
        meta: {
          title: "采购需求",
          moduleCode: ModuleCode.PurchaseDemand,
        },
      },
      {
        path: "order",
        component: () => import("@/pages/purchaseManagement/order/list.vue"),
        name: ModuleCode.PurchaseOrder,
        meta: {
          title: "采购订单",
          moduleCode: ModuleCode.PurchaseOrder,
        },
      },
      {
        path: "return",
        component: () => import("@/pages/purchaseManagement/return/list.vue"),
        name: ModuleCode.PurchaseReturn,
        meta: {
          title: "采购退单",
          moduleCode: ModuleCode.PurchaseReturn,
        },
      },
    ],
  },
  {
    path: "/inventoryManagement",
    component: Layouts,
    redirect: "/inventoryManagement/inventory",
    meta: {
      title: "库存管理",
      elIcon: "Tickets",
      moduleCode: ModuleCode.InventoryManagement,
    },
    children: [
      {
        path: "inventory",
        component: () =>
          import("@/pages/inventoryManagement/inventory/list.vue"),
        name: ModuleCode.InventoryManagement,
        meta: {
          title: "商品库存",
          moduleCode: ModuleCode.Inventory,
        },
      },
      {
        path: "history",
        component: () => import("@/pages/inventoryManagement/history/list.vue"),
        name: ModuleCode.InventoryHistory,
        meta: {
          title: "库存流水",
          moduleCode: ModuleCode.InventoryHistory,
        },
      },
      {
        path: "check",
        component: () => import("@/pages/inventoryManagement/check/list.vue"),
        name: ModuleCode.InventoryCheck,
        meta: {
          title: "库存盘点",
          moduleCode: ModuleCode.InventoryCheck,
        },
      },
      {
        path: "receipt",
        component: () => import("@/pages/inventoryManagement/receipt/list.vue"),
        name: ModuleCode.InventoryReceipt,
        meta: {
          title: "入库",
          moduleCode: ModuleCode.InventoryReceipt,
        },
      },
      {
        path: "shipment",
        component: () =>
          import("@/pages/inventoryManagement/shipment/list.vue"),
        name: ModuleCode.InventoryShipment,
        meta: {
          title: "出库",
          moduleCode: ModuleCode.InventoryShipment,
        },
      },
    ],
  },
  {
    path: "/accountManagement",
    component: Layouts,
    redirect: "/accountManagement/account",
    meta: {
      title: "账单管理",
      elIcon: "Coin",
      moduleCode: ModuleCode.AccountManagement,
    },
    children: [
      {
        path: "account",
        component: () => import("@/pages/accountManagement/account/list.vue"),
        name: ModuleCode.Account,
        meta: {
          title: "账单管理",
          elIcon: "Coin",
          moduleCode: ModuleCode.Account,
        },
      }, {
        path: "accountStatistics",
        component: () => import("@/pages/accountManagement/statistics/index.vue"),
        name: ModuleCode.AccountStatistics,
        meta: {
          title: "利润统计",
          elIcon: "DataLine",
          moduleCode: ModuleCode.AccountStatistics,
        },
      },
    ],
  },
];

/** 路由实例 */
export const router = createRouter({
  history: routerConfig.history,
  routes: routerConfig.thirdLevelRouteCache
    ? flatMultiLevelRoutes(constantRoutes)
    : constantRoutes,
});

/** 重置路由 */
export function resetRouter() {
  try {
    // 注意：所有动态路由路由必须带有 Name 属性，否则可能会不能完全重置干净
    router.getRoutes().forEach((route) => {
      const { name, meta } = route;
      if (name && meta.roles?.length) {
        router.hasRoute(name) && router.removeRoute(name);
      }
    });
  } catch {
    // 强制刷新浏览器也行，只是交互体验不是很好
    location.reload();
  }
}

// 注册路由导航守卫
registerNavigationGuard(router);
