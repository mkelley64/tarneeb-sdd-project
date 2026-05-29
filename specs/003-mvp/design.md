# Tarneeb iOS MVP 003 Design

## 1. Overview

This design covers the Tarneeb MVP 003 requirements in `requirements.md`.
The gameplay scope remains deal-only: the app launches, shows one human seat and
three simulated seats, lets the human player deal cards, displays the completed
deal, and allows a replacement deal. No bidding, passing, Tarneeb suit
selection, trick play, scoring, persistence, multiplayer, or AI decision-making
is introduced.

MVP 003 changes the product surface from a top-title diamond layout into a
portrait-only card-table scene:

- The app is locked to portrait orientation.
- A circular card table appears in the center area with diameter equal to half
  the screen width.
- The Arabic title `طرنيب` is centered on the card table and uses the table-title
  typography and effect tokens from `design-tokens.md`.
- Before a deal, a non-fanned stack of 52 hidden cards appears just below the
  title on the card table so the title remains visible.
- After a deal, the central deck stack disappears.
- Player stations are rounded squares surrounding the card table.
- After a deal, the South station expands below the card table to show the
  human player's revealed hand.
- The user-facing deal action label is `Deal`, both before the first deal and
  after a completed deal.
- A separate `New Game` reset action sits next to `Deal` and restores the
  original launch state without immediately dealing.
- The bottom control row sits at the bottom of the screen, with `Deal complete`
  above it after a completed deal.
- MVP 002 card readability requirements remain: Hearts and Diamonds use the red
  suit role, Clubs and Spades use the dark suit role, and hidden/exposed cards
  share a readable standard-card base size.

## 2. Architecture

### 2.1 Layers

| Layer | Responsibility | Notes |
| --- | --- | --- |
| App shell and orientation policy | Launch the SwiftUI app and restrict supported orientation to portrait. | The exact implementation mechanism is not specified in the requirements and is flagged as an ambiguity. |
| SwiftUI presentation | Render the table scene, circular table, table title, initial deck stack, player stations, card faces, hidden card backs, deal status, and bottom controls. | Owns layout only; it must not create decks or assign cards. |
| Presentation state | Own current game state and expose the visible `Deal` and `New Game` actions. | `Deal` routes to first deal or replacement deal based on phase; `New Game` resets to `notStarted`. |
| Presentation mapping | Convert domain cards/seats into display values such as suit text, token-backed color role, sorted South hand, card size config, deck stack presentation, layout metrics, and accessibility identifiers. | Should be testable without inspecting SwiftUI views where practical. |
| Domain model | Represent suits, ranks, cards, seats, teams, players, hands, and game phase. | UI-independent and unit-testable. |
| Game setup/deal service | Create players, create a valid deck, shuffle, deal 13-card chunks, and validate completed deals. | Core correctness layer. |
| Shuffle abstraction | Wrap Swift's standard shuffle behavior while allowing deterministic test shufflers. | Production should use the standard Swift shuffle method. |
| Asset catalog | Provide `card_back.png` for hidden simulated hands and the initial central deck stack. | Must be referenced by a stable asset name. |
| Design token specification | Own all concrete colors, table-title typography, and table-title shadow values. | `design.md` references token names and semantic roles only; `design-tokens.md` is the source of truth. |
| Tests | Verify domain invariants, presentation mapping, portrait/table UI behavior, and absence of prohibited gameplay UI. | UI geometry tests should use tolerances because exact coordinates are not specified. |

### 2.2 Data Flow

1. App launches with portrait-only orientation, `phase = notStarted`, exactly
   four empty player seats, and no dealt player hands.
2. SwiftUI renders the card-table scene:
   - circular card table in the center area,
   - `طرنيب` title centered on the table,
   - non-fanned 52-card hidden deck stack just below the title on the table,
   - four rounded-square stations around the table,
   - bottom `New Game` and `Deal` buttons.
3. The human player taps `Deal`.
4. Presentation state detects `phase = notStarted` and requests a completed deal
   from the deal service.
5. The deal service creates or resets the four canonical players.
6. The deal service creates a canonical 52-card no-joker deck.
7. The deck is shuffled with the production shuffler.
8. The shuffled deck is split into four 13-card chunks and assigned to players.
9. The completed deal is validated for player count, hand sizes, uniqueness,
   and no undealt cards.
10. Presentation state stores the result as `phase = dealt`.
11. Presentation mapping prepares visible South cards, hidden simulated card
   counts, token-backed suit color roles, shared card sizing, and a hidden
   central deck stack state.
12. SwiftUI renders the dealt table:
   - central deck stack removed,
   - South station expanded below the table with 13 visible cards,
   - West/North/East compact stations with 13 hidden card backs each,
   - `Deal complete` above the bottom control row.
