CREATE TABLE `user_event` (
  `event_id` bigint NOT NULL COMMENT '事件ID',
  `event_date` date NOT NULL COMMENT '事件日期',
  `event_code` varchar(20) NOT NULL COMMENT '事件代码',
  `user_id` char(11) NOT NULL COMMENT '用户编号',
  `event_name` varchar(45) NOT NULL COMMENT '事件名称',
  `event_status` char(1) NOT NULL COMMENT '事件状态 R 登记;  P 已发布',
  `retry_count` int NOT NULL DEFAULT '0' COMMENT '发布重试次数，第一次发布不计数',
  `extra_data` json DEFAULT NULL COMMENT '附加数据',
  `create_time` datetime(6) NOT NULL COMMENT '创建时间',
  `creator_id` char(11) NOT NULL COMMENT '创建人ID',
  `modifier_id` char(11) NOT NULL COMMENT '修改者id',
  `modify_time` datetime(6) NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`event_id`,`event_date`),
  KEY `IDX_EVENT_STATUS` (`event_date`,`event_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户事件'
/*!50500 PARTITION BY RANGE  COLUMNS(event_date)
(PARTITION p20230502 VALUES LESS THAN ('2023-05-02') ENGINE = InnoDB,
 PARTITION p20230503 VALUES LESS THAN ('2023-05-03') ENGINE = InnoDB,
 PARTITION p20230504 VALUES LESS THAN ('2023-05-04') ENGINE = InnoDB) */;



-- 创建分区、删除分区的存储过程
delimiter $$
DROP PROCEDURE IF EXISTS pro_user_event
$$
CREATE PROCEDURE pro_user_event()
BEGIN
  DECLARE v_sysdate date;
  DECLARE v_mindate date;
  DECLARE v_maxdate date;
  DECLARE v_pt varchar(20);
  DECLARE v_maxval varchar(20);
  DECLARE i int;

  /*增加新分区代码，执行时，不要复制此行*/
  SELECT max(cast(replace(partition_description, '''', '') AS date)) AS val
  INTO   v_maxdate
  FROM   INFORMATION_SCHEMA.PARTITIONS
  WHERE  TABLE_NAME = 'user_event' AND TABLE_SCHEMA = 'user';

  set v_sysdate = sysdate();

  WHILE v_maxdate <= (v_sysdate + INTERVAL 7 DAY) DO
    SET v_pt = date_format(v_maxdate+ INTERVAL 1 DAY ,'%Y%m%d');
    SET v_maxval = date_format(v_maxdate + INTERVAL 1 DAY, '%Y-%m-%d');
    SET @sql = concat('alter table user_event add partition (partition p', v_pt, ' values less than(''', v_maxval, '''))');
    -- SELECT @sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_maxdate = v_maxdate + INTERVAL 1 DAY;
  END WHILE;

  /*删除旧分区，执行时，不要复制此行*/
  SELECT min(cast(replace(partition_description, '''', '') AS date)) AS val
  INTO   v_mindate
  FROM   INFORMATION_SCHEMA.PARTITIONS
  WHERE  TABLE_NAME = 'user_event ' AND TABLE_SCHEMA = 'user';

  WHILE v_mindate <= (v_sysdate - INTERVAL 31 DAY) DO
    SET v_pt = date_format(v_mindate - INTERVAL 1 DAY,'%Y%m%d');
    SET @sql = concat('alter table user_event drop partition p', v_pt);
    -- SELECT @sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_mindate = v_mindate + INTERVAL 1 DAY;
  END WHILE;

END$$
delimiter ;

-- 自动分区的事件
DELIMITER $$
drop event if exists auto_user_event_pt $$
create event auto_user_event_pt
on schedule
every 1 minute
starts '2023-05-02 12:19:02'
do
BEGIN
    call pro_user_event();
END$$
delimiter ;