# Tarneeb iOS MVP 002 Design

## 1. Overview

This design covers the Tarneeb MVP 002 requirements in `requirements.md`.
The gameplay scope remains deal-only: the app launches, shows one human seat and
three simulated seats, lets the human player deal cards, displays the completed
deal, and allows a new deal. No bidding, passing, Tarneeb suit selection, trick
play, scoring, persistence, multiplayer, or AI decision-making is introduced.

MVP 002 adds visual and layout requirements to the original deal-only MVP:

- Hearts and Diamonds must use the token-backed `suitWarm` presentation role,
  which resolves to `color.card.suit.red`.
- Clubs and Spades must use the token-backed `suitNeutral` presentation role,
  which resolves to `color.card.suit.black`.
- The four player stations must be arranged in a diamond pattern.
- North, West, and East stations must be compact.
- Exposed cards and hidden card backs must use the same readable base size and
  standard-card aspect ratio.
- Hidden cards may be shown as slightly spread stacks, but must still represent
  13 hidden cards per simulated player.

## 2. Architecture

### 2.1 Layers

| Layer | Responsibility | Notes |
| --- | --- | --- |
| SwiftUI presentation | Render launch, empty table, dealt table, card faces, hidden card backs, deal messages, and actions. | Owns layout only; it must not create decks or assign cards. |
| Presentation state | Own current game state and expose user actions such as `Deal Cards` and `New Deal`. | Bridges UI events to domain services. |
| Presentation mapping | Convert domain cards/seats into display-facing values such as suit symbol, token-backed suit color role, sorted South hand, card sizing config, and accessibility identifiers. | Should be testable without needing to inspect SwiftUI views where practical. |
| Domain model | Represent suits, ranks, cards, seats, teams, players, hands, and game phase. | UI-independent and unit-testable. |
| Game setup/deal service | Create players, create a valid deck, shuffle, deal 13-card chunks, and validate completed deals. | Core correctness layer. |
| Shuffle abstraction | Wrap Swift's standard shuffle behavior while allowing deterministic test shufflers. | Production should use the standard Swift shuffle method. |
| Asset catalog | Provide `card_back.png` for hidden simulated hands. | Must be referenced by a stable asset name. |
| Design token specification | Own all concrete color values for table surfaces, card faces, suit styling, text, stations, and action buttons. | `design.md` may reference token names and semantic roles only; `design-tokens.md` is the source of truth. |

### 2.2 Data Flow

1. App launches with `phase = notStarted`, exactly four empty player seats, and
   no visible cards.
2. SwiftUI renders the title, `Deal Cards`, and empty player stations in the
   required diamond relationship.
3. The human player taps `Deal Cards`.
4. Presentation state requests a completed deal from the deal service.
5. The deal service creates or resets the four canonical players.
6. The deal service creates a canonical 52-card no-joker deck.
7. The deck is shuffled with the production shuffler.
8. The shuffled deck is split into four 13-card chunks and assigned to players.
9. The completed deal is validated for player count, hand sizes, uniqueness,
   and no undealt cards.
10. Presentation state stores the result as `phase = dealt`.
11. Presentation mapping prepares visible South cards, hidden simulated card
   counts, token-backed suit color roles, and shared card sizing.
12. SwiftUI renders the dealt diamond table, `Deal complete`, and `New Deal`.

### 2.3 Primary Components

| Component | Purpose |
| --- | --- |
| App entry point | Hosts the root SwiftUI view. |
| Root table view | Displays the full MVP screen in both `notStarted` and `dealt` phases. |
| Diamond table layout | Places North at top, West left, South bottom, and East right while preserving usable controls. |
| Player station view | Renders a seat label and either an empty station, visible South hand, or hidden simulated stack. |
| Card face view | Renders exposed South cards with rank, suit symbol, token-backed color role, and standard-card aspect ratio. |
| Hidden card back view | Renders `card_back.png` at the same base size as exposed cards. |
| Hidden hand stack view | Renders 13 hidden card backs for a simulated player, optionally with slight overlap. |
| Deal status/action view | Renders `Deal complete` and `New Deal` in the dealt state, or `Deal Cards` in the initial state. |
| Game state owner | Handles button actions and publishes renderable state. |
| Deal service | Performs player setup, deck creation, shuffle, chunk assignment, and validation. |

