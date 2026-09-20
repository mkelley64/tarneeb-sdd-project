# Physical opening-search diagnostics

September 20, 2026. Isolated bundle `com.mkelley.latencyprobe.Tarneeb`, selected team `3QM6PM3F9J`, Release build, connected iPhone 15 Pro. Production policies and original app data remain unchanged. This is a focused first device pass, not full-match strength or animation/frame-time acceptance.

Freeze 64 diagnostic decks 520000–520063 × four own-hand seats = 256 opening positions. Cycle trump, contract 7–13, and score 0–0 / 30–29. Every position has a full 13-card own hand, no prior play and the acting seat as declarer. These intentionally exercise larger root searches rather than representative complete-hand play. Search seeds derive only from observable inputs.

Compare the production detached entry point against an observed detached worker, alternating order. Preserve 8 samples / 13 tricks / 150 ms. Record production request-to-main-actor-return time, observed worker elapsed/CPU time and checkpoint gaps, selections and fallbacks. Assert legality and completed-search parity, not arbitrary timing thresholds. Retain all fallback/deadline outcomes. Capture all public opening inputs for replay.

Measure a 10 ms main-actor heartbeat for 50 idle ticks and during searches; report actual intervals, not display frame rates. Verify existing detached bid/card cancellation tests on device. This is no substitute for sustained thermal, background/resume, animation or touch-latency testing. Do not attribute the historical 25.43-second Mac event from these measurements. Report signing/installation/device blockers honestly.
