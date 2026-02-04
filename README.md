# Mexico Real Estate: Forensic Data Pipeline

**NOTE: This repository is a public, sanitized version of a private production codebase. Proprietary scraping logic, specific heuristic keywords, and sensitive market configurations have been omitted to protect intellectual property while showcasing architectural design and engineering standards.**

A high-fidelity data engineering pipeline designed to solve the "Moving Baseline" problem in fragmented real estate markets. This project transforms raw, unstandardized property data into actionable, bilingual (English/Spanish) market intelligence.

## 🏗️ Systems Philosophy
Built with a focus on **High Cohesion** and **Loose Coupling** (SRP). This project demonstrates a commitment to "Software Craftsmanship"—prioritizing code that is defensible, maintainable, and resilient.

* **Data Integrity:** Employs a multi-stage firewall (Z-Score & Bulk Purge Gating) to filter statistical anomalies.
* **Systems Rigor:** Uses Materialized Views and a multi-tiered SQL architecture to decouple heavy analytical calculations from the reporting interface.
* **Technical Empathy:** Comprehensive documentation of market distortions and edge cases to ensure data is interpreted with the correct context.

## 🛠️ Tech Stack
* **Language:** Python 3.10
* **Automation:** Playwright (Stealth)
* **Database:** PostgreSQL v17 (Relational Modeling & Materialized Views)
* **Intelligence:** Gemini SDK (LLM-driven narrative generation)
* **Environment:** OS-agnostic configuration via `python-dotenv`

## 🛰️ Architecture Highlights

### 1. The Relational Foundation
The core schema (`schema.sql`) implements a strict relational design, separating static property metadata from time-series price history. This allows for the calculation of historical volatility and "Capitulation Indices" without duplicating core listing data.

### 2. Materialized Intelligence Layer
To ensure high performance, the pipeline utilizes a "Thin Client" backend. Complex metrics like **Absorption Tiers** (`analytics_absorption_tiers.sql`) and **Market Momentum** (`analytics_market_momentum.sql`) are pre-calculated in PostgreSQL. This allows the system to detect "Tier Flips" (markets shifting from Seller to Buyer states) in real-time.

### 3. Forensic Auditing & Data Hygiene
The pipeline includes a specialized **Data Quality Audit** layer (`audit_data_quality.sql`) that identifies "Ghost Listings" and "Lazy Entries" by comparing Land vs. Built dimensions. It also scans unstructured text for regional legal risks, converting "noisy" descriptions into structured risk-density metrics.

### 4. Strategic Reporting
The reporting layer transforms raw calculations into business-ready insights. The **Absorption Heatmap** identifies supply/velocity imbalances, while the **Panic Intensity Score** (`report_panic_zones.sql`) normalizes price drop volume against total inventory to reveal true market pressure.

## 📂 Repository Structure
* **/architecture**: High-level [Design Maps](./architecture/dependency_graph.md) and [Known Market Limitations](./architecture/data_limitations.md).
* **/database**:
    * `schema.sql`: Relational design for listings and time-series history.
    * `market_pulse_view.sql`: Core logic for DOM and multi-currency normalization.
    * `analytics_absorption_tiers.sql`: Logic for inventory aging, sales velocity, and price-tier segmentation.
    * `report_absorption_heatmap.sql`: Strategic view for identifying "Buyer vs. Seller" market states.
    * `analytics_market_momentum.sql`: Analytical engine for tracking price dislocations over 7/15/30 day windows.
    * `report_panic_zones.sql`: Normalized ranking of neighborhoods by "Panic Intensity."
    * `audit_data_quality.sql`: Forensic integrity checks for missing or "lazy" data entry.
* **/src/core**: Core service modules including database management, telemetry, and custom exception handling.
