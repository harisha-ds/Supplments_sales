
use supplements;

-- kpi's :
-- total revenue :
SELECT SUM(revenue) AS total_revenue FROM sales;
-- units_sold :
SELECT SUM(units_sold) AS total_units_sold
FROM sales;
-- Units Returned / Return Rate % : 
SELECT SUM(units_returned) AS total_returns,SUM(units_sold) AS total_sold,
ROUND(SUM(units_returned) * 100.0 / SUM(units_sold), 2) AS return_rate_pct
FROM sales;
-- Net Revenue after Returns
SELECT SUM(revenue) AS gross_revenue,
ROUND(SUM(units_returned * (revenue/units_sold)),2) AS loss_due_to_returns,
SUM(revenue) - ROUND(SUM(units_returned * (revenue/units_sold)),2) AS net_revenue
FROM sales;

-- return rate %
SELECT ROUND(SUM(units_returned)*100.0 / SUM(units_sold), 2) AS return_rate_pct
FROM sales;

-- net revenue after returns :
SELECT SUM(revenue) - SUM(units_returned * (revenue/units_sold)) AS net_revenue
FROM sales;

-- total money “spent” on discounts.
SELECT SUM(discount * revenue / 100) AS total_discount_amount
FROM sales;


-- top selling products by revenue
SELECT p.product, SUM(s.revenue) AS total_revenue,
SUM(s.units_sold) AS total_units 
FROM sales s 
INNER JOIN products p ON s.product_id = p.product_id 
GROUP BY p.product 
ORDER BY total_revenue DESC
LIMIT 5; 
 
 
 -- underperforming products by revenue
SELECT p.product, SUM(s.revenue) AS total_revenue,
SUM(s.units_sold) AS total_units
FROM sales s
INNER JOIN products p ON s.product_id = p.product_id
GROUP BY p.product 
ORDER BY total_revenue ASC 
LIMIT 5;
 
 
 -- high return products 
 SELECT p.product,SUM(s.units_returned) AS total_returns, 
ROUND(SUM(s.units_returned) * 100.0 / SUM(s.units_sold), 2) AS return_rate_pct FROM sales s
INNER JOIN products p ON s.product_id = p.product_id GROUP BY p.product
 HAVING SUM(s.units_sold) > 0 ORDER BY return_rate_pct DESC LIMIT 5; 
 
 -- revenue by category 
 SELECT p.category,SUM(s.revenue) AS total_revenue FROM sales s 
 INNER JOIN products p ON s.product_id = p.product_id 
 GROUP BY p.category ORDER BY total_revenue DESC;
 
 SELECT p.category,p.product,SUM(s.revenue) AS total_revenue 
 FROM sales s 
 INNER JOIN products p ON s.product_id = p.product_id 
 GROUP BY p.category,p.product
 ORDER BY total_revenue DESC;
 

select*from products where category is null ;
 -- sales by location 
SELECT l.location_name,SUM(s.revenue) AS total_revenue,
SUM(s.units_sold) AS total_units 
FROM sales s 
INNER JOIN locations l ON s.location_id = l.location_id 
GROUP BY l.location_name 
ORDER BY total_revenue DESC;
 
 -- sales by platform 
SELECT f.platform_name,SUM(s.revenue) AS total_revenue,
SUM(s.units_sold) AS total_units 
FROM sales s 
INNER JOIN platforms f ON s.platform_id = f.platform_id 
GROUP BY f.platform_name 
ORDER BY total_revenue DESC;
 
 -- impact of discounts on sales and revenue
 SELECT l.location_name,CASE WHEN s.discount = 0 THEN 'No Discount'
 WHEN s.discount BETWEEN 1 AND 10 THEN '1-10%'
 WHEN s.discount BETWEEN 11 AND 20 THEN '11-20%' 
 ELSE '20%+' 
 END AS discount_range, 
 SUM(s.revenue) AS total_revenue, COUNT(*) AS transactions FROM sales s
 inner join locations as l on l.location_id=s.location_id
 GROUP BY discount_range,l.location_name
