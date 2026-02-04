import time
from dataclasses import dataclass, field
from typing import Set, Dict, Any, List

@dataclass
class ScrapeStats:
    """
    Encapsulates all metrics for a single scrape session.
    """
    start_time: float = field(default_factory=time.time)
    listings_processed: int = 0
    total_listings_in_market: int = 0
    captured_ids: Set[str] = field(default_factory=set)
    ids_with_date: Set[str] = field(default_factory=set)

    @property
    def duration(self) -> int:
        return int(time.time() - self.start_time)

    def to_log_payload(self) -> Dict[str, Any]:
        """
        Prepares the stats for the JSONB database column.
        Converts Sets to Lists for JSON serialization.
        """
        return {
            "start_time": self.start_time,
            "duration": self.duration,
            "listings_processed": self.listings_processed,
            "total_listings_in_market": self.total_listings_in_market,
            "captured_count": len(self.captured_ids),
            "date_count": len(self.ids_with_date),
            "captured_ids": list(self.captured_ids),
            "ids_with_date": list(self.ids_with_date)
        }