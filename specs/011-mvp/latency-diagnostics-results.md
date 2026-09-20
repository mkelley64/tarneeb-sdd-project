# Latency investigation results

September 19, 2026. **The 25.43-second historical outlier did not recur in this diagnostic profile, and its cause remains unknown.** Added offline wall-time/thread-CPU/checkpoint diagnostics and public-context replay without changing any app source or production policy. A clean short profile is not proof that rare stalls are fixed.

## What inspection established

Expert checks its elapsed budget at sample boundaries, throughout constrained sampling, at every rollout action and before its final choice. Sampling also has a 4,096-node cap. The deadline is cooperative: it cannot force progress while a thread/process is not scheduled. Work between checkpoints and fallback/return work are not independently preempted by a timer. The app uses detached work; the earlier offline benchmark was synchronous, so its elapsed-time maximum alone is not evidence of a UI-thread stall.

The old report retained aggregate timings and fallback counts, not per-decision contexts, timestamps, CPU time or reason codes. It cannot establish which decision produced the maximum, whether that maximum was one of the four fallbacks, or whether computation versus a host interruption caused it. Its records and strength findings remain unchanged.

## Instrumentation and controlled checks

`tools/ai/LatencyDiagnostics.swift` observes the existing cancellation callback; it does not duplicate or alter the search algorithm. It records elapsed time, current-thread CPU time, callback count, maximum interval between observations (including entry and return), CPU consumed during that interval, selected card, samples and fallback/cancellation flags. Instrumentation itself consumes time. Baseline calls record entry/return only; their single gap is not an internal search checkpoint interval.

Production does not expose exact fallback reason codes or phase labels. The report therefore distinguishes **observed cancellation**, **invalid/zero limits**, **fallback with elapsed budget exceeded**, and **fallback before elapsed budget**, without asserting an unobserved internal cause. Callback indices locate observations, not named sampler/rollout phases. Adding exact phase/reason telemetry would require a separately verified production diagnostic hook.

Controlled checks were isolated from normal performance statistics:

| Injected condition | Wall time | Thread CPU time | Observed outcome |
|---|---:|---:|---|
| 200 ms sleep inside a checkpoint | 205.05 ms | 0.047 ms | Legal fallback; elapsed budget exceeded |
| 200 ms thread-CPU work inside a checkpoint | 200.50 ms | 200.04 ms | Legal fallback; elapsed budget exceeded |
| Immediate cancellation | 0.010 ms | 0.010 ms | Cancellation flag, legal fallback |
| Cancellation requested during sampling/search | 0.050 ms | 0.050 ms | Cancellation flag, legal fallback |
| Zero budget | 0.006 ms | 0.006 ms | Advanced fallback |
| Malformed duplicated own-card input | 0.010 ms | 0.010 ms | Sampling rejected; fallback before budget |

These demonstrate distinguishable CPU/non-CPU delay signatures and safe return paths; they do **not** reproduce or explain the historical event. A large wall-minus-CPU gap cannot alone distinguish sleeping, suspension, contention and scheduling. Immediate/mid-search cancellation here uses the synchronous test callback; the existing native suite separately verifies detached cancellation and stale-result rejection.

## Fresh diagnostic profile

The [predeclared plan](latency-diagnostics.md) used decks **500000–500031**, four seat/dealer rotations, all seats Advanced bidding and Expert card play, and cycling public score contexts 0–0, 30–29 and 15–20. This exercises synthetic individual hands, not complete matches or comparative playing strength. There were **116 played hands and 12 all-pass deals**, without replacements.

Each of **6,032 decision positions** was evaluated twice with identical public inputs and seeds: ordinary and observed search, alternating execution order. All **12,064 selector calls** agreed on card, sample count and status. There were **zero fallbacks or cancellations**, no illegal choices, and all 6,032 applied plays conserved the cards through the existing service. Ordinary results drove the game trajectory.

| Metric | Median | p95 | p99 | Maximum |
|---|---:|---:|---:|---:|
| Ordinary elapsed time | 2.728 ms | 17.627 ms | 25.493 ms | 34.513 ms |
| Ordinary thread CPU | 2.723 ms | 17.581 ms | 25.430 ms | 34.512 ms |
| Observed elapsed time | 2.821 ms | 18.091 ms | 26.164 ms | 38.153 ms |
| Observed thread CPU | 2.815 ms | 18.068 ms | 26.122 ms | 31.694 ms |
| Paired observed-minus-ordinary elapsed time | 0.084 ms | 0.530 ms | 0.799 ms | 9.211 ms |
| Per-decision largest observation gap | 0.0168 ms | 0.0326 ms | 0.0455 ms | 1.5919 ms |

