# What limits Expert: full-match component results

September 19, 2026. **Expert bidding hurts performance relative to Advanced bidding, while Expert card play helps**, averaged over the other component against the fixed Advanced reference. Their opposing effects explain the lack of a demonstrated overall Expert advantage in this experiment. The test identifies the limiting component, not the particular assumption inside the bidder responsible for it. No production policy changed.

## Predeclared primary results

Four candidate combinations faced Advanced bidding + Advanced card play. All used the same 256 fresh deal streams, eight balanced matches per stream: **2,048 matches per combination, 8,192 total**. Bidding is the first letter below; A means Advanced and E means Expert.

Effects were computed within each matched stream, then averaged. Intervals are two-sided **98.3333%**, Bonferroni-adjusted across three primary endpoints, using 256 independent stream clusters. Units are **percentage points of match win rate**, not relative percentages.

| Component effect | Mean | Adjusted interval | Finding |
|---|---:|---:|---|
| Switch to Expert bidding, averaged across card levels | −3.66 pp | [−5.81, −1.52] | Harm detected |
| Switch to Expert card play, averaged across bidding levels | +2.59 pp | [+0.59, +4.58] | Benefit detected |
| Bidding × card-play interaction | −0.88 pp | [−3.90, +2.15] | Inconclusive |

The bidding and card-play intervals exclude zero. The interaction interval does not: this is **not proof of zero interaction or exact additivity**. The means approximately offset; combined Expert still has no demonstrated full-match advantage over the control.

## Observed combinations

| Code | Candidate bidding | Candidate cards | Wins / 2,048 | Win rate |
|---|---|---|---:|---:|
| AA | Advanced | Advanced | 1,024 | 50.00% |
| EA | Expert | Advanced | 958 | 46.78% |
| AE | Advanced | Expert | 1,086 | 53.03% |
| EE | Expert | Expert | 1,002 | 48.93% |

AA's exact 50–50 split is an intentional control: identical policies play both sides and the candidate label is swapped. It is not an empirical claim about human win rates. There were no unresolved matches or ties in any cell.

Secondary paired contrasts below have **nominal 95% intervals**, not family-adjusted promotion tests:

| Contrast | Effect | Interval |
|---|---:|---:|
| Expert bidding with Advanced cards: EA − AA | −3.22 pp | [−5.53, −0.92] |
| Expert bidding with Expert cards: EE − AE | −4.10 pp | [−6.08, −2.12] |
| Expert cards with Advanced bidding: AE − AA | +3.03 pp | [+1.31, +4.75] |
| Expert cards with Expert bidding: EE − EA | +2.15 pp | [−0.19, +4.48] |
| Combined Expert versus control: EE − AA | −1.07 pp | [−3.04, +0.90] |

Thus the combined Expert result is still inconclusive versus Advanced; do not call Expert overall worse from its 48.93% point estimate. The mixed **Advanced bidding + Expert play** combination is a promising candidate for independent validation, not a silently promoted production change.

## Match and contract outcomes

Actual first-to-31 scoring, running match-score context, dealer progression and all-pass redeals were preserved. Streams were indexed by deal attempts rather than scored hands. Different bidding choices were allowed to change auctions, redeals and match lengths. All matches finished below the 256-attempt cap; the longest used 19 attempts.

| Cell | Played hands | All-pass deals | Mean played hands/match | Final score margin, nominal 95% interval |
|---|---:|---:|---:|---:|
| AA | 13,352 | 1,400 | 6.520 | 0.000 [0.000, 0.000] |
| EA | 13,054 | 1,897 | 6.374 | −0.823 [−1.894, +0.248] |
| AE | 13,112 | 1,315 | 6.402 | +1.667 [+0.760, +2.575] |
| EE | 12,851 | 1,866 | 6.275 | +0.388 [−0.667, +1.443] |

Final candidate-minus-reference score margin is descriptive and affected by stopping/overshoot; match win rate is the primary outcome.

| Cell | Candidate contracts made | Reference contracts made | Candidate contracts defeated | Reference contracts defeated |
|---|---:|---:|---:|---:|
| AA | 5,268 / 6,676 | 5,268 / 6,676 | 1,408 / 6,676 | 1,408 / 6,676 |
| EA | 4,537 / 5,359 | 6,078 / 7,695 | 1,617 / 7,695 | 822 / 5,359 |
| AE | 5,306 / 6,567 | 5,145 / 6,545 | 1,400 / 6,545 | 1,261 / 6,567 |
| EE | 4,538 / 5,274 | 5,946 / 7,577 | 1,631 / 7,577 | 736 / 5,274 |

Expert bidding produced fewer declaring opportunities and higher conditional make rates. Those facts do **not** prove that conservatism alone causes its lower win rate. The bidding component also includes suit selection, sampled outcomes and modeled auction continuation; this experiment does not distinguish those mechanisms.

## Performance and correctness

