CREATE TABLE IF NOT EXISTS `mortuary_deaths` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `citizenid` VARCHAR(50) NOT NULL,
    `expires_at` INT NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_citizenid` (`citizenid`)
);
