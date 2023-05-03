CREATE TABLE `user_base` (
  `user_id` char(11) NOT NULL COMMENT '用户编号',
  `user_name` varchar(250) NOT NULL COMMENT '用户名称',
  `password` varchar(45) NOT NULL COMMENT '密码',
  `sex` varchar(45) DEFAULT NULL COMMENT '性别',
  `birthday` date DEFAULT NULL COMMENT '出生日期',
  `mobile` varchar(15) DEFAULT NULL COMMENT '手机号',
  `certificate_country` varchar(45) DEFAULT NULL COMMENT '证件国家',
  `certificate_type` varchar(45) DEFAULT NULL COMMENT '证件类型',
  `certificate_number` varchar(45) DEFAULT NULL COMMENT '证件号码',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `create_time` datetime(6) NOT NULL COMMENT '创建时间',
  `modify_time` datetime(6) NOT NULL COMMENT '修改时间',
  `creator_id` char(11) NOT NULL COMMENT '创建者id',
  `modifier_id` char(11) NOT NULL COMMENT '修改者id',
  `user_status` char(1) DEFAULT NULL COMMENT '用户状态 N 正常; L 锁定; C 注销',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户基本信息';
