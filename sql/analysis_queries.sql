-- ============================================================
-- Athleisure Brand Analytics Platform
-- Analysis Queries
-- Mock Brand: Summit Active
-- ============================================================


-- ============================================================
-- 1. Table Counts
-- Purpose: Confirm data loaded correctly
-- ============================================================

SELECT 'products' AS table_name, COUNT(*) AS row_count FROM products
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'inventory_snapshots', COUNT(*) FROM inventory_snapshots
UNION ALL
SELECT 'returns', COUNT(*) FROM returns
UNION ALL
SELECT 'marketing_campaigns', COUNT(*) FROM marketing_campaigns;


-- ============================================================
-- 2. Revenue by Product Category
-- Purpose: Identify which categories generate the most revenue
-- ============================================================

SELECT
    p.category,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.gross_profit), 2) AS gross_profit,
    ROUND(SUM(oi.gross_profit) / NULLIF(SUM(oi.net_sales), 0) * 100, 2) AS gross_margin_percent
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;


-- ============================================================
-- 3. Revenue by Sales Channel
-- Purpose: Compare Ecommerce, Retail, and Wholesale performance
-- ============================================================

SELECT
    o.channel,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.net_sales) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.channel
ORDER BY revenue DESC;


-- ============================================================
-- 4. Monthly Revenue Trend
-- Purpose: Show sales performance over time
-- ============================================================

SELECT
    DATE_TRUNC('month', o.order_date)::date AS sales_month,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.gross_profit), 2) AS gross_profit
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY sales_month;


-- ============================================================
-- 5. Top 20 Products by Revenue
-- Purpose: Identify strongest individual products
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.gender,
    p.color,
    p.size,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.gross_profit), 2) AS gross_profit,
    ROUND(SUM(oi.gross_profit) / NULLIF(SUM(oi.net_sales), 0) * 100, 2) AS gross_margin_percent
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.gender,
    p.color,
    p.size
ORDER BY revenue DESC
LIMIT 20;


-- ============================================================
-- 6. Gross Margin by Category
-- Purpose: Identify which categories are most profitable
-- ============================================================

SELECT
    p.category,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    ROUND(SUM(oi.gross_profit), 2) AS gross_profit,
    ROUND(SUM(oi.gross_profit) / NULLIF(SUM(oi.net_sales), 0) * 100, 2) AS gross_margin_percent
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY gross_margin_percent DESC;


-- ============================================================
-- 7. Revenue by Region
-- Purpose: Compare geographic performance
-- ============================================================

SELECT
    o.region,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.net_sales) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.region
ORDER BY revenue DESC;


-- ============================================================
-- 8. Return Rate by Category
-- Purpose: Identify categories with high return rates
-- ============================================================

WITH sold_by_category AS (
    SELECT
        p.category,
        SUM(oi.quantity) AS units_sold
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.category
),

returned_by_category AS (
    SELECT
        p.category,
        SUM(r.quantity_returned) AS units_returned
    FROM returns r
    JOIN products p
        ON r.product_id = p.product_id
    GROUP BY p.category
)

SELECT
    s.category,
    s.units_sold,
    COALESCE(r.units_returned, 0) AS units_returned,
    ROUND(COALESCE(r.units_returned, 0)::numeric / NULLIF(s.units_sold, 0) * 100, 2) AS return_rate_percent
FROM sold_by_category s
LEFT JOIN returned_by_category r
    ON s.category = r.category
ORDER BY return_rate_percent DESC;


-- ============================================================
-- 9. Return Reason Breakdown
-- Purpose: Understand why customers are returning products
-- ============================================================

SELECT
    return_reason,
    COUNT(*) AS return_count,
    ROUND(COUNT(*)::numeric / NULLIF((SELECT COUNT(*) FROM returns), 0) * 100, 2) AS percent_of_returns
FROM returns
GROUP BY return_reason
ORDER BY return_count DESC;


-- ============================================================
-- 10. Latest Inventory Snapshot
-- Purpose: Get the most recent inventory position for every product
-- ============================================================

WITH latest_inventory AS (
    SELECT
        i.*,
        ROW_NUMBER() OVER (
            PARTITION BY i.product_id
            ORDER BY i.snapshot_date DESC
        ) AS row_num
    FROM inventory_snapshots i
)

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.gender,
    p.color,
    p.size,
    li.snapshot_date,
    li.ending_inventory
FROM latest_inventory li
JOIN products p
    ON li.product_id = p.product_id
WHERE li.row_num = 1
ORDER BY li.ending_inventory DESC;


-- ============================================================
-- 11. Sell-Through Rate by Product
-- Purpose: Identify products moving quickly or slowly
-- ============================================================

