# Selectable AI skill

September 20 physical-device check: [Isolated Release tests on iPhone 15 Pro](physical-latency-results.md) passed 256 paired opening positions with legal identical choices and zero fallbacks. Production detached p95/max were 30.14/64.09 ms; main-actor heartbeat continued and bid/card cancellation tests passed. This focused check is not full-game frame-time, sustained-load or rare-tail acceptance. The historical Mac stall remains unexplained and production policies are unchanged.

September 19 latency investigation: [Offline diagnostics](latency-diagnostics-results.md) compared 6,032 public decision positions twice on fresh diagnostic deals, with full selection parity and no fallbacks. Ordinary p95/max were 17.63/34.51 ms; the historical 25.43-second delay did not recur and remains unexplained. Wall/thread-CPU/checkpoint telemetry and public-context replay were added only to offline tooling. Controlled delay/cancellation checks passed; physical-device responsiveness is still unverified because only simulators were available. Production policies and prior strength evidence remain unchanged.

September 19 hybrid confirmation: [6,144 fresh full matches](hybrid-confirmation-results.md) tested Advanced bidding + current Expert cards. Win rates were 76.95% versus Standard, 51.86% versus Advanced and 54.44% versus current Expert. Adjusted intervals supported gains over Standard/current Expert but not Advanced ([49.80%, 53.91%]); the frozen all-three gate was not met. Production stays unchanged. Four legal card fallbacks and an unexplained 25.43-second elapsed-time outlier require follow-up profiling; typical card p95 was below 20 ms, not a hard latency guarantee.

September 19 component diagnosis: [Fresh full-match factorial experiment](match-components-results.md), 8,192 matches against fixed Advanced, found Expert bidding harmful on average (−3.66 win-rate percentage points, adjusted interval [−5.81, −1.52]) and Expert card play beneficial (+2.59 [+0.59, +4.58]). Interaction was inconclusive. Advanced bidding + Expert play is a candidate for independent confirmation, not a production change. Complete Expert superiority remains unproven.

September 19 full-match evidence: [Combined bidding-and-play evaluation](full-match-results.md) completed 6,144 matches. Advanced and Expert beat Standard, but Expert versus Advanced split 1,024–1,024 (adjusted win-rate interval 47.52%–52.48%). A strict full-match strength progression is not established. Production policies are unchanged; this does not negate the narrower fixed-bidding card-play evidence below.

September 18 evaluation: [Current Expert versus revised Advanced](expert-advanced-evaluation-results.md) found a +0.441 paired score advantage for Expert, 95% interval [0.299, 0.583], on 2,048 fresh decks / 15,312 played rounds with fixed Standard bidding. No production policy changed. This supersedes the earlier lack of a direct current-policy comparison, but does not establish full-match strength with skill-specific bidding.

September 17 production update: [Public-threat separation](public-threat-revision.md) independently improved Advanced versus Standard and original Advanced on fresh held-out deals, preserving intended tactics. Generic higher-card speculation is disabled; demonstrated-void risk remains. Expert retains its original rollout model after the substitution regressed its results; its fallback uses revised Advanced. The benchmarks and weaknesses below describe the **original** policies, not the revised Advanced. The earlier [ablation candidate](advanced-ablation-results.md) was not promoted.

## Requirements

Standard is the unchanged September 16 selector, including ordering. All three simulated seats use one match-frozen skill. Scoring, legality, presentation tokens and audio/motion timing remain unchanged. The next-game preference defaults to Standard; older saves resume Standard. Public information alone enters policies and search. This document records the original card-play-only implementation and benchmarks; the subsequent [bidding extension](ai-bidding.md) applies the same setting to bidding, with separate evaluation evidence. Historical statements below about unchanged bidding refer to that original slice and its fixed-auction benchmark.

## Design and tasks

