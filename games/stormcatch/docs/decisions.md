# Reel the Storm (id `stormcatch`): human decisions

This file records decisions the human made in chat, in their words, so agents can follow them. The Director writes it; agents never decide these items. Formal checkpoints (pitch, prototype, release) are still recorded by the human with `python3 agents/studioctl.py human ...`.

## 2026-10-24: answers to the pitch-stage questions

The human's reply in chat: "Aprove , Yeah they do, Reel the Storm is better and no search. Whatever the designer recommends."

| # | Question (asked by) | Decision | What it means for the work |
|---|---|---|---|
| D1 | Approve or reject the pitch (Director) | **Intends to approve** | The pitch gate (T-0004) still runs on evidence. When it passes, the human records the approval with `python3 agents/studioctl.py human approve stormcatch`. Agents do not run that command. |
| D2 | Do companion nests count as paid random items if coins can be bought with Robux? (Designer, loop sketch section 12) | **Yes** | Answer "paid random items: yes" on the maturity and compliance questionnaire. Nests show their odds and respect `ArePaidRandomItemsRestricted` (the template's `Services/Policy.luau` already does both). The Monetization Designer treats nests as paid random items in the catalog and compliance work. |
| D3 | Store title, and whether to run a trademark search (Scout, Designer) | **"Reel the Storm". No trademark search.** | Use "Reel the Storm" in docs, store page and thumbnails. The game id stays `stormcatch`. The human accepts the risk of not searching. |
| D4 | Should weather ever be summoned or sold, for coins or Robux, after launch? (Designer) | **Follow the designer: no** | Weather is never sold or summoned. The forecast stays true for everyone. The co-op Sky Bell stays parked unless the human reopens it. |
| D5 | Maturity questionnaire answers (Designer, Scout) | **Follow the designer: expect Minimal** | Design keeps to the loop sketch's section 8 (no violence or fear, storms never hazards). The human fills in the questionnaire in Creator Hub before release (RC-03), answering paid random items per D2. |

How the Director read "Whatever the designer recommends": as covering D4 and D5, the two items whose recommendation came from the designer. The human can correct this here at any time.

Related: [Pitch](pitch.md) · [Loop sketch](loop-sketch.md) · [Market scan](market-scan.md)
