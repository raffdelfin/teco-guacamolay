# DATA LIMITATIONS & STRATEGIC CONSTRAINTS

**Purpose:** Document known distortions in the dataset to prevent misinterpretation of the "Riviera Maya Market Analysis" metrics.
**Scope:** Real Estate Scraper.

## 1. Inventory Volume Distortions
* **The "Desarrollo" (New Development) Compression:**
    * *Observation:* Pre-construction projects (Developments) often purchase a single "Showcase" listing slot to represent an entire building or phase.
    * *Impact:* **Months of Inventory** will be significantly *underestimated*. A single record in our DB might represent 50+ actual available units.
    * *Strategic Note:* Metric should be labeled "Active Listing Slots" rather than "Total Units Available."

* **The "Agent Spam" Multiplier:**
    * *Observation:* Multiple agents often list the exact same resale property to capture the lead.
    * *Impact:* **Inventory Levels** may be *overestimated* by 15-20%.
    * *Mitigation:* We rely on SQL deduplication (grouping by Price + M2 + Title Similarity) to calculate "True Unique Inventory" vs. "Raw Listing Count."

## 2. Transactional Blind Spots ("Sold" vs. "Expired")
* **The "Sold" Proxy Problem:**
    * *Observation:* The platform removes listings but does not tag them as "Sold" or disclose the closing price.
    * *Impact:* We cannot calculate an exact **Sold to List Ratio** or **Units Sold**.
    * *Workaround:* We must define a proxy logic: *If Listing disappears AND was not re-uploaded within 10 days -> Assume "Sold/Off-Market".*
    * *Critical Gap:* We only see the *Last Asking Price*, not the *Closing Price*. In Mexico, the spread can be significant (5-15%).

## 3. Temporal Distortions (Days on Market - DOM)
* **The "Refresh" Tactic:**
    * *Observation:* Agents frequently delete and re-create listings to reset the portal's "Days Online" counter.
    * *Impact:* **Average DOM** will appear artificially low.
    * *Mitigation:* Our `price_history` table tracks assets by characteristics. If a "new" ID appears with identical specs to a deleted ID, we can link them (Advanced Logic required).

* **The "Baseline Bias":**
    * *Observation:* For the first scrape (Pre-Production run), every listing has `first_seen_date = TODAY`.
    * *Impact:* DOM metrics will be statistically invalid for the first 30-60 days of operation. The dataset needs to "mature" before DOM becomes reliable.

## 4. Market Coverage ("Shadow Inventory")
* **Platform Exclusivity:**
    * *Observation:* Target website is a dominant player, but not a monopoly. Lower-end inventory often lives on Facebook Marketplace; high-end luxury often lives in private WhatsApp groups ("Pocket Listings").
    * *Impact:* Our analysis represents the "Public Digital Market," not the "Total Addressable Market."
