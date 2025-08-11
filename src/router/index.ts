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
    redirect: "/dashboard",
    children: [
      {
        path: "dashboard",
        component: () => import("@/pages/dashboard/index.vue"),
        name: "Dashboard",
        meta: {
          title: "首页",
          svgIcon: "dashboard",
          affix: true,
        },
      },
    ],
  },
  {
    path: "/demo",
    component: Layouts,
    redirect: "/demo/unocss",
    name: "Demo",
    meta: {
      title: "示例集合",
      elIcon: "DataBoard",
    },
    children: [
      {
        path: "unocss",
        component: () => import("@/pages/demo/unocss/index.vue"),
        name: "UnoCSS",
        meta: {
          title: "UnoCSS",
        },
      },
      {
        path: "element-plus",
        component: () => import("@/pages/demo/element-plus/index.vue"),
        name: "ElementPlus",
        meta: {
          title: "Element Plus",
          keepAlive: true,
        },
      },
      {
        path: "vxe-table",
        component: () => import("@/pages/demo/vxe-table/index.vue"),
        name: "VxeTable",
        meta: {
          title: "Vxe Table",
          keepAlive: true,
        },
      },
      {
        path: "level2",
        component: () => import("@/pages/demo/level2/index.vue"),
        redirect: "/demo/level2/level3",
        name: "Level2",
        meta: {
          title: "二级路由",
          alwaysShow: true,
        },
        children: [
          {
            path: "level3",
            component: () => import("@/pages/demo/level2/level3/index.vue"),
            name: "Level3",
            meta: {
              title: "三级路由",
              keepAlive: true,
            },
          },
        ],
      },
      {
        path: "composable-demo",
        redirect: "/demo/composable-demo/use-fetch-select",
        name: "ComposableDemo",
        meta: {
          title: "组合式函数",
        },
        children: [
          {
            path: "use-fetch-select",
            component: () =>
              import("@/pages/demo/composable-demo/use-fetch-select.vue"),
            name: "UseFetchSelect",
            meta: {
              title: "useFetchSelect",
            },
          },
          {
            path: "use-fullscreen-loading",
            component: () =>
              import("@/pages/demo/composable-demo/use-fullscreen-loading.vue"),
            name: "UseFullscreenLoading",
            meta: {
              title: "useFullscreenLoading",
            },
          },
          {
            path: "use-watermark",
            component: () =>
              import("@/pages/demo/composable-demo/use-watermark.vue"),
            name: "UseWatermark",
            meta: {
              title: "useWatermark",
            },
          },
        ],
      },
    ],
  },
  {
    path: "/link",
    meta: {
      title: "文档链接",
      elIcon: "Link",
    },
    children: [
      {
        path: "https://juejin.cn/post/7445151895121543209",
        component: () => {},
        name: "Link1",
        meta: {
          title: "中文文档",
        },
      },
      {
        path: "https://juejin.cn/column/7207659644487139387",
        component: () => {},
        name: "Link2",
        meta: {
          title: "新手教程",
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
      title: "员工管理",
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
      elIcon: "Goods",
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
      elIcon: "Goods",
      moduleCode: ModuleCode.WarehouseManagement,
    },
    children: [
      {
        path: "customer",
        component: () => import("@/pages/saleManagement/customer/list.vue"),
        name: "customer",
        meta: {
          title: "客户管理",
          moduleCode: ModuleCode.Customer,
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
      elIcon: "Goods",
      moduleCode: ModuleCode.PurchaseManagement,
    },
    children: [
      {
        path: "supplier",
        component: () => import("@/pages/purchaseManagement/supplier/list.vue"),
        name: "supplier",
        meta: {
          title: "供应商管理",
          moduleCode: ModuleCode.Supplier,
        },
      },
      {
        path: "demand",
        component: () => import("@/pages/purchaseManagement/demand/list.vue"),
        name: "demand",
        meta: {
          title: "采购需求",
          moduleCode: ModuleCode.PurchaseDemand,
        },
      },
      {
        path: "order",
        component: () => import("@/pages/purchaseManagement/order/list.vue"),
        name: "order",
        meta: {
          title: "采购订单",
          moduleCode: ModuleCode.PurchaseOrder,
        },
      },
      {
        path: "return",
        component: () => import("@/pages/purchaseManagement/return/list.vue"),
        name: "return",
        meta: {
          title: "采购退单",
          moduleCode: ModuleCode.PurchaseReturn,
        },
      },
    ],
  },
  {
    path: "/permission",
    component: Layouts,
    redirect: "/permission/page-level",
    name: "Permission",
    meta: {
      title: "权限演示",
      elIcon: "Lock",
      // 可以在根路由中设置角色
      roles: ["admin", "editor"],
      alwaysShow: true,
    },
    children: [
      {
        path: "page-level",
        component: () => import("@/pages/demo/permission/page-level.vue"),
        name: "PermissionPageLevel",
        meta: {
          title: "页面级",
          // 或者在子路由中设置角色
          roles: ["admin"],
        },
      },
      {
        path: "button-level",
        component: () => import("@/pages/demo/permission/button-level.vue"),
        name: "PermissionButtonLevel",
        meta: {
          title: "按钮级",
          // 如果未设置角色，则表示：该页面不需要权限，但会继承根路由的角色
          roles: undefined,
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
