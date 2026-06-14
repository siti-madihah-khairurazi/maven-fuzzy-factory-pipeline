-- ============================================================================
-- MAVEN FUZZY FACTORY E-COMMERCE ANALYTICS PROJECT
-- Enterprise SQL Database & High-Performance Analytics Layer (MySQL Version)
--
-- Author: Madihah
-- Data Source & Credit: Dataset provided by Maven Analytics
-- Website: https://www.mavenanalytics.io/
-- ============================================================================

DROP DATABASE IF EXISTS maven_fuzzy_factory;
CREATE DATABASE maven_fuzzy_factory;
USE maven_fuzzy_factory;

-- ============================================================================
-- 1. DATA INGESTION LAYER
-- ============================================================================

-- Table 1: products (Targeted Manual Data Ingestion via Import Wizard)
CREATE TABLE products (
    product_id INT,
    created_at VARCHAR(100),
    product_name VARCHAR(100),
    PRIMARY KEY (product_id)
);

-- Table 2: order_item_refunds (Targeted Manual Data Ingestion via Import Wizard)
CREATE TABLE order_item_refunds (
    order_item_refund_id INT,
    created_at VARCHAR(100),
    order_item_id INT,
    order_id INT,
    refund_amount_usd DECIMAL(10,2),
    PRIMARY KEY (order_item_refund_id)
);

-- Automated Bulk Ingestion Pipeline for High-Volume Datasets
SET GLOBAL local_infile = 1;

-- Table 3: order_items
CREATE TABLE order_items (
    order_item_id INT,
    created_at VARCHAR(100), 
    order_id INT,
    product_id INT,
    is_primary_item INT,
    price_usd DECIMAL(10,2),
    cogs_usd DECIMAL(10,2),
    PRIMARY KEY (order_item_id)
);

LOAD DATA LOCAL INFILE "C:/Users/Asus/Documents/maven fuzzy factory/Maven+Fuzzy+Factory/order_items.csv"
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_item_id, created_at, order_id, product_id, is_primary_item, price_usd, cogs_usd);

-- Table 4: orders
CREATE TABLE orders (
    order_id INT,
    created_at VARCHAR(100), 
    website_session_id INT,
    user_id INT,
    primary_product_id INT,
    items_purchased INT,
    price_usd DECIMAL(10,2),
    cogs_usd DECIMAL(10,2),
    PRIMARY KEY (order_id)
);

LOAD DATA LOCAL INFILE "C:/Users/Asus/Documents/maven fuzzy factory/Maven+Fuzzy+Factory/orders.csv"
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, created_at, website_session_id, user_id, primary_product_id, items_purchased, price_usd, cogs_usd);

-- Table 5: website_pageviews
CREATE TABLE website_pageviews (
    website_pageview_id INT,
    created_at VARCHAR(100), 
    website_session_id INT,
    pageview_url VARCHAR(255),
    PRIMARY KEY (website_pageview_id)
);

LOAD DATA LOCAL INFILE "C:/Users/Asus/Documents/maven fuzzy factory/Maven+Fuzzy+Factory/website_pageviews.csv"
INTO TABLE website_pageviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES 
(website_pageview_id, created_at, website_session_id, pageview_url);

-- Table 6: website_sessions
CREATE TABLE website_sessions (
    website_session_id INT,
    created_at VARCHAR(100), 
    user_id INT,
    is_repeat_session INT,   
    utm_source VARCHAR(100),
    utm_campaign VARCHAR(100),
    utm_content VARCHAR(100),
    device_type VARCHAR(100),
    http_referer VARCHAR(255),
    PRIMARY KEY (website_session_id)
);
    
LOAD DATA LOCAL INFILE "C:/Users/Asus/Documents/maven fuzzy factory/Maven+Fuzzy+Factory/website_sessions.csv"
INTO TABLE website_sessions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES 
(website_session_id, created_at, user_id, is_repeat_session, utm_source, utm_campaign, utm_content, device_type, http_referer);

SET GLOBAL local_infile = 0;

-- ============================================================================
-- 2. SCHEMATIC DATA TYPE REFACTORING & OPTIMIZATION
-- ============================================================================
-- Sanitizing string timestamps by truncating carriage return noise (\r) and casting to DATETIME.
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE order_items ADD COLUMN temp_dt DATETIME;
UPDATE order_items SET temp_dt = CAST(SUBSTRING(TRIM(created_at), 1, 19) AS DATETIME);
ALTER TABLE order_items DROP COLUMN created_at;
ALTER TABLE order_items CHANGE COLUMN temp_dt created_at DATETIME;