13. If the player taps `Deal` again in `phase = dealt`, presentation state clears
   or replaces previous hands, requests a fresh completed deal, and remains in
   `phase = dealt`.
14. If the player taps `New Game` in any phase, presentation state restores the
   original launch state: `phase = notStarted`, empty hands, visible title,
   visible central deck stack, and no completion label.

### 2.3 Primary Components

| Component | Purpose |
| --- | --- |
| App entry point | Hosts the root SwiftUI view and applies portrait-only app support. |
| Root table screen | Displays the full MVP screen in both `notStarted` and `dealt` phases. |
| Table scene layout | Allocates the main table area and bottom control area. |
| Circular card table view | Renders the central circular table at half the screen width. |
| Table title view | Renders `طرنيب` centered on the table using table-title typography and token-backed color/effect roles. |
| Central deck stack view | Renders or represents 52 hidden card backs in a non-fanned stack just below the title before a deal. |
| Player station layout | Places North above, West left, South below, and East right of the circular table. |
| Player station view | Renders a rounded-square station label and either empty content, a visible South hand, or a hidden simulated stack. |
| South hand view | Renders 13 sorted exposed cards after a deal. |
| Card face view | Renders exposed South cards with rank, suit text, token-backed color role, and standard-card aspect ratio. |
| Hidden card back view | Renders `card_back.png` at the shared card size. |
| Hidden hand stack view | Renders 13 hidden card backs for a simulated player, optionally with slight overlap. |
| Bottom controls view | Renders `Deal complete` in dealt state and the bottom `New Game` and `Deal` buttons in all MVP states. |
| Game state owner | Handles the visible `Deal` and `New Game` buttons and publishes renderable state. |
| Deal service | Performs player setup, deck creation, shuffle, chunk assignment, and validation. |
| Token resolver | Maps semantic roles to token values defined in `specs/003-mvp/design-tokens.md`. |

### 2.4 MVP Boundary

The completed-deal screen is terminal for gameplay. It may expose the bottom
`Deal` action to produce a replacement deal and the bottom `New Game` action to
reset to launch state, but must not expose bidding, passing, choosing the
Tarneeb suit, playing a card, resolving tricks, scoring, saved games, accounts,
or multiplayer.

### 2.5 Design Token Boundary

`specs/003-mvp/design-tokens.md` is the source of truth for all concrete color,
typography, and title-shadow values. This design may name semantic roles and
token keys, but must not define hex, RGB, platform color constants, or concrete
shadow values outside the token file.

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
| `tableTitleText` | `color.tableTitle.text` |
| `tableTitleTextOpacity` | `effect.tableTitle.text.opacity` |
| `tableTitleFont` | `typography.tableTitle.font` |
| `tableTitleFontSize` | `typography.tableTitle.fontSize` |
| `tableTitleTrackingMinimum` | `typography.tableTitle.tracking.min` |
| `tableTitleTrackingMaximum` | `typography.tableTitle.tracking.max` |
| `tableTitleShadowColor` | `effect.tableTitle.shadow.color` |
| `tableTitleShadowOpacity` | `effect.tableTitle.shadow.opacity` |
| `tableTitleShadowBlurRadius` | `effect.tableTitle.shadow.blurRadius` |
| `dealActionBackground` | `color.button.deal.background` |
| `dealActionPressedBackground` | `color.button.deal.background.pressed` |
| `dealActionText` | `color.button.deal.text` |
| `newGameActionBackground` | `color.button.newGame.background` |
| `newGameActionPressedBackground` | `color.button.newGame.background.pressed` |
| `newGameActionText` | `color.button.newGame.text` |

The MVP 003 deal action is always labeled `Deal` and should use the primary
deal button tokens. The reset action is always labeled `New Game` and should use
the secondary new-game button tokens.

If implementation or later design work needs a color, font, or effect value not
represented by these tokens, update `specs/003-mvp/design-tokens.md` first and
reference the new token from this design afterward.

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
003 still does not use rank strength for trick play.

### 3.4 Seat

| Seat | Player Type | Team | Model Order | Visual Placement |
| --- | --- | --- | --- | --- |
| `south` | Human | `teamA` | 1 | Below the table; expands after deal. |
| `east` | Simulated | `teamB` | 2 | Right of the table; compact station. |
| `north` | Simulated | `teamA` | 3 | Above the table; compact station. |
| `west` | Simulated | `teamB` | 4 | Left of the table; compact station. |

The model order preserves the requirements' recommended counterclockwise order:
South, East, North, West. The visual placement is separate: North above, West
left, South below, East right.

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
| `notStarted` | Four seats exist but no deal has completed. | Card table, table title, central 52-card hidden deck stack, empty rounded-square stations, bottom `New Game` and `Deal`. |
| `dealt` | A valid deal has completed. | Card table, no central deck stack, expanded South hand, hidden simulated hands, `Deal complete`, bottom `New Game` and `Deal`. |

