-- =============================================
-- 1.Create database and set context
-- =============================================

CREATE DATABASE project_3;
GO

USE project_3;
GO


-- =============================================
-- 2. Table: olist_products_dataset
-- =============================================

-- Updating product_id, cleaning the database.
IF OBJECT_ID('dbo.olist_products_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.olist_products_dataset;
GO

CREATE TABLE dbo.olist_products_dataset (
    product_id VARCHAR(50) NULL,
    product_category_name VARCHAR(50) NULL,
    product_name_lenght INT NULL,          -- Cambié directamente a INT
    product_description_lenght INT NULL,
    product_photos_qty INT NULL,
    product_weight_g INT NULL,
    product_length_cm INT NULL,
    product_height_cm INT NULL,
    product_width_cm INT NULL
);
GO

UPDATE dbo.olist_products_dataset
SET product_id = REPLACE(product_id, '"', '')
WHERE product_id LIKE '%"%' ;

--Validating columns with non-numeric data (Cleaning)
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

-- cleaning data
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

-- cleaning data
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

-- Limpiar customer_zip_code_prefix
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

-- NOTA IMPORTANTE: No se debe definir PRIMARY KEY en order_id ni seller_id aquí,
-- porque esta tabla es de detalle, con múltiples items por pedido y vendedor.
-- Esto evita errores de duplicados.

-- Validar valores no numéricos en freight_value
SELECT * FROM dbo.olist_order_items_dataset WHERE ISNUMERIC(CAST(freight_value AS VARCHAR)) = 0;

-- Validar y corregir tipos de columnas ya definidos en la creación.

-- Limpiar posibles comillas en datos si existiesen (puedes agregar UPDATEs si es necesario)

-- =============================================
-- 7. Tabla: olist_order_payments_dataset
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

--En la tabla olist_order_items_dataset no se puede crear clave primaria debido a que sus tablas por su naturaleza tienen registros duplicados, estos son necesarios para el analisis

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'olist_order_items_dataset';

EXEC sp_rename 'olist_order_items_dataset.["order_id"]', 'order_id', 'COLUMN';
EXEC sp_rename 'olist_order_items_dataset.["order_item_id"]', 'order_item_id', 'COLUMN';
EXEC sp_rename 'olist_order_items_dataset.["product_id"]', 'product_id', 'COLUMN';
EXEC sp_rename 'olist_order_items_dataset.["seller_id"]', 'seller_id', 'COLUMN';
EXEC sp_rename 'olist_order_items_dataset.["shipping_limit_date"]', 'shipping_limit_date', 'COLUMN';
EXEC sp_rename 'olist_order_items_dataset.["price"]', 'price', 'COLUMN';
EXEC sp_rename 'olist_order_items_dataset.["freight_value"]', 'freight_value', 'COLUMN';

select * from [dbo].[olist_order_items_dataset]

CREATE TABLE [dbo].[olist_order_payments_dataset](
	order_id varchar(50) primary key NOT NULL,
	payment_sequential varchar(50) NULL,
	payment_type varchar(50) NULL,
	payment_installments varchar(50) NULL,
	payment_value varchar(50) NULL
);

select * from [dbo].[olist_order_payments_dataset]

ALTER TABLE [dbo].[olist_order_payments_dataset]
ALTER COLUMN  payment_sequential int;

ALTER TABLE [dbo].[olist_order_payments_dataset]
ALTER COLUMN  payment_installments int;

ALTER TABLE [dbo].[olist_order_payments_dataset]
ALTER COLUMN  payment_value money;

-- -En la tabla olist_order_payments_dataset no se puede crear clave primaria debido a que sus tablas por su naturaleza tienen registros duplicados, estos son necesarios para el analisis

drop table [dbo].[olist_order_payments_dataset]

ALTER TABLE [dbo].[olist_order_items_dataset]
ALTER COLUMN order_id VARCHAR(100) NOT NULL;

ALTER TABLE [olist_order_payments_dataset]
ADD CONSTRAINT PK_olist_order_payments_dataset PRIMARY KEY (order_id);

SELECT
    name
FROM
    sys.key_constraints
WHERE
    type = 'PK' AND
    parent_object_id = OBJECT_ID( '[dbo].[olist_order_payments_dataset]');

ALTER TABLE dbo.olist_order_payments_dataset
DROP CONSTRAINT PK__olist_or__4659622917FD9D80;

select * from [dbo].[olist_order_payments_dataset]


UPDATE [dbo].[olist_order_payments_dataset] SET order_id = REPLACE(order_id, '"', '')

SELECT order_id, COUNT(*) AS veces
FROM [dbo].[olist_order_payments_dataset]
GROUP BY order_id
HAVING COUNT(*) > 1;

--- La tabla tiene multiples valores que se repiten y no deben ser elminados, son necesarios para el analisis

use project_3
CREATE TABLE [dbo].[olist_order_reviews_dataset](
	review_id [varchar](50)NULL,
	order_id varchar(50) NULL,
	review_score varchar(50) NULL,
	review_comment_title varchar(50) NULL,
	review_comment_message varchar(50) NULL,
	review_creation_date varchar(50) NULL,
	review_answer_timestamp varchar(50) NULL
);


select * from [dbo].[olist_order_reviews_dataset]

EXEC sp_rename 'olist_order_reviews_dataset.["review_id"]', 'review_id', 'COLUMN';
EXEC sp_rename 'olist_order_reviews_dataset.["order_id"]', 'order_id', 'COLUMN';
EXEC sp_rename 'olist_order_reviews_dataset.["review_score"]', 'review_score', 'COLUMN';
EXEC sp_rename 'olist_order_reviews_dataset.["review_comment_title"]', 'review_comment_title', 'COLUMN';
EXEC sp_rename 'olist_order_reviews_dataset.["review_comment_message"]', 'review_comment_message', 'COLUMN';
EXEC sp_rename 'olist_order_reviews_dataset.[review_creation_date"]', 'review_creation_date', 'COLUMN';
EXEC sp_rename 'olist_order_reviews_dataset.["review_answer_timestamp"]', 'review_answer_timestamp', 'COLUMN';

UPDATE [dbo].[olist_order_reviews_dataset] SET review_id = REPLACE(review_id, '"', '')
UPDATE [dbo].[olist_order_reviews_dataset] SET order_id = REPLACE(order_id, '"', '')
UPDATE [dbo].[olist_order_reviews_dataset] SET review_score = REPLACE(review_score, '"', '')
UPDATE [dbo].[olist_order_reviews_dataset] SET review_creation_date = REPLACE(review_creation_date, '"', '')
UPDATE [dbo].[olist_order_reviews_dataset] SET review_answer_timestamp = REPLACE(review_answer_timestamp, '"', '')

ALTER TABLE olist_order_reviews_dataset
ADD CONSTRAINT pk_olist_order_reviews_dataset PRIMARY KEY (review_id);

SELECT * 
FROM olist_order_reviews_dataset
WHERE review_id IS NULL;

ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN review_id VARCHAR(50) NOT NULL;

ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN review_score INT;

ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN  review_creation_date DATETIME;

ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN  review_answer_timestamp DATETIME;


select * from olist_order_reviews_dataset;


CREATE TABLE [dbo].[product_category_name_translation](
	[product_category_name] [varchar](50) NULL,
	[product_category_name_english] [varchar](50) NULL
);


select * from [dbo].[product_category_name_translation]



CREATE TABLE [dbo].[olist_geolocation_dataset](
	["geolocation_zip_code_prefix"] [varchar](50) NULL,
	["geolocation_lat"] [varchar](50) NULL,
	["geolocation_lng"] [varchar](50) NULL,
	["geolocation_city"] [varchar](50) NULL,
	["geolocation_state"] [varchar](50) NULL
);


EXEC sp_rename 'olist_geolocation_dataset.["geolocation_zip_code_prefix"]', 'geolocation_zip_code_prefix', 'COLUMN';
EXEC sp_rename 'olist_geolocation_dataset.["geolocation_lat"]', 'geolocation_lat', 'COLUMN';
EXEC sp_rename 'olist_geolocation_dataset.["geolocation_lng"]', 'geolocation_lng', 'COLUMN';
EXEC sp_rename 'olist_geolocation_dataset.["geolocation_city"]', 'geolocation_city', 'COLUMN';
EXEC sp_rename 'olist_geolocation_dataset.["geolocation_state"]', 'geolocation_state', 'COLUMN';

select * from [dbo].[olist_geolocation_dataset]


UPDATE [dbo].[olist_geolocation_dataset] SET geolocation_zip_code_prefix = REPLACE(geolocation_zip_code_prefix, '"', '')
UPDATE [dbo].[olist_geolocation_dataset] SET geolocation_lat = REPLACE(geolocation_lat, '"', '')
UPDATE [dbo].[olist_geolocation_dataset] SET geolocation_lng = REPLACE(geolocation_lng, '"', '')
UPDATE [dbo].[olist_geolocation_dataset] SET geolocation_city = REPLACE(geolocation_city, '"', '')
UPDATE [dbo].[[olist_geolocation_dataset] SET geolocation_state = REPLACE(geolocation_state, '"', '')


select * from [dbo].[product_category_name_translation]

-- Analisis y graficas 

-- Union de la tabla category name translation y product dataset

select pd.product_id, pd.product_category_name AS portuguese_category, pct.product_category_name as english_category from [dbo].[olist_products_dataset] AS PD
left join [dbo].[product_category_name_translation] AS PCT ON pd.product_category_name = pct.product_category_name;

UPDATE pd SET pd.product_category_name = pct.product_category_name_english FROM [dbo].[olist_products_dataset] AS pd INNER JOIN 
[dbo].[product_category_name_translation] AS pct ON pd.product_category_name = pct.product_category_name;

--Sales by category 

SELECT pd.product_category_name, count(*) AS total_sales FROM [dbo].[olist_products_dataset] pd join olist_products_dataset oi ON oi.product_id = pd.product_id
GROUP BY  pd.product_category_name ORDER BY total_sales DESC;


--Average delivery time

select o.order_id, datediff(day, o.order_approved_at, o.order_delivered_customer_date) AS delivery_days
from olist_orders_dataset o where o.order_status = 'delivered' AND o.order_delivered_customer_date is not null;



--- Average rating per seller
SELECT 
    oi.seller_id,
    AVG(r.review_score) AS promedio_calificacion
FROM olist_order_items_dataset oi
JOIN olist_order_reviews_dataset r ON oi.order_id = r.order_id
GROUP BY oi.seller_id
ORDER BY promedio_calificacion DESC;

---- Average time deliver by country 

SELECT 
    c.customer_state AS customer_state,
    AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS Average_delivery_days
FROM [dbo].[olist_orders_dataset] o
JOIN [dbo].[olist_customers_dataset] c
    ON o.customer_id = c.customer_id
WHERE 
    o.order_delivered_customer_date IS NOT NULL
    AND o.order_purchase_timestamp IS NOT NULL
    AND o.order_delivered_customer_date >= o.order_purchase_timestamp  -- evita valores negativos
GROUP BY c.customer_state
ORDER BY Average_delivery_days DESC;

--Comparison between Estimated and Actual Delivery Dates by State

SELECT 
    c.customer_state AS State,
    AVG(DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date)) AS Avg_Days_Difference
FROM [dbo].[olist_orders_dataset] o
JOIN [dbo].[olist_customers_dataset] c
    ON o.customer_id = c.customer_id
WHERE 
    o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
    AND o.order_delivered_customer_date >= o.order_purchase_timestamp -- ensure valid data
GROUP BY c.customer_state
ORDER BY Avg_Days_Difference DESC;

--- In this case Avg_Days_Difference > 0: orders were delivered after the estimated date (delayed). Avg_Days_Difference < 0: orders were delivered before the estimated date (early).

--Pedidos entregados con retraso vs a tiempo 

SELECT 
    c.customer_state AS State,
	sum(case
	        when o.order_delivered_customer_date > o.order_estimated_delivery_date then 1
			else 0
         end) AS late_deliveries,
		 sum(case
		         when o.order_delivered_customer_date <= o.order_estimated_delivery_date then 1
				 else 0
         end) AS on_time_or_erly_deliveries
    FROM [dbo].[olist_orders_dataset] o
	JOIN [dbo].[olist_customers_dataset] c
	ON o.customer_id = c.customer_id
	where o.order_delivered_customer_date IS NOT NULL
	AND O.order_estimated_delivery_date IS NOT NULL
group by c.customer_state
order by late_deliveries desc;

--Pedidos cancelados por categoria de producto
	
Select p.product_category_name AS Product_Category, count(distinct o.order_id) 
AS Cancelled_orders FROM [dbo].[olist_orders_dataset] o 
JOIN [dbo].[olist_order_items_dataset] i
ON O.order_id = i.order_id JOIN [dbo].[olist_products_dataset] p ON i.product_id = p.product_id
Where o.order_status = 'Canceled' Group by p.product_category_name Order by Cancelled_orders DESC;

--Total de ventas por mes 

select c.customer_state AS State, sum(i.price + i.freight_value) AS Total_sales from [dbo].[olist_order_items_dataset] i
join [dbo].[olist_orders_dataset] o ON i.order_id = o.order_id join [dbo].[olist_customers_dataset] c
ON o.customer_id = c.customer_id where o.order_status = 'delivered' group by c.customer_state ORDER BY Total_sales DESC;

--•	Total de ventas por estado del vendedor

SELECT 
    s.seller_state AS State,
    SUM(i.price + i.freight_value) AS Total_Sales
FROM [dbo].[olist_order_items_dataset] i
JOIN [dbo].[olist_orders_dataset] o
    ON i.order_id = o.order_id
JOIN [dbo].[olist_sellers_dataset] s
    ON i.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY Total_Sales DESC;

--Ticket promedio por pedido

SELECT 
    AVG(Order_Total) AS Average_Ticket_Per_Order
FROM (
    SELECT 
        o.order_id,
        SUM(i.price + i.freight_value) AS Order_Total
    FROM [dbo].[olist_orders_dataset] o
    JOIN [dbo].[olist_order_items_dataset] i
        ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
) AS order_totals;

--productos mas vendidos por categoria

with product_sales AS(
SELECT p.product_category_name, i.product_id,
count(i.order_item_id) AS total_sold,
ROW_NUMBER() OVER (PARTITION BY p.product_category_name
ORDER BY COUNT(i.order_item_id) DESC
) AS rank_in_category from olist_order_items_dataset i
join olist_products_dataset p
on i.product_id = p.product_id
group by p.product_category_name, i.product_id
)
select product_category_name, product_id, total_sold
from product_sales
where rank_in_category = 1
order by total_sold DESC;


--Categoria mas popular
SELECT p.product_id, p.product_category_name,
count(*) as quantity_sold
from [dbo].[olist_order_items_dataset] i
join[dbo].[olist_products_dataset] p
on i.product_id = p.product_id
group by p.product_id, p.product_category_name
order by quantity_sold desc;

---Distribuccion geografica de clientes estado 

select customer_state as State, customer_city as city, count(*) as number_of_customers
from [dbo].[olist_customers_dataset] group by customer_state, customer_city
order by customer_state,number_of_customers desc;


select c.customer_state, avg(DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date)) as avg_delivery_days
FROM [dbo].[olist_orders_dataset] O JOIN [dbo].[olist_customers_dataset] ON O.customer_id = c.customer_id where o.order_delivered_customer_date is not null
group by c.customer_state order by avg_delivery_days desc;

