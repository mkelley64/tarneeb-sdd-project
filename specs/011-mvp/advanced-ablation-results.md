# Advanced card-play ablation: findings

September 17, 2026. Completed offline research in `/Users/markkelley/tarneeb-sdd-project`. **The app’s production policies have not changed.**

## Outcome

The current “opponents still to act” estimate is the largest harmful component identified by the training ablations. Cashing known winners and trump management help. Other additions are inconclusive within the original combination, and some behave differently in isolation.

After 108 training configurations and separate validation, a frozen calibrated combination improved on both Standard and current Advanced on untouched held-out deals. However, a descriptive tactical audit exposes losses of vulnerable-partner protection and long-suit establishment. The candidate is a useful research result, **not a production-ready replacement**.

## What helped and hurt

Training used 512 new base decks (seeds 50000–50511), with 479 playable clusters after excluding 33 all-pass decks. Bidding was fixed to Standard. Each variant used four seat/dealer orientations and swapped partnerships: 3,832 rounds.

The all-zero **scoring scaffold is not Standard**: it retains immediate partnership-winning value and basic card economy but lacks the eight extra strategic groups. It scored −2.836 against Standard; full original Advanced scored −0.294.

“Alone vs Standard” means scaffold plus that one group. “Added to scaffold” measures its incremental effect on score versus the same Standard opponent. “Contribution within full Advanced” is full policy minus leave-one-out performance versus Standard on matched deals; positive helps, negative hurts. These last contrasts are not direct head-to-head matches between the two variants.

| Heuristic group | Alone vs Standard | Added to scaffold | Contribution within full Advanced, exploratory 95% interval |
|---|---:|---:|---:|
| Cash known winners on lead | +0.065 | +2.900 | +2.166 [+1.630, +2.702] |
| Extra entry/control retention | -2.831 | +0.005 | -0.091 [-0.241, +0.058] |
| Opponents-still-to-act estimate | -3.451 | -0.616 | -1.148 [-1.670, -0.626] |
| Extra partner-overtake penalty | -2.836 | +0.000 | -0.018 [-0.064, +0.029] |
| Long-suit establishment | -3.363 | -0.528 | -0.083 [-0.409, +0.243] |
| Trump lead management | -1.784 | +1.052 | +0.449 [+0.183, +0.715] |
| Known-ruff avoidance | -2.717 | +0.118 | +0.186 [-0.063, +0.434] |
| Contract/scoring urgency | -2.836 | +0.000 | -0.033 [-0.253, +0.186] |

The strongest signals are +2.166 for cashing winners, +0.449 for trump management, and −1.148 for the future-opponent estimate within the original combination. Long-suit establishment hurt when used alone but was inconclusive in the full policy. The other full-policy intervals include zero; that does not prove those ideas are useless. These training intervals are exploratory, unadjusted for multiple tests, and not independent confirmation. Complete singleton and matched-contrast intervals are preserved in the raw training data.

The code explains a plausible mechanism: it discounts the current winner against possible higher cards at each remaining opponent, without crediting a partner who can subsequently win. That can encourage spending high cards early. The ablation identifies the problematic **group**, not which assumption inside it causes how much loss.

The groups interact. In particular, the known-ruff contribution while following is inside the future-opponent survival calculation. Disabling the latter also disables that protection. A zero partner-penalty weight does not remove partnership awareness: the base scorer still values a partner’s winning trick.

## Calibration and frozen selection

The protocol was written before results. Search used weights {0, 0.5, 1, 2}, two coordinate sweeps from each of the all-zero and all-one starts, fixed feature order, mean training score as the objective, and simplicity/lexicographic tie-breaking. No extra sweeps, new heuristic, or wider grid was added after observing outcomes.

Of 108 distinct configurations, the best five training configurations advanced to validation on seeds 52000–52511. The original and zero scaffold were validation controls. These 512 validation decks had 468 playable clusters and 3,744 rounds per variant. The selected candidate scored +0.873 in training and +1.023 in validation. Validation was selection data, not held-out evidence.

| Group | Selected weight (original = 1) |
|---|---:|
| Cash known winners on lead | 0.5 |
| Extra entry/control retention | 0.5 |
| Opponents-still-to-act estimate | 0 |
| Extra partner-overtake penalty | 0 |
| Long-suit establishment | 0 |
| Trump lead management | 0.5 |
| Known-ruff avoidance | 0.5 |
| Contract/scoring urgency | 2 |

Weights multiply existing bonuses/costs; threat weight scales the survival exponent, and urgency scales the departure from neutral urgency. The selection was saved and hashed **before** evaluation on the final set: training artifact SHA-256 `b07e04ec5b134c60c63074e7caefbbf492fe4b7c084558a7518c34358e7402af`. Source/protocol/binary hashes are recorded in the repository audit manifest.

## Fresh held-out evidence

Seeds 60000–62047: 2,048 previously unused base decks, of which 157 all-pass decks were excluded identically from all comparisons. Each comparison contains 1,891 independent deck clusters, 7,564 paired orientations, and 15,128 rounds. Across the three comparisons: 45,384 rounds and 2,359,968 legal, card-conserving plays.

The score margin is candidate partnership points minus opposing partnership points, averaged over partnership swaps and seat/dealer rotations. Confidence intervals cluster by base deck, not repeated rotations. The two candidate comparisons use Bonferroni-adjusted **97.5% two-sided intervals**; original versus Standard is descriptive at 95%.

