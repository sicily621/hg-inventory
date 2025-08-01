/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80025 (8.0.25)
 Source Host           : localhost:3306
 Source Schema         : hg-inventory

 Target Server Type    : MySQL
 Target Server Version : 80025 (8.0.25)
 File Encoding         : 65001

 Date: 01/08/2025 17:39:43
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for hg_category
-- ----------------------------
DROP TABLE IF EXISTS `hg_category`;
CREATE TABLE `hg_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父分类ID，0表示顶级分类',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_category
-- ----------------------------

-- ----------------------------
-- Table structure for hg_collection_record
-- ----------------------------
DROP TABLE IF EXISTS `hg_collection_record`;
CREATE TABLE `hg_collection_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `receivable_id` bigint NOT NULL COMMENT '关联应收账款ID',
  `collection_date` date NOT NULL COMMENT '收款日期',
  `amount` decimal(10, 2) NOT NULL COMMENT '收款金额',
  `payment_method` tinyint NULL DEFAULT 1 COMMENT '收款方式(1-银行转账,2-现金,3-支票,4-其他)',
  `bank_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '银行名称',
  `transaction_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '交易号',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`record_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '收款记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_collection_record
-- ----------------------------

-- ----------------------------
-- Table structure for hg_customer
-- ----------------------------
DROP TABLE IF EXISTS `hg_customer`;
CREATE TABLE `hg_customer`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户名称',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `credit_level` int NULL DEFAULT 1 COMMENT '客户等级(1-5)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '客户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_customer
-- ----------------------------

-- ----------------------------
-- Table structure for hg_customer_receivable
-- ----------------------------
DROP TABLE IF EXISTS `hg_customer_receivable`;
CREATE TABLE `hg_customer_receivable`  (
  `receivable_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `order_id` bigint NOT NULL COMMENT '关联销售订单ID',
  `invoice_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发票号码',
  `invoice_date` date NULL DEFAULT NULL COMMENT '发票日期',
  `amount` decimal(10, 2) NOT NULL COMMENT '应收金额',
  `received_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已收金额',
  `balance` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '余额',
  `due_date` date NULL DEFAULT NULL COMMENT '到期日期',
  `collection_status` tinyint NULL DEFAULT 1 COMMENT '收款状态(1-未收款,2-部分收款,3-已收清)',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`receivable_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '客户应收账款表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_customer_receivable
-- ----------------------------

-- ----------------------------
-- Table structure for hg_department
-- ----------------------------
DROP TABLE IF EXISTS `hg_department`;
CREATE TABLE `hg_department`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '部门名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父部门ID',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '部门负责人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `department_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_department
-- ----------------------------

-- ----------------------------
-- Table structure for hg_employee
-- ----------------------------
DROP TABLE IF EXISTS `hg_employee`;
CREATE TABLE `hg_employee`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '员工编码',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '加密密码',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '真实姓名',
  `department_id` bigint NOT NULL COMMENT '部门ID',
  `position` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '职位',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` int NULL DEFAULT 1 COMMENT '状态(1-在职,0-离职)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `gender` int NULL DEFAULT NULL COMMENT '0女1男',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
  `del_flag` int NULL DEFAULT 0 COMMENT '0正常1删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1950095792504283139 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '员工表（用户表）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_employee
-- ----------------------------
INSERT INTO `hg_employee` VALUES (1950095792504283138, '', 'admin', 'Admin@123', 'zm', 0, '', '', '', 0, '2025-07-29 15:27:22', '2025-07-29 15:55:56', 0, 0, '', 0);

-- ----------------------------
-- Table structure for hg_inventory
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory`;
CREATE TABLE `hg_inventory`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `shelf_id` bigint NULL DEFAULT NULL COMMENT '货架ID',
  `current_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '当前库存数量',
  `available_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '可用库存数量',
  `locked_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '锁定数量(已分配未出库)',
  `min_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '最低库存预警值',
  `max_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '最高库存预警值',
  `last_update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_inventory
-- ----------------------------

-- ----------------------------
-- Table structure for hg_inventory_check
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_check`;
CREATE TABLE `hg_inventory_check`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '盘点单号',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `time` datetime NOT NULL COMMENT '盘点时间',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态(1-进行中,2-已完成)',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存盘点表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_inventory_check
-- ----------------------------

-- ----------------------------
-- Table structure for hg_inventory_check_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_check_detail`;
CREATE TABLE `hg_inventory_check_detail`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `check_id` int NOT NULL COMMENT '盘点单ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `shelf_id` int NULL DEFAULT NULL COMMENT '货架ID',
  `system_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '系统库存数量',
  `actual_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '实际盘点数量',
  `difference` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '差异数量',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存盘点明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_inventory_check_detail