### 2.4 MVP Boundary

The completed-deal screen is terminal for gameplay. It may expose `New Deal`, but
must not expose bidding, passing, choosing the Tarneeb suit, playing a card,
resolving tricks, scoring, saved games, accounts, or multiplayer.

### 2.5 Design Token Boundary

`specs/002-mvp/design-tokens.md` is the source of truth for all concrete color
values. This design may name semantic roles and token keys, but must not define
hex, RGB, platform, or other concrete color values.

Implementation should resolve display roles through a token layer:

| Semantic Role | Token Source |
| --- | --- |
| `tableSurface` | `color.table.background.primary` |
| `tableSurfaceSecondary` | `color.table.background.secondary` |
| `tableHighlight` | `color.table.felt.highlight` |
| `cardFace` | `color.card.background` |
| `cardBorder` | `color.card.border` |
| `cardShadow` | `color.card.shadow` |
| `suitWarm` | `color.card.suit.red` |
| `suitWarmEmphasis` | `color.card.suit.red.dark` |
| `suitNeutral` | `color.card.suit.black` |
| `suitNeutralSecondary` | `color.card.suit.black.soft` |
| `stationOutline` | `color.station.outline` |
| `stationOutlineActive` | `color.station.outline.active` |
| `stationOutlineInactive` | `color.station.outline.inactive` |
| `textPrimary` | `color.text.primary` |
| `textSecondary` | `color.text.secondary` |
| `textDisabled` | `color.text.disabled` |
| `textWarning` | `color.text.warning` |
| `dealActionBackground` | `color.button.deal.background` |
| `dealActionPressedBackground` | `color.button.deal.background.pressed` |
| `dealActionText` | `color.button.deal.text` |
| `newDealActionBackground` | `color.button.newGame.background` |
| `newDealActionPressedBackground` | `color.button.newGame.background.pressed` |
| `newDealActionText` | `color.button.newGame.text` |

If implementation or later design work needs a color not represented by these
tokens, update `specs/002-mvp/design-tokens.md` first and reference the new token
from this design afterward.

## 3. Domain Data Model

### 3.1 Card