SELECT 
    c.customer_state,
    AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_days
FROM [dbo].[olist_orders_dataset] o
JOIN [dbo].[olist_customers_dataset] c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- Average rating per seller state

select s.seller_state, round(avg(r.review_score),2) as AVG_RATING
from olist_order_reviews_dataset r
join olist_order_items_dataset i
on r.order_id = i.order_id
join olist_sellers_dataset s
on i.seller_id = s.seller_id
group by s.seller_state
order by AVG_RATING DESC;

--- customers by state 

select customer_state, count(distinct customer_id) as Total_customers
from olist_customers_dataset group by customer_state order by total_customers DESC;


---total sales amount by customer status

SELECT 
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_sales DESC;

---- customer segmentation by product category sold 

SELECT 
    p.product_category_name,
    COUNT(DISTINCT o.customer_id) AS total_customers
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_customers DESC;

----customer segmentation by frecuency buys 

WITH customer_frequency AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM olist_orders_dataset
    GROUP BY customer_id
)
SELECT 
    customer_id,
    total_orders,
    CASE 
        WHEN total_orders = 1 THEN 'Poco frecuente'
        WHEN total_orders BETWEEN 2 AND 3 THEN 'Frecuencia media'
        WHEN total_orders >= 4 THEN 'Muy frecuente'
    END AS frecuencia_segmento
