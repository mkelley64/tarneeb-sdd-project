# Contract Feedback, Card Identity, and Circular Felt

## Acceptance Criteria

- CI-1: Show declaring-team trick progress within the existing contract row, with a subtle progress bar. Highlight one trick away and acknowledge a secured contract with a checkmark, without pausing play or adding sounds/haptics.
- CI-2: Count resolved tricks, including the pending winner after the final card lands, exactly once. Keep the numeric count visible beside concise milestone text and preserve full declaring-team/numeric accessibility. Handle either partnership, targets 7 through 13, and unattainable contracts. Show the missed state instead of one-away when insufficient tricks remain.
- CI-3: Use the new bundled geometric card back consistently for the undealt deck, dealing packets, card flips, and hidden opponent hands. Preserve face readability and hidden card semantics; supply all three display scales.
- CI-4: Keep the opening and live felt circular and center the deck/title/trick layout on it. Preserve station and hand positions, full rectangular drag target, touch targets, card slot separation, and existing animation timing. Results are unchanged.
- CI-5: Reduce Motion removes progress/checkmark animation while preserving state feedback. Background/restore derives progress from game state without a replayed celebration or new persisted fields.

## Design

ContractProgressPresentation is a pure projection of PostBiddingSummary and TrickPlayState.resolvedTricks. The fraction saturates at 1; trick counts continue beyond the target. Milestones are building, oneAway, secured, and missed. No timers, transient event flags, new save fields, or gameplay changes are needed. Existing landing/collection feedback remains untouched.

CircularTableGeometry computes a circle within the current inset table rectangle; both opening and live play use it. The live card slots retain their offsets around its center and existing flight anchors follow the new slot positions automatically. Card drags continue accepting the full table rectangle. On minimum-height layouts, card corners may extend beyond the decorative felt; they must remain inside the table hit area and not overlap stations or the hand.

The card back is generated original artwork with source/provenance retained under assets/. Asset catalog name and hidden-card metadata remain stable. Colors and progress/surface metrics are defined in design-tokens.md.

## Verification

Unit tests cover milestone boundaries, both partnerships/all seats, impossible contracts, pending-to-collected equality, target 13, saturated progress, circular geometry, slot bounds, and 1x/2x/3x bitmap dimensions. UI tests exercise a six-trick contract through its seventh and eighth wins with normal and reduced motion; verify visible milestone labels, accessible numeric progress, bounds, and continued interaction. Existing opening, deal, drag, selection, automatic-final-card, and full-match tests protect gameplay. Review screenshots on compact and large phones for circles, tiny card-back clarity, milestone layout, and unobstructed controls.

September 16, 2026 verification:

- `/private/tmp/tarneeb-contract-identity-verified.xcresult`: 178 unit tests plus 13 UI tests pass on iPhone SE (iOS 18.6) and iPhone 17 Pro (iOS 26.2), 382 passing runs, no failures/skips. Includes two complete hands, match win, recall/background/restore, reset, deal/trump flow, card dragging, and both milestone motion modes.
- `/private/tmp/tarneeb-contract-labels-final.xcresult`: all 178 unit tests and both milestone UI tests pass again on both devices after retaining visible numeric counts alongside milestone labels, 360 passing runs.
- Screenshots reviewed on both sizes: opening deck, readable hand, circular felt, opponent card-back thumbnails, one-away and secured states. No card-face/touch-target changes were needed. Existing animation timing tests remain green.
- Signed iPhone build succeeds with the pre-existing supported-orientations warning. Installation could not complete because the paired iPhone is unavailable; a fresh non-persisting simulator preview is provided instead.
