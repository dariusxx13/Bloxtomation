"""Polite client for the public endpoints the Roblox website uses for its Charts page.

These endpoints are unofficial and undocumented: they can change without notice. Everything here
tolerates missing fields, spaces requests at least ``delay`` seconds apart, backs off on 429 and
5xx responses, and never authenticates.
"""

from __future__ import annotations

import json
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from typing import Any, Callable, Dict, Iterable, List, Optional

SORTS_URL = "https://apis.roblox.com/explore-api/v1/get-sorts"
GAMES_URL = "https://games.roblox.com/v1/games"
USER_AGENT = "Bloxtomation-charts/1.0 (low-frequency market research)"
DETAILS_BATCH = 50
MAX_PAGES = 12


class FetchError(Exception):
    pass


class Client:
    def __init__(
        self,
        delay: float = 1.0,
        retries: int = 4,
        timeout: float = 30.0,
        opener: Callable[..., Any] = urllib.request.urlopen,
        sleep: Callable[[float], None] = time.sleep,
    ) -> None:
        self.delay = delay
        self.retries = retries
        self.timeout = timeout
        self._open = opener
        self._sleep = sleep
        self._last = 0.0
        self.requests = 0

    def _wait_turn(self) -> None:
        elapsed = time.monotonic() - self._last
        if self._last and elapsed < self.delay:
            self._sleep(self.delay - elapsed)
        self._last = time.monotonic()

    def get_json(self, url: str) -> Dict[str, Any]:
        backoff = 2.0
        last_error: Optional[str] = None
        for attempt in range(self.retries + 1):
            self._wait_turn()
            self.requests += 1
            request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "application/json"})
            try:
                with self._open(request, timeout=self.timeout) as response:
                    return json.loads(response.read().decode("utf-8"))
            except urllib.error.HTTPError as error:
                last_error = f"HTTP {error.code}"
                if error.code not in (429, 500, 502, 503, 504):
                    raise FetchError(f"{last_error} for {url}") from error
                retry_after = error.headers.get("Retry-After") if error.headers else None
                wait = float(retry_after) if retry_after and retry_after.isdigit() else backoff
            except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as error:
                last_error = str(error)
                wait = backoff
            if attempt < self.retries:
                self._sleep(min(wait, 60.0))
                backoff *= 2
        raise FetchError(f"giving up on {url}: {last_error}")

    def sorts(self, device: str = "computer", country: str = "all", max_pages: int = MAX_PAGES) -> List[Dict[str, Any]]:
        """All game sorts on the charts page, in display order."""
        session = str(uuid.uuid4())
        token: Optional[str] = None
        found: List[Dict[str, Any]] = []
        for _ in range(max_pages):
            query = {"sessionId": session, "device": device, "country": country}
            if token:
                query["sortsPageToken"] = token
            payload = self.get_json(f"{SORTS_URL}?{urllib.parse.urlencode(query)}")
            for sort in payload.get("sorts") or []:
                if sort.get("contentType") == "Games" and sort.get("games"):
                    found.append(sort)
            token = payload.get("nextSortsPageToken")
            if not token:
                break
        return found

    def details(self, universe_ids: Iterable[int]) -> Dict[int, Dict[str, Any]]:
        ids = sorted(set(int(u) for u in universe_ids))
        result: Dict[int, Dict[str, Any]] = {}
        for start in range(0, len(ids), DETAILS_BATCH):
            batch = ids[start : start + DETAILS_BATCH]
            payload = self.get_json(f"{GAMES_URL}?universeIds={','.join(map(str, batch))}")
            for item in payload.get("data") or []:
                if "id" in item:
                    result[int(item["id"])] = item
        return result
