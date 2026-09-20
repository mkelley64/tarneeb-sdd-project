# Full-match AI evaluation

September 19, 2026. **Advanced and Expert both clearly beat Standard, but Expert did not demonstrate stronger full-match performance than Advanced.** No production policies were changed or tuned.

## Primary result

Each pairing played 2,048 complete matches, using 256 fresh independent deal sequences (200000–200255), four hand/seat/dealer rotations and swapped partnerships. Both bidding and card play used each partnership's assigned production level. Matches started at zero, passed the running score to both policies, and ended at the app's actual first-to-31 boundary.

| Candidate versus reference | Candidate wins | Win rate | Adjusted confidence interval |
|---|---:|---:|---:|
| Advanced versus Standard | 1,578 / 2,048 | 77.05% | 73.58%–80.52% |
| Expert versus Standard | 1,570 / 2,048 | 76.66% | 73.78%–79.54% |
| Expert versus Advanced | 1,024 / 2,048 | 50.00% | 47.52%–52.48% |

Intervals are stream-clustered, two-sided **98.3333%**, Bonferroni-adjusted across the three predeclared comparisons. Rotations and hands are not treated as independent samples. The first two intervals exceed 50%; the third includes it. All matches finished: zero unresolved outcomes and zero ties. The exact 1,024–1,024 split is an observed match result, **not proof that the policies are equivalent**; small differences remain plausible.

The slightly different win rates against Standard do not establish Advanced versus Expert ordering. Their direct comparison is the relevant test.

## Match and scoring details

Identical deal-attempt sequences were reused across seat/partnership arrangements and comparisons. All-pass auctions consumed a deal and advanced the dealer without scoring; they were not replaced or discarded. Auctions and match lengths could differ between policies. Maximum permitted length was 256 deal attempts; the longest observed match used 22.

| Pairing | Played hands | All-pass deals | Mean played hands per match | Final score margin, nominal 95% interval |
|---|---:|---:|---:|---:|
| Advanced − Standard | 14,848 | 1,312 | 7.250 | +21.165 [19.127, 23.203] |
| Expert − Standard | 14,482 | 1,936 | 7.071 | +20.441 [18.813, 22.069] |
| Expert − Advanced | 12,800 | 1,903 | 6.250 | +0.503 [−0.546, 1.553] |

Final candidate-minus-reference score margins are secondary descriptive endpoints affected by match stopping and overshoot. Their nominal intervals are not the family-adjusted primary test. The Expert–Advanced score interval also includes zero.

| Pairing | Candidate contracts made | Reference contracts made | Candidate defenses successful | Reference defenses successful |
|---|---:|---:|---:|---:|
| Advanced − Standard | 5,372 / 6,744 (79.66%) | 4,418 / 8,104 (54.52%) | 3,686 / 8,104 (45.48%) | 1,372 / 6,744 (20.34%) |
| Expert − Standard | 4,657 / 5,350 (87.05%) | 5,292 / 9,132 (57.95%) | 3,840 / 9,132 (42.05%) | 693 / 5,350 (12.95%) |
| Expert − Advanced | 4,577 / 5,276 (86.75%) | 5,951 / 7,524 (79.09%) | 1,573 / 7,524 (20.91%) | 699 / 5,276 (13.25%) |

Contract percentages reflect different bidding choices and opportunities, not controlled like-for-like contracts. In the direct higher-level comparison, Expert took fewer contracts and made a greater fraction, but this did not yield more match wins. That observation does not establish a causal explanation.

## Performance and safety

Across **6,144 matches**, the runner completed **42,130 played hands**, **5,151 all-pass deals**, **2,190,760 card decisions** and **198,428 bidding decisions**. All played hands conserved their 52 cards and emptied all hands. Card legality, action progress, bounded auctions, actual scoring and match termination checks passed. Standard recommendations still pass through the unchanged acceptance service, which may turn a too-low recommendation into Pass. There were **zero bidding or card-search fallbacks** across all levels and comparisons.

Latency below is median / p95 / maximum, in milliseconds, on an optimized arm64 development-Mac build. Bidding includes baseline/request construction; card calls include observable-context seed derivation. UI delays and animations are not included.