FROM customer_frequency
ORDER BY total_orders DESC;


WITH customer_frequency AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM olist_orders_dataset
    GROUP BY customer_id
),
frequency_segments AS (
    SELECT
        customer_id,
        total_orders,
        CASE 
            WHEN total_orders = 1 THEN 'Poco frecuente'
            WHEN total_orders BETWEEN 2 AND 3 THEN 'Frecuencia media'
            WHEN total_orders >= 4 THEN 'Muy frecuente'
        END AS frecuencia_segmento
    FROM customer_frequency
)
SELECT 
    frecuencia_segmento,
    COUNT(customer_id) AS total_customers
FROM frequency_segments
GROUP BY frecuencia_segmento
ORDER BY 
    CASE 
        WHEN frecuencia_segmento = 'Poco frecuente' THEN 1
        WHEN frecuencia_segmento = 'Frecuencia media' THEN 2
        WHEN frecuencia_segmento = 'Muy frecuente' THEN 3
    END;

--- the most used payment method 

select payment_type, count(order_id) as total_orders from  olist_order_payments_dataset group by payment_type  order by total_orders  

select * from [dbo].[olist_order_payments_dataset]

--Number of installaments by payment type 

select payment_type, count(payment_installments) as total_installments from  olist_order_payments_dataset group by payment_type  order by total_installments

