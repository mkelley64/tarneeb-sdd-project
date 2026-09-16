# Restrained Visual Finishing Pass

September 16, 2026. Applies to the current readable-card experience; supersedes only the surface and typography treatments described here.

## Acceptance Criteria

- VF-1: Opening, live play, and results use a consistent, subtle felt surface and stationary woven detail. Opening/live play add a fine inset rim; results omit rim lines behind the score rows. Preserve the existing table bounds and card/deal anchors.
- VF-2: Scores emphasize numeric values over team labels, retain monospaced digits and the match goal, and preserve spoken score labels. Header elements must remain visible and non-overlapping on the compact and large iPhone layouts.
- VF-3: Inactive player details and result metric labels use secondary text; active/winning emphasis remains amber. Score separators use an explicit shared token treatment.
- VF-4: Decoration must not intercept card dragging, selection, commands, or accessibility navigation. Keep card faces, touch targets, button finish, gameplay, sounds, and approved animation timings unchanged, including Reduce Motion behavior.

## Implementation

`TableFeltSurface` is shared by opening, live, and result views. Its deterministic Canvas weave is clipped to the ellipse; the entire surface is non-interactive and accessibility-hidden. Colors come from existing `GameColorToken` values; finish dimensions/opacities are specified in design-tokens.md and mirrored by `TableFinishToken`. No persisted state or domain model changes.

Score labels and values remain a single accessible Text element for each team. Existing layout constraints, accessibility identifiers, and result presentation transitions remain intact. The weave has no timer or randomized state, so view updates cannot change its pattern.

## Edge Cases and Verification

- Compact screens: inspect opening, selected hand, bidding/trump controls, and results screenshots; verify scores do not collide with toolbar controls.
- Negative and multi-digit scores: preserve explicit minus signs, single-line scaling, and monospaced digits. Result UI coverage includes negative scores and both match winners.
- Reduce Motion: surface is static; existing reduced-motion opening/trick tests must pass without altered timing.
- Hit testing: existing edge-button taps and valid/invalid card drags must remain functional over the decoration.
- Unit tests constrain texture density and low opacity. UI tests assert preserved score labels and bounds, complete tricks, and exercise results. Screenshots provide visual review rather than relying on token assertions as proof of appearance.
- Physical-device impression and GPU frame-time profiling are separate from simulator functional checks; no performance improvement is claimed.

## Verification Record

- `tarneeb-visual-finish-tests.xcresult`: 175 unit tests and 18 opening/live/results UI tests pass on iPhone SE (3rd generation, iOS 18.6) and iPhone 17 Pro (iOS 26.2), 386 passing runs with no failures or skips.
- Screenshot review confirmed preserved score labels and spacing, readable selected cards, unobstructed bidding, and subtle felt detail on both sizes. Review prompted removal of the results rim to avoid lines crossing behind score rows.
- `tarneeb-visual-finish-results.xcresult`: all four result UI tests pass again on both devices after that refinement, eight passing runs. Final results screenshots were inspected on both sizes.
- Result bundles and exported screenshots are under `/private/tmp/`. Signed device build succeeds and the final app is installed on the attached iPhone. Xcode still reports the pre-existing supported-orientations warning.