Paired time differences include host variability and cache/order effects as well as observation overhead; the largest difference is not an isolated estimate of instrumentation cost. These are optimized native arm64 Mac measurements, not simulator frame-time or physical-iPhone guarantees.

Five slowest cases are retained with own hand, public trick history, contract, score, actor and search seed. No opponents' hidden hands, deck order or deal seed are serialized into replay inputs. Any future profiled case at least 50 ms, fallback or mismatch is also retained by this command. This profiler does not automatically add telemetry to historical/full-match benchmark commands.

The slowest observed case, decision **5464**, took 38.153 ms wall / 31.694 ms CPU and chose Q-spades with eight samples. Replaying only its serialized public context took **25.571 ms wall / 25.570 ms CPU**, chose the same card, completed eight samples with the same 4,913 observations and did not fall back. Changed elapsed time with the same choice is expected; a saved context cannot reproduce a past host scheduling interruption.

## Verification and audit

- `latency-check` passed observer/ordinary seeded parity, public-context encode/decode, controlled wall/CPU delay signatures, immediate and mid-search cancellation, zero-budget and malformed-input fallback, and legality checks.
- Native regressions passed unchanged: 6,656 frozen Standard card comparisons; 7,168 Standard bid recommendations; 542 auctions; legality/constrained samples, all 48 skill/declarer/trump combinations, contract/score sensitivity, persistence/freezing/migration/restore, hidden-information fairness, cancellation/fallback/stale results, Expert compatibility, full-match and component-routing checks.
- Independently reconstructed all six reported distributions from individual records; verified counts, unique indices, all paired results, and replay schema fields. Replay of the slowest observed case passed.
- App source hashes match the prior confirmation audit. Previous confirmation results are retained unchanged. `git diff --check` passed. No commit was made; prior unrelated/uncommitted work was preserved.
- Xcode device discovery succeeded outside the sandbox and listed only simulators. **No physical iPhone was available, so on-device profiling remains undone.** No new UI/simulator suite was run for this offline-only addition.

Production limits remain eight samples, thirteen-trick rollouts and a 150 ms cooperative card budget. No skill, save, setting, scoring, legal-play, audio/animation timing or visual token changed. No new strength evaluation was run and the hybrid's all-three promotion criterion remains unmet.

Changed files: new `tools/ai/LatencyDiagnostics.swift`; command/build wiring in `tools/ai/main.swift` and `tools/ai/run.sh`; new `specs/011-mvp/latency-diagnostics*` plan/results/raw evidence/audit; and evidence/task updates in `ai-skill.md` and `tasks.md`.

## Reproduce

From `/Users/markkelley/tarneeb-sdd-project`, run sequentially:

```sh
sh tools/ai/run.sh
sh tools/ai/run.sh latency-check > /tmp/latency-check.json
sh tools/ai/run.sh latency-profile > /tmp/latency-profile.json
sh tools/ai/run.sh latency-replay /tmp/latency-profile.json 5464
```

The ordinary profile fixes its deck range and production limits in source. Retained witness indices can vary if deadlines alter the trajectory; choose an index actually present in that run's `witnesses` array. The original recorded profile contains index 5464. Search outcomes are seeded, but timing/deadline outcomes remain host-dependent.

Evidence: [ordinary profile and replay inputs](latency-diagnostics-profile.json), [controlled checks](latency-diagnostics-checks.json), [recorded replay](latency-diagnostics-replay.json), [source/result audit](latency-diagnostics-audit.json).

## Next boundary

The local investigation provides diagnostics and found no long delay **in this small observed workload**; it does not establish the original root cause or a hard response bound. Before performance acceptance, connect a physical iPhone and profile detached search/turn responsiveness under realistic load, with wall/CPU and cancellation/return telemetry. Exact phase and fallback-reason instrumentation, if needed, must preserve policy decisions and be verified separately. Retain rare outliers rather than rerunning them away. A powered fresh strength comparison against Advanced is subsequent work, not a substitute for this unresolved performance check.
