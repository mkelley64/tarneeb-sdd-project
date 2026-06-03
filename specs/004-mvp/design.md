# Tarneeb iOS MVP 004 Design

## 1. Overview

This design covers the Tarneeb MVP 004 requirements in `requirements.md`.
The gameplay scope remains deal-only: the app launches, randomly selects a
dealer from the four seats, shows one human seat and three simulated seats, lets
the human player deal cards, displays the completed deal, supports
counterclockwise dealer rotation for replacement deals, and allows a new-game
reset. No bidding, passing, Tarneeb suit selection, trick play, scoring,
persistence, multiplayer, or AI decision-making is introduced.

MVP 004 carries forward the portrait card-table scene and adds dealer
selection, dealer badge indication, very-centered squared undealt deck
placement, counterclockwise dealer rotation, and the 13-card stack deal
animation:

- The app is locked to portrait orientation.
- A circular card table appears in the center area with diameter equal to half
  the screen width.
- The Arabic title `طرنيب` is centered on the card table and uses the table-title
  typography and effect tokens from `design-tokens.md`.
- A new game randomly selects exactly one dealer from South, East, North, and
  West.
- Before a deal, a squared stack of 52 hidden cards appears at the
  very center of the card table, remains inside the circular table, and keeps a
  buffer from the table edge.
- The selected dealer station displays a small circular badge in its upper-left
  corner. The badge uses the same color as the `Deal` button and contains a
  white `D`.
- Dealer indication does not change player station outlines; station outlines
  remain at the default station outline color.
- After a deal, the undealt deck stack disappears and the dealer badge remains
  visible on the current dealer's station until the next deal request advances
  the dealer.
- When `Deal` is tapped, four animated 13-card hidden stacks move from the
  table center to each station, starting with the player on the dealer's right
  and continuing counterclockwise. A station reveals its final dealt display
  after its stack arrives.
- Replacement deals rotate dealer counterclockwise in the order South, East,
  North, West, then South.
- Player stations are rounded squares surrounding the card table.
- After a deal, the South station expands below the card table to show the
  human player's revealed hand.
- The user-facing deal action label is `Deal`, both before the first deal and
  after a completed deal.
- A separate `New Game` reset action sits next to `Deal` and restores a launch
  state without immediately dealing.
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
| SwiftUI presentation | Render the table scene, circular table, table title, very-centered squared undealt deck stack, animated 13-card deal stacks, dealer badge, player stations, card faces, hidden card backs, deal status, and bottom controls. | Owns layout and transient animation only; it must not create decks, assign cards, or select dealers. |
| Presentation state | Own current game state and expose the visible `Deal` and `New Game` actions. | `Deal` routes to first deal or replacement deal based on phase; `New Game` resets to `notStarted` and selects a new-game dealer. |
| Presentation mapping | Convert domain cards/seats into display values such as suit text, token-backed color role, sorted South hand, card size config, dealer badge presentation, deck stack presentation, deal-animation sequence, layout metrics, and accessibility identifiers. | Should be testable without inspecting SwiftUI views where practical. |
| Domain model | Represent suits, ranks, cards, seats, teams, players, hands, game phase, and dealer seat. | UI-independent and unit-testable. |
| Game setup/deal service | Create players, create a valid deck, shuffle, deal 13-card chunks, rotate dealer for replacement deals, and validate completed deals. | Core correctness layer. |
| Shuffle abstraction | Wrap Swift's standard shuffle behavior while allowing deterministic test shufflers. | Production should use the standard Swift shuffle method. |
| Dealer selection abstraction | Randomly select the initial dealer while allowing deterministic test selection. | Production should choose one of South, East, North, and West; tests should not rely on true randomness. |
| Asset catalog | Provide `card_back.png` for hidden simulated hands and the initial undealt deck stack. | Must be referenced by a stable asset name. |
| Design token specification | Own all concrete colors, table-title typography, table-title shadow values, dealer badge colors, and undealt deck stack/placement values. | `design.md` references token names and semantic roles only; `design-tokens.md` is the source of truth. |
| Tests | Verify domain invariants, dealer selection/rotation, presentation mapping, portrait/table UI behavior, and absence of prohibited gameplay UI. | UI geometry tests should use tolerances because exact coordinates and table-edge buffer are not specified. |

### 2.2 Data Flow

1. App launches with portrait-only orientation, `phase = notStarted`, exactly
   four empty player seats, a randomly selected `dealerSeat`, and no dealt
   player hands.
2. SwiftUI renders the card-table scene:
   - circular card table in the center area,
   - `طرنيب` title centered on the table,
   - squared 52-card hidden undealt deck stack at the very center of
     the table,
   - selected dealer station with an upper-left circular `D` badge,
   - default station outlines for every station,
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
10. Presentation state holds the validated result as pending presentation data
   while the SwiftUI layer plays the deal animation.
11. The animation presents a 13-card hidden stack moving from the table center
   to the player on the dealer's right.
12. When the stack arrives, that station reveals its final 13-card display and
   animates to its final dealt size.
13. Steps 11 and 12 repeat counterclockwise until all four stations have
   received 13 cards.
14. Presentation state stores the result as `phase = dealt`.
15. Presentation mapping prepares visible South cards, hidden simulated card
   counts, token-backed suit color roles, shared card sizing, default station
   outlines, and a hidden undealt deck stack state.
16. SwiftUI renders the dealt table:
   - undealt deck stack removed,
   - South station expanded below the table with 13 visible cards,
   - West/North/East compact stations with 13 hidden card backs each,
   - `Deal complete` above the bottom control row.