| Pairing and policy | Bidding latency | Card latency |
|---|---:|---:|
| Advanced–Standard: Advanced | 0.0166 / 0.0253 / 0.1855 | 0.0083 / 0.0107 / 0.1399 |
| Advanced–Standard: Standard | 0.0090 / 0.0114 / 0.1640 | 0.0049 / 0.0062 / 0.3210 |
| Expert–Standard: Expert | 0.0187 / 9.6883 / 23.2505 | 2.7876 / 16.7015 / 45.1154 |
| Expert–Standard: Standard | 0.0100 / 0.0177 / 0.1648 | 0.0056 / 0.0073 / 0.3175 |
| Expert–Advanced: Expert | 0.0180 / 9.7958 / 19.7615 | 2.7211 / 16.2300 / 39.6027 |
| Expert–Advanced: Advanced | 0.0178 / 0.0281 / 0.1585 | 0.0086 / 0.0105 / 0.0998 |

Expert bidding often has no candidate requiring search, explaining its low median and much higher p95. Production limits remained **eight samples / thirteen-trick rollouts / 150 ms for cards**, and **sixteen samples / 200 ms for bids**. Deadline enforcement is cooperative, not a hard real-time guarantee. These are not physical-iPhone or UI frame-pacing measurements.

## Verification and unchanged behavior

The native regression suite passed before the held-out run: 6,656 Standard card comparisons, 572 legal/inference/fairness positions, settings/freezing/migration/restore/stale-result checks, contract and match-score sensitivity, 48 full-hand combinations / 2,496 conserved plays, 7,168 frozen bidding recommendations, 542 auction positions, 1,560 public-threat parity positions, 223 Expert card and 131 Expert bid compatibility checks.

New diagnostic harness checks passed on separate streams 120000–120003: deterministic Standard full-match replay, immediate termination of an already-won match, all-pass dealer advancement without scoring, explicit unresolved cap handling, forced Expert fallback, nonzero score propagation and order-invariant public search seeds. These were verification, not tuning or strength evidence.

After evaluation, independent checks reproduced the published win proportions and adjusted confidence intervals directly from per-match records, and verified stream/arrangement uniqueness, decision counts, scoring totals and contract accounting. Production, harness and protocol hashes remained identical to their pre-run values. `git diff --check` passed. No simulator suite was rerun: this turn changed offline tooling and documentation only. No commit was made; earlier uncommitted work was preserved.

## Reproduction and artifacts

From `/Users/markkelley/tarneeb-sdd-project`, run sequentially against the frozen source snapshot:

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh full-match advanced standard > /tmp/full-match-advanced-standard.json
sh tools/ai/run.sh full-match expert standard > /tmp/full-match-expert-standard.json
sh tools/ai/run.sh full-match expert advanced > /tmp/full-match-expert-advanced.json
```

Each command fixes the 256-stream range and production budgets. Search seeds derive only from observable information, including running score—not shuffle seeds, hidden hands or private preferred suits. Runtime randomness remains independent in the app. Machine load can change latency and deadline outcomes on replay.

- [Frozen protocol](full-match-evaluation.md) and [pre-run audit](full-match-evaluation-audit.json).
- Complete per-match records, cluster scores, counts and timings: [Advanced–Standard](full-match-advanced-standard.json), [Expert–Standard](full-match-expert-standard.json), [Expert–Advanced](full-match-expert-advanced.json).

Result SHA-256 hashes, respectively: `cddcfbf5008bafb932ea98362d38a63716fe7d184bfaed55cc21748e6ea30e61`, `22ef491c873aa2bbbe1cdf16279aa9c8186ae330c5a8ec2eeee0740a52bd1a3f`, `1c89c598329cc45acb5b0899d959278275f15aa273ff6177bf62ab906f06164d`.

Changed files this turn: new `tools/ai/FullMatchBenchmark.swift`; command/build wiring in `tools/ai/main.swift` and `run.sh`; the `specs/011-mvp/full-match-*` protocol, audit and result artifacts; evidence updates in `ai-skill.md`, `ai-bidding.md` and `tasks.md`. No app files, policies, settings, timing tokens or saved-state formats changed.

## Interpretation and next work

The earlier fixed-bidding benchmark demonstrated Expert's card-play advantage over revised Advanced. This full-match benchmark does **not** demonstrate an overall advantage once bidding and running match scores are included. It also does not prove which component explains the difference between those findings.

The next useful strength experiment is a controlled full-match component comparison: switch bidding and card-play levels independently against a fixed reference, using fresh streams and a predeclared protocol. That can test whether bidding, score-sensitive play, or their interaction explains the missing advantage. Do not tune or extend this sample to obtain a favorable result. The current streams are now observed evaluation data.

This tests two homogeneous AI partnerships, not the app's one human plus three equal-level simulated seats; it does not predict human win rates. Physical-iPhone profiling remains outstanding. The three-level product should not yet be described as a proven strict progression in full-match strength.
