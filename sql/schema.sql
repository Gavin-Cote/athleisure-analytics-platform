-- ============================================================
-- Athleisure Brand Analytics Platform
-- PostgreSQL Database Schema
-- Mock Brand: Summit Active
-- ============================================================

-- Drop tables in reverse dependency order so the script can be rerun safely
DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS inventory_snapshots;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS marketing_campaigns;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

-- ============================================================
-- Products
-- ============================================================

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    color VARCHAR(50) NOT NULL,
    size VARCHAR(20) NOT NULL,
    season VARCHAR(30) NOT NULL,
    unit_cost NUMERIC(10, 2) NOT NULL,
    retail_price NUMERIC(10, 2) NOT NULL,
    launch_date DATE NOT NULL,
    product_status VARCHAR(30) DEFAULT 'active',

    CONSTRAINT chk_product_category
        CHECK (category IN (
            'Joggers',
            'Shorts',
            'Hoodies',
            'Half-Zips',
            'Performance Tees',
            'Tanks',
            'Leggings',
            'Polos',
            'Outerwear',
            'Accessories'
        )),

    CONSTRAINT chk_product_gender
        CHECK (gender IN (
            'Men',
            'Women',
            'Unisex'
        )),

    CONSTRAINT chk_product_season
        CHECK (season IN (
            'Spring',
            'Summer',
            'Fall',
            'Winter',
            'Core'
        )),

    CONSTRAINT chk_product_status
        CHECK (product_status IN (
            'active',
            'discontinued'
        )),

    CONSTRAINT chk_product_cost_positive
        CHECK (unit_cost >= 0),

    CONSTRAINT chk_product_price_positive
        CHECK (retail_price >= 0),

    CONSTRAINT chk_price_greater_than_cost
        CHECK (retail_price >= unit_cost)
);

-- ============================================================
-- Customers
-- ============================================================

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    region VARCHAR(50) NOT NULL,
    customer_segment VARCHAR(50) NOT NULL,
    created_at DATE NOT NULL,

    CONSTRAINT chk_customer_region
        CHECK (region IN (
            'Northeast',
            'Southeast',
            'Midwest',
            'Southwest',
            'West'
        )),

    CONSTRAINT chk_customer_segment
        CHECK (customer_segment IN (
            'New',
            'Returning',
            'Loyal',
            'High Value'
        ))
);

-- ============================================================
-- Orders
-- ============================================================

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    channel VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    order_status VARCHAR(50) DEFAULT 'completed',
    total_amount NUMERIC(10, 2),

    CONSTRAINT chk_order_channel
        CHECK (channel IN (
            'Ecommerce',
            'Retail',
            'Wholesale'
        )),

    CONSTRAINT chk_order_region
        CHECK (region IN (
            'Northeast',
            'Southeast',
            'Midwest',
            'Southwest',
            'West'
        )),

    CONSTRAINT chk_order_status
        CHECK (order_status IN (
            'completed',
            'returned',
            'cancelled'
        )),

    CONSTRAINT chk_total_amount_positive
        CHECK (total_amount IS NULL OR total_amount >= 0)
);

-- ============================================================
-- Order Items
-- ============================================================

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    discount_amount NUMERIC(10, 2) DEFAULT 0,
    unit_cost NUMERIC(10, 2) NOT NULL,

    net_sales NUMERIC(10, 2)
        GENERATED ALWAYS AS ((unit_price * quantity) - discount_amount) STORED,

    gross_profit NUMERIC(10, 2)
        GENERATED ALWAYS AS (((unit_price * quantity) - discount_amount) - (unit_cost * quantity)) STORED,

    CONSTRAINT chk_quantity_positive
        CHECK (quantity > 0),

    CONSTRAINT chk_unit_price_positive
        CHECK (unit_price >= 0),

    CONSTRAINT chk_discount_amount_positive
        CHECK (discount_amount >= 0),

    CONSTRAINT chk_unit_cost_positive
        CHECK (unit_cost >= 0),

    CONSTRAINT chk_discount_not_greater_than_sales
        CHECK (discount_amount <= unit_price * quantity)
);