1. Characterize and freeze the existing selector before changing routing.
2. Separate public decision context, public inference, Advanced policy, constrained sampler and bounded Expert orchestration.
3. Store next-game preference separately from the active match level; expose AI skill in every existing options menu.
4. Search off the main actor, propagate cancellation, and validate a request identity and current state before committing through TrickPlayService.
5. Verify legal play, conservation, history constraints, seeds, migration, freezing, cancellation and stale results.
6. Run paired evaluation and publish limitations without claiming strength from tactical fixtures.

## Evaluation protocol (fixed before tuning)

Use deterministic shuffled decks with disjoint seed ranges: tuning 10000–10127, held-out 20000–20511 (512 independent decks). Rotate each deck through all four seats with the dealer rotated identically; swap the candidate and reference partnerships for each orientation. Bidding uses the unchanged automated bidder for every seat, fixed personality inputs, and identical contracts within each pair. All-pass deals are recorded and excluded from card-play comparisons. Compare Advanced–Standard, Expert–Standard and Expert–Advanced. Standard is frozen before policy changes.

Primary endpoint: paired partnership score differential under the actual round scoring rules. Report win/tie/loss of the paired score, declaring contract success and defensive contract defeat, mean score difference and 95% confidence intervals clustered by original deck (rotations are not independent samples). Report sample/deal counts, seeds, per-decision median/p95/max latency and fallback rates. No tuning on held-out deals. A positive mean alone is insufficient evidence: the confidence interval must exclude zero. Report inconclusive/negative results honestly. Round outcomes are not full-match win probabilities.

Profile candidate search configurations on tuning deals before setting production limits. Search uses common sampled assignments across root moves, but each rollout policy receives only that seat's own hand and public history. It must not select future moves by consulting other sampled hands. This reduces perfect-information planning; determinization and heuristic rollout bias remain limitations.

## Implemented information and policy boundaries

`AIDecisionContext` contains the acting seat's own cards, public trick history, declarer, target, trick totals/remaining tricks (derived), and match score. `TrickPlayService.decisionContext` reads only the acting player's hand plus public fields, never the other hands or deck. Policies do not accept `GameState`. Bids are deliberately not used as sampling constraints or evidence in this iteration.

`AutomatedCardSelector` remains unchanged. Standard still uses its exact order and winner rules. `AdvancedCardPolicy` derives outstanding cards and demonstrated voids, estimates opponents still to act, conserves partner winners/entries, strengthens vulnerable winners, draws trump from declaring control, establishes length and penalizes known ruff risks. Contract urgency includes the actual scoring service's marginal score change and first-to-31 outcome. Scores tie by existing economical rank/suit order (spades, clubs, hearts, diamonds), with a 1e-10 comparison tolerance.

`PlausibleHandSampler` uses seeded, constrained randomized backtracking, most-constrained cards first, subset-capacity pruning, and a 4,096-node cap. Own cards remain fixed; public cards cannot reappear; remaining sizes and observed voids are hard constraints. Inconsistent inputs fail. This is plausible sampling, not a uniform Bayesian posterior.

`ExpertCardPolicy` evaluates every legal root move on the same eight assignments. Rollout policies use Advanced with only their own sampled hand and evolving public history. They never receive the complete sampled assignment, an oracle, a future random stream or the actual game state. Future actions are fixed policy responses, not perfect-information minimax choices. Rollouts extend up to 13 collected tricks (the remaining hand). An injected shorter depth uses a neutral binomial continuation integrated through actual terminal scoring, not immediate trick count. This continuation is only a bounded approximation. Exact utility is round score difference plus 64 for a match win/minus 64 for a match loss, using `GameScore.winnerTeam` for the existing winner rule.

Root ties prefer Advanced's answer, then economical order. Tests inject seeded SplitMix64 randomness; normal play generates a fresh independent seed. With a nonbinding deadline, identical information/seed produces identical choices, including hand-array permutations. Wall-clock exhaustion deliberately returns Advanced, so replay across differently loaded machines can differ if one hits the deadline.

## Search lifecycle and limits

