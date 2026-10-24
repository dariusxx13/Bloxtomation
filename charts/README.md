# Chart tracker

Snapshots of the Roblox discovery sorts (the Charts page: Top Trending, Up-and-Coming, Top Playing Now, Top Earning, Top Revisited, Fun with Friends, Top Rated, the genre trending sorts and more), turned into market evidence: breakouts, risers, new entries, rank movers, genre shares and trend phases, plus per-game histories and pitch-ready evidence blocks with dates and sources. Python 3.9+, standard library only.

It implements the method in the vault's [Reading the charts](../vault/15-market-research/reading-the-charts.md) and feeds the Scout agent and the PITCH gate (PITCH-01: every market claim cites a dated snapshot no older than 7 days).

## Commands

```bash
python3 charts/charts.py snapshot                      # one snapshot: ~5 sort pages + ~18 detail batches, 1 s apart (~30 s)
python3 charts/charts.py status                        # what is stored
python3 charts/charts.py report --days 7               # writes <data>/reports/<date>-computer-all.md and prints the top
python3 charts/charts.py genres --days 7               # genre shares, growth of daily peaks, phase heuristic
python3 charts/charts.py game "Some Game"              # one game's history (name or universe id)
python3 charts/charts.py evidence --genre Simulation --game "Comparable A" --game 1234567   # block for a pitch
python3 charts/charts.py export --days 7 --out placements.csv
python3 charts/charts.py compact --keep-days 14        # older snapshots become one per day (peaks, best ranks)
```

Options shared by the analysis commands: `--device` (`computer`, `high_end_phone`, `low_end_phone`, `high_end_tablet`, `low_end_tablet`, `console`, `vr`), `--country` (`all` or a code such as `us`), `--days`, `--min-players` (threshold for "big" games, default 1,000). Analyses only compare snapshots taken with the same device and country.

## What the report contains

| Section | Signal |
|---|---|
| Breakouts (24h) | Games above the threshold with +25% concurrent players versus the snapshot nearest the same time yesterday |
| Risers over the window | Growth of daily peaks (last 24 h peak versus first 24 h peak), robust to time-of-day swings |
| New on the charts | Games first seen in the last 24 h and still charting |
| Breakout candidates | The vault's definition: created in the last 60 days or under 1M lifetime visits, threshold players, rising |
| Rank movers | Organic rank climbs and new entries in Top Trending, Up-and-Coming and Top Earning versus 24 h ago |
| Genres | Players, share, games charting, big games, growth of daily peaks, risers, phase heuristic (early, rising, stable or saturated, churning, declining) |

Each game row carries players, visits per day, like ratio, age, days since its last update and its current organic ranks. Sponsored placements are removed before ranking, so ads never look like momentum.

## Data

- One gzipped JSON file per snapshot: `<data>/snapshots/YYYY/MM/DD/<UTC stamp>-<device>-<country>.json.gz` (about 110 KB). It keeps ids, names, genres, counts, votes, ranks, sponsored flags and dates; it stores no descriptions, images or other creative content.
- `compact` merges every day older than `--keep-days` into one snapshot per day (peak players, best rank per sort, last visits), in the same format, so long histories stay small and every command still works.
- Data location: `$CHARTS_DATA_DIR`, else a `.chart-data/` worktree of the `chart-data` branch if present, else `charts/data/` (git-ignored).

## Collect automatically

[`.github/workflows/charts-snapshot.yml`](../.github/workflows/charts-snapshot.yml) takes a snapshot every 3 hours, compacts data older than 14 days, writes the 7-day report, and force-pushes everything as a single commit to the `chart-data` branch (so the branch never accumulates history). It runs once the workflow file is on the default branch; trigger it by hand from the Actions tab at any time. GitHub pauses scheduled workflows after 60 days without repository activity.

Use that data locally or in an agent session:

```bash
git fetch origin chart-data
git worktree add --detach .chart-data origin/chart-data     # charts.py picks it up automatically
git -C .chart-data fetch origin chart-data && git -C .chart-data checkout --detach origin/chart-data   # refresh later
```

## Being a good citizen

The endpoints are the public, unauthenticated ones the Roblox website itself uses for its Charts page. They are unofficial and undocumented and can change or be rate-limited at any time. The tracker:

- sends a descriptive User-Agent, spaces requests at least 0.5 s apart (1 s by default), retries 429 and 5xx with exponential backoff and honours `Retry-After`;
- refuses to snapshot more often than `--min-interval` minutes (60 by default; the scheduled workflow uses 120);
- never logs in, never plays games, never generates traffic to them.

If the endpoint shape changes, `snapshot` saves nothing and says so; the analysis code tolerates missing fields.

## Tests

```bash
python3 -m unittest discover -s charts/tests   # offline: synthetic snapshots and a mocked HTTP client
```
