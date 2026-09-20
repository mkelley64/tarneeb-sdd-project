# Public-threat separation

September 17, 2026 protocol, before new results. Implement a focused revision of Advanced's following-play survival calculation; retain its lead, long-suit, entry, partner and contract heuristics. Standard, legal moves, scoring, UI, timing and saved settings must not change.

A demonstrated void in the led suit is certain public information; an outstanding trump at that seat is only possible. Apply a separate risk discount when an opponent still to act has demonstrated that void and could hold a trump that beats the projected winner. Exclude opponents known void in trump, already-acted seats, exhausted trump and trumps that cannot overtake. This rule operates independently of speculative higher-card estimates. Generic unseen higher-card risk is capped rather than allowed to dominate economical winning play; it remains an approximation, not knowledge of holdings.

Training: seeds 80000–80511, 512 deals. Compare six fixed settings: public-risk survival factors {0.25, 0.4} and maximum speculative discounts {0, 0.05, 0.1}. Retain only configurations passing tactical protection, conservation and legality checks. Select highest paired score against frozen Standard, ties preferring lower speculation then public survival 0.4 (less intervention). Freeze before held-out evaluation; do not tune using prior held-out seeds.

Held out: seeds 90000–92047, 2,048 deals. Compare selected vs Standard and selected vs frozen original Advanced using 97.5% two-sided normal intervals clustered by base deck (Bonferroni for two comparisons). Fixed Standard bidding, four seat/dealer rotations, swapped partnerships, all-pass exclusion as in previous card experiments. Publish contract results, uncertainty, latency and failures. Promote only if both lower bounds exceed zero and intended tactics/fairness pass.

Integration after selection: preserve frozen original Advanced, Expert card and Expert bidding policies for comparison. Check native regression, Expert seeded fairness/cancellation/fallback and simulator tests. Evaluate revised vs old Expert card play on 512 fresh deals (94000–94511), and revised vs old Expert bidding on 512 fresh deals (96000–96511) with fixed original Advanced card play to isolate rollout effects. These integration checks are descriptive, not additional tuning. Report any regression or uncertainty honestly; no claim of whole-match/human strength. A clearly adverse Expert change must be resolved or kept out of production rather than silently shipped.

## Implemented separation and frozen selection

`PublicCardInference.hasDemonstratedRuffRisk` checks a public led-suit void and at least one outstanding trump that could legally belong to the opponent and beat the projected winning card. Advanced calls it only for opponents still to act. Known trump voids, exhausted trump, a trump lead, and a winning trump that no unseen trump can beat remove the risk. A void does **not** establish that the opponent holds trump.

The independent public-risk score multiplier is 0.4. This is a calibrated heuristic weight, not a claim of a 40% true survival probability. Generic higher-card speculation is disabled in the selected policy. Trump leading, long suits, entry retention, extra partner-overtake cost, actual scoring utility and deterministic tie-breaking remain unchanged. Standard is untouched. The separate experimental scorer retains the six settings for reproducibility; it is not linked into the app.

All six settings passed the tactical gate. Training used 512 deals, 471 scored clusters and 3,768 rounds per setting. Score margins versus Standard were +0.831 (0.4/0), +0.820 (0.25/0), +0.823 (0.4/0.05), +0.812 (0.25/0.05), +0.700 (0.4/0.1), +0.699 (0.25/0.1). These are selection results, not independent strength evidence. The 0.4/0 selection was saved before held-out evaluation; the training artifact SHA-256 is `09f7952257e112e1e5742805729b1e3985c40a0f819e3885fd7db04432c79e97`.

## Advanced held-out evidence

Each comparison requested 2,048 fresh decks (90000–92047), excluded the same 144 all-pass decks, and scored 1,904 independent clusters, 7,616 paired orientations and 15,232 rounds. Fixed Standard auctions, rotated seats/dealers and swapped partnerships were retained. No further tuning followed evaluation.

| Comparison | Mean paired score margin | Adjusted 97.5% interval |
|---|---:|---:|
| Revised Advanced − Standard | +0.923 | [0.652, 1.195] |
| Revised Advanced − original Advanced | +0.516 | [0.275, 0.757] |