| Field | Type/Allowed Values | Requirement |
| --- | --- | --- |
| `suit` | `spades`, `clubs`, `hearts`, `diamonds` | Required. |
| `rank` | `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `J`, `Q`, `K`, `A` | Required. |
| `id` | Stable suit-rank identity, such as `spades-A` | Required for uniqueness and UI identity. |

Card identity is derived from suit and rank. No joker suit, joker rank, or
duplicate suit-rank combination is valid.

### 3.2 Suit

| Suit | Display Symbol | Token-Backed Color Role | Sort Order |
| --- | --- | --- | --- |
| `hearts` | Heart symbol | `suitWarm` -> `color.card.suit.red` | 1 |
| `clubs` | Club symbol | `suitNeutral` -> `color.card.suit.black` | 2 |
| `diamonds` | Diamond symbol | `suitWarm` -> `color.card.suit.red` | 3 |
| `spades` | Spade symbol | `suitNeutral` -> `color.card.suit.black` | 4 |

The requirements call for suit symbols. The implementation may store symbols as
presentation values rather than domain values, but the mapping must be stable and
testable.

### 3.3 Rank

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

Rank order is used for South-hand display sorting and deterministic tests. MVP
002 still does not use rank strength for trick play.

### 3.4 Seat

| Seat | Player Type | Team | Model Order | Visual Placement |
| --- | --- | --- | --- | --- |
| `south` | Human | `teamA` | 1 | Bottom, largest station. |
| `east` | Simulated | `teamB` | 2 | Right, compact station. |
| `north` | Simulated | `teamA` | 3 | Top, compact station. |
| `west` | Simulated | `teamB` | 4 | Left, compact station. |

The model order preserves the requirements' recommended counterclockwise order.
The visual order is a separate diamond placement: North top, West left, South
bottom, East right.

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
| `notStarted` | Four seats exist but no deal has completed. | Title, `Deal Cards`, empty diamond stations, no cards. |
| `dealt` | A valid deal has completed. | Diamond stations, South hand, hidden simulated hands, completion message, `New Deal`. |

No additional phases are part of MVP 002.

### 3.7 Game State

| Field | Requirement |
| --- | --- |
| `phase` | Must be `notStarted` or `dealt`. |
| `players` | Exactly four players in both phases. |
| `deck` | Optional to retain; if retained after dealing, ownership semantics must be clear. |

For a completed deal, the source of truth should be the four player hands. If a
deck is retained after dealing, it should represent either an empty undealt deck
or an immutable source/audit deck, not another owner of cards.

## 4. Presentation Data Model

### 4.1 Card Presentation

Presentation mapping should expose enough information to render and test cards
without putting display rules directly into the domain model.

| Field | Source | Requirement |
| --- | --- | --- |
| `cardID` | Card identity | Stable UI identity. |
| `rankText` | Card rank | One of the allowed rank labels. |
| `suitSymbol` | Card suit | Suit symbol shown on exposed cards. |
| `suitColorRole` | Card suit | `suitWarm` for Hearts/Diamonds, `suitNeutral` for Clubs/Spades. |
| `suitColorToken` | `suitColorRole` | Token key resolved from `design-tokens.md`; no concrete color values in card presentation. |
| `sortKey` | Suit order plus rank order | Hearts, Clubs, Diamonds, Spades; then 2 through Ace. |
| `accessibilityLabel` | Card rank and suit | Useful for UI tests and standard control accessibility. |

### 4.2 Card Size Configuration

The UI should use a single card size source for exposed cards and hidden card
backs.

| Field | Requirement |
| --- | --- |
| `baseCardWidth` | Chosen responsively to fit the device and station. |
| `baseCardHeight` | Derived from width using an approximately 5:7 playing-card ratio. |
| `cornerRadius` | Small enough to read as a playing card, not a pill. |
| `rankFont` | Large enough to read on supported device sizes. |
| `hiddenStackOffset` | Slight spread amount for hidden card stacks. |

Exact point values are intentionally not specified in the requirements. The
implementation should choose responsive values and verify them visually and in UI
tests where practical.

### 4.3 Player Station Presentation

| Station | Content Before Deal | Content After Deal | Size Intent |
| --- | --- | --- | --- |
| South | Label only | Label plus 13 exposed sorted cards | Largest station because it contains the human hand. |
| North | Label only | Label plus hidden stack/count of 13 backs | Compact station. |
| West | Label only | Label plus hidden stack/count of 13 backs | Compact station. |
| East | Label only | Label plus hidden stack/count of 13 backs | Compact station. |

Compact simulated stations should not become large empty panels. Their visual
bounds should be driven by the label and hidden card arrangement.

### 4.4 UI Token Usage

Presentation should reference semantic roles or token keys from
`specs/002-mvp/design-tokens.md` for every colored UI element.

| UI Element | Required Token Usage |
| --- | --- |
| Table background | `color.table.background.primary`; `color.table.background.secondary` or `color.table.felt.highlight` only for token-defined depth or emphasis. |
| Face-up card surface | `color.card.background`, `color.card.border`, and `color.card.shadow`. |
| Hearts and Diamonds rank/suit | `suitWarm`, resolved to `color.card.suit.red`. |
| Clubs and Spades rank/suit | `suitNeutral`, resolved to `color.card.suit.black`. |
| Optional suit emphasis state | `color.card.suit.red.dark` or `color.card.suit.black.soft` only when the UI has an explicitly modeled emphasis state. |
| Player station outlines | `color.station.outline`, `color.station.outline.active`, or `color.station.outline.inactive` according to state. |
| Table labels and messages | `color.text.primary`, `color.text.secondary`, `color.text.disabled`, or `color.text.warning` according to information hierarchy. |
| `Deal Cards` action | `color.button.deal.background`, `color.button.deal.background.pressed`, and `color.button.deal.text`. |
| `New Deal` action | `color.button.newGame.background`, `color.button.newGame.background.pressed`, and `color.button.newGame.text`. |
| Destructive actions | Not used in MVP 002; if introduced later, use `color.button.destructive.background` and `color.button.destructive.text`. |

The `New Deal` action uses the existing `newGame` button tokens because the
token file does not define a separate `newDeal` token. This naming mismatch is
flagged as an ambiguity rather than resolved in this document.

## 5. Deal Design

### 5.1 Deck Creation

Deck creation must be deterministic before shuffle:

1. Enumerate the four allowed suits.
2. For each suit, enumerate the thirteen allowed ranks.
3. Create exactly one card per suit-rank pair.
4. Verify the resulting collection has 52 cards and 52 unique identities.

### 5.2 Shuffle

The deck must be shuffled before assignment. The shuffle operation must preserve:

- Card count: 52 cards in, 52 cards out.
- Card identity: every original card remains present.
- Uniqueness: no duplicate card appears after shuffle.

Production code should use Swift's standard shuffle method. Tests should avoid
asserting a specific random order. Tests that need repeatability should inject a
deterministic shuffler or a deterministic wrapper around the shuffle step.

### 5.3 Player Setup

Player setup must create exactly four players:

| Seat | Type | Team |
| --- | --- | --- |
| South | Human | Team A |
| East | Simulated | Team B |
| North | Simulated | Team A |
| West | Simulated | Team B |

Player setup should remain independent from deck creation so seat/team rules can
be tested directly.

### 5.4 Card Assignment

The product requirements specify dealing one 13-card chunk to each player. The
deal service should produce a completed deal by:

1. Starting from a shuffled 52-card deck.
2. Splitting the deck into four 13-card chunks.
3. Assigning one chunk to each player using model order South, East, North, West.
4. Marking the game state as `dealt`.
5. Validating no cards remain undealt and no duplicates were assigned.

Tests that assert exact card ownership should use deterministic shuffle input
and the South, East, North, West chunk-to-seat order.

### 5.5 New Deal

`New Deal` should be available only after a completed deal. When invoked:

1. Previous hands are cleared or replaced.
2. A fresh full deck is created or the previous full deck is reset.
3. The deck is shuffled.
4. Cards are assigned into four 13-card chunks.
5. The new completed deal is validated.
6. The presentation reuses the same diamond layout, card sizing, and token-backed
   suit presentation rules.

## 6. UI Design

### 6.1 Initial Screen

Required elements:

- App title: `Tarneeb`.
- Primary action labeled `Deal Cards`.
- Four empty player stations labeled `North`, `West`, `South`, and `East`.
- Diamond placement with North top, West left, South bottom, East right.
- Table surface, labels, station outlines, and action styling must resolve
  through the token usage defined in section 4.4.
- No visible card faces or card backs before the first deal.
- No bidding, passing, trump/Tarneeb suit, trick, scoring, or game-over UI.

### 6.2 Dealt Table Screen

Required elements:

- Four visible player areas arranged in the required diamond pattern.
- South human hand with 13 visible cards.
- West, North, and East simulated players with 13 hidden card backs each.
- Deal completion message such as `Deal complete`.
- Action labeled `New Deal`.
- Card faces, suit glyphs, labels, stations, and actions must resolve through
  the token usage defined in section 4.4.
- No gameplay controls beyond `New Deal`.

### 6.3 Diamond Layout

The layout should preserve the relationship below:

```text
          North

