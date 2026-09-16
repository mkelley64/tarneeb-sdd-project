# Live Trick Polish

The subsequent [Opening Flow Polish](opening-polish.md) extends the readable hand and presentation language to dealing, bidding, and trump selection. The original scope statements below describe the first live-play slice.

Approved direction: September 2026 user request to implement a redesigned hand and one polished trick. This slice applies the experience review to live trick play, including repeated tricks and hand completion. Opening deal and bidding remain unchanged. This document supersedes the half-screen table, suit-lane hand, shared small card size, and persistent Deal footer constraints only in these phases.

## Acceptance Criteria

- TP-1: Live play shows a compact scoreboard/contract, opponent stations, a readable current trick, and a larger two-row hand on supported portrait phones without scrolling. Indices remain visible and card-selection targets are at least 44 points wide. Long hands do not change height as cards are played.
- TP-2: A legal card can be selected with one tap and lifted visibly. Double-tapping a legal card plays it directly, whether selected or not; dragging it onto the table also plays it. There is no separate Play button. The accessible Play action remains available. Illegal/out-of-turn input and repeated taps during motion cannot mutate game state.
- TP-3: Each card moves from its own measured hand/station origin to its corresponding table slot. Its source stays stable until landing; the next play waits for the preceding landing. Played cards do not obscure each other's indices.
- TP-4: After four cards land, identify the winner, hold the result, then collect all four cards toward that winner. Visible trick counts update on collection completion, exactly once. The next trick starts afterward.
- TP-5: Selection, landing, and collection have distinct optional sound/haptic feedback synchronized with the interaction. Sound respects silent mode and other audio. Preferences persist.
- TP-6: Reduce Motion replaces travel with brief fades. Backgrounding, confirmation dialogs, and reset cannot leave orphaned motion or continue accepting input; foreground/Keep Playing resumes from a consistent state. VoiceOver labels describe gameplay, not test internals.
- TP-7: Unit tests cover hand geometry, non-overlapping trick slots, motion sequencing, and card conservation. UI tests exercise selection, play, winner collection, reset, and reduced-motion behavior. Visual checks cover compact and modern phones.
- TP-8: A persistent "Your tricks" counter below the South hand shows only tricks won by South in the current hand, distinct from team match score and contract progress. It starts at zero and updates after collection, using the same completed-trick state as opponent counters. It remains visible during play and hand completion and exposes its count to VoiceOver.
- TP-9: Dragging a legal card starts on finger movement without a long-press delay. The card follows the finger; releasing over the table plays it and continues its landing animation from the release position. Releasing outside the table or cancelling the gesture restores the hand without playing. Tap selection, double-tap play, and legality/turn guards remain intact.
- TP-10: When South has exactly one card left, play it automatically on South's legal turn using the normal card flight, landing feedback, and serialized trick sequence. Do not auto-play from a multi-card hand, even if only one card is legal. Wait until previous collection completes; pause for background/confirmation and resume without duplicating the play or score.

## Architecture

Keep existing trick rules and scoring. ContentView owns the existing game state and serialized asynchronous turn execution. A small live-table view renders measured anchors, readable card faces, hand selection, and card-flight/collection state. Visual state is committed at landing, and completed tricks clear only after collection. A feedback service owns short audio and haptics, independent of view redraws. Numeric styling lives in DesignTokens.swift; colors reuse the token specification.

## Non-goals

No AI changes, new deal animation, bidding redesign, background music, monetization, multiplayer, or new game rules. Full-match celebration and a separate round-summary redesign remain later work.

## Implementation and Verification

- TP-1/TP-2: LiveTableView and ReadableCardFace provide a fixed-height two-row hand, larger indices, stable overlap order, single-tap selection lift, double-tap play, drag, and accessible Play actions. Exclusive tap recognition separates selection from play. Card backgrounds remain opaque when unavailable.
- TP-3/TP-4: Measured hand/station and slot anchors drive independent, identity-keyed flights. ContentView serializes arrivals, commits the visible state at landing, holds the winner, then collects before updating visible trick counts.
- TP-5/TP-6: TableFeedback supplies short paper-like effects and native haptics. The game-options menu persists independent preferences. Reduce Motion uses fades; lifecycle and confirmation boundaries cancel/settle pending motion and resume safely.
- TP-7: Added three unit tests covering hand geometry, disjoint trick slots, and held-state/card-conservation/collection behavior. Added five live UI tests covering selection and a complete trick, reduced motion, mixed-suit drag/follow-suit enforcement, background/resume, and confirmation/reset.
- Verification devices: iPhone SE (3rd generation), iOS 18.6; iPhone 17 Pro, iOS 26.2. All 155 unit tests passed. All five live UI cases passed on both devices across focused runs; the original opening-screen UI regression also passed on iPhone 17 Pro.
- UI test synchronization accounts for native sheet presentation on iOS 18 and popover-style outside-tap cancellation on iOS 26. Failed early runs were investigated using accessibility snapshots and recordings, then the affected cases were rerun successfully.
- Double-tap interaction update: all five live UI tests passed on iPhone 17 Pro (iOS 26.2); selection/double-tap/collection and mixed-suit drag/follow-suit tests also passed on iPhone SE (iOS 18.6). Tests assert that single-tap preserves the hand, selected and unselected cards support double-tap play, illegal double-taps preserve state, and no Play button exists. Unit tests were not rerun for this gesture-only update.
- Direct-drag fix: a 0.05-second press-and-drag test reproduced the old long-press implementation's failure. Replaced system drag-and-drop with mutually exclusive direct-drag and tap gestures, a finger-tracking overlay, table-bound release validation, and a retained release origin for landing. All six live UI tests passed on iPhone 17 Pro; quick drag and outside-table release tests also passed on iPhone SE. Unit tests were not rerun for this gesture-only fix.
- Automatic last card (TP-10): the turn scheduler uses a legal, exactly-one-card rule and the existing guarded South play/animation path. Added a unit test for multi-card, out-of-turn, pending-collection, empty-hand, and duplicate-play cases, plus UI tests for last-card play after collection and reduced-motion/background resume. All 157 unit tests and eight live UI cases passed on iPhone 17 Pro; both new UI cases passed on iPhone SE with the final cancellation guard. Debug fixtures `last-one` and `last-two` reach these states through real rules, not fabricated hands.
- Remaining manual QA: physical-device audio volume/haptic intensity and a full VoiceOver/full-match playthrough. The entire historical UI test suite was not run. No frame-rate or performance claim is made.

Debug-only preview fixtures are available through `TARNEEB_LIVE_FIXTURE=balanced` (mixed suits) or `1` (13 spades). They use the real deal, bidding, and trick rules and are not included in Release behavior. `TARNEEB_REDUCE_MOTION=1` exercises the short-transition path for tests; system Reduce Motion remains authoritative for normal use.
