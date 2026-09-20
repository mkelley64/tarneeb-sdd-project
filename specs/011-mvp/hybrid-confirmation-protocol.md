# Hybrid confirmation — frozen protocol

September 19, 2026. The previous component experiment selected **Advanced bidding + current Expert card play** as a candidate. Confirm that fixed candidate on untouched streams before any production promotion. Do not tune or change a policy in this experiment.

## Fixed design

Candidate partnership: Advanced bidding (including suit choice), current Expert card selection (including its preserved rollout model, tie-breaking and Advanced fallback). Both candidate seats retain these components for the whole match. References, in execution order: current Standard, current Advanced, current Expert; each reference uses its own bidding and card policy.

Use **256 fresh deal-stream seeds 400000–400255**, four hand/seat/initial-dealer rotations and swapped candidate partnerships: **2,048 full matches per reference, 6,144 total**. Reuse the same streams across comparisons, but do not treat comparisons or the eight arrangements as independent observations. Earlier component streams 300000–300255 are selection data and must not contribute to this confirmation.

Reuse the verified full-match runner: zero initial scores, actual first-to-31 rules and immediate winner stop, accumulated match score passed to both decisions, independent seeded shuffle stream indexed by all deal attempts, and counterclockwise dealer progression after played hands and all-pass redeals. All-pass deals remain in the sequence without scoring. Different auctions and match lengths are legitimate effects; do not force matching contracts or align by scored-hand number. Simulate South only for offline evaluation.

Search seeds derive solely from own cards and public context, including running score; never deal seeds, unseen holdings or private suits. Card search remains eight samples / thirteen-trick rollouts / 150 ms. Current Expert reference bidding remains sixteen samples / 200 ms; candidate bidding is deterministic Advanced and does not perform bid simulations. Retain all fallback/deadline outcomes. Run sequential optimized native builds so benchmark workers do not compete. The app's normal runtime randomness is unchanged.

Bound each auction at 64 actions, each scored hand at 52 legal/conserved cards and each match at 256 deal attempts. Report any unfinished match, never silently drop it, call it a draw or add replacements.

## Predeclared success criteria

Primary endpoint for each reference: candidate match-win fraction, averaged over eight arrangements within each original stream and then over 256 stream clusters. Use mean ± z×cluster standard error with z=2.39397979981851: two-sided **98.3333%** intervals, Bonferroni-adjusted across three reference comparisons.

Full statistical confirmation requires the lower adjusted bound to exceed **0.5 in all three comparisons**, all matches to finish, and no legality/conservation/state-progression failures. An interval containing 0.5 is inconclusive, not equivalence or success. An upper bound below 0.5 supports inferiority. If any matches hit the cap, publish their counts and the runner's descriptive win bounds, but withhold full confirmation. Fallbacks are retained and reported, not grounds for selecting a rerun.

No early stopping, sample-size extension, policy adjustment, favorable-run selection or substitution of prior data. Report individual findings honestly even if the complete gate fails. A successful result supports a separate promotion decision; it does not automatically authorize changing production in this turn.

Secondary descriptive endpoints: terminal score margin with nominal 95% stream-cluster interval, contract made/defeated counts and denominators, all-pass rate, match lengths, bid/card latency (median/p95/max), fallbacks and decision counts. Match-win rate is primary; do not use a favorable secondary metric to rescue a failed gate. Contract percentages are conditional on differing auction choices.

## Verification and limitations

Run native regressions and existing component/full-match checks before held-out execution. Record source, harness, dispatch and protocol hashes before results; recheck afterward. Reconstruct primary intervals from raw match records independently and verify stream/arrangement uniqueness, actual winner thresholds, move counts, score/contract accounting and censoring.

This tests homogeneous AI partnerships against three current policy references, not human win rates or the exact one-human/three-AI experience. It is development-Mac timing, not physical-iPhone profiling. Finite samples may leave small differences inconclusive. No production app, settings, save format, animation/audio timing or visual changes; no simulator rerun is needed for a command/protocol-only change. Observed confirmation streams cannot later be reused as untouched evaluation data after tuning.

## Reproduction

Run sequentially from `/Users/markkelley/tarneeb-sdd-project` against the frozen source snapshot:

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh hybrid-confirmation standard > /tmp/hybrid-standard.json
sh tools/ai/run.sh hybrid-confirmation advanced > /tmp/hybrid-advanced.json
sh tools/ai/run.sh hybrid-confirmation expert > /tmp/hybrid-expert.json
```

Reports explicitly label `candidateBidding` as Advanced and `candidate` (card level) as Expert. Current Expert is still the original coupled Expert bidder/player, not the candidate. Search seeds are reproducible; timings and cooperative deadlines can vary with machine load.
