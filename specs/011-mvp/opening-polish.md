# Opening Flow Polish

Approved continuation of the September 2026 experience review. Supersedes the scrolling opening layout, small suit lanes, persistent inactive Deal footer, and crossfade-only reveal. Game rules, bidding order, dealer rotation, four sequential 13-card packets, and existing deal pacing remain unchanged.

## Acceptance Criteria

- OP-1: Opening, dealing, bidding, and trump selection use compact stations, the Arabic title, and the same readable two-row hand as live play. The hand and current decision fit together without scrolling on iPhone SE and iPhone 17 Pro.
- OP-2: Each packet starts at the center deck and moves independently to its recipient, counter-clockwise from the dealer's right. Backs appear only after arrival; the center count excludes delivered and moving packets. South's reveal turns each card around its vertical axis, switching faces at the edge-on midpoint. Reduce Motion substitutes brief fades without travel or rotation.
- OP-3: Only legal bid choices are available on South's turn; bidding never selects trump early. After South wins, four recognizable suit controls and an explicit Set command choose trump. Waiting, high-bid, all-pass redeal, and transition states are clear. Controls cannot submit twice or act out of turn.
- OP-4: New Game moves to the options menu. Sound/haptic preferences remain available. Optional packet landing and human confirmation feedback reuse the existing service and tokens. Deal and decision controls are disabled while inactive or showing confirmation.
- OP-5: Backgrounding settles an in-flight deal to the authoritative dealt state without stale animations; automated bidding and terminal transitions pause and resume safely. Reset cancels pending opening work. An all-pass redeal preserves existing rules.
- OP-6: Tests cover no-scroll geometry, normal/reduced-motion deal to bid to trump to live play, legal options, reset, background/resume, and all-pass redeal. Capture compact and modern phone screenshots. Physical-device sensory tuning and full VoiceOver/large-text coverage remain manual follow-ups.

## Architecture and Data

OpeningTableView is a presentation-only sibling of LiveTableView. It consumes GameState, pending dealt hands, DealAnimationPlayback, draft bindings, and guarded ContentView commands. It reuses ReadableCardFace and LiveHandLayout. No new persisted game fields or rule engine are introduced. A local frame preference maps the deck and station origins; each packet has a step-specific view identity. Card flip angle is interpolated as animatable view data so face changes happen at the midpoint, not when the target state changes.

ContentView owns a cancellable deal task and the existing automated bidding tasks. Lifecycle interruption cancels those tasks and reconciles the visible state with the authoritative presentation model. Preferences remain in their existing AppStorage keys. Numeric additions live in the token file; all colors reuse the existing palette.

## Scope Limits

No round-summary redesign, AI strategy changes, tablet-specific redesign, or new audio assets. Existing historical UI assertions for the superseded layout are not evidence for this replacement; new opening-flow UI tests exercise the actual controls.

## Verification

- All 156 unit tests passed, including the new compact-height layout budget check.
- All five opening UI cases passed on iPhone 17 Pro (iOS 26.2). All five also passed on iPhone SE (iOS 18.6) across the main run and focused reruns. The final alignment changes were included in a normal-flow rerun on both devices.
- All six live-play UI regressions passed on iPhone SE, including direct drag, double-tap, collection, reduced motion, lifecycle interruption, and reset.
- Inspected bidding and trump screenshots on both phone sizes. The hand and action area remain visible without scrolling.
- The initial all-pass test targeted a transient reduced-motion packet; it now checks durable dealer rotation and the next dealt hand. An iOS 18 alert-presentation race was fixed by waiting for stable button frames; the affected reset test then passed.
- Remaining checks: full VoiceOver/large-text and tablet layouts, physical-device audio/haptic tuning, a complete match, and frame-by-frame motion/performance verification. The historical UI suite for superseded opening layouts was not run.

Debug preview: `TARNEEB_OPENING_FIXTURE=1` uses a deterministic mixed hand while retaining the existing configurable dealer and simulated bids. This override is compiled only in Debug.