Native optimized opening-position profiling on 15 non-all-pass deals from seeds 10000–10015 measured roughly 13/25/38 ms medians for 4/8/12 full-hand samples, with maxima 14/26/42 ms and no fallback. Three-trick rollouts measured roughly 4/6/9 ms. Production defaults were then fixed at eight samples, 13 tricks, a 150 ms monotonic wall budget, and the sampler's 4,096-node cap. Every assignment recursion and rollout play checks cancellation/deadline. Exhaustion or sampling failure discards incomplete search scores and returns Advanced; forced moves bypass search. These measurements are on the development Mac, not physical iPhone validation.

`AIDecisionEngine.detached` runs outside the UI actor and forwards parent cancellation. The existing thinking cue overlaps search; its approved duration and all motion/audio tokens are unchanged. A request includes an ephemeral request UUID and command/restore revision. The presentation model checks both plus the current public context and active skill before applying the selected card. Reset, restore, another request, accepted play or other domain checkpoint invalidate old results. Existing `TrickPlayService.play` performs final legality and state mutation. Neither inference nor search state is saved.

## Preference and save lifecycle

All three existing Game options menus contain `AI skill` with Standard, Advanced, Expert and explanatory text covering North and next-game applicability. The `tarneeb.aiSkill` UserDefaults preference defaults to Standard, including unknown preference strings. As confirmed by the user, the first fresh match captures it on the first successful Deal. Subsequent New Game commands capture it immediately. Redeals, next hands and preference edits cannot change the active value. Restoring even a pre-deal saved match retains its saved active value.

Snapshot version 2 writes `activeAISkill` separately from UserDefaults. Version 1 accepts the missing field and always restores Standard. Version 2 requires a valid non-null level; corrupt/unknown enum values fail decoding through the existing save-error flow. The existing `match-v1.json` filename remains the migration discovery path; its contents carry the schema version. No rule state or derived inference is added.

## Verification commands