ALTER TABLE orders ADD COLUMN temp_dt DATETIME;
UPDATE orders SET temp_dt = CAST(SUBSTRING(TRIM(created_at), 1, 19) AS DATETIME);
ALTER TABLE orders DROP COLUMN created_at;
ALTER TABLE orders CHANGE COLUMN temp_dt created_at DATETIME;

ALTER TABLE website_pageviews ADD COLUMN temp_dt DATETIME;
UPDATE website_pageviews SET temp_dt = CAST(SUBSTRING(TRIM(created_at), 1, 19) AS DATETIME);
ALTER TABLE website_pageviews DROP COLUMN created_at;
ALTER TABLE website_pageviews CHANGE COLUMN temp_dt created_at DATETIME;
CREATE INDEX idx_pv_session ON website_pageviews(website_session_id);

ALTER TABLE website_sessions ADD COLUMN temp_dt DATETIME;
UPDATE website_sessions SET temp_dt = CAST(SUBSTRING(TRIM(created_at), 1, 19) AS DATETIME);
ALTER TABLE website_sessions DROP COLUMN created_at;
ALTER TABLE website_sessions CHANGE COLUMN temp_dt created_at DATETIME;

ALTER TABLE products ADD COLUMN temp_dt DATETIME;
UPDATE products SET temp_dt = CAST(SUBSTRING(TRIM(created_at), 1, 19) AS DATETIME);
ALTER TABLE products DROP COLUMN created_at;
ALTER TABLE products CHANGE COLUMN temp_dt created_at DATETIME;

ALTER TABLE order_item_refunds ADD COLUMN temp_dt DATETIME;
UPDATE order_item_refunds SET temp_dt = CAST(SUBSTRING(TRIM(created_at), 1, 19) AS DATETIME);
ALTER TABLE order_item_refunds DROP COLUMN created_at;
ALTER TABLE order_item_refunds CHANGE COLUMN temp_dt created_at DATETIME;

-- Appending Time-Series Dimension Columns to Fact Table for Performance Optimization
ALTER TABLE website_sessions
ADD COLUMN session_year INT,
ADD COLUMN session_month INT,
ADD COLUMN session_day INT,
ADD COLUMN session_year_month VARCHAR(7);

UPDATE website_sessions 
SET 
    session_year = YEAR(created_at),
    session_month = MONTH(created_at),
    session_day = DAY(created_at),
    session_year_month = DATE_FORMAT(created_at, '%Y-%m');

SET SQL_SAFE_UPDATES = 1;

-- ============================================================================
-- 3. EXPLORATORY DATA ANALYSIS (EDA) & DATA QUALITY PROFILING
-- ============================================================================

-- [Profiling 1]: Standardizing Case-Sensitivity Anomalies across Product Lines
-- Objective: Fix mixed casing ('bear' vs 'Bear') to ensure clean string matching in Power BI.
SET SQL_SAFE_UPDATES = 0;
UPDATE products 
SET product_name = REPLACE(product_name, 'bear', 'Bear') 
WHERE product_name LIKE '%bear%';
SET SQL_SAFE_UPDATES = 1;


-- [Profiling 2]: Identifying System Boundaries & Operational Lifespan
-- Data Insight Gathered:
--   - Pipeline Start : 2012-03-19
--   - Pipeline End   : 2015-03-20
--   - Total Lifespan : 1,096 Operating Days (Exactly 3 Full Calendar Years)
-- Purpose: Establishes chronological boundaries for time-series modeling in BI.
SELECT 
    MIN(created_at) AS data_pipeline_start, 
    MAX(created_at) AS data_pipeline_end,
    DATEDIFF(MAX(created_at), MIN(created_at)) AS total_operational_days
FROM website_sessions;


-- [Profiling 3]: Integrity Check - Verifying System Against Session Duplication
-- Objective: Ensure `website_session_id` behaves strictly as a unique primary key 
-- to prevent artificial inflation of conversion and traffic metrics.
-- Expected Result: 0 rows returned (Data Integrity Confirmed).
SELECT website_session_id, COUNT(*) AS duplicate_count
FROM website_sessions
GROUP BY website_session_id
HAVING COUNT(*) > 1;

-- ============================================================================
-- 4. BI ANALYTICS LAYER (GOLD ANALYTICAL VIEWS)
-- ============================================================================

