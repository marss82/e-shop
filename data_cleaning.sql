SELECT *
FROM eshop_orders;

CREATE TABLE eshop_staging
LIKE eshop_orders;

INSERT INTO eshop_staging
SELECT * FROM eshop_orders;


-- Duplicate orders with different order_id (60)
WITH duplicates AS
(
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_date, customer_id, country, device_type, marketing_channel, product_category, 
                payment_method, is_new_customer, units, gross_revenue, discount_pct, discount_amount, shipping_fee, 
                refund_flag, refunded_amount, net_revenue, coupon_code ORDER BY order_id) AS row_num
    FROM eshop_staging
)
SELECT *
FROM duplicates
WHERE row_num>1;

SELECT *
FROM eshop_staging
WHERE customer_id=12251 AND country= 'CZ' AND device_type = 'desktop' AND net_revenue=20792.40;


CREATE TABLE `eshop_staging2` (
  `order_id` int DEFAULT NULL,
  `order_date` varchar(12) DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `country` varchar(10) DEFAULT NULL,
  `device_type` varchar(20) DEFAULT NULL,
  `marketing_channel` varchar(30) DEFAULT NULL,
  `product_category` varchar(30) DEFAULT NULL,
  `payment_method` varchar(20) DEFAULT NULL,
  `is_new_customer` tinyint DEFAULT NULL,
  `units` int DEFAULT NULL,
  `gross_revenue` decimal(10,2) DEFAULT NULL,
  `discount_pct` decimal(5,2) DEFAULT NULL,
  `discount_amount` decimal(10,2) DEFAULT NULL,
  `shipping_fee` decimal(10,2) DEFAULT NULL,
  `refund_flag` tinyint DEFAULT NULL,
  `refunded_amount` decimal(10,2) DEFAULT NULL,
  `net_revenue` decimal(10,2) DEFAULT NULL,
  `coupon_code` varchar(50) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO eshop_staging2
SELECT *,
	ROW_NUMBER() OVER (
		 PARTITION BY order_date, customer_id, country, device_type, marketing_channel, product_category, 
                payment_method, is_new_customer, units, gross_revenue, discount_pct, discount_amount,
                shipping_fee, refund_flag, refunded_amount, net_revenue, coupon_code ORDER BY order_id) AS row_num
	FROM eshop_staging;

SELECT *
FROM eshop_staging2
WHERE row_num>1;

DELETE
FROM eshop_staging2
WHERE row_num>1;



-- Change order_date format from string to date
SELECT order_date, STR_TO_DATE(order_date, '%d.%m.%Y')
FROM eshop_staging2;

UPDATE eshop_staging2
SET order_date = STR_TO_DATE(order_date, '%d.%m.%Y');

ALTER TABLE eshop_staging2
MODIFY COLUMN order_date DATE;



-- Missing marketing_channel in 310 rows. Can't fix this reliably.
SELECT COUNT(order_id)
FROM eshop_staging2
WHERE marketing_channel IS NULL OR marketing_channel='';



-- Business logic error. Refunded amount is more than 0, but no refund_flag in 87 rows. Net_revenue sits well, so there must be an error with flag.
SELECT COUNT(order_id)
FROM eshop_staging2
WHERE refund_flag=0 AND refunded_amount>0;

UPDATE eshop_staging2
SET refund_flag = 1
WHERE refund_flag=0 AND refunded_amount>0;



-- Delete unnecessary columns
SELECT *
FROM eshop_staging2;

ALTER TABLE eshop_staging2
DROP COLUMN row_num;
  