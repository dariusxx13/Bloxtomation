# Reel the Storm (id `stormcatch`): human decisions

This file records decisions the human made in chat, in their words, so agents can follow them. The Director writes it; agents never decide these items. Formal checkpoints (pitch, prototype, release) are still recorded by the human with `python3 agents/studioctl.py human ...`.

## 2026-10-24: answers to the pitch-stage questions

The human's reply in chat: "Aprove , Yeah they do, Reel the Storm is better and no search. Whatever the designer recommends."

| # | Question (asked by) | Decision | What it means for the work |
|---|---|---|---|
| D1 | Approve or reject the pitch (Director) | **Intends to approve** | The pitch gate (T-0004) still runs on evidence. When it passes, the human records the approval with `python3 agents/studioctl.py human approve stormcatch`. Agents do not run that command. |
| D2 | Do companion nests count as paid random items if coins can be bought with Robux? (Designer, loop sketch section 12) | **Yes** | Answer "paid random items: yes" on the maturity and compliance questionnaire. Nests show their odds and respect `ArePaidRandomItemsRestricted` (the template's `Services/Policy.luau` already does both). The Monetization Designer treats nests as paid random items in the catalog and compliance work. |
| D3 | Store title, and whether to run a trademark search (Scout, Designer) | **"Reel the Storm". No trademark search.** | Use "Reel the Storm" in docs, store page and thumbnails. The game id stays `stormcatch`. The human accepts the risk of not searching. |
| D4 | Should weather ever be summoned or sold, for coins or Robux, after launch? (Designer) | **Superseded by D6 the same day.** First answer: "Follow the designer: no". | See D6. |
| D5 | Maturity questionnaire answers (Designer, Scout) | **Follow the designer: expect Minimal** | Design keeps to the loop sketch's section 8 (no violence or fear, storms never hazards). The human fills in the questionnaire in Creator Hub before release (RC-03), answering paid random items per D2. |

How the Director read "Whatever the designer recommends": as covering D4 and D5, the two items whose recommendation came from the designer. The human can correct this here at any time.

## 2026-10-24: weather summoning (replaces D4)

The human's follow-up in chat: "Wait, summoning weather shall be at a robux cost."

| # | Decision | What it means for the work |
|---|---|---|
| D6 | **Players can summon weather for Robux.** | Design stage: the Designer reworks loop sketch sections 3, 4.3 and 12, and the Monetization Designer adds the product to the catalog. Design constraints so the twist still holds: (1) a summoned front appears on the Sky Dial for everyone in the server, so the forecast stays true in that server; (2) its benefit is shared with every player there (a social purchase, as in the grow-and-farm playbook), never only the buyer; (3) it never moves or replaces the Great Storm schedule, which stays the same in every server; (4) duration, price and effects are designed, not guessed, and the purchase is granted only in `ProcessReceipt`. |
| D6 open item | How a paid, server-wide luck or odds change is disclosed, and whether it changes the questionnaire answers. | A policy question for the human. The Monetization Designer drafts it at the design stage and escalates it with `--kind policy`; agents do not answer it. |

The parked co-op Sky Bell (summoning a front for free, together) is a design option the Designer may combine with D6 or drop.

Related: [Pitch](pitch.md) · [Loop sketch](loop-sketch.md) · [Market scan](market-scan.md)
