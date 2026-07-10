-- ============================================================
-- Athleisure Brand Analytics Platform
-- Power BI / Analytics Views
-- Mock Brand: Summit Active
-- ============================================================

DROP VIEW IF EXISTS v_executive_kpi_summary;
DROP VIEW IF EXISTS v_monthly_revenue;
DROP VIEW IF EXISTS v_category_performance;
DROP VIEW IF EXISTS v_channel_performance;
DROP VIEW IF EXISTS v_region_performance;
DROP VIEW IF EXISTS v_product_performance;
DROP VIEW IF EXISTS v_inventory_health;
DROP VIEW IF EXISTS v_product_recommendations;
DROP VIEW IF EXISTS v_return_reason_breakdown;
DROP VIEW IF EXISTS v_marketing_campaign_summary;


-- ============================================================
-- 1. Executive KPI Summary
-- One-row table for dashboard KPI cards
-- ============================================================

CREATE VIEW v_executive_kpi_summary AS
SELECT
    ROUND(SUM(oi.net_sales), 2) AS total_revenue,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.gross_profit), 2) AS total_gross_profit,
    ROUND(SUM(oi.gross_profit) / NULLIF(SUM(oi.net_sales), 0) * 100, 2) AS gross_margin_percent,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    ROUND(SUM(oi.net_sales) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;


-- ============================================================
-- 2. Monthly Revenue
-- Time-series table for trend charts
-- ============================================================

CREATE VIEW v_monthly_revenue AS
SELECT
    DATE_TRUNC('month', o.order_date)::date AS sales_month,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.gross_profit), 2) AS gross_profit,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.net_sales) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS average_order_value,
    ROUND(SUM(oi.gross_profit) / NULLIF(SUM(oi.net_sales), 0) * 100, 2) AS gross_margin_percent
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY sales_month;


-- ============================================================
-- 3. Category Performance
-- Product category-level sales and profitability
-- ============================================================

CREATE VIEW v_category_performance AS
SELECT
    p.category,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.gross_profit), 2) AS gross_profit,
    ROUND(SUM(oi.gross_profit) / NULLIF(SUM(oi.net_sales), 0) * 100, 2) AS gross_margin_percent,
    ROUND(SUM(oi.discount_amount), 2) AS total_discount_amount,
    ROUND(SUM(oi.discount_amount) / NULLIF(SUM(oi.unit_price * oi.quantity), 0) * 100, 2) AS discount_rate_percent
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category;


-- ============================================================
-- 4. Channel Performance
-- Ecommerce vs Retail vs Wholesale
-- ============================================================