17. If the player taps `Deal` again in `phase = dealt`, presentation state clears
   or replaces previous hands, rotates `dealerSeat` counterclockwise, requests a
   fresh completed deal, plays the same dealer-relative deal animation, and
   remains in `phase = dealt`.
18. If the player taps `New Game` in any phase, presentation state restores the
   launch state: `phase = notStarted`, empty hands, a selected dealer, visible
   title, visible very-centered squared undealt deck stack, dealer badge
   on the selected dealer station, and no completion label.

### 2.3 Primary Components

| Component | Purpose |
| --- | --- |
| App entry point | Hosts the root SwiftUI view and applies portrait-only app support. |
| Root table screen | Displays the full MVP screen in both `notStarted` and `dealt` phases. |
| Table scene layout | Allocates the main table area and bottom control area. |
| Circular card table view | Renders the central circular table at half the screen width. |
| Table title view | Renders `طرنيب` centered on the table using table-title typography and token-backed color/effect roles. |
| Undealt deck stack view | Renders or represents 52 hidden card backs in a squared stack at the very center of the card table before a deal. |
| Deal animation overlay | Renders the transient moving 13-card hidden stack, target order, and center-stack decrement during the deal animation. |
| Player station layout | Places North above, West left, South below, and East right of the circular table. |
| Player station view | Renders a rounded-square station label, token-backed default outline state, optional dealer badge, and either empty content, a visible South hand, or a hidden simulated stack. |
| South hand view | Renders 13 sorted exposed cards after a deal. |
| Card face view | Renders exposed South cards with rank, suit text, token-backed color role, and standard-card aspect ratio. |
| Hidden card back view | Renders `card_back.png` at the shared card size. |
| Hidden hand stack view | Renders 13 hidden card backs for a simulated player, optionally with slight overlap. |
| Bottom controls view | Renders `Deal complete` in dealt state and the bottom `New Game` and `Deal` buttons in all MVP states. |
| Game state owner | Handles the visible `Deal` and `New Game` buttons, owns dealer selection/rotation, and publishes renderable state. |
| Deal service | Performs player setup, deck creation, shuffle, chunk assignment, and validation. |
| Dealer service | Selects initial dealer and rotates dealer counterclockwise for replacement deals. |
| Token resolver | Maps semantic roles to token values defined in `specs/004-mvp/design-tokens.md`. |

### 2.4 MVP Boundary

The completed-deal screen is terminal for gameplay. It may expose the bottom
`Deal` action to produce a replacement deal and the bottom `New Game` action to
reset to launch state, but must not expose bidding, passing, choosing the
Tarneeb suit, playing a card, resolving tricks, scoring, saved games, accounts,
or multiplayer.

### 2.5 Design Token Boundary

`specs/004-mvp/design-tokens.md` is the source of truth for all concrete color,
typography, title-shadow, dealer-badge, and undealt-deck stack/placement values.
This design may name semantic roles and token keys, but must not define hex, RGB,
platform color constants, concrete shadow values, or concrete undealt-deck stack
geometry outside the token file.

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
| `dealerBadgeBackground` | `color.dealerBadge.background` |
| `dealerBadgeText` | `color.dealerBadge.text` |
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
| `undealtDeckAnchorX` | `layout.undealtDeck.anchor.x` |
| `undealtDeckAnchorY` | `layout.undealtDeck.anchor.y` |
| `undealtDeckCenterOffsetX` | `layout.undealtDeck.centerOffset.x` |
| `undealtDeckCenterOffsetY` | `layout.undealtDeck.centerOffset.y` |
| `undealtDeckStackRotation` | `layout.undealtDeck.stack.rotation` |
| `undealtDeckStackOffsetX` | `layout.undealtDeck.stack.offset.x` |
| `undealtDeckStackOffsetY` | `layout.undealtDeck.stack.offset.y` |
| `undealtDeckEdgeBufferMinimum` | `layout.undealtDeck.edgeBuffer.min` |
| `dealStackFlightDuration` | `animation.deal.stack.flight.duration` |
| `dealStationExpansionDuration` | `animation.deal.station.expand.duration` |
| `dealStepPauseDuration` | `animation.deal.step.pause.duration` |

The MVP 004 deal action is always labeled `Deal` and should use the primary
deal button tokens. The reset action is always labeled `New Game` and should use
the secondary new-game button tokens. Dealer indication should use
`color.dealerBadge.background` and `color.dealerBadge.text`; the badge
background is kept matched to `color.button.deal.background` by the token file.
Dealer indication must not change any player station outline to blue.

If implementation or later design work needs a color, font, effect, or
undealt-deck layout value not represented by these tokens, update
`specs/004-mvp/design-tokens.md` first and reference the new token from this
design afterward.

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
004 still does not use rank strength for trick play.

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

Dealer rotation uses the same counterclockwise model order:

1. South
2. East
3. North
4. West
5. South, repeating

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
| `notStarted` | Four seats exist, one dealer is selected, and no deal has completed. | Card table, table title, dealer badge on the selected station, very-centered squared undealt 52-card hidden deck stack, empty rounded-square stations with default outlines, bottom `New Game` and `Deal`. |
| `dealt` | A valid deal has completed. | Card table, current dealer badge remains visible, no undealt deck stack, expanded South hand, hidden simulated hands, `Deal complete`, bottom `New Game` and `Deal`. |

No additional phases are part of MVP 004 unless product later requires an
intermediate replacement-dealer preview state.

### 3.7 Game State

| Field | Requirement |
| --- | --- |
| `phase` | Must be `notStarted` or `dealt`. |
| `players` | Exactly four players in both phases. |
| `dealerSeat` | Exactly one of `south`, `east`, `north`, or `west`. Randomly selected for a new game and rotated counterclockwise for replacement deals. |
| `deck` | Optional to retain; if retained after dealing, ownership semantics must be clear. |