-- VIEW 1: MARKETING PERFORMANCE & CHANNEL TRAFFIC SHARE
-- Feeds: Donut Chart (Traffic Share) & Time-Series Line and Clustered Bar Chart
CREATE OR REPLACE VIEW vw_marketing_performance AS
SELECT 
    s.session_year_month AS `year_month`,
    s.session_year,
    s.session_month,
    COALESCE(s.utm_source, 'direct') AS utm_source,
    COALESCE(s.utm_campaign, 'none') AS utm_campaign,
    s.device_type,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COALESCE(SUM(o.price_usd), 0), 2) AS revenue,
    ROUND(COUNT(DISTINCT o.order_id) / NULLIF(COUNT(DISTINCT s.website_session_id), 0), 4) AS conversion_rate,
    ROUND(COALESCE(SUM(o.price_usd), 0) / NULLIF(COUNT(DISTINCT s.website_session_id), 0), 2) AS revenue_per_session
FROM website_sessions s
LEFT JOIN orders o ON s.website_session_id = o.website_session_id
GROUP BY s.session_year_month, s.session_year, s.session_month, s.utm_source, s.utm_campaign, s.device_type;

SELECT *
FROM vw_marketing_performance;

-- VIEW 2: UX WEB CONVERSION FUNNEL
-- Feeds: Funnel Chart & Executive KPI Cards (Conversion Rate & Sessions)
CREATE OR REPLACE VIEW vw_funnel_analysis AS
WITH session_funnel_flags AS (
    SELECT 
        website_session_id,
        MAX(CASE WHEN pageview_url IN ('/home', '/lander-1', '/lander-2', '/lander-3', '/lander-4', '/lander-5') THEN 1 ELSE 0 END) AS saw_any_landing_page,
        MAX(CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN pageview_url IN ('/lander-1', '/lander-2', '/lander-3', '/lander-4', '/lander-5') THEN 1 ELSE 0 END) AS saw_custom_lander,
        MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS saw_products_page,
        MAX(CASE WHEN pageview_url IN ('/the-original-mr-fuzzy', '/the-hudson-river-mini-bear', '/the-forever-love-bear', '/the-birthday-sugar-panda') THEN 1 ELSE 0 END) AS saw_product_details_page,
        MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS saw_cart_page,
        MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS saw_shipping_page,
        MAX(CASE WHEN pageview_url IN ('/billing', '/billing-2') THEN 1 ELSE 0 END) AS saw_billing_page,
        MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS completed_purchase
    FROM website_pageviews
    GROUP BY website_session_id
)
SELECT 
    s.website_session_id,
    s.session_year_month AS `year_month`,
    s.session_year,
    s.session_month,
    s.device_type,
    o.primary_product_id AS product_id,
    f.saw_any_landing_page,
    f.saw_homepage,
    f.saw_custom_lander,
    f.saw_products_page,
    f.saw_product_details_page,
    f.saw_cart_page,
    f.saw_shipping_page,
    f.saw_billing_page,
    f.completed_purchase,
    CASE WHEN o.order_id IS NOT NULL THEN 1 ELSE 0 END AS is_converted,
    ROUND(COALESCE(o.price_usd, 0), 2) AS order_revenue
FROM website_sessions s
LEFT JOIN session_funnel_flags f ON s.website_session_id = f.website_session_id
LEFT JOIN orders o ON s.website_session_id = o.website_session_id;

SELECT *
FROM vw_funnel_analysis;

-- VIEW 3: PRODUCT REVENUE PERFORMANCE & REFUND RISK ANALYSIS
-- Feeds: Monthly Revenue Trend (Bar Component), Product Slicer & Revenue Loss Risk Chart
CREATE OR REPLACE VIEW vw_product_revenue_loss AS
SELECT
    DATE_FORMAT(o.created_at, '%Y-%m') AS `year_month`,
    YEAR(o.created_at) AS session_year,
    MONTH(o.created_at) AS session_month,
    oi.product_id,
    s.device_type,
    COUNT(DISTINCT oi.order_id) AS total_orders_volume,
    ROUND(SUM(oi.price_usd), 2) AS gross_revenue,
    ROUND(SUM(oi.price_usd - oi.cogs_usd), 2) AS net_profit,
    COUNT(DISTINCT r.order_item_refund_id) AS total_refunded_items,
    ROUND(COALESCE(SUM(r.refund_amount_usd), 0), 2) AS estimated_lost_revenue
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN website_sessions s ON o.website_session_id = s.website_session_id
LEFT JOIN order_item_refunds r ON oi.order_item_id = r.order_item_id
GROUP BY DATE_FORMAT(o.created_at, '%Y-%m'), YEAR(o.created_at), MONTH(o.created_at), oi.product_id, s.device_type;

SELECT *
FROM vw_product_revenue_loss;

-- ============================================================================
-- 5. METADATA VALIDATION
-- ============================================================================
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_SCHEMA = DATABASE() 
ORDER BY TABLE_NAME;
