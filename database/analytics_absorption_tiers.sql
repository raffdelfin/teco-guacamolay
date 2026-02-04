-- ANALYTICS: ABSORPTION TIERS (Trend Aware + Statistical Gating)
-- Calculates "Months of Inventory" (MOI) by Price Tier to detect market shifts.
DROP VIEW IF EXISTS analytics_absorption_tiers CASCADE;
CREATE VIEW analytics_absorption_tiers AS
WITH categorized_listings AS (
    SELECT
        city, property_type, status, first_seen_date, last_seen_date,
        CASE
            WHEN price_mxn < 5000000 THEN 'Entry'
            WHEN price_mxn <= 12000000 THEN 'Mid'
            ELSE 'Luxury'
        END as price_tier
    FROM market_status_view
    WHERE data_quality = 'Verified'
),
inventory_snapshots AS (
    SELECT
        city, property_type, price_tier,
        COUNT(*) FILTER (WHERE status = 'Active') as active_current,
        COUNT(*) FILTER (
            WHERE first_seen_date < CURRENT_DATE - INTERVAL '7 days'
            AND last_seen_date >= CURRENT_DATE - INTERVAL '7 days'
        ) as active_lagged
    FROM categorized_listings
    GROUP BY 1, 2, 3
),
clean_sales_events AS (
    SELECT
        cl.city, cl.property_type, cl.price_tier, cl.last_seen_date
    FROM categorized_listings cl
    LEFT JOIN analytics_volatility_vix avi -- Sanitized name
        ON cl.city = avi.city
        AND cl.property_type = avi.property_type
        AND cl.last_seen_date = avi.activity_date
    WHERE cl.status = 'Off-Market'
      AND COALESCE(avi.z_score_out, 0) <= 3.5 -- Gate to exclude administrative purges
),
sales_windows AS (
    SELECT
        city, property_type, price_tier,
        COUNT(*) FILTER (WHERE last_seen_date >= CURRENT_DATE - INTERVAL '30 days') as sales_30d_current,
        COUNT(*) FILTER (
            WHERE last_seen_date >= CURRENT_DATE - INTERVAL '37 days'
            AND last_seen_date < CURRENT_DATE - INTERVAL '7 days'
        ) as sales_30d_lagged
    FROM clean_sales_events
    GROUP BY 1, 2, 3
)
SELECT
    i.city, i.property_type, i.price_tier,
    i.active_current as active_listings,
    COALESCE(s.sales_30d_current, 0) as monthly_sales_pace,
    CASE
        WHEN COALESCE(s.sales_30d_current, 0) > 0
        THEN ROUND(i.active_current::numeric / s.sales_30d_current, 1)
        ELSE NULL
    END as months_of_inventory,
    CASE
        WHEN COALESCE(s.sales_30d_lagged, 0) > 0
        THEN ROUND(i.active_lagged::numeric / s.sales_30d_lagged, 1)
        ELSE NULL
    END as prev_months_of_inventory,
    CASE
        WHEN COALESCE(s.sales_30d_current, 0) > 0 AND COALESCE(s.sales_30d_lagged, 0) > 0
        THEN ROUND((i.active_current::numeric / s.sales_30d_current) - (i.active_lagged::numeric / s.sales_30d_lagged), 1)
        ELSE NULL
    END as moi_delta
FROM inventory_snapshots i
LEFT JOIN sales_windows s ON i.city = s.city AND i.property_type = s.property_type AND i.price_tier = s.price_tier;