For a completed deal, the source of truth should be the four player hands. If a
deck is retained after dealing, it should represent either an empty undealt deck
or an immutable source/audit deck, not another owner of cards.

The initial 52-card undealt deck stack does not require a new game phase. It can
be derived from `phase = notStarted` and `dealerSeat` as presentation state,
provided tests can verify that it represents 52 hidden cards, appears at the
very center of the card table, uses the tokenized squared-stack geometry, stays inside
the card table with a buffer, and disappears after `phase = dealt`.

### 3.8 Transient Deal Animation State

The deal animation is presentation state, not a persisted game phase. The
validated completed deal should be available as pending render data while
animation is running, but the domain still exposes only `notStarted` and
`dealt`.

| Field | Requirement |
| --- | --- |
| `dealerSeat` | Current dealer for the deal being animated. |
| `targetOrder` | Starts with the player on the dealer's right and continues counterclockwise. |
| `activeStepIndex` | Zero-based index for the current 13-card stack movement. |
| `movingStackVisible` | True while the current 13-card stack is moving from the center deck to the target station. |
| `deliveredSeats` | Seats whose animated stack has arrived and whose final dealt display can be shown. |
| `pendingDealtState` | Valid completed deal result to reveal station-by-station. |

The animation order is:

| Dealer | Target Order |
| --- | --- |
| South | East, North, West, South |
| East | North, West, South, East |
| North | West, South, East, North |
| West | South, East, North, West |

The moving stack should render as an overlay at the full table-scene layer,
not only inside the circular table view, so it visually travels from the
center deck over the table layout and into each player station.

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
| `deckAnchor` | Uses `layout.undealtDeck.anchor.x` and `layout.undealtDeck.anchor.y` for exact table-center anchoring. |
| `deckCenterOffset` | Uses `layout.undealtDeck.centerOffset.x` and `layout.undealtDeck.centerOffset.y`; offsets remain zero unless requirements change. |
| `deckStackRotation` | Uses `layout.undealtDeck.stack.rotation` for the squared-stack geometry. |
| `deckStackOffset` | Uses `layout.undealtDeck.stack.offset.x` and `layout.undealtDeck.stack.offset.y` for per-card squared-stack offset. |
| `deckEdgeBuffer` | Uses `layout.undealtDeck.edgeBuffer.min` as the minimum distance between undealt deck stack bounds and circular table edge. |

Exact point values are intentionally not specified in the requirements. The
implementation should use the tokenized values from `design-tokens.md` for
undealt-deck stack/placement geometry and choose any remaining responsive values
with visual and UI-test verification where practical.

### 4.3 Undealt Deck Stack Presentation

The initial undealt deck stack should be display-only presentation derived from
`phase = notStarted`.

| Field | Requirement |
| --- | --- |
| `hiddenCardCount` | Exactly 52 before a deal. |
| `assetName` | Stable reference to `card_back.png`. |
| `isVisible` | True only in `notStarted`; false in `dealt`. |
| `layout` | Positioned at the very center of the card table using `layout.undealtDeck.anchor.*` and zero center-offset tokens. |
| `titleOverlap` | Allowed before the deal; the stacked undealt deck may visually overlap or obscure the centered title. |
| `tableEdgeBuffer` | Must keep the deck inside the circular card table with an appropriate buffer from the edge. |
| `stackOffset` | Must use the squared-stack offset tokens from `layout.undealtDeck.stack.offset.*`; both values are zero for MVP 004. |
| `rotation` | Must use the squared-stack rotation token from `layout.undealtDeck.stack.rotation`; the value is zero for MVP 004. |
| `revealsCardIdentity` | Always false. |
| `accessibilityValue` | Should expose enough metadata for UI tests to verify count, very-centered placement, stack token usage, table-edge buffer, and hidden-card representation. |

Whether the initial 52-card stack must use the exact same base dimensions as
player hidden hands is ambiguous because the table diameter is constrained to
half the screen width and the stack must share the table center with the title
while maintaining an edge buffer and a squared-stack geometry. This ambiguity is listed
in section 12.

### 4.4 Deal Animation Presentation

The deal animation presentation is display-only metadata derived from the
current dealer and the pending completed deal.

| Field | Requirement |
| --- | --- |
| `cardsPerStack` | Exactly 13. |
| `totalCards` | Exactly 52 across four movements. |
| `targetOrder` | Dealer-relative order, beginning at the dealer's right and continuing counterclockwise. |
| `movingStack` | 13 hidden card backs using `card_back.png`; no ranks or suits exposed. |
| `centerStackCount` | Remaining center cards during animation; must be 0 after the fourth movement resolves. |
| `timingTokens` | Use `animation.deal.*` timing tokens from `design-tokens.md`. |
| `accessibilityValue` | Should expose count, hidden-card asset, center-deck origin, player-station destination, target seat, direction, and target order for UI tests. |

When a moving stack arrives, the target station may reveal the final hand
presentation from `pendingDealtState`. The animation must not create partial
domain hands or bypass completed-deal validation.

### 4.5 Table Title Presentation

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
| `zIndex` | Presentation layout | Title may sit below the initial squared undealt deck stack before the deal. |
| `accessibilityIdentifier` | Presentation mapping | Stable identifier for UI tests. |

The requirements specify title font family, fixed point size, title color,
title opacity, and shadow values. These values must stay in the token spec.

### 4.6 Player Station Presentation

