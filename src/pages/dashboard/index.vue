<template>
  <div class="app-container flex flex-col h-full">
    <div class="h-full w-full flex flex-col">
      <div class="flex-1 flex">
        <div class="el-card flex-1 m-r-2 h-full">
          <div class="m-t-6 m-l-6">商品概况</div>
          <div class="flex flex-center content-height">
            <div class="flex flex-col flex-center m-r-20">
              <div class="fz24 m-b-5">{{ categoryCount }}</div>
              <div>商品分类</div>
            </div>
            <div class="flex flex-col flex-center">
              <div class="fz24 m-b-5">{{ productCount }}</div>
              <div>商品</div>
            </div>
          </div>
        </div>
        <div class="el-card flex-1 m-r-2 h-full">
          <div class="m-t-6 m-l-6">仓库概况</div>
          <div class="flex flex-center content-height">
            <div class="flex flex-col flex-center m-r-20">
              <div class="fz24 m-b-5">{{ warehouseCount }}</div>
              <div>仓库数量</div>
            </div>
            <div class="flex flex-col flex-center m-r-20">
              <div class="fz24 m-b-5">{{ areaCount }}</div>
              <div>区域数量</div>
            </div>
            <div class="flex flex-col flex-center">
              <div class="fz24 m-b-5">{{ shelfCount }}</div>
              <div>货架数量</div>
            </div>
          </div>
        </div>
        <div class="el-card flex-1 h-full">
          <div class="m-t-6 m-l-6">销售概况</div>
          <div class="flex flex-center content-height">
            <div class="flex flex-col flex-center m-r-20">
              <div class="fz24 m-b-5">{{ customerCount }}</div>
              <div>客户数量</div>
            </div>
            <div class="flex flex-col flex-center m-r-20 blue">
              <div class="fz24 m-b-5">{{ orderCount }}</div>
              <div>销售订单</div>
            </div>
            <div class="flex flex-col flex-center red">
              <div class="fz24 m-b-5">{{ returnCount }}</div>
              <div>销售退单</div>
            </div>
          </div>
        </div>
      </div>
      <div class="flex-1 flex m-t-2">
        <div class="el-card flex-1 m-r-2 h-full">
          <div class="m-t-6 m-l-6">采购概况</div>
          <div class="flex flex-center content-height">
            <div class="flex flex-col flex-center m-r-20">
              <div class="fz24 m-b-5">{{ supplierCount }}</div>
              <div>供应商</div>
            </div>
            <div class="flex flex-col flex-center m-r-20">
              <div class="fz24 m-b-5">{{ demandCount }}</div>
              <div>采购需求</div>
            </div>
            <div class="flex flex-col flex-center m-r-20 blue">
              <div class="fz24 m-b-5">{{ purchaseOrderCount }}</div>
              <div>采购订单</div>
            </div>
            <div class="flex flex-col flex-center red">
              <div class="fz24 m-b-5">{{ purchaseReturnCount }}</div>
              <div>采购退单</div>
            </div>
          </div>
        </div>
        <div class="el-card flex-1 m-r-2 h-full">
          <div class="m-t-6 m-l-6">销售订单概况</div>
          <div class="flex flex-center content-height">
            <div class="flex flex-col flex-center m-r-20 yellow">
              <div class="fz24 m-b-5">{{ pendingSaleOrderCount }}</div>
              <div>待审批</div>
            </div>
            <div class="flex flex-col flex-center m-r-20 blue">
              <div class="fz24 m-b-5">{{ approvedSaleOrderCount }}</div>
              <div>已审批</div>
            </div>
            <div class="flex flex-col flex-center green">
              <div class="fz24 m-b-5">{{ deliveredSaleOrderCount }}</div>
              <div>已出库</div>
            </div>
          </div>
        </div>
        <div class="el-card flex-1 h-full">
          <div class="m-t-6 m-l-6">销售退单概况</div>
          <div class="flex flex-center content-height">
            <div class="flex flex-col flex-center m-r-20 yellow">
              <div class="fz24 m-b-5">{{ pendingSaleReturnCount }}</div>
              <div>待审批</div>
            </div>
            <div class="flex flex-col flex-center blue m-r-20">
              <div class="fz24 m-b-5">{{ approvedSaleReturnCount }}</div>
              <div>已审批</div>
            </div>
            <div class="flex flex-col flex-center green">
              <div class="fz24 m-b-5">{{ deliveredSaleReturnCount }}</div>
              <div>已入库</div>
            </div>
          </div>
        </div>
      </div>
      <div class="flex-1 flex m-t-2">
        <div class="el-card flex-1 m-r-2 h-full">
          <div class="m-t-6 m-l-6">采购订单概况</div>
          <div class="flex flex-center content-height">
            <div class="flex flex-col flex-center m-r-20 yellow">
              <div class="fz24 m-b-5">{{ pendingPurchaseOrderCount }}</div>
              <div>待审批</div>
            </div>
            <div class="flex flex-col flex-center m-r-20 blue">
              <div class="fz24 m-b-5">{{ approvedPurchaseOrderCount }}</div>
              <div>已审批</div>
            </div>
            <div class="flex flex-col flex-center red">
              <div class="fz24 m-b-5">{{ deliveredPurchaseOrderCount }}</div>
              <div>已入库</div>
            </div>
          </div>
        </div>
        <div class="el-card flex-1 m-r-2 h-full">
          <div class="m-t-6 m-l-6">采购退单概况</div>
          <div class="flex flex-center content-height">
            <div class="flex flex-col flex-center m-r-20 yellow">
              <div class="fz24 m-b-5">{{ pendingPurchaseReturnCount }}</div>
              <div>待审批</div>
            </div>
            <div class="flex flex-col flex-center blue">
              <div class="fz24 m-b-5">{{ approvedPurchaseReturnCount }}</div>
              <div>已审批</div>
            </div>
          </div>
        </div>
        <div class="el-card flex-1 h-full">
          <div class="m-t-6 m-l-6">账单概况</div>
          <div class="flex flex-center content-height">
            <div class="flex flex-col flex-center m-r-20 yellow">
              <div class="fz24 m-b-5">8</div>
              <div>待审批</div>
            </div>
            <div class="flex flex-col flex-center m-r-20 green">
              <div class="fz24 m-b-5">8</div>
              <div>已收款</div>
            </div>
            <div class="flex flex-col flex-center blue">
              <div class="fz24 m-b-5">8</div>
              <div>已付款</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { getCategoryList } from "@/pages/productManagement/api/category";
