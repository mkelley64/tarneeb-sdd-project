# Hybrid confirmation results

September 19, 2026. **Advanced bidding + current Expert card play beat Standard and current Expert, but did not demonstrate superiority over Advanced under the predeclared adjusted test. The all-three confirmation gate was not met. No production policy changed.**

## Primary outcome

The fixed hybrid faced each current reference on fresh streams **400000–400255**, with four seat/dealer rotations and swapped candidate partnerships: **2,048 full first-to-31 matches per comparison, 6,144 total**. The earlier component experiment selected this candidate; none of its streams were included here. Policies, sample sizes, budgets and the success rule were frozen before execution in [the protocol](hybrid-confirmation-protocol.md) and [source audit](hybrid-confirmation-audit.json).

Intervals use 256 independent stream clusters, not 2,048 independent matches. They are two-sided **98.3333%**, Bonferroni-adjusted across the three comparisons. Shared streams across references are correlated; their results are not pooled as independent evidence.

| Reference | Hybrid wins / 2,048 | Hybrid match-win rate | Adjusted interval | Finding |
|---|---:|---:|---:|---|
| Standard | 1,576 | 76.95% | [74.23%, 79.68%] | Superiority demonstrated |
| Advanced | 1,062 | 51.86% | [49.80%, 53.91%] | Inconclusive |
| Current Expert | 1,115 | 54.44% | [52.27%, 56.62%] | Superiority demonstrated |

All matches finished, with no legality, conservation or state-progression failures. Full confirmation nevertheless required **all three lower bounds above 50%**. The Advanced comparison misses that condition. Its positive point estimate is not proof of superiority, and its interval is not proof of equivalence or inferiority. No unadjusted interval, favorable score metric, prior experiment or replacement run is used to rescue the failed gate.

Against current Expert, both sides use the same Expert card policy; their bidding differs. This independently supports the hybrid's practical benefit over the existing coupled Expert in these matches, but does not identify the faulty internal assumption in the Expert bidder or establish the desired complete Standard < Advanced < Expert progression.

## Match and contract outcomes

Actual first-to-31 scoring, score-aware decisions, dealer advancement after every deal attempt, and all-pass redeals were retained. Different auctions and match lengths are legitimate effects. The longest match used 25 of the allowed 256 attempts.

| Reference | Played hands | All-pass deals (% of attempts) | Mean hands/match | Final hybrid-minus-reference score margin, nominal 95% interval |
|---|---:|---:|---:|---:|
| Standard | 14,832 | 1,154 (7.22%) | 7.242 | +19.979 [+18.411, +21.547] |
| Advanced | 12,997 | 1,141 (8.07%) | 6.346 | +1.472 [+0.622, +2.322] |
| Current Expert | 12,642 | 1,672 (11.68%) | 6.173 | +1.860 [+0.996, +2.724] |

These score intervals are descriptive, nominal 95%, and affected by match stopping and score overshoot. They are not the promotion endpoint.

| Reference | Hybrid contracts made | Reference contracts made | Hybrid defenses won | Reference defenses won |
|---|---:|---:|---:|---:|
| Standard | 5,438 / 6,756 | 4,564 / 8,076 | 3,512 / 8,076 | 1,318 / 6,756 |
| Advanced | 5,305 / 6,527 | 5,133 / 6,470 | 1,337 / 6,470 | 1,222 / 6,527 |
| Current Expert | 6,084 / 7,456 | 4,490 / 5,186 | 696 / 5,186 | 1,372 / 7,456 |

Contract percentages are conditional on the contracts each policy chooses. The current Expert reference made a higher proportion of fewer contracts than the hybrid; that does not imply higher overall match strength or prove that conservatism alone explains its result.

## Performance, fallbacks and an unresolved latency outlier

The complete evaluation included **40,471 played hands, 3,967 all-pass deals, 2,104,492 card decisions and 189,890 bidding decisions**. Every played hand conserved all 52 cards and completed through the existing validation/scoring paths.

Decision times below are milliseconds, **median / p95 / maximum**, from sequential optimized native development-Mac runs. Timing includes public seed derivation and, for bidding, request/baseline construction; it excludes UI pacing.

| Comparison side | Bidding ms | Card play ms | Card fallbacks / decisions |
|---|---:|---:|---:|
| Hybrid vs Standard | 0.0183 / 0.0331 / 0.1023 | 2.818 / 17.394 / 41.837 | 0 / 385,632 |
| Standard reference | 0.0098 / 0.0181 / 0.1350 | 0.0056 / 0.0075 / 0.1631 | 0 / 385,632 |
| Hybrid vs Advanced | 0.0191 / 0.0362 / 0.1444 | 2.876 / 18.052 / **25,430.299** | **4 / 337,922 (0.00118%)** |
| Advanced reference | 0.0191 / 0.0361 / 0.2403 | 0.0095 / 0.0132 / 2.0898 | 0 / 337,922 |
| Hybrid vs current Expert | 0.0196 / 0.0347 / 0.1080 | 2.803 / 19.083 / 48.203 | 0 / 328,692 |
| Current Expert reference | 0.0190 / 9.9519 / 21.4430 | 2.773 / 17.977 / 52.913 | 0 / 328,692 |