--sales comparison by payment method

select payment_type, sum(payment_value) as total_sales from  olist_order_payments_dataset group by payment_type  order by total_sales

--Products with the highest and lowest sales volume

select product_category_name, count(product_id) AS total_product_sold from [dbo].[olist_products_dataset] group by product_category_name order by total_product_sold desc

--size and weight per category 

select * from [dbo].[olist_products_dataset]

select product_category_name, sum(product_length_cm * product_height_cm * product_width_cm) AS Product_size, 
sum(product_weight_g) as Total_weight_product from  olist_products_dataset  group by product_category_name order by Total_weight_product desc, Product_size DESC

----

WITH product_dimensions AS (
    SELECT 
        p.product_id,
        p.product_category_name,
        (p.product_length_cm * p.product_height_cm * p.product_width_cm) AS volume_cm3,
        p.product_weight_g
    FROM olist_products_dataset p
),
order_statuses AS (
    SELECT 
        oi.product_id,
        o.order_status
    FROM olist_order_items_dataset oi
    JOIN olist_orders_dataset o
        ON oi.order_id = o.order_id
),
product_returns AS (
    SELECT 
        d.product_category_name,
        COUNT(CASE WHEN o.order_status IN ('canceled', 'returned') THEN 1 END) AS total_returns,
        COUNT(*) AS total_orders,
        AVG(d.volume_cm3) AS avg_volume,
        AVG(d.product_weight_g) AS avg_weight
    FROM product_dimensions d
    JOIN order_statuses o
        ON d.product_id = o.product_id
    GROUP BY d.product_category_name
)
SELECT 
    product_category_name,
    total_orders,
    total_returns,
    ROUND((CAST(total_returns AS FLOAT) / total_orders) * 100, 2) AS return_rate_percent,
    ROUND(avg_volume, 2) AS avg_volume_cm3,
    ROUND(avg_weight, 2) AS avg_weight_g