Both predeclared promotion gates pass. Versus Standard, revised Advanced made 4,662/7,616 contracts and defeated 3,488/7,616; Standard made 4,128/7,616 and defeated 2,954/7,616. Versus original Advanced, the revised policy made 4,934/7,616 and defeated 2,994/7,616; original made 4,622/7,616 and defeated 2,682/7,616. These are single-round, zero-start-score outcomes, not human or whole-match win rates.

Held-out revised-policy p95 decision latency was 0.0075–0.0077 ms and maximum 0.362 ms on the optimized arm64 development build. It has no search fallback. Physical-iPhone performance is not established by these measurements. Full paired counts, contract results, latency and per-deal scores are in `public-threat-heldout.json`.

The new implementation passed 1,560 production-versus-selected-policy parity positions on diagnostic seeds 99000–99031. The native suite also passed 6,656 frozen Standard comparisons, 572 history/inference/fairness positions, 48 full-hand skill/declarer/trump combinations (2,496 plays), cancellation/fallback/stale-result/persistence tests, and 7,168 frozen bidding recommendations plus 542 auction positions. Target and match-score sensitivity remain present.

## Reproduction

```sh
sh tools/ai/run.sh public-threat-train > /tmp/public-training.json
sh tools/ai/run.sh public-threat-heldout /tmp/public-training.json
sh tools/ai/run.sh public-threat-expert-cards
sh tools/ai/run.sh public-threat-expert-bids
sh tools/ai/run.sh
```

Use `specs/011-mvp/public-threat-training.json` for the exact frozen selection. Expert integration commands reproduce the **rejected trial substitution**, retained in offline `TrialPublicThreatExpert.swift`, against the preserved original policies; they do not benchmark the final preserved production Expert. The historical ablation/tactic tools explicitly use frozen original Advanced rather than relabeling the updated policy as historical. The observed held-out seeds must not be reused as untouched evidence after future tuning.

## Expert integration: rejected substitution, preserved production model

Substituting revised Advanced inside Expert card rollouts and root tie-breaking regressed paired score by −0.310, nominal 95% interval [−0.573, −0.047], over 512 fresh decks (473 scored clusters, 3,784 rounds). Trial/original fallback counts were 1/98,384 and 0/98,384 decisions; trial p95 latency was 18.608 ms, maximum 151.304 ms. This change was **not shipped**. The bidding substitution was inconclusive: −0.116 [−0.256, 0.024], 512 decks / 4,096 rounds, with zero fallbacks. Raw rejected results are `public-threat-rejected-expert-cards.json` and `public-threat-rejected-expert-bids.json`.

Production `ExpertRolloutCardPolicy` preserves the original scorer for Expert card rollouts, root tie-breaking and bidding rollouts. Expert's budget/sampling fallback still uses live revised Advanced. Native checks establish exact old-scorer parity on 1,560 positions, completed-search compatibility on 223 reproducibly seeded Expert card decisions and 131 Expert bidding decisions. These are compatibility checks, not a new strength estimate. Expert limits remain eight samples / thirteen-trick depth / 150 ms for card play and sixteen samples / 200 ms for bidding. No new claim that Expert beats the revised Advanced is established by this revision.

## Final verification

`sh tools/ai/run.sh` passed after the final offline reproduction files were added. Simulator verification on iPhone 17 Pro / iOS 26.5 passed all 188 unit tests plus the real Expert bidding/play UI test on the final production code (`/tmp/tarneeb-public-threat-expert-preserved.xcresult`). The broader run passed all 28 UI tests; its result-bundle finalization stalled, so its text log, not an incomplete xcresult, is the evidence (`/tmp/tarneeb-public-threat-simulator.log`). That broader run exposed one incorrect newly added test fixture, corrected before the final 188-test pass. Thus the 188 unit and 28 UI passes are across runs, not one aggregate successful invocation. No physical-device profile or whole-match strength evaluation was performed.
