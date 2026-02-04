import psycopg2
import json
import time
import pandas as pd
from typing import List, Dict, Set, Any
# Sanitized config import
# from src.config import DB_CONFIG

class DatabaseManager:
    """
    Handles interactions with the PostgreSQL database.
    Implements a robust Auto-Reconnect logic and batch optimization for high-uptime
    scraping environments.
    """

    def __init__(self, db_config: Dict):
        self.conn = None
        self.db_config = db_config
        self.connect()

    def connect(self):
        """Establishes a connection with retry logic."""
        max_retries = 5
        for i in range(max_retries):
            try:
                if self.conn:
                    try: self.conn.close()
                    except: pass
                self.conn = psycopg2.connect(**self.db_config)
                return
            except Exception as e:
                print(f"⏳ DB Connection Attempt {i+1}/{max_retries} Failed: {e}")
                if i < max_retries - 1:
                    time.sleep(2)
        raise ConnectionError("Could not connect to Database after multiple retries.")

    def _ensure_connection(self):
        """Verifies if the connection is alive; reconnects if necessary."""
        try:
            if self.conn is None or self.conn.closed != 0:
                self.connect()
        except Exception:
            self.connect()

    def upsert_listing(self, data: Dict[str, Any], city: str, property_type: str, today_date: str) -> bool:
        """
        Inserts or Updates a listing using the PostgreSQL ON CONFLICT clause.
        Returns: True if NEW listing created, False if EXISTING listing updated.
        """
        self._ensure_connection()
        cur = self.conn.cursor()
        try:
            cur.execute('''
                INSERT INTO listings
                (id, url, title, location, city, property_type, land_m2, built_m2,
                 first_seen_date, last_seen_date, description, latitude, longitude,
                 portal_date)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (id) DO UPDATE SET
                    last_seen_date = EXCLUDED.last_seen_date,
                    url = EXCLUDED.url,
                    title = EXCLUDED.title,
                    description = COALESCE(NULLIF(EXCLUDED.description, ''), listings.description),
                    latitude = COALESCE(EXCLUDED.latitude, listings.latitude),
                    longitude = COALESCE(EXCLUDED.longitude, listings.longitude),
                    portal_date = COALESCE(EXCLUDED.portal_date, listings.portal_date)
                RETURNING (xmax = 0) AS is_new_entry;
            ''', (
                data['id'], data['url'], data['title'], data['location_name'], city, property_type,
                data['land_m2'], data['built_m2'], today_date, today_date, data['description'],
                data['latitude'], data['longitude'], data.get('portal_date')
            ))

            is_new_entry = cur.fetchone()[0]
            self.conn.commit()
            return is_new_entry
        except Exception as e:
            self.conn.rollback()
            return False
        finally:
            cur.close()

    def apply_heuristic_tags(self):
        """
        Sanitized heuristic tagging logic.
        Classifies listings based on keyword patterns found in unstructured descriptions.
        """
        self._ensure_connection()
        # Public version uses generalized categories
        query = """
        UPDATE listings
        SET metadata_tags = ARRAY_REMOVE(ARRAY[
            CASE WHEN description ~* 'keyword_a|keyword_b' THEN 'Category_1' ELSE NULL END,
            CASE WHEN description ~* 'keyword_c|keyword_d' THEN 'Category_2' ELSE NULL END
        ], NULL)
        WHERE metadata_tags IS NULL;
        """
        cur = self.conn.cursor()
        try:
            cur.execute(query)
            self.conn.commit()
        except Exception as e:
            self.conn.rollback()
        finally:
            cur.close()
