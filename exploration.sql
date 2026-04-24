-- Exploration


-- OVERALL

-- After cleaning, we have 28,965 order records for 2 years (from the beginning of 2024 to the end of 2025), from 8,188 customers across 4 countries
SELECT 
	MIN(order_date), 	
	MAX(order_date), 
    COUNT(*) AS orders, 
    SUM(is_new_customer) AS new_customers, 
    COUNT(DISTINCT(country)) AS countries
FROM eshop_staging2
GROUP BY YEAR(order_date);

-- in 2025 we have 0.5% more refunds orders. (3.4% in 2024 and 3.9% in 2025)
SELECT 
	YEAR(order_date) AS year,
     SUM(refund_flag) AS refunds, 
	ROUND( SUM(refund_flag) * 100.0 / COUNT(*), 1) AS pct_refund
FROM eshop_staging2
GROUP BY year;

-- The average order contains 1.5 units
SELECT 
	YEAR(order_date) AS year,
	AVG(units) AS avg_units_per_order
FROM eshop_staging2
GROUP BY year;

-- The average revenue per order grew by 5%
SELECT 
	YEAR(order_date) AS year,
	ROUND(AVG(net_revenue),0) AS avg_revenue_per_order
FROM eshop_staging2
GROUP BY year;

-- 62% of orders are from the Czech Republic, 18% from Slovakia, 13% from Germany, and 7% from Austria
SELECT 
	country, 
	COUNT(*) AS orders, 
	ROUND(COUNT(*) *100/ SUM(COUNT(*)) OVER(), 2) AS pct_orders
FROM eshop_staging2
GROUP BY country;



-- CUSTOMERS

-- On average, customers made 3.5 orders over the 2 years. The maximum number of orders per customer is 12
WITH avg_order_count AS (
SELECT COUNT(*) AS orders
FROM eshop_staging2
GROUP BY customer_id
)
SELECT 
	AVG(orders), 
	MAX(orders), 
    MIN(orders)
FROM avg_order_count;

-- 89% of customers have 2 or more orders, indicating strong customer retention. The average number of orders for this group is 3.9
WITH avg_order_count AS (
SELECT
	customer_id, 
	COUNT(*) AS orders
FROM eshop_staging2
GROUP BY customer_id
)
SELECT 
	COUNT(*) AS repeated_customers, 
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM avg_order_count), 2) AS pct_customers , 
    AVG(orders) AS avg_order_count
FROM avg_order_count
WHERE orders>1;

-- count of new customers is growing. We see big waves in November and December.
SELECT 
	YEAR(order_date) AS year, 
	MONTH(order_date) AS month, 
    SUM(is_new_customer) AS new_customer
FROM eshop_staging2
GROUP BY year, month
ORDER BY  year, month;



-- ORDERS AND REVENUE

-- The number of orders is increasing over time, along with net revenue
-- The strongest months economically are November and December, with the highest number of items purchased and the highest revenue
-- In both years, users tend to purchase less in January, February, and during the summer, especially in 2025
SELECT 
	YEAR(order_date) AS year, 
	MONTH(order_date) AS month, 
    COUNT(*) AS orders, 
    SUM(net_revenue) AS revenue
FROM eshop_staging2
GROUP BY year, month
ORDER BY  year, revenue;

-- The number of orders is growing across all countries
SELECT 
	YEAR(order_date) AS year, 
	MONTH(order_date) AS month, 
    country, 
    COUNT(*) AS orders
FROM eshop_staging2
GROUP BY year, month, country
ORDER BY  country,  year, month;
 
 
 -- The highest revenue growth from 2024 to 2025 is in Sports (+29%), while the lowest is in Home (+19%)
WITH yearly AS (
    SELECT
        product_category,
        YEAR(order_date) AS year,
        SUM(net_revenue) AS revenue
    FROM eshop_staging2
    GROUP BY product_category, YEAR(order_date)
)
SELECT
    y1.product_category,
    y1.revenue AS revenue_2024,
    y2.revenue AS revenue_2025,
    ROUND((y2.revenue - y1.revenue) / NULLIF(y1.revenue, 0) * 100, 1) AS growth_pct