-- ----------------------------

-- ----------------------------
-- Table structure for hg_inventory_history
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_history`;
CREATE TABLE `hg_inventory_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `shelf_id` bigint NULL DEFAULT NULL COMMENT '货架ID',
  `operation_type` int NOT NULL COMMENT '操作类型(1-采购入库,2-销售出库,3-采购退货,4-销售退货,5-库存调整)',
  `document_id` bigint NOT NULL COMMENT '关联单据ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '变动数量(正数表示增加，负数表示减少)',
  `operator_id` bigint NOT NULL COMMENT '操作人ID',
  `operation_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_inventory_history
-- ----------------------------

-- ----------------------------
-- Table structure for hg_login_log
-- ----------------------------
DROP TABLE IF EXISTS `hg_login_log`;
CREATE TABLE `hg_login_log`  (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `login_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  `login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '登录IP',
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'User-Agent信息',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态(1-成功,0-失败)',
  `message` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '登录信息',
  PRIMARY KEY (`log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户登录日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_login_log
-- ----------------------------

-- ----------------------------
-- Table structure for hg_payment_record
-- ----------------------------
DROP TABLE IF EXISTS `hg_payment_record`;
CREATE TABLE `hg_payment_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `payable_id` bigint NOT NULL COMMENT '关联应付账款ID',
  `payment_date` date NOT NULL COMMENT '付款日期',
  `amount` decimal(10, 2) NOT NULL COMMENT '付款金额',
  `payment_method` tinyint NULL DEFAULT 1 COMMENT '付款方式(1-银行转账,2-现金,3-支票,4-其他)',
  `bank_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '银行名称',
  `transaction_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '交易号',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`record_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '付款记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_payment_record
-- ----------------------------

-- ----------------------------
-- Table structure for hg_permission
-- ----------------------------
DROP TABLE IF EXISTS `hg_permission`;
CREATE TABLE `hg_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '权限名称',
  `module_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '所属模块编码',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父权限ID',
  `url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '关联URL',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '权限描述',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `permission_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_permission
-- ----------------------------
INSERT INTO `hg_permission` VALUES (1, '商品管理', 'product', 0, '/product', NULL, '2025-07-17 17:30:29', '2025-07-17 17:30:29', NULL);
INSERT INTO `hg_permission` VALUES (2, '商品查看', 'product', 1, '/product/list', NULL, '2025-07-17 17:30:29', '2025-07-17 17:30:29', NULL);
INSERT INTO `hg_permission` VALUES (3, '商品新增', 'product', 1, '/product/add', NULL, '2025-07-17 17:30:29', '2025-07-17 17:30:29', NULL);
INSERT INTO `hg_permission` VALUES (4, '供应商管理', 'supplier', 0, '/supplier', NULL, '2025-07-17 17:30:29', '2025-07-17 17:30:29', NULL);
INSERT INTO `hg_permission` VALUES (5, '采购订单管理', 'purchase', 0, '/purchase/order', NULL, '2025-07-17 17:30:29', '2025-07-17 17:30:29', NULL);
INSERT INTO `hg_permission` VALUES (6, '销售订单管理', 'sales', 0, '/sales/order', NULL, '2025-07-17 17:30:29', '2025-07-17 17:30:29', NULL);
INSERT INTO `hg_permission` VALUES (7, '库存查询', 'inventory', 0, '/inventory/query', NULL, '2025-07-17 17:30:29', '2025-07-17 17:30:29', NULL);
INSERT INTO `hg_permission` VALUES (8, '库存调整', 'inventory', 0, '/inventory/adjust', NULL, '2025-07-17 17:30:29', '2025-07-17 17:30:29', NULL);
INSERT INTO `hg_permission` VALUES (9, '财务管理', 'finance', 0, '/finance', NULL, '2025-07-17 17:30:29', '2025-07-17 17:30:29', NULL);

-- ----------------------------
-- Table structure for hg_product
-- ----------------------------
DROP TABLE IF EXISTS `hg_product`;
CREATE TABLE `hg_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
  `category_id` bigint NOT NULL COMMENT '分类ID',
  `purchase_price` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '采购价',
  `retail_price` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '零售价',
  `specification` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '规格',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '单位',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌',
  `barcode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '条形码',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1949752573690052611 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_product
