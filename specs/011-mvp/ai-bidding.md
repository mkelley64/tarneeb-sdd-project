# AI skill for bidding

September 19 hybrid confirmation: [Fresh confirmation](hybrid-confirmation-results.md) found Advanced bidding + current Expert cards beat current coupled Expert in 54.44% of 2,048 full matches (adjusted interval [52.27%, 56.62%]). It also beat Standard, but its advantage over Advanced remained inconclusive, so the predeclared all-three promotion gate failed. This supports the practical hybrid over current Expert in this setting, not a specific causal diagnosis inside the bidder. No production policy changed. Four card fallbacks and a 25.43-second timing outlier are retained and reported for further profiling.

September 19 component evidence: [Controlled full-match component experiment](match-components-results.md) found switching from Advanced to Expert bidding reduced win rate by 3.66 percentage points on average across card levels, adjusted interval [−5.81, −1.52], against a fixed Advanced reference. This identifies the bidding component as harmful in this setting, not the particular internal cause. No production policy changed; a hybrid or bidder revision requires a separate decision and fresh confirmation.

September 19 continuation: [Full-match evaluation](full-match-results.md) tests each level's bidding and card play together with running match scores. Both higher levels beat Standard, but Expert did not demonstrate an overall advantage over Advanced. This is not an isolated bidding ablation and does not identify the cause. Current Expert rollouts retain the original Advanced scorer through `ExpertRolloutCardPolicy`; references to Advanced rollout play below describe that original model.

September 16, 2026 extension requested after selectable card-play skill. This supersedes the prior card-play-only scope: the same match-frozen AI skill now governs all three simulated seats' bidding and card play. No new setting or save field is needed. Existing saves retain their active level; Standard keeps the original bidder unchanged. Human bids and trump selection, scoring, rules and animation timing remain unchanged.

## Design and implementation tasks

1. Characterize Standard bid recommendations and complete auctions before changing routing.
2. Add a public bidding context (own hand, visible bid/pass states, actor, current high bidder/value, match score). Do not expose stored preferred trump suits of other seats, actual hidden hands, deck or deal seed.
3. Advanced compares legal minimum commitments and trump suits using an analytic trick distribution and actual scoring utility. Preserve existing structural hand ceilings and partner-raise safeguards; higher skill must not mean indiscriminate larger bids. A bid of 13 is evaluated separately because its scoring differs.
4. Expert samples complete unseen hands, compares candidate bids with Pass on common samples, continues the auction with seat-local Standard bidders and plays full hands with seat-local Advanced card policies. Observed bids are public commitments, not proof of particular cards. Sampling does not reject hands because of bids. The hypothetical preferred suit of an existing high bidder is derived only from that sampled bidder's own hand.
5. Reuse existing bid acceptance, legal ordering and partner protection. Run search in a cancellable detached task overlapping the existing bid delay/cue; validate request/revision/context before applying. On deadline or sampling failure use Advanced. Preserve explicit injected/environment bid overrides for fixtures.
6. Verify parity, legality, partner discipline, scoring thresholds, suit selection, hidden-information independence, seeds, cancellation, fallback, stale results and match-level routing. Run existing bidding unit tests and simulator bidding/menu/resume regressions.

## Evaluation protocol fixed before tuning

Keep the original card-play-only benchmark unchanged. For bidding comparisons use separate tuning seeds 30000–30127 and held-out seeds 40000–40511. Compare Advanced–Standard, Expert–Standard and Expert–Advanced bidding on identical shuffled deals, four seat/dealer orientations and swapped partnerships. Hold **card play fixed to Advanced for every seat**, isolating bidding effects; auction outcomes may differ because that is the treatment. All-pass orientations count as a zero-score redeal, are reported, and are not silently replaced with favorable deals. Simulate South too for offline evaluation only.

Primary endpoint: mean paired partnership score differential with a 95% interval over original-deal cluster means, not over correlated rotations. Report declaration opportunities, contract success, defensive contract defeat, round-score margins, all-pass rates, bidding latency and search fallback rates. These are single-round bidding comparisons, not whole-match/human win rates. No strength claim unless supported on the held-out set; report inconclusive or worse results honestly. Profile candidate sample limits on tuning seeds before fixing production bounds. Do not tune on held-out outcomes.

## Frozen policy and production budget

Policies were fixed before held-out evaluation. Advanced uses the original structural suit ceilings, an analytic trick distribution with spread 0.9–1.5, a 60% minimum estimated make probability (97% for 13), and expected score margins of 0.5 versus Pass or 1.5 when partner leads. Candidate order is canonical Suit.allCases order, cheapest legal bid before 13; exact ties retain that order, and Pass wins ties. Expert shares the same candidate set and make/margin gates, averages real scoring outcomes over 16 common assignments, and models future bidding with unchanged Standard policies. Future play is seat-local Advanced. Bids remain unconditioned soft evidence: no sampled hand is excluded for an earlier bid or pass.

Release profiling on tuning seeds 30000–30031 covered complete auctions: 8 samples / 130 decisions / 40 searches had p95 5.00 ms, max 8.00 ms; 16 / 131 / 39 had p95 9.95 ms, max 14.98 ms; 32 / 130 / 37 had p95 20.20 ms, max 29.50 ms. No fallbacks occurred. Select **16 samples, 200 ms cooperative deadline, at most nine root actions, 64 future bid actions and 52 card plays per rollout**. Deadline/cancellation is checked at every rollout action; unfinished searches discard partial estimates and return Advanced. These are development-Mac measurements, not physical-iPhone latency guarantees. Search runs detached, overlapping the existing simulated-bid delay and cue; timing tokens are untouched.