No additional phases are part of MVP 003.

### 3.7 Game State

| Field | Requirement |
| --- | --- |
| `phase` | Must be `notStarted` or `dealt`. |
| `players` | Exactly four players in both phases. |
| `deck` | Optional to retain; if retained after dealing, ownership semantics must be clear. |

For a completed deal, the source of truth should be the four player hands. If a
deck is retained after dealing, it should represent either an empty undealt deck
or an immutable source/audit deck, not another owner of cards.

The initial 52-card deck stack does not require a new game phase. It can be
derived from `phase = notStarted` as presentation state, provided tests can
verify that it represents 52 hidden cards and disappears after `phase = dealt`.

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
| `deckStackOffset` | Central deck stack spread offset; must be 0 for the non-fanned initial stack. |

Exact point values are intentionally not specified in the requirements. The
implementation should choose responsive values and verify them visually and in UI
tests where practical.

### 4.3 Central Deck Stack Presentation

The initial deck stack should be display-only presentation derived from
`phase = notStarted`.

| Field | Requirement |
| --- | --- |
| `hiddenCardCount` | Exactly 52 before a deal. |
| `assetName` | Stable reference to `card_back.png`. |
| `isVisible` | True only in `notStarted`; false in `dealt`. |
| `layout` | Positioned just below the table title as a non-fanned stack. |
| `titleOverlap` | Must not overlap the title in the initial state. |
| `revealsCardIdentity` | Always false. |
| `accessibilityValue` | Should expose enough metadata for UI tests to verify count and hidden-card representation. |

Whether the initial 52-card stack must use the exact same base dimensions as
player hidden hands is ambiguous because the table diameter is constrained to
half the screen width. This ambiguity is listed in section 12.

### 4.4 Table Title Presentation

The `طرنيب` title should be display-only presentation placed in the center of
the circular card table.

| Field | Token Source | Requirement |
| --- | --- | --- |
| `text` | Static content | Must be `طرنيب`. |
| `font` | `typography.tableTitle.font` | Use the tokenized Arabic rounded title font. |
| `fontSize` | `typography.tableTitle.fontSize` | Use the tokenized fixed title size. |
| `tracking` | `typography.tableTitle.tracking.min` through `typography.tableTitle.tracking.max` | Use tracking within the specified token range. |
| `textColor` | `color.tableTitle.text` | Use the tokenized table-title text color. |
| `textOpacity` | `effect.tableTitle.text.opacity` | Use the tokenized table-title text opacity. |
| `shadow` | `effect.tableTitle.shadow.*` | Use the tokenized subtle table-title shadow. |
| `zIndex` | Presentation layout | Title remains visually above and unobscured by the initial central deck stack. |
| `accessibilityIdentifier` | Presentation mapping | Stable identifier for UI tests. |

The requirements specify title font family, fixed point size, title color,
title opacity, and shadow values. These values must stay in the token spec.

### 4.5 Player Station Presentation

| Station | Content Before Deal | Content After Deal | Size Intent |
| --- | --- | --- | --- |
| South | Label only in a rounded-square station | Label plus 13 exposed sorted cards; station expands below the table | Largest station after deal because it contains the human hand. |
| North | Label only in a rounded-square station | Label plus hidden stack/count of 13 backs | Compact station. |
| West | Label only in a rounded-square station | Label plus hidden stack/count of 13 backs | Compact station. |
| East | Label only in a rounded-square station | Label plus hidden stack/count of 13 backs | Compact station. |

Before deal, all stations should read as rounded squares. After deal, South
expands below the card table; whether it must remain a square after expansion is
not specified and is flagged in section 12.

### 4.6 Bottom Controls Presentation

| Field | Requirement |
| --- | --- |
| `dealButtonLabel` | Always `Deal`. |
| `newGameButtonLabel` | Always `New Game`. |
| `buttonPlacement` | Bottom control row at the bottom of the screen or bottom safe-area region; exact interpretation is ambiguous. |
| `dealButtonTokens` | Primary deal button tokens from `design-tokens.md`. |
| `newGameButtonTokens` | Secondary new-game button tokens from `design-tokens.md`. |
| `completionLabel` | `Deal complete`, visible only in `dealt`. |
| `completionPlacement` | Above the bottom control row in `dealt`. |
| `oldLabels` | `Deal Cards` and `New Deal` must not appear in MVP 003 UI. |

Internally, the visible `Deal` action can map to either "first deal" or
"replacement deal" based on phase. That internal distinction should not leak into
button text, accessibility label text, or visible UI.