ORDER BY total_revenue DESC; 

 
 -- time period sales 
 SELECT DATE_FORMAT(s.sale_date, '%Y-%m') AS month, SUM(s.revenue) AS total_revenue,
 SUM(s.units_sold) AS total_units, SUM(s.units_returned) AS total_returns 
 FROM sales s GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m') ORDER BY month;
 
 -- 2. Monthly Revenue Across All Years
SELECT YEAR(sale_date) AS year, MONTH(sale_date) AS month,
SUM(revenue) AS total_revenue 
FROM sales 
GROUP BY YEAR(sale_date), MONTH(sale_date) 
ORDER BY year, MONTH(sale_date);
 
 -- 3. Quarterly Revenue Across All Years 
SELECT YEAR(sale_date) AS year, QUARTER(sale_date) AS quarter,
SUM(revenue) AS total_revenue 
FROM sales
GROUP BY YEAR(sale_date), QUARTER(sale_date) 
ORDER BY year, quarter; 
 
 -- Profitability After Returns
 SELECT p.product,SUM(s.revenue) AS gross_revenue, ROUND(SUM(s.units_returned * (s.revenue/s.units_sold)),3) AS loss_due_to_returns, 
 (SUM(s.revenue) - SUM(s.units_returned * (s.revenue/s.units_sold))) AS net_revenue FROM sales s
 INNER JOIN products p ON s.product_id = p.product_id GROUP BY p.product ORDER BY net_revenue DESC;
 
 -- unprofitable products 
 SELECT p.product,SUM(s.revenue) AS gross_revenue, ROUND(SUM(s.units_returned * (s.revenue/s.units_sold)),3) AS loss_due_to_returns, 
 (SUM(s.revenue) - SUM(s.units_returned * (s.revenue/s.units_sold))) AS net_revenue FROM sales s
 INNER JOIN products p ON s.product_id = p.product_id GROUP BY p.product ORDER BY net_revenue ASC; 
 
 -- Return Rate by Category
 SELECT p.category, SUM(s.units_returned) AS total_returns, SUM(s.units_sold) AS total_sold, 
 ROUND(SUM(s.units_returned)*100.0 / SUM(s.units_sold),2) AS return_rate_percent FROM sales s
 INNER JOIN products p ON s.product_id = p.product_id GROUP BY p.category ORDER BY return_rate_percent DESC;
 
 -- Revenue Contribution by Category (Optional KPI) 
SELECT p.category, SUM(s.revenue) AS total_revenue,
ROUND(SUM(s.revenue) * 100.0 / (SELECT SUM(revenue) FROM sales), 2) AS contribution_percent 
FROM sales s 
INNER JOIN products p ON s.product_id = p.product_id 
GROUP BY p.category 
ORDER BY total_revenue DESC;
 
 
-- Profitability After Returns & Unprofitable Products
 SELECT p.product,SUM(s.revenue) AS gross_revenue,
ROUND(SUM(CASE WHEN s.units_sold > 0 THEN s.units_returned * (s.revenue/s.units_sold) ELSE 0 END), 2) AS loss_due_to_returns,
(SUM(s.revenue) - SUM(CASE WHEN s.units_sold > 0 THEN s.units_returned * (s.revenue/s.units_sold) ELSE 0 END)) AS net_revenue
FROM sales s
INNER JOIN products p ON s.product_id = p.product_id
GROUP BY p.product
ORDER BY net_revenue DESC;

 WITH product_sales AS (SELECT 
p.category,p.product,SUM(s.revenue) AS total_revenue
FROM sales s
INNER JOIN products p ON s.product_id = p.product_id
GROUP BY p.category, p.product)
SELECT category,product,total_revenue,
ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS product_rank
FROM product_sales WHERE total_revenue > 0
ORDER BY category, product_rank;

-- Profitability After Returns
SELECT p.product,SUM(s.revenue) AS gross_revenue,
SUM(s.units_returned * (s.revenue/s.units_sold)) AS loss_due_to_returns,
(SUM(s.revenue) - SUM(s.units_returned * (s.revenue/s.units_sold))) AS net_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product
ORDER BY net_revenue DESC ;