-- ----------------------------
INSERT INTO `hg_product` VALUES (1949752573690052610, '', '111', 0, 0.00, 0.00, '', '', '', '', '2025-07-28 16:43:33', '2025-07-28 16:43:33', 0);

-- ----------------------------
-- Table structure for hg_purchase_order
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_order`;
CREATE TABLE `hg_purchase_order`  (
  `order_id` bigint NOT NULL AUTO_INCREMENT,
  `order_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号',
  `supplier_id` bigint NOT NULL COMMENT '供应商ID',
  `employee_id` bigint NOT NULL COMMENT '采购人员ID',
  `order_date` datetime NOT NULL COMMENT '订单日期',
  `expected_date` datetime NULL DEFAULT NULL COMMENT '预计到货时间',
  `actual_date` datetime NULL DEFAULT NULL COMMENT '实际到货时间',
  `order_status` tinyint NULL DEFAULT 1 COMMENT '订单状态(1-待审核,2-已审核,3-已发货,4-已完成,5-已取消)',
  `total_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '订单总金额',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`order_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_purchase_order
-- ----------------------------

-- ----------------------------
-- Table structure for hg_purchase_order_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_order_detail`;
CREATE TABLE `hg_purchase_order_detail`  (
  `detail_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '采购数量',
  `price` decimal(10, 2) NOT NULL COMMENT '采购单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `received_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已收货数量',
  `return_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已退货数量',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '入库仓库ID',
  `shelf_id` bigint NULL DEFAULT NULL COMMENT '入库货架ID',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`detail_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_purchase_order_detail
-- ----------------------------