FROM product_returns
ORDER BY return_rate_percent DESC;

--- total sold by seller state

SELECT 
    s.seller_state, 
    SUM(i.price) AS total_sold
FROM olist_order_items_dataset as i
join olist_sellers_dataset as s
on s.seller_id = i.seller_id	
GROUP BY seller_state
ORDER BY total_sold DESC;


--Cancellation rate by seller status

WITH seller_orders AS (
    SELECT 
        s.seller_state,
        o.order_status
    FROM olist_order_items_dataset i
    JOIN olist_orders_dataset o 
        ON i.order_id = o.order_id
    JOIN olist_sellers_dataset s 
        ON i.seller_id = s.seller_id
),
state_cancellations AS (
    SELECT 
        seller_state,
        COUNT(*) AS total_orders,
        COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) AS canceled_orders
    FROM seller_orders
    GROUP BY seller_state
)
SELECT 
    seller_state,
    total_orders,
    canceled_orders,
    ROUND(CAST(canceled_orders AS FLOAT) / total_orders * 100, 2) AS cancellation_rate_percent
FROM state_cancellations
ORDER BY cancellation_rate_percent DESC;

-- delivered time by seller state

SELECT 
    s.seller_state,
    DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_time_days,
    COUNT(*) AS num_orders
FROM olist_order_items_dataset i
JOIN olist_orders_dataset o 
    ON i.order_id = o.order_id
JOIN olist_sellers_dataset s 
    ON i.seller_id = s.seller_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_state, DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)
ORDER BY s.seller_state, delivery_time_days;

--income generated by seller status
SELECT 
    s.seller_state,
    SUM(i.price) AS total_revenue
FROM olist_order_items_dataset i
JOIN olist_sellers_dataset s 
    ON i.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;

--Orders by state anb city 

-- State
select c.customer_state,
count(o.order_id) AS total_orders
from olist_orders_dataset o
join olist_customers_dataset c
on o.customer_id = c.customer_id
group by c.customer_state order by total_orders