The visible `New Game` action maps to reset only. In `dealt`, it clears all
hands, hides `Deal complete`, restores the central non-fanned deck stack below
the title, and returns the presentation to `notStarted`. In `notStarted`, it
leaves the launch state unchanged and must not start a deal.

### 4.7 Layout Metrics Presentation

The presentation layer should centralize layout calculations so tests can inspect
or infer them where practical.

| Metric | Requirement |
| --- | --- |
| `tableDiameter` | Half the current screen width. |
| `tableCenter` | Centered in the main table area; exact vertical center is ambiguous. |
| `stationCornerRadius` | Rounded-square appearance; exact radius is ambiguous. |
| `stationSideLength` | Rounded-square station sizing before deal; exact size is ambiguous. |
| `southExpandedHeight` | Large enough to display the South hand after deal without making bottom controls unusable. |
| `bottomControlHeight` | Large enough for the bottom `New Game` and `Deal` buttons and completion label when present. |

Where exact geometry is not specified, tests should verify relationships and
usability rather than brittle pixel-perfect coordinates.

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

### 5.5 Replacement Deal

The visible `Deal` action should be available in the dealt state. When invoked:

1. Previous hands are cleared or replaced.
2. A fresh full deck is created or the previous full deck is reset.
3. The deck is shuffled.
4. Cards are assigned into four 13-card chunks.
5. The new completed deal is validated.
6. The presentation remains in `phase = dealt`.
7. The central deck stack remains hidden.
8. The `Deal complete` label remains above the bottom control row.
9. The UI continues to use the portrait table layout, rounded-square stations,
   shared card sizing, and token-backed suit presentation rules.

### 5.6 New Game Reset

The visible `New Game` action should be available in both MVP phases. When
invoked:

1. Presentation state returns to `phase = notStarted`.
2. The four canonical seats remain present as South, West, North, and East.
3. All player hands are cleared.
4. The South expanded hand, simulated hidden hands, and `Deal complete` label are
   hidden.
5. The central non-fanned 52-card deck stack is visible again below the title.
6. No new deal is created until the player taps `Deal`.

## 6. UI Design

### 6.1 Root Layout

The root screen should be portrait-only and organized into two conceptual areas:

- A main table scene containing the circular table, table title, optional deck
  stack, and player stations.
- A bottom control area containing `Deal complete` when applicable and the bottom
  `New Game` and `Deal` buttons.

The bottom controls must remain usable on supported devices. If scrolling is
needed on small screens, the implementation must avoid a layout where the user
cannot reach the controls or where the South hand overlaps them.

### 6.2 Initial Screen

Required elements:

- Portrait orientation only.
- Circular card table centered in the main table area.
- Card table diameter equal to half the screen width.
- `طرنيب` title centered on the card table.
- Title styling from `typography.tableTitle.*`, `color.tableTitle.text`,
  `effect.tableTitle.text.opacity`, and `effect.tableTitle.shadow.*` tokens.
- Non-fanned 52-card hidden deck stack just below the title on the card table.
- Four rounded-square player stations surrounding the table.
- North above the table, West left of the table, South below the table, and East
  right of the table.
- Bottom buttons labeled `New Game` and `Deal`.
- No visible dealt player hands before the first deal.
- No `Deal Cards` or `New Deal` labels.
- No bidding, passing, trump/Tarneeb suit, trick, scoring, or game-over UI.

### 6.3 Dealt Table Screen

Required elements:

- Portrait orientation only.
- Circular card table remains in the main table area.
- Central 52-card deck stack is absent.
- Four player stations continue to surround the card table.
- South station expands below the card table and displays 13 visible cards.
- West, North, and East display 13 hidden card backs each.
- Hearts and Diamonds use the `suitWarm` role.
- Clubs and Spades use the `suitNeutral` role.
- Exposed and hidden cards use the same base size and standard-card aspect ratio.
- West, North, and East stations remain compact when screen space allows.
- `Deal complete` appears above the bottom control row.
- Bottom buttons are labeled `New Game` and `Deal`.
- No `Deal Cards` or `New Deal` labels.
- No gameplay controls beyond the replacement deal action.

### 6.4 Circular Card Table

The circular table must:

- Render as a circle, not an oval.
- Use a diameter equal to half the screen width.
- Sit in the center area of the screen's main table scene.
- Contain the centered `طرنيب` title.
- Contain the initial 52-card deck stack before deal.
- Keep the initial deck stack below the title so the title remains visible.
- Avoid conflicting with the bottom deal control.

Exact vertical placement is not specified beyond "center of the screen" and
"centered in the main table area"; this is flagged as an ambiguity because the
bottom control area changes the available visual center.

### 6.5 Table Title