All **52,369 played hands** conserved 52 cards and terminated through the existing legal-play/scoring paths. There were **6,478 all-pass deals, 2,723,188 card decisions and 251,278 bidding decisions**, with **zero fallbacks, illegal card plays, conservation failures or unresolved matches**.

Candidate decision latency in milliseconds, shown as median / p95 / maximum:

| Cell | Bidding | Card play |
|---|---:|---:|
| AA | 0.0165 / 0.0248 / 0.1115 | 0.0081 / 0.0103 / 0.1457 |
| EA | 0.0174 / 10.0015 / 20.0395 | 0.0083 / 0.0104 / 0.0853 |
| AE | 0.0180 / 0.0328 / 0.0976 | 2.7773 / 17.3473 / 48.5965 |
| EE | 0.0188 / 9.9048 / 19.8706 | 2.7775 / 16.5717 / 48.6961 |

Reference Advanced p95 latency ranged from 0.0248–0.0328 ms for bidding and 0.0102–0.0117 ms for cards; maximums were 0.2771 and 3.3000 ms respectively. All reference and candidate timings/decision denominators are in the raw reports. Low Expert bidding medians reflect many decisions with no candidate requiring simulation.

These are optimized arm64 development-Mac measurements, not physical-iPhone or UI frame-time claims. Production Expert limits remain eight samples / thirteen-trick rollouts / 150 ms for cards and sixteen samples / 200 ms for bids; deadlines are cooperative. Timing includes request/baseline construction for bids and public seed derivation, but excludes UI pacing.

## Verification and audit

Existing native regressions passed before execution, including Standard parity (6,656 card comparisons; 7,168 frozen bid recommendations), legality/inference/fairness, contract and score sensitivity, settings persistence/freezing/migration/restore, cancellation/fallback/stale-result checks, full-hand conservation, and preserved Expert rollout compatibility.

New checks on separate streams 130000–130001 passed: historical default routing versus explicit equivalent bidding, independent bid/card routing, unchanged reference policy, selected-component-only forced fallback, fallback equivalence to the Advanced control, and synthetic factorial main/interaction contrasts. Existing full-match boundary, all-pass/dealer/cap and observable-seed checks also passed.

After execution, the analyzer verified all cell metadata and reconstructed stream win rates from per-match records. Independent arithmetic reproduced all three primary means and intervals from those records. Counts, unique balanced arrangements, score boundaries and contract accounting passed checks. Production, harness and protocol hashes match the frozen pre-run audit. `git diff --check` passed. No simulator suite was repeated because no app files changed. No commit was made; existing uncommitted work was preserved.

Changed files this turn: `tools/ai/FullMatchBenchmark.swift` (optional offline candidate bidding override and parameterized runner, historical defaults retained), new `tools/ai/MatchComponentEvaluation.swift` (analysis and tests), `tools/ai/main.swift` and `run.sh` (command/build wiring), and the `specs/011-mvp/match-components-*`, `ai-skill.md`, `ai-bidding.md`, and `tasks.md` documentation/evidence. No settings, saves, rules, production policies, UI or timing tokens changed.

## Reproduce and inspect

From `/Users/markkelley/tarneeb-sdd-project`, run sequentially. CLI order is **bidding, then card play**:

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh match-component advanced advanced > /tmp/components-AA.json
sh tools/ai/run.sh match-component expert advanced > /tmp/components-EA.json
sh tools/ai/run.sh match-component advanced expert > /tmp/components-AE.json
sh tools/ai/run.sh match-component expert expert > /tmp/components-EE.json
sh tools/ai/run.sh match-component-analysis /tmp/components-AA.json /tmp/components-EA.json /tmp/components-AE.json /tmp/components-EE.json
```

Each cell fixes streams 300000–300255, 2,048 matches and production budgets. Search seeds use only observable information, not deal seeds or hidden holdings. The app retains independent runtime randomness; deadlines and timings can vary with machine load on replay.

- [Frozen protocol](match-components-protocol.md), [pre-run source/configuration audit](match-components-audit.json), [completed result hashes and validation summary](match-components-results-audit.json).
- Raw per-match records and metrics: [AA](match-components-AA.json), [EA](match-components-EA.json), [AE](match-components-AE.json), [EE](match-components-EE.json).
- [Complete paired effects, confidence intervals and per-stream contrasts](match-components-effects.json).

## Next decision and limits

The evidence supports prioritizing the Expert bidder rather than weakening or removing the beneficial Expert card search. A practical next candidate is **Advanced bidding + Expert card play**, followed by fresh held-out confirmation before any production promotion. Alternatively, investigate Expert bidder assumptions on new diagnostic/training deals; this experiment does not identify which internal assumption needs changing.

The effects are specific to these policies against a fixed Advanced opponent, averaged over the other component. Running score was preserved, not independently manipulated. No claim is made about all opponents, human win rates, equivalence of the complete levels, or physical-phone performance. These streams are now observed evaluation data and cannot be reused as untouched evidence after tuning.