--City 
select c.customer_city,
count(o.order_id) AS total_orders
from olist_orders_dataset o
join olist_customers_dataset c
on o.customer_id = c.customer_id
group by c.customer_city order by total_orders desc

--sales by state 

SELECT 
    c.customer_state, 
    SUM(p.payment_value) AS total_sales
FROM olist_orders_dataset as o
join olist_customers_dataset as c
on o.customer_id = c.customer_id
join olist_order_payments_dataset as p
on o.order_id = p.order_id
GROUP BY customer_state
ORDER BY total_sales DESC;


-- Orders by state 

SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

select * from [dbo].[olist_order_items_dataset]

select * from [dbo].[olist_customers_dataset]


--Delivery by state where the customer is located

WITH order_status_by_state AS (
    SELECT
        c.customer_state,
        o.order_id,
        o.order_delivered_customer_date,
        o.order_purchase_timestamp,
        o.order_status,
        DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
)
SELECT
    customer_state,
    COUNT(CASE WHEN order_delivered_customer_date IS NOT NULL THEN 1 END) AS total_deliveries,
    COUNT(CASE WHEN order_delivered_customer_date IS NOT NULL AND DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date) > 7 THEN 1 END) AS delayed_deliveries,
    COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) AS total_cancellations
FROM order_status_by_state
GROUP BY customer_state
ORDER BY total_deliveries DESC;


SELECT 
    s.seller_id,
    ROUND(AVG(r.review_score), 2) AS avg_rating
FROM olist_order_reviews_dataset r
JOIN olist_order_items_dataset i ON r.order_id = i.order_id
JOIN olist_sellers_dataset s ON i.seller_id = s.seller_id
GROUP BY s.seller_id
ORDER BY avg_rating DESC;

-- ratings by seller and category

SELECT
    s.seller_state,
    p.product_category_name,
    r.review_score
FROM olist_order_reviews_dataset r
JOIN olist_order_items_dataset i ON r.order_id = i.order_id
JOIN olist_sellers_dataset s ON i.seller_id = s.seller_id
JOIN olist_products_dataset p ON i.product_id = p.product_id
ORDER BY s.seller_state, p.product_category_name, r.review_score DESC;

--Relationship between rating and delivery time.

SELECT
    CASE
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 3 THEN '0-3 days'
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) BETWEEN 4 AND 7 THEN '4-7 days'
        ELSE '8+ days'
    END AS delivery_time_range,
    ROUND(AVG(r.review_score), 2) AS avg_rating,
    COUNT(*) AS total_orders
FROM olist_order_reviews_dataset r
JOIN olist_orders_dataset o ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY 
    CASE
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 3 THEN '0-3 days'
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) BETWEEN 4 AND 7 THEN '4-7 days'
        ELSE '8+ days'
    END
ORDER BY delivery_time_range;

--monthly sales evolution

SELECT 
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS year_month,
    SUM(i.price) AS total_sales
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY year_month;

--Seasons with the most orders or income.

SELECT 
    CONCAT(YEAR(o.order_purchase_timestamp), '-Q', DATEPART(QUARTER, o.order_purchase_timestamp)) AS year_quarter,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(i.price) AS total_sales
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
GROUP BY CONCAT(YEAR(o.order_purchase_timestamp), '-Q', DATEPART(QUARTER, o.order_purchase_timestamp))
ORDER BY total_orders DESC;

-- ventas totales por categoria y año 

SELECT
    p.product_category_name,
    YEAR(o.order_purchase_timestamp) AS order_year,
    SUM(oi.order_quantity) AS total_items_sold
FROM olist_orders_dataset o
JOIN olist_order_item_dataset oi
    ON o.order_id = oi.order_id
JOIN olist_product_dataset p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name, YEAR(o.order_purchase_timestamp)
ORDER BY p.product_category_name, order_year;

-- trying eda by state's sales
SELECT
    COUNT(State) AS num_estados,
    SUM(Total_Sales) AS ventas_totales,
    AVG(Total_Sales) AS ventas_promedio,
    MAX(Total_Sales) AS ventas_maximas,
    MIN(Total_Sales) AS ventas_minimas
FROM (
    SELECT 
        s.seller_state AS State,
        SUM(i.price + i.freight_value) AS Total_Sales
    FROM [dbo].[olist_order_items_dataset] i
    JOIN [dbo].[olist_orders_dataset] o ON i.order_id = o.order_id
    JOIN [dbo].[olist_sellers_dataset] s ON i.seller_id = s.seller_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_state
) AS ventas_por_estado;