| Station | Content Before Deal | Content After Deal | Size Intent |
| --- | --- | --- | --- |
| South | Label only in a rounded-square station; dealer badge if `dealerSeat = south`; default outline | Label plus 13 exposed sorted cards; station expands below the table; dealer badge remains if South is current dealer; default outline | Largest station after deal because it contains the human hand. |
| North | Label only in a rounded-square station; dealer badge if `dealerSeat = north`; default outline | Label plus hidden stack/count of 13 backs; dealer badge remains if North is current dealer; default outline | Compact station. |
| West | Label only in a rounded-square station; dealer badge if `dealerSeat = west`; default outline | Label plus hidden stack/count of 13 backs; dealer badge remains if West is current dealer; default outline | Compact station. |
| East | Label only in a rounded-square station; dealer badge if `dealerSeat = east`; default outline | Label plus hidden stack/count of 13 backs; dealer badge remains if East is current dealer; default outline | Compact station. |

Before deal, all stations should read as rounded squares. After deal, South
expands below the card table; whether it must remain a square after expansion is
not specified and is flagged in section 12.

### 4.7 Dealer Presentation

Dealer presentation should be derived from `dealerSeat`.

| Field | Requirement |
| --- | --- |
| `dealerSeat` | Exactly one of South, East, North, or West. |
| `showsDealerBadge` | True for the current dealer station in both `notStarted` and `dealt`; false for all non-dealer stations. |
| `badgeShape` | Small circle. |
| `badgePlacement` | Upper-left corner of the dealer's player station. |
| `badgeText` | `D`. |
| `badgeBackgroundRole` | `dealerBadgeBackground`. |
| `badgeBackgroundToken` | `color.dealerBadge.background`; this token matches `color.button.deal.background`. |
| `badgeTextRole` | `dealerBadgeText`. |
| `badgeTextToken` | `color.dealerBadge.text`. |
| `defaultOutlineRole` | `stationOutline`. |
| `defaultOutlineToken` | `color.station.outline`. |
| `nextDealerSeat` | Counterclockwise next seat using South -> East -> North -> West -> South. |
| `accessibilityValue` | Should expose dealer badge state for tests without adding visible instructional copy beyond the badge itself. |

### 4.8 Bottom Controls Presentation

| Field | Requirement |
| --- | --- |
| `dealButtonLabel` | Always `Deal`. |
| `newGameButtonLabel` | Always `New Game`. |
| `buttonPlacement` | Bottom control row at the bottom of the screen or bottom safe-area region; exact interpretation is ambiguous. |
| `dealButtonTokens` | Primary deal button tokens from `design-tokens.md`. |
| `newGameButtonTokens` | Secondary new-game button tokens from `design-tokens.md`. |
| `completionLabel` | `Deal complete`, visible only in `dealt`. |
| `completionPlacement` | Above the bottom control row in `dealt`. |
| `oldLabels` | `Deal Cards` and `New Deal` must not appear in MVP 004 UI. |
| `disabledDuringDealAnimation` | Prevent overlapping `Deal` or `New Game` while a transient deal animation is running. |

Internally, the visible `Deal` action can map to either "first deal" or
"replacement deal" based on phase. That internal distinction should not leak into
button text, accessibility label text, or visible UI.

The visible `New Game` action maps to reset only. In `dealt`, it clears all
hands, hides `Deal complete`, selects a dealer for the new game, restores the
very-centered squared undealt deck stack, shows the dealer badge on the
selected station, and returns the presentation to `notStarted`. In `notStarted`,
it leaves the app in `notStarted` and must not start a deal. Whether it
re-randomizes the current dealer is ambiguous.

### 4.9 Layout Metrics Presentation

The presentation layer should centralize layout calculations so tests can inspect
or infer them where practical.

| Metric | Requirement |
| --- | --- |
| `tableDiameter` | Half the current screen width. |
| `tableCenter` | Centered in the main table area; exact vertical center is ambiguous. |
| `stationCornerRadius` | Rounded-square appearance; exact radius is ambiguous. |
| `stationSideLength` | Rounded-square station sizing before deal; exact size is ambiguous. |
| `undealtDeckAnchor` | Exact center placement on the circular card table using `layout.undealtDeck.anchor.*` and zero center-offset tokens. |
| `undealtDeckStack` | Squared-stack geometry using `layout.undealtDeck.stack.*` tokens. |
| `undealtDeckEdgeBuffer` | Distance from the stacked undealt deck bounds to the circular table edge using `layout.undealtDeck.edgeBuffer.min`. |
| `dealerBadgeInset` | Upper-left station inset for the circular dealer badge; exact value is ambiguous. |
| `dealerBadgeSize` | Small circular badge size; exact value is ambiguous. |
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

### 5.4 Dealer Selection and Rotation

Dealer selection and rotation must be independent from shuffle randomness so each
behavior can be tested separately.

Initial new-game selection:

1. Select exactly one dealer from South, East, North, and West.
2. Use an injectable random source or selector abstraction for testability.
3. Store the selected seat as `dealerSeat`.
4. Render the squared undealt deck stack at the very center of the
   card table before a deal.
5. Render a circular `D` badge in the upper-left corner of the selected dealer
   station, using dealer badge tokens.
6. Keep every player station outline at the default station outline color.

Counterclockwise replacement rotation:

| Current Dealer | Next Dealer |
| --- | --- |
| South | East |
| East | North |
| North | West |
| West | South |

The requirements do not specify whether dealer affects card assignment order, so
MVP 004 keeps the carried-forward chunk assignment order unchanged and treats
dealer as table-state indication and rotation only. This is flagged again in
section 12.

### 5.5 Card Assignment

The product requirements specify dealing one 13-card chunk to each player. The
deal service should produce a completed deal by:

1. Ensuring `dealerSeat` is present.
2. Starting from a shuffled 52-card deck.
3. Splitting the deck into four 13-card chunks.
4. Assigning one chunk to each player using model order South, East, North, West.
5. Marking the game state as `dealt`.
6. Hiding the undealt deck stack.
7. Keeping all station outlines at the default station outline.
8. Keeping the current dealer badge visible until the next deal request advances
   the dealer.
9. Validating no cards remain undealt and no duplicates were assigned.

Tests that assert exact card ownership should use deterministic shuffle input
and the South, East, North, West chunk-to-seat order.

The visual animation order is separate from card ownership assignment. It should
use the current `dealerSeat` to target the player on the dealer's right first,
then continue counterclockwise, while revealing the already validated completed
deal station-by-station.

### 5.6 Replacement Deal

The visible `Deal` action should be available in the dealt state. When invoked:

1. Previous hands are cleared or replaced.
2. The dealer rotates counterclockwise from the previous `dealerSeat`.
3. A fresh full deck is created or the previous full deck is reset.
4. The deck is shuffled.
5. Cards are assigned into four 13-card chunks.
6. The new completed deal is validated.
7. The same four-step 13-card stack animation plays from the table center.
8. The presentation remains in `phase = dealt` after the animation resolves.
9. The undealt deck stack remains hidden after completion.
10. All station outlines remain default after the completed replacement deal.
11. The dealer badge remains visible on the rotated current dealer.
12. The `Deal complete` label remains above the bottom control row.
13. The UI continues to use the portrait table layout, rounded-square stations,
   shared card sizing, and token-backed suit presentation rules.

Replacement `Deal` should use transient animation state rather than a new domain
phase. The rotated dealer and pending completed deal may be staged for animation
before the final `dealt` presentation replaces the old hands.

### 5.7 New Game Reset

The visible `New Game` action should be available in both MVP phases. When
invoked:

1. Presentation state returns to `phase = notStarted`.
2. The four canonical seats remain present as South, West, North, and East.
3. A dealer is selected for the new game.
4. All player hands are cleared.
5. The South expanded hand, simulated hidden hands, and `Deal complete` label are
   hidden.
6. The squared 52-card undealt deck stack is visible at the very
   center of the card table.
7. The selected dealer station displays the dealer badge.
8. All player station outlines remain default.
9. No new deal is created until the player taps `Deal`.

## 6. UI Design

### 6.1 Root Layout

The root screen should be portrait-only and organized into two conceptual areas:

- A main table scene containing the circular table, table title, optional
  very-centered squared undealt deck stack, dealer badge, and player
  stations.
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
- Exactly one randomly selected dealer.
- Circular dealer badge in the upper-left corner of the selected dealer station,
  using `color.dealerBadge.background` and `color.dealerBadge.text`.
- Default station outlines for all player stations.
- Squared 52-card hidden undealt deck stack at the very center of
  the card table, inside the circular table edge buffer.
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
- Undealt 52-card deck stack is absent.
- Four player stations continue to surround the card table.
- All station outlines use the default station outline.
- Current dealer station continues to show the circular `D` badge until the next
  deal request advances the dealer.
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
- Contain the initial 52-card undealt deck stack before deal.
- Keep the initial undealt deck stack at the very center of the card table,
  inside the circular table edge buffer; it may layer above and obscure the
  title before the deal.
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
- May be visually obscured by the initial squared undealt deck stack before the
  deal because both occupy the table center.
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
- Before and after deal, every station uses the default station outline for
  dealer indication.
- Exactly one station, the current dealer, shows the circular dealer `D` badge.
- The dealer badge uses `color.dealerBadge.background`, which matches the
  `Deal` button background, and `color.dealerBadge.text`.
- The badge remains visible on the current dealer until the next deal request
  advances the dealer.
- After deal, South expands below the table because it displays all exposed
  human cards.
- North, West, and East should be compact and sized around their labels plus
  hidden card arrays.
- Station labels should remain readable and should not collide with cards.
- The bottom controls should remain reachable and should not cover cards.
- On a small supported simulator, spacing may compress or the table may scroll,
  but labels, cards, message, and available controls must remain usable.

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

The initial undealt deck stack must:

- Use `card_back.png` or equivalent hidden-card presentation backed by that
  asset.
- Represent exactly 52 hidden cards.
- Use the tokenized squared-stack geometry defined by `layout.undealtDeck.stack.*`.
- Sit at the very center of the circular card table using
  `layout.undealtDeck.anchor.*` and zero center-offset tokens.
- Remain inside the circular table with an appropriate buffer from the table
  edge.
- May overlap or obscure the title before the deal.
- Disappear after the deal completes.
- Never expose rank or suit text/symbols.

Hidden hands may use overlap to conserve space. The undealt deck stack should
use the squared-stack geometry tokens while tests or accessibility metadata verify the
required hidden-card count, center placement, stack token usage, and no card
identities are revealed.

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
- Reset to a launch state when `New Game` is tapped.
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
| App launch | None | Create four empty canonical seats, randomly select one dealer, show `notStarted` in portrait, show the dealer badge, and place the squared undealt deck stack at the very center of the card table. |
| `notStarted` | Tap visible `Deal` | Create a fresh valid deal, hide undealt deck stack, keep all station outlines default, keep the current dealer badge visible, and move to `dealt`. |
| `notStarted` | Tap visible `New Game` | Remain in `notStarted`; no deal starts. Dealer re-randomization is ambiguous. |
| `dealt` | Tap visible `Deal` | Clear/replace previous hands, rotate dealer counterclockwise, create a fresh valid deal, keep undealt deck stack hidden, keep station outlines default, show the badge on the rotated dealer, remain in `dealt`. |
| `dealt` | Tap visible `New Game` | Clear all hands, select a dealer for the new game, hide dealt UI, restore the squared undealt deck stack at the very center of the card table, show the dealer badge, and move to `notStarted`. |
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
- `dealerSeat` is exactly one of South, East, North, or West.
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
- Exactly one dealer is selected in `notStarted`.
- Exactly one station shows the dealer badge in `notStarted` and `dealt`.
- The dealer badge uses `color.dealerBadge.background` and
  `color.dealerBadge.text`.