WITH yearly_inventory AS (
    SELECT
        product_id,
        SUM(units_sold) AS units_sold,
        MAX(snapshot_date) AS latest_snapshot_date
    FROM inventory_snapshots
    GROUP BY product_id
),

latest_inventory AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        ending_inventory
    FROM inventory_snapshots
    ORDER BY product_id, snapshot_date DESC
)

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.gender,
    p.color,
    p.size,
    y.units_sold,
    l.ending_inventory,
    ROUND(y.units_sold::numeric / NULLIF(y.units_sold + l.ending_inventory, 0) * 100, 2) AS sell_through_rate_percent
FROM yearly_inventory y
JOIN latest_inventory l
    ON y.product_id = l.product_id
JOIN products p
    ON y.product_id = p.product_id
ORDER BY sell_through_rate_percent DESC;


-- ============================================================
-- 12. Slow-Moving Products
-- Purpose: Identify products with low sales and high inventory
-- ============================================================

WITH latest_inventory AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        snapshot_date,
        ending_inventory
    FROM inventory_snapshots
    ORDER BY product_id, snapshot_date DESC
),

recent_sales AS (
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
    li.ending_inventory,
    COALESCE(rs.units_sold_last_60_days, 0) AS units_sold_last_60_days,
    ((SELECT MAX(order_date) FROM orders)::date - p.launch_date) AS inventory_age_days
FROM products p
JOIN latest_inventory li
    ON p.product_id = li.product_id
LEFT JOIN recent_sales rs
    ON p.product_id = rs.product_id
WHERE COALESCE(rs.units_sold_last_60_days, 0) <= 10
  AND li.ending_inventory >= 50
ORDER BY li.ending_inventory DESC;


-- ============================================================
-- 13. Stockout Risk Products
-- Purpose: Identify products with high recent demand and low inventory
-- ============================================================

WITH latest_inventory AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        snapshot_date,
        ending_inventory
    FROM inventory_snapshots
    ORDER BY product_id, snapshot_date DESC
),

recent_sales AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold_last_30_days
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_date >= (SELECT MAX(order_date) FROM orders) - INTERVAL '30 days'
    GROUP BY oi.product_id
)

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.gender,
    p.color,
    p.size,
    li.ending_inventory,
    COALESCE(rs.units_sold_last_30_days, 0) AS units_sold_last_30_days,
    CASE
        WHEN li.ending_inventory <= 20
         AND COALESCE(rs.units_sold_last_30_days, 0) >= 10
        THEN 'High Stockout Risk'
        WHEN li.ending_inventory <= 35
         AND COALESCE(rs.units_sold_last_30_days, 0) >= 8
        THEN 'Moderate Stockout Risk'
        ELSE 'Low Stockout Risk'
    END AS stockout_risk
FROM products p
JOIN latest_inventory li
    ON p.product_id = li.product_id
LEFT JOIN recent_sales rs
    ON p.product_id = rs.product_id
WHERE li.ending_inventory <= 35
ORDER BY
    COALESCE(rs.units_sold_last_30_days, 0) DESC,
    li.ending_inventory ASC;


-- ============================================================
-- 14. Markdown Candidates
-- Purpose: Identify products that may need discounts or promotions
-- ============================================================

WITH latest_inventory AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        snapshot_date,
        ending_inventory
    FROM inventory_snapshots
    ORDER BY product_id, snapshot_date DESC
),

yearly_sell_through AS (
    SELECT
        i.product_id,
        SUM(i.units_sold) AS units_sold
    FROM inventory_snapshots i
    GROUP BY i.product_id
)

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.gender,
    p.color,
    p.size,
    li.ending_inventory,
    y.units_sold,
    ROUND(y.units_sold::numeric / NULLIF(y.units_sold + li.ending_inventory, 0) * 100, 2) AS sell_through_rate_percent,
    ((SELECT MAX(order_date) FROM orders)::date - p.launch_date) AS inventory_age_days,
    'Markdown Candidate' AS recommendation
FROM products p
JOIN latest_inventory li
    ON p.product_id = li.product_id
JOIN yearly_sell_through y
    ON p.product_id = y.product_id
WHERE ((SELECT MAX(order_date) FROM orders)::date - p.launch_date) >= 90
  AND y.units_sold::numeric / NULLIF(y.units_sold + li.ending_inventory, 0) < 0.30
  AND li.ending_inventory >= 50
ORDER BY li.ending_inventory DESC;


-- ============================================================
-- 15. Restock Candidates
-- Purpose: Identify strong products that may need replenishment
-- ============================================================