FROM yearly y1
JOIN yearly y2
    ON y1.product_category = y2.product_category
WHERE y1.year = 2024
  AND y2.year = 2025
ORDER BY growth_pct DESC;

-- Order counts peak in November and December, with 1.5–2x more orders than other months. Peaks were larger in 2025 than in 2024.
SELECT
	YEAR(order_date) AS year,
	MONTH(order_date) AS month,
    product_category,
	COUNT(*) AS orders
FROM eshop_staging2
GROUP BY year, month, product_category
ORDER BY year, month;



-- MARKETING CHANNELS

-- When analyzing revenue by marketing channel, organic, paid search, and direct are the leading channels
-- Comparing 2024 and 2025, paid social increased its share by 4.5% (from 9% to 13.5%), taking share mainly from organic, direct, email, and affiliate channels
-- organic and paid search got us the most new customers.
SELECT 
    YEAR(order_date) AS year,
    marketing_channel,
    ROUND(SUM(net_revenue) * 100.0 / SUM(SUM(net_revenue)) OVER (PARTITION BY YEAR(order_date)), 2 ) AS pct_revenue,
	ROUND(SUM(is_new_customer) * 100.0 / SUM(SUM(is_new_customer)) OVER (PARTITION BY YEAR(order_date)), 1 ) AS pct_new_customers
FROM eshop_staging2
WHERE marketing_channel<>''
GROUP BY year, marketing_channel;


-- email has biggest discount % (10%) instead of normal 6%
SELECT 
	YEAR(order_date) AS year,
    marketing_channel,
	ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY YEAR(order_date)),1) AS pct_orders,
    SUM(is_new_customer) AS sum_of_new_customers,
    ROUND(SUM(gross_revenue) /COUNT(*)) AS avg_order_value,
    ROUND(AVG(discount_pct),2) AS avg_pct_discount
FROM eshop_staging2
WHERE marketing_channel <> ''
GROUP BY YEAR(order_date), marketing_channel
ORDER BY year;

