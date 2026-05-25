# Tarneeb iOS MVP Design

## 1. Overview

This design covers the deal-only Tarneeb iOS MVP described in `requirements.md`.
The app launches to a start screen, creates a valid four-player Tarneeb table when
the app starts, keeps those seats empty until the human player taps
`Deal Cards`, shuffles a standard 52-card deck without jokers, deals one
13-card chunk to each seat, displays only the South player's hand, and then
stops in a completed-deal state.

The MVP must not introduce bidding, Tarneeb suit selection, trick play, scoring,
persistence, accounts, multiplayer, AI decision-making, or user-facing error
handling.

## 2. Architecture

### 2.1 Layers

| Layer | Responsibility | Notes |
| --- | --- | --- |
| SwiftUI presentation | Render the start screen, empty seats before the first deal, dealt table screen, visible South hand, hidden simulated hands, completion message, and new-deal action. | Views should not create decks, assign teams, or perform deal validation directly. |
| Presentation state | Own the currently displayed game state and expose user actions such as `Deal Cards` and `New Deal`. | This may be a view model or equivalent observable state object. |
| Domain model | Represent cards, suits, ranks, seats, teams, players, hands, and game phase. | Should be UI-independent and easy to unit test. |
| Game setup/deal service | Create players, create the deck, shuffle it, deal cards, and validate the completed deal invariants. | This is the core test target for MVP correctness. |
| Shuffle abstraction | Wrap the standard Swift shuffle behavior while allowing tests to inject deterministic ordering. | Production dealing should use Swift's standard shuffle method; tests should not depend on random output. |

### 2.2 Data Flow

1. The app starts with `phase = notStarted`, exactly four empty player seats,
   and no visible cards.
2. The human player taps `Deal Cards`.
3. Presentation state requests a new completed deal from the deal service.
4. The deal service uses or recreates the canonical player seats and teams.
5. The deal service creates the canonical 52-card deck.
6. The deck is shuffled using Swift's standard shuffle method.
7. Cards are assigned as four 13-card chunks, one chunk per player.
8. The completed state is validated.
9. Presentation state stores the result as `phase = dealt`.
10. SwiftUI renders the dealt table screen.

### 2.3 Primary Components

| Component | Purpose |
| --- | --- |
| App entry point | Hosts the root SwiftUI view. |
| Root/start view | Shows title `Tarneeb`, primary `Deal Cards` action, and four empty player seats before the first deal. |
| Table view | Shows four seats after a deal is complete. |
| Human hand view | Shows South player's 13 visible cards with rank and suit. |
| Simulated hand view | Shows 13 hidden `card_back.png` card backs for each simulated player without ranks or suits. |
| Deal completion view element | Shows a message such as `Deal complete` and a `New Deal` action. |
| Game state owner | Bridges button actions to domain operations and exposes current render state. |
| Deal service | Performs player setup, deck creation, shuffle, deal, and validation. |

### 2.4 MVP Boundary

The completed-deal screen is terminal for gameplay. It may offer a new deal, but
it must not expose controls or state transitions for bidding, passing, choosing a
Tarneeb suit, playing cards, resolving tricks, scoring, or finishing a full game.

## 3. Data Model

### 3.1 Card

