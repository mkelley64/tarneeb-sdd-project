# Full-match component experiment — frozen protocol

September 19, 2026. Diagnose the prior Expert–Advanced full-match result with a fixed 2×2 component experiment. No policy tuning or production changes.

## Fixed design

Every reference partnership uses current Advanced bidding and current Advanced card play. Candidate cells, in execution/analysis order, are:

| Code (bidding first) | Candidate bidding | Candidate cards |
|---|---|---|
| AA | Advanced | Advanced |
| EA | Expert | Advanced |
| AE | Advanced | Expert |
| EE | Expert | Expert |

Run all four cells on the same **256 fresh stream seeds 300000–300255**, four hand/seat/initial-dealer rotations and swapped candidate partnerships: **2,048 matches per cell, 8,192 matches total**. These streams are separate from previous diagnostic, training and held-out ranges. Diagnostic streams 130000–130001 are for harness verification only. No training, cell selection, early stopping, sample extension or rerun selection based on outcomes.

Use the existing full-match runner: start at zero, actual first-to-31 scoring and winner boundary, running match score supplied to bids/cards, the same independent shuffle stream indexed by every deal attempt (including all-pass), dealer advancement after every attempt, bounded auctions and legal conserved 52-card hands. Preserve all-pass outcomes. Each candidate component level is fixed for the entire match and applies to both seats. The reference is never switched. All four seats are simulated only for offline measurement.

Search seeds remain derived only from own cards and public information, including match score; no deal seeds, hidden hands or private preferred suits reach a policy. Expert retains its current rollout model and Advanced fallback. Runtime budgets remain eight samples / thirteen tricks / 150 ms for cards and sixteen samples / 200 ms for bidding. Sequential optimized native execution; preserve all deadline/fallback outcomes and report them. Cap each match at 256 deal attempts; report unresolved matches rather than dropping or relabeling them.

## Predeclared analysis

Let AA, EA, AE, EE be the candidate win proportions over eight arrangements within **each stream**. Compute paired stream-level contrasts before estimating uncertainty:

- Bidding main effect: `((EA − AA) + (EE − AE)) / 2`.
- Card-play main effect: `((AE − AA) + (EE − EA)) / 2`.
- Interaction: `EE − EA − AE + AA` (difference of the bidding effects across card policies; equivalent difference of card effects across bidding policies).

These are the three primary endpoints. Report their means in percentage points and normal intervals based on 256 stream-cluster standard errors, z=2.39397979981851: two-sided 98.3333% intervals, Bonferroni-adjusted for the three tests. Positive/negative main-effect intervals excluding zero support help/harm averaged across the other component. Interaction intervals excluding zero support a departure from additivity; intervals including zero are inconclusive, not proof of no interaction. Do not pool individual matches or treat correlated cells as independent samples.

Secondary descriptive contrasts use nominal 95% stream-paired intervals: EA−AA, EE−AE, AE−AA, EE−EA and EE−AA. Report raw cell win rates, match-score margins, contract make/defeat denominators, match lengths, all-pass counts, latency and fallbacks. Existing per-cell intervals emitted by the shared runner are descriptive only, not additional promotion gates. AA should split wins exactly through symmetric partnership relabeling; do not portray its degenerate interval as empirical proof of universal 50% behavior.

If any match is unresolved, retain raw per-cell win bounds and counts but withhold the component-effect significance analysis. Do not impute a draw, silently exclude a censored match, or add extra streams. Interpret modest/inconclusive effects honestly.

## Verification and limits

Before running, pass existing native regressions and new checks: historical default routing parity, explicit equivalent bidding routing, zero-budget tests proving only the selected Expert component falls back, reference remains unchanged, forced fallbacks reproduce the Advanced control, and synthetic factorial contrasts including a known interaction. Verify source/harness/protocol hashes before and after evaluation. Independently reconstruct results and paired intervals from per-match records afterward.

This estimates component contributions against one fixed Advanced opponent under the stated full-match distribution. It does not separately manipulate match-score utility, establish a mechanism inside the bidder, predict human results, or prove broad opponent-independent strength. Contract success rates are conditional on different auction choices. No observed winning hybrid will be silently promoted to production. Any tuning or promotion needs a separate decision and fresh evaluation. Physical-device performance remains outside scope; no simulator rerun is needed for offline-only changes.

## Reproduction

From the repository, run sequentially on the frozen source snapshot:

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh match-component advanced advanced > /tmp/components-AA.json
sh tools/ai/run.sh match-component expert advanced > /tmp/components-EA.json
sh tools/ai/run.sh match-component advanced expert > /tmp/components-AE.json
sh tools/ai/run.sh match-component expert expert > /tmp/components-EE.json
sh tools/ai/run.sh match-component-analysis /tmp/components-AA.json /tmp/components-EA.json /tmp/components-AE.json /tmp/components-EE.json
```

CLI argument order is **bidding, then card play**. Each raw report records `candidateBidding` and `candidate` (card level), with Advanced as reference. The historical `full-match` command keeps its original defaults and coupled skill routing. Latency and deadline behavior can vary with machine load despite reproducible search seeds.