The `طرنيب` title must:

- Appear centered on the circular card table.
- Use the table-title font token.
- Use the table-title `26pt` font-size token.
- Use tracking within the table-title tracking token range.
- Use the table-title text color and opacity tokens.
- Use the table-title shadow tokens.
- Remain visible above the initial central deck stack.
- Not be duplicated as a large title at the top of the screen.

The requirements specify font family, fixed point size, tracking range, color,
and shadow. Any future change to those values should be added to the
token spec before implementation.

### 6.6 Player Stations

The layout should preserve the relationship below:

```text
            North

West      [Table]      East

            South
```

Design requirements:

- Stations are rounded squares surrounding the circular table.
- North and South must appear opposite each other.
- West and East must appear opposite each other.
- Before deal, all stations read as rounded squares.
- After deal, South expands below the table because it displays all exposed
  human cards.
- North, West, and East should be compact and sized around their labels plus
  hidden card arrays.
- Station labels should remain readable and should not collide with cards.
- The action button should remain reachable and should not cover cards.
- On a small supported simulator, spacing may compress or the table may scroll,
  but labels, cards, message, and available action must remain usable.

### 6.7 Exposed South Cards

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
- Fit within the expanded South station without incoherent overlap with other UI.
- Not be tappable or selectable for gameplay.

### 6.8 Hidden Cards

Simulated player hidden cards must:

- Use `card_back.png`.
- Use the same base card dimensions and aspect ratio as South cards.
- Represent 13 hidden cards for each of West, North, and East.
- Never expose rank or suit text/symbols.
- Avoid simulated player action controls.
- Fit inside compact simulated stations.

The initial central deck stack must:

- Use `card_back.png` or equivalent hidden-card presentation backed by that
  asset.
- Represent exactly 52 hidden cards.
- Be non-fanned, with no spread or rotation.
- Sit just below the `طرنيب` title on the circular card table.
- Not overlap the title.
- Disappear after the deal completes.
- Never expose rank or suit text/symbols.

Hidden hands may use overlap to conserve space. The central deck stack should
use direct overlap with no fan, spread, or rotation while tests or accessibility
metadata verify the required hidden-card count and no card identities are
revealed.

### 6.9 Bottom Controls

The bottom controls must:

- Show a button labeled `Deal` before the first deal.
- Continue showing a button labeled `Deal` after a completed deal.
- Show a button labeled `New Game` next to `Deal` before the first deal.
- Continue showing a button labeled `New Game` next to `Deal` after a completed
  deal.
- Show `Deal complete` above the bottom control row after a completed deal.
- Use primary deal button tokens for `Deal`.
- Use secondary new-game button tokens for `New Game`.
- Reset to the original launch state when `New Game` is tapped.
- Avoid `Deal Cards` and `New Deal` in visible labels and accessibility labels.
- Remain usable when the South station expands after deal.

The exact meaning of "very bottom" is ambiguous with respect to the iOS safe
area and scrollable content. This design does not invent a stricter coordinate
rule; it flags the issue in section 12.

### 6.10 Prohibited UI

The MVP must not show:

- Bid controls.
- Pass controls.
- Trump/Tarneeb suit selector.
- Play-card controls.
- Trick area.
- Scoreboard.
- Game-over state.
- Landscape-only layout.

## 7. State Transitions

| Current State | Trigger | Result |
| --- | --- | --- |
| App launch | None | Create four empty canonical seats and show `notStarted` in portrait. |
| `notStarted` | Tap visible `Deal` | Create a fresh valid deal, hide central deck stack, and move to `dealt`. |
| `notStarted` | Tap visible `New Game` | Keep the original launch state; no deal starts. |
| `dealt` | Tap visible `Deal` | Clear/replace previous hands, create a fresh valid deal, keep central deck stack hidden, remain in `dealt`. |
| `dealt` | Tap visible `New Game` | Clear all hands, hide dealt UI, restore central deck stack, and move to `notStarted`. |
| `dealt` | Tap visible card | No gameplay action occurs. |
| `dealt` | Tap simulated hidden stack | No gameplay action occurs. |
| Any state | Device rotates | App remains portrait. |

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

- The app is portrait-only.
- The visible primary action is always labeled `Deal`.
- The visible reset action is always labeled `New Game`.
- `Deal Cards` and `New Deal` are absent from visible and accessibility labels.
- The card table is circular.
- The card table diameter is half the screen width.
- The table title is centered on the card table.
- The initial central deck stack represents exactly 52 hidden cards.
- The central deck stack is visible only before a deal.
- South displays exactly 13 exposed cards after a deal.
- West, North, and East each display or represent exactly 13 hidden card backs
  after a deal.
