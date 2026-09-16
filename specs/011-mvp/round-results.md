# Round Results and Match Wins

Approved September 2026 continuation of the experience review. This supersedes timed automatic advancement after a completed hand. Existing scoring rules, the 31-point match target, and dealer rotation are unchanged.

## Acceptance Criteria

- RR-1: After the final trick is collected and scored, show a persistent, readable round result with Contract made/missed, declaring partnership, bid, trump, and tricks taken. Special bids of 13 and all-trick sweeps receive an accurate short explanation.
- RR-2: Show both partnerships' previous totals, signed round changes, and new totals from the authoritative scored result. Viewing, backgrounding, or returning to the result cannot score again.
- RR-3: Non-winning rounds wait for Next Hand. One press starts the next deal with preserved totals and the normal counter-clockwise dealer rotation. Repeated input cannot start multiple hands.
- RR-4: At the winning threshold, show which partnership won, final totals, and New Game instead of Next Hand. A player-side win gets a restrained trophy entrance and short success phrase; an opponent win gets a neutral result. New Game resets the match and returns to the opening deck.
- RR-5: Result audio/haptics are optional and played once per completed round. Existing sound, haptic, silent-mode, and background-audio behavior is retained. Reduce Motion uses a short fade with no trophy scaling. No looping celebration.
- RR-6: Results and commands fit on supported portrait phones, have useful accessible labels, and remain available after interruption. Tests cover made/missed contracts, both declaring teams, special scoring, continuation, match completion, reset, reduced motion, and score stability.

## Architecture and Data

RoundResultView is a presentation-only screen rendered by ContentView after handComplete. RoundResultPresentation derives labels and previous scores from RoundScoreResult and GameScore; it does not recompute awards. ContentView replaces the automatic round timer with a guarded Next Hand command and records the last announced round number for once-only feedback. No saved-game schema changes. Result styling extends the token spec and reuses existing colors.

## Edge Cases and Scope

Negative previous/current scores and zero deltas remain visible. Existing winner precedence is unchanged if both teams reach the threshold. Interrupted collection settles through the existing authoritative state and exposes the result once scoring finishes. No rematch auto-start, sharing, leaderboard, opponent AI changes, or persistent match history. Physical-device audio/haptic tuning, full VoiceOver, large-text, and tablet validation remain separate manual checks.

## Verification (September 15, 2026)

- RR-1/RR-2: Model tests cover all six scoring outcomes for either declaring partnership, signed changes, negative previous totals, and both match winners. The full 159-test unit suite passes.
- RR-2/RR-3: UI tests verify persistent results beyond the old automatic-advance delay, preserved totals after Next Hand, return to bidding, and unchanged negative scores after backgrounding.
- RR-4: UI tests verify both winning partnerships, absence of Next Hand after a win, and New Game returning to a 52-card deck with zero totals.
- RR-5/RR-6: Four result UI scenarios pass on iPhone 17 Pro (iOS 26.2) and iPhone SE 3 (iOS 18.6), covering normal and reduced-motion settings. Screenshots verify visible text and commands without scrolling. The two last-card autoplay UI regression tests also pass on iPhone 17 Pro.
- Feedback preferences, once-per-round dispatch guards, and the reduced-motion animation branch were code-reviewed. Audible quality, physical haptics, full VoiceOver, large text, tablet layout, and animation frame-time measurements are not established by these automated checks.
