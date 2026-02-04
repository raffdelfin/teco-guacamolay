class CriticalBlockingError(Exception):
    """
    Raised when the scraper detects a hard block (Cloudflare/403) 
    that requires immediate pipeline termination.
    """
    pass