- Simulated card ranks and suits are not visible.
- Hearts and Diamonds use `suitWarm`, resolved through `color.card.suit.red`.
- Clubs and Spades use `suitNeutral`, resolved through
  `color.card.suit.black`.
- All colored, typographic, and title-shadow UI values reference tokens from
  `specs/003-mvp/design-tokens.md`; no concrete color values are defined in
  this design.
- Exposed and hidden player cards use the same base card size.
- Player stations preserve the table-surrounding relationship.
- The `Deal complete` label appears above the bottom control row in `dealt`.
- Tapping `New Game` returns display state to `notStarted`, clears all hands,
  hides completion text, and restores the central deck stack below the title.

## 9. Edge Cases

| Edge Case | Expected Handling |
| --- | --- |
| User taps `Deal` repeatedly in `notStarted` | Prevent overlapping deals; each accepted tap should result in one complete valid deal. |
| User taps `Deal` repeatedly in `dealt` | Previous hands are cleared/replaced and the result is another valid completed deal. |
| User taps `New Game` in `notStarted` | Remain in the launch state; do not start a deal. |
| User taps `New Game` in `dealt` | Reset to `notStarted`, clear hands, hide `Deal complete`, and restore the central deck stack below the title. |
| User taps `New Game` repeatedly | Remain in or return to the launch state without producing partial hands or a completed deal. |
| Shuffle returns same order by chance | Valid if the deck was actually passed through the shuffle operation; tests should not fail solely because random order matches source order. |
| Shuffle implementation loses or duplicates cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 003 scope. |
| Deck creation contains a duplicate or missing card | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 003 scope. |
| Deal assignment leaves undealt cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 003 scope. |
| Any player receives fewer or more than 13 cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 003 scope. |
| Simulated hand exposes card data in UI | Invalid MVP behavior; hidden players must show only `card_back.png` backs or equivalent hidden-card representation. |
| Initial deck stack exposes card data in UI | Invalid MVP behavior; the stack must not reveal ranks or suits. |
| Human hand sorting changes underlying ownership | Sorting must affect display only; it must not duplicate, remove, or reassign cards. |
| Small portrait screen cannot fit generous spacing | Compress spacing or allow scrolling while preserving the table relationship and bottom control usability. |
| Device rotates to landscape | App remains portrait. |
| South station expansion conflicts with bottom controls | Layout must adjust spacing or scrolling so `Deal complete`, `New Game`, and `Deal` remain usable. |
| Card size calculation differs by station | Invalid if player hidden and exposed cards no longer share the same base dimensions. |
| Hidden stack overlap hides most cards | Acceptable only if the required hidden-card count is still represented and the stack remains visibly card-like. |
| Initial 52-card stack overlaps the title | Invalid after the title-visibility update; move the stack below the title. |
| Appearance mode changes token rendering | `suitWarm` and `suitNeutral` must remain visually distinct in the supported appearance mode; do not invent appearance variants outside `design-tokens.md`. |
| `card_back.png` is missing from assets | Hidden player display and central deck stack cannot satisfy requirements; implementation should include and reference the asset by stable name. |
| Specified table-title font is unavailable | Do not silently choose a different brand font without product approval; this is an implementation risk to resolve or flag. |
| Title shadow is omitted | Treat as a regression because the specified title style includes the tokenized subtle shadow. |

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
| Replacement deal | Previous hands are cleared/replaced and another valid completed deal is produced from the visible `Deal` action. | PRD-008, PRD-009, PRD-012 |
| New Game reset | Visible `New Game` returns the presentation to `notStarted`, clears hands, hides completion, and restores the central deck stack without dealing. | PRD-001, PRD-008, PRD-012, PRD-013 |
| South sorting | Visible South cards sort Hearts, Clubs, Diamonds, Spades and 2 through Ace. | PRD-006 |
| Suit presentation | Hearts/Diamonds map to `suitWarm` and `color.card.suit.red`; Clubs/Spades map to `suitNeutral` and `color.card.suit.black`. | PRD-006, NFR-005 |
| Token boundary | Presentation values expose semantic roles or token keys instead of concrete color values. | PRD-006, PRD-010, NFR-003, NFR-005 |
| Table title presentation | Title maps to table-title font, fixed font size, tracking range, text color/opacity tokens, and shadow tokens. | PRD-001, PRD-010 |
| Card size config | Exposed and hidden player cards share the same base dimensions when represented in presentation config. | PRD-006, PRD-007, PRD-011 |
| Initial deck stack presentation | Initial stack represents 52 hidden cards, uses hidden-card asset, is visible only before deal, and exposes no ranks/suits. | PRD-005, PRD-010 |
| Hidden hand presentation | Simulated hands expose hidden count/back presentation but no rank or suit values. | PRD-007 |
| Action labels | Visible/accessibility labels use `Deal` and `New Game`, and never `Deal Cards` or `New Deal`. | PRD-001, PRD-008, PRD-009, PRD-012, PRD-013 |