-- ============================================================
-- Inventory Snapshots
-- ============================================================

CREATE TABLE inventory_snapshots (
    snapshot_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    snapshot_date DATE NOT NULL,
    starting_inventory INTEGER NOT NULL,
    ending_inventory INTEGER NOT NULL,
    units_received INTEGER DEFAULT 0,
    units_sold INTEGER DEFAULT 0,

    CONSTRAINT chk_starting_inventory_nonnegative
        CHECK (starting_inventory >= 0),

    CONSTRAINT chk_ending_inventory_nonnegative
        CHECK (ending_inventory >= 0),

    CONSTRAINT chk_units_received_nonnegative
        CHECK (units_received >= 0),

    CONSTRAINT chk_units_sold_nonnegative
        CHECK (units_sold >= 0),

    CONSTRAINT unique_product_snapshot_date
        UNIQUE (product_id, snapshot_date)
);

-- ============================================================
-- Returns
-- ============================================================

CREATE TABLE returns (
    return_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    order_item_id INTEGER NOT NULL REFERENCES order_items(order_item_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    return_date DATE NOT NULL,
    quantity_returned INTEGER NOT NULL,
    return_reason VARCHAR(100) NOT NULL,
    refund_amount NUMERIC(10, 2) NOT NULL,

    CONSTRAINT chk_quantity_returned_positive
        CHECK (quantity_returned > 0),

    CONSTRAINT chk_refund_amount_positive
        CHECK (refund_amount >= 0),

    CONSTRAINT chk_return_reason
        CHECK (return_reason IN (
            'Too small',
            'Too large',
            'Color not as expected',
            'Quality issue',
            'Changed mind',
            'Late delivery'
        ))
);

-- ============================================================
-- Marketing Campaigns
-- ============================================================

CREATE TABLE marketing_campaigns (
    campaign_id SERIAL PRIMARY KEY,
    campaign_name VARCHAR(150) NOT NULL,
    marketing_channel VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    spend NUMERIC(10, 2) NOT NULL,
    target_category VARCHAR(50) NOT NULL,
    campaign_goal VARCHAR(100) NOT NULL,

    CONSTRAINT chk_marketing_channel
        CHECK (marketing_channel IN (
            'Email',
            'Paid Search',
            'Paid Social',
            'Organic Social',
            'Influencer',
            'Affiliate'
        )),

    CONSTRAINT chk_campaign_target_category
        CHECK (target_category IN (
            'Joggers',
            'Shorts',
            'Hoodies',
            'Half-Zips',
            'Performance Tees',
            'Tanks',
            'Leggings',
            'Polos',
            'Outerwear',
            'Accessories'
        )),

    CONSTRAINT chk_campaign_goal
        CHECK (campaign_goal IN (
            'Awareness',
            'Conversion',
            'Retention',
            'Product Launch',
            'Markdown Support'
        )),

    CONSTRAINT chk_campaign_spend_positive
        CHECK (spend >= 0),

    CONSTRAINT chk_campaign_dates
        CHECK (end_date >= start_date)
);

-- ============================================================
-- Indexes for Faster Analysis Queries
-- ============================================================

CREATE INDEX idx_products_category
ON products(category);

CREATE INDEX idx_products_launch_date
ON products(launch_date);

CREATE INDEX idx_orders_order_date
ON orders(order_date);

CREATE INDEX idx_orders_channel
ON orders(channel);

CREATE INDEX idx_orders_region
ON orders(region);

CREATE INDEX idx_order_items_order_id
ON order_items(order_id);

CREATE INDEX idx_order_items_product_id
ON order_items(product_id);

CREATE INDEX idx_inventory_product_id
ON inventory_snapshots(product_id);

CREATE INDEX idx_inventory_snapshot_date
ON inventory_snapshots(snapshot_date);

CREATE INDEX idx_returns_product_id
ON returns(product_id);

CREATE INDEX idx_returns_return_date
ON returns(return_date);

CREATE INDEX idx_campaigns_dates
ON marketing_campaigns(start_date, end_date);

-- ============================================================
-- End of Schema
-- ============================================================