import { getProductList } from "@/pages/productManagement/api/product";
import { getWarehouseList } from "@/pages/warehouseManagement/api/warehouse";
import { getAreaList } from "@/pages/warehouseManagement/api/area";
import { getShelfList } from "@/pages/warehouseManagement/api/shelf";
import { getCustomerList } from "@/pages/saleManagement/api/customer";
import { getOrderList } from "@/pages/saleManagement/api/order";
import { getReturnList } from "@/pages/saleManagement/api/return";
import { getSupplierList } from "@/pages/purchaseManagement/api/supplier";
import { getDemandList } from "@/pages/purchaseManagement/api/demand";
import { getOrderList as getPurchaseOrderList } from "@/pages/purchaseManagement/api/order";
import { getReturnList as getPurchaseReturnList } from "@/pages/purchaseManagement/api/return";
const categoryCount = ref(0);
const productCount = ref(0);
const warehouseCount = ref(0);
const areaCount = ref(0);
const shelfCount = ref(0);
const customerCount = ref(0);
const orderCount = ref(0);
const returnCount = ref(0);
const supplierCount = ref(0);
const demandCount = ref(0);
const purchaseOrderCount = ref(0);
const purchaseReturnCount = ref(0);
const pendingSaleOrderCount = ref(0);
const approvedSaleOrderCount = ref(0);
const deliveredSaleOrderCount = ref(0);
const pendingSaleReturnCount = ref(0);
const approvedSaleReturnCount = ref(0);
const deliveredSaleReturnCount = ref(0);
const pendingPurchaseOrderCount = ref(0);
const approvedPurchaseOrderCount = ref(0);
const deliveredPurchaseOrderCount = ref(0);
const pendingPurchaseReturnCount = ref(0);
const approvedPurchaseReturnCount = ref(0);