Shuffle tests should not depend on random output being different on every run.
Use a deterministic injected shuffler for exact chunk assignment tests.

### 10.2 UI Tests

UI tests should verify user-facing behavior and layout-critical elements.

| Scenario | Assertions | Requirements Covered |
| --- | --- | --- |
| Initial launch | App remains portrait; `طرنيب`, bottom `New Game` and `Deal`, four stations, central table, and central deck stack are visible; dealt hands are absent. | PRD-001, PRD-002, PRD-010, PRD-011, PRD-012 |
| Old labels absent | `Deal Cards` and `New Deal` are absent before and after deal. | PRD-012 |
| Central table geometry | Circular table is visible and its diameter is half the screen width within a defined test tolerance. | PRD-010 |
| Table title placement | `طرنيب` appears centered on the card table and not as a top page title. | PRD-001, PRD-010 |
| Initial deck stack | Stack represents 52 hidden cards, sits below the table title, and reveals no ranks or suits. | PRD-010 |
| Station layout | North above, West left, South below, East right; stations read as rounded squares around the table. | PRD-002, PRD-011 |
| Deal action | Tapping `Deal` shows South hand with 13 visible cards, hides central deck stack, and displays `Deal complete`. | PRD-005, PRD-006, PRD-008, PRD-010 |
| South expansion | After deal, South station expands below the card table and does not cover the bottom control area. | PRD-006, PRD-011, PRD-012 |
| Simulated hands | West, North, and East each show or represent 13 hidden card backs; ranks and suits are absent for those seats. | PRD-007 |
| Completion placement | `Deal complete` appears above the bottom control row. | PRD-008, PRD-012 |
| Replacement deal | Tapping `Deal` after completion replaces the previous completed deal with another valid displayed deal and keeps old labels absent. | PRD-009, PRD-012 |
| New Game reset | Tapping `New Game` after completion clears dealt cards, hides `Deal complete`, restores the central deck stack below the title, and leaves `Deal` ready for a new first deal. | PRD-013 |
| New Game on launch | Tapping `New Game` before dealing leaves the initial table unchanged and does not deal hands. | PRD-013 |
| Prohibited controls | Bid, pass, trump/Tarneeb suit, play-card, trick, scoring, and game-over UI are absent. | PRD-008 |
| Small screen | On the smallest supported simulator, labels, cards, hidden backs, completion message, and bottom controls remain usable. | PRD-011, NFR-005 |
| Responsiveness | Deal and replacement deal complete quickly enough that UI tests can continue interacting without long waits. | NFR-002 |

Token, rendered-color, font, shadow, and precise layout assertions may require one
of these approaches:

- Expose stable accessibility identifiers or values for token keys, title
  typography roles, suit color roles, card counts, and card size categories.
- Use view inspection if available in the test stack.
- Use snapshot or screenshot comparison for manual/automated visual review.
- Combine UI tests for existence/usability with manual visual QA for rendered
  token output and layout details that XCTest cannot robustly inspect.

### 10.3 Manual Visual QA

Manual visual QA should verify:

- The app remains portrait when the device rotates.
- The circular card table is centered in the intended table area and appears
  about half the screen width.
- The `طرنيب` title is centered on the card table rather than placed as a
  large top title.
- The title uses the table-title font, 26pt size, tracking range,
  token-backed title color, token-backed title opacity, and subtle
  token-backed shadow.
- The initial 52-card deck stack appears as a non-fanned stack just below the
  title on the card table and does not obscure the title.
- The initial deck stack disappears after tapping `Deal`.
- Player stations read as rounded squares surrounding the table: North top, West
  left, South bottom, East right.
- Hearts and Diamonds render with the `suitWarm` role backed by
  `color.card.suit.red`.
- Clubs and Spades render with the `suitNeutral` role backed by
  `color.card.suit.black` and remain distinct from `suitWarm`.
- Table, text, station, card, action, title, and title-shadow styling matches
  token usage from `specs/003-mvp/design-tokens.md`.
- East, North, and West stations look compact compared with the expanded South
  station after deal.
- The South station expands below the card table after deal and exposed cards
  remain readable.
- Hidden card backs are the same base size as exposed player cards and are large
  enough to resemble cards.
- Exposed cards look like standard playing cards and remain readable.
- `Deal complete` appears above the bottom control row.
- The bottom control row shows `New Game` next to `Deal` before and after dealing.
- Tapping `New Game` after a deal restores the launch state with no dealt hands
  and the central deck stack visible again.
- Small-screen layout remains usable and avoids incoherent overlap.
- Deal and replacement-deal interactions remain responsive.

