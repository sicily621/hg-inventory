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

 Date: 25/09/2025 17:59:12
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for hg_account
-- ----------------------------
DROP TABLE IF EXISTS `hg_account`;
CREATE TABLE `hg_account`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '关联订单ID',
  `related_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单编码或者退单编码',
  `related_entity_type` int NULL DEFAULT NULL COMMENT '往来单位类型（1 供应商 2 客户）',
  `related_entity_id` bigint NULL DEFAULT NULL COMMENT '供应商ID或者客户ID',
  `type` int NOT NULL COMMENT '类型(1-- 采购支付 2--采购退款 3--销售收入 4--销售退款)',
  `amount` decimal(10, 2) NOT NULL COMMENT '收款金额',
  `payment_method` tinyint NULL DEFAULT NULL COMMENT '收款方式(1-银行转账,2-现金,3-支票,4-其他)',
  `bank_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '银行名称',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '操作员工ID',
  `status` int NULL DEFAULT NULL COMMENT '状态(1--待审核，2--已审核，3--已支付)',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970049739118804994 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '收款记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_account
-- ----------------------------
INSERT INTO `hg_account` VALUES (1970038667502616578, 1970038499210362882, 'purchaseOrder20250922161221300', 1, 1953021744750215169, 1, 222.00, NULL, NULL, 1950095792504283138, 1, '', '2025-09-22 16:13:15', '2025-09-22 18:22:55', 0);
INSERT INTO `hg_account` VALUES (1970049739118804993, 1970038499210362882, 'purchaseReturn20250922161445362', 1, 1953021744750215169, 2, 81.00, NULL, NULL, 1950095792504283138, 3, '', '2025-09-22 16:57:14', '2025-09-22 18:23:23', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1952678710640549890 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_category
-- ----------------------------
INSERT INTO `hg_category` VALUES (1952678553081520129, '食品', 0, '2025-08-05 18:30:21', '2025-08-05 18:30:21', 0);
INSERT INTO `hg_category` VALUES (1952678599009148929, '生活用品', 0, '2025-08-05 18:30:32', '2025-08-05 18:30:32', 0);
INSERT INTO `hg_category` VALUES (1952678628172144642, '米', 1952678553081520129, '2025-08-05 18:30:39', '2025-08-05 18:30:39', 0);
INSERT INTO `hg_category` VALUES (1952678652444581890, '面', 1952678553081520129, '2025-08-05 18:30:44', '2025-08-05 18:30:44', 0);
INSERT INTO `hg_category` VALUES (1952678680789688322, '粮', 1952678553081520129, '2025-08-05 18:30:51', '2025-08-05 18:30:51', 0);
INSERT INTO `hg_category` VALUES (1952678710640549889, '油', 1952678553081520129, '2025-08-05 18:30:58', '2025-08-05 18:30:58', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1953018819353198595 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '客户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_customer
-- ----------------------------
INSERT INTO `hg_customer` VALUES (1953018819353198594, '客户1', '17312021111', 'sasas', '1213@163.com', 1, '2025-08-06 17:02:27', '2025-08-06 17:02:33', '小明', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1952987749664636930 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_department
-- ----------------------------
INSERT INTO `hg_department` VALUES (1952262586321022978, '销售部', 0, 0, '2025-08-04 14:57:27', '2025-08-06 14:59:11', 0);
INSERT INTO `hg_department` VALUES (1952264115023196161, '人事部', 0, 0, '2025-08-04 15:03:31', '2025-08-04 15:03:31', 0);
INSERT INTO `hg_department` VALUES (1952265346936418305, '销售小组1', 1952262586321022978, 0, '2025-08-04 15:08:25', '2025-08-04 15:43:05', 0);
INSERT INTO `hg_department` VALUES (1952275260559798273, '销售小组2', 1952262586321022978, 0, '2025-08-04 15:47:48', '2025-08-04 15:47:48', 0);
INSERT INTO `hg_department` VALUES (1952276451498864642, '采购部', 0, 0, '2025-08-04 15:52:32', '2025-08-04 15:53:04', 0);
INSERT INTO `hg_department` VALUES (1952276503030083586, '采购小组1', 1952276451498864642, 0, '2025-08-04 15:52:45', '2025-08-04 15:52:45', 0);
INSERT INTO `hg_department` VALUES (1952276547581980674, '采购小组2', 1952276451498864642, 0, '2025-08-04 15:52:55', '2025-08-04 15:52:55', 0);
INSERT INTO `hg_department` VALUES (1952276768491778049, '仓库管理部', 0, 0, '2025-08-04 15:53:48', '2025-08-04 15:53:48', 0);
INSERT INTO `hg_department` VALUES (1952276819339325441, '财务部', 0, 0, '2025-08-04 15:54:00', '2025-08-04 15:54:00', 0);
INSERT INTO `hg_department` VALUES (1952987749664636929, '11', 0, 0, '2025-08-06 14:58:59', '2025-08-06 14:59:05', 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1954553753768919042 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '员工表（用户表）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_employee
-- ----------------------------
INSERT INTO `hg_employee` VALUES (1950095792504283138, '001', 'admin', '0f2797f2182804d0cc7f0b85d254c146', 'zm', 0, '', '17312124545', '123@163.com', 0, '2025-07-29 15:27:22', '2025-08-11 10:29:37', 1952303554671882242, 0, '', 0);
INSERT INTO `hg_employee` VALUES (1952309334494097410, '004', 'xiaoliu', '0f2797f2182804d0cc7f0b85d254c146', '小刘', 1952264115023196161, '', '17300001111', '123@163.com', 1, '2025-08-04 18:03:12', '2025-08-10 22:48:01', 1952580037491453953, 1, 'defaultAvatar.png', 0);
INSERT INTO `hg_employee` VALUES (1954553753768919041, '004', '采购经理', '0f2797f2182804d0cc7f0b85d254c146', '刘xx', 1952276451498864642, '', '17311112222', '123@163.com', 1, '2025-08-10 22:41:43', '2025-08-10 22:41:43', 1, 1, 'defaultAvatar.png', 0);

-- ----------------------------
-- Table structure for hg_inventory
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory`;
CREATE TABLE `hg_inventory`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `area_id` bigint NOT NULL COMMENT '区域ID',
  `shelf_id` bigint NOT NULL COMMENT '货架ID',
  `quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '当前库存数量',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970038666529538051 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_inventory
-- ----------------------------
INSERT INTO `hg_inventory` VALUES (1970038666403708930, 1954455089243312130, 1952918491823816705, 1952986337115324418, 1953005820022308865, 7.00, '2025-09-22 16:13:14', '2025-09-25 17:36:32', 0);
INSERT INTO `hg_inventory` VALUES (1970038666529538050, 1954455374657310721, 1952918491823816705, 1952986337115324418, 1953005982987796481, 0.00, '2025-09-22 16:13:14', '2025-09-22 16:57:14', 0);

-- ----------------------------
-- Table structure for hg_inventory_check
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_check`;
CREATE TABLE `hg_inventory_check`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '盘点单号',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态(1-进行中,2-已完成)',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1971106136380047363 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存盘点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_inventory_check
-- ----------------------------
INSERT INTO `hg_inventory_check` VALUES (1971106136380047362, 'inventoryCheck20250925145430564', 1952918491823816705, 1950095792504283138, 2, '', '2025-09-25 14:54:59', '2025-09-25 17:21:21', 0);

-- ----------------------------
-- Table structure for hg_inventory_check_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_check_detail`;
CREATE TABLE `hg_inventory_check_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `check_id` bigint NOT NULL COMMENT '盘点单ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '商品分类ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `area_id` bigint NULL DEFAULT NULL COMMENT '区域ID',
  `shelf_id` bigint NULL DEFAULT NULL COMMENT '货架ID',
  `system_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '系统库存数量',
  `actual_quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '实际盘点数量',
  `difference` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '差异数量',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1971143055944089603 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存盘点明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_inventory_check_detail
-- ----------------------------
INSERT INTO `hg_inventory_check_detail` VALUES (1971106137562841089, 1971106136380047362, 1952678553081520129, 1954455089243312130, 1952986337115324418, 1953005820022308865, 3.00, 1.00, 0.00, '', '2025-09-25 14:54:59', '2025-09-25 14:54:59', 1);
INSERT INTO `hg_inventory_check_detail` VALUES (1971143055944089602, 1971106136380047362, 1952678553081520129, 1954455089243312130, 1952986337115324418, 1953005820022308865, 3.00, 7.00, 4.00, '', '2025-09-25 14:54:59', '2025-09-25 14:54:59', 0);

-- ----------------------------
-- Table structure for hg_inventory_history
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_history`;
CREATE TABLE `hg_inventory_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `area_id` bigint NULL DEFAULT NULL COMMENT '区域ID',
  `shelf_id` bigint NULL DEFAULT NULL COMMENT '货架ID',
  `type` int NOT NULL COMMENT '操作类型(1-采购入库,2-销售出库,3-采购退货,4-销售退货,5-库存调整)',
  `document_id` bigint NULL DEFAULT NULL COMMENT '关联单据ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '变动数量(正数表示增加，负数表示减少)',
  `employee_id` bigint NOT NULL COMMENT '操作人ID',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1971143056397074434 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存流水表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_inventory_history
-- ----------------------------
INSERT INTO `hg_inventory_history` VALUES (1970038667179655170, 1954455089243312130, 1952918491823816705, 1952986337115324418, 1953005820022308865, 1, NULL, 3.00, 1950095792504283138, NULL, '2025-09-22 16:13:14', '2025-09-22 16:13:14', 0);
INSERT INTO `hg_inventory_history` VALUES (1970038667179655171, 1954455374657310721, 1952918491823816705, 1952986337115324418, 1953005982987796481, 1, NULL, 3.00, 1950095792504283138, NULL, '2025-09-22 16:13:14', '2025-09-22 16:13:14', 0);
INSERT INTO `hg_inventory_history` VALUES (1970049738791649281, 1954455374657310721, 1952918491823816705, 1952986337115324418, 1953005982987796481, 3, NULL, 3.00, 1950095792504283138, NULL, '2025-09-22 16:57:14', '2025-09-22 16:57:14', 0);
INSERT INTO `hg_inventory_history` VALUES (1971143056397074433, 1954455089243312130, 1952918491823816705, 1952986337115324418, 1953005820022308865, 5, NULL, 7.00, 1950095792504283138, NULL, '2025-09-25 17:21:41', '2025-09-25 17:21:41', 0);

-- ----------------------------
-- Table structure for hg_inventory_receipt
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_receipt`;
CREATE TABLE `hg_inventory_receipt`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '入库单号',
  `order_id` bigint NOT NULL COMMENT '关联采购订单ID',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970038666013638658 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '入库表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_inventory_receipt
-- ----------------------------
INSERT INTO `hg_inventory_receipt` VALUES (1970038666013638657, 'inventoryReceipt20250922161250786', 1970038499210362882, 1950095792504283138, '', '2025-09-22 16:13:14', '2025-09-22 16:13:14', 0);

-- ----------------------------
-- Table structure for hg_inventory_receipt_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_receipt_detail`;
CREATE TABLE `hg_inventory_receipt_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `receipt_id` bigint NOT NULL COMMENT '入库单ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '商品分类ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '入库数量',
  `price` decimal(10, 2) NOT NULL COMMENT '入库单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `area_id` bigint NULL DEFAULT NULL COMMENT '区域ID',
  `shelf_id` bigint NULL DEFAULT NULL COMMENT '存放货架ID',
  `batch_number` int NULL DEFAULT NULL COMMENT '批次号',
  `production_date` date NULL DEFAULT NULL COMMENT '生产日期',
  `expiration_date` date NULL DEFAULT NULL COMMENT '过期日期',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970038666722476035 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '入库明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_inventory_receipt_detail
-- ----------------------------
INSERT INTO `hg_inventory_receipt_detail` VALUES (1970038666722476033, 1970038666013638657, 1952678553081520129, 1954455089243312130, 3.00, 47.00, 141.00, 1952918491823816705, 1952986337115324418, 1953005820022308865, 1, NULL, NULL, '2025-09-22 16:13:14', '2025-09-22 16:13:14', 0);
INSERT INTO `hg_inventory_receipt_detail` VALUES (1970038666722476034, 1970038666013638657, 1952678553081520129, 1954455374657310721, 3.00, 27.00, 81.00, 1952918491823816705, 1952986337115324418, 1953005982987796481, 1, NULL, NULL, '2025-09-22 16:13:14', '2025-09-22 16:13:14', 0);

-- ----------------------------
-- Table structure for hg_inventory_shipment
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_shipment`;
CREATE TABLE `hg_inventory_shipment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '出库单号',
  `order_id` bigint NOT NULL COMMENT '关联销售订单ID',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970049737764044802 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_inventory_shipment
-- ----------------------------
INSERT INTO `hg_inventory_shipment` VALUES (1970049737764044801, 'inventoryShipment20250922165700653', 1970038499210362882, 1950095792504283138, '', '2025-09-22 16:57:14', '2025-09-22 16:57:14', 0);

-- ----------------------------
-- Table structure for hg_inventory_shipment_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_inventory_shipment_detail`;
CREATE TABLE `hg_inventory_shipment_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shipment_id` bigint NOT NULL COMMENT '出库单ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '商品分类ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '出库数量',
  `price` decimal(10, 2) NOT NULL COMMENT '出库单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `area_id` bigint NULL DEFAULT NULL COMMENT '区域ID',
  `shelf_id` bigint NULL DEFAULT NULL COMMENT '来源货架ID',
  `batch_number` int NULL DEFAULT NULL COMMENT '批次号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970049738271555586 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_inventory_shipment_detail
-- ----------------------------
INSERT INTO `hg_inventory_shipment_detail` VALUES (1970049738271555585, 1970049737764044801, 1952678553081520129, 1954455374657310721, 3.00, 27.00, 81.00, 1952918491823816705, 1952986337115324418, 1953005982987796481, 1, '2025-09-22 16:57:14', '2025-09-22 16:57:14', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户登录日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_login_log
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
  `action` int NOT NULL DEFAULT 1 COMMENT '操作类型 1 view、2 add、3 edit、4 delete、5 approve',
  `type` int NOT NULL DEFAULT 1 COMMENT '权限类型 1 菜单级别 2 按钮级别',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `permission_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970053380479320067 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_permission
-- ----------------------------
INSERT INTO `hg_permission` VALUES (1952561113785896961, '员工管理菜单', 'employeeManagement', 0, '/employeeManagement', '', '2025-08-05 10:43:41', '2025-08-05 17:09:01', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1952561423342309377, '部门管理', 'department', 1952561113785896961, '/employeeManagement/department', '', '2025-08-05 10:44:55', '2025-08-05 10:44:55', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1952562158385696769, '部门添加', 'department', 1952561423342309377, '/employeeManagement/department', '', '2025-08-05 10:47:50', '2025-08-05 10:49:01', 0, 2, 2);
INSERT INTO `hg_permission` VALUES (1952562778312216578, '部门删除', 'department', 1952561423342309377, '/employeeManagement/department', '', '2025-08-05 10:50:18', '2025-08-05 10:50:18', 0, 4, 2);
INSERT INTO `hg_permission` VALUES (1952658215757062146, '角色管理', 'role', 1952561113785896961, '/employeeManagement/role', '', '2025-08-05 17:09:32', '2025-08-05 17:09:46', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1952658439359602690, '员工管理页面', 'employee', 1952561113785896961, '/employeeManagement/employee', '', '2025-08-05 17:10:25', '2025-08-05 17:10:39', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1952658612836016129, '权限管理', 'permission', 1952561113785896961, '/employeeManagement/permission', '', '2025-08-05 17:11:07', '2025-08-05 17:11:35', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1954554256779214850, '采购管理', 'purchaseManagement', 0, 'purchaseManagement', '', '2025-08-10 22:43:43', '2025-08-10 22:43:43', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1954554607104262146, '采购需求', 'purchaseDemand', 1954554256779214850, 'purchaseManagement/demand', '', '2025-08-10 22:45:07', '2025-08-11 16:32:24', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1954554993114447874, '审批采购需求', 'purchaseDemand', 1954554607104262146, 'purchaseManagement/demand', '', '2025-08-10 22:46:39', '2025-08-11 16:32:32', 0, 5, 2);
INSERT INTO `hg_permission` VALUES (1954833520101867522, '采购订单', 'purchaseOrder', 1954554256779214850, 'purchaseManagement/purchaseorder', '', '2025-08-11 17:13:25', '2025-08-11 23:07:40', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1954834079097733121, '审批采购订单', 'purchaseOrder', 1954833520101867522, 'purchaseManagement/purchaseorder', '', '2025-08-11 17:15:38', '2025-08-11 23:07:46', 0, 5, 2);
INSERT INTO `hg_permission` VALUES (1954922598694195201, '采购退单', 'purchaseReturn', 1954554256779214850, 'purchaseManagemen/purchaseReturn', '', '2025-08-11 23:07:23', '2025-08-11 23:07:23', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1954922913359269890, '审批采购退单', 'purchaseReturn', 1954922598694195201, 'purchaseManagemen/purchaseReturn', '', '2025-08-11 23:08:38', '2025-08-11 23:08:38', 0, 5, 2);
INSERT INTO `hg_permission` VALUES (1957435491113308162, '销售管理', 'saleManagement', 0, 'saleManagement', '', '2025-08-18 21:32:43', '2025-08-18 21:33:24', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1957435627012952065, '销售订单', 'salesOrder', 1957435491113308162, 'saleManagement/salesOrder', '', '2025-08-18 21:33:16', '2025-08-18 21:33:16', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1957435790586613762, '审批', 'salesOrder', 1957435627012952065, 'saleManagement/salesOrder', '', '2025-08-18 21:33:55', '2025-08-18 21:33:55', 0, 5, 2);
INSERT INTO `hg_permission` VALUES (1957436138843869185, '销售退单', 'salesReturn', 1957435491113308162, 'saleManagement/salesReturn', '', '2025-08-18 21:35:18', '2025-08-18 21:35:18', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1957436430557712385, '审批销售退单', 'salesReturn', 1957436138843869185, 'saleManagement/salesReturn', '', '2025-08-18 21:36:27', '2025-08-18 21:36:27', 0, 5, 2);
INSERT INTO `hg_permission` VALUES (1970053250455896065, '账单管理', 'accountManagement', 0, 'accountManagement', '', '2025-09-22 17:11:11', '2025-09-22 17:11:11', 0, 1, 1);
INSERT INTO `hg_permission` VALUES (1970053380479320066, '账单审批', 'account', 1970053250455896065, 'accountManagement/account', '', '2025-09-22 17:11:42', '2025-09-22 17:11:42', 0, 5, 2);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1954539014309384194 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_product
-- ----------------------------
INSERT INTO `hg_product` VALUES (1949752573690052610, '', '111', 0, 0.00, 0.00, '', '', '', '', '2025-07-28 16:43:33', '2025-08-10 16:07:50', 1);
INSERT INTO `hg_product` VALUES (1954455089243312130, '001', '大米', 1952678628172144642, 50.00, 75.00, '2000kg', '袋', '福临门', 'dami001', '2025-08-10 16:09:40', '2025-08-10 16:09:40', 0);
INSERT INTO `hg_product` VALUES (1954455374657310721, '002', '小米', 1952678628172144642, 30.00, 40.00, '500g', '袋', '福临门', '002', '2025-08-10 16:10:48', '2025-08-10 16:10:48', 0);
INSERT INTO `hg_product` VALUES (1954455665985277953, '003', '大豆油', 1952678710640549889, 50.00, 60.00, '5KG', '桶', '中粮', '003', '2025-08-10 16:11:57', '2025-08-10 16:33:24', 0);
INSERT INTO `hg_product` VALUES (1954539014309384193, '004', '牙膏', 1952678599009148929, 10.00, 20.00, '100g', '支', '黑人', 'yagao004', '2025-08-10 21:43:09', '2025-08-10 21:43:09', 0);

-- ----------------------------
-- Table structure for hg_purchase_demand
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_demand`;
CREATE TABLE `hg_purchase_demand`  (
  `id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '需求单编号（如：REQ20250807001）',
  `department_id` bigint NOT NULL COMMENT '部门ID',
  `applicant_id` bigint NOT NULL COMMENT '申请人ID',
  `expected_arrival_date` date NULL DEFAULT NULL COMMENT '期望到货日期',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '需求说明',
  `status` int NOT NULL DEFAULT 1 COMMENT '审批状态：1 pending-待审批,  2 approved-已通过, 3 rejected-已驳回',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审批人ID',
  `approval_time` datetime NULL DEFAULT NULL COMMENT '审批时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '采购需求主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_purchase_demand
-- ----------------------------
INSERT INTO `hg_purchase_demand` VALUES ('1970038371623829506', 0, 1950095792504283138, '2025-09-22', '需求一', 4, 1950095792504283138, '2025-09-22 16:12:19', '2025-09-22 16:12:04', '2025-09-22 16:12:35', 0);

-- ----------------------------
-- Table structure for hg_purchase_demand_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_demand_detail`;
CREATE TABLE `hg_purchase_demand_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '详情ID',
  `demand_id` bigint NOT NULL COMMENT '关联的需求单编号',
  `product_id` bigint NOT NULL COMMENT '商品ID（关联商品库）',
  `category_id` bigint NOT NULL COMMENT '商品分类',
  `quantity` decimal(10, 2) NOT NULL COMMENT '需求数量',
  `update_time` datetime NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970038435578576900 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购需求详情表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_purchase_demand_detail
-- ----------------------------
INSERT INTO `hg_purchase_demand_detail` VALUES (1970038372009705473, 1970038371623829506, 1954455089243312130, 1952678553081520129, 3.00, '2025-09-22 16:12:04', '2025-09-22 16:12:04', 1);
INSERT INTO `hg_purchase_demand_detail` VALUES (1970038372076814337, 1970038371623829506, 1954455374657310721, 1952678553081520129, 3.00, '2025-09-22 16:12:04', '2025-09-22 16:12:04', 1);
INSERT INTO `hg_purchase_demand_detail` VALUES (1970038435578576898, 1970038371623829506, 1954455089243312130, 1952678553081520129, 3.00, '2025-09-22 16:12:19', '2025-09-22 16:12:19', 0);
INSERT INTO `hg_purchase_demand_detail` VALUES (1970038435578576899, 1970038371623829506, 1954455374657310721, 1952678553081520129, 3.00, '2025-09-22 16:12:19', '2025-09-22 16:12:19', 0);

-- ----------------------------
-- Table structure for hg_purchase_order
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_order`;
CREATE TABLE `hg_purchase_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `demand_id` bigint NOT NULL COMMENT '关联需求id',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号',
  `employee_id` bigint NOT NULL COMMENT '采购人员ID',
  `expected_date` datetime NULL DEFAULT NULL COMMENT '预计到货时间',
  `actual_date` datetime NULL DEFAULT NULL COMMENT '实际到货时间',
  `status` tinyint NULL DEFAULT 1 COMMENT '订单状态(1-待审核,2-已审核,3-已驳回,4-供应商已确认,5 部分收货 5 全部收货 )',
  `total_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '订单总金额',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `approval_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970038499210362883 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_purchase_order
-- ----------------------------
INSERT INTO `hg_purchase_order` VALUES (1970038499210362882, 1970038371623829506, 'purchaseOrder20250922161221300', 1950095792504283138, '2025-09-22 16:12:21', '1970-01-01 08:00:00', 7, 222.00, '', 1950095792504283138, '2025-09-22 16:12:40', '2025-09-22 16:12:34', '2025-09-22 16:14:57', 0);

-- ----------------------------
-- Table structure for hg_purchase_order_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_order_detail`;
CREATE TABLE `hg_purchase_order_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `supplier_id` bigint NULL DEFAULT NULL COMMENT '供应商ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `category_id` bigint NOT NULL COMMENT '商品分类',
  `quantity` decimal(10, 2) NOT NULL COMMENT '采购数量',
  `price` decimal(10, 2) NOT NULL COMMENT '采购单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970038499537518595 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_purchase_order_detail
-- ----------------------------
INSERT INTO `hg_purchase_order_detail` VALUES (1970038499537518593, 1970038499210362882, 1953021744750215169, 1954455089243312130, 1952678553081520129, 3.00, 47.00, 141.00, '2025-09-22 16:12:34', '2025-09-22 16:12:34', 0);
INSERT INTO `hg_purchase_order_detail` VALUES (1970038499537518594, 1970038499210362882, 1953021744750215169, 1954455374657310721, 1952678553081520129, 3.00, 27.00, 81.00, '2025-09-22 16:12:34', '2025-09-22 16:12:34', 0);

-- ----------------------------
-- Table structure for hg_purchase_return
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_return`;
CREATE TABLE `hg_purchase_return`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '退货单号',
  `order_id` bigint NOT NULL COMMENT '关联采购订单ID',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态(1-待审核,2-已审核,3-已驳回,4-部分到货，5全部到货)',
  `total_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '退单总金额',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `approval_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `receipt` int NULL DEFAULT NULL COMMENT '是否入过库',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970039095195795459 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购退货表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_purchase_return
-- ----------------------------
INSERT INTO `hg_purchase_return` VALUES (1970039095195795458, 'purchaseReturn20250922161445362', 1970038499210362882, 1950095792504283138, 5, 81, '', 1950095792504283138, '2025-09-22 16:16:15', 1, '2025-09-22 16:14:57', '2025-09-22 16:57:14', 0);

-- ----------------------------
-- Table structure for hg_purchase_return_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_purchase_return_detail`;
CREATE TABLE `hg_purchase_return_detail`  (
  `id` bigint NOT NULL,
  `return_id` bigint NOT NULL COMMENT '退货单ID',
  `supplier_id` bigint NULL DEFAULT NULL COMMENT '供应商ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `category_id` bigint NOT NULL COMMENT '商品分类ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '退货数量',
  `price` decimal(10, 2) NOT NULL COMMENT '退货单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购退货明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_purchase_return_detail
-- ----------------------------
INSERT INTO `hg_purchase_return_detail` VALUES (1970039095816552449, 1970039095195795458, 1953021744750215169, 1954455089243312130, 1952678553081520129, 0.00, 47.00, 0.00, '2025-09-22 16:14:57', '2025-09-22 16:14:57', 0);
INSERT INTO `hg_purchase_return_detail` VALUES (1970039095816552450, 1970039095195795458, 1953021744750215169, 1954455374657310721, 1952678553081520129, 3.00, 27.00, 81.00, '2025-09-22 16:14:57', '2025-09-22 16:14:57', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1952580037491453954 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_role
-- ----------------------------
INSERT INTO `hg_role` VALUES (1, '系统管理员', 'sys_admin', '拥有系统所有权限', 1, '2025-07-17 17:30:15', '2025-08-04 17:33:28', 0);
INSERT INTO `hg_role` VALUES (2, '仓库管理员', 'warehouse_admin', '负责仓库管理和库存操作', 1, '2025-07-17 17:30:15', '2025-08-04 17:33:28', 0);
INSERT INTO `hg_role` VALUES (3, '库存人员', 'inventory_staff', '负责库存盘点和调整', 1, '2025-07-17 17:30:15', '2025-08-04 17:33:28', 0);
INSERT INTO `hg_role` VALUES (4, '库存经理', 'inventory_manager', '负责库存报表和决策', 1, '2025-07-17 17:30:15', '2025-08-04 17:33:28', 0);
INSERT INTO `hg_role` VALUES (5, '销售人员', 'sales_staff', '负责销售订单和客户维护', 1, '2025-07-17 17:30:15', '2025-08-04 17:33:28', 0);
INSERT INTO `hg_role` VALUES (6, '销售经理', 'sales_manager', '负责销售团队管理和报表', 1, '2025-07-17 17:30:15', '2025-08-04 17:33:29', 0);
INSERT INTO `hg_role` VALUES (7, '财务人员', 'finance_staff', '负责财务管理和报表', 1, '2025-07-17 17:30:15', '2025-08-04 17:33:29', 0);
INSERT INTO `hg_role` VALUES (1952303554671882242, '超级管理员', 'admin', '超级管理员拥有最大权限', 1, '2025-08-04 17:40:14', '2025-09-22 17:12:00', 0);
INSERT INTO `hg_role` VALUES (1952580037491453953, '测试角色', 'test', '', 1, '2025-08-05 11:58:53', '2025-08-11 23:16:15', 0);

-- ----------------------------
-- Table structure for hg_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `hg_role_permission`;
CREATE TABLE `hg_role_permission`  (
  `id` bigint NOT NULL,
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色权限关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_role_permission
-- ----------------------------
INSERT INTO `hg_role_permission` VALUES (1952659164466683906, 1952580037491453953, 1952561423342309377, '2025-08-05 17:13:18', 1, '2025-08-05 17:13:18');
INSERT INTO `hg_role_permission` VALUES (1952659164466683907, 1952580037491453953, 1952562778312216578, '2025-08-05 17:13:18', 1, '2025-08-05 17:13:18');
INSERT INTO `hg_role_permission` VALUES (1952659164537987074, 1952580037491453953, 1952561113785896961, '2025-08-05 17:13:18', 1, '2025-08-05 17:13:18');
INSERT INTO `hg_role_permission` VALUES (1952659164537987075, 1952580037491453953, 1952562158385696769, '2025-08-05 17:13:18', 1, '2025-08-05 17:13:18');
INSERT INTO `hg_role_permission` VALUES (1952659164537987076, 1952580037491453953, 1952658215757062146, '2025-08-05 17:13:18', 1, '2025-08-05 17:13:18');
INSERT INTO `hg_role_permission` VALUES (1952659164537987077, 1952580037491453953, 1952658439359602690, '2025-08-05 17:13:18', 1, '2025-08-05 17:13:18');
INSERT INTO `hg_role_permission` VALUES (1952659164537987078, 1952580037491453953, 1952658612836016129, '2025-08-05 17:13:18', 1, '2025-08-05 17:13:18');
INSERT INTO `hg_role_permission` VALUES (1954555941157175298, 1952580037491453953, 1952562778312216578, '2025-08-10 22:50:25', 1, '2025-08-10 22:50:25');
INSERT INTO `hg_role_permission` VALUES (1954555941161369602, 1952580037491453953, 1952561113785896961, '2025-08-10 22:50:25', 1, '2025-08-10 22:50:25');
INSERT INTO `hg_role_permission` VALUES (1954555941161369603, 1952580037491453953, 1952562158385696769, '2025-08-10 22:50:25', 1, '2025-08-10 22:50:25');
INSERT INTO `hg_role_permission` VALUES (1954555941161369604, 1952580037491453953, 1952658215757062146, '2025-08-10 22:50:25', 1, '2025-08-10 22:50:25');
INSERT INTO `hg_role_permission` VALUES (1954555941161369605, 1952580037491453953, 1952658439359602690, '2025-08-10 22:50:25', 1, '2025-08-10 22:50:25');
INSERT INTO `hg_role_permission` VALUES (1954555941161369606, 1952580037491453953, 1952658612836016129, '2025-08-10 22:50:25', 1, '2025-08-10 22:50:25');
INSERT INTO `hg_role_permission` VALUES (1954556505844711426, 1952580037491453953, 1952561113785896961, '2025-08-10 22:52:40', 1, '2025-08-10 22:52:40');
INSERT INTO `hg_role_permission` VALUES (1954556505844711427, 1952580037491453953, 1952658215757062146, '2025-08-10 22:52:40', 1, '2025-08-10 22:52:40');
INSERT INTO `hg_role_permission` VALUES (1954556505844711428, 1952580037491453953, 1952658439359602690, '2025-08-10 22:52:40', 1, '2025-08-10 22:52:40');
INSERT INTO `hg_role_permission` VALUES (1954556505844711429, 1952580037491453953, 1952658612836016129, '2025-08-10 22:52:40', 1, '2025-08-10 22:52:40');
INSERT INTO `hg_role_permission` VALUES (1954556723176767489, 1952580037491453953, 1952561113785896961, '2025-08-10 22:53:31', 1, '2025-08-10 22:53:31');
INSERT INTO `hg_role_permission` VALUES (1954556723176767490, 1952580037491453953, 1952658215757062146, '2025-08-10 22:53:31', 1, '2025-08-10 22:53:31');
INSERT INTO `hg_role_permission` VALUES (1954556723176767491, 1952580037491453953, 1952658439359602690, '2025-08-10 22:53:31', 1, '2025-08-10 22:53:31');
INSERT INTO `hg_role_permission` VALUES (1954556723176767492, 1952580037491453953, 1952658612836016129, '2025-08-10 22:53:31', 1, '2025-08-10 22:53:31');
INSERT INTO `hg_role_permission` VALUES (1954556723176767493, 1952580037491453953, 1954554256779214850, '2025-08-10 22:53:31', 1, '2025-08-10 22:53:31');
INSERT INTO `hg_role_permission` VALUES (1954556723176767494, 1952580037491453953, 1954554607104262146, '2025-08-10 22:53:31', 1, '2025-08-10 22:53:31');
INSERT INTO `hg_role_permission` VALUES (1954556723176767495, 1952580037491453953, 1954554993114447874, '2025-08-10 22:53:31', 1, '2025-08-10 22:53:31');
INSERT INTO `hg_role_permission` VALUES (1954559545356156930, 1952580037491453953, 1952561113785896961, '2025-08-10 23:04:44', 1, '2025-08-10 23:04:44');
INSERT INTO `hg_role_permission` VALUES (1954559545427460097, 1952580037491453953, 1952658215757062146, '2025-08-10 23:04:44', 1, '2025-08-10 23:04:44');
INSERT INTO `hg_role_permission` VALUES (1954559545427460098, 1952580037491453953, 1952658439359602690, '2025-08-10 23:04:44', 1, '2025-08-10 23:04:44');
INSERT INTO `hg_role_permission` VALUES (1954559545427460099, 1952580037491453953, 1952658612836016129, '2025-08-10 23:04:44', 1, '2025-08-10 23:04:44');
INSERT INTO `hg_role_permission` VALUES (1954559545427460100, 1952580037491453953, 1954554256779214850, '2025-08-10 23:04:44', 1, '2025-08-10 23:04:44');
INSERT INTO `hg_role_permission` VALUES (1954559545431654401, 1952580037491453953, 1954554607104262146, '2025-08-10 23:04:44', 1, '2025-08-10 23:04:44');
INSERT INTO `hg_role_permission` VALUES (1954559710691426306, 1952580037491453953, 1952561113785896961, '2025-08-10 23:05:24', 1, '2025-08-10 23:05:24');
INSERT INTO `hg_role_permission` VALUES (1954559710691426307, 1952580037491453953, 1952658215757062146, '2025-08-10 23:05:24', 1, '2025-08-10 23:05:24');
INSERT INTO `hg_role_permission` VALUES (1954559710691426308, 1952580037491453953, 1952658439359602690, '2025-08-10 23:05:24', 1, '2025-08-10 23:05:24');
INSERT INTO `hg_role_permission` VALUES (1954559710691426309, 1952580037491453953, 1952658612836016129, '2025-08-10 23:05:24', 1, '2025-08-10 23:05:24');
INSERT INTO `hg_role_permission` VALUES (1954559710691426310, 1952580037491453953, 1954554256779214850, '2025-08-10 23:05:24', 1, '2025-08-10 23:05:24');
INSERT INTO `hg_role_permission` VALUES (1954559710691426311, 1952580037491453953, 1954554607104262146, '2025-08-10 23:05:24', 1, '2025-08-10 23:05:24');
INSERT INTO `hg_role_permission` VALUES (1954559710754340865, 1952580037491453953, 1954554993114447874, '2025-08-10 23:05:24', 1, '2025-08-10 23:05:24');
INSERT INTO `hg_role_permission` VALUES (1954730300742529026, 1952580037491453953, 1952561113785896961, '2025-08-11 10:23:15', 1, '2025-08-11 10:23:15');
INSERT INTO `hg_role_permission` VALUES (1954730300742529027, 1952580037491453953, 1952658215757062146, '2025-08-11 10:23:15', 1, '2025-08-11 10:23:15');
INSERT INTO `hg_role_permission` VALUES (1954730300742529028, 1952580037491453953, 1952658439359602690, '2025-08-11 10:23:15', 1, '2025-08-11 10:23:15');
INSERT INTO `hg_role_permission` VALUES (1954730300742529029, 1952580037491453953, 1952658612836016129, '2025-08-11 10:23:15', 1, '2025-08-11 10:23:15');
INSERT INTO `hg_role_permission` VALUES (1954730300742529030, 1952580037491453953, 1954554256779214850, '2025-08-11 10:23:15', 1, '2025-08-11 10:23:15');
INSERT INTO `hg_role_permission` VALUES (1954730300742529031, 1952580037491453953, 1954554607104262146, '2025-08-11 10:23:15', 1, '2025-08-11 10:23:15');
INSERT INTO `hg_role_permission` VALUES (1954731986328449025, 1952303554671882242, 1952561113785896961, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954731986328449026, 1952303554671882242, 1952561423342309377, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954731986328449027, 1952303554671882242, 1952562158385696769, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954731986328449028, 1952303554671882242, 1952562778312216578, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954731986328449029, 1952303554671882242, 1952658215757062146, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954731986328449030, 1952303554671882242, 1952658439359602690, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954731986328449031, 1952303554671882242, 1952658612836016129, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954731986328449032, 1952303554671882242, 1954554256779214850, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954731986328449033, 1952303554671882242, 1954554607104262146, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954731986328449034, 1952303554671882242, 1954554993114447874, '2025-08-11 10:29:57', 1, '2025-08-11 10:29:57');
INSERT INTO `hg_role_permission` VALUES (1954834189445677057, 1952303554671882242, 1952561113785896961, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677058, 1952303554671882242, 1952561423342309377, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677059, 1952303554671882242, 1952562158385696769, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677060, 1952303554671882242, 1952562778312216578, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677061, 1952303554671882242, 1952658215757062146, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677062, 1952303554671882242, 1952658439359602690, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677063, 1952303554671882242, 1952658612836016129, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677064, 1952303554671882242, 1954554256779214850, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677065, 1952303554671882242, 1954554607104262146, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677066, 1952303554671882242, 1954554993114447874, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189445677067, 1952303554671882242, 1954833520101867522, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954834189508591617, 1952303554671882242, 1954834079097733121, '2025-08-11 17:16:04', 1, '2025-08-11 17:16:04');
INSERT INTO `hg_role_permission` VALUES (1954923007395565569, 1952303554671882242, 1952561113785896961, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674433, 1952303554671882242, 1952561423342309377, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674434, 1952303554671882242, 1952562158385696769, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674435, 1952303554671882242, 1952562778312216578, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674436, 1952303554671882242, 1952658215757062146, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674437, 1952303554671882242, 1952658439359602690, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674438, 1952303554671882242, 1952658612836016129, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674439, 1952303554671882242, 1954554256779214850, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674440, 1952303554671882242, 1954554607104262146, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674441, 1952303554671882242, 1954554993114447874, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674442, 1952303554671882242, 1954833520101867522, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674443, 1952303554671882242, 1954834079097733121, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674444, 1952303554671882242, 1954922598694195201, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954923007462674445, 1952303554671882242, 1954922913359269890, '2025-08-11 23:09:00', 1, '2025-08-11 23:09:00');
INSERT INTO `hg_role_permission` VALUES (1954924832689557506, 1952580037491453953, 1952561113785896961, '2025-08-11 23:16:16', 0, '2025-08-11 23:16:16');
INSERT INTO `hg_role_permission` VALUES (1954924832689557507, 1952580037491453953, 1952658215757062146, '2025-08-11 23:16:16', 0, '2025-08-11 23:16:16');
INSERT INTO `hg_role_permission` VALUES (1954924832689557508, 1952580037491453953, 1952658439359602690, '2025-08-11 23:16:16', 0, '2025-08-11 23:16:16');
INSERT INTO `hg_role_permission` VALUES (1954924832689557509, 1952580037491453953, 1952658612836016129, '2025-08-11 23:16:16', 0, '2025-08-11 23:16:16');
INSERT INTO `hg_role_permission` VALUES (1954924832689557510, 1952580037491453953, 1954554256779214850, '2025-08-11 23:16:16', 0, '2025-08-11 23:16:16');
INSERT INTO `hg_role_permission` VALUES (1954924832689557511, 1952580037491453953, 1954554607104262146, '2025-08-11 23:16:16', 0, '2025-08-11 23:16:16');
INSERT INTO `hg_role_permission` VALUES (1954924832689557512, 1952580037491453953, 1954833520101867522, '2025-08-11 23:16:16', 0, '2025-08-11 23:16:16');
INSERT INTO `hg_role_permission` VALUES (1954924832689557513, 1952580037491453953, 1954922598694195201, '2025-08-11 23:16:16', 0, '2025-08-11 23:16:16');
INSERT INTO `hg_role_permission` VALUES (1957435840427528193, 1952303554671882242, 1952561113785896961, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840427528194, 1952303554671882242, 1952561423342309377, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840427528195, 1952303554671882242, 1952562158385696769, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840427528196, 1952303554671882242, 1952562778312216578, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840427528197, 1952303554671882242, 1952658215757062146, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840427528198, 1952303554671882242, 1952658439359602690, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840427528199, 1952303554671882242, 1952658612836016129, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840427528200, 1952303554671882242, 1954554256779214850, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840427528201, 1952303554671882242, 1954554607104262146, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840494637058, 1952303554671882242, 1954554993114447874, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840494637059, 1952303554671882242, 1954833520101867522, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840494637060, 1952303554671882242, 1954834079097733121, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840494637061, 1952303554671882242, 1954922598694195201, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840494637062, 1952303554671882242, 1954922913359269890, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840494637063, 1952303554671882242, 1957435491113308162, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840494637064, 1952303554671882242, 1957435627012952065, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957435840494637065, 1952303554671882242, 1957435790586613762, '2025-08-18 21:34:06', 1, '2025-08-18 21:34:06');
INSERT INTO `hg_role_permission` VALUES (1957436579656830977, 1952303554671882242, 1952561113785896961, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830978, 1952303554671882242, 1952561423342309377, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830979, 1952303554671882242, 1952562158385696769, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830980, 1952303554671882242, 1952562778312216578, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830981, 1952303554671882242, 1952658215757062146, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830982, 1952303554671882242, 1952658439359602690, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830983, 1952303554671882242, 1952658612836016129, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830984, 1952303554671882242, 1954554256779214850, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830985, 1952303554671882242, 1954554607104262146, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830986, 1952303554671882242, 1954554993114447874, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830987, 1952303554671882242, 1954833520101867522, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830988, 1952303554671882242, 1954834079097733121, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830989, 1952303554671882242, 1954922598694195201, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830990, 1952303554671882242, 1954922913359269890, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830991, 1952303554671882242, 1957435491113308162, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579656830992, 1952303554671882242, 1957435627012952065, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579728134146, 1952303554671882242, 1957435790586613762, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579728134147, 1952303554671882242, 1957436138843869185, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1957436579732328450, 1952303554671882242, 1957436430557712385, '2025-08-18 21:37:03', 1, '2025-08-18 21:37:03');
INSERT INTO `hg_role_permission` VALUES (1970053456761126913, 1952303554671882242, 1952561113785896961, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456761126914, 1952303554671882242, 1952561423342309377, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456761126915, 1952303554671882242, 1952562158385696769, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456761126916, 1952303554671882242, 1952562778312216578, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456761126917, 1952303554671882242, 1952658215757062146, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456761126918, 1952303554671882242, 1952658439359602690, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456761126919, 1952303554671882242, 1952658612836016129, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041473, 1952303554671882242, 1954554256779214850, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041474, 1952303554671882242, 1954554607104262146, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041475, 1952303554671882242, 1954554993114447874, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041476, 1952303554671882242, 1954833520101867522, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041477, 1952303554671882242, 1954834079097733121, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041478, 1952303554671882242, 1954922598694195201, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041479, 1952303554671882242, 1954922913359269890, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041480, 1952303554671882242, 1957435491113308162, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041481, 1952303554671882242, 1957435627012952065, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041482, 1952303554671882242, 1957435790586613762, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041483, 1952303554671882242, 1957436138843869185, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041484, 1952303554671882242, 1957436430557712385, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041485, 1952303554671882242, 1970053250455896065, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');
INSERT INTO `hg_role_permission` VALUES (1970053456824041486, 1952303554671882242, 1970053380479320066, '2025-09-22 17:12:01', 0, '2025-09-22 17:12:01');

-- ----------------------------
-- Table structure for hg_sales_order
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_order`;
CREATE TABLE `hg_sales_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `employee_id` bigint NOT NULL COMMENT '销售人员ID',
  `expected_date` date NULL DEFAULT NULL COMMENT '预计交货日期',
  `actual_date` date NULL DEFAULT NULL COMMENT '实际交货日期',
  `status` tinyint NULL DEFAULT 1 COMMENT '订单状态(1-待审核,2-已审核,3-已发货,4-已完成,5-已取消)',
  `total_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '订单总金额',
  `discount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '折扣金额',
  `tax` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '税额',
  `final_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '最终金额',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `approval_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970076796481634307 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_sales_order
-- ----------------------------
INSERT INTO `hg_sales_order` VALUES (1970038159782117377, 'salesOrder20250922161051124', 1953018819353198594, 1950095792504283138, '2025-09-22', '1970-01-01', 4, 240.00, 0.00, 0.00, 240.00, '', 1950095792504283138, '2025-09-22 18:43:41', '2025-09-22 16:11:13', '2025-09-22 18:44:04', 0);
INSERT INTO `hg_sales_order` VALUES (1970075826372673537, 'salesOrder20250922184040198', 1953018819353198594, 1950095792504283138, '2025-09-22', '1970-01-01', 4, 148.50, 0.00, 0.00, 148.50, '', 1950095792504283138, '2025-09-22 18:47:56', '2025-09-22 18:40:54', '2025-09-22 18:48:00', 0);
INSERT INTO `hg_sales_order` VALUES (1970076796481634306, 'salesOrder20250922184429718', 1953018819353198594, 1950095792504283138, '2025-09-22', '1970-01-01', 4, 148.50, 0.00, 0.00, 148.50, '', 1950095792504283138, '2025-09-22 18:47:41', '2025-09-22 18:44:45', '2025-09-22 18:47:45', 0);

-- ----------------------------
-- Table structure for hg_sales_order_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_order_detail`;
CREATE TABLE `hg_sales_order_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '商品分类ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '销售数量',
  `price` decimal(10, 2) NOT NULL COMMENT '销售单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1970077614505132035 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_sales_order_detail
-- ----------------------------
INSERT INTO `hg_sales_order_detail` VALUES (1970038160222519298, 1970038159782117377, 1952678628172144642, 1954455089243312130, 3.00, 49.60, 148.80, '2025-09-22 16:11:14', '2025-09-22 18:43:41', 1);
INSERT INTO `hg_sales_order_detail` VALUES (1970038160222519299, 1970038159782117377, 1952678628172144642, 1954455374657310721, 3.00, 29.40, 88.20, '2025-09-22 16:11:14', '2025-09-22 18:43:41', 1);
INSERT INTO `hg_sales_order_detail` VALUES (1970075826892767234, 1970075826372673537, 1952678628172144642, 1954455089243312130, 3.00, 49.50, 148.50, '2025-09-22 18:40:54', '2025-09-22 18:47:56', 1);
INSERT INTO `hg_sales_order_detail` VALUES (1970076529010868226, 1970038159782117377, 1952678628172144642, 1954455089243312130, 3.00, 50.00, 150.00, '2025-09-22 18:43:41', '2025-09-22 18:44:03', 1);
INSERT INTO `hg_sales_order_detail` VALUES (1970076529010868227, 1970038159782117377, 1952678628172144642, 1954455374657310721, 3.00, 30.00, 90.00, '2025-09-22 18:43:41', '2025-09-22 18:44:03', 1);
INSERT INTO `hg_sales_order_detail` VALUES (1970076623525314561, 1970038159782117377, 1952678628172144642, 1954455089243312130, 3.00, 50.00, 150.00, '2025-09-22 18:44:04', '2025-09-22 18:44:04', 0);
INSERT INTO `hg_sales_order_detail` VALUES (1970076623525314562, 1970038159782117377, 1952678628172144642, 1954455374657310721, 3.00, 30.00, 90.00, '2025-09-22 18:44:04', '2025-09-22 18:44:04', 0);
INSERT INTO `hg_sales_order_detail` VALUES (1970076796880093186, 1970076796481634306, 1952678628172144642, 1954455089243312130, 3.00, 49.50, 148.50, '2025-09-22 18:44:45', '2025-09-22 18:47:41', 1);
INSERT INTO `hg_sales_order_detail` VALUES (1970077535035654146, 1970076796481634306, 1952678628172144642, 1954455089243312130, 3.00, 49.50, 148.50, '2025-09-22 18:47:41', '2025-09-22 18:47:45', 1);
INSERT INTO `hg_sales_order_detail` VALUES (1970077551397634049, 1970076796481634306, 1952678628172144642, 1954455089243312130, 3.00, 49.50, 148.50, '2025-09-22 18:47:45', '2025-09-22 18:47:45', 0);
INSERT INTO `hg_sales_order_detail` VALUES (1970077597916659713, 1970075826372673537, 1952678628172144642, 1954455089243312130, 3.00, 49.50, 148.50, '2025-09-22 18:47:56', '2025-09-22 18:48:00', 1);
INSERT INTO `hg_sales_order_detail` VALUES (1970077614505132034, 1970075826372673537, 1952678628172144642, 1954455089243312130, 3.00, 49.50, 148.50, '2025-09-22 18:48:00', '2025-09-22 18:48:00', 0);

-- ----------------------------
-- Table structure for hg_sales_return
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_return`;
CREATE TABLE `hg_sales_return`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '退货单号',
  `order_id` bigint NOT NULL COMMENT '关联销售订单ID',
  `employee_id` bigint NOT NULL COMMENT '操作员工ID',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态(1-待审核,2-已审核,3-已驳回,4-部分到货，5全部到货)',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `total_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '总金额',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `approval_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售退货表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_sales_return
-- ----------------------------

-- ----------------------------
-- Table structure for hg_sales_return_detail
-- ----------------------------
DROP TABLE IF EXISTS `hg_sales_return_detail`;
CREATE TABLE `hg_sales_return_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `return_id` bigint NOT NULL COMMENT '退货单ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '商品分类ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '退货数量',
  `price` decimal(10, 2) NOT NULL COMMENT '退货单价',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL,
  `del_flag` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售退货明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_sales_return_detail
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
) ENGINE = InnoDB AUTO_INCREMENT = 1953005982987796482 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '货架表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_shelf
-- ----------------------------
INSERT INTO `hg_shelf` VALUES (1953005820022308865, 1952986337115324418, '001', '货架1', 10, 1000.00, '2025-08-06 16:10:47', '2025-08-06 16:10:47', 0);
INSERT INTO `hg_shelf` VALUES (1953005982987796481, 1952986337115324418, '001', '货架2', 12, 131.00, '2025-08-06 16:11:26', '2025-08-06 16:11:26', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1958803048640946179 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_supplier
-- ----------------------------
INSERT INTO `hg_supplier` VALUES (1953021744750215169, '001', '供应商1', '小李', '17310241221', '', '123@163.com', '2025-08-06 17:14:04', '2025-08-06 17:14:04', 0);
INSERT INTO `hg_supplier` VALUES (1958803048640946178, '123', '供应商2', 'haha', '17302024565', '', 'ewyui@163.com', '2025-08-22 16:06:54', '2025-08-22 16:06:54', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1952985683936362498 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_warehouse
-- ----------------------------
INSERT INTO `hg_warehouse` VALUES (1952918491823816705, '001', '仓库1', NULL, 100.00, 1950095792504283138, '2025-08-06 10:23:47', '2025-08-06 10:23:47', 0);
INSERT INTO `hg_warehouse` VALUES (1952985683936362497, '002', '仓库2', NULL, 120.00, 1952309334494097410, '2025-08-06 14:50:46', '2025-08-06 14:50:46', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1952987596086001667 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库区域表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hg_warehouse_area
-- ----------------------------
INSERT INTO `hg_warehouse_area` VALUES (1952986337115324418, 1952918491823816705, '区域1', 2, '2025-08-06 14:53:22', '2025-08-06 14:58:27', 0);
INSERT INTO `hg_warehouse_area` VALUES (1952987508542488577, 1952918491823816705, '区域2', 1, '2025-08-06 14:58:01', '2025-08-06 14:58:01', 0);
INSERT INTO `hg_warehouse_area` VALUES (1952987596086001666, 1952918491823816705, '区域3', 1, '2025-08-06 14:58:22', '2025-08-06 14:58:22', 0);

SET FOREIGN_KEY_CHECKS = 1;