CREATE VIEW v_channel_performance AS
SELECT
    o.channel,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.gross_profit), 2) AS gross_profit,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    ROUND(SUM(oi.net_sales) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS average_order_value,
    ROUND(SUM(oi.gross_profit) / NULLIF(SUM(oi.net_sales), 0) * 100, 2) AS gross_margin_percent
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.channel;


-- ============================================================
-- 5. Region Performance
-- Regional sales view
-- ============================================================

CREATE VIEW v_region_performance AS
SELECT
    o.region,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.gross_profit), 2) AS gross_profit,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    ROUND(SUM(oi.net_sales) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS average_order_value,
    ROUND(SUM(oi.gross_profit) / NULLIF(SUM(oi.net_sales), 0) * 100, 2) AS gross_margin_percent
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.region;


-- ============================================================
-- 6. Product Performance
-- Product-level revenue, units, profit, margin, and returns
-- ============================================================

CREATE VIEW v_product_performance AS
WITH sales_by_product AS (
    SELECT
        product_id,
        SUM(quantity) AS units_sold,
        ROUND(SUM(net_sales), 2) AS revenue,
        ROUND(SUM(gross_profit), 2) AS gross_profit,
        ROUND(SUM(discount_amount), 2) AS total_discount_amount
    FROM order_items
    GROUP BY product_id
),

returns_by_product AS (
    SELECT
        product_id,
        SUM(quantity_returned) AS units_returned,
        ROUND(SUM(refund_amount), 2) AS refund_amount
    FROM returns
    GROUP BY product_id
)

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.gender,
    p.color,
    p.size,
    p.season,
    p.unit_cost,
    p.retail_price,
    p.launch_date,
    COALESCE(s.units_sold, 0) AS units_sold,
    COALESCE(s.revenue, 0) AS revenue,
    COALESCE(s.gross_profit, 0) AS gross_profit,
    ROUND(COALESCE(s.gross_profit, 0) / NULLIF(s.revenue, 0) * 100, 2) AS gross_margin_percent,
    COALESCE(s.total_discount_amount, 0) AS total_discount_amount,
    COALESCE(r.units_returned, 0) AS units_returned,
    COALESCE(r.refund_amount, 0) AS refund_amount,
    ROUND(COALESCE(r.units_returned, 0)::numeric / NULLIF(s.units_sold, 0) * 100, 2) AS return_rate_percent
FROM products p
LEFT JOIN sales_by_product s
    ON p.product_id = s.product_id
LEFT JOIN returns_by_product r
    ON p.product_id = r.product_id;


-- ============================================================
-- 7. Inventory Health
-- Product-level inventory, sell-through, aging, and risk status
-- ============================================================

CREATE VIEW v_inventory_health AS
WITH latest_inventory AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        snapshot_date,
        ending_inventory
    FROM inventory_snapshots
    ORDER BY product_id, snapshot_date DESC
),

yearly_inventory AS (
    SELECT
        product_id,
        SUM(units_sold) AS yearly_units_sold
    FROM inventory_snapshots
    GROUP BY product_id
),

recent_30_day_sales AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold_last_30_days
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_date >= (SELECT MAX(order_date) FROM orders) - INTERVAL '30 days'
    GROUP BY oi.product_id
),

recent_60_day_sales AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold_last_60_days
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_date >= (SELECT MAX(order_date) FROM orders) - INTERVAL '60 days'
    GROUP BY oi.product_id
)

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.gender,
    p.color,
    p.size,
    p.season,
    p.launch_date,
    li.snapshot_date AS latest_snapshot_date,
    li.ending_inventory,
    COALESCE(y.yearly_units_sold, 0) AS yearly_units_sold,
    COALESCE(r30.units_sold_last_30_days, 0) AS units_sold_last_30_days,
    COALESCE(r60.units_sold_last_60_days, 0) AS units_sold_last_60_days,
    ROUND(COALESCE(y.yearly_units_sold, 0)::numeric / NULLIF(COALESCE(y.yearly_units_sold, 0) + li.ending_inventory, 0) * 100, 2) AS sell_through_rate_percent,
    ((SELECT MAX(order_date) FROM orders)::date - p.launch_date) AS inventory_age_days,

    CASE
        WHEN li.ending_inventory <= 20
         AND COALESCE(r30.units_sold_last_30_days, 0) >= 10
        THEN 'High Stockout Risk'

        WHEN li.ending_inventory <= 35
         AND COALESCE(r30.units_sold_last_30_days, 0) >= 8
        THEN 'Moderate Stockout Risk'

        ELSE 'Low Stockout Risk'
    END AS stockout_risk_level,

    CASE
        WHEN COALESCE(r60.units_sold_last_60_days, 0) <= 10
         AND li.ending_inventory >= 50
        THEN 'Slow Moving'

        WHEN COALESCE(y.yearly_units_sold, 0)::numeric / NULLIF(COALESCE(y.yearly_units_sold, 0) + li.ending_inventory, 0) >= 0.70
        THEN 'Fast Moving'

        ELSE 'Healthy'
    END AS inventory_status

FROM products p
JOIN latest_inventory li
    ON p.product_id = li.product_id
LEFT JOIN yearly_inventory y
    ON p.product_id = y.product_id