onMounted(async () => {
  const categoryRes: any = await getCategoryList();
  categoryCount.value = categoryRes?.data.length;
  const productRes: any = await getProductList({});
  productCount.value = productRes?.data.length;
  const warehouseRes: any = await getWarehouseList({});
  warehouseCount.value = warehouseRes?.data.length;
  const areaRes: any = await getAreaList({});
  areaCount.value = areaRes?.data.length;
  const shelfRes: any = await getShelfList({});
  shelfCount.value = shelfRes?.data.length;
  const customerRes: any = await getCustomerList();
  customerCount.value = customerRes?.data.length;
  const orderRes: any = await getOrderList({});
  orderCount.value = orderRes?.data.length;
  const returnRes: any = await getReturnList({});
  returnCount.value = returnRes?.data.length;
  const supplierRes: any = await getSupplierList();
  supplierCount.value = supplierRes?.data.length;
  const demandRes: any = await getDemandList();
  demandCount.value = demandRes?.data.length;
  const purchaseOrderRes: any = await getPurchaseOrderList({});
  purchaseOrderCount.value = purchaseOrderRes?.data.length;
  const purchaseReturnRes: any = await getPurchaseReturnList({});
  purchaseReturnCount.value = purchaseReturnRes?.data.length;
  const orderRes1: any = await getOrderList({ status: 1 });
  pendingSaleOrderCount.value = orderRes1?.data.length;
  const orderRes2: any = await getOrderList({ startStatus: 2, endStatus: 9 });
  approvedSaleOrderCount.value = orderRes2?.data.length;
  const orderRes3: any = await getOrderList({ startStatus: 5, endStatus: 9 });
  deliveredSaleOrderCount.value = orderRes3?.data.length;
  const returnRes2: any = await getReturnList({ status: 1 });
  pendingSaleReturnCount.value = returnRes2?.data.length;
  const returnRes3: any = await getReturnList({ startStatus: 2, endStatus: 5 });
  approvedSaleReturnCount.value = returnRes3?.data.length;
  const returnRes4: any = await getReturnList({ startStatus: 4, endStatus: 5 });
  deliveredSaleReturnCount.value = returnRes4?.data.length;
  const purchaseOrderRes1: any = await getPurchaseOrderList({ status: 1 });
  pendingPurchaseOrderCount.value = purchaseOrderRes1?.data.length;
  const purchaseOrderRes2: any = await getPurchaseOrderList({
    startStatus: 2,
    endStatus: 9,
  });
  pendingPurchaseOrderCount.value = purchaseOrderRes2?.data.length;
  const purchaseOrderRes3: any = await getPurchaseOrderList({
    startStatus: 2,
    endStatus: 5,
  });
  deliveredPurchaseOrderCount.value = purchaseOrderRes3?.data.length;
  const purchaseReturnRes2: any = await getPurchaseReturnList({ status: 1 });
  pendingPurchaseReturnCount.value = purchaseReturnRes2?.data.length;
  const purchaseReturnRes3: any = await getPurchaseReturnList({
    startStatus: 2,
    endStatus: 5,
  });
  approvedPurchaseReturnCount.value = purchaseReturnRes3?.data.length;
});
</script>
<style lang="scss" scoped>
@use "@@/assets/styles/size.scss" as *;
.content-height {
  height: calc(100% - zrem(50));
}
.blue {
  color: var(--el-color-primary);
}
.yellow {
  color: var(--el-color-warning);
}
.red {
  color: var(--el-color-danger);
}
.green {
  color: var(--el-color-success);
}
</style>
