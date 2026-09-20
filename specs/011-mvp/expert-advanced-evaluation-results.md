# Expert versus revised Advanced: held-out result

September 18, 2026. **Current Expert demonstrated stronger card play than revised Advanced** under the frozen, fixed-bidding protocol. No production policy was changed or tuned.

## Primary result

Expert's mean paired partnership score advantage was **+0.441 points**, with a deck-clustered **95% confidence interval [0.299, 0.583]**. The entire interval is positive, meeting the predeclared superiority criterion. This is a score-differential endpoint, not a percentage improvement or a whole-match win rate.

The evaluation used all 2,048 fresh base-deal seeds **100000–102047**. Fixed Standard auctions excluded 134 all-pass decks (536 orientations), leaving **1,914 independent deck clusters, 7,656 paired orientations and 15,312 played rounds**. Four hand/seat/dealer rotations and swapped partnerships used the identical bidding conditions. Paired Expert wins/ties/losses were **2,851 / 2,391 / 2,414**. The 1,914 decks—not the 15,312 rounds or individual decisions—are the uncertainty units.

| Metric | Expert | Revised Advanced |
|---|---:|---:|
| Contracts made | 4,906 / 7,656 (64.08%) | 4,624 / 7,656 (60.40%) |
| Opposing contracts defeated | 3,032 / 7,656 (39.60%) | 2,750 / 7,656 (35.92%) |
| Decisions | 398,112 | 398,112 |
| Median latency | 2.741 ms | 0.0086 ms |
| p95 latency | 17.036 ms | 0.0110 ms |
| Maximum latency | 37.666 ms | 0.1366 ms |
| Fallbacks | 0 / 398,112 | 0 / 398,112 |

Latency includes the policy callback and observable-context seed derivation. Measurements are from an optimized arm64 native Mac build (Swift 6.4, macOS 27.0), not a physical iPhone or UI frame-time measurement. Expert used unchanged production limits: **eight samples, thirteen-trick rollout depth, 150 ms cooperative budget**. Normal runtime uses independent randomness; this benchmark injects reproducible observable-context seeds. No deadline outcomes were excluded and no run was selected for favorable results.

## Verification and scope

- The native regression suite passed before evaluation: 6,656 Standard comparisons; 572 legal/inference/fairness positions; settings/freezing/migration/restore/stale-result checks; target and score sensitivity; 48 full-hand combinations / 2,496 conserved plays; 7,168 frozen bidding recommendations and 542 auction positions; 1,560 public-threat parity positions, 223 Expert card and 131 Expert bid compatibility checks.
- All **796,224 benchmark card plays** passed legal-play validation; every played round conserved all 52 cards, emptied all hands and terminated. The existing state-mutation path was used throughout.
- Aggregate counts, seed uniqueness/range, contract accounting and decision totals were independently checked after completion. Recomputing the mean and confidence interval directly from the published cluster scores reproduced the reported values.
- Production `AISkill.swift`, `AIBidding.swift` and `DomainModels.swift` hashes still match the pre-run audit. The protocol file is unchanged. No simulator run was repeated because this turn changed only offline tooling and documentation, not the app.
- `git diff --check` passed. Existing uncommitted work was preserved; no commit was made.

Expert retains its original rollout scorer and root tie-breaking; its fallback remains revised Advanced. The rejected rollout substitution from the previous experiment was **not** used here. This result does not rehabilitate that rejected change.

## Reproduction and audit

From `/Users/markkelley/tarneeb-sdd-project`:

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh current-expert-advanced > /tmp/current-expert-advanced.json
```

The command fixes the seed range and sample size, calls the production policies, and retains per-deck scores. Machine load can affect deadlines and latency even with reproducible random seeds.

- [Frozen protocol](expert-advanced-evaluation.md)
- [Pre-run source hashes and configuration](expert-advanced-evaluation-audit.json)
- [Complete raw results, including cluster scores](expert-advanced-evaluation-results.json)

Protocol SHA-256: `9fc5e8afd430f3936783bc2f03da29548a7d651ae4b1ce2de35080e42eaea82f`.

Results SHA-256: `57b363f2058ccbd15fdb5f5dfdf4bfaa21e01adfaae93d5ac10e577288be276d`.

## Files changed this turn

- `tools/ai/PublicThreatIntegration.swift`: added the fixed production Expert-versus-Advanced evaluation entry point.
- `tools/ai/AdvancedAblation.swift`: added an optional progress callback; existing measurement and play logic are unchanged.
- `tools/ai/main.swift`: added `current-expert-advanced` command dispatch.
- `specs/011-mvp/expert-advanced-evaluation*`: frozen protocol, audit, raw results and this report.
- `specs/011-mvp/ai-skill.md`, `tasks.md`: linked the current evidence and recorded completion.

## What this establishes—and what remains

The prior evidence showed revised Advanced outperforming Standard. This fresh test now shows that unchanged Expert still outperforms revised Advanced **for card play with fixed bidding**. It does not establish the size of the gap with skill-specific bidding, different opponents, human partners, nonzero match scores or full-match play.

The next useful evaluation is **complete matches with each level's bidding enabled**, using another predeclared, fresh paired-deal protocol. Physical-iPhone profiling remains separate. No further policy tuning is justified by this result alone; these evaluation seeds must not later be reused as untouched evidence after tuning.
