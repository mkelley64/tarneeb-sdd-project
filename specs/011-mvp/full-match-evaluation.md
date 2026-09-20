# Full-match skill evaluation — frozen protocol

September 19, 2026. Evaluate unchanged production bidding **and** card play together. No tuning in this experiment.

## Design

Run Advanced–Standard, Expert–Standard and Expert–Advanced, in that order. Each comparison uses 256 independent fresh deal-stream seeds 200000–200255, four hand/seat/initial-dealer rotations, and swapped partnerships: 2,048 matches per comparison, 6,144 total. Reuse the same streams across comparisons for variance reduction; do not pool their correlated results as independent evidence. Simulate South as well as the other seats only in the offline harness. Within each match, both seats of a partnership retain their assigned level for bidding and play.

Each stream initializes a separate SplitMix64 generator. Its successive values seed the existing canonical shuffled deal generator; these shuffle seeds never enter a policy. Each rotation and partnership assignment restarts the same stream, indexed by **deal attempts**, including all-pass redeals. Initial dealer rotates with hands; subsequent dealers advance counterclockwise after every attempt. Different policies may produce different auctions, redeals, match lengths and stopping points. Do not align by scored-hand count or force identical contracts, which would remove bidding effects.

Use actual `GameScore` / `TarneebScoringService` rules, starting at zero and stopping immediately when `winnerTeam` is non-nil (31 points). Pass the accumulated score to every bid and play decision. Preserve all-pass outcomes without scoring them. Bound auctions at 64 actions and each played hand at 52 legal, conserved card plays. A defensive cap of 256 deal attempts per match prevents a stall. Any unfinished match is reported, never silently dropped or called a draw.

Inject reproducible FNV-1a search seeds derived only from the acting hand and observable state, including running score. Card seeds extend the existing public-history fingerprint with declaring seat and score. Bid seeds include sorted own cards, seat, public bid/pass states, public high bidder/value and score; never private preferred suits. Production Expert bounds stay at eight samples / thirteen tricks / 150 ms for cards and sixteen samples / 200 ms for bids. Keep deadline/sampling fallback outcomes in the result. Execute sequentially on the development Mac; report actual latency and fallbacks, not physical-phone claims.

## Endpoints and interpretation

Primary: candidate match-win proportion relative to 50%. Average the eight match outcomes in each original stream, then average over 256 streams. Use a normal confidence interval based on stream-cluster standard error, with z=2.39397979981851 (two-sided 98.3333%, Bonferroni family adjustment for three comparisons). Do not treat the eight arrangements or individual hands as independent samples. No early stopping, policy selection or sample-size extension based on outcomes.

A lower adjusted bound above 0.5 supports superiority; an upper bound below 0.5 supports inferiority; otherwise report inconclusive. If matches hit the cap, publish candidate-win bounds assigning all unfinished matches first losses, then wins; require the conservative lower confidence bound to exceed 0.5 before any superiority claim. Never infer a precise win rate from censored matches.

Secondary descriptive endpoints: final candidate-minus-reference match score with nominal 95% stream-cluster interval; match lengths, all-pass counts, contract success/defeat with denominators, bidding/card decision latency (median/p95/max) and fallback rates. Terminal score margin is affected by stopping and overshoot and is not the primary endpoint. Contract make percentages are conditional on different bidding choices, not controlled contract quality. Publish per-match records and per-stream aggregates.

## Verification and scope

Before held-out execution, run existing native regressions plus harness checks on diagnostic streams 120000–120003: deterministic Standard replay, score/termination boundaries, all-pass/dealer progression, legal/conserved hands, bounded unresolved outcomes, forced Expert fallback, and observable search seed invariance. These diagnostics are not tuning or strength evidence. Record source, harness and protocol SHA-256 hashes before evaluation, recheck production hashes afterward. No production app edits or new simulator run are required for offline-only work.

The finite sample can leave small differences inconclusive. This measures fixed homogeneous partnerships against these policies, not the app's one human plus three equal-level simulated seats, human win rates, or physical-iPhone performance. No additional policy changes are authorized by an adverse result. Observed streams cannot later be called untouched held-out data after tuning.

## Reproduction

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh full-match advanced standard
sh tools/ai/run.sh full-match expert standard
sh tools/ai/run.sh full-match expert advanced
```

Each command fixes the 256-stream range and all production search limits. The three commands must use the same frozen production snapshot. The raw report includes limits, counts and stream/match records. Runtime deadline behavior can vary with machine load.