### 10.4 Full Verification

Before marking MVP 003 done:

1. Run the full domain unit suite.
2. Run presentation-mapping unit tests for token usage, action labels, card size,
   table-title presentation, deck stack state, and reset presentation state.
3. Run the full UI suite on a primary portrait simulator.
4. Run layout-focused UI tests on the smallest supported simulator available to
   the project.
5. Perform manual visual QA for token-backed styling, title treatment, central
   deck stack, card sizing, compact stations, South expansion, bottom control,
   and portrait behavior.

## 11. Requirement Traceability

| Requirement | Design Coverage |
| --- | --- |
| PRD-001 App Launch | Architecture data flow, initial screen, table title presentation, state transitions, UI tests. |
| PRD-002 Player Seats | Domain seat/player model, player setup, rounded-square station presentation, station layout. |
| PRD-003 Deck Creation | Card model, deck creation design, unit tests. |
| PRD-004 Shuffle | Shuffle abstraction, shuffle design, deterministic test guidance. |
| PRD-005 Deal Cards | Card assignment, validation invariants, deck stack hiding, deal UI tests. |
| PRD-006 Human Hand Display | Card presentation model, South station expansion, exposed card UI, token-backed suit presentation tests. |
| PRD-007 Simulated Player Display | Hidden hand presentation, hidden card stack UI, edge cases. |
| PRD-008 Deal Completion State | Dealt screen, bottom deal control, prohibited UI, state transitions. |
| PRD-009 Replacement Deal | Replacement-deal design, edge cases, tests. |
| PRD-010 Central Card Table | Circular table view, table-title presentation, central deck stack, geometry UI tests. |
| PRD-011 Station Layout and Visual Sizing | Station layout, shared card sizing, compact stations, South expansion, small-screen testing. |
| PRD-012 Bottom Controls | Bottom controls presentation, state transitions, action label tests. |
| PRD-013 New Game Reset | Bottom controls presentation, reset state transition, edge cases, unit/UI reset tests. |
| NFR-001 Platform | App shell and orientation policy, portrait UI tests. |
| NFR-002 Responsiveness | Data flow, responsiveness UI tests, full verification. |
| NFR-003 Testability | Presentation mapping, stable identifiers, unit/UI test split. |
| NFR-004 Reliability | Validation invariants and domain tests. |
| NFR-005 Visual Usability | Token-backed card presentation, manual visual QA, small-screen tests. |

## 12. Ambiguities and Open Questions

These items are intentionally flagged rather than guessed:

| Topic | Ambiguity |
| --- | --- |
| Exact card dimensions | Requirements specify readable standard-card dimensions and about a 5:7 ratio, but no point sizes or breakpoints. |
| Initial deck stack card size | Requirements require a 52-card hidden deck stack on a half-width table, but do not state whether this stack must use the exact same base size as player hidden cards. |
| Smallest supported simulator | Requirements say at least one small-screen simulator but do not name a required device. |
| Portrait lock mechanism | Requirements state portrait-only behavior but do not specify whether this belongs in app metadata, app delegate configuration, SwiftUI scene policy, or another mechanism. |
| Bottom control placement | Requirements say "very bottom", but do not define safe-area bottom, absolute screen bottom, or bottom of scrollable content. |
| Card table vertical position | Requirements say center of screen and center of the main table area, but the bottom control area affects visual centering. |
| Table geometry tolerance | Requirements specify half the screen width but do not define UI-test tolerance for device scale, safe areas, or layout rounding. |
| Station dimensions | Requirements specify rounded squares but do not define side length, corner radius, stroke width, padding, or compact size ratios. |
| South station shape after expansion | Requirements say stations are rounded squares and South expands after deal; they do not specify whether expanded South must remain square or become a rounded rectangle. |
| Table-title tracking value | Requirements provide a range, not a single required value. |
| Hidden hand stack spread | Requirements allow simulated hidden hands to use compact overlap but do not define offset, overlap, or whether all backs must be individually visible. |
| Automated token verification | Requirements ask for visual distinction and token-backed values, but XCTest may not inspect rendered token output directly without additional test tooling. |
| Automated geometric verification | Requirements specify table/station relationships but do not provide exact coordinates, size ratios, or tolerances. |
| Dynamic Type and accessibility | Requirements limit accessibility beyond standard iOS controls, so custom VoiceOver wording, Dynamic Type scaling targets, and contrast ratios are not fully specified. |
| Error handling UX | Requirements keep error handling out of scope beyond preventing invalid completed states; no user-facing error screen is specified for internal validation failures. |
| Font fallback | Requirements specify `SF Arabic Rounded Bold` but do not specify an approved fallback if that font is unavailable on a target device. |
