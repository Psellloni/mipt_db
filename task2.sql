SELECT
    'customers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_keys
FROM online_store.customers
UNION ALL
SELECT
    'products',
    COUNT(*),
    COUNT(DISTINCT product_id)
FROM online_store.products
UNION ALL
SELECT
    'orders',
    COUNT(*),
    COUNT(DISTINCT order_id)
FROM online_store.orders
UNION ALL
SELECT
    'order_items',
    COUNT(*),
    COUNT(DISTINCT order_item_id)
FROM online_store.order_items;


SELECT
    'orders → customers' AS relationship,
    COUNT(*) AS violations
FROM online_store.orders o
LEFT JOIN online_store.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'order_items → orders',
    COUNT(*)
FROM online_store.order_items oi
LEFT JOIN online_store.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'order_items → products',
    COUNT(*)
FROM online_store.order_items oi
LEFT JOIN online_store.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT
    postcode,
    COUNT(DISTINCT state) AS states_count
FROM online_store.customers
GROUP BY postcode
HAVING COUNT(DISTINCT state) > 1
ORDER BY states_count DESC;

SELECT
    postcode,
    state,
    COUNT(*) AS customers_count
FROM online_store.customers
WHERE postcode IN ('2601', '2602', '2603')
GROUP BY postcode, state
ORDER BY postcode, state;

SELECT
    product_line,
    COUNT(DISTINCT brand) AS brands_count
FROM online_store.products
GROUP BY product_line
HAVING COUNT(DISTINCT brand) > 1
ORDER BY brands_count DESC;

SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'online_store'
  AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY')
ORDER BY tc.table_name, tc.constraint_type;
