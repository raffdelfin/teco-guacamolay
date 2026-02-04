-- REPORT: PANIC ZONES (Strategic)
-- Normalizes price drop volume against inventory to reveal "Panic Intensity."
DROP VIEW IF EXISTS report_panic_zones CASCADE;
CREATE VIEW report_panic_zones AS
WITH inventory AS (
    SELECT city, zone, property_type, active_listings
    FROM analytics_market_pulse
)
SELECT
    m.city, m.zone, m.property_type,
    m.drops_7d, m.avg_drop_depth_pct,
    COALESCE(i.active_listings, 0) as zone_inventory,
    ROUND((m.drops_7d::numeric / NULLIF(i.active_listings, 0)) * 100, 2) as panic_intensity_score
FROM analytics_market_momentum m
LEFT JOIN inventory i ON m.city = i.city AND m.zone = i.zone AND m.property_type = i.property_type
WHERE m.drops_7d > 0 AND i.active_listings >= 5
ORDER BY panic_intensity_score DESC;
