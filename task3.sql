-- ЗАПРОС 1
SELECT
    product_id,
    ROUND(AVG(item_list_price_at_sale), 2) AS avg_sale_price
FROM online_store.order_items
GROUP BY product_id
ORDER BY avg_sale_price DESC, product_id
LIMIT 5;


-- ЗАПРОС 2
SELECT
    p.brand,
    ROUND(
        SUM(oi.item_list_price_at_sale * oi.quantity),
        2
    ) AS total_sales
FROM online_store.order_items oi
JOIN online_store.products p
    ON oi.product_id = p.product_id
GROUP BY p.brand
ORDER BY total_sales DESC, p.brand;


-- ЗАПРОС 3
SELECT
    EXTRACT(YEAR FROM order_date)::INTEGER AS order_year,
    EXTRACT(MONTH FROM order_date)::INTEGER AS order_month,
    COUNT(*) AS orders_count
FROM online_store.orders
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY order_year, order_month;

-- ЗАПРОС 4
WITH ranked_products AS (
    SELECT
        product_id,
        product_line,
        standard_cost,
        RANK() OVER (
            PARTITION BY product_line
            ORDER BY standard_cost DESC
        ) AS cost_rank
    FROM online_store.products
)
SELECT
    product_id,
    product_line,
    standard_cost
FROM ranked_products
WHERE cost_rank = 1
ORDER BY product_line, product_id;

-- ЗАПРОС 5
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(
        SUM(oi.item_list_price_at_sale * oi.quantity),
        2
    ) AS total_order_value
FROM online_store.orders o
JOIN online_store.order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY o.order_status;

-- ЗАПРОС 6
SELECT
    c.customer_id,
    c.last_name,
    c.first_name
FROM online_store.customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM online_store.orders o
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- ЗАПРОС 7
WITH ranked_customers AS (
    SELECT
        customer_id,
        state,
        property_valuation,
        last_name,
        first_name,
        RANK() OVER (
            PARTITION BY state
            ORDER BY property_valuation DESC
        ) AS max_rank,
        RANK() OVER (
            PARTITION BY state
            ORDER BY property_valuation ASC
        ) AS min_rank
    FROM online_store.customers
    WHERE property_valuation IS NOT NULL
)
SELECT
    state,
    property_valuation,
    last_name,
    first_name
FROM ranked_customers
WHERE max_rank = 1
   OR min_rank = 1
ORDER BY
    state,
    property_valuation DESC,
    last_name,
    first_name;

-- ЗАПРОС 8
SELECT
    o.customer_id,
    MIN(p.product_line) AS product_line,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM online_store.orders o
JOIN online_store.order_items oi
    ON o.order_id = oi.order_id
JOIN online_store.products p
    ON oi.product_id = p.product_id
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.product_line) = 1
ORDER BY o.customer_id;

-- ЗАПРОС 9
SELECT
    p.product_class AS category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_status = 'Cancelled'
    ) AS cancelled_orders,
    ROUND(
        100.0 *
        COUNT(DISTINCT o.order_id) FILTER (
            WHERE o.order_status = 'Cancelled'
        )
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS cancelled_percentage
FROM online_store.products p
JOIN online_store.order_items oi
    ON p.product_id = oi.product_id
JOIN online_store.orders o
    ON oi.order_id = o.order_id
GROUP BY p.product_class
ORDER BY cancelled_percentage DESC, category;

-- ЗАПРОС 10
WITH customer_orders AS (
    SELECT
        c.customer_id,
        COUNT(o.order_id) AS orders_count
    FROM online_store.customers c
    LEFT JOIN online_store.orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
),
customer_segments AS (
    SELECT
        customer_id,
        orders_count,
        CASE
            WHEN orders_count > 10 THEN 'High'
            WHEN orders_count BETWEEN 5 AND 10 THEN 'Medium'
            ELSE 'Low'
        END AS segment
    FROM customer_orders
)
SELECT
    segment,
    COUNT(*) AS customers_count
FROM customer_segments
GROUP BY segment
ORDER BY
    CASE segment
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
    END;

-- ЗАПРОС 11
WITH ordered_purchases AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_date
    FROM online_store.orders
),
order_intervals AS (
    SELECT
        customer_id,
        EXTRACT(
            EPOCH FROM (order_date - previous_order_date)
        ) / 86400.0 AS days_between_orders
    FROM ordered_purchases
    WHERE previous_order_date IS NOT NULL
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.job_title,
    ROUND(
        MAX(oi.days_between_orders)::NUMERIC,
        2
    ) AS max_interval_days
FROM online_store.customers c
JOIN order_intervals oi
    ON c.customer_id = oi.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.job_title
ORDER BY max_interval_days DESC, c.customer_id;
