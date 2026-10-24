#!/usr/bin/env python3
"""Roblox chart tracker. Run with --help.

  python3 charts/charts.py snapshot                 # collect a snapshot (polite, ~25 requests)
  python3 charts/charts.py report --days 7          # breakouts, risers, new entries, rank movers, genres
  python3 charts/charts.py game "<name or universe id>"
  python3 charts/charts.py evidence --genre Simulation --game "<comparable>"
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from chartlib.cli import main  # noqa: E402

if __name__ == "__main__":
    sys.exit(main())