From the repository root on Apple Silicon with Xcode installed:

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh profile
sh tools/ai/run.sh benchmark advanced standard 10000 128
sh tools/ai/run.sh benchmark expert standard 10000 128
sh tools/ai/run.sh benchmark expert advanced 10000 128
sh tools/ai/run.sh benchmark advanced standard 20000 512
sh tools/ai/run.sh benchmark expert standard 20000 512
sh tools/ai/run.sh benchmark expert advanced 20000 512
xcodebuild -project Tarneeb.xcodeproj -scheme Tarneeb -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/tarneeb-ai-ios-build CODE_SIGNING_ALLOWED=NO build-for-testing
```

The runner uses the native Swift toolchain and the same domain sources, an explicit macOS SDK/target and optimized compilation. It builds in a new temporary directory. Benchmark JSON reports paired outcomes, scoring confidence intervals, contract success/defeat counts, latency and fallbacks. Standard's frozen oracle is based on commit `f0c6e182c40c5a06ab8320c22d00b1548afaae9e`; its rank mapping and ordering are independent copies, while unchanged rule winner/scoring code remains shared.

## Verification coverage and execution status

Native verification passed on September 16, 2026:

- 6,656 frozen-policy comparisons were first run before selection-path edits; they still pass. A further 572 real public-history positions match the frozen selector.
- Fixtures distinguish Advanced from Standard for drawing trump while preserving an ace entry, establishing length, considering players still to act, and protecting a partner against a demonstrated ruff. Additional fixtures verify unnecessary-overtake avoidance and safe lead selection.
- All bid targets 7–13 and declaring totals 0–13 agree with the existing scoring service, including kaboot and bid-13 boundaries. Match-win/loss utility boundaries pass. A fixed tuning-domain audit observes 13 decisions changing with target and three with match score.
- 572 sampled positions preserve 52 unique cards, the acting hand, remaining sizes and observed voids; identical seeds reproduce assignments. Hidden-hand permutations preserve decision context and seeded choices. Impossible void/capacity constraints fail safely.
- 572 mixed-policy plays plus 2,496 plays across all 48 skill/declarer/trump combinations follow suit, conserve cards and finish exactly 13 tricks. The latter matrix uses two samples/full-hand depth with a nonbinding test deadline; the benchmark exercises production limits.
- Empty-work budgets, an actual tiny positive deadline, sampling failure, mid-search cancellation and detached cancellation fall back or cancel promptly. Superseded requests, duplicate results, changed turns, illegal results, reset and restore reject stale work.
- Preferences, first-Deal freezing, subsequent-New-Game freezing, all-pass redeals, next hands, disk round trips, restored active levels, v1 migration and rejection of v2 missing-level saves pass. East, North and West requests share the same match level.
- Debug simulator app/test targets (`build-for-testing`) and unsigned Release device app (`build`) compile successfully. `git diff --check` passes. The existing bidding, selector, rule, scoring, design-token and audio implementation bodies were not changed.

Three focused XCTest methods and a UI-menu test were added to the existing targets. Initial execution was blocked by mismatched CoreSimulator/CoreDevice frameworks. The later simulator verification below supersedes that limitation; native tests alone were not treated as a substitute for iOS regressions.

On a physical phone, verify menu readability, background/reset during Expert search, restored play, frame pacing and actual Release search latency. Simulator passes do not establish physical-device performance.

### Simulator follow-up (September 16, 2026)

Xcode 27.0 (27A266a) successfully ran iOS 26.5 simulators. The main iPhone 17 Pro run executed 208 tests: all 181 unit tests passed, and 26 of 27 current UI tests passed. The only failure was the new AI-skill menu test. Its accessibility snapshot showed SwiftUI had flattened the Picker into Standard/Advanced/Expert rows, omitting the required AI skill label. This was a real UI issue, not a relaxed test assertion.

Wrapped the picker and explanatory text in an explicit `Menu("AI skill")` in `OpeningTableView.swift`, shared by all three options surfaces. The test now includes the accessibility tree in failure diagnostics. The corrected opening/live/result submenu test passed on iPhone 17e. On iPhone 17 Pro, the complete 181-test unit suite and two affected UI tests (AI-skill menu and live options confirmation/reset) then passed with zero failures/skips.

Thus all 181 unit tests and all 27 current UI tests have passing results across the main run and targeted rerun; this is not a claim that the entire 208-test suite was rerun after the isolated menu change. The superseded historical `TarneebLaunchUITests` layout suite was excluded. Current coverage includes full two-hand match completion/relaunch/reset, mixed-suit play, resume/recall, opening/bidding/trump, live interactions, reduced motion, automatic final-card play, and round/match results.

Result bundles: `/tmp/tarneeb-ai-simulator-results-20260916.xcresult` (initial run), `/tmp/tarneeb-ai-menu-fixed-17e.xcresult`, and `/tmp/tarneeb-ai-simulator-fixed-17pro.xcresult` (final reruns).

### Menu copy clipping follow-up

User screenshot review found that the explanatory menu row truncated its final sentence. Split the copy into two short native menu rows: `All AI players, including North.` and `Applies to the next new game.` The focused opening/live/result menu test now checks both rows and retains screenshots for visual inspection. It also waits for submenu choices to appear, addressing an immediate-query failure on iPhone 17. The focused test passed on iPhone 17 and the narrower iPhone 17e (iOS 26.5); captured result-screen screenshots were inspected and both sentences are fully visible. Results: `/tmp/tarneeb-ai-copy-17-retry.xcresult` and `/tmp/tarneeb-ai-copy-17e.xcresult`.

## Held-out benchmark evidence

The policies and production limits were fixed before evaluating seeds 20000–20511. Each comparison requested 512 independent shuffled decks, excluded 41 all-pass decks (164 orientations), and scored 471 deck clusters, 1,884 paired orientations, and 3,768 rounds. Across all three comparisons this is 11,304 rounds / 587,808 decisions. The same base deck rotates hands through four seat positions and uses all four dealers; each orientation swaps candidate/reference partnerships under identical hands, bids and trump. Bidding is deterministic AutomatedBidRecommender for all seats, including an automated South for offline evaluation; no personality randomness is introduced.

For each orientation, the paired score is half the sum of candidate-minus-reference partnership score margins from the two partnership assignments. Average these four values per original deck, then report the mean across decks and a normal 95% interval using the standard error of those independent deck means. Rotations and duplicate seeds are not treated as independent observations. The intervals are unadjusted per comparison. Round scores start at 0–0: these are not full-match win rates or estimates of a human's experience with three equally skilled simulated seats.

| Comparison | Mean paired score difference | 95% deck-clustered interval | Paired wins / ties / losses |
| --- | ---: | --- | --- |
| advanced vs standard | -0.027 | [-0.497, 0.444] | 658 / 592 / 634 |
| expert vs standard | 0.656 | [0.344, 0.968] | 824 / 551 / 509 |
| expert vs advanced | 0.745 | [0.445, 1.045] | 731 / 625 / 528 |

| Comparison and policy | Contracts made | Contracts defeated while defending | Median / p95 / max decision ms | Fallbacks / decisions |
| --- | --- | --- | --- | --- |
| advanced vs standard: advanced | 1100/1884 (58.39%) | 768/1884 (40.76%) | 0.006 / 0.009 / 0.069 | 0/97968 |
| advanced vs standard: standard | 1116/1884 (59.24%) | 784/1884 (41.61%) | 0.002 / 0.006 / 0.096 | 0/97968 |
| expert vs standard: expert | 1193/1884 (63.32%) | 773/1884 (41.03%) | 2.965 / 18.478 / 34.643 | 0/97968 |
| expert vs standard: standard | 1111/1884 (58.97%) | 691/1884 (36.68%) | 0.002 / 0.007 / 0.038 | 0/97968 |
| expert vs advanced: expert | 1254/1884 (66.56%) | 745/1884 (39.54%) | 2.909 / 17.720 / 33.758 | 0/97968 |
| expert vs advanced: advanced | 1139/1884 (60.46%) | 630/1884 (33.44%) | 0.006 / 0.009 / 0.075 | 0/97968 |

**Conclusion:** Expert improved paired round score over both references in this held-out benchmark. Advanced did **not** demonstrate improvement over Standard; its interval contains zero and its mean is slightly negative. Do not market Advanced as proven stronger based on tactical examples. Expert's observed latency/fallback results are optimized native Mac measurements, not physical-phone frame-time evidence.

The separate tuning set (10000–10127) scored 117 non-all-pass decks / 936 rounds per comparison. Advanced–Standard was +0.306 [−0.770, +1.381]; Expert–Standard +0.993 [+0.369, +1.616]; Expert–Advanced +0.876 [+0.338, +1.414]. No heuristic parameters were adjusted after viewing held-out outcomes. All six full reports, including counts and timings, are in [ai-skill-benchmark.json](ai-skill-benchmark.json).

Reproduction uses the commands above and Swift 6.4 optimized native builds. The evaluated production policy SHA-256 is `d3a8321edafa395944f84e77e79a9af2edfcfa0ed0220b19f5abe7cee4d740c5` for AISkill.swift; benchmark SHA-256 is `e711e87702c2351cd49a40c2f5f5dd6bb0004cd1b53f705377ff288f22ed59a2`. Runtime deadlines can affect replay on much slower or overloaded hardware; inspect fallback counts when comparing runs.

## Remaining weaknesses and next work

Advanced's independent marginal survival estimates are crude. They can overvalue covering early in a trick, undervalue a partner still to play, and do not explicitly reason about deliberate ducking or sequences of entries. Its urgency multipliers and suit-establishment rules need further tuning on a new training set, followed by a new untouched evaluation set. Do not reuse this held-out set for tuning while retaining its test status.

Expert inherits those rollout weaknesses. Eight assignments give noisy move estimates; randomized constrained backtracking is biased, and policy rollouts do not model a human partner or bluffing. Information-set action restrictions limit unrealistic perfect-information planning, but cannot remove determinization bias or all strategy-fusion effects. Bids remain unused soft evidence. Full-match strength distributions, broader opponents and physical-device performance remain unverified. The 150 ms cooperative deadline is not a hard real-time operating-system guarantee; fallback is checked frequently and remains legal.
