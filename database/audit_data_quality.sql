-- AUDIT DATA QUALITY
-- Identifies "Ghost Listings" (Missing Dimensions) and "Lazy Entry" (Copy-Paste Errors).
DROP VIEW IF EXISTS audit_data_quality CASCADE;
CREATE VIEW audit_data_quality AS
SELECT
    city,
    property_type,
    advertiser_id,
    COUNT(*) as total_listings,
    COUNT(*) FILTER (WHERE land_m2 = 0 AND built_m2 = 0) as ghost_count,
    COUNT(*) FILTER (WHERE land_m2 = built_m2 AND land_m2 > 0) as lazy_entry_count,
    ROUND(
        (COUNT(*) FILTER (WHERE land_m2 <> built_m2 AND (land_m2 > 0 OR built_m2 > 0))::numeric
        / NULLIF(COUNT(*), 0)) * 100
    , 1) as data_integrity_score
FROM listings
GROUP BY city, property_type, advertiser_id;