- All stations use the default station outline for dealer indication.
- The initial undealt deck stack represents exactly 52 hidden cards.
- The undealt deck stack is visible only before a deal.
- The undealt deck stack appears at the very center of the card table in
  `notStarted`.
- The undealt deck stack uses the tokenized squared-stack geometry in `notStarted`.
- The undealt deck stack remains inside the circular card table with a table-edge
  buffer.
- South displays exactly 13 exposed cards after a deal.
- West, North, and East each display or represent exactly 13 hidden card backs
  after a deal.
- Simulated card ranks and suits are not visible.
- Hearts and Diamonds use `suitWarm`, resolved through `color.card.suit.red`.
- Clubs and Spades use `suitNeutral`, resolved through
  `color.card.suit.black`.
- All colored, typographic, station-outline, title-shadow, and undealt-deck
  layout/stack UI values reference tokens from
  `specs/004-mvp/design-tokens.md`; no concrete color or undealt-deck stack
  geometry values are defined in this design.
- Exposed and hidden player cards use the same base card size.
- Player stations preserve the table-surrounding relationship.
- The `Deal complete` label appears above the bottom control row in `dealt`.
- Tapping `New Game` returns display state to `notStarted`, clears all hands,
  hides completion text, selects a dealer, shows the dealer badge, and restores
  the squared undealt deck stack at the very center of the card
  table.

## 9. Edge Cases

| Edge Case | Expected Handling |
| --- | --- |
| User taps `Deal` repeatedly in `notStarted` | Prevent overlapping deals; each accepted tap should result in one complete valid deal. |
| User taps `Deal` repeatedly in `dealt` | Previous hands are cleared/replaced, dealer rotation advances once per accepted replacement deal, and the result is another valid completed deal. |
| User taps `Deal` during the deal animation | Ignore or disable the action until the animation resolves; do not create overlapping animations or advance dealer more than once. |
| User taps `New Game` during the deal animation | Ignore or disable the action until the animation resolves; do not leave partial hands on screen. |
| User taps `New Game` in `notStarted` | Remain in `notStarted`; do not start a deal. Whether the dealer is re-randomized is ambiguous. |
| User taps `New Game` in `dealt` | Reset to `notStarted`, select a dealer, clear hands, hide `Deal complete`, show the dealer badge, and restore the squared undealt deck stack at the very center of the card table. |
| User taps `New Game` repeatedly | Remain in or return to the launch state without producing partial hands or a completed deal. |
| Random dealer selection returns an invalid seat | Invalid internal state; select only South, East, North, or West. |
| Dealer rotation advances from West | Wrap to South. |
| Dealer indication changes a station outline to blue | Invalid MVP 004 display; dealer indication must use the badge and all station outlines remain default. |
| Undealt deck stack is placed outside table or too close to edge | Invalid MVP 004 display; keep it inside the circular table with a buffer. |
| Undealt deck stack is offset away from the table center before deal | Invalid MVP 004 display; keep its center point aligned with the circular table center within layout tolerance. |
| Undealt deck stack renders with visible fan, spread, or rotation before deal | Invalid MVP 004 display; use tokenized squared-stack geometry with zero stack offset and zero rotation. |
| Shuffle returns same order by chance | Valid if the deck was actually passed through the shuffle operation; tests should not fail solely because random order matches source order. |
| Shuffle implementation loses or duplicates cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 004 scope. |
| Deck creation contains a duplicate or missing card | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 004 scope. |
| Deal assignment leaves undealt cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 004 scope. |
| Any player receives fewer or more than 13 cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 004 scope. |
| Simulated hand exposes card data in UI | Invalid MVP behavior; hidden players must show only `card_back.png` backs or equivalent hidden-card representation. |
| Initial deck stack exposes card data in UI | Invalid MVP behavior; the stack must not reveal ranks or suits. |
| Animated 13-card stack exposes card data in UI | Invalid MVP behavior; the moving stack must use hidden card backs only. |
| Deal animation target order does not start at dealer's right | Invalid MVP 004 animation; use the dealer-relative counterclockwise target order. |
| Deal animation completes with center stack still visible | Invalid MVP 004 display; center stack must be gone after all 52 cards have been dealt. |
| Human hand sorting changes underlying ownership | Sorting must affect display only; it must not duplicate, remove, or reassign cards. |
| Small portrait screen cannot fit generous spacing | Compress spacing or allow scrolling while preserving the table relationship and bottom control usability. |
| Device rotates to landscape | App remains portrait. |
| South station expansion conflicts with bottom controls | Layout must adjust spacing or scrolling so `Deal complete`, `New Game`, and `Deal` remain usable. |
| Card size calculation differs by station | Invalid if player hidden and exposed cards no longer share the same base dimensions. |
| Hidden stack overlap hides most cards | Acceptable only if the required hidden-card count is still represented and the stack remains visibly card-like. |
| Initial 52-card stack obscures the title before deal | Valid MVP 004 display; the title and deck stack share the table center, and the deck may layer above the title. |
| Appearance mode changes token rendering | `suitWarm` and `suitNeutral` must remain visually distinct in the supported appearance mode; do not invent appearance variants outside `design-tokens.md`. |
| `card_back.png` is missing from assets | Hidden player display and undealt deck stack cannot satisfy requirements; implementation should include and reference the asset by stable name. |
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
| Dealer selection | New games select exactly one dealer from South, East, North, and West through an injectable random source. | PRD-001, PRD-014, NFR-003 |
| Dealer rotation | Replacement deals rotate dealer South -> East -> North -> West -> South. | PRD-009, PRD-014 |
| Deal assignment | Four 13-card chunks, all 52 cards assigned, no duplicates, no undealt cards, phase is `dealt`. | PRD-005 |
| Deal animation presentation | Dealer-relative target order starts at dealer's right, uses four 13-card hidden stacks, decrements center-card count, and exposes animation timing token keys. | PRD-005, PRD-015 |
| Replacement deal | Previous hands are cleared/replaced, dealer rotates, and another valid completed deal is produced from the visible `Deal` action. | PRD-008, PRD-009, PRD-012, PRD-014 |
| New Game reset | Visible `New Game` returns the presentation to `notStarted`, selects a dealer, clears hands, hides completion, shows the dealer badge, and restores the squared undealt deck stack at the very center of the table without dealing. | PRD-001, PRD-008, PRD-012, PRD-013, PRD-014 |
| South sorting | Visible South cards sort Hearts, Clubs, Diamonds, Spades and 2 through Ace. | PRD-006 |
| Suit presentation | Hearts/Diamonds map to `suitWarm` and `color.card.suit.red`; Clubs/Spades map to `suitNeutral` and `color.card.suit.black`. | PRD-006, NFR-005 |
| Token boundary | Presentation values expose semantic roles or token keys instead of concrete color values. | PRD-006, PRD-010, PRD-014, NFR-003, NFR-005 |
| Table title presentation | Title maps to table-title font, fixed font size, tracking range, text color/opacity tokens, and shadow tokens. | PRD-001, PRD-010 |
| Card size config | Exposed and hidden player cards share the same base dimensions when represented in presentation config. | PRD-006, PRD-007, PRD-011 |
| Undealt deck stack presentation | Initial stack represents 52 hidden cards, uses hidden-card asset, is visible only before deal, appears at the very center of the card table, uses the tokenized squared-stack geometry, stays inside the table buffer, and exposes no ranks/suits. | PRD-005, PRD-010, PRD-014 |
| Dealer badge presentation | Current dealer station shows a circular `D` badge using dealer badge tokens, all station outlines remain default, and the badge remains visible until the next deal request advances the dealer. | PRD-005, PRD-014, NFR-005 |
| Hidden hand presentation | Simulated hands expose hidden count/back presentation but no rank or suit values. | PRD-007 |
| Action labels | Visible/accessibility labels use `Deal` and `New Game`, and never `Deal Cards` or `New Deal`. | PRD-001, PRD-008, PRD-009, PRD-012, PRD-013 |

