CREATE TABLE IF NOT EXISTS `ricky_reward` (
  `code` varchar(500) NOT NULL DEFAULT '',
  `data` longtext DEFAULT NULL,
  `staffInfo` varchar(500) DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `userInfo` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
