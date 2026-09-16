# Full-Match Experience Review

## Scope

Review the current phone experience as a continuous game, preserving the pacing approved on the physical iPhone. This is a simulator-driven UI walkthrough plus screenshot and code inspection, not a human sensory or strategy evaluation.

## Findings and Changes

1. Result commands did not respond across their visible blue area. A focused test tapping Next Hand near its left edge failed before the fix. Moved the full-width styling and rectangular hit shape inside the button label; the complete-match test now taps Next Hand near the left edge and New Game near the right edge.
2. Match goal missing from the current screens. Scores were visible, but the 31-point target existed only in the old, inactive layout. Added a quiet "First to 31" caption to opening/live score headings and round/match result headings without increasing their height.
3. Dealer indication lost at phase changes. South's badge disappeared when the hand replaced the station; live stations did not render any dealer badge. Restored the existing blue D marker in the active layouts. A follow-up test caught the parent status identifier overriding South's badge identifier; placing that identifier on the status text fixes the accessibility grouping.
4. Player naming inconsistent. Live contract and in-flight text called the human "South" while actions said "You". Changed those two player-facing phrases to "You bid" and "You play".

## Walkthrough

The initial normal-motion UI walkthrough completed two full hands (26 tricks), reached a 32-point match win, restored the finished match from disk, and reset scores and deck through New Game. It exercised selection, double-tap, dragging, recall, background/resume, and the automatic last card. This uses a deterministic sweep deal to ensure the match finishes; scores and results are earned through the real UI/domain pipeline, not injected fixtures.

A separate mixed-suit hand and the missed-contract/opponent-win result cases complement this happy path.

## Verification

- iPhone 17 Pro / iOS 26.2 and iPhone SE 3 / iOS 18.6: all 173 unit tests and the mixed-suit full-hand walkthrough passed on each device in the broader run. That run exposed the result-button and dealer-accessibility issues described above; it was not an all-green run.
- After those fixes, the full two-hand match and all four round-result UI tests passed on both devices: ten successful final UI runs, no failures or skips. This includes left-edge Next Hand and right-edge New Game taps, persistent scores, West-to-South dealer rotation, final-card automation, final-score restoration, and reset.
- Inspected screenshots of compact bidding/trump, mixed-suit legal/illegal cards, South's dealer cue, selected cards, contract results, negative totals, and both match-win outcomes. Match goal and dealer markers fit without overlapping the hand or controls. The existing approved motion and sound values are unchanged.
- Signed iPhone build succeeded and installed on the connected iPhone 15 Pro. Remote launch was blocked because the phone was locked. Unlock and open Tarneeb; the normal saved game was not reset.
- Final UI result bundle: `/private/tmp/tarneeb-full-match-review-verified.xcresult`. Broader unit/mixed-hand run: `/private/tmp/tarneeb-full-match-review-final.xcresult`. Focused pre-fix hit-area reproduction: `/private/tmp/tarneeb-result-hit-area-check.xcresult`.
- The rest of the historical UI suite was not rerun for this pass. The final rerun changes only UI hit geometry and accessibility identifier placement relative to the unit/mixed-hand run.

## Remaining Checks

- A human full-match playtest on the phone is still needed to judge challenge, hesitation, fatigue, and repeated sound/haptic feedback. Preserve the user's accepted audio/pacing unless that playtest identifies a new issue.
- VoiceOver, large text, tablet layouts, and frame-by-frame/performance measurements remain outside this pass.
- This review does not establish that a new player can understand bidding without explanation; that needs observation with someone unfamiliar with Tarneeb.
