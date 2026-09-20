# Current Expert versus revised Advanced

Protocol frozen September 18, 2026, before running this evaluation. No policy tuning or production changes are authorized by this experiment.

## Question and fixed protocol

Does current production Expert card play outperform revised production Advanced under identical bidding conditions?

- Use 2,048 previously unused base-deal seeds 100000–102047. No training, selection, early stopping, sample-size extension, or rerun selection based on the outcome.
- Use existing canonical shuffle, fixed Standard bidding, four hand/seat/dealer rotations and swapped candidate partnerships on the identical auction. Exclude all-pass orientations and report exclusions. Start round scores at zero.
- Candidate: production `AIDecisionEngine` Expert, including preserved `ExpertRolloutCardPolicy` and revised Advanced fallback. Reference: production Advanced.
- Inject `expertIntegrationSeed(context)` (FNV-1a of own sorted card IDs, public play history, seat, trump and contract). No hidden holdings, deal seed or future randomness enter the selector. Production limits: eight samples, thirteen-trick rollouts, 150 ms cooperative budget. Use one sequential optimized native process, not concurrent benchmark workers.
- Primary endpoint: paired partnership score differential, using actual scoring. Each orientation averages candidate-minus-reference score over the two partnership assignments. Average orientations within each base deck; decks, not rounds/decisions, are independent uncertainty clusters.
- One two-sided 95% normal interval, mean ± 1.96 times deck-cluster standard error. Lower bound above zero supports Expert superiority in this card-play protocol; upper bound below zero supports a regression; an interval containing zero is inconclusive. No multiple-primary adjustment is needed for this single comparison.
- Report all cluster seeds/scores, pair wins/ties/losses, contracts made/defeated and denominators, decision counts, median/p95/max latency, and fallback counts. Assert legality, 52-card conservation and hand completion throughout.
- Run existing native regression suite before evaluation. Preserve source hashes and protocol hash before observing results. Diagnostic tests use existing diagnostic seeds, not these held-out decks.
- If runtime deadlines trigger fallbacks, keep their outcomes in the primary result; do not discard slow decisions or select a more favorable run. Machine load can change fallback behavior despite reproducible search seeds.

This is not a full-match, skill-specific-bidding, human-opponent or physical-iPhone benchmark. It does not establish that every individual Expert move is superior or prove transitive strength across all opponents. No app UI or simulator rerun is required for an offline-only harness addition.

## Frozen production hashes (SHA-256)

- AISkill.swift: `4963c6ab6f99fa1a01c876c470b83fd3d16479ffe07b30e99de289c351c54f96`
- AIBidding.swift: `5c51ea4c13675777fc3d174b10202b2f5c9f26ee3a651e1e6b4d8d4b04732f01`
- DomainModels.swift: `92edb116262597cac6a876251fb92f2b497624c29680cfc904e42b9eec5faa4a`

## Reproduction

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh current-expert-advanced > /tmp/current-expert-advanced.json
```

The command evaluates exactly the fixed seed range above and reports production Expert as candidate and revised Advanced as reference. It is distinct from the rejected trial commands in the public-threat revision.