LEFT JOIN recent_30_day_sales r30
    ON p.product_id = r30.product_id
LEFT JOIN recent_60_day_sales r60
    ON p.product_id = r60.product_id;


-- ============================================================
-- 8. Product Recommendations
-- Decision-support view for restocks, markdowns, promotions, and product review
-- ============================================================

CREATE VIEW v_product_recommendations AS
WITH product_metrics AS (
    SELECT
        pp.product_id,
        pp.product_name,
        pp.category,
        pp.gender,
        pp.color,
        pp.size,
        pp.revenue,
        pp.units_sold,
        pp.gross_profit,
        pp.gross_margin_percent,
        pp.return_rate_percent,
        ih.ending_inventory,
        ih.units_sold_last_30_days,
        ih.units_sold_last_60_days,
        ih.sell_through_rate_percent,
        ih.inventory_age_days,
        ih.stockout_risk_level,
        ih.inventory_status
    FROM v_product_performance pp
    JOIN v_inventory_health ih
        ON pp.product_id = ih.product_id
)

SELECT
    product_id,
    product_name,
    category,
    gender,
    color,
    size,
    revenue,
    units_sold,
    gross_profit,
    gross_margin_percent,
    return_rate_percent,
    ending_inventory,
    units_sold_last_30_days,
    units_sold_last_60_days,
    sell_through_rate_percent,
    inventory_age_days,
    stockout_risk_level,
    inventory_status,

    CASE
        WHEN sell_through_rate_percent >= 70
         AND ending_inventory <= 25
         AND COALESCE(return_rate_percent, 0) < 10
        THEN 'Restock'

        WHEN inventory_age_days >= 90
         AND sell_through_rate_percent < 30
         AND ending_inventory >= 50
        THEN 'Markdown'

        WHEN sell_through_rate_percent >= 60
         AND ending_inventory >= 50
        THEN 'Promote'

        WHEN COALESCE(return_rate_percent, 0) >= 12
        THEN 'Review Product Experience'

        ELSE 'Monitor'
    END AS recommended_action,

    CASE
        WHEN sell_through_rate_percent >= 70
         AND ending_inventory <= 25
         AND COALESCE(return_rate_percent, 0) < 10
        THEN 'High demand and low inventory'

        WHEN inventory_age_days >= 90
         AND sell_through_rate_percent < 30
         AND ending_inventory >= 50
        THEN 'Older product with low sell-through and high inventory'

        WHEN sell_through_rate_percent >= 60
         AND ending_inventory >= 50
        THEN 'Strong demand with enough inventory to support promotion'

        WHEN COALESCE(return_rate_percent, 0) >= 12
        THEN 'High return rate may indicate sizing, quality, or customer expectation issue'

        ELSE 'No immediate action needed'
    END AS recommendation_reason

FROM product_metrics;


-- ============================================================
-- 9. Return Reason Breakdown
-- Return count and percentage by reason
-- ============================================================

CREATE VIEW v_return_reason_breakdown AS
SELECT
    return_reason,
    COUNT(*) AS return_count,
    ROUND(COUNT(*)::numeric / NULLIF((SELECT COUNT(*) FROM returns), 0) * 100, 2) AS percent_of_returns,
    ROUND(SUM(refund_amount), 2) AS total_refund_amount
FROM returns
GROUP BY return_reason;


-- ============================================================
-- 10. Marketing Campaign Summary
-- Campaign spend by channel, category, and goal
-- ============================================================

CREATE VIEW v_marketing_campaign_summary AS
SELECT
    marketing_channel,
    target_category,
    campaign_goal,
    COUNT(*) AS campaign_count,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(AVG(spend), 2) AS average_spend,
    MIN(start_date) AS earliest_campaign_start,
    MAX(end_date) AS latest_campaign_end
FROM marketing_campaigns
GROUP BY
    marketing_channel,
    target_category,
    campaign_goal;


-- ============================================================
-- End of Views
-- ============================================================