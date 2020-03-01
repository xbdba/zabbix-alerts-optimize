-------------------------------
-- Table structure for tmp_alerts
-------------------------------
DROP TABLE IF EXISTS `tmp_alerts`;
CREATE TABLE `tmp_alerts`  (
  `eventid` bigint(20) NULL DEFAULT NULL,
  `clock` int(20) NULL DEFAULT NULL,
  `sendto` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `triggername` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `itemvalue` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `eventtime` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `p_eventid` bigint(20) NULL DEFAULT NULL,
  `status` varchar(2) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-------------------------------
-- Table structure for his_alerts
-------------------------------
DROP TABLE IF EXISTS `his_alerts`;
CREATE TABLE `his_alerts`  (
  `eventid` bigint(20) NULL DEFAULT NULL,
  `clock` int(20) NULL DEFAULT NULL,
  `sendto` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `triggername` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `itemvalue` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `eventtime` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `p_eventid` bigint(20) NULL DEFAULT NULL,
  `status` varchar(2) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

create index idx_his_alerts_eventid on his_alerts(eventid);

-- ----------------------------
-- Table structure for all_alerts
-- ----------------------------
DROP TABLE IF EXISTS `all_alerts`;
CREATE TABLE `all_alerts`  (
  `sendto` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `subject` varchar(4000) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `eventtime` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for all_alerts_history
-- ----------------------------
DROP TABLE IF EXISTS `all_alerts_history`;
CREATE TABLE `all_alerts_history`  (
  `sendto` varchar(20) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `subject` varchar(4000) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `eventtime` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;