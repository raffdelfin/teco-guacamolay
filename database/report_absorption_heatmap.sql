-- REPORT: ABSORPTION HEATMAP (Strategic)
-- Categorizes the "Buyer's vs. Seller's Market" state.
-- Compares Supply (Inventory) vs. Velocity (Sales Pace) to identify saturation or scarcity.
DROP VIEW IF EXISTS report_absorption_heatmap CASCADE;
CREATE VIEW report_absorption_heatmap AS
SELECT
    city,
    price_tier,
    property_type,
    -- Core Metric: Months of Inventory (MOI)
    SUM(months_of_inventory) AS total_moi,
    -- Trend Metrics: Detecting "Tier Flips"
    SUM(prev_months_of_inventory) AS prev_total_moi,
    SUM(moi_delta) AS total_moi_delta
FROM
    analytics_absorption_tiers
GROUP BY
    city,
    price_tier,
    property_type;
