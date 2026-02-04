# Data Dependency Graph

## Level 0: Ingestion
* `listings`
* `price_history`
* `exchange_rates`

## Level 1: Core Materialized Layer
**Role:** Heavy-lifting normalization.
* **`market_status_view`**: Implements FX conversion and data quality validation.
* **`analytics_volatility_vix`**: Pre-calculates statistical z-scores for anomaly detection.

## Level 2: Presentation Layer
**Role:** Formatting for the Publishing Engine.
* **`report_pulse_summary`**: High-level market health.
* **`report_opportunity_matrix`**: Identifying price-to-staleness outliers.
* **`report_risk_zones`**: Geospatial aggregation of heuristic tags.
