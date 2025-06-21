-- =============================================
-- 1. Create databases and set context
-- =============================================

CREATE DATABASE project_3;
GO

USE project_3;
GO

-- =============================================
-- 2. Table: olist_products_dataset
-- =============================================

-- Drop and create table
IF OBJECT_ID('dbo.olist_products_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.olist_products_dataset;
GO

CREATE TABLE dbo.olist_products_dataset (
    product_id VARCHAR(50) NULL,
    product_category_name VARCHAR(50) NULL,
    product_name_lenght INT NULL,
    product_description_lenght INT NULL,
    product_photos_qty INT NULL,
    product_weight_g INT NULL,
    product_length_cm INT NULL,
    product_height_cm INT NULL,
    product_width_cm INT NULL
);
GO

-- Clean product_id from double quotes
UPDATE dbo.olist_products_dataset
SET product_id = REPLACE(product_id, '"', '')
WHERE product_id LIKE '%"%';

-- Validate non-numeric values
SELECT product_name_lenght FROM dbo.olist_products_dataset WHERE ISNUMERIC(CAST(product_name_lenght AS VARCHAR)) = 0;
SELECT product_width_cm FROM dbo.olist_products_dataset WHERE ISNUMERIC(CAST(product_width_cm AS VARCHAR)) = 0;

-- =============================================
-- 3. Table: olist_orders_dataset
-- =============================================

IF OBJECT_ID('dbo.olist_orders_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.olist_orders_dataset;
GO

CREATE TABLE dbo.olist_orders_dataset (
    order_id VARCHAR(50) PRIMARY KEY NOT NULL,
    customer_id VARCHAR(50) NULL,
    order_status VARCHAR(50) NULL,
    order_purchase_timestamp DATETIME NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NULL
);
GO

-- Clean order_id from double quotes
UPDATE dbo.olist_orders_dataset
SET order_id = REPLACE(order_id, '"', '')
WHERE order_id LIKE '%"%';

-- Validate invalid dates
SELECT order_estimated_delivery_date FROM dbo.olist_orders_dataset WHERE ISDATE(order_estimated_delivery_date) = 0;

-- =============================================
-- 4. Table: olist_sellers_dataset
-- =============================================

IF OBJECT_ID('dbo.olist_sellers_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.olist_sellers_dataset;
GO

CREATE TABLE dbo.olist_sellers_dataset (
    seller_id VARCHAR(50) PRIMARY KEY NOT NULL,
    seller_zip_code_prefix INT NULL,
    seller_city VARCHAR(50) NULL,
    seller_state VARCHAR(50) NULL
);
GO

-- Clean zip code prefix from double quotes and convert to INT
UPDATE dbo.olist_sellers_dataset
SET seller_zip_code_prefix = TRY_CAST(REPLACE(CAST(seller_zip_code_prefix AS VARCHAR), '"', '') AS INT)
WHERE seller_zip_code_prefix LIKE '%"%';

-- =============================================
-- 5. Table: olist_customers_dataset
-- =============================================

IF OBJECT_ID('dbo.olist_customers_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.olist_customers_dataset;
GO

CREATE TABLE dbo.olist_customers_dataset (
    customer_id VARCHAR(50) PRIMARY KEY NOT NULL,
    customer_unique_id VARCHAR(50) NULL,
    customer_zip_code_prefix INT NULL,
    customer_city VARCHAR(50) NULL,
    customer_state VARCHAR(50) NULL
);
GO

-- Clean customer_zip_code_prefix from double quotes and convert to INT
UPDATE dbo.olist_customers_dataset
SET customer_zip_code_prefix = TRY_CAST(REPLACE(CAST(customer_zip_code_prefix AS VARCHAR), '"', '') AS INT)
WHERE customer_zip_code_prefix LIKE '%"%';

-- =============================================
-- 6. Table: olist_order_items_dataset
-- =============================================

IF OBJECT_ID('dbo.olist_order_items_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.olist_order_items_dataset;
GO

CREATE TABLE dbo.olist_order_items_dataset (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NULL,
    product_id VARCHAR(50) NULL,
    seller_id VARCHAR(50) NULL,
    shipping_limit_date DATETIME NULL,
    price MONEY NULL,
    freight_value MONEY NULL
);
GO

-- Note: Primary keys are not defined here due to expected duplicates in order_id and seller_id
-- Validate non-numeric values in freight_value column
SELECT * FROM dbo.olist_order_items_dataset WHERE ISNUMERIC(CAST(freight_value AS VARCHAR)) = 0;

-- =============================================
-- 7. Table: olist_order_payments_dataset
-- =============================================

IF OBJECT_ID('dbo.olist_order_payments_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.olist_order_payments_dataset;
GO

CREATE TABLE dbo.olist_order_payments_dataset (
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NULL,
    payment_type VARCHAR(50) NULL,
    payment_installments INT NULL,
    payment_value MONEY NULL
);
GO

-- Note: This table can contain repeated order_id values due to multiple payment methods
-- Validate duplicates for analytical purposes
SELECT order_id, COUNT(*) AS occurrences
FROM dbo.olist_order_payments_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Clean double quotes if needed
UPDATE dbo.olist_order_payments_dataset
SET order_id = REPLACE(order_id, '"', '')
WHERE order_id LIKE '%"%';

-- =============================================
-- 8. Table: olist_order_reviews_dataset
-- =============================================

IF OBJECT_ID('dbo.olist_order_reviews_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.olist_order_reviews_dataset;
GO

CREATE TABLE dbo.olist_order_reviews_dataset (
    review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NULL,
    review_score INT NULL,
    review_comment_title VARCHAR(50) NULL,
    review_comment_message VARCHAR(50) NULL,
    review_creation_date DATETIME NULL,
    review_answer_timestamp DATETIME NULL,
    PRIMARY KEY (review_id)
);
GO

-- Clean double quotes from review-related fields
UPDATE dbo.olist_order_reviews_dataset SET review_id = REPLACE(review_id, '"', '');
UPDATE dbo.olist_order_reviews_dataset SET order_id = REPLACE(order_id, '"', '');
UPDATE dbo.olist_order_reviews_dataset SET review_creation_date = REPLACE(review_creation_date, '"', '');
UPDATE dbo.olist_order_reviews_dataset SET review_answer_timestamp = REPLACE(review_answer_timestamp, '"', '');

-- =============================================
-- 9. Table: product_category_name_translation
-- =============================================

IF OBJECT_ID('dbo.product_category_name_translation', 'U') IS NOT NULL
    DROP TABLE dbo.product_category_name_translation;
GO

CREATE TABLE dbo.product_category_name_translation (
    product_category_name VARCHAR(50) NULL,
    product_category_name_english VARCHAR(50) NULL
);
GO

-- =============================================
-- 10. Table: olist_geolocation_dataset
-- =============================================

IF OBJECT_ID('dbo.olist_geolocation_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.olist_geolocation_dataset;
GO

CREATE TABLE dbo.olist_geolocation_dataset (
    geolocation_zip_code_prefix VARCHAR(50) NULL,
    geolocation_lat VARCHAR(50) NULL,
    geolocation_lng VARCHAR(50) NULL,
    geolocation_city VARCHAR(50) NULL,
    geolocation_state VARCHAR(50) NULL
);
GO

-- Clean quotes from geolocation columns
UPDATE dbo.olist_geolocation_dataset SET geolocation_zip_code_prefix = REPLACE(geolocation_zip_code_prefix, '"', '');
UPDATE dbo.olist_geolocation_dataset SET geolocation_lat = REPLACE(geolocation_lat, '"', '');
UPDATE dbo.olist_geolocation_dataset SET geolocation_lng = REPLACE(geolocation_lng, '"', '');
UPDATE dbo.olist_geolocation_dataset SET geolocation_city = REPLACE(geolocation_city, '"', '');
UPDATE dbo.olist_geolocation_dataset SET geolocation_state = REPLACE(geolocation_state, '"', '');


-- =============================================
-- 11. Analysis and Visualization Queries (Part 1)
-- =============================================

-- Merge Product Categories (Portuguese to English)
SELECT pd.product_id, pd.product_category_name AS portuguese_category, pct.product_category_name AS english_category 
FROM dbo.olist_products_dataset AS pd
LEFT JOIN dbo.product_category_name_translation AS pct 
  ON pd.product_category_name = pct.product_category_name;

-- Update Product Category Names to English
UPDATE pd
SET pd.product_category_name = pct.product_category_name_english
FROM dbo.olist_products_dataset AS pd
INNER JOIN dbo.product_category_name_translation AS pct
  ON pd.product_category_name = pct.product_category_name;

-- Total Sales by Product Category
SELECT pd.product_category_name, COUNT(*) AS total_sales 
FROM dbo.olist_products_dataset pd
JOIN dbo.olist_products_dataset oi ON oi.product_id = pd.product_id
GROUP BY pd.product_category_name
ORDER BY total_sales DESC;

-- Average Delivery Time (Approved to Delivered)
SELECT order_id, DATEDIFF(DAY, order_approved_at, order_delivered_customer_date) AS delivery_days
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL;

-- Average Review Score per Seller
SELECT oi.seller_id, AVG(r.review_score) AS avg_rating
FROM dbo.olist_order_items_dataset oi
JOIN dbo.olist_order_reviews_dataset r ON oi.order_id = r.order_id
GROUP BY oi.seller_id
ORDER BY avg_rating DESC;

-- Average Delivery Time by Customer State
SELECT c.customer_state, AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_days
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL
  AND o.order_delivered_customer_date >= o.order_purchase_timestamp
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- Difference Between Estimated and Actual Delivery Date by State
SELECT c.customer_state AS state, 
       AVG(DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date)) AS avg_days_difference
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_delivered_customer_date >= o.order_purchase_timestamp
GROUP BY c.customer_state
ORDER BY avg_days_difference DESC;

-- Late vs On-Time Deliveries by State
SELECT c.customer_state AS state,
       SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_deliveries,
       SUM(CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS on_time_or_early_deliveries
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_deliveries DESC;

-- Canceled Orders by Product Category
SELECT p.product_category_name AS product_category, COUNT(DISTINCT o.order_id) AS cancelled_orders
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_order_items_dataset i ON o.order_id = i.order_id
JOIN dbo.olist_products_dataset p ON i.product_id = p.product_id
WHERE o.order_status = 'canceled'
GROUP BY p.product_category_name
ORDER BY cancelled_orders DESC;

-- Total Sales by Customer State
SELECT c.customer_state AS state, SUM(i.price + i.freight_value) AS total_sales
FROM dbo.olist_order_items_dataset i
JOIN dbo.olist_orders_dataset o ON i.order_id = o.order_id
JOIN dbo.olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_sales DESC;

-- Total Sales by Seller State
SELECT s.seller_state AS state, SUM(i.price + i.freight_value) AS total_sales
FROM dbo.olist_order_items_dataset i
JOIN dbo.olist_orders_dataset o ON i.order_id = o.order_id
JOIN dbo.olist_sellers_dataset s ON i.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY total_sales DESC;

-- Average Order Ticket
SELECT AVG(order_total) AS average_ticket_per_order
FROM (
    SELECT o.order_id, SUM(i.price + i.freight_value) AS order_total
    FROM dbo.olist_orders_dataset o
    JOIN dbo.olist_order_items_dataset i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
) AS order_totals;

-- Best-Selling Product per Category
WITH product_sales AS (
    SELECT p.product_category_name, i.product_id,
           COUNT(i.order_item_id) AS total_sold,
           ROW_NUMBER() OVER (PARTITION BY p.product_category_name ORDER BY COUNT(i.order_item_id) DESC) AS rank_in_category
    FROM dbo.olist_order_items_dataset i
    JOIN dbo.olist_products_dataset p ON i.product_id = p.product_id
    GROUP BY p.product_category_name, i.product_id
)
SELECT product_category_name, product_id, total_sold
FROM product_sales
WHERE rank_in_category = 1
ORDER BY total_sold DESC;

-- Most Popular Product Categories
SELECT p.product_id, p.product_category_name, COUNT(*) AS quantity_sold
FROM dbo.olist_order_items_dataset i
JOIN dbo.olist_products_dataset p ON i.product_id = p.product_id
GROUP BY p.product_id, p.product_category_name
ORDER BY quantity_sold DESC;


-- =============================================
-- 12. Analysis and Visualization Queries (Part 2)
-- =============================================

-- Geographic Distribution of Customers by State and City
SELECT customer_state AS state, customer_city AS city, COUNT(*) AS number_of_customers
FROM dbo.olist_customers_dataset
GROUP BY customer_state, customer_city
ORDER BY customer_state, number_of_customers DESC;

-- Average Delivery Time by Customer State (duplicate handling)
SELECT c.customer_state, 
       AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_days
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- Average Rating by Seller State
SELECT s.seller_state, ROUND(AVG(r.review_score), 2) AS avg_rating
FROM dbo.olist_order_reviews_dataset r
JOIN dbo.olist_order_items_dataset i ON r.order_id = i.order_id
JOIN dbo.olist_sellers_dataset s ON i.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY avg_rating DESC;

-- Total Customers by State
SELECT customer_state, COUNT(DISTINCT customer_id) AS total_customers
FROM dbo.olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Total Sales by Customer State
SELECT c.customer_state, ROUND(SUM(oi.price), 2) AS total_sales
FROM dbo.olist_customers_dataset c
JOIN dbo.olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN dbo.olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_sales DESC;

-- Customer Segmentation by Product Category
SELECT p.product_category_name, COUNT(DISTINCT o.customer_id) AS total_customers
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN dbo.olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_customers DESC;

-- Customer Segmentation by Purchase Frequency
WITH customer_frequency AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS total_orders
    FROM dbo.olist_orders_dataset
    GROUP BY customer_id
)
SELECT customer_id, total_orders,
    CASE 
        WHEN total_orders = 1 THEN 'Low Frequency'
        WHEN total_orders BETWEEN 2 AND 3 THEN 'Medium Frequency'
        ELSE 'High Frequency'
    END AS frequency_segment
FROM customer_frequency
ORDER BY total_orders DESC;

-- Frequency Segment Distribution
WITH customer_frequency AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS total_orders
    FROM dbo.olist_orders_dataset
    GROUP BY customer_id
),
frequency_segments AS (
    SELECT customer_id, total_orders,
        CASE 
            WHEN total_orders = 1 THEN 'Low Frequency'
            WHEN total_orders BETWEEN 2 AND 3 THEN 'Medium Frequency'
            ELSE 'High Frequency'
        END AS frequency_segment
    FROM customer_frequency
)
SELECT frequency_segment, COUNT(customer_id) AS total_customers
FROM frequency_segments
GROUP BY frequency_segment
ORDER BY 
    CASE 
        WHEN frequency_segment = 'Low Frequency' THEN 1
        WHEN frequency_segment = 'Medium Frequency' THEN 2
        WHEN frequency_segment = 'High Frequency' THEN 3
    END;


-- Monthly Order Trends
SELECT 
  FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
  COUNT(DISTINCT order_id) AS total_orders
FROM dbo.olist_orders_dataset
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;

-- Monthly Revenue
SELECT 
  FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS monthly_revenue
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_order_items_dataset oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;

-- Monthly Cancellations
SELECT 
  FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
  COUNT(order_id) AS cancelled_orders
FROM dbo.olist_orders_dataset
WHERE order_status = 'canceled'
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;

-- Top States by Revenue
SELECT c.customer_state,
       ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue
FROM dbo.olist_order_items_dataset oi
JOIN dbo.olist_orders_dataset o ON oi.order_id = o.order_id
JOIN dbo.olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- Product Categories with Highest Return Rate
SELECT p.product_category_name,
       COUNT(CASE WHEN o.order_status = 'unavailable' THEN 1 END) AS returns,
       COUNT(*) AS total_orders,
       ROUND(COUNT(CASE WHEN o.order_status = 'unavailable' THEN 1 END) * 100.0 / COUNT(*), 2) AS return_rate_percent
FROM dbo.olist_order_items_dataset oi
JOIN dbo.olist_orders_dataset o ON oi.order_id = o.order_id
JOIN dbo.olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY return_rate_percent DESC;

-- Customer Loyalty Score (Repeat Purchases)
SELECT customer_id,
       COUNT(DISTINCT order_id) AS total_orders,
       CASE 
         WHEN COUNT(DISTINCT order_id) = 1 THEN 'One-time'
         WHEN COUNT(DISTINCT order_id) BETWEEN 2 AND 3 THEN 'Returning'
         ELSE 'Loyal'
       END AS loyalty_segment
FROM dbo.olist_orders_dataset
GROUP BY customer_id
ORDER BY total_orders DESC;


-- =============================================
-- 13. Exploratory Data Analysis: State-Level Sales Summary
-- =============================================

-- EDA: Summary of Sales Metrics by Seller State
SELECT
    COUNT(State) AS num_states,
    SUM(Total_Sales) AS total_sales,
    AVG(Total_Sales) AS avg_sales,
    MAX(Total_Sales) AS max_sales,
    MIN(Total_Sales) AS min_sales
FROM (
    SELECT 
        s.seller_state AS State,
        SUM(i.price + i.freight_value) AS Total_Sales
    FROM dbo.olist_order_items_dataset i
    JOIN dbo.olist_orders_dataset o ON i.order_id = o.order_id
    JOIN dbo.olist_sellers_dataset s ON i.seller_id = s.seller_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_state
) AS state_sales_summary;