There were **four card fallbacks total and zero bidding fallbacks**. All fallback outcomes were retained, remained legal, and finished their matches; no unfavorable run was discarded. The raw reports contain all decision denominators.

The **25.43-second elapsed-time maximum is a serious unresolved outlier**, despite typical card p95 times below 20 ms. The aggregate timing data do not establish whether CPU work, scheduling/suspension or another host interruption caused it, nor associate individual timings with fallback reasons. Do not attribute it to a confirmed cause or claim a hard 150 ms response guarantee. Follow-up profiling must capture per-decision wall/CPU time, cancellation/deadline checkpoints and fallback reasons, then verify responsiveness on a physical iPhone. This is not a measured UI-thread stall: the offline harness calls policies synchronously, while the app uses detached work.

Frozen limits remain **8 samples / 13-trick rollouts / 150 ms cooperative budget for cards**, and **16 samples / 200 ms for the current Expert reference's bidding**. Hybrid Advanced bidding is deterministic and does not sample. The sampler retains its 4,096-node cap. Cooperative checks cannot bound time while the process is not scheduled. Limits and production code were not changed in response to this result.

## Verification and changed files

Before held-out execution, the native suite passed: 6,656 Standard card comparisons; 7,168 frozen bid recommendations; 542 auction positions; 572 legal-play/constrained-sample checks; all 48 skill/declarer/trump combinations and 2,496 conserved plays; contract/score sensitivity; inference, hidden-information fairness and deterministic seeds; settings persistence/freezing/migration/restore; cancellation, fallback and stale-result protection; preserved Expert rollout compatibility; full-match boundaries/dealer/all-pass/cap checks; and independent component routing/factorial checks.

The separate Ruby auditor reconstructed win and score intervals from raw match records, checked all 256 streams and eight unique arrangements per stream, terminal score thresholds, dealer progression, 52-card decision accounting, contract/defense totals, metadata and limits. All checks passed. Production, evaluated harness and frozen protocol hashes match the pre-run audit. `git diff --check` passed.

Changed files for this step: `tools/ai/main.swift` (fixed hybrid-confirmation dispatch), `tools/ai/verify-hybrid.rb` (independent result audit), `specs/011-mvp/hybrid-confirmation-*` (protocol, audits, raw results and this report), plus evidence/task updates in `ai-skill.md`, `ai-bidding.md` and `tasks.md`. No app source, preferences, saves, rules, UI, design tokens or audio/animation timing changed. No simulator suite was rerun for this offline-only change. No commit was made; prior uncommitted work was preserved.

## Reproduction and raw evidence

From `/Users/markkelley/tarneeb-sdd-project`, run sequentially against the audited source:

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh hybrid-confirmation standard > /tmp/hybrid-standard.json
sh tools/ai/run.sh hybrid-confirmation advanced > /tmp/hybrid-advanced.json
sh tools/ai/run.sh hybrid-confirmation expert > /tmp/hybrid-expert.json
ruby tools/ai/verify-hybrid.rb /tmp/hybrid-standard.json /tmp/hybrid-advanced.json /tmp/hybrid-expert.json
```

The commands fix streams 400000–400255 and 2,048 matches per reference. Search seeds use only observable context; the app's independent runtime randomness is unchanged. Timings and deadline-triggered fallback outcomes can vary with machine load, so replay need not be bit-identical when a deadline intervenes.

- Raw reports: [Standard](hybrid-confirmation-standard.json), [Advanced](hybrid-confirmation-advanced.json), [current Expert](hybrid-confirmation-expert.json).
- [Completed audit and result hashes](hybrid-confirmation-results-audit.json).
- [Selection experiment](match-components-results.md), which is separate evidence, not part of these confirmation intervals.

## Decision and next work

**Do not promote the hybrid under the frozen all-three rule.** Keep the demonstrated gains over Standard/current Expert and the inconclusive Advanced comparison distinct. No claim is made about human partners, all opponent types or physical-phone performance.

First investigate the long latency tail using diagnostic instrumentation and device profiling, without changing this experiment's recorded results. If pursuing the unchanged hybrid afterward, predeclare a new adequately powered fresh-stream comparison for the small possible advantage over Advanced, including the minimum practically useful effect, sample size and error-control rule. Do not extend this sample after seeing the result, relax the threshold or tune on these streams while calling them held-out. Alternatively, diagnose and improve specific bidding/card heuristics on separate training deals before another untouched evaluation. This result leaves both the strict three-level strength progression and physical-device responsiveness unresolved.
