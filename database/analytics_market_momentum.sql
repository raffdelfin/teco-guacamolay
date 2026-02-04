-- MARKET MOMENTUM (THE "RADAR")
-- Aggregates recent discount activity (7/15/30 days) to highlight market volatility.
-- Includes a "Sanity Window" (5-40%) to exclude typos and non-material drops.
DROP VIEW IF EXISTS analytics_market_momentum CASCADE;
CREATE VIEW analytics_market_momentum AS
WITH drop_events AS (
    SELECT
        ph.listing_id,
        ph.scrape_date,
        ph.price_amount,
        LAG(ph.price_amount) OVER (PARTITION BY ph.listing_id ORDER BY ph.scrape_date) as prev_price
    FROM price_history ph
),
confirmed_drops AS (
    SELECT
        d.listing_id,
        d.scrape_date as drop_date,
        ((d.prev_price - d.price_amount) / d.prev_price::numeric) as drop_pct
    FROM drop_events d
    WHERE d.prev_price IS NOT NULL
      AND d.price_amount < d.prev_price -- Logic: Only price REDUCTIONS
)
SELECT
    m.city,
    m.zone,
    m.property_type,

    -- Time Windows for Trend Analysis
    COUNT(CASE WHEN cd.drop_date >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END) as drops_7d,
    COUNT(CASE WHEN cd.drop_date >= CURRENT_DATE - INTERVAL '15 days' THEN 1 END) as drops_15d,
    COUNT(CASE WHEN cd.drop_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as drops_30d,

    -- Metric Quality: Average depth of confirmed discounts
    ROUND(AVG(cd.drop_pct), 1) as avg_drop_depth_pct

FROM confirmed_drops cd
JOIN market_status_view m ON cd.listing_id = m.id
WHERE m.data_quality = 'Verified'
  AND cd.drop_pct BETWEEN 0.05 AND 0.40 -- The Sanity Window: Excludes outliers/typos
GROUP BY m.city, m.zone, m.property_type;