| Field | Type/Allowed Values | Requirement |
| --- | --- | --- |
| `suit` | `spades`, `clubs`, `hearts`, `diamonds` | Required. |
| `rank` | `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `J`, `Q`, `K`, `A` | Required. |
| `id` | Stable suit-rank identity, such as `spades-A` | Required for uniqueness and UI identity. |

Card identity is derived from suit and rank. No joker suit, joker rank, or
duplicate suit-rank combination is valid.

### 3.2 Suit

The deck contains exactly these suits:

| Suit | Display Symbol |
| --- | --- |
| `spades` | `♠` |
| `clubs` | `♣` |
| `hearts` | `♥` |
| `diamonds` | `♦` |

### 3.3 Rank

The deck contains exactly these ranks per suit:

| Low-to-high order | Rank |
| --- | --- |
| 1 | `2` |
| 2 | `3` |
| 3 | `4` |
| 4 | `5` |
| 5 | `6` |
| 6 | `7` |
| 7 | `8` |
| 8 | `9` |
| 9 | `10` |
| 10 | `J` |
| 11 | `Q` |
| 12 | `K` |
| 13 | `A` |

Ranks should be displayed using the listed numbers or letters. This order is
used for required South-hand display sorting and deterministic tests. The MVP
does not use rank strength for gameplay.

### 3.4 Seat

| Seat | Player Type | Team | Visual Intent |
| --- | --- | --- | --- |
| `south` | Human | `teamA` | Bottom / primary human hand area. |
| `west` | Simulated | `teamB` | Side simulated area. |
| `north` | Simulated | `teamA` | Top simulated area. |
| `east` | Simulated | `teamB` | Side simulated area. |

The table must contain exactly one player per seat.

### 3.5 Player

| Field | Type/Allowed Values | Requirement |
| --- | --- | --- |
| `id` | Stable unique identifier | Required. |
| `seat` | `south`, `west`, `north`, `east` | Required and unique per game. |
| `type` | `human`, `simulated` | South must be human; all others simulated. |
| `team` | `teamA`, `teamB` | South/North on Team A; East/West on Team B. |
| `hand` | List of cards | Empty before deal; exactly 13 after deal. |

### 3.6 Game Phase

| Phase | Meaning | Allowed UI |
| --- | --- | --- |
| `notStarted` | No deal has been completed in the current state. | Title, `Deal Cards`, and four empty player seats; no visible cards. |
| `dealt` | A valid deal has completed. | Four seats, South hand, hidden simulated hands, completion message, and new-deal action. |

No additional phases are part of the MVP.

### 3.7 Game State

| Field | Requirement |
| --- | --- |
| `phase` | Must be `notStarted` or `dealt`. |
| `players` | Exactly four players in both not-started and dealt states. |
| `deck` | Optional to retain; if retained during/after deal, it must not create duplicate ownership ambiguity. |

For a completed deal, the source of truth should be the four player hands. If a
deck is retained after dealing, it should represent either an empty undealt deck
or an immutable audit/source deck with clear ownership semantics.

## 4. Deal Design

### 4.1 Deck Creation

Deck creation must be deterministic before shuffle:

1. Enumerate the four allowed suits.
2. For each suit, enumerate the thirteen allowed ranks.
3. Create exactly one card per suit-rank pair.
4. Verify the resulting collection has 52 cards and 52 unique identities.

### 4.2 Shuffle

The deck must be shuffled before assignment. The shuffle operation must preserve:

- Card count: 52 cards in, 52 cards out.
- Card identity: every original card remains present.
- Uniqueness: no duplicate card appears after shuffle.

Production code should use Swift's standard shuffle method. Tests should not
assert a specific random order. Tests that need repeatability should inject a
deterministic shuffler or a deterministic wrapper around the shuffle step.

### 4.3 Player Setup

Player setup must create exactly four players:

| Seat | Type | Team |
| --- | --- | --- |
| South | Human | Team A |
| West | Simulated | Team B |
| North | Simulated | Team A |
| East | Simulated | Team B |

Player setup should be independent from deck creation so the seat/team rules can
be tested directly.

### 4.4 Card Assignment

The edited product requirements specify dealing one 13-card chunk to each
player. The deal service should produce a valid completed deal by:

1. Starting from a shuffled 52-card deck.
2. Splitting the deck into four 13-card chunks.
3. Assigning one chunk to each player.
4. Marking the game state as `dealt`.
5. Validating there are no remaining undealt cards and no duplicate assignments.

The implementation should assign chunks using the recommended seat order from
the requirements: South, East, North, West. Tests that assert exact card
ownership should use deterministic shuffle input and this chunk-to-seat order.

## 5. UI Design

### 5.1 Initial Screen

Required elements:

- App title: `Tarneeb`
- Primary action: `Deal Cards`
- Four empty player areas labeled by seat
- No visible cards
- No bidding, passing, trump/Tarneeb suit, trick, or scoring controls

Primary action behavior:

- Tapping `Deal Cards` starts and completes a new deal.
- The user should not see partial gameplay state beyond optional basic dealing
  feedback.

### 5.2 Dealt Table Screen

Required elements:

- Four visible player areas labeled by seat.
- South hand with 13 visible cards.
- West, North, and East hidden hands.
- Deal completion message such as `Deal complete`.
- Fresh-deal action labeled `New Deal`.

South card display:

- Each visible card must show rank and suit.
- Suits must be shown using symbols.
- Ranks must be shown using numbers/letters.
- Cards must be sorted by suit and rank for readability.
- Suit order must be Hearts, Clubs, Diamonds, Spades.
- Rank order must be 2 through Ace.
- Cards must not be selectable, playable, discardable, or otherwise actionable.

Simulated player display:

- Must not expose rank or suit.
- Must show 13 hidden card backs for each simulated player using
  `card_back.png`.
- Must not expose simulated player controls.

### 5.3 Prohibited UI

The MVP must not show:

- Bid controls.
- Pass controls.
- Trump/Tarneeb suit selector.
- Play-card controls.
- Trick area.
- Scoreboard.
- Game-over state.

## 6. State Transitions

| Current State | Trigger | Result |
| --- | --- | --- |
| `notStarted` | App launch | Show initial screen with four empty player seats and no cards. |
| `notStarted` | Tap `Deal Cards` | Create a fresh valid deal and move to `dealt`. |
| `dealt` | Tap `New Deal` | Clear previous hands, create a fresh valid deal, remain in `dealt`. |
| `dealt` | Tap/card interaction attempt | No gameplay action occurs. |

No transition may enter bidding, trump selection, trick play, scoring, or game
completion.

## 7. Edge Cases

| Edge Case | Expected Handling |
| --- | --- |
| User taps `Deal Cards` repeatedly | Prevent overlapping deals; each accepted tap should result in one complete valid deal. |
| User taps `New Deal` repeatedly | Previous state is replaced by a fresh valid completed deal. |
| Shuffle returns same order by chance | This is valid if the deck was actually passed through the shuffle operation; tests should not fail solely because random order matches source order. |
| Shuffle implementation loses or duplicates cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of scope. |
| Deck creation contains a duplicate or missing card | Internal validation should prevent rendering a completed deal; user-facing error handling is out of scope. |
| Deal assignment leaves undealt cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of scope. |
| Any player receives fewer or more than 13 cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of scope. |
| Simulated hand accidentally exposes card data in UI | Invalid MVP behavior; hidden players must show only `card_back.png` card backs. |
| Human hand sorting changes underlying ownership | Sorting should affect display only; it must not duplicate, remove, or reassign cards. |
| App relaunches | Persistence is out of scope; initial launch may return to `notStarted`. |
| Device has small screen or large Dynamic Type | Standard iOS controls should remain usable; no custom accessibility scope is required beyond standard controls for MVP. |

## 8. Validation Invariants

A completed deal is valid only if all of the following are true:

- Game phase is `dealt`.
- There are exactly four players.
- Seats are exactly South, West, North, and East.
- South is the only human player.
- West, North, and East are simulated.
- South and North are Team A.
- East and West are Team B.
- Each player has exactly 13 cards.
- Each player's hand was assigned as one 13-card chunk from the shuffled deck.
- The combined dealt hands contain exactly 52 cards.
- The combined dealt hands contain exactly 52 unique card identities.
- Every dealt card belongs to the standard no-joker Tarneeb deck.
- No cards remain undealt if the deck represents remaining cards.

## 9. Test Strategy

### 9.1 Unit Tests

Unit tests should cover the domain and deal service without SwiftUI:

| Area | Tests |
| --- | --- |
| Deck creation | 52 cards, no jokers, four suits, thirteen ranks per suit, all identities unique. |
| Player setup | Four seats, one player per seat, South human, other seats simulated, correct teams. |
| Shuffle | Count preserved, uniqueness preserved, all original cards still present. |
| Deal assignment | Each player receives one 13-card chunk, all 52 cards assigned, no duplicates, no undealt cards. |
| Game phase | Initial state is `notStarted`; completed deal records `dealt`. |
| New deal | Previous hands are replaced; resulting state is another valid completed deal. |
| Sorting | South hand display uses Hearts, Clubs, Diamonds, Spades and 2-through-Ace order without changing card identity or ownership. |

Shuffle tests should avoid brittle assertions that require two random deals to
always differ. If deterministic proof is needed, inject a known test shuffler and
assert assignment from that known order.

### 9.2 UI Tests

UI tests should verify the user-facing acceptance criteria:

| Scenario | Assertions |
| --- | --- |
| Initial launch | `Tarneeb` title, `Deal Cards` button, and four empty player seats are visible; no cards are visible. |
| Deal action | Tapping `Deal Cards` shows South hand with 13 visible cards. |
| Simulated hands | West, North, and East each show 13 hidden `card_back.png` card backs; ranks and suits are not visible for those seats. |
| Completion state | `Deal complete` or equivalent message appears. |
| Prohibited controls | Bid, pass, trump/Tarneeb suit, play-card, trick, scoring, and game-over UI are absent. |
| New deal action | Tapping `New Deal` replaces the previous completed deal with another valid displayed deal. |

### 9.3 Manual QA

Manual verification should include:

- Launch app from a clean install.
- Confirm four empty player seats and no cards appear before dealing.
- Complete several deals and visually confirm South changes over repeated deals
  when randomness produces different orders.
- Confirm simulated seats never reveal rank or suit.
- Confirm cards cannot be tapped to play or selected for gameplay.
- Confirm the UI remains responsive immediately after a deal.

## 10. Ambiguities and Open Questions

These items are intentionally flagged rather than resolved by this design:

| Topic | Ambiguity |
| --- | --- |
| Chunk-to-seat order acceptance | Requirements specify 13-card chunks and recommend South, East, North, West seat order, but do not make exact chunk ownership a product acceptance criterion. Tests may still assert the design's chosen South, East, North, West assignment order. |
| Shuffle test determinism | Production must use Swift's standard shuffle method, but requirements do not specify seed behavior or deterministic replay outside tests. |
| Accessibility scope | Requirements limit accessibility to standard iOS controls; no custom VoiceOver labels, Dynamic Type targets, or contrast requirements are specified. |
| Visual card layout | Requirements now specify suit symbols and number/letter ranks, but do not specify card art, colors, typography, or exact layout. |
