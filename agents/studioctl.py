#!/usr/bin/env python3
"""Studio control for the Bloxtomation agent team. Run with --help.

Examples:
  python3 agents/studioctl.py init --studios 1
  python3 agents/studioctl.py game new crystal-tap --title "Crystal Tap" --from-template
  python3 agents/studioctl.py task add --game crystal-tap --title "Write the pitch" --owner scout --brief brief.md
  python3 agents/studioctl.py task next --owner scout
  python3 agents/studioctl.py board
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from studio.cli import main  # noqa: E402

if __name__ == "__main__":
    sys.exit(main())
