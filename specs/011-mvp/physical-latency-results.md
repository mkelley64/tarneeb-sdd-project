# Physical iPhone opening-search results

September 20, 2026. Device registration and development signing succeeded for the user-selected team `3QM6PM3F9J`. The isolated Release diagnostic build ran successfully on the connected **iPhone 15 Pro, iOS 27.0**. No production AI policy changed and the previous 25.43-second Mac event remains unexplained.

## Frozen diagnostic scope

The [plan](physical-latency-plan.md) fixed 64 diagnostic decks 520000–520063 and four own-hand positions per deck, cycling trump, contracts 7–13 and public scores 0–0 / 30–29. Every position is an opening lead with a 13-card hand. This intentionally emphasizes larger root searches, not representative full-hand/game latency or playing strength.

The 256 positions were each evaluated through the production detached entry point and an observed detached worker, alternating order. Search seeds use only own cards and public context. Production limits stayed at eight samples, thirteen tricks and a 150 ms cooperative budget. All **512 calls returned legal cards, with zero fallbacks, zero cancellations and zero selection/sample/status mismatches**.

| Measurement | Median | p95 | p99 | Maximum |
|---|---:|---:|---:|---:|
| Production detached request-to-main-actor-return | 28.252 ms | 30.136 ms | 31.138 ms | 64.088 ms |
| Observed worker elapsed time | 28.458 ms | 30.279 ms | 31.410 ms | 35.492 ms |
| Observed worker thread CPU | 28.445 ms | 30.277 ms | 31.408 ms | 35.468 ms |
| Largest observation gap per decision | 0.0230 ms | 0.0542 ms | 0.0695 ms | 0.1031 ms |

These are different boundaries: the production measurement includes detached scheduling and return to the main actor; the observed worker measurement does not. They are separate executions, so subtracting them does not isolate scheduling cost. Observation gaps include entry and return; observer overhead and instrumentation differences prevent direct comparison with earlier Mac profiles. The largest production measurement was below the configured budget in this run, but this is **not a hard response-time guarantee**.

## Responsiveness and cancellation

A main-actor task requested a tick every 10 ms. Actual idle intervals (50 ticks) were median 11.122 ms, p95 11.193 ms, maximum 11.658 ms. During the searches (1,317 ticks), intervals were median 11.097 ms, p95 11.273 ms, maximum 14.153 ms. The main actor continued servicing the heartbeat; these intervals are **not display frame times, touch latency or full-game animation measurements**. Thermal state at the end was nominal (raw value 0); there was no sustained thermal/load study.

All three selected on-device tests passed:

- `testPhysicalExpertLatency` — 15.187 seconds; legality, observer parity and main-actor progress.
- `testExpertDetachedCancellationPropagates` — card-search cancellation.
- `testBiddingDetachedCancellation` — bidding-search cancellation.

The entire unit/UI suite was not rerun. The native full suite passed in the preceding offline investigation; this turn added a test-only device diagnostic. Simulator execution explicitly skips the new physical-only test.

## Signing, installation and preservation

The first registration build referenced a missing newly generated provisioning profile. A fresh derived-data retry succeeded. Signing used command-line overrides, not edits to the project's saved team settings. App identifier `com.mkelley.latencyprobe.Tarneeb` keeps the installed production app's data container separate. A diagnostic app was installed and remains on the phone; no original Tarneeb save was replaced or removed.

Production hashes remain unchanged:

- `Tarneeb/AISkill.swift`: `4963c6ab6f99fa1a01c876c470b83fd3d16479ffe07b30e99de289c351c54f96`
- `Tarneeb/AIBidding.swift`: `5c51ea4c13675777fc3d174b10202b2f5c9f26ee3a651e1e6b4d8d4b04732f01`
- `Tarneeb/DomainModels.swift`: `92edb116262597cac6a876251fb92f2b497624c29680cfc904e42b9eec5faa4a`

Changed files: `TarneebTests/TarneebTests.swift` (device-only diagnostic), this results document, `physical-latency-plan.md`, raw `physical-latency-results.json`, and evidence/task updates in `ai-skill.md` and `tasks.md`. Rules, policies, settings, persistence, visuals and approved animation/audio timings were not edited. Existing unrelated work was preserved; no commit was made. `git diff --check` passed.

## Reproduction

Use a registered, trusted physical device and valid team signing credentials. Set the destination to the actual connected device identifier, and choose an unused result-bundle path:

```sh
xcodebuild test -project Tarneeb.xcodeproj -scheme Tarneeb -configuration Release \
  -destination 'id=YOUR_CONNECTED_DEVICE_ID' \
  -derivedDataPath /tmp/tarneeb-device-latency-replay \
  -resultBundlePath /tmp/tarneeb-device-latency-replay.xcresult \
  CODE_SIGN_IDENTITY='Apple Development' DEVELOPMENT_TEAM=3QM6PM3F9J \
  'PRODUCT_BUNDLE_IDENTIFIER=com.mkelley.latencyprobe.$(PRODUCT_NAME:rfc1034identifier)' \
  -allowProvisioningUpdates \
  -only-testing:TarneebTests/TarneebTests/testPhysicalExpertLatency \
  -only-testing:TarneebTests/TarneebTests/testExpertDetachedCancellationPropagates \
  -only-testing:TarneebTests/TarneebTests/testBiddingDetachedCancellation
```

The full report is emitted as `PHYSICAL_LATENCY_JSON` in the test log and retained as an XCTest attachment named `physical-opening-latency.json`. [Raw measurements and public inputs](physical-latency-results.json) contain all 256 records. Original result bundle: `/tmp/tarneeb-physical-latency-20260920.xcresult`.

## Remaining work

This first device pass found no long stall and showed main-actor progress during detached opening searches. It does not explain the historical Mac outlier or establish reliable tail latency across millions of turns. Before broad performance acceptance, cover full-game play, animation/touch responsiveness, sustained thermal load, and background/resume cancellation/stale-result behavior on the device. Keep those checks separate from a newly preregistered, adequately powered comparison against Advanced. The hybrid's strength-promotion gate remains unmet; no policy was promoted.
