-- 1. Core Ingestion Table
CREATE TABLE listings (
    id VARCHAR(255) PRIMARY KEY,
    url TEXT NOT NULL,
    title TEXT,
    city VARCHAR(100),
    property_type VARCHAR(50),
    land_m2 NUMERIC(12,2),
    built_m2 NUMERIC(12,2),
    first_seen_date DATE NOT NULL,
    last_seen_date DATE NOT NULL,
    portal_date DATE,
    -- Array to store dynamically generated tags based on
    -- heuristic analysis of the description field.
    metadata_tags TEXT[],
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
);

-- 2. Time-Series Price Tracking
CREATE TABLE price_history (
    id SERIAL PRIMARY KEY,
    listing_id VARCHAR(255) REFERENCES listings(id) ON DELETE CASCADE,
    price_amount NUMERIC(18,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    scrape_date DATE NOT NULL,
    UNIQUE(listing_id, scrape_date, price_amount)
);

-- 3. Operational Logging
CREATE TABLE system_logs (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(50),
    message TEXT,
    payload JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