Tuning-set results (128 deals, 1,024 rounds per comparison): Advanced–Standard +1.598 [0.789, 2.407]; Expert–Standard +1.450 [0.575, 2.325]; Expert–Advanced −0.496 [−1.034, 0.042]. These are exploratory, not strength claims. No policy changes were made in response to these outcomes. The all-spades tactical test fixes the other players to Pass to isolate the 13 scoring choice: with an open auction, an economical 7 may tie 13 in sampled utility because Standard continuation later raises it to 13. This is an auction-model limitation, not evidence that the immediate bids are equivalent in every real game.

## Held-out evidence

Each comparison uses 512 independent decks, four seat/dealer orientations, two partnership assignments: 4,096 rounds, including all-pass outcomes, and 2,048 paired orientations. Intervals use 512 base-deal clusters. The three nominal 95% intervals are not adjusted for multiple comparisons. Policies and limits were frozen before this evaluation. Full counts and latency data are in [ai-bidding-benchmark.json](ai-bidding-benchmark.json).

| Bidding comparison | Mean paired score margin | 95% interval | Paired wins / ties / losses | All-pass rounds |
|---|---:|---:|---:|---:|
| Advanced − Standard | +1.234 | [0.876, 1.593] | 506 / 1,384 / 158 | 264 |
| Expert − Standard | +1.435 | [1.020, 1.850] | 757 / 924 / 367 | 449 |
| Expert − Advanced | −0.173 | [−0.413, 0.066] | 329 / 1,357 / 362 | 449 |

For each paired orientation the score margin is the mean of the candidate's partnership score minus its opponent's across swapped partnerships; these are not independent match wins. Advanced and Expert bidding improve over Standard under this fixed-Advanced-play protocol. **Expert has not demonstrated stronger bidding than Advanced.** This evidence does not establish combined bidding-and-play strength, human match win rates, or improvement in Advanced card play.

| Comparison | Candidate contracts made | Reference contracts made | Candidate defenses won | Reference defenses won |
|---|---:|---:|---:|---:|
| Advanced − Standard | 1,372 / 1,728 (79.4%) | 1,392 / 2,104 (66.2%) | 712 / 2,104 (33.8%) | 356 / 1,728 (20.6%) |
| Expert − Standard | 1,108 / 1,270 (87.2%) | 1,552 / 2,377 (65.3%) | 825 / 2,377 (34.7%) | 162 / 1,270 (12.8%) |
| Expert − Advanced | 1,233 / 1,440 (85.6%) | 1,747 / 2,207 (79.2%) | 460 / 2,207 (20.8%) | 207 / 1,440 (14.4%) |

Contract success rates are selected by each policy's bidding decisions, not like-for-like contract quality. Expert claims fewer contracts and produces more all-pass rounds than Advanced; its higher make percentage does not imply a higher overall score. No ablation establishes a single causal explanation for its inconclusive result against Advanced.

Held-out Expert p95 bidding latency was 10.55 ms against Standard and 10.68 ms against Advanced. Maximums were 20.73 and 151.14 ms respectively; other build/simulator activity ran on the development Mac, so these are wall-clock measurements under concurrent load. All 17,247 Expert decisions completed without fallback. Advanced p95 was 0.024–0.027 ms. Timing includes baseline recommendation construction and policy selection, but not UI delay or full round simulation outside the decision. Physical-device latency/frame pacing remains unverified.

## Verification and reproducibility

From the repository root:

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh bid-baseline
sh tools/ai/run.sh bid-profile
sh tools/ai/run.sh bid-benchmark advanced standard 30000 128
sh tools/ai/run.sh bid-benchmark expert standard 30000 128
sh tools/ai/run.sh bid-benchmark expert advanced 30000 128
sh tools/ai/run.sh bid-benchmark advanced standard 40000 512
sh tools/ai/run.sh bid-benchmark expert standard 40000 512
sh tools/ai/run.sh bid-benchmark expert advanced 40000 512
```

Native verification passed: 7,168 frozen Standard recommendations (sorted-JSON FNV-1a 2562604130927913130), 542 auction positions with complete legacy-routing parity and 158 Advanced bid/suit differences; legal values and partner safeguards; all bid/trick scoring boundaries; certain 13; seeded repeatability; 52-card sample conservation; hidden-hand permutations exercising actual Expert search; private stored trump isolation; invalid-hand/budget fallback; detached and mid-rollout cancellation; shared skill across East/North/West; first-Deal freezing; resumed bidding, superseded/duplicate/reset/restore stale results; fixture overrides. The existing card-play, persistence and migration verification also passed unchanged.

Xcode 27.0 / iOS 26.5 / iPhone 17 Pro: all **185 unit tests and 12 selected UI tests passed**. UI selection: six OpeningTable tests, four ContinuedPlay tests, AI-skill-menu test across three screens, and new Expert bidding from Deal to legal card play without bid overrides. After strengthening the certain-13 fixture, the final 185-unit-test suite passed again. Result bundles: `/tmp/tarneeb-bidding-simulator.xcresult`, `/tmp/tarneeb-bidding-final-unit.xcresult`. `git diff --check` passed. The unrelated historical launch-layout suite and full-match long-play tests were not rerun for this bidding extension.

## Remaining weaknesses

Advanced's analytic trick probabilities are heuristic, not calibrated probabilities. Expert uses only 16 assignments and does not condition hand strength on observed bids/passes; rare threats and inferred strong bidders may be underrepresented. Future auctions assume Standard rather than the actual opponent level, and future play assumes Advanced; these assumptions can misvalue passes, future raises and retained contracts. Both share conservative Standard structural bid ceilings, restricting exploration of marginal hands. Next work should measure individual decision disagreements and ablate these assumptions on a new tuning set before a new untouched evaluation set. Do not tune against the now-observed held-out seeds. No additional saved search state is introduced.
