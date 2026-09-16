# Full-Match Polish Pass

September 16, 2026 continuation of the experience review. Preserve the device-approved card motion and sound pacing. No scoring, AI, deal-order, or match-target rule changes.

## Acceptance Criteria

- FM-1: Opening/bidding, live play, round results, and match results state the existing "First to 31" goal beside the score or round heading. Keep the existing layout height, colors, and primary controls.
- FM-2: The blue circular dealer badge remains visible through bidding and trick play, including when South's cards replace the opening station. Rotation changes the badge to the next dealer, without changing player borders. Non-South badges remain beside station names; South has a compact "You" cue during bidding and a badge beside the personal trick tally during play.
- FM-3: South's live contract and play status use "You bid" and "You play", consistent with the direct player-facing language elsewhere. Other players retain their seat names.
- FM-4: Exercise a complete match through actual UI actions: opening deal, bid, trump, all tricks, round result, next deal, match win, relaunch, and reset. Exercise tap selection, double-tap, drag, recall, background/resume, and the automatic final card. Also complete a mixed-suit hand through results. Check compact and modern phone layouts.
- FM-5: Result commands respond across their entire visible button, not just their text. Verify Next Hand near the left edge and New Game near the right edge, with the same score-preservation/reset rules.

## Implementation and Edge Cases

MatchScoreHeading reuses the score labels and GameScore.winningScore; it does not store duplicate totals. The goal is a secondary caption within the existing 36-point header. RoundResultView shows the same goal under its round/match heading.

CompactDealerBadge reuses existing dealer color tokens. OpeningTableView exposes South's dealer cue after the expanded hand replaces the South station. LiveTableView renders the marker for the current game.dealerSeat, either at the opponent station or beside the player's own trick count. No extra persisted state is needed.

Do not change the accepted timings, sounds, haptics, or reduce-motion path. Negative scores and larger score totals must not obscure the match goal or controls. Badge changes follow authoritative dealer rotation, not a separately incremented presentation value.

Result button labels contain their own full-width frame, background, and rectangular content shape. This keeps the rendered bounds and hit region aligned without changing the button's appearance.

## Tests and Limitations

The Debug-only opening fixture accepts "sweep" to provide a deterministic unshuffled deck while still starting before Deal. It does not inject a completed round, advance tricks, or set scores. Two legally played sweep hands at bid 7 earn 16 points each under the existing rules. The finished saved match is then restored with the fixture removed.

The mixed-suit walkthrough uses the existing balanced opening fixture and only taps enabled cards. It checks all 13 cards are played and the result and final trick are reachable. Existing result fixtures separately cover missed contracts, negative totals, and an opponent match win.

Screenshots verify goal/badge placement and control visibility. Automated walkthroughs are not substitutes for a human judging strategy, fatigue, sensory repetition, or accessibility on a physical phone. Full VoiceOver, large-text, tablet, and frame-time audits remain separate.

## Verification

FM-1 through FM-5 passed in the final full-match UI walkthrough on iPhone 17 Pro (iOS 26.2) and iPhone SE 3 (iOS 18.6). All four result-screen tests also passed on each device after the hit-area fix. The preceding broader run passed 173 unit tests and the mixed-suit hand on each device. Screenshot inspection confirmed the goal caption, dealer cues, hand, and result commands fit both phone sizes. See `docs/reviews/2026-09-16-full-match-review.md` for the initial failures, fixes, and validation limits.
