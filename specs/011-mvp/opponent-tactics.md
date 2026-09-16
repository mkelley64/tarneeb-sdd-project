# Opponent Tactics

The subsequent [Continued Play](continued-play.md) slice refines opening leads and third-seat partner protection using public history. The policy below records the initial tactical slice.

Approved September 2026 follow-up to experience-review finding 10. This is a bounded tactical improvement for all three simulated seats, including South's partner North. Bidding, legal moves, scoring, turn order, and presentation timing are unchanged.

## Acceptance Criteria

- AI-1: Simulated players select only from the rule engine's legal cards and still follow the led suit when possible. Human turns, completed tricks, and inactive game phases remain untouched.
- AI-2: When a partner currently wins the trick, conserve strength by selecting the cheapest legal card. Prefer a non-trump discard when void in the led suit; do not spend trump merely to overtake a partner.
- AI-3: When an opponent currently wins, play the lowest-ranked legal card that would take the lead. Use the existing winner rules, so an off-suit high card cannot be mistaken for a winner.
- AI-4: When void in the led suit, use the lowest winning trump or overtrump against an opponent. If no card can win, discard the lowest non-trump first, or the lowest trump if only trumps are legal.
- AI-5: Decisions are deterministic and independent of card-array order or other players' hidden hands. The selector accepts only the acting seat, legal options, current public trick, and trump suit. Existing rank/suit ordering breaks ties.
- AI-6: The normal play service applies exactly one selected card and preserves all 52 cards across hands and tricks. Full-hand tests exercise every declarer and trump suit; existing UI regressions still cover play, collection, and round completion.

## Architecture

AutomatedCardSelector is a pure policy beside TrickPlayRules. TrickPlayService obtains legal moves, passes only those moves and public trick information into the policy, and applies its answer through the existing validated play path. Candidate cards are evaluated using TrickPlayRules.winner, keeping trump and rank comparisons in one place. No state, persistence, difficulty setting, or UI changes are required.

## Limits and Edge Cases

An empty legal set returns no selection. A singleton is forced. Leading retains the existing low non-trump preference. Partner protection applies even with an opponent still to act; this intentionally conservative policy does not claim that the trick is secured. No hidden-card inference, future-trick search, contract-aware endgame planning, bidding changes, or difficulty levels are included. Later evaluation may refine third-seat play and opening leads.

## Test Strategy

Use table-driven decision cases for partners in either partnership, follow-suit wins, trump leads, trumping, overtrumping, impossible wins, forced choices, and stable ordering. Service integration tests verify legal filtering, hidden-hand independence, one-card mutation, and unchanged human/collection boundaries. Exercise complete deterministic hands across all declarers and trump suits, checking card conservation and trick completion. Run the unit suite and focused live/opening/result UI regressions. Passing tactical cases establish these decisions, not a measured win-rate or difficulty improvement.

## Verification (September 15, 2026)

- AI-1/AI-5: Service tests confirm mandatory follow-suit even when trump could win, unchanged choices after swapping hidden hands, and no mutation during human turns or collection boundaries.
- AI-2/AI-3/AI-4/AI-5: Sixteen decision fixtures pass in forward and reversed option order, with an additional equal-rank tie check. Coverage includes both partnerships, partner trump conservation, economical wins, overtrumping, losing discards, empty options, and a forced card.
- AI-6: Sixteen full hands (every declarer and trump combination) finish all 13 tricks. Every step preserves the canonical 52-card set; each play removes exactly one legal card.
- Final iPhone 17 Pro / iOS 26.2 run: 163 unit tests and 18 live/opening/result UI tests passed, zero failures or skips. This includes direct drag, double-tap, collection, last-card autoplay, background/resume, bidding, trump selection, result continuation, and match reset. The superseded historical layout UI suite was not included.
- Human playtesting and comparative win-rate measurement remain outstanding. No claim of expert-level play is made.