SELECT p.product,
       AVG(s.discount) AS avg_discount,
       SUM(s.units_sold) AS total_units,
       SUM(s.revenue) AS total_revenue,
       SUM(s.units_sold) / NULLIF(COUNT(DISTINCT s.sale_date),0) AS avg_units_per_day
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product
ORDER BY avg_discount DESC;



-- Total Returns Over Time (Monthly/Quarterly)
-- Monthly Returns
SELECT DATE_FORMAT(s.sale_date, '%Y-%m') AS month,
       SUM(s.units_returned) AS total_returns
FROM sales s
GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY month;



-- Quarterly Returns
SELECT YEAR(s.sale_date) AS year,
       QUARTER(s.sale_date) AS quarter,
       SUM(s.units_returned) AS total_returns
FROM sales s
GROUP BY YEAR(s.sale_date), QUARTER(s.sale_date)
ORDER BY year, quarter;


SELECT DATE_FORMAT(s.sale_date, '%Y-%m') AS month,
       SUM(s.units_sold) AS total_sold,
       SUM(s.units_returned) AS total_returns,
       ROUND(SUM(s.units_returned) * 100.0 / SUM(s.units_sold), 2) AS return_rate_pct
FROM sales s
GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY month;


-- mom :
SELECT 
    DATE_FORMAT(s.sale_date, '%Y-%m') AS month,
    SUM(s.revenue) AS total_revenue,
    ROUND(
        (SUM(s.revenue) - LAG(SUM(s.revenue)) OVER (ORDER BY DATE_FORMAT(s.sale_date, '%Y-%m')))
        / LAG(SUM(s.revenue)) OVER (ORDER BY DATE_FORMAT(s.sale_date, '%Y-%m')) * 100, 2
    ) AS mom_growth_pct
FROM sales s
GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY month;


-- yoy sales :
SELECT 
    YEAR(s.sale_date) AS year,
    SUM(s.revenue) AS total_revenue,
    ROUND(
        (SUM(s.revenue) - LAG(SUM(s.revenue)) OVER (ORDER BY YEAR(s.sale_date)))
        / LAG(SUM(s.revenue)) OVER (ORDER BY YEAR(s.sale_date)) * 100, 2
    ) AS yoy_growth_pct
FROM sales s
GROUP BY YEAR(s.sale_date)
ORDER BY year;

-- monthly revenue by year : 
SELECT 
    YEAR(s.sale_date) AS year,
    MONTH(s.sale_date) AS month,
    SUM(s.revenue) AS total_revenue
FROM sales s
GROUP BY YEAR(s.sale_date), MONTH(s.sale_date)
ORDER BY year, month;

-- yoy growth by month : 
SELECT 
    YEAR(s.sale_date) AS year,
    MONTH(s.sale_date) AS month,
    SUM(s.revenue) AS total_revenue,
    ROUND(
        (SUM(s.revenue) - LAG(SUM(s.revenue)) OVER (PARTITION BY MONTH(s.sale_date) ORDER BY YEAR(s.sale_date)))
        / LAG(SUM(s.revenue)) OVER (PARTITION BY MONTH(s.sale_date) ORDER BY YEAR(s.sale_date)) * 100, 2
    ) AS yoy_growth_pct
FROM sales s
GROUP BY YEAR(s.sale_date), MONTH(s.sale_date)
ORDER BY year, month;

-- yoy growth by category :
SELECT 
    YEAR(s.sale_date) AS year,
    p.category,
    SUM(s.revenue) AS total_revenue,
    ROUND(
        (SUM(s.revenue) - LAG(SUM(s.revenue)) OVER (PARTITION BY p.category ORDER BY YEAR(s.sale_date)))
        / LAG(SUM(s.revenue)) OVER (PARTITION BY p.category ORDER BY YEAR(s.sale_date)) * 100, 2
    ) AS yoy_growth_pct
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY YEAR(s.sale_date), p.category
ORDER BY p.category, year;

-- revenue by category and year : 
SELECT 
    YEAR(s.sale_date) AS year,
    p.category,
    SUM(s.revenue) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY YEAR(s.sale_date), p.category
ORDER BY year, total_revenue DESC;