-- In 2025, there were approximately 1.5–2x more monthly orders from paid social throughout the year, with peaks in January, February and November
-- In January, March, and October those orders have a lower average value. While in February, April, September, and winter holidays (November, December), we see bigger numbers
WITH yearly AS (
    SELECT 
		YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        COUNT(*) AS orders,
        SUM(net_revenue) AS revenue
    FROM eshop_staging2 
    WHERE marketing_channel = 'paid_social'
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    y2025.month,
    y2024.orders AS orders_2024,
    y2025.orders AS orders_2025,
    (y2025.orders - y2024.orders) *100/ y2024.orders AS diff_orders,
	ROUND(y2024.revenue / y2024.orders) AS avg_order_value_2024,
    ROUND(y2025.revenue / y2025.orders) AS avg_order_value_2025
FROM yearly y2024
JOIN yearly y2025
    ON y2024.month = y2025.month
WHERE y2024.year = 2024
  AND y2025.year = 2025
ORDER BY y2025.month;



-- DEVICE USAGE

-- Mobile usage increased significantly in 2025, strengthening its leading position
-- Other device types remained relatively stable
SELECT 
	YEAR(order_date) AS year,
	device_type,
	COUNT(*) AS orders
FROM eshop_staging2
GROUP BY year, device_type
ORDER BY year, orders DESC;

-- This growth is consistent across both new and returning customers
SELECT
	YEAR(order_date) AS year,
	device_type, 
	COUNT(*) AS orders,
	is_new_customer
FROM eshop_staging2
WHERE device_type='mobile'
GROUP BY is_new_customer, device_type, year;



-- REFUNDS

-- Electronics has the highest refund rate (5.1%), while Sports and Home are the lowest (around 3.2%)
SELECT
    product_category,
    COUNT(*) AS total_orders,
    SUM(refund_flag) AS refunded_orders,
    ROUND(SUM(refund_flag) * 100.0 / COUNT(*), 1) AS refund_rate_pct
FROM eshop_staging2
GROUP BY product_category
ORDER BY refund_rate_pct DESC;

-- Most refund activity occurs in November and December. We classically see 2x spike those months, but unlike general orders, there is also elevated activity in January and May
-- electronics experienced a more significant spike, with 3x more returned orders in November 2025.
SELECT
	YEAR(order_date) AS year,
	MONTH(order_date) AS month,
    product_category,
	COUNT(*) AS refunded_orders
FROM eshop_staging2
WHERE refund_flag=1
GROUP BY year, month, product_category
ORDER BY year, month;


-- The November 2025 spike is spread across channels — organic and paid search each account for multiple refunded orders, so there's no single campaign culprit.  Refund value is also different. So its not one product
SELECT
    marketing_channel,
    discount_pct,
    units,
    COUNT(*) AS refunded_orders,
    ROUND(AVG(refunded_amount)) AS avg_refund_value
FROM eshop_staging2
WHERE refund_flag = 1 
  AND product_category = 'electronics'
  AND YEAR(order_date) = 2025 
  AND MONTH(order_date) = 11
GROUP BY marketing_channel, discount_pct, units
ORDER BY refunded_orders DESC;



-- COUPONS

-- Coupon usage gives avg 18% discount instead of a casual 5% without a coupon, and orders get 15% less net revenue
SELECT
    CASE WHEN coupon_code <> '' 
         THEN 'with coupon' ELSE 'no coupon' END AS coupon_used,
    COUNT(*) AS orders,
    ROUND(AVG(net_revenue)) AS avg_net_revenue,
    ROUND(AVG(discount_pct)) AS avg_discount_pct
FROM eshop_staging2
GROUP BY coupon_used;

-- Coupons are used relatively evenly
SELECT 
	COUNT(*) AS orders, 
	coupon_code
FROM eshop_staging2 
WHERE coupon_code<>''
GROUP BY coupon_code;
        
-- Coupons are used throughout the year, but peak in November and December, which does not fully align with coupons like “Spring” or “BF2025”
SELECT 
	coupon_code, 
	COUNT(*) AS orders, 
    YEAR(order_date) AS year, 
    MONTH(order_date) AS month
FROM eshop_staging2
WHERE coupon_code<>''
GROUP BY coupon_code, `year`, `month`
ORDER BY  coupon_code, `year`, `month`;



-- DISCOUNT

 -- higher-discount have lower net revenue and orders with big discount have a lower refund rate (2% instead of 3-4% for other categories). The most orders and the biggest refund has 1-10% discount category
 SELECT 
    CASE WHEN discount_pct = 0 THEN '0% discount'
         WHEN discount_pct <= 10 THEN '1-10% discount'
         WHEN discount_pct <= 20 THEN '11-20% discount'
         ELSE '20%+ discount' END AS discount_tier,
    COUNT(*) AS orders,
    ROUND(AVG(net_revenue)) AS avg_net_revenue,
    ROUND(SUM(CASE WHEN refund_flag=1 THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS refund_rate
FROM eshop_staging2
GROUP BY discount_tier;

 -- Discounted orders come mainly from organic and paid search, where we have a good refund rate of 3.55. The biggest refund rate has affiliate channel with 5%. Also, we have the fewest orders from that channel
SELECT 
    marketing_channel,
    COUNT(*) AS orders,
    ROUND(AVG(discount_pct), 1) AS avg_discount_pct,
    ROUND(AVG(discount_amount)) AS avg_discount_amount,
    ROUND(SUM(CASE WHEN refund_flag=1 THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS refund_rate
FROM eshop_staging2
WHERE discount_pct > 0
GROUP BY marketing_channel
ORDER BY orders DESC;