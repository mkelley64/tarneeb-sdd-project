# Advanced card-play ablation and calibration

Protocol fixed September 17, 2026, before running the new experiment. This is an offline investigation, not a production policy replacement. Bidding, Standard, Advanced and Expert in the app remain unchanged. Altering Advanced in production would also affect Expert card and bidding rollouts, so promotion needs separate integration evaluation.

## Question and controls

Which current Advanced additions help or hurt, and can their weights be combined more effectively? Decompose the existing scorer into eight groups: cashing known winners on lead; protecting entries/control; accounting for opponents still to act; avoiding partner overtakes; establishing long suits; drawing/conserving trump on lead; avoiding known ruffs; contract/scoring urgency. Public-card inference is shared infrastructure, not a ninth separately estimated treatment; Standard already uses public history.

The all-zero scoring scaffold still values immediate partnership wins and basic rank/trump economy. It is **not Standard**. Therefore report (a) every singleton versus frozen Standard, (b) each singleton minus the zero scaffold on matched base-deal results, and (c) full policy minus each leave-one-out variant. Positive (c) means that component helps in the full combination. Neither singleton superiority over Standard nor a tactical fixture alone identifies a component's incremental value. All-one experimental scoring must match production Advanced exactly on every checked decision.

## Data separation and search, declared before results

- Training: 512 new base decks, seeds 50000–50511. Run zero scaffold, eight singleton variants, full original, and eight leave-one-out variants.
- Calibration: on the same training deals, deterministic coordinate search from both zero and all-one vectors. Weights are restricted to {0, 0.5, 1, 2}; two sweeps in fixed feature order per start, retaining each candidate evaluated. No new heuristic, weight range or additional sweep after seeing outcomes. Maximize mean paired score against Standard; exact ties prefer lower sum of weights, then lexicographic order. Cache repeated configurations.
- Validation: seeds 52000–52511, 512 new decks. Evaluate the five highest training-scoring configurations plus original Advanced and the zero scaffold. Select the highest validation mean among the five candidates, with the same tie-breaking. Validation is model-selection data, not final evidence.
- Freeze the selected vector in a machine-readable training artifact **before** opening held-out results.
- Final held-out evaluation: seeds 60000–62047, 2,048 new base decks, untouched until selection is frozen. Run selected versus frozen Standard, original Advanced versus frozen Standard, and selected versus original Advanced. No subsequent tuning using these results. The two selected-policy comparisons are co-primary: use Bonferroni-adjusted 97.5% two-sided intervals (z=2.241403) so combined error is at most 5% under the normal approximation. Original-versus-Standard is descriptive at 95%. Report inconclusive or harmful results, not just positive means.

## Paired-deal measurement

Reuse fixed Standard bidding, identical hands/contracts/trump within comparisons, four hand/dealer rotations and swapped partnerships. All-pass deals are counted and excluded equally because no card play occurs. Primary endpoint is the mean candidate partnership score minus opponent score averaged across the two partnership assignments and then the four rotations. Cluster intervals over independent base deals, not duplicated rotations. Singletons and leave-one-out contrasts use matched base-deal differences. Training intervals are exploratory and not multiplicity-adjusted; do not present them as confirmatory discoveries.

Report contract success/defeat, pair wins/ties/losses, decision disagreement with Standard, median/p95/max decision latency, legal moves, card conservation and fallback rates (these deterministic scorers have no search fallback). These are single-round, zero-start-score comparisons, not full-match or human win probabilities. Keep all variants' policies limited to own cards and public context. Runtime environment contains actual hands only to enforce play; the scorer receives no hidden cards or deal seed.

## Verification and delivery

Before training, verify all-one parity, legality, hand-order invariance and baseline repeatability on fresh diagnostic seeds outside all three data partitions. Test controlled feature switches and actual hidden-hand permutation with public context unchanged. Keep scorer/runner code offline under tools/ai, and leave production sources unchanged. Record raw per-deal results, weights, seeds, source hashes, commands, selected configuration, and limitations. A promising result can justify a later production integration with Expert re-evaluation; it is not automatically deployed by this experiment.

## Completed results

See [results and limitations](advanced-ablation-results.md), [training/validation data](advanced-ablation-training.json), [held-out data](advanced-ablation-heldout.json), and [freeze/source audit](advanced-ablation-audit.json). The frozen candidate improved over both Standard and original Advanced on held-out data, but lost two intended tactical behaviors. Production policies are unchanged. The audit's pre-results protocol hash refers to this document before this completion section was appended.

Implementation detail: bonuses/costs are scaled by their group weights; future-opponent survival uses the corresponding weight as an exponent, and urgency scales its departure from neutral. Following-play ruff protection is nested inside the survival estimate, so disabling threats also disables that branch. The groups are not assumed to be independent. A separate, descriptive post-selection tactical audit was added without changing training selection, the frozen scorer, or held-out evaluation.