-- ----------------------------
-- Table structure for hg_purchase_receipt
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_receipt`;
CREATE TABLE `hg_purchase_receipt`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '入库单号',
  `order_id` bigint NOT NULL COMMENT '关联采购订单ID',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `receipt_date` datetime NOT NULL COMMENT '入库日期',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `status` int NULL DEFAULT 1 COMMENT '状态(1-待审核,2-已完成)',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购入库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_purchase_receipt
-- ----------------------------

-- ----------------------------
-- Table structure for hg_purchase_receipt_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_receipt_detail`;
CREATE TABLE `hg_purchase_receipt_detail`  (
  `detail_id` bigint NOT NULL AUTO_INCREMENT,
  `receipt_id` bigint NOT NULL COMMENT '入库单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '入库数量',
  `price` decimal(10, 2) NOT NULL COMMENT '入库单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `shelf_id` bigint NULL DEFAULT NULL COMMENT '存放货架ID',
  `batch_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '批次号',
  `production_date` date NULL DEFAULT NULL COMMENT '生产日期',
  `expiration_date` date NULL DEFAULT NULL COMMENT '过期日期',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`detail_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购入库明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_purchase_receipt_detail
-- ----------------------------

-- ----------------------------
-- Table structure for hg_purchase_return
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_return`;
CREATE TABLE `hg_purchase_return`  (
  `return_id` bigint NOT NULL AUTO_INCREMENT,
  `return_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '退货单号',
  `order_id` bigint NOT NULL COMMENT '关联采购订单ID',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `return_date` date NOT NULL COMMENT '退货日期',
  `supplier_id` bigint NOT NULL COMMENT '供应商ID',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态(1-待审核,2-已审核,3-已完成)',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`return_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购退货表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_purchase_return
-- ----------------------------

-- ----------------------------
-- Table structure for hg_purchase_return_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_return_detail`;
CREATE TABLE `hg_purchase_return_detail`  (
  `detail_id` bigint NOT NULL AUTO_INCREMENT,
  `return_id` bigint NOT NULL COMMENT '退货单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '退货数量',
  `price` decimal(10, 2) NOT NULL COMMENT '退货单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退货原因',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`detail_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购退货明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_purchase_return_detail
-- ----------------------------

-- ----------------------------
-- Table structure for hg_role
-- ----------------------------
DROP TABLE IF EXISTS `hg_role`;
CREATE TABLE `hg_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色名称',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色编码',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色描述',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态(1-启用,0-禁用)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `role_name`(`name` ASC) USING BTREE,
  UNIQUE INDEX `role_code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_role
-- ----------------------------
INSERT INTO `hg_role` VALUES (1, '系统管理员', 'sys_admin', '拥有系统所有权限', 1, '2025-07-17 17:30:15', '2025-07-17 17:30:15', NULL);
INSERT INTO `hg_role` VALUES (2, '仓库管理员', 'warehouse_admin', '负责仓库管理和库存操作', 1, '2025-07-17 17:30:15', '2025-07-17 17:30:15', NULL);
INSERT INTO `hg_role` VALUES (3, '库存人员', 'inventory_staff', '负责库存盘点和调整', 1, '2025-07-17 17:30:15', '2025-07-17 17:30:15', NULL);
INSERT INTO `hg_role` VALUES (4, '库存经理', 'inventory_manager', '负责库存报表和决策', 1, '2025-07-17 17:30:15', '2025-07-17 17:30:15', NULL);
INSERT INTO `hg_role` VALUES (5, '销售人员', 'sales_staff', '负责销售订单和客户维护', 1, '2025-07-17 17:30:15', '2025-07-17 17:30:15', NULL);
INSERT INTO `hg_role` VALUES (6, '销售经理', 'sales_manager', '负责销售团队管理和报表', 1, '2025-07-17 17:30:15', '2025-07-17 17:30:15', NULL);
INSERT INTO `hg_role` VALUES (7, '财务人员', 'finance_staff', '负责财务管理和报表', 1, '2025-07-17 17:30:15', '2025-07-17 17:30:15', NULL);

-- ----------------------------
-- Table structure for hg_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `hg_role_permission`;
CREATE TABLE `hg_role_permission`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  `id` bigint NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`) USING BTREE,
  INDEX `permission_id`(`permission_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色权限关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_role_permission
-- ----------------------------
INSERT INTO `hg_role_permission` VALUES (1, 1, '2025-07-17 17:30:50', NULL, 0);
INSERT INTO `hg_role_permission` VALUES (1, 2, '2025-07-17 17:30:50', NULL, 0);
INSERT INTO `hg_role_permission` VALUES (1, 3, '2025-07-17 17:30:50', NULL, 0);
INSERT INTO `hg_role_permission` VALUES (1, 4, '2025-07-17 17:30:50', NULL, 0);
INSERT INTO `hg_role_permission` VALUES (1, 5, '2025-07-17 17:30:50', NULL, 0);
INSERT INTO `hg_role_permission` VALUES (1, 6, '2025-07-17 17:30:50', NULL, 0);
INSERT INTO `hg_role_permission` VALUES (1, 7, '2025-07-17 17:30:50', NULL, 0);
INSERT INTO `hg_role_permission` VALUES (1, 8, '2025-07-17 17:30:50', NULL, 0);
INSERT INTO `hg_role_permission` VALUES (1, 9, '2025-07-17 17:30:50', NULL, 0);

-- ----------------------------
-- Table structure for hg_sales_order
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_order`;
CREATE TABLE `hg_sales_order`  (
  `order_id` bigint NOT NULL AUTO_INCREMENT,
  `order_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `employee_id` bigint NOT NULL COMMENT '销售人员ID',
  `order_date` date NOT NULL COMMENT '订单日期',
  `expected_date` date NULL DEFAULT NULL COMMENT '预计交货日期',
  `actual_date` date NULL DEFAULT NULL COMMENT '实际交货日期',
  `order_status` tinyint NULL DEFAULT 1 COMMENT '订单状态(1-待审核,2-已审核,3-已发货,4-已完成,5-已取消)',
  `total_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '订单总金额',
  `discount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '折扣金额',
  `tax` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '税额',
  `final_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '最终金额',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_sales_order
-- ----------------------------

-- ----------------------------
-- Table structure for hg_sales_order_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_order_detail`;
CREATE TABLE `hg_sales_order_detail`  (
  `detail_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '销售数量',
  `price` decimal(10, 2) NOT NULL COMMENT '销售单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `shipped_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已发货数量',
  `return_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已退货数量',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '出库仓库ID',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`detail_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售订单明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_sales_order_detail
-- ----------------------------

-- ----------------------------
-- Table structure for hg_sales_return
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_return`;
CREATE TABLE `hg_sales_return`  (
  `return_id` int NOT NULL AUTO_INCREMENT,
  `return_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '退货单号',
  `order_id` int NOT NULL COMMENT '关联销售订单ID',
  `employee_id` int NOT NULL COMMENT '操作员工ID',
  `return_date` date NOT NULL COMMENT '退货日期',
  `customer_id` int NOT NULL COMMENT '客户ID',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态(1-待审核,2-已审核,3-已完成)',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`return_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售退货表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_sales_return
-- ----------------------------

-- ----------------------------
-- Table structure for hg_sales_return_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_return_detail`;
CREATE TABLE `hg_sales_return_detail`  (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `return_id` int NOT NULL COMMENT '退货单ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '退货数量',
  `price` decimal(10, 2) NOT NULL COMMENT '退货单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退货原因',
  `warehouse_id` int NULL DEFAULT NULL COMMENT '入库仓库ID',
  `shelf_id` int NULL DEFAULT NULL COMMENT '存放货架ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`detail_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售退货明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_sales_return_detail
-- ----------------------------

-- ----------------------------
-- Table structure for hg_sales_shipment
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_shipment`;
CREATE TABLE `hg_sales_shipment`  (
  `shipment_id` bigint NOT NULL AUTO_INCREMENT,
  `shipment_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '出库单号',
  `order_id` bigint NOT NULL COMMENT '关联销售订单ID',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `shipment_date` date NOT NULL COMMENT '出库日期',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态(1-待审核,2-已完成)',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`shipment_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售出库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_sales_shipment
-- ----------------------------

-- ----------------------------
-- Table structure for hg_sales_shipment_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_shipment_detail`;
CREATE TABLE `hg_sales_shipment_detail`  (
  `detail_id` bigint NOT NULL AUTO_INCREMENT,
  `shipment_id` bigint NOT NULL COMMENT '出库单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '出库数量',
  `price` decimal(10, 2) NOT NULL COMMENT '出库单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `shelf_id` bigint NULL DEFAULT NULL COMMENT '来源货架ID',
  `batch_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '批次号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`detail_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售出库明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_sales_shipment_detail
-- ----------------------------

-- ----------------------------
-- Table structure for hg_shelf
-- ----------------------------
DROP TABLE IF EXISTS `hg_shelf`;
CREATE TABLE `hg_shelf`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `area_id` bigint NOT NULL COMMENT '所属区域ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '货架编码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '货架名称',
  `layer_count` int NULL DEFAULT 1 COMMENT '层数',
  `max_capacity` decimal(10, 2) NULL DEFAULT NULL COMMENT '最大容量(kg)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '货架表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_shelf
-- ----------------------------

-- ----------------------------
-- Table structure for hg_supplier
-- ----------------------------
DROP TABLE IF EXISTS `hg_supplier`;
CREATE TABLE `hg_supplier`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '供应商编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '供应商名称',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `supplier_code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_supplier
-- ----------------------------

-- ----------------------------
-- Table structure for hg_supplier_payable
-- ----------------------------
DROP TABLE IF EXISTS `hg_supplier_payable`;
CREATE TABLE `hg_supplier_payable`  (
  `payable_id` bigint NOT NULL AUTO_INCREMENT,
  `supplier_id` bigint NOT NULL COMMENT '供应商ID',
  `order_id` bigint NOT NULL COMMENT '关联采购订单ID',
  `invoice_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发票号码',
  `invoice_date` date NULL DEFAULT NULL COMMENT '发票日期',
  `amount` decimal(10, 2) NOT NULL COMMENT '应付金额',
  `paid_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已付金额',
  `balance` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '余额',
  `due_date` date NULL DEFAULT NULL COMMENT '到期日期',
  `payment_status` tinyint NULL DEFAULT 1 COMMENT '付款状态(1-未付款,2-部分付款,3-已付清)',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payable_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商应付账款表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_supplier_payable
-- ----------------------------

-- ----------------------------
-- Table structure for hg_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `hg_warehouse`;
CREATE TABLE `hg_warehouse`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库名称',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `area` decimal(10, 2) NULL DEFAULT NULL COMMENT '面积(m²)',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '负责人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_warehouse
-- ----------------------------

-- ----------------------------
-- Table structure for hg_warehouse_area
-- ----------------------------
DROP TABLE IF EXISTS `hg_warehouse_area`;
CREATE TABLE `hg_warehouse_area`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `warehouse_id` bigint NOT NULL COMMENT '所属仓库ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '区域名称',
  `type` int NULL DEFAULT 1 COMMENT '区域类型(1-存储区,2-收货区,3-发货区)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库区域表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hg_warehouse_area
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
