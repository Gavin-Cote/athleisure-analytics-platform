-- ============================================================
-- Updated Inventory Health & Product Recommendation Logic
-- Purpose: Create more realistic recommendation distribution
-- ============================================================

DROP VIEW IF EXISTS v_product_recommendations;
DROP VIEW IF EXISTS v_inventory_health;

-- ============================================================
-- Inventory Health View
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
),

base AS (
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
        ROUND(
            COALESCE(y.yearly_units_sold, 0)::numeric
            / NULLIF(COALESCE(y.yearly_units_sold, 0) + li.ending_inventory, 0)
            * 100,
            2
        ) AS sell_through_rate_percent,
        ((SELECT MAX(order_date) FROM orders)::date - p.launch_date) AS inventory_age_days
    FROM products p
    JOIN latest_inventory li
        ON p.product_id = li.product_id
    LEFT JOIN yearly_inventory y
        ON p.product_id = y.product_id
    LEFT JOIN recent_30_day_sales r30
        ON p.product_id = r30.product_id
    LEFT JOIN recent_60_day_sales r60
        ON p.product_id = r60.product_id
),

thresholds AS (
    SELECT
        percentile_cont(0.75) WITHIN GROUP (ORDER BY yearly_units_sold) AS high_sales_threshold,
        percentile_cont(0.25) WITHIN GROUP (ORDER BY yearly_units_sold) AS low_sales_threshold,
        percentile_cont(0.25) WITHIN GROUP (ORDER BY ending_inventory) AS low_inventory_threshold,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY ending_inventory) AS high_inventory_threshold
    FROM base
)

SELECT
    b.product_id,
    b.product_name,
    b.category,
    b.gender,
    b.color,
    b.size,
    b.season,
    b.launch_date,
    b.latest_snapshot_date,
    b.ending_inventory,
    b.yearly_units_sold,
    b.units_sold_last_30_days,
    b.units_sold_last_60_days,
    b.sell_through_rate_percent,
    b.inventory_age_days,

    CASE
        WHEN b.ending_inventory <= t.low_inventory_threshold
         AND b.yearly_units_sold >= t.high_sales_threshold
        THEN 'High Stockout Risk'

        WHEN b.ending_inventory <= t.low_inventory_threshold
         AND b.units_sold_last_30_days >= 2
        THEN 'Moderate Stockout Risk'

        ELSE 'Low Stockout Risk'
    END AS stockout_risk_level,

    CASE
        WHEN b.yearly_units_sold >= t.high_sales_threshold
        THEN 'Fast Moving'

        WHEN b.yearly_units_sold <= t.low_sales_threshold
         AND b.ending_inventory >= t.high_inventory_threshold
        THEN 'Slow Moving'

        ELSE 'Healthy'
    END AS inventory_status

FROM base b
CROSS JOIN thresholds t;


-- ============================================================
-- Product Recommendations View
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
),

thresholds AS (
    SELECT
        percentile_cont(0.35) WITHIN GROUP (ORDER BY ending_inventory) AS restock_inventory_threshold
    FROM product_metrics
)

SELECT
    pm.product_id,
    pm.product_name,
    pm.category,
    pm.gender,
    pm.color,
    pm.size,
    pm.revenue,
    pm.units_sold,
    pm.gross_profit,
    pm.gross_margin_percent,
    pm.return_rate_percent,
    pm.ending_inventory,
    pm.units_sold_last_30_days,
    pm.units_sold_last_60_days,
    pm.sell_through_rate_percent,
    pm.inventory_age_days,
    pm.stockout_risk_level,
    pm.inventory_status,

    CASE
        WHEN COALESCE(pm.return_rate_percent, 0) >= 12
         AND pm.units_sold >= 10
        THEN 'Review Product Experience'

        WHEN pm.inventory_status = 'Fast Moving'
         AND pm.ending_inventory <= t.restock_inventory_threshold
         AND COALESCE(pm.return_rate_percent, 0) < 10
        THEN 'Restock'

        WHEN pm.inventory_status = 'Slow Moving'
        THEN 'Markdown'

        WHEN pm.inventory_status = 'Fast Moving'
         AND pm.ending_inventory > t.restock_inventory_threshold
        THEN 'Promote'

        ELSE 'Monitor'
    END AS recommended_action,

    CASE
        WHEN COALESCE(pm.return_rate_percent, 0) >= 12
         AND pm.units_sold >= 10
        THEN 'High return rate may indicate sizing, quality, or product expectation issues'

        WHEN pm.inventory_status = 'Fast Moving'
         AND pm.ending_inventory <= t.restock_inventory_threshold
         AND COALESCE(pm.return_rate_percent, 0) < 10
        THEN 'Strong sales velocity with relatively low inventory'

        WHEN pm.inventory_status = 'Slow Moving'
        THEN 'Low sales velocity and high inventory position'

        WHEN pm.inventory_status = 'Fast Moving'
         AND pm.ending_inventory > t.restock_inventory_threshold
        THEN 'Strong sales velocity with enough inventory to support promotion'

        ELSE 'No immediate action needed'
    END AS recommendation_reason

FROM product_metrics pm
CROSS JOIN thresholds t;