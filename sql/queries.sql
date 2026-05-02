-- 1. Create Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);

-- 2. Create Products Table
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- 3. Create Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 4. Create Order Items Table
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2)
);





-- Identifies which categories drive the most revenue and their Average Order Value (AOV)
SELECT 
    p.product_category_name AS category,
    COUNT(DISTINCT od.order_id) AS total_orders,
    SUM(od.price) AS gross_revenue,
    ROUND(AVG(od.price), 2) AS average_order_value
FROM order_items od
JOIN products p ON od.product_id = p.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY gross_revenue DESC
LIMIT 10;

-- Analyzes how freight costs eat into the actual product price margin
WITH FreightAnalysis AS (
    SELECT 
        p.product_category_name AS category,
        SUM(od.price) AS total_price,
        SUM(od.freight_value) AS total_freight
    FROM order_items od
    JOIN products p ON od.product_id = p.product_id
    WHERE p.product_category_name IS NOT NULL
    GROUP BY p.product_category_name
)
SELECT 
    category,
    total_price,
    total_freight,
    ROUND((total_freight / total_price) * 100, 2) AS freight_to_price_ratio
FROM FreightAnalysis
ORDER BY freight_to_price_ratio DESC
LIMIT 10;





-- Calculates the percentage of total revenue driven by each Brazilian state
WITH RegionalRevenue AS (
    SELECT 
        c.customer_state AS state,
        SUM(od.price) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items od ON o.order_id = od.order_id
    GROUP BY c.customer_state
)
SELECT 
    state,
    total_revenue,
    ROUND(total_revenue / (SELECT SUM(total_revenue) FROM RegionalRevenue) * 100, 2) AS pct_of_total_revenue
FROM RegionalRevenue
ORDER BY total_revenue DESC
LIMIT 10;