Shuffle tests should not depend on random output being different on every run.
Use a deterministic injected shuffler for exact chunk assignment tests.

### 10.2 UI Tests

UI tests should verify user-facing behavior and layout-critical elements.

| Scenario | Assertions | Requirements Covered |
| --- | --- | --- |
| Initial launch | App remains portrait; `طرنيب`, bottom `New Game` and `Deal`, four stations, central table, dealer badge, and very-centered squared undealt deck stack are visible; dealt hands are absent. | PRD-001, PRD-002, PRD-010, PRD-011, PRD-012, PRD-014 |
| Old labels absent | `Deal Cards` and `New Deal` are absent before and after deal. | PRD-012 |
| Central table geometry | Circular table is visible and its diameter is half the screen width within a defined test tolerance. | PRD-010 |
| Table title placement | `طرنيب` appears centered on the card table and not as a top page title. | PRD-001, PRD-010 |
| Undealt deck stack | Stack represents 52 hidden cards, sits at the very center of the card table, uses the tokenized squared-stack geometry, stays inside the table buffer, may obscure the title before deal, and reveals no ranks or suits. | PRD-010, PRD-014 |
| Station layout | North above, West left, South below, East right; stations read as rounded squares around the table; only the current dealer shows the circular badge. | PRD-002, PRD-011, PRD-014 |
| Deal action | Tapping `Deal` shows South hand with 13 visible cards, hides undealt deck stack, keeps station outlines default, keeps the current dealer badge visible, and displays `Deal complete`. | PRD-005, PRD-006, PRD-008, PRD-010, PRD-014 |
| Deal animation | After tapping `Deal`, a transient 13-card hidden stack appears from the table center, exposes dealer-relative counterclockwise target order metadata, and resolves to the completed deal state. | PRD-005, PRD-015 |
| South expansion | After deal, South station expands below the card table and does not cover the bottom control area. | PRD-006, PRD-011, PRD-012 |
| Simulated hands | West, North, and East each show or represent 13 hidden card backs; ranks and suits are absent for those seats. | PRD-007 |
| Completion placement | `Deal complete` appears above the bottom control row. | PRD-008, PRD-012 |
| Replacement deal | Tapping `Deal` after completion rotates dealer, replaces the previous completed deal with another valid displayed deal, and keeps old labels absent. | PRD-009, PRD-012, PRD-014 |
| New Game reset | Tapping `New Game` after completion clears dealt cards, selects a dealer, hides `Deal complete`, restores the squared undealt deck stack at the table center, shows the dealer badge, and leaves `Deal` ready for a new first deal. | PRD-013, PRD-014 |
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
- Exactly one station has the circular dealer `D` badge.
- The dealer badge uses `color.dealerBadge.background`, matching the `Deal`
  button background, and `color.dealerBadge.text`.
