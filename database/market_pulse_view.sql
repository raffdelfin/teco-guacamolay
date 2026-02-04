-- ANALYTICS_MARKET_PULSE (Sanitized for Portfolio)
-- A health dashboard that demonstrates the ability to handle:
--   - Native vs. Converted Currency Metrics
--   - Forensic Days on Market (DOM) calculation using fallbacks
--   - Verified Data Quality Filtering

DROP VIEW IF EXISTS analytics_market_pulse CASCADE;
CREATE VIEW analytics_market_pulse AS
SELECT
    m.city,
    m.zone,
    m.property_type,

    -- Volume Analysis
    count(*) as active_listings,

    -- Multi-Currency Normalization
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY m.price_mxn) as median_price_mxn,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY m.price_usd) as median_price_usd,

    -- Performance Metrics (Days on Market)
    -- Demonstrates complex COALESCE and conditional filtering
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY (CURRENT_DATE - COALESCE(m.portal_date, m.first_seen_date))
    )
    FILTER (WHERE m.portal_date IS NOT NULL OR m.first_seen_date IS NOT NULL) as median_dom,

    MAX(m.last_seen_date) as last_sync_date

FROM market_status_view m
WHERE m.status = 'Active'
GROUP BY m.city, m.zone, m.property_type;