-- -------------------------




-- Total Revenue
SELECT SUM(revenue) AS total_revenue
FROM sales;

-- Total Units Sold
SELECT SUM(units_sold) AS total_units_sold
FROM sales;

-- Net Revenue (after returns)
SELECT SUM(revenue) - SUM(units_returned * (revenue / NULLIF(units_sold,0))) AS net_revenue
FROM sales;

-- Return Rate %
SELECT ROUND(SUM(units_returned) * 100.0 / SUM(units_sold), 2) AS return_rate_percent
FROM sales
WHERE units_sold > 0;

-- Total Discount Amount
SELECT SUM(discount) AS total_discount_amount
FROM sales;
-- ---------

-- Total Returns
SELECT SUM(units_returned) AS total_returns
FROM sales;

-- Return Rate %
SELECT ROUND(SUM(units_returned) * 100.0 / SUM(units_sold), 2) AS return_rate_percent
FROM sales
WHERE units_sold > 0;

-- High Return Products (Top 5 by Return Rate %)
SELECT p.product,
       SUM(s.units_returned) AS total_returns,
       ROUND(SUM(s.units_returned) * 100.0 / SUM(s.units_sold), 2) AS return_rate_percent
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product
HAVING SUM(s.units_sold) > 0
ORDER BY return_rate_percent DESC
LIMIT 5;

--  high returns and revenue loss by products 
SELECT p.product,SUM(s.revenue) AS gross_revenue,
    ROUND(SUM(s.units_returned * (s.revenue / NULLIF(s.units_sold,0))), 2) AS revenue_loss_due_to_returns,
    (SUM(s.revenue) - SUM(s.units_returned * (s.revenue / NULLIF(s.units_sold,0)))) AS net_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product
ORDER BY revenue_loss_due_to_returns DESC
LIMIT 10;

-- by category revenue loss

SELECT p.category,SUM(s.revenue) AS gross_revenue,
    ROUND(SUM(s.units_returned * (s.revenue / NULLIF(s.units_sold,0))), 2) AS revenue_loss_due_to_returns,
    (SUM(s.revenue) - SUM(s.units_returned * (s.revenue / NULLIF(s.units_sold,0)))) AS net_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue_loss_due_to_returns DESC
LIMIT 10;



-- Average Discount %
SELECT ROUND(AVG(discount), 2) AS avg_discount_percent
FROM sales;

-- Weighted Average Discount % (by revenue)
SELECT ROUND(SUM(discount * revenue) / SUM(revenue), 2) AS weighted_avg_discount_percent
FROM sales;

-- % Revenue from Discounted Sales
SELECT ROUND(SUM(CASE WHEN discount > 0 THEN revenue ELSE 0 END) * 100.0 / SUM(revenue), 2) AS pct_revenue_from_discounted_sales
FROM sales;


-- Return Rate by platform
 SELECT p.platform_name, SUM(s.units_returned) AS total_returns, SUM(s.units_sold) AS total_sold, 
 ROUND(SUM(s.units_returned)*100.0 / SUM(s.units_sold),2) AS return_rate_percent FROM sales s
 INNER JOIN platforms p ON p.platform_id = s.platform_id GROUP BY p.platform_name ORDER BY return_rate_percent DESC;
 
-- Return Rate by location
 SELECT l.location_name, SUM(s.units_returned) AS total_returns, SUM(s.units_sold) AS total_sold, 
 ROUND(SUM(s.units_returned)*100.0 / SUM(s.units_sold),2) AS return_rate_percent FROM sales s
 INNER JOIN locations l ON s.location_id = l.location_id GROUP BY l.location_name ORDER BY return_rate_percent DESC;
 
 -- revenue loss by location and platform 
 SELECT p.category,SUM(s.revenue) AS gross_revenue,
    ROUND(SUM(s.units_returned * (s.revenue / NULLIF(s.units_sold,0))), 2) AS revenue_loss_due_to_returns,
    (SUM(s.revenue) - SUM(s.units_returned * (s.revenue / NULLIF(s.units_sold,0)))) AS net_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue_loss_due_to_returns DESC
LIMIT 10;
