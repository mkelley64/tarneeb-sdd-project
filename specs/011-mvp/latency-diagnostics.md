# Card-search latency diagnostics — plan

September 19, 2026. Investigate the 25.43-second maximum from hybrid confirmation without changing production policies, reclassifying its four fallbacks, replacing its outcomes, or starting another strength evaluation.

## Design fixed before profiling

- Use the existing Expert cancellation callback as an offline observation point; leave all app source and search budgets unchanged. Record monotonic elapsed time, current-thread CPU time, callback count and maximum inter-check gap (including entry/return). The callback observes but never cancels ordinary profile decisions.
- Record selected card, completed samples, fallback/cancelled flags and elapsed-budget evidence. Production currently exposes no exact fallback reason or stage; report that limitation rather than inventing one. Record replayable own-hand/public trick/contract/score context and search seed for slow decisions, fallbacks and the five slowest decisions.
- Compare instrumented and ordinary search on identical public inputs and seeds. Alternate execution order to reduce warm-cache/order bias. Compare selections and sample counts when both complete normally; deadline-triggered differences are retained. Ordinary decisions drive the diagnostic game trajectory through existing legal-play/state-mutation services.
- Profile **32 fresh diagnostic decks 500000–500031, four seat/dealer rotations**, all four seats Expert card play and all seats Advanced bidding. All-pass deals are counted, not replaced. Cycle public score contexts (0–0, 30–29, 15–20) across deck/rotation combinations. These are synthetic diagnostic hands, not full matches or strength evidence.
- Keep production 8 samples / 13 tricks / 150 ms. Report baseline versus instrumented wall/CPU distributions, overhead, fallbacks, legal card conservation, and outlier checkpoint evidence. Instrumentation perturbs timing; neither distribution is a physical-iPhone latency guarantee.
- Separate controlled diagnostic cases: 200 ms sleep in a checkpoint (wall without comparable CPU), 200 ms thread-CPU work in a checkpoint (both grow), immediate and mid-search cancellation, zero budget, malformed sampling input, and normal seeded parity. These injected delays are never included in ordinary profile percentiles or presented as reproductions of the historical event.
- Add a public-context replay command. Preserve previous source/result hashes. Run native regressions and diagnostic assertions. Check whether a physical device is available; do not claim device profiling if unavailable.

## Interpretation boundary

A large elapsed/CPU gap can reveal non-CPU delay but cannot by itself distinguish sleep, suspension, contention or scheduling. Frequent checkpoint observations do not create a hard response deadline. A short clean diagnostic run cannot rule out rare stalls across millions of decisions. Exact historical attribution is impossible from aggregate-only data. Device responsiveness and a new powered strength protocol remain separate subsequent work; do not silently launch another long strength evaluation here.