West                 East

          South
```

Design requirements:

- North and South must appear opposite each other.
- West and East must appear opposite each other.
- South should have the most room because it displays all exposed human cards.
- North, West, and East should be compact and sized around their labels plus
  hidden card arrays.
- The center area may remain open or hold the deal completion message if it does
  not cause overlap.
- The action button should remain reachable and should not cover cards.
- On a small supported simulator, spacing may compress or the table may scroll,
  but labels, cards, message, and available action must remain usable.

### 6.4 Exposed South Cards

South cards must:

- Display rank and suit symbol.
- Render Hearts and Diamonds using `suitWarm`, resolved through
  `color.card.suit.red`.
- Render Clubs and Spades using `suitNeutral`, resolved through
  `color.card.suit.black`.
- Use the shared card size configuration.
- Use a standard playing-card aspect ratio of approximately 5:7.
- Be large enough for rank and suit to be readable on supported devices.
- Be sorted by Hearts, Clubs, Diamonds, Spades, then 2 through Ace.
- Fit within the South station without incoherent overlap with other UI.
- Not be tappable or selectable for gameplay.

### 6.5 Hidden Simulated Cards

Simulated cards must:

- Use `card_back.png`.
- Use the same base card dimensions and aspect ratio as South cards.
- Represent 13 hidden cards for each of West, North, and East.
- Never expose rank or suit text/symbols.
- Avoid simulated player action controls.
- Fit inside compact simulated stations.

Hidden hands may use a slightly spread stack. A spread stack is valid only if it
still lets tests or accessibility metadata verify that 13 hidden cards are
represented and no card identities are revealed.

### 6.6 Prohibited UI

The MVP must not show:

- Bid controls.
- Pass controls.
- Trump/Tarneeb suit selector.
- Play-card controls.
- Trick area.
- Scoreboard.
- Game-over state.

## 7. State Transitions

| Current State | Trigger | Result |
| --- | --- | --- |
| App launch | None | Create four empty canonical seats and show `notStarted`. |
| `notStarted` | Tap `Deal Cards` | Create a fresh valid deal and move to `dealt`. |
| `dealt` | Tap `New Deal` | Clear/replace previous hands, create a fresh valid deal, remain in `dealt`. |
| `dealt` | Tap visible card | No gameplay action occurs. |
| `dealt` | Tap simulated hidden stack | No gameplay action occurs. |

No transition may enter bidding, trump selection, trick play, scoring, or game
completion.

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

Display invariants:

- South displays exactly 13 exposed cards.
- West, North, and East each display or represent exactly 13 hidden card backs.
- Simulated card ranks and suits are not visible.
- Hearts and Diamonds use `suitWarm`, resolved through `color.card.suit.red`.
- Clubs and Spades use `suitNeutral`, resolved through
  `color.card.suit.black`.
- All colored UI elements reference tokens from
  `specs/002-mvp/design-tokens.md`; no concrete color values are defined in
  this design.
- Exposed and hidden cards use the same base card size.
- Player stations preserve the diamond relationship.

## 9. Edge Cases

| Edge Case | Expected Handling |
| --- | --- |
| User taps `Deal Cards` repeatedly | Prevent overlapping deals; each accepted tap should result in one complete valid deal. |
| User taps `New Deal` repeatedly | Previous hands are cleared/replaced and the result is another valid completed deal. |
| Shuffle returns same order by chance | Valid if the deck was actually passed through the shuffle operation; tests should not fail solely because random order matches source order. |
| Shuffle implementation loses or duplicates cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 002 scope. |
| Deck creation contains a duplicate or missing card | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 002 scope. |
| Deal assignment leaves undealt cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 002 scope. |
| Any player receives fewer or more than 13 cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 002 scope. |
| Simulated hand exposes card data in UI | Invalid MVP behavior; hidden players must show only `card_back.png` backs or equivalent hidden-card representation. |
| Human hand sorting changes underlying ownership | Sorting must affect display only; it must not duplicate, remove, or reassign cards. |
| Small screen cannot fit generous spacing | Compress spacing or allow scrolling while preserving diamond relationship and usability. |
| Dynamic Type or localized platform sizing increases text | Standard iOS controls should remain usable; custom accessibility targets are not specified. |
| Card size calculation differs by station | Invalid if hidden and exposed cards no longer share the same base dimensions. |
| Hidden stack overlap hides most cards | Acceptable only if 13 hidden cards are still represented and the stack remains visibly card-like. |
| Appearance mode changes token rendering | `suitWarm` and `suitNeutral` must remain visually distinct in the supported appearance mode; do not invent appearance variants outside `design-tokens.md`. |
| `card_back.png` is missing from assets | Hidden simulated display cannot satisfy requirements; implementation should include and reference the asset by stable name. |

## 10. Test Strategy

### 10.1 Unit Tests

Unit tests should cover domain and presentation mapping without SwiftUI where
practical.

| Area | Tests | Requirements Covered |
| --- | --- | --- |
| Deck creation | 52 cards, no jokers, four suits, thirteen ranks per suit, unique identities. | PRD-003, NFR-004 |
| Player setup | Four seats, one player per seat, South human, other seats simulated, correct teams. | PRD-002 |
| Shuffle | Shuffle is invoked before assignment; count and uniqueness are preserved. | PRD-004 |
| Deal assignment | Four 13-card chunks, all 52 cards assigned, no duplicates, no undealt cards, phase is `dealt`. | PRD-005 |
| New deal | Previous hands are cleared/replaced and another valid completed deal is produced. | PRD-009 |
| South sorting | Visible South cards sort Hearts, Clubs, Diamonds, Spades and 2 through Ace. | PRD-006 |
| Suit presentation | Hearts/Diamonds map to `suitWarm` and `color.card.suit.red`; Clubs/Spades map to `suitNeutral` and `color.card.suit.black`. | PRD-006, NFR-005 |
| Token boundary | Presentation values expose semantic roles or token keys instead of concrete color values. | PRD-006, NFR-003, NFR-005 |
| Card size config | Exposed and hidden cards share the same base dimensions when represented in presentation config. | PRD-006, PRD-007, PRD-010 |
| Hidden hand presentation | Simulated hands expose hidden count/back presentation but no rank or suit values. | PRD-007 |

Shuffle tests should not depend on random output being different on every run.
Use a deterministic injected shuffler for exact chunk assignment tests.

### 10.2 UI Tests

UI tests should verify user-facing behavior and layout-critical elements.

| Scenario | Assertions | Requirements Covered |
| --- | --- | --- |
| Initial launch | `Tarneeb`, `Deal Cards`, and four empty diamond station labels are visible; cards are absent. | PRD-001, PRD-002, PRD-010 |
| Deal action | Tapping `Deal Cards` shows South hand with 13 visible cards and `Deal complete`. | PRD-005, PRD-006, PRD-008 |
| Simulated hands | West, North, and East each show or represent 13 hidden card backs; ranks and suits are absent for those seats. | PRD-007 |
| New deal | Tapping `New Deal` replaces the previous completed deal with another valid displayed deal. | PRD-009 |
| Prohibited controls | Bid, pass, trump/Tarneeb suit, play-card, trick, scoring, and game-over UI are absent. | PRD-008 |
| Small screen | On the smallest supported simulator, labels, cards, hidden backs, message, and available action remain usable. | PRD-010, NFR-005 |
| Responsiveness | Deal and new deal complete quickly enough that UI tests can continue interacting without long waits. | NFR-002 |

Token, rendered-color, and precise layout assertions may require one of these
approaches:

- Expose stable accessibility identifiers or values for suit color roles, token
  keys, and card size categories.
- Use view inspection if available in the test stack.
- Use snapshot or screenshot comparison for manual/automated visual review.
- Combine UI tests for existence/usability with manual visual QA for rendered
  token output and layout details that XCTest cannot robustly inspect.

### 10.3 Manual Visual QA

Manual visual QA should verify:

- Hearts and Diamonds render with the `suitWarm` role backed by
  `color.card.suit.red`.
- Clubs and Spades render with the `suitNeutral` role backed by
  `color.card.suit.black` and remain distinct from `suitWarm`.
- Table, text, station, card, and action styling matches the token usage in
  section 4.4.
- The table reads as a diamond: North top, West left, South bottom, East right.
- South and North appear opposite each other.
- East and West appear opposite each other.
- North, West, and East stations look compact compared with South.
- Hidden card backs are the same base size as exposed South cards.
- Hidden card backs are large enough to resemble cards.
- Exposed cards look like standard playing cards and remain readable.
- Small-screen layout remains usable and avoids incoherent overlap.
- Deal and new-deal interactions remain responsive.

### 10.4 Full Verification

Before marking MVP 002 done:

1. Run the full domain unit suite.
2. Run the full UI suite on a primary simulator.
3. Run layout-focused UI tests on the smallest supported simulator available to
   the project.
4. Perform manual visual QA for token-backed styling, card sizing, hidden stacks,
   compact stations, and diamond placement.

## 11. Requirement Traceability

| Requirement | Design Coverage |
| --- | --- |
| PRD-001 App Launch | Architecture data flow, initial screen, state transitions, UI tests. |
| PRD-002 Player Seats | Domain seat/player model, player setup, diamond station labels. |
| PRD-003 Deck Creation | Card model, deck creation design, unit tests. |
| PRD-004 Shuffle | Shuffle abstraction, shuffle design, deterministic test guidance. |
| PRD-005 Deal Cards | Card assignment, validation invariants, deal UI tests. |
| PRD-006 Human Hand Display | Card presentation model, South card UI, token-backed suit presentation tests. |
| PRD-007 Simulated Player Display | Hidden hand presentation, hidden card stack UI, edge cases. |
| PRD-008 Deal Completion State | Dealt screen, prohibited UI, state transitions. |
| PRD-009 New Deal | New-deal design, edge cases, tests. |
| PRD-010 Table Layout and Visual Sizing | Diamond layout, shared card sizing, compact stations, small-screen testing. |
| NFR-002 Responsiveness | Data flow, responsiveness UI tests, full verification. |
| NFR-003 Testability | Presentation mapping, stable identifiers, unit/UI test split. |
| NFR-004 Reliability | Validation invariants and domain tests. |
| NFR-005 Visual Usability | Token-backed card presentation, manual visual QA, small-screen tests. |

## 12. Ambiguities and Open Questions

These items are intentionally flagged rather than guessed:

| Topic | Ambiguity |
| --- | --- |
| Exact card dimensions | Requirements specify readable standard-card dimensions and about a 5:7 ratio, but no point sizes or breakpoints. |
| Smallest supported simulator | Requirements say at least one small-screen simulator but do not name a required device. |
| Token naming for `New Deal` | `design-tokens.md` names the secondary action tokens `newGame`, while the MVP action label is `New Deal`; this design maps `New Deal` to the existing tokens until product/design renames or aliases them. |
| Appearance-specific token variants | `design-tokens.md` defines one token value per color role and does not define separate appearance-mode variants; implementation should not invent variants without a token spec update. |
| Hidden stack spread | Requirements allow a slightly spread stack but do not define offset, overlap, or whether all 13 backs must be individually visible. |
| Automated token verification | Requirements ask for visual distinction, but XCTest may not inspect rendered token output directly without additional test tooling. |
| Automated geometric verification | Requirements specify diamond layout and compact stations but do not provide exact coordinates, size ratios, or tolerances. |
| Dynamic Type and accessibility | Requirements limit accessibility beyond standard iOS controls, so custom VoiceOver wording, Dynamic Type scaling targets, and contrast ratios are not specified. |
| Error handling UX | Requirements keep error handling out of scope beyond preventing invalid completed states; no user-facing error screen is specified for internal validation failures. |
| `card_back.png` source | Requirements require the asset, but do not specify whether MVP 002 should reuse the existing MVP 001 asset or source a revised image. |