| Comparison | Mean paired score margin | Interval |
|---|---:|---:|
| Calibrated − Standard | +0.942 | [0.698, 1.185], 97.5% |
| Calibrated − Original Advanced | +0.787 | [0.541, 1.033], 97.5% |
| Original Advanced − Standard | +0.029 | [−0.212, 0.271], 95% |

Both calibrated-policy intervals exclude zero. Original Advanced again has no demonstrated advantage over Standard. No tuning or re-selection followed these results. These are fixed-auction, single-round, zero-start-score results—not combined bidding/play, whole-match, or human win rates. The arithmetic gap between two policies’ scores against Standard is not necessarily their direct head-to-head margin, which is why the latter was measured separately.

| Comparison | Candidate contracts made | Reference contracts made | Candidate defenses won | Reference defenses won |
|---|---:|---:|---:|---:|
| Calibrated − Standard | 4600/7564 (60.8%) | 4052/7564 (53.6%) | 3512/7564 | 2964/7564 |
| Original Advanced − Standard | 4498/7564 (59.5%) | 4518/7564 (59.7%) | 3046/7564 | 3066/7564 |
| Calibrated − Original Advanced | 4990/7564 (66.0%) | 4500/7564 (59.5%) | 3064/7564 | 2574/7564 |

Paired wins/ties/losses were 2,884/3,074/1,606 (calibrated–Standard), 2,842/2,986/1,736 (calibrated–original), and 2,572/2,456/2,536 (original–Standard). These paired orientations are correlated within each deck and are not match-win counts.

Against Standard, the calibrated policy differed from Standard on 26,584 of 393,328 decisions (6.8%), mostly leads: 23,658 lead differences versus 2,926 following differences. Original Advanced differed on 68,996 decisions (17.5%), with 38,060 following differences. These are policy-specific trajectories, not matched-state causal comparisons.

## Tactical limitations: why this is not deployed

A separate post-selection audit reused small existing synthetic tactical fixtures. It was descriptive and did not select or change weights.

| Fixture | Original Advanced | Calibrated |
|---|---|---|
| Draw trump while retaining an entry | K♠ | K♠ |
| Preserve a secure partner winner | 2♣ | 2♣ |
| Avoid a known ruff risk on lead | A♦ | A♦ |
| Second-seat economy with higher cards still unseen | A♣ | 7♣ |
| Establish a long club suit | 3♣ | 2♦ |
| Protect vulnerable partner against known ruff risk | A♠ | 2♦ |

The last two are regressions against intended Advanced behaviors. The second-seat change illustrates conservation; the fixture alone cannot establish that it is always correct. **Better aggregate scores do not erase the tactical regressions.**

The next implementation should separate reliable public-threat protection from speculative survival estimates, then re-evaluate a revised policy on new training and held-out data. Simply zeroing all future-opponent reasoning would lose an explicit product requirement. Expert also uses Advanced in card and bidding rollouts; changing that shared policy would require fresh Expert and combined-game evaluation. Current Standard, Advanced, Expert, bidding, persistence, UI and timing remain unchanged.

## Verification and performance

- Experimental all-one scorer matched production Advanced at 1,612 diagnostic positions (seeds 70000–70031); every all-one decision throughout training, validation and held-out evaluation was also checked against production.
- All eight switches changed at least some diagnostic decisions. Legal play, hidden-hand permutation invariance, hand-order invariance, paired Standard self-play neutrality and repeated outcome reproducibility passed.
- Every experimental round checked 52 legal plays, no duplicated/lost cards and empty hands at completion.
- Existing native regressions passed: 6,656 Standard characterization comparisons, 572 inference/play positions, all 48 skill/declarer/trump combinations (2,496 plays), persistence/freezing/migration/stale results, and 7,168 frozen bidding recommendations plus 542 auction positions.
- Calibrated held-out decision p95 was 0.0096–0.0098 ms; maximum 0.108 ms on this arm64 development Mac with Xcode 27.0 / optimized Swift. No search or fallback is involved. These are not physical-iPhone guarantees.
- Production source hashes remained unchanged. No simulator UI suite was rerun because this work changes only offline tools/documentation, not app code or targets.
- `git diff --check` passed.

## Reproduce and inspect

From the repository root:

```sh
sh tools/ai/run.sh ablation-check
sh tools/ai/run.sh ablation-train > /tmp/advanced-training.json
sh tools/ai/run.sh ablation-heldout /tmp/advanced-training.json > /tmp/advanced-heldout.json
sh tools/ai/audit-tactics.sh /tmp/advanced-training.json
sh tools/ai/run.sh
```

For the exact frozen selection, pass `specs/011-mvp/advanced-ablation-training.json` to the held-out/tactical commands. Timings vary by machine; decisions and score outcomes are deterministic.

The fresh held-out seeds are now observed; they must not be reused as an untouched test after further tuning.

Files added: `tools/ai/AdvancedAblationPolicy.swift`, `AdvancedAblation.swift`, `AdvancedTacticAudit.swift`, `audit-tactics.sh`; protocol/results/audit JSON under `specs/011-mvp/advanced-ablation*`. Updated `tools/ai/main.swift`, `run.sh`, and relevant specification/task links. Earlier uncommitted app changes were preserved; no commit was created.

Raw evidence: [training, validation, all configurations and per-deal scores](advanced-ablation-training.json); [held-out outcomes, per-deal scores and performance](advanced-ablation-heldout.json).