- Player station outlines remain default for dealer indication.
- The initial 52-card undealt deck stack appears as a squared stack
  at the very center of the card table.
- The undealt deck stack stays inside the circular table with a buffer; title
  overlap or obscuring by the deck is allowed before the deal.
- The initial deck stack disappears after tapping `Deal`.
- The dealer badge remains visible on the current dealer after tapping `Deal`
  and moves only when the next deal request advances the dealer.
- Dealer rotation follows South, East, North, West for replacement deals where
  state or test metadata exposes it.
- Player stations read as rounded squares surrounding the table: North top, West
  left, South bottom, East right.
- Hearts and Diamonds render with the `suitWarm` role backed by
  `color.card.suit.red`.
- Clubs and Spades render with the `suitNeutral` role backed by
  `color.card.suit.black` and remain distinct from `suitWarm`.
- Table, text, station, dealer badge, card, action, title, and title-shadow styling matches
  token usage from `specs/004-mvp/design-tokens.md`.
- East, North, and West stations look compact compared with the expanded South
  station after deal.
- The South station expands below the card table after deal and exposed cards
  remain readable.
- Hidden card backs are the same base size as exposed player cards and are large
  enough to resemble cards.
- Exposed cards look like standard playing cards and remain readable.
- `Deal complete` appears above the bottom control row.
- The bottom control row shows `New Game` next to `Deal` before and after dealing.
- Tapping `New Game` after a deal restores the launch state with no dealt hands,
  a dealer badge on the selected dealer, and the undealt deck stack visible in
  the very center of the card table.
- Small-screen layout remains usable and avoids incoherent overlap.
- Deal and replacement-deal interactions remain responsive.

### 10.4 Full Verification

Before marking MVP 004 done:

1. Run the full domain unit suite.
2. Run presentation-mapping unit tests for token usage, action labels, card size,
   table-title presentation, dealer state, deck stack state, and reset
   presentation state.
3. Run the full UI suite on a primary portrait simulator.
4. Run layout-focused UI tests on the smallest supported simulator available to
   the project.
5. Perform manual visual QA for token-backed styling, title treatment,
   dealer badge treatment, very-centered squared undealt deck stack, card sizing,
   compact stations, South expansion, bottom control, and portrait behavior.

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
| PRD-010 Central Card Table | Circular table view, table-title presentation, undealt deck stack, geometry UI tests. |
| PRD-011 Station Layout and Visual Sizing | Station layout, shared card sizing, compact stations, South expansion, small-screen testing. |
| PRD-012 Bottom Controls | Bottom controls presentation, state transitions, action label tests. |
| PRD-013 New Game Reset | Bottom controls presentation, reset state transition, edge cases, unit/UI reset tests. |
| PRD-014 Dealer Selection and Rotation | Dealer selection abstraction, dealer badge presentation, very-centered squared deck stack placement, replacement rotation, unit/UI dealer tests. |
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
| Undealt deck edge buffer | Requirements say "appropriate buffer" but do not define an exact point value or ratio. |
| Very-centered deck and title coexistence | Requirements place both the `طرنيب` title and undealt stack at the table center; the deck may overlap or obscure the title before the deal. |
| Undealt deck stack tuning | Requirements require a squared undealt deck stack; any future offset or rotation should be specified in token defaults before implementation changes. |
| Dealer badge geometry | Requirements specify a small circular badge in the upper-left corner, but do not define exact size, inset, text size, or z-order. |
| Dealer badge token source | Requirements say the badge should match the Deal button color and use a white `D`; this design adds `color.dealerBadge.background` and `color.dealerBadge.text` to the MVP 004 token file. |
| Dealer affects assignment | Requirements do not specify whether dealer changes card assignment order; this design preserves the carried-forward chunk assignment order and treats dealer as indication/rotation only. |
| New Game while notStarted | Requirements say tapping `New Game` in the initial screen remains `notStarted`, but do not specify whether dealer should re-randomize. |
| Replacement dealer visibility | Replacement deals now use transient animation state; exact visual timing for the rotated dealer badge before the final replacement deal appears is not otherwise specified. |
| Dealer's right | Requirements do not define table-perspective handedness; this design interprets dealer's right as the next seat in the counterclockwise dealer rotation order. |
| Deal animation timing | Requirements do not define duration, easing, pause timing, or whether the center stack visibly decrements during each flight; use `animation.deal.*` tokens. |
| Station dimensions | Requirements specify rounded squares but do not define side length, corner radius, stroke width, padding, or compact size ratios. |
| South station shape after expansion | Requirements say stations are rounded squares and South expands after deal; they do not specify whether expanded South must remain square or become a rounded rectangle. |
| Table-title tracking value | Requirements provide a range, not a single required value. |
| Hidden hand stack spread | Requirements allow simulated hidden hands to use compact overlap but do not define offset, overlap, or whether all backs must be individually visible. |
| Automated token verification | Requirements ask for visual distinction and token-backed values, but XCTest may not inspect rendered token output directly without additional test tooling. |
| Automated geometric verification | Requirements specify table/station relationships but do not provide exact coordinates, size ratios, or tolerances. |
| Dynamic Type and accessibility | Requirements limit accessibility beyond standard iOS controls, so custom VoiceOver wording, Dynamic Type scaling targets, and contrast ratios are not fully specified. |
| Error handling UX | Requirements keep error handling out of scope beyond preventing invalid completed states; no user-facing error screen is specified for internal validation failures. |
| Font fallback | Requirements specify `SF Arabic Rounded Bold` but do not specify an approved fallback if that font is unavailable on a target device. |