WITH latest_inventory AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        snapshot_date,
        ending_inventory
    FROM inventory_snapshots
    ORDER BY product_id, snapshot_date DESC
),

yearly_sell_through AS (
    SELECT
        i.product_id,
        SUM(i.units_sold) AS units_sold
    FROM inventory_snapshots i
    GROUP BY i.product_id
),

product_returns AS (
    SELECT
        product_id,
        SUM(quantity_returned) AS units_returned
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
    li.ending_inventory,
    y.units_sold,
    ROUND(y.units_sold::numeric / NULLIF(y.units_sold + li.ending_inventory, 0) * 100, 2) AS sell_through_rate_percent,
    ROUND(COALESCE(pr.units_returned, 0)::numeric / NULLIF(y.units_sold, 0) * 100, 2) AS return_rate_percent,
    'Restock Candidate' AS recommendation
FROM products p
JOIN latest_inventory li
    ON p.product_id = li.product_id
JOIN yearly_sell_through y
    ON p.product_id = y.product_id
LEFT JOIN product_returns pr
    ON p.product_id = pr.product_id
WHERE y.units_sold::numeric / NULLIF(y.units_sold + li.ending_inventory, 0) >= 0.70
  AND li.ending_inventory <= 25
  AND COALESCE(pr.units_returned, 0)::numeric / NULLIF(y.units_sold, 0) < 0.10
ORDER BY sell_through_rate_percent DESC;


-- ============================================================
-- 16. Product Recommendation Summary
-- Purpose: Create a single table of recommended business actions
-- ============================================================

WITH latest_inventory AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        snapshot_date,
        ending_inventory
    FROM inventory_snapshots
    ORDER BY product_id, snapshot_date DESC
),

yearly_sales AS (
    SELECT
        i.product_id,
        SUM(i.units_sold) AS units_sold
    FROM inventory_snapshots i
    GROUP BY i.product_id
),

product_returns AS (
    SELECT
        product_id,
        SUM(quantity_returned) AS units_returned
    FROM returns
    GROUP BY product_id
),

metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.gender,
        p.color,
        p.size,
        li.ending_inventory,
        y.units_sold,
        ROUND(y.units_sold::numeric / NULLIF(y.units_sold + li.ending_inventory, 0) * 100, 2) AS sell_through_rate_percent,
        ROUND(COALESCE(pr.units_returned, 0)::numeric / NULLIF(y.units_sold, 0) * 100, 2) AS return_rate_percent,
        ((SELECT MAX(order_date) FROM orders)::date - p.launch_date) AS inventory_age_days
    FROM products p
    JOIN latest_inventory li
        ON p.product_id = li.product_id
    JOIN yearly_sales y
        ON p.product_id = y.product_id
    LEFT JOIN product_returns pr
        ON p.product_id = pr.product_id
)

SELECT
    product_id,
    product_name,
    category,
    gender,
    color,
    size,
    ending_inventory,
    units_sold,
    sell_through_rate_percent,
    return_rate_percent,
    inventory_age_days,
    CASE
        WHEN sell_through_rate_percent >= 70
         AND ending_inventory <= 25
         AND return_rate_percent < 10
        THEN 'Restock'

        WHEN inventory_age_days >= 90
         AND sell_through_rate_percent < 30
         AND ending_inventory >= 50
        THEN 'Markdown'

        WHEN sell_through_rate_percent >= 60
         AND ending_inventory >= 50
        THEN 'Promote'

        WHEN return_rate_percent >= 12
        THEN 'Review Product Experience'

        ELSE 'Monitor'
    END AS recommended_action
FROM metrics
ORDER BY
    CASE
        WHEN sell_through_rate_percent >= 70
         AND ending_inventory <= 25
         AND return_rate_percent < 10
        THEN 1

        WHEN inventory_age_days >= 90
         AND sell_through_rate_percent < 30
         AND ending_inventory >= 50
        THEN 2

        WHEN sell_through_rate_percent >= 60
         AND ending_inventory >= 50
        THEN 3

        WHEN return_rate_percent >= 12
        THEN 4

        ELSE 5
    END,
    units_sold DESC;


-- ============================================================
-- 17. Marketing Campaign Overview
-- Purpose: Review campaign spend by channel and target category
-- ============================================================

SELECT
    marketing_channel,
    target_category,
    campaign_goal,
    COUNT(*) AS campaign_count,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(AVG(spend), 2) AS average_spend
FROM marketing_campaigns
GROUP BY
    marketing_channel,
    target_category,
    campaign_goal
ORDER BY total_spend DESC;


-- ============================================================
-- 18. Executive KPI Summary
-- Purpose: One-row summary for dashboard cards
-- ============================================================

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