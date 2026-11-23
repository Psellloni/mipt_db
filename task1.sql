
CREATE SCHEMA IF NOT EXISTS online_store;
SET search_path TO online_store, public;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(30),
    dob DATE,
    job_title VARCHAR(150),
    job_industry_category VARCHAR(100),
    wealth_segment VARCHAR(50),
    deceased_indicator BOOLEAN,
    owns_car BOOLEAN,
    address VARCHAR(255),
    postcode VARCHAR(10),
    state VARCHAR(50),
    country VARCHAR(100),
    property_valuation NUMERIC(12,2)
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    brand VARCHAR(100),
    product_line VARCHAR(100),
    product_class VARCHAR(50),
    product_size VARCHAR(50),
    list_price NUMERIC(12,2),
    standard_cost NUMERIC(12,2)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date TIMESTAMP,
    online_order BOOLEAN,
    order_status VARCHAR(30)
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER,
    item_list_price_at_sale NUMERIC(12,2),
    item_standard_cost_at_sale NUMERIC(12,2)
);
