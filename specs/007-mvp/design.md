# Tarneeb iOS MVP 007 Design

## 1. Overview

This design covers the Tarneeb MVP 007 requirements in `requirements.md`.
The gameplay scope extends the completed deal with a simple post-deal bidding
round: the app launches, randomly selects a dealer from the four seats, shows
one human seat and three simulated seats, lets the human player deal cards,
keeps South card faces hidden until all hands are dealt, keeps any received
South stack visible as fanned backs until reveal time, reveals South with a
backs-first 1.5-second left-to-right flip into imported xCards face artwork,
logs each player's hand for debugging, runs a simplified
bidding round for all four players, and fades the bidding area away.
Numeric bidding completion then shows the high-bidding team, bid value, and
preferred Tarneeb suit symbol; all-pass completion before any numeric bid starts
a fresh automatic deal with the dealer advanced counterclockwise. It also
supports counterclockwise dealer rotation for replacement deals and allows a
new-game reset. South chooses a bid during South's bidding turn; if South ends
as the numeric high bidder, South sets the Tarneeb suit in a short post-bidding
step before the final summary appears. Post-summary editable Tarneeb suit
selection, trick play, scoring,
persistence, multiplayer, and advanced AI decision-making are not introduced.

MVP 007 carries forward the portrait card-table scene, dealer selection, dealer
badge indication, very-centered squared undealt deck placement,
counterclockwise dealer rotation, and the 13-card stack deal animation:

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
  and continuing counterclockwise. Simulated stations reveal hidden card-back
  displays after their stack arrives; if South receives a stack before all four
  stacks arrive, South keeps a slightly fanned hidden-back stack visible while
  still hiding all ranks and suits.
- After all four stacks have arrived and the center deck is gone, the South
  station expands below the card table with 13 card backs, then flips the cards
  face-up left-to-right over 1.5 seconds.
- Replacement deals rotate dealer counterclockwise in the order South, East,
  North, West, then South.
- Player stations are rounded squares surrounding the card table.
- After the South reveal flip completes, the South station remains expanded
  below the card table to show the human player's revealed hand.
- After the South reveal flip completes, a bordered `Bidding` area appears
  under the South station.
- The `Bidding` area contains a bid table with one row or entry for South, East,
  North, and West.
- Every bid entry begins as `--`.
- Bidding starts with the player to the dealer's right and proceeds
  counterclockwise around the table.
- Simulated turns use conservatively calibrated automated hand-strength
  recommendations that consider the player's cards, partner context, current
  highest bid, and prior bid states. Each possible Tarneeb suit is evaluated
  independently with both an optimistic `expectedTricks` estimate and a
  conservative `safeBidCeiling`. The displayed bid is chosen from the legal
  `safeBidCeiling`, not from the optimistic estimate alone. Suit length, side
  honors, and short-suit shape are supporting evidence only, and higher bids
  must pass structural gates for trump control and reliable outside winners.
  Partner-winning context defaults to `Pass`; a partner raise must be at least
  two tricks above the partner's highest bid and satisfy the partner-raise
  guard. Each simulated display update takes at least one second before the
  value changes.
- Phase 2 bidding state stores each accepted numeric bidder's preferred
  trump/Tarneeb suit alongside that bidder's resolved bid value. `Pass` and
  pending `--` states do not carry preferred suit data. South's preferred suit
  is collected only after bidding if South is the numeric high bidder, then
  stored by the post-bidding `Set` action before the final summary appears.
- While bidding is in progress, the South `Bid` button remains visible under
  the South bid value and is disabled unless South's turn is active with a valid
  submission.
- When South's turn is active, South's bid entry is controlled by a bid-chip
  selector containing `Pass` and only currently legal numeric bids through 13.
  Numeric South bids do not require a Tarneeb suit during the in-progress
  bidding round. After South taps `Bid`, the selected value replaces the bid
  chips and the button returns to disabled state unless bidding completes or
  returns to South.
- When bidding completes, the status label changes from `Deal complete` to
  `Bidding complete`, the South `Bid` button disappears completely, and the
  `Bidding` area fades out over one second before being removed.
- If bidding completes with a numeric high bid by East, North, or West, a
  post-bidding summary appears after the fade-out and displays `East-West` or
  `North-South`, the high bid value, and `Tarneeb` with the high bidder's
  preferred suit symbol. If South has the numeric high bid, a post-bidding
  suit-setting panel appears first with white-background suit chips and a `Set`
  button; once South sets the suit, the final summary appears.
- If all four players pass before any numeric bid is accepted, no post-bidding
  summary appears. After the terminal bidding fade, the hand is abandoned and a
  fresh deal starts automatically with the dealer advanced to the previous
  dealer's right using the same counterclockwise rotation.
- Bid value changes use a one-second fade and color transition. The current
  highest numeric bid remains in the same yellow used by the `New Game` button;
  if a higher bid is accepted, the previous high bid transitions back to white.
- The user-facing deal action label is `Deal`, both before the first deal and
  after a completed deal.
- A separate `New Game` reset action sits next to `Deal` and restores a launch
  state without immediately dealing.
- The bottom control row sits at the bottom of the screen, with a status label
  above it. The label shows `Deal complete` after the deal and South reveal
  complete, and `Bidding complete` after the bidding round completes.
- MVP 002 card readability requirements remain: Hearts and Diamonds use the red
  suit role, Clubs and Spades use the dark suit role, and hidden/exposed cards
  share a readable standard-card base size.

## 2. Architecture

### 2.1 Layers

| Layer | Responsibility | Notes |
| --- | --- | --- |
| App shell and orientation policy | Launch the SwiftUI app and restrict supported orientation to portrait. | The exact implementation mechanism is not specified in the requirements and is flagged as an ambiguity. |
| SwiftUI presentation | Render the table scene, circular table, table title, very-centered squared undealt deck stack, animated 13-card deal stacks, dealer badge, player stations, card faces, hidden card backs, South interim fanned-back stack, South delayed reveal backs/flip animation, bidding area, South bid-chip selector, post-bidding South Tarneeb suit-setting panel, post-bidding summary, bidding status label, and bottom controls. | Owns layout, South active-turn controls, post-bidding South suit controls, terminal South button visibility, terminal bidding-area fade, and transient deal/bid animations only; it must not create decks, assign cards, select dealers, score hands, or resolve simulated bid turns. |
| Presentation state | Own current game state and expose the visible `Deal`, `New Game`, South draft bid selection, post-bidding South draft suit selection, enabled South `Bid` actions, and enabled post-bidding `Set` actions. | `Deal` routes to first deal or replacement deal based on phase; `New Game` resets to `notStarted` and selects a new-game dealer; South `Bid` resolves the human bidding turn only while enabled for `Pass` or a legal numeric bid; deal-complete status and bidding initialization wait until the South reveal flip finishes; terminal bidding state drives summary visibility for simulated numeric high bids, South post-bidding suit-setting visibility for South numeric high bids, or automatic redeal for all-pass hands after the fade-out. |
| Presentation mapping | Convert domain cards/seats/bids into display values such as suit text, stable card-face asset names, token-backed color role, sorted South hand, card size config, dealer badge presentation, deck stack presentation, deal-animation sequence, South interim fanned-back visibility, South reveal state/revealed-card count, bidding table presentation, active South bid options, active South suit options, post-bidding summary, layout metrics, and accessibility identifiers. | Should be testable without inspecting SwiftUI views where practical. |
| Domain model | Represent suits, ranks, cards, seats, teams, players, hands, game phase, dealer seat, structured bid states, each accepted numeric bid's preferred trump/Tarneeb suit, current bidding turn, current highest bid, bid recommendation metadata, and post-bidding summary data. | UI-independent and unit-testable. |
| Game setup/deal service | Create players, create a valid deck, shuffle, deal 13-card chunks, rotate dealer for replacement deals and all-pass automatic redeals, log completed hands, and validate completed deals. | Core correctness layer. Hand logging should use an injectable or replaceable log sink. |
| Shuffle abstraction | Wrap Swift's standard shuffle behavior while allowing deterministic test shufflers. | Production should use the standard Swift shuffle method. |
| Dealer selection abstraction | Randomly select the initial dealer while allowing deterministic test selection. | Production should choose one of South, East, North, and West; tests should not rely on true randomness. |
| Bidding service | Resolve the simplified bidding round, including dealer-relative first turn, counterclockwise turn order, simulated bid recommendations, current-highest comparison, service-level partner-raise threshold enforcement, one-second simulated update pacing, terminal `13`, all-pass automatic-redeal outcome, South human bid submission, post-bidding South suit setting when South wins, and high-bid summary derivation. | Production simulated bids come from the automated hand-strength evaluator, but the service must still reject injected, stale, or override recommendations that fail legal bid or partner-raise rules; South numeric high bids receive South's selected Tarneeb suit only from the post-bidding `Set` action; MVP 007 does not include post-summary editable Tarneeb suit selection. |
| Automated bid evaluator | Evaluate simulated hands against possible Tarneeb suits, partner context, current highest bid, and prior bid states. | Produces per-suit diagnostics with `expectedTricks`, `safeBidCeiling`, trump texture, side-winner treatment, short-suit eligibility, high-bid gate results, preferred Tarneeb suit, final recommendation, and confidence metadata. The final bid must come from the conservative safe ceiling and legal/partner filters. Exact hand fixtures in section 5.6 are regression examples for the generalized evaluator, not hand-specific override cases. |
| Hand log sink | Receives completed South, East, North, and West hands in readable rank/suit format after each deal. | Console-only in production and replaceable for tests. |
| Asset catalog | Provide `card_back.png` for hidden simulated hands and the initial undealt deck stack, plus xCards standard 52-card face images named `card_face_<rank><suit>` with `1x`, `2x`, and `3x` variants. | Asset names must be stable; Ten uses `T`, suits use `C`, `D`, `H`, and `S`, and joker faces are excluded. |
| Design token specification | Own all concrete colors, table-title typography, table-title shadow values, dealer badge colors, bidding area colors, post-bidding summary colors, current-highest bid color, bid selector colors, South post-bidding Tarneeb suit selector colors, South bid/Set button colors, bid fade/color timings, bidding-area fade timing, 1.5-second South reveal flip timing, and undealt deck stack/placement values. | `design.md` references token names and semantic roles only; `design-tokens.md` is the source of truth. The one-second bid fade/color, one-second bidding-area fade, summary suit chip, South suit selector, current-highest bid color, and South reveal flip requirements should be reflected in tokens. |
| Tests | Verify domain invariants, dealer selection/rotation, bid values, South bid submission, post-bidding South Tarneeb suit setting, bidding progression, automated bid recommendations, all-pass automatic redeal, presentation mapping, post-bidding summary derivation, hand logging, portrait/table UI behavior, and absence of unsupported gameplay UI. | UI geometry tests should use tolerances because exact coordinates and table-edge buffer are not specified. |

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
10. The completed South, East, North, and West hands are logged to the console
   through the hand log sink in readable rank/suit format.
11. Presentation state holds the validated result as pending presentation data
   while the SwiftUI layer plays the deal animation.
12. The animation presents a 13-card hidden stack moving from the table center
   to the player on the dealer's right.
13. When a stack arrives at West, North, or East, that station shows its final
   hidden 13-card back display and animates to its final dealt size.
14. When a stack arrives at South before all four hands have been dealt, South
   shows a slightly fanned 13-card hidden-back stack and no South rank, suit, or
   card face is exposed.
15. Steps 12 through 14 repeat counterclockwise until all four stations have
   received 13 cards.
16. After the fourth stack arrives, the center deck stack is gone and the South
   reveal animation begins from the pending completed deal.
17. South station expands below the table with 13 card backs, then flips those
   cards face-up left-to-right over 1.5 seconds into the sorted South hand.
18. Presentation state stores the result as `phase = dealt` only after the South
   reveal flip completes.
19. Presentation mapping prepares visible South cards, hidden simulated card
   counts, token-backed suit color roles, shared card sizing, default station
   outlines, and a hidden undealt deck stack state.
20. Presentation state initializes the bidding round with all four bid entries as
   pending (`--`) and sets the first bidding turn to the player on the dealer's
   right.
21. SwiftUI renders the dealt table:
   - undealt deck stack removed,
   - South station expanded below the table with 13 visible cards,
   - West/North/East compact stations with 13 hidden card backs each,
   - bordered `Bidding` area under the South station,
   - bid table values initialized as `--`,
   - status label above the bottom control row showing `Deal complete`.
22. The bidding service resolves simulated turns in counterclockwise order. A
   simulated player displays `Pass` when the automated recommendation is `Pass`
   or when a numeric recommendation is not higher than the current highest bid;
   otherwise the accepted higher number is shown. Accepted numeric bid records
   store the bidder seat, bid value, preferred trump/Tarneeb suit, and
   confidence metadata. Each simulated display update waits at least one second
   before applying the new value.
23. When the active turn reaches South before bidding is terminal, SwiftUI
   shows the legal-value bid chips below the table while South's table entry
   remains pending until submission. The South `Bid` button is already visible
   during in-progress bidding and becomes enabled for `Pass` or for a legal
   numeric bid selection.
24. After South taps `Bid`, presentation state resolves South's selected value,
   replaces the bid chips with the selected bid value, and either disables the
   South `Bid` button for continued bidding or hides it completely if bidding is
   terminal. If South commits `Pass`, no South suit is stored. If South commits
   a numeric bid, no South suit is stored yet; it is set only if South remains
   the numeric high bidder after bidding completes.
25. Every displayed bid value change uses a one-second bid fade/color
   transition. The current highest numeric bid remains in the same yellow used
   by the `New Game` button; if a higher bid is accepted, the previous high bid
   transitions back to white.
26. When bidding completes, the status label changes from `Deal complete` to
   `Bidding complete`, the South `Bid` button disappears completely, and the
   `Bidding` area begins a one-second fade-out.
27. When the bidding-area fade-out completes, SwiftUI removes the `Bidding` area
   from layout. If East, North, or West has the numeric high bid, presentation
   mapping displays the post-bidding summary with the high-bidding team, bid
   value, and `Tarneeb` suit symbol read from the high bidder's accepted bid
   record. If South has the numeric high bid and no suit has been set yet,
   SwiftUI displays a post-bidding South suit-setting panel with suit chips and
   a `Set` button; tapping `Set` stores the selected suit and then displays the
   final summary. If all players passed with no numeric high bid, no high-bidding
   summary is shown and presentation state immediately starts an automatic fresh
   deal with the dealer advanced to the previous dealer's right.
28. If the player taps `Deal` again in `phase = dealt`, presentation state clears
   or replaces previous hands, bid values, post-bidding summary, and terminal
   bidding animation state; rotates `dealerSeat` counterclockwise; requests a
   fresh completed deal; initializes a fresh pending bidding round; plays the
   same dealer-relative deal animation and South reveal; and remains in
   `phase = dealt`.
29. If the player taps `New Game` in any phase, presentation state restores the
   launch state: `phase = notStarted`, empty hands, no visible bidding area, no
   post-bidding summary, a selected dealer, visible title, visible very-centered
   squared undealt deck stack, dealer badge on the selected dealer station, and
   no status label.

### 2.3 Primary Components

| Component | Purpose |
| --- | --- |
| App entry point | Hosts the root SwiftUI view and applies portrait-only app support. |
| Root table screen | Displays the full MVP screen in both `notStarted` and `dealt` phases. |
| Table scene layout | Allocates the main table area and bottom control area. |
| Circular card table view | Renders the central circular table at half the screen width. |
| Table title view | Renders `طرنيب` centered on the table using table-title typography and token-backed color/effect roles. |
| Undealt deck stack view | Renders or represents 52 hidden card backs in a squared stack at the very center of the card table before a deal. |
| Deal animation overlay | Renders the transient moving 13-card hidden stack, target order, center-stack decrement, South interim fanned-back stack, and South delayed reveal backs/flip state during the deal animation. |
| Player station layout | Places North above, West left, South below, and East right of the circular table. |
| Player station view | Renders a rounded-square station label, token-backed default outline state, optional dealer badge, and either empty content, South interim fanned backs, South final reveal backs/flip state, a visible South hand, or a hidden simulated stack. |
| South hand view | Renders the delayed South reveal sequence: no faces during stack movement, fanned backs if South receives cards before the full deal completes, 13 backs after all hands are dealt, 1.5-second left-to-right flip, then 13 sorted exposed cards. |
| Card face view | Renders exposed South cards with rank, suit text, token-backed color role, and standard-card aspect ratio. |
| Hidden card back view | Renders `card_back.png` at the shared card size. |
| Hidden hand stack view | Renders 13 hidden card backs for a simulated player, optionally with slight overlap. |
| Bidding area view | Renders the bordered post-reveal `Bidding` area under the South station. |
| Bid table view | Renders pending, active, passed, and numeric bid entries for South, East, North, and West. |
| South bid selector | Renders only on South's active turn as bid chips with `Pass` and currently legal numeric values through 13. |
| Post-bidding South Tarneeb suit selector | Renders only after bidding when South is the numeric high bidder and the final summary is waiting on South's suit choice; offers `♠`, `♣`, `♥`, and `♦` with a `Set` button. |
| South bid button | Renders under the South bid value while bidding is in progress, disabled except for valid South submissions, and hidden after bidding completes. |
| Post-bidding summary view | Renders the terminal high-bidding team, bid value, and `Tarneeb` suit symbol after the `Bidding` area fade-out completes when a numeric high bid exists. |
| Bottom controls view | Renders the status label (`Deal complete` after South reveal and before bidding completes, `Bidding complete` after bidding completes) and the bottom `New Game` and `Deal` buttons in all MVP states. |
| Game state owner | Handles the visible `Deal` and `New Game` buttons, owns dealer selection/rotation, and publishes renderable state. |
| Deal service | Performs player setup, deck creation, shuffle, chunk assignment, and validation. |
| Dealer service | Selects initial dealer and rotates dealer counterclockwise for replacement deals and all-pass automatic redeals. |
| Bidding service | Tracks bidding turn order, resolves simulated recommendations, validates legal bid values, resolves South submissions, stores preferred trump/Tarneeb suit on accepted numeric bid records, derives the post-bidding summary for numeric high bids, emits an automatic-redeal outcome for all-pass hands, and determines when the simplified bidding round is over. |
| Automated bid evaluator | Evaluates each possible Tarneeb suit independently, emits `expectedTricks` and `safeBidCeiling` diagnostics, applies high-bid structural gates, and returns conservative bid recommendations with preferred Tarneeb suit metadata. |
| Hand log sink | Writes completed hand summaries to the console and can be replaced in tests. |
| Token resolver | Maps semantic roles to token values defined in `specs/007-mvp/design-tokens.md`. |

### 2.4 MVP Boundary

The completed-deal screen includes the simplified MVP 007 bidding display and is
terminal after that bidding display. It may expose the bottom `Deal` action to
produce a replacement deal, the bottom `New Game` action to reset to launch
state, and the South bid selector only while South's bidding turn is active.
The South `Bid` button remains visible but disabled during in-progress non-South
turns, is enabled only when South has a valid submission, and disappears when
bidding completes. After bidding completes, the `Bidding` area fades away and
may be replaced by the non-interactive post-bidding summary when a simulated
seat or North has the numeric high bid, or by a South suit-setting panel when
South has the numeric high bid and the suit has not yet been set. The South
suit-setting panel contains suit chips and a `Set` button and disappears after
the final summary is produced. If every player passed before any numeric bid,
the fade-away path instead starts an automatic fresh deal with the dealer
advanced counterclockwise. The screen must not expose post-summary Tarneeb suit
editing, resolving the highest bid into a trick-play flow, playing a card,
resolving tricks, scoring, saved games, accounts, or multiplayer.

### 2.5 Design Token Boundary

`specs/007-mvp/design-tokens.md` is the source of truth for all concrete color,
typography, title-shadow, dealer-badge, bidding area, post-bidding summary, bid
selector, post-bidding South Tarneeb suit selector, South bid/Set button, bid value fade
animation, bidding-area fade animation, and undealt-deck stack/placement values.
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
| `bidAreaBackground` | `color.bidArea.background` |
| `bidAreaBorder` | `color.bidArea.border` |
| `bidAreaLabel` | `color.bidArea.label` |
| `bidAreaTableDivider` | `color.bidArea.table.divider` |
| `bidAreaValueText` | `color.bidArea.value.text` |
| `bidAreaPendingValueText` | `color.bidArea.value.pending.text` |
| `bidAreaHighestValueText` | `color.bidArea.value.highest.text` |
| `bidAreaSeatText` | `color.bidArea.seat.text` |
| `postBiddingSummaryBackground` | `color.postBiddingSummary.background` |
| `postBiddingSummaryBorder` | `color.postBiddingSummary.border` |
| `postBiddingSummaryLabelText` | `color.postBiddingSummary.label.text` |
| `postBiddingSummaryTeamText` | `color.postBiddingSummary.team.text` |
| `postBiddingSummaryBidText` | `color.postBiddingSummary.bid.text` |
| `postBiddingSummaryTarneebText` | `color.postBiddingSummary.tarneeb.text` |
| `bidSelectorBackground` | `color.bidSelector.background` |
| `bidSelectorBorder` | `color.bidSelector.border` |
| `bidSelectorText` | `color.bidSelector.text` |
| `bidSelectorFocusRing` | `color.bidSelector.focusRing` |
| `bidSuitSelectorBackground` | `color.bidSuitSelector.background` |
| `bidSuitSelectorBorder` | `color.bidSuitSelector.border` |
| `bidSuitSelectorText` | `color.bidSuitSelector.text` |
| `bidSuitSelectorSelectedBackground` | `color.bidSuitSelector.selected.background` |
| `bidSuitSelectorSelectedText` | `color.bidSuitSelector.selected.text` |
| `bidSuitSelectorDisabledOpacity` | `effect.bidSuitSelector.disabled.opacity` |
| `bidActionBackground` | `color.button.bid.background` |
| `bidActionPressedBackground` | `color.button.bid.background.pressed` |
| `bidActionText` | `color.button.bid.text` |
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
| `dealSouthRevealTotalDuration` | `animation.deal.southReveal.total.duration` |
| `dealSouthRevealFlipDuration` | `animation.deal.southReveal.flip.duration` |
| `dealSouthRevealFlipStagger` | `animation.deal.southReveal.flip.stagger` |
| `bidValueFadeOutDuration` | `animation.bid.value.fadeOut.duration` |
| `bidValueFadeInDuration` | `animation.bid.value.fadeIn.duration` |
| `bidAreaFadeOutDuration` | `animation.bid.area.fadeOut.duration` |

The MVP 007 deal action is always labeled `Deal` and should use the primary
deal button tokens. The reset action is always labeled `New Game` and should use
the secondary new-game button tokens. Dealer indication should use
`color.dealerBadge.background` and `color.dealerBadge.text`; the badge
background is kept matched to `color.button.deal.background` by the token file.
Dealer indication must not change any player station outline to blue.

The bidding area should use `color.bidArea.*` tokens for its bordered panel and
table text. Pending bid values displayed as `--` should use the pending bid text
token. The current highest numeric bid should use
`color.bidArea.value.highest.text`, which is kept matched to the `New Game`
button yellow by the token file; `Pass` and non-high numeric bid values should
use `color.bidArea.value.text`. The South bid chips should use
`color.bidSelector.*` tokens, the post-bidding South Tarneeb suit selector should
use `color.bidSuitSelector.*` and `effect.bidSuitSelector.*` tokens, and the South
`Bid` and post-bidding `Set` buttons should use `color.button.bid.*` tokens in
enabled and disabled states. Bid value changes
should use `animation.bid.value.*` timing tokens and complete in one second.
The terminal bidding-area fade should use `animation.bid.area.fadeOut.duration`.
The South reveal should use `animation.deal.southReveal.total.duration`,
`animation.deal.southReveal.flip.duration`, and
`animation.deal.southReveal.flip.stagger`; the full South reveal takes 1.5
seconds from first card flip start to final card flip completion.
The post-bidding summary should use `color.postBiddingSummary.*` tokens and
`layout.postBiddingSummary.*` tokens. Its Tarneeb suit symbol should use the
suit's black/red card-suit token inside a compact `color.card.background` chip
with the selected-style border token. Concrete bid panel colors, summary colors,
selector colors, button colors, animation timings, and spacing values should not
be hard-coded in views.

If implementation or later design work needs a color, font, effect, or
undealt-deck layout value not represented by these tokens, update
`specs/007-mvp/design-tokens.md` first and reference the new token from this
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
005 still does not use rank strength for trick play or simulated bid strategy.

### 3.4 Seat

| Seat | Player Type | Team | Model Order | Visual Placement |
| --- | --- | --- | --- | --- |
| `south` | Human | `teamA` | 1 | Below the table; expands after all hands are dealt for the South reveal. |
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
| `dealt` | A valid deal and South reveal have completed, and the simplified bidding round is visible, fading out, waiting for South's post-bidding suit setting, complete with a summary, or starting an all-pass automatic redeal. | Card table, current dealer badge remains visible, no undealt deck stack, expanded South hand, hidden simulated hands, bordered `Bidding` area with bid table while bidding is active or fading out, optional post-bidding South suit-setting panel when South is the numeric high bidder, optional post-bidding summary after the fade/suit-setting step for numeric high bids, pending/resolved bid values, South bid chips only on South's active turn, South `Bid` button visible while bidding is in progress and hidden after completion, status label showing `Deal complete` or `Bidding complete`, bottom `New Game` and `Deal`. |

No additional phases are part of MVP 007 unless product later requires an
intermediate replacement-dealer preview state.

### 3.7 Game State

| Field | Requirement |
| --- | --- |
| `phase` | Must be `notStarted` or `dealt`. |
| `players` | Exactly four players in both phases. |
| `dealerSeat` | Exactly one of `south`, `east`, `north`, or `west`. Randomly selected for a new game and rotated counterclockwise for replacement deals and all-pass automatic redeals. |
| `deck` | Optional to retain; if retained after dealing, ownership semantics must be clear. |
| `bids` | Empty or absent in `notStarted`; keyed by seat after dealing. Entries may be pending, active South selection, `Pass`, or an accepted numeric bid record containing value and preferred trump/Tarneeb suit; South's numeric high-bid record may wait for the post-bidding `Set` action before the preferred suit is attached. |
| `biddingTurnSeat` | Empty when no bidding turn is active; otherwise exactly one of South, East, North, or West while bidding is in progress. |
| `southDraftBidValue` | Empty unless South is the active bidding seat; otherwise `Pass` or one currently legal numeric bid. |
| `southDraftTarneebSuit` | Empty unless South is the numeric high bidder after bidding and the final summary is waiting on South's suit setting; otherwise one of `spades`, `clubs`, `hearts`, or `diamonds`. |
| `highestBidSeat` | Empty until a numeric bid is accepted; otherwise the seat with the current highest numeric bid. |
| `highestBidValue` | Empty until a numeric bid is accepted; otherwise one numeric bid from 7 through 13. |
| `bidRecommendations` | Optional metadata keyed by seat, including the recommended bid, preferred Tarneeb suit for numeric recommendations, confidence, selected suit, per-suit `expectedTricks`, per-suit `safeBidCeiling`, and any high-bid gate that capped the recommendation. |
| `postBiddingSummary` | Optional terminal summary containing team label, bid value, preferred Tarneeb suit from the high bidder's accepted bid record, and suit symbol when a numeric high bid exists. |
| `biddingCompletionOutcome` | Empty while bidding is active; `numericHighBid` when bidding ends with a numeric highest bidder; `allPassRedeal` when all four players pass before any numeric bid is accepted. |
| `biddingStatus` | Suggested values are `notStarted`, `inProgress`, and `complete`; this is bidding state, not a new game phase. |
| `biddingAreaPresentationState` | Suggested presentation-only values are `hidden`, `visible`, and `fadingOut`; used to coordinate the one-second terminal fade before summary display or all-pass automatic redeal. |

For a completed deal, the source of truth should be the four player hands. If a
deck is retained after dealing, it should represent either an empty undealt deck
or an immutable source/audit deck, not another owner of cards.

The initial 52-card undealt deck stack does not require a new game phase. It can
be derived from `phase = notStarted` and `dealerSeat` as presentation state,
provided tests can verify that it represents 52 hidden cards, appears at the
very center of the card table, uses the tokenized squared-stack geometry, stays inside
the card table with a buffer, and disappears after `phase = dealt`.

### 3.8 Bid State

Bid state is part of the MVP 007 game state only after a deal and South reveal
complete.

| Field | Type/Allowed Values | Requirement |
| --- | --- | --- |
| `seat` | `south`, `east`, `north`, `west` | Required so the bid table can render one value per player. |
| `state` | `pending`, `activeSouthSelection`, `pass`, `number` | Required so the table can distinguish `--`, the South active selector, `Pass`, and numeric bids. |
| `displayValue` | `--`, `Pass`, `7`, `8`, `9`, `10`, `11`, `12`, `13`, or active selector | `--` is valid only before that player's bid resolves. The active bid-chip selector is valid only for South on South's turn. |
| `numericValue` | Empty or 7 through 13 | Present only for accepted numeric bid states. |
| `preferredTarneebSuit` | Empty, `spades`, `clubs`, `hearts`, or `diamonds` | Present for accepted simulated numeric bid states and for South numeric high bids after the post-bidding `Set` action. Empty for pending, `Pass`, active South selection, and South's unresolved post-bidding suit-setting state. |
| `confidence` | Empty or 0 through 1 | Optional internal value for accepted numeric bids that came from automated recommendations. |
| `source` | `pending`, `humanSelection`, `simulatedRecommendation` | South uses `humanSelection` after submission; East, North, and West use `simulatedRecommendation` after their turns resolve. |

The simplified auction tracks the current highest numeric bid so later bids can
be rejected into `Pass`. It derives a non-interactive summary from the highest
numeric bid record and that record's stored preferred trump/Tarneeb suit, but
does not resolve the highest bid into post-bidding Tarneeb suit selection or
trick play.

### 3.9 Bid Recommendation and Post-Bidding Summary

Bid recommendation metadata is internal bidding state used for simulated players.
When a numeric recommendation is accepted, the preferred suit and confidence are
copied onto the accepted bid record. The final summary derives its suit from the
accepted high-bid record rather than from recommendation metadata alone.

| Field | Requirement |
| --- | --- |
| `recommendedBid` | `Pass` or a numeric value from 7 through 13. |
| `preferredTarneebSuit` | Empty for `Pass`; otherwise one of `spades`, `clubs`, `hearts`, or `diamonds`. |
| `confidence` | Numeric confidence from 0 through 1. |

The post-bidding summary is present only after terminal bidding with a numeric
high bid. Its preferred suit source is the high bidder's accepted numeric bid
record, not transient recommendation-only metadata. All-pass terminal bidding
does not create this summary.

| Field | Requirement |
| --- | --- |
| `teamLabel` | `East-West` when the high bidder is East or West; `North-South` when the high bidder is North or South. |
| `bidValue` | The accepted high bid value from 7 through 13. |
| `tarneebSuit` | Preferred suit stored on the high bidder's accepted numeric bid record. If this is missing, the state is invalid because every accepted numeric bid must store a preferred suit. |
| `tarneebSymbol` | `♠`, `♣`, `♥`, or `♦` derived from `tarneebSuit`. |

All-pass terminal bidding leaves `postBiddingSummary` empty and triggers the
automatic redeal path unless future requirements define an all-pass result
display.

### 3.10 Transient Deal Animation State

The deal animation is presentation state, not a persisted game phase. The
validated completed deal should be available as pending render data while
animation is running, but South card identities stay hidden until every hand has
been dealt and the South reveal flip completes. The domain still exposes only
`notStarted` and `dealt`.

| Field | Requirement |
| --- | --- |
| `dealerSeat` | Current dealer for the deal being animated. |
| `targetOrder` | Starts with the player on the dealer's right and continues counterclockwise. |
| `activeStepIndex` | Zero-based index for the current 13-card stack movement. |
| `movingStackVisible` | True while the current 13-card stack is moving from the center deck to the target station. |
| `deliveredSeats` | Seats whose animated stack has arrived. Simulated delivered seats may show final hidden backs; South delivered state does not expose ranks or suits until South reveal completes. |
| `pendingDealtState` | Valid completed deal result to reveal station-by-station and then reveal for South. |
| `southRevealState` | One of `hidden`, `backsVisible`, `flipping`, or `revealed`; remains `hidden` until all four stacks arrive. |
| `southRevealBackCount` | Exactly 13 while `southRevealState` is `backsVisible` or `flipping`. |
| `southRevealRevealedCount` | Number of South cards that have flipped face-up from left-to-right; ranges from 0 through 13. |
| `dealCompletionAvailable` | True only after `southRevealState = revealed`; gates `Deal complete`, bidding initialization, and bidding-area visibility. |

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

If South receives a stack before the fourth movement resolves, the South station
may record the delivery internally but must continue to show no card faces.
After the fourth stack arrives, the South station expands with 13 backs and
then flips those backs face-up left-to-right using the deal reveal tokens.

## 4. Presentation Data Model

### 4.1 Card Presentation

Presentation mapping should expose enough information to render and test cards
without putting display rules directly into the domain model.

| Field | Source | Requirement |
| --- | --- | --- |
| `cardID` | Card identity | Stable UI identity. |
| `rankText` | Card rank | One of the allowed rank labels. |
| `suitSymbol` | Card suit | Suit symbol shown on exposed cards. |
| `faceAssetName` | Card rank and suit | Stable xCards face image name in the form `card_face_<rank><suit>`; Ten maps to `T`, and suits map to `C`, `D`, `H`, and `S`. |
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
| `cornerRadius` | Applies to generated hidden-card backs and simple fallback card shells only; xCards face images preserve their native card corners without an extra rounded-rectangle clip or border. |
| `rankFont` | Large enough to read on supported device sizes if a non-asset fallback face is ever used; production exposed South cards use xCards face images. |
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
| `stackOffset` | Must use the squared-stack offset tokens from `layout.undealtDeck.stack.offset.*`; both values are zero for MVP 007. |
| `rotation` | Must use the squared-stack rotation token from `layout.undealtDeck.stack.rotation`; the value is zero for MVP 007. |
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
| `southInterimBackStackVisible` | True after South receives its 13-card stack before the fourth movement completes; false after final South expansion begins. |
| `southRevealState` | Hidden before South receives cards, fanned-backs while South's received stack is waiting for the rest of the deal, then backs-visible, flipping, and revealed after all four stacks arrive. |
| `southRevealRevealedCount` | 0 through 13; determines how many South cards render face-up during the left-to-right flip. |
| `southRevealTotalDuration` | Uses `animation.deal.southReveal.total.duration` and must be 1.5 seconds from first card flip start to final card flip completion. |
| `timingTokens` | Use `animation.deal.*` timing tokens from `design-tokens.md`. |
| `accessibilityValue` | Should expose count, hidden-card asset, center-deck origin, player-station destination, target seat, direction, target order, South interim-back visibility, South reveal state, South revealed-card count, and South reveal total duration for UI tests. |

When a moving stack arrives, West, North, and East may reveal final hidden-card
presentations from `pendingDealtState`. If South receives its stack before all
four stacks have arrived, the South station should keep 13 hidden backs visible
as a slightly fanned dealt stack, matching the hidden-back treatment of the other
dealt stations while revealing no ranks or suits. After all four stacks arrive,
South expands with 13 backs and flips face-up left-to-right over 1.5 seconds.
The animation must not create partial domain hands or bypass completed-deal
validation.

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
| South | Label only in a rounded-square station; dealer badge if `dealerSeat = south`; default outline | If South receives cards before the full deal completes, label plus a slightly fanned 13-card hidden-back stack; after all stacks arrive, label plus 13 backs during final reveal, then 13 exposed sorted cards; station expands below the table for final reveal; dealer badge remains if South is current dealer; default outline | Largest station after deal because it contains the human hand. |
| North | Label only in a rounded-square station; dealer badge if `dealerSeat = north`; default outline | Label plus hidden stack/count of 13 backs; dealer badge remains if North is current dealer; default outline | Compact station. |
| West | Label only in a rounded-square station; dealer badge if `dealerSeat = west`; default outline | Label plus hidden stack/count of 13 backs; dealer badge remains if West is current dealer; default outline | Compact station. |
| East | Label only in a rounded-square station; dealer badge if `dealerSeat = east`; default outline | Label plus hidden stack/count of 13 backs; dealer badge remains if East is current dealer; default outline | Compact station. |

Before deal, all stations should read as rounded squares. South expands below
the card table only after all four hands have been dealt; the expanded reveal
state first contains 13 backs, then flips them face-up left-to-right over 1.5
seconds. Before that final expansion, a South stack that has already arrived
stays visible as fanned backs rather than disappearing. Whether South must remain
a square after expansion is not specified and is flagged in section 12.

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

### 4.8 Bidding Presentation

Bidding presentation is derived from the post-reveal bid state and rendered only
after the South reveal flip completes and `phase = dealt`.

| Field | Requirement |
| --- | --- |
| `isVisible` | True only after all four stacks arrive, the South reveal flip resolves, and `phase = dealt`; false in `notStarted` and during deal/reveal animation. |
| `presentationState` | `visible` while bidding is active, `fadingOut` during the one-second terminal fade, and `hidden` after the fade completes. |
| `title` | Visible label `Bidding`. |
| `panelRole` | `bidAreaBackground` with `bidAreaBorder`. |
| `tableSeats` | South, East, North, and West. Use South, East, North, West order unless product specifies another order. |
| `entryStates` | One entry per seat, each displaying `--`, `Pass`, a numeric bid, or the active South selector. |
| `acceptedBidRecords` | Internal structured bid records keyed by seat for accepted numeric bids. Each record contains bidder seat, bid value, preferred trump/Tarneeb suit, and optional confidence metadata. Pending, active South selector, and `Pass` states do not have accepted bid records. |
| `pendingDisplayValue` | `--`, using the pending bid text token. |
| `currentTurnSeat` | The active bidding seat when bidding is in progress; exposed for test metadata. |
| `highestBid` | Current highest numeric bid and seat, if any; exposed for test metadata and legal-option calculation. |
| `biddingStatus` | `inProgress` or `complete`; controls status-label text and South `Bid` button visibility. |
| `completionOutcome` | Empty while bidding is active; `numericHighBid` when a summary should appear after the fade; `allPassRedeal` when no numeric bid was accepted and a fresh automatic deal should start after the fade. |
| `southControlType` | No selector unless `currentTurnSeat = south`; active South turn renders the bid-chip selector only. |
| `southAllowedValues` | `Pass` plus numeric values from the current legal minimum through `13`. Legal minimum is `7` when no numeric bid exists, otherwise one more than the current highest numeric bid. |
| `southSelectedDraftValue` | South's currently selected bid-chip value before the `Bid` button is tapped. |
| `southTarneebSuitOptions` | Spades, clubs, hearts, and diamonds, displayed as `♠`, `♣`, `♥`, and `♦` or equivalent suit labels in the post-bidding South suit-setting panel only. |
| `southSelectedDraftTarneebSuit` | South's currently selected post-bidding suit before `Set` is tapped. Required only when South is the numeric high bidder awaiting summary. |
| `southBidButtonState` | Visible and disabled during in-progress non-South turns, visible and enabled for any legal South bid-chip submission, hidden when `biddingStatus = complete`. |
| `simulatedValues` | Displayed values for East, North, and West after each simulated turn resolves. They remain non-interactive and update no sooner than one second after their active turn begins. |
| `seatLabelRole` | `bidAreaSeatText`. |
| `valueTextRole` | `bidAreaValueText` for resolved non-high values, `bidAreaHighestValueText` for the current highest numeric bid, and `bidAreaPendingValueText` for `--`. |
| `dividerRole` | `bidAreaTableDivider`. |
| `selectorTokens` | `color.bidSelector.*` for South bid-chip states. |
| `suitSelectorTokens` | `color.bidSuitSelector.*` and `effect.bidSuitSelector.*` for post-bidding South Tarneeb suit selector states. |
| `bidButtonTokens` | `color.button.bid.*` for the South `Bid` button and post-bidding `Set` button in enabled and disabled states. |
| `valueChangeAnimationTokens` | `animation.bid.value.*` for a one-second fade/color transition when a bid entry changes. |
| `areaFadeOutAnimationToken` | `animation.bid.area.fadeOut.duration` for the one-second terminal hide transition. |
| `accessibilityValue` | Should expose visible seat/value pairs, bidding status, completion outcome, current turn, highest bid metadata, accepted numeric bid preferred-suit metadata where suitable for tests, South bid selector options, post-bidding South suit selector options, post-bidding South draft suit selection, South `Bid`/`Set` button visibility/enabled state, simulated-update timing metadata, bidding-area presentation state, and status-label text for UI tests. |

The bid table must not display strategic explanations, interactive winning-bid
flow, post-bidding Tarneeb suit selection controls, or trick-play controls. The
separate post-bidding South suit-setting panel is allowed only after the bid
table has faded away and only when South is the numeric high bidder.
East, North, and West values are non-interactive display values for this MVP.
South bid selection is interactive only while South's bidding turn is active.
The South suit selector is not part of the in-progress `Bidding` area; it is a
separate post-bidding suit-setting panel shown only when South is the numeric
high bidder. After bidding completes, the South `Bid` button is removed entirely
rather than shown disabled, and the full bidding area fades out before being
removed from layout. Numeric-high-bid completion may then show the South
post-bidding suit-setting panel when needed or the final post-bidding summary;
all-pass completion must leave the summary hidden and start the automatic redeal
path.

### 4.9 Post-Bidding Summary Presentation

Post-bidding summary presentation is derived only after terminal bidding and is
shown only after the `Bidding` area fade-out completes.

| Field | Requirement |
| --- | --- |
| `isVisible` | True only after terminal bidding fade-out completes and a numeric high bid exists; false for all-pass automatic redeals. |
| `teamLabel` | `East-West` or `North-South`. |
| `bidValueText` | Numeric high bid value from `7` through `13`. |
| `tarneebLabel` | Visible label `Tarneeb`. |
| `tarneebSymbol` | One of `♠`, `♣`, `♥`, or `♦`, derived from the high bidder's preferred trump/Tarneeb suit stored on the accepted bid record. |
| `containerRole` | `postBiddingSummaryBackground` with `postBiddingSummaryBorder`. |
| `labelTextRole` | `postBiddingSummaryLabelText`. |
| `teamTextRole` | `postBiddingSummaryTeamText`. |
| `bidTextRole` | `postBiddingSummaryBidText`. |
| `tarneebTextRole` | `postBiddingSummaryTarneebText`. |
| `accessibilityValue` | Should expose team label, bid value, and Tarneeb symbol for UI tests. |

The summary is a compact result display under the South station. It must not
look or behave like a suit picker: no segmented control, menu, buttons, or card
selection affordance should be used for the Tarneeb symbol in MVP 007. It must
not appear during the all-pass automatic redeal path.

### 4.10 Bottom Controls Presentation

| Field | Requirement |
| --- | --- |
| `dealButtonLabel` | Always `Deal`. |
| `newGameButtonLabel` | Always `New Game`. |
| `buttonPlacement` | Bottom control row at the bottom of the screen or bottom safe-area region; exact interpretation is ambiguous. |
| `dealButtonTokens` | Primary deal button tokens from `design-tokens.md`. |
| `newGameButtonTokens` | Secondary new-game button tokens from `design-tokens.md`. |
| `statusLabel` | `Deal complete` after the deal and South reveal complete and before bidding completes; `Bidding complete` when bidding is terminal; hidden in `notStarted`. |
| `statusPlacement` | Above the bottom control row in `dealt`, after the South reveal flip completes. |
| `oldLabels` | `Deal Cards` and `New Deal` must not appear in MVP 007 UI. |
| `disabledDuringDealAnimation` | Prevent overlapping `Deal` or `New Game` while a transient deal animation is running, including an all-pass automatic redeal animation. |

Internally, the visible `Deal` action can map to either "first deal" or
"replacement deal" based on phase. That internal distinction should not leak into
button text, accessibility label text, or visible UI.

The visible `New Game` action maps to reset only. In `dealt`, it clears all
hands, hides the status label, selects a dealer for the new game, restores the
very-centered squared undealt deck stack, hides the bidding area, hides any
post-bidding summary, shows the dealer badge on the selected station, and
returns the presentation to `notStarted`. In
`notStarted`, it leaves the app in `notStarted` and must not start a deal.
Whether it re-randomizes the current dealer is ambiguous.

### 4.11 Layout Metrics Presentation

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
| `southExpandedHeight` | Large enough to display the South hand during and after the South reveal without making bottom controls unusable. |
| `biddingAreaPlacement` | Under the expanded South station after the South reveal flip completes. |
| `biddingAreaPadding` | Uses bidding area spacing tokens from `design-tokens.md`. |
| `postBiddingSummaryPlacement` | Same general under-South region vacated by the `Bidding` area after terminal fade-out. |
| `postBiddingSummaryPadding` | Uses post-bidding summary spacing tokens from `design-tokens.md`. |
| `bidSelectorSize` | Uses bid selector height and minimum width tokens from `design-tokens.md`. |
| `southBidButtonSize` | Uses bid button height and minimum width tokens from `design-tokens.md`. |
| `bottomControlHeight` | Large enough for the bottom `New Game` and `Deal` buttons and status label when present. |

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
MVP 007 keeps the carried-forward chunk assignment order unchanged and treats
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
9. Initializing bid state for South, East, North, and West.
10. Logging South, East, North, and West hands to the console through an
    injectable hand log sink.
11. Validating no cards remain undealt and no duplicates were assigned.

Tests that assert exact card ownership should use deterministic shuffle input
and the South, East, North, West chunk-to-seat order.

The visual animation order is separate from card ownership assignment. It should
use the current `dealerSeat` to target the player on the dealer's right first,
then continue counterclockwise, while revealing the already validated completed
deal station-by-station.

Hand logs must never render in the game UI. Each console entry should include
the seat label and all 13 cards in a readable rank/suit format, and replacement
deals should log a fresh set of four hands.

### 5.6 Bidding Round Resolution

Bidding round data may be prepared after the completed deal is validated, but
the active bidding turn and visible `Bidding` area begin only after the South
reveal flip completes.

Allowed bid values:

1. `Pass`
2. `7`
3. `8`
4. `9`
5. `10`
6. `11`
7. `12`
8. `13`

Initial bid state:

1. Set South, East, North, and West bid entries to pending, displayed as `--`.
2. Set the first active bidding turn to the player on the dealer's right.
3. Clear `highestBidSeat` and `highestBidValue`.
4. Render the `Bidding` area as soon as the South reveal flip completes and the
   completed deal screen appears.

South bid behavior:

1. South remains displayed as `--` until South's bidding turn becomes active.
2. While bidding is in progress, keep the South `Bid` button visible under the
   South bid value.
3. Disable the South `Bid` button while the active bidding turn belongs to East,
   North, or West.
4. When South is the active turn, show the South bid-chip selector while South's
   table value remains pending until submission.
5. If no numeric bid exists, the bid-chip numeric values are `7` through `13`.
6. If a current highest numeric bid exists, the bid-chip numeric values start
   at one more than that highest bid and continue through `13`.
7. `Pass` is always available.
8. Do not show a South Tarneeb suit selector during the in-progress bidding
   round.
9. Changing the bid-chip selection updates only the South draft bid value.
10. Enable the South `Bid` button when the selected draft bid value is legal.
11. Tapping the enabled South `Bid` button commits the draft value, replaces the
   bid chips with the committed bid value, and advances or completes bidding.
12. If South commits `Pass`, store no preferred Tarneeb suit for South.
13. If South commits a numeric bid, store South's accepted bid as a structured
   bid record containing South's seat and the bid value.
14. If South remains the numeric high bidder after bidding completes, show the
   post-bidding suit-setting panel with spades, clubs, hearts, and diamonds as
   `♠`, `♣`, `♥`, and `♦` or equivalent suit labels plus a `Set` button.
15. Keep the post-bidding `Set` button disabled until South selects a suit.
16. Tapping `Set` stores South's selected Tarneeb suit on South's accepted bid
   record and displays the final summary.
17. If South's committed bid does not complete bidding, return the South `Bid`
    button to the visible disabled state until bidding returns to South.
18. If South's committed bid completes bidding, hide the South `Bid` button
    completely.
19. Reject or prevent any bid value outside `Pass` and the current legal numeric
   range.
20. Reject or prevent any post-bidding South suit value outside spades, clubs,
   hearts, and diamonds.

Simulated bid behavior:

1. Resolve each simulated turn only when that simulated seat is active.
2. Run the automated bid evaluator with the simulated player's hand, seat,
   partner seat, current highest bid, current highest bidder, and prior bid
   states.
3. Wait at least one second before applying the displayed result for that
   simulated turn.
4. If the recommendation is `Pass`, display `Pass`.
5. If the numeric recommendation is equal to or lower than the current highest
   numeric bid, display `Pass`.
6. If the current highest bidder is the simulated player's partner, re-apply the
   partner-raise threshold before acceptance. A one-trick partner raise, such as
   East recommending `8` while West is highest at `7`, must display `Pass` unless
   the recommendation satisfies the stronger independent trump-control and
   at-least-two-tricks-higher requirements. This guard also applies to injected
   overrides, stale recommendations, and deterministic test recommenders.
7. If the numeric recommendation is higher than the current highest numeric bid
   and passes any partner-raise guard, display that number; store an accepted bid
   record with the simulated seat,
   bid value, preferred trump/Tarneeb suit, and confidence metadata; update the
   current highest bid to that seat/value; keep the new highest numeric bid in
   the `New Game` button yellow; and transition the previous high bid value, if
   any, from yellow to white.
8. Do not store preferred trump/Tarneeb suit on simulated bid states that
   resolve to `Pass`.
9. Store resolved simulated values in game state or presentation state so they
   remain stable until a replacement deal or new-game reset.

Automated bid evaluator behavior:

1. Evaluate each suit as a possible future Tarneeb suit.
2. Consider high cards, candidate Tarneeb suit length, candidate Tarneeb suit
   high-card strength, side-suit winners, and useful voids or singletons.
3. Use a conservative normal/balanced baseline so ordinary hands do not reach a
   numeric bid mostly from baseline value.
4. Treat candidate Tarneeb suit length as supporting evidence rather than enough
   evidence by itself for bids above 7.
5. Reduce or gate length bonuses when the candidate suit is missing the ace or
   lacks multiple protected top honors.
6. Apply a meaningful risk penalty to candidate Tarneeb suits missing the ace,
   especially before recommending 8 or higher.
7. Count voids and singletons as positive only when candidate Tarneeb length and
   top-card control make ruffing plausible.
8. Discount side-suit ace and king value when those winners do not make the
   full team trick commitment likely.

Risk-budget constraints for `safeBidCeiling`:

- When optimistic `expectedTricks` comes mainly from length, ordinary side
  honors, or short-suit shape, apply a conservative risk budget before allowing
  the hand to cross the 9-, 10-, or 11-bid thresholds.
- Do not let six-card ace-jack-ten candidate suits missing king and queen reach
  10 from two outside aces or protected side honors alone.
- Do not let six-card ace-king-queen candidate suits missing jack and ten reach
  10 when they have no outside aces; ordinary side kings are not enough.
- Do not let six-card ace-king-queen candidate suits missing jack and ten reach
  11 from only one outside ace plus ordinary side king/queen support.
- Do not let six-card ace-king-queen-ten candidate suits missing jack reach 11
  from only one outside ace and ordinary side queen/king support.
- Do not let seven-card ace-king-queen-ten candidate suits missing jack reach 11
  when they have no outside aces or outside kings.
- Do not let seven-card ace-low candidate suits reach 9 when they have at most
  one outside ace and no stronger trump texture.
- Do not let seven-card ace-jack-low candidate suits missing king, queen, and
  ten reach 9 from length plus only one outside ace.
- Do not let seven-card king-queen-low candidate suits missing ace, jack, and
  ten reach 9 from length plus at most one outside ace and ordinary side support.
- Do not let four-card ace-king-queen-ten candidate suits missing jack reach 9
  from only one outside ace and ordinary side honor support.
- Do not let four-card ace-king-queen-jack candidate suits missing ten reach 9
  from only one outside ace and ordinary side honor support.
- Do not let six-card ace-king-low candidate suits missing queen, jack, and ten
  reach 10 from one outside ace and ordinary side king/queen support.
- Do not let six-card ace-king or ace-king-ten candidate suits with queen and
  jack both absent reach 9 when they have no reliable outside winners; ordinary
  side honors and ordinary short-suit value are not enough.
- Do not let six-card king-queen candidate suits missing the ace reach 9 from
  jack or ten texture plus at most one outside ace and ordinary side support;
  require the trump ace, extra trump length, multiple outside aces, stronger
  protected side winners, useful short-suit shape backed by enough trump control,
  or partnership context.
- Do not let seven-card ace-king-queen-jack-ten candidate suits reach 13 from
  only two outside aces; 13 requires at least eight trump cards plus
  near-commanding texture.

9. Treat exactly five-card candidate Tarneeb suits as strong only when they have
   enough top trump control, outside winners, and low distribution risk to
   support the target bid.
10. Treat five-card candidate Tarneeb suits headed by the ace but lacking king or
   queen support as uncertain; avoid recommendations above 7 unless the hand has
   additional strong evidence such as multiple outside aces, stronger trump
   intermediates, or useful distribution.
11. Treat exactly six-card candidate Tarneeb suits as not automatically 10-safe;
   when the candidate suit has ace-queen support but lacks the king, avoid
   recommendations above 9 unless stronger 10-level trump control or other
   clearly exceptional evidence is present. Treat six-card ace-king-low suits
   missing queen, jack, and ten the same way when support is only one outside ace
   plus ordinary side king/queen honors.
   Treat six-card ace-king or ace-king-ten suits with queen and jack both absent
   as not automatically 9-safe when they have no reliable outside winners; cap
   them at 8 unless stronger trump texture, protected outside winners, multiple
   outside aces, exceptional short-suit shape, extra trump length, or partnership
   context is present. Treat six-card king-queen suits missing the ace the same
   way for 9-level bids when the hand has at most one outside ace, even if the
   trump suit also contains jack or ten texture.
12. Treat six-card candidate Tarneeb suits headed by ace-jack but missing king,
   queen, and ten support as not automatically 10-safe; avoid recommendations
   above 9 from one outside ace, one outside king, and a void unless stronger
   evidence is present.
13. Treat exactly five-card candidate Tarneeb suits headed by ace-king-queen-ten
   as strong but still not automatically 10-safe when the hand has no outside
   aces; avoid recommending 10 unless extra trump length, reliable outside
   winners, useful short-suit shape backed by enough trump depth, or partnership
   context clearly supports the commitment.
14. Treat five-card candidate Tarneeb suits headed by ace-king-queen-jack but
   missing ten as not automatically 10-safe when the hand has no outside aces,
   only one outside king, and one singleton; avoid recommending 10 unless extra
   trump length, the trump ten, reliable outside winners, stronger short-suit
   shape, or partnership context clearly supports the commitment.
15. Treat five-card candidate Tarneeb suits headed by ace-king-queen but missing
   both jack and ten as not automatically 9-safe when the hand has no outside
   aces; avoid recommending 9 unless extra trump length, reliable outside
   winners, useful short-suit shape backed by enough trump depth, or partnership
   context clearly supports the commitment. Treat five-card ace-king-jack
   missing both queen and ten the same way when the hand has only one outside
   ace and no void or singleton support.
16. Treat five-card candidate Tarneeb suits headed by ace-king-ten but missing
   both queen and jack as not automatically 9-safe; avoid recommending 9 from
   one outside ace and one singleton unless stronger trump texture, multiple
   outside aces, stronger side-suit winners, useful short-suit shape, or
   partnership context clearly supports the commitment.
17. Treat five-card candidate Tarneeb suits headed by ace-queen-ten but missing
   both king and jack as not automatically 9-safe from ordinary support, and not
   automatically 11-safe even from three outside aces plus one outside king;
   require extra trump length, stronger trump texture, protected trump control,
   useful short-suit shape, or partnership context for those higher commitments.
   Across all exactly five-card candidate suits, do not allow a 10-level bid
   unless the candidate has at least three top trump controls, at least three
   reliable outside winners, or exceptional partnership context; two top trump
   controls plus two outside aces should remain capped below 10.
18. Treat five-card candidate Tarneeb suits headed by ace-jack-ten but missing
   king and queen as below the default opening threshold when the hand has no
   outside aces and only ordinary outside king or queen support.
19. Treat five-card candidate Tarneeb suits headed by ace-ten but missing king,
   queen, and jack as below the default opening threshold when the hand has no
   outside aces, no void or singleton support, and only ordinary outside king or
   jack support.
20. Treat five-card candidate Tarneeb suits headed only by the ace and missing
   king, queen, jack, and ten as below 8 even with two outside aces and one
   outside king unless stronger trump texture, extra trump length, useful
   short-suit shape, or partnership context supports the commitment.
21. Treat six-card candidate Tarneeb suits headed by ace-king-queen-jack but
   with no outside aces as not automatically 11-safe; avoid recommending 11 from
   trump texture and one side king alone unless an outside ace, stronger side
   winners, extra trump length, useful short-suit shape, or partnership context
   clearly supports the commitment.
22. Treat six-card candidate Tarneeb suits headed by ace-king-queen but missing
   both jack and ten as texture-sensitive: avoid recommending 12 from two
   outside aces and one outside king alone, and avoid recommending 10 when the
   hand has no outside aces, no outside kings, and no void or singleton support,
   and avoid recommending 11 when the hand has no outside aces and only one
   outside king plus void or singleton support, and avoid recommending 11 from
   only one outside ace plus ordinary side king/queen support, unless stronger
   trump texture, reliable outside aces, additional protected side winners,
   useful short-suit shape, extra trump length, or partnership context supports
   the commitment.
23. Treat seven-card candidate Tarneeb suits as length-supported but still
   texture-sensitive; ace-queen-ten missing king and jack, or ace-queen missing
   king, jack, and ten, should stay below 11 without stronger trump texture,
   reliable outside winners, useful short-suit shape backed by enough trump
   control, or partnership context. Seven-card king-queen-low candidates missing
   ace, jack, and ten should stay below 9 from at most one outside ace plus
   ordinary side support unless the trump ace, protected jack or ten support,
   multiple outside aces, additional reliable side winners, useful short-suit
   shape, or partnership context supports the commitment. Treat eight-card
   ace-queen-jack-ten candidates missing king as below 12 when they have no
   outside aces or kings and only one singleton unless the trump king, reliable
   outside winners, stronger side-suit support, useful short-suit shape, or
   partnership context supports the higher commitment.
24. Treat five-card candidate Tarneeb suits headed by king-queen-ten but missing
   the ace as uncertain; avoid recommendations above 7 from side kings and only
   one outside ace unless stronger support is present.
25. Treat five-card candidate Tarneeb suits headed by king-queen but missing ace,
   jack, and ten as below 8 from one outside ace, one outside king, and a
   singleton unless extra trump length, stronger trump texture, multiple outside
   aces, reliable side winners, useful short-suit shape, or partnership context
   supports the commitment.
26. Treat four-card candidate Tarneeb suits as limited by trump length; avoid
   inflating ace-low openings to 7, ace-king-ten/ace-king-jack/ace-king-low/
   ace-queen-jack shapes to 9, ace-queen-low, ace-jack-ten, or
   ace-jack-ten-low openings to 7, ace-king-jack-ten shapes to 8,
   ace-king-low shapes without outside aces to 8, shallow three-card
   king-queen or four-card ace-jack-low candidates to 8, or
   ace-king-jack shapes with strong outside honors to 10, or ace-king-queen-jack
   shapes missing ten to 9 from only one outside ace and ordinary side support,
   unless extra trump length, stronger trump texture, queen or ten trump support,
   reliable outside winners, exceptional short-suit shape, multiple outside aces,
   or partnership context supports the target bid.
27. Apply conservative risk penalties so weak or uncertain hands tend to pass.
28. Recommend `Pass` when the estimate is below seven likely team tricks.
29. Recommend a numeric value from 7 through 13 only when the hand supports that
   level of commitment.
30. When the simulated player's partner is already the highest bidder, recommend
   `Pass` by default.
31. Raise a partner only when the simulated player's preferred Tarneeb suit shows
   clearly stronger independent trump potential than the partner's current
   commitment requires.
32. A partner raise must require an adjusted recommendation at least two tricks
   above the current highest bid and strong independent trump control, such as
   the trump ace or multiple protected top honors.
33. Do not raise a partner from marginal extra side winners, suit length alone,
   or a recommendation that only barely exceeds the partner's current high bid.
34. Choose deterministically for tied recommendations so unit tests can assert
   stable results.
35. Return preferred Tarneeb suit only for numeric recommendations and confidence
   from 0 through 1 for every recommendation.
36. Treat recommendation preferred-suit data as transient until the recommendation
   becomes an accepted numeric bid; once accepted, copy the preferred suit onto
   the accepted bid record.

The default/balanced evaluator must include a regression fixture for weak
long-suit overbidding: with no current highest bid, the hand
`2♦ 4♦ 2♠ 3♠ 2♥ 8♠ Q♠ K♦ 10♦ 5♦ 7♣ 3♣ J♦` must recommend `Pass` or at most
`7`. It must not recommend `8` or higher. This fixture should keep long-suit
length from overpowering the absence of aces, outside winners, and strong top
control in the candidate Tarneeb suit.

The default/balanced evaluator must also include a regression fixture for
strong-but-not-10-safe five-card trump hands: with no current highest bid, the
hand `7♥ 6♦ 8♦ 4♠ 10♠ A♠ J♠ 10♦ A♥ K♥ 4♣ Q♠ 5♥` must recommend no higher than
`9`. It must not recommend `10` or higher. This fixture should keep side winners,
a singleton, and a five-card ace-high candidate Tarneeb suit from overpowering
the uncertainty of a 10-trick team commitment.

The default/balanced evaluator must also include a regression fixture for
ace-led five-card trump hands without king or queen support: with no current
highest bid, the hand `3♠ 6♥ 9♦ 2♣ 3♥ 2♠ J♦ 9♠ A♣ 2♦ 5♦ J♠ A♠` must recommend
`Pass` or at most `7`. It must not recommend `8` or higher. This fixture should
keep a five-card ace-led candidate Tarneeb suit and one outside ace from
overpowering weak top trump support and low overall trick certainty.

The default/balanced evaluator must also include a regression fixture for
strong-but-not-10-safe six-card trump hands: with no current highest bid, the
hand `K♣ A♦ 10♥ 10♠ 2♠ 8♣ 3♦ 6♦ Q♦ 2♦ 4♦ A♠ 4♠` must recommend no higher than
`9`. It must not recommend `10` or higher. This fixture should keep six-card
diamond length, ace-queen trump support without the king, outside winners, and
singleton value from overpowering the uncertainty of a 10-trick team commitment.

The default/balanced evaluator must also include a regression fixture for
five-card ace-king-queen-ten trump hands without outside aces: with no current
highest bid, the hand `Q♣ 10♠ Q♦ 4♣ 5♣ K♠ J♣ A♠ 5♦ K♦ Q♠ 7♠ 7♣` must prefer
spades and recommend no higher than `9`. It must not recommend `10` or higher.
This fixture should keep excellent five-card trump texture and a void from
overpowering the absence of outside aces, extra trump length, or clearly reliable
outside winners.

The default/balanced evaluator must also include a regression fixture for
five-card ace-king-queen-jack trump hands without the trump ten or outside aces:
with no current highest bid, the hand
`Q♥ J♥ J♣ Q♦ 4♣ A♥ Q♠ K♥ 8♦ K♣ 2♥ 4♦ 9♣` must prefer hearts and recommend no
higher than `9`. It must not recommend `10` or higher. This fixture should keep
strong five-card trump texture from overpowering the absence of the trump ten,
outside aces, extra trump length, or clearly reliable outside winners.

The default/balanced evaluator must also include regression fixtures for newer
conservative boundaries:

- The hand `5♥ 10♠ 8♠ 8♣ 6♠ 6♦ 8♦ J♠ A♥ A♣ 7♠ 7♣ 3♣` must recommend `Pass`,
  not `7` or higher, because a four-card ace-low clubs candidate with one outside
  ace is not enough to open.
- The hand `2♣ K♦ Q♦ 10♦ K♠ 8♥ 3♦ 4♥ 7♦ 6♥ 10♣ K♣ A♠` must prefer diamonds
  but recommend no higher than `7`, not `8` or higher, because five-card
  king-queen-ten trump missing the ace should not be lifted by side kings and
  only one outside ace.
- The hand `3♦ 10♠ 3♥ A♦ 4♦ J♦ 4♥ A♠ 6♥ 8♦ 9♦ K♠ 7♠` must prefer diamonds
  but recommend no higher than `9`, not `10` or higher, because six-card
  ace-jack trump without king, queen, or ten support is not 10-safe from one
  outside ace, one outside king, and a void alone.
- The hand `J♦ 5♥ A♠ K♥ Q♦ 4♠ 8♦ 10♥ 4♣ 10♦ 4♦ 6♥ A♥` must prefer hearts but
  recommend no higher than `8`, not `9` or higher, because five-card
  ace-king-ten trump missing queen and jack should not reach 9 from one outside
  ace and one singleton alone.
- The hand `3♠ Q♣ J♠ 10♣ 4♣ A♣ A♦ 7♥ 7♠ 9♠ 8♣ 2♥ Q♠` must prefer clubs but
  recommend no higher than `8`, not `9` or higher, because five-card
  ace-queen-ten trump missing king and jack should not reach 9 from one outside
  ace and one singleton alone.
- The hand `J♥ 9♦ 4♥ 8♦ 4♣ K♠ A♥ Q♥ 3♦ K♥ 5♠ J♠ 3♥` must prefer hearts but
  recommend no higher than `10`, not `11` or higher, because six-card
  ace-king-queen-jack trump without outside aces should not reach 11 from trump
  texture and one side king alone.
- The hand `J♣ A♣ 5♦ J♦ 6♣ K♠ K♥ 9♥ 8♠ 8♦ 6♠ J♥ A♥` must prefer hearts but
  recommend no higher than `8`, not `9` or higher, because four-card ace-king-jack
  trump is too short for 9 from one outside ace and one outside king.
- The hand `A♥ A♦ K♠ 6♦ Q♥ J♣ Q♦ 4♠ 6♣ K♦ 10♥ A♣ K♣` must prefer clubs but
  recommend no higher than `9`, not `10` or higher, because four-card
  ace-king-jack trump remains too short for 10 even with two outside aces and
  side king/queen honors.
- The hand `6♦ Q♥ 9♠ 8♠ 10♥ 6♠ A♠ 5♦ K♠ Q♣ 7♥ 8♣ A♣` must prefer spades but
  recommend no higher than `8`, not `9` or higher, because four-card ace-king-low
  trump should not reach 9 from one outside ace plus side queens.
- The hand `A♣ 5♦ K♠ 5♣ 4♥ Q♣ 2♥ J♥ A♥ 8♠ 7♣ 2♠ J♣` must prefer clubs but
  recommend no higher than `8`, not `9` or higher, because four-card
  ace-queen-jack trump should not reach 9 from one outside ace plus one outside
  king.
- The hand `9♥ 2♥ Q♠ 6♠ 8♦ Q♣ 4♥ 2♣ 8♣ 6♦ 5♥ A♠ 4♠` must treat spades as the
  best candidate but recommend `Pass`, not `7` or higher, because four-card
  ace-queen-low trump with no outside aces or kings should not open from ordinary
  outside queen support.
- The hand `7♥ J♣ K♠ Q♦ 7♠ 9♥ 7♦ 6♣ 10♣ A♣ 3♠ 6♠ 4♥` must treat clubs as the
  best candidate but recommend `Pass`, not `7` or higher, because four-card
  ace-jack-ten trump missing king and queen should not open without outside aces,
  void or singleton support, or stronger top trump texture.
- The hand `J♣ A♣ J♠ 5♥ Q♦ 8♥ 9♦ 2♦ 5♣ J♦ 5♠ 3♠ 10♣` must treat clubs as the
  best candidate but recommend `Pass`, not `7` or higher, because four-card
  ace-jack-ten-low trump with no outside aces or kings, no void or singleton
  support, and only ordinary outside queen/jack support should not open without
  stronger trump texture, outside ace or king support, extra length, useful
  short-suit shape, or partnership context.
- The hand `7♥ J♦ Q♣ K♥ J♠ A♦ 6♠ 8♦ 5♣ 5♦ 8♠ A♠ Q♥` must recommend no higher
  than `7`, not `8` or higher, because shallow three-card king-queen or four-card
  ace-jack-low trump candidates should not reach 8 from two outside aces and one
  outside king alone.
- The hand `7♠ 8♠ Q♦ 9♦ A♥ 2♦ 9♣ Q♥ K♥ 7♣ 2♥ 9♥ 5♣` must prefer hearts but
  recommend no higher than `8`, not `9` or higher, because five-card
  ace-king-queen trump missing jack and ten should not reach 9 without outside
  aces or stronger side winners.
- The hand `J♠ 3♥ 6♠ J♥ 9♠ 8♦ 4♦ K♥ 9♣ 9♦ A♣ A♥ 4♥` must prefer hearts but
  recommend no higher than `8`, not `9` or higher, because five-card
  ace-king-jack trump missing queen and ten should not reach 9 from one outside
  ace with no void or singleton support.
- The hand `7♦ Q♦ 3♥ A♠ 5♣ K♣ K♦ 4♦ 6♠ 5♦ 10♣ A♦ A♣` must prefer diamonds
  but recommend no higher than `11`, not `12` or higher, because six-card
  ace-king-queen trump missing jack and ten should not reach 12 from two outside
  aces and one outside king alone.
- The hand `J♠ Q♥ 3♦ 10♠ 3♥ A♦ 6♦ J♣ Q♦ K♦ Q♣ 2♦ 10♥` must prefer diamonds
  but recommend no higher than `9`, not `10` or higher, because six-card
  ace-king-queen trump missing jack and ten should not reach 10 without outside
  aces, outside kings, voids, or singleton support.
- The hand `7♠ 10♠ 5♠ 8♦ K♣ A♦ 8♠ 2♦ 9♣ Q♦ K♦ 6♠ 5♦` must prefer diamonds
  but recommend no higher than `10`, not `11` or higher, because six-card
  ace-king-queen trump missing jack and ten should not reach 11 from one outside
  king plus a void alone.
- The hand `9♥ 6♦ 6♠ K♠ 4♥ 10♠ 7♦ K♦ 7♥ Q♥ 3♥ Q♦ K♥` must prefer hearts but
  recommend no higher than `8`, not `9` or higher, because six-card king-queen
  trump missing ace, jack, and ten should not reach 9 from side kings/queens and
  a void when no outside aces are present.
- The hand `10♥ K♠ Q♠ 7♠ K♦ 2♦ 2♠ 7♦ 6♣ 3♣ 5♦ A♣ Q♦` must prefer diamonds
  but recommend no higher than `7`, not `8` or higher, because five-card
  king-queen trump missing ace, jack, and ten should not be lifted by one outside
  ace, one outside king, and one singleton alone.
- The hand `5♠ A♠ A♦ 4♦ 2♥ 10♦ A♥ A♣ 9♥ K♣ 7♣ Q♦ 2♦` must prefer diamonds
  but recommend no higher than `10`, not `11` or higher, because five-card
  ace-queen-ten trump missing king and jack should not reach 11 from three
  outside aces and one outside king alone.
- The hand `3♠ K♥ 3♦ 5♣ 8♥ A♣ 2♠ 9♣ 6♠ 10♥ 8♣ Q♣ A♥` must recommend no
  higher than `8`, not `9` or higher, because four-card ace-king-ten or
  ace-queen texture remains limited by short trump length.
- The hand `10♣ 8♠ 5♠ 9♠ 3♥ J♣ K♦ A♣ J♥ 6♥ 4♦ J♦ K♣` must prefer clubs but
  recommend no higher than `7`, not `8` or higher, because four-card
  ace-king-jack-ten trump without outside aces is still too short for an
  8-trick commitment.
- The hand `7♠ K♣ 9♣ 3♦ 9♠ 2♥ 4♦ 6♥ Q♥ K♥ 10♣ K♦ A♦` must prefer diamonds
  but recommend no higher than `7`, not `8` or higher, because four-card
  ace-king trump with low remaining trump cards and no outside aces should not
  reach 8 from ordinary outside kings.
- The hand `A♦ 10♦ 2♣ Q♣ J♦ 9♥ Q♠ 4♥ 7♦ K♥ 9♦ 5♣ K♠` must prefer diamonds
  but recommend `Pass`, not `7` or higher, because five-card ace-jack-ten trump
  missing king and queen should not open without outside aces or stronger trump
  texture.
- The hand `9♠ 6♥ 10♠ 8♥ 8♣ J♦ J♣ 7♦ K♣ K♦ 3♠ A♠ 7♠` must prefer spades but
  recommend `Pass`, not `7` or higher, because five-card ace-ten trump missing
  king, queen, and jack should not open without outside aces, useful short-suit
  shape, or stronger trump texture.
- The hand `A♣ 6♥ 5♥ 8♥ 3♠ 4♦ 3♣ 4♠ A♦ 6♦ A♥ 4♥ K♣` must prefer hearts but
  recommend no higher than `7`, not `8` or higher, because five-card ace-low
  trump should not reach 8 from two outside aces and one outside king alone.
- The hand `2♦ 5♠ Q♦ A♦ 8♦ 10♦ 6♠ 2♠ 10♥ 2♥ 3♦ 4♦ 9♥` must prefer diamonds
  but recommend no higher than `10`, not `11` or higher, because seven-card
  ace-queen-ten trump missing king and jack still lacks enough top control or
  outside winners for 11.
- The hand `A♠ 7♠ A♣ 4♣ 3♠ 5♠ 9♠ 7♥ 4♥ J♦ Q♠ 4♠ 3♥` must prefer spades but
  recommend no higher than `10`, not `11` or higher, because seven-card
  ace-queen trump missing king, jack, and ten should not reach 11 from one
  outside ace and one singleton alone.
- Seven-card ace-king-queen trump hands missing jack and ten, with at most one
  outside ace, must recommend no higher than `11`, not `12` or higher, because
  the missing middle trump controls leave the hand short of 12-level certainty
  without extra trump length, multiple reliable outside winners, or exceptional
  partnership context. Representative hands include
  `6♣ 4♥ 3♣ 2♥ 8♥ A♠ K♥ Q♥ A♥ 5♥ 4♦ 10♣ K♣` and
  `A♠ K♥ 8♣ 7♠ Q♥ A♥ 4♠ 7♥ 4♣ 7♣ 8♥ 2♥ 4♥`.
- The hand `7♦ 4♥ 7♥ 9♦ 5♥ Q♦ 2♥ J♦ 6♦ A♦ 2♦ 10♦ 5♠` must prefer diamonds but
  recommend no higher than `11`, not `12` or higher, because eight-card
  ace-queen-jack-ten trump missing king should not reach 12 without outside aces
  or outside kings.

Bidding terminal rules:

1. If any player bids `13`, set every other player's bid value to `Pass` and end
   bidding.
2. If at least one numeric bid exists, end bidding when every player except the
   current highest bidder has `Pass`.
3. If all four players pass before any numeric bid is accepted, end bidding with
   no highest bidder and mark the completion outcome as `allPassRedeal`.
4. Change the status label from `Deal complete` to `Bidding complete`.
5. Hide the South `Bid` button completely.
6. Fade the full `Bidding` area out over one second.
7. After the fade-out completes, remove the `Bidding` area from layout.
8. If a numeric high bid exists, show the post-bidding summary with the
   high-bidding team, high bid value, and `Tarneeb` suit symbol from the high
   bidder's accepted bid record.
9. If no numeric high bid exists, show no high-bidding team or Tarneeb summary
   and start a fresh automatic deal after the fade-out completes.
10. The automatic deal rotates `dealerSeat` counterclockwise to the previous
   dealer's right, creates and shuffles a fresh deck, logs each completed hand,
   initializes bid values to `--`, and begins the new deal animation.
11. Do not proceed into post-bidding Tarneeb suit selection, winning-bid trick
   flow, trick play, or scoring.

The automated bid evaluator should be deterministic and injectable so tests can
verify bid progression, preferred-suit metadata, conservative calibration, and
terminal states.

### 5.7 Replacement Deal

The visible `Deal` action should be available in the dealt state. When invoked:

1. Previous hands and bid values are cleared or replaced.
2. The dealer rotates counterclockwise from the previous `dealerSeat`.
3. A fresh full deck is created or the previous full deck is reset.
4. The deck is shuffled.
5. Cards are assigned into four 13-card chunks.
6. The new completed deal is validated.
7. A fresh bidding round is initialized with all bid values set to `--`.
8. The first bidding turn is set to the player on the rotated dealer's right.
9. The same four-step 13-card stack animation plays from the table center.
10. South stays face-down until all four stacks arrive, then expands with 13
    backs and flips face-up left-to-right.
11. The presentation remains in `phase = dealt` after the animation and South
    reveal resolve.
12. The undealt deck stack remains hidden after completion.
13. All station outlines remain default after the completed replacement deal.
14. The dealer badge remains visible on the rotated current dealer.
15. The status label is reset to `Deal complete` above the bottom control row
    after the South reveal completes.
16. The `Bidding` area appears with fresh pending bid values and then resolves
    according to the bidding round rules.
17. The UI continues to use the portrait table layout, rounded-square stations,
   shared card sizing, and token-backed suit presentation rules.

Replacement `Deal` should use transient animation state rather than a new domain
phase. The rotated dealer and pending completed deal may be staged for animation
before the final `dealt` presentation replaces the old hands.

### 5.8 All-Pass Automatic Redeal

When all four players resolve to `Pass` before any numeric bid is accepted, the
current hand is abandoned after the terminal bidding transition. The automatic
redeal should reuse the replacement-deal machinery with an automatic trigger
instead of a visible button tap:

1. Finish resolving the fourth `Pass` value using the normal one-second bid
   value fade/color transition.
2. Set `biddingCompletionOutcome = allPassRedeal`.
3. Update the status label to `Bidding complete`.
4. Hide the South `Bid` button completely.
5. Fade the full `Bidding` area out over one second.
6. Do not create or show a post-bidding summary.
7. Rotate `dealerSeat` counterclockwise to the previous dealer's right.
8. Clear or replace the abandoned hands, bid values, accepted bid records,
   recommendation metadata, draft South bid state, post-bidding South suit
   state, and terminal bidding presentation state.
9. Create a fresh full deck, shuffle it, assign four 13-card hands, validate the
   completed deal, and log South, East, North, and West hands.
10. Stage and play the same four-step dealer-relative 13-card stack animation,
    including South interim fanned backs when applicable, followed by the
    1.5-second South backs/flip reveal.
11. After the animation and South reveal resolve, show the fresh completed deal
    with the rotated dealer badge, `Deal complete` status, and a fresh `Bidding`
    area initialized to `--`.
12. Start the new bidding round with the first turn at the player on the new
   dealer's right.

The all-pass automatic redeal must not briefly show an all-pass summary or
post-bidding Tarneeb result. It also must not route through `notStarted`; the
user remains in the dealt table flow while the fresh deal replaces the abandoned
hand.

### 5.9 New Game Reset

The visible `New Game` action should be available in both MVP phases. When
invoked:

1. Presentation state returns to `phase = notStarted`.
2. The four canonical seats remain present as South, West, North, and East.
3. A dealer is selected for the new game.
4. All player hands are cleared.
5. The South expanded hand, simulated hidden hands, bidding area, bid values,
   post-bidding summary, and status label are hidden.
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
  stations, plus the post-reveal bidding area or post-bidding summary under South.
- A bottom control area containing the status label when applicable and the
  bottom `New Game` and `Deal` buttons.

The bottom controls must remain usable on supported devices. If scrolling is
needed on small screens, the implementation must avoid a layout where the user
cannot reach the controls or where the South hand, bidding area, or
post-bidding summary overlaps them.

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
- No visible `Bidding` area before the first deal.
- No visible post-bidding summary before the first deal.
- No `Deal Cards` or `New Deal` labels.
- No bidding, trump/Tarneeb suit, trick, scoring, or game-over UI before the
  first deal.

### 6.3 Dealt Table Screen

Required elements:

- Portrait orientation only.
- Circular card table remains in the main table area.
- Undealt 52-card deck stack is absent.
- Four player stations continue to surround the card table.
- All station outlines use the default station outline.
- Current dealer station continues to show the circular `D` badge until the next
  deal request advances the dealer.
- South station has expanded below the card table and displays 13 visible cards
  after completing the backs-first left-to-right reveal.
- West, North, and East display 13 hidden card backs each.
- Hearts and Diamonds use the `suitWarm` role.
- Clubs and Spades use the `suitNeutral` role.
- Exposed and hidden cards use the same base size and standard-card aspect ratio.
- West, North, and East stations remain compact when screen space allows.
- A bordered `Bidding` area appears under the South station after the South
  reveal completes.
- The `Bidding` area uses `color.bidArea.*` tokens and reads as part of the table
  screen, not a modal.
- The `Bidding` area contains a table showing South, East, North, and West.
- Each table value begins as `--`.
- Resolved values are `Pass` or numeric bids 7 through 13.
- The South bid chips appear only while South's bidding turn is active.
- The South bid chips contain `Pass` and the current legal numeric bids through
  13.
- No South Tarneeb suit selector appears during the in-progress bidding round.
- The South `Bid` button appears under the South player bid value while bidding
  is in progress.
- The South `Bid` button is disabled while it is not South's turn.
- The South `Bid` button is enabled on South's turn when the selected bid value
  is legal.
- The South `Bid` button disappears completely after bidding is complete.
- East, North, and West show non-interactive resolved bid values after their
  simulated turns resolve.
- East, North, and West bid updates take at least one second before their
  displayed values change.
- Bid value changes use a one-second fade/color transition. The current highest
  numeric bid remains yellow; superseded previous high bids transition to white.
- When bidding completes, the full `Bidding` area fades out over one second and
  is removed from layout.
- If East, North, or West has the numeric high bid, a post-bidding summary
  appears after the fade-out with `East-West` or `North-South`, the bid value,
  and `Tarneeb` with the preferred suit symbol in a compact white chip.
- If South has the numeric high bid, a post-bidding South suit-setting panel
  appears after the fade-out. It uses white-background suit chips with
  black Spades/Clubs and red Hearts/Diamonds, a disabled-until-selected `Set`
  button, and then shows the final summary after `Set`.
- If all four players pass before any numeric bid is accepted, no summary
  appears and a fresh deal starts automatically after the fade-out with the
  dealer advanced counterclockwise.
- The status label appears above the bottom control row and displays
  `Deal complete` after the South reveal completes until bidding completes, then
  `Bidding complete`.
- Bottom buttons are labeled `New Game` and `Deal`.
- No `Deal Cards` or `New Deal` labels.
- No gameplay controls beyond the active South bid selector, South `Bid` button,
  South post-bidding Tarneeb suit-setting panel when South is the numeric high
  bidder, the non-interactive post-bidding summary, and replacement deal action.

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
- After all hands are dealt, South expands below the table with 13 backs, flips
  face-up left-to-right, and then displays all exposed human cards.
- North, West, and East should be compact and sized around their labels plus
  hidden card arrays.
- Station labels should remain readable and should not collide with cards.
- The bottom controls should remain reachable and should not cover cards.
- On a small supported simulator, spacing may compress or the table may scroll,
  but labels, cards, bid table, in-progress South `Bid` button, status label,
  and available controls must remain usable.

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

### 6.9 Bidding Area

The bidding area must:

- Appear only after the deal and South reveal complete.
- Sit under the South player station.
- Use a visible border and the bidding area tokens from `design-tokens.md`.
- Be labeled `Bidding`.
- Contain a table with South, East, North, and West entries.
- Show exactly one value per player.
- Initialize every value as `--`.
- Use only `--`, `Pass`, numeric bid values 7 through 13, or the active South
  bid-chip controls.
- Render the South bid chips only when it is South's turn.
- Do not render a South Tarneeb suit selector inside the in-progress `Bidding`
  area.
- Use only `♠`, `♣`, `♥`, and `♦` in the post-bidding South Tarneeb suit
  selector.
- Render the South `Bid` button under the South bid value while bidding is in
  progress.
- Show the South `Bid` button disabled while it is not South's turn.
- Show the South `Bid` button enabled on South's turn only when the draft bid
  value is legal.
- Hide the South `Bid` button completely after bidding is complete.
- Render East, North, and West values as static non-interactive resolved values.
- Delay each simulated player bid display update by at least one second.
- Use a one-second fade/color transition when a value changes from `--`, from
  the South selector, or from any previous visible value.
- Render the current highest numeric bid using the `New Game` button yellow, and
  transition a superseded previous high bid back to white when a higher bid is
  accepted.
- Fade the entire bidding area out over one second after terminal bidding.
- Remove the bidding area from layout after the fade-out completes.
- Start an automatic fresh deal after the fade-out when terminal bidding was
  caused by all four players passing before any numeric bid was accepted.
- Avoid covering the South hand, the status label, or bottom controls.
- Avoid explaining bidding rules in visible app copy.

The bid table may use rows or compact columns depending on available space. The
table should prioritize readability over decorative density and should use
token-backed divider, label, and value colors.

### 6.10 Post-Bidding Summary

The post-bidding summary must:

- Appear only after bidding completes, the one-second `Bidding` area fade-out
  completes, any required South suit-setting step is complete, and a numeric
  high bid exists.
- Sit in the same under-South region previously occupied by the bidding area.
- Use `color.postBiddingSummary.*` and `layout.postBiddingSummary.*` tokens.
- Display the high-bidding team as `East-West` when East or West is highest and
  `North-South` when North or South is highest.
- Display the high bid value from 7 through 13.
- Display a `Tarneeb` label with one suit symbol: `♠`, `♣`, `♥`, or `♦`.
- Render the suit symbol in the same font as the bid value, inside a compact
  white chip with just enough padding to separate it from the dark table
  surface.
- Use black suit color for `♠` and `♣`, and red suit color for `♥` and `♦`.
- Remain non-interactive; it must not use a drop-down, segmented picker, button,
  or other suit-selection affordance.
- Avoid covering the South hand, the status label, or bottom controls.

If bidding completes with no numeric high bid, the post-bidding summary remains
hidden and the all-pass automatic redeal path replaces the abandoned hand.

### 6.11 Hidden Cards

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
- Disappear after the fourth 13-card stack arrives.
- Never expose rank or suit text/symbols.

Hidden hands may use overlap to conserve space. The undealt deck stack should
use the squared-stack geometry tokens while tests or accessibility metadata verify the
required hidden-card count, center placement, stack token usage, and no card
identities are revealed.

### 6.12 Bottom Controls

The bottom controls must:

- Show a button labeled `Deal` before the first deal.
- Continue showing a button labeled `Deal` after a completed deal.
- Show a button labeled `New Game` next to `Deal` before the first deal.
- Continue showing a button labeled `New Game` next to `Deal` after a completed
  deal.
- Show a status label above the bottom control row after a completed deal and
  South reveal.
- Display `Deal complete` after the South reveal completes and before bidding
  completes, then `Bidding complete` after bidding completes.
- Use primary deal button tokens for `Deal`.
- Use secondary new-game button tokens for `New Game`.
- Reset to a launch state when `New Game` is tapped.
- Avoid `Deal Cards` and `New Deal` in visible labels and accessibility labels.
- Remain usable when the South station expands and the bidding area or
  post-bidding summary appears after the South reveal.

The exact meaning of "very bottom" is ambiguous with respect to the iOS safe
area and scrollable content. This design does not invent a stricter coordinate
rule; it flags the issue in section 12.

### 6.13 Prohibited UI

The MVP must not show:

- Post-summary editable Trump/Tarneeb suit selector. The only interactive
  Tarneeb suit selector is South's post-bidding suit-setting panel when South is
  the numeric high bidder.
- Play-card controls.
- Trick area.
- Scoreboard.
- Game-over state.
- Landscape-only layout.

## 7. State Transitions

| Current State | Trigger | Result |
| --- | --- | --- |
| App launch | None | Create four empty canonical seats, randomly select one dealer, show `notStarted` in portrait, show the dealer badge, and place the squared undealt deck stack at the very center of the card table. |
| `notStarted` | Tap visible `Deal` | Create a fresh valid deal, play the dealer-relative hidden-stack animation, keep South card faces hidden until all four hands are dealt, keep any received South stack visible as fanned backs until final reveal, expand South with 13 backs, flip South face-up left-to-right over 1.5 seconds, initialize bidding values to `--`, hide the undealt deck stack, keep all station outlines default, keep the current dealer badge visible, show the `Bidding` area, and move to `dealt`. |
| `notStarted` | Tap visible `New Game` | Remain in `notStarted`; no deal starts. Dealer re-randomization is ambiguous. |
| `dealt` | South bid chip changes during South's turn | Update the South draft bid selection only; do not commit the value until the South `Bid` button is tapped. No suit is required during in-progress bidding. |
| `dealt` | Tap South `Bid` button during South's turn | Commit South's selected value only when it is `Pass` or a legal numeric bid. Replace the bid chips with the committed value, then either continue bidding with the South `Bid` button visible and disabled or complete bidding with the button hidden, the status label set to `Bidding complete`, and the bidding-area fade started. |
| `dealt` | Simulated bid turn resolves | Wait at least one second, apply the resolved `Pass` or accepted numeric value with the one-second bid fade/color transition, store preferred trump/Tarneeb suit only for accepted numeric bids, keep the current highest numeric bid yellow, transition any superseded previous high bid to white, then continue or complete bidding. |
| `dealt` | Bidding reaches terminal state with numeric high bid | Update status label to `Bidding complete`, hide the South `Bid` button completely, fade the full `Bidding` area out for one second, remove it, then show either the South post-bidding suit-setting panel when South is the high bidder or the final post-bidding summary when a simulated player is the high bidder. |
| `dealt` | Tap South post-bidding `Set` button | When South is the numeric high bidder and has selected `♠`, `♣`, `♥`, or `♦`, store the selected Tarneeb suit on South's accepted bid record, hide the suit-setting panel, and show the final post-bidding summary. |
| `dealt` | Bidding reaches terminal state with all four players passing before any numeric bid | Update status label to `Bidding complete`, hide the South `Bid` button completely, fade the full `Bidding` area out for one second, remove it, keep the post-bidding summary hidden, rotate dealer counterclockwise, and automatically start a fresh valid deal with a fresh bidding round. |
| `dealt` | Tap visible `Deal` | Clear/replace previous hands, bids, and post-bidding summary; rotate dealer counterclockwise; create a fresh valid deal; play the dealer-relative hidden-stack animation, South interim fanned-back state when applicable, and 1.5-second South backs/flip reveal; initialize fresh bid values to `--`; keep undealt deck stack hidden; keep station outlines default; show the badge on the rotated dealer; show the fresh `Bidding` area after the reveal; and remain in `dealt`. |
| `dealt` | Tap visible `New Game` | Clear all hands, bids, and post-bidding summary; select a dealer for the new game; hide dealt and bidding UI; restore the squared undealt deck stack at the very center of the card table; show the dealer badge; and move to `notStarted`. |
| `dealt` | Tap visible card | No gameplay action occurs. |
| `dealt` | Tap simulated hidden stack | No gameplay action occurs. |
| Any state | Device rotates | App remains portrait. |

No transition may enter post-summary interactive trump selection, trick play,
scoring, winning-bid trick flow, or game completion.

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
- Bid state exists for all four seats in `dealt`.
- Each bid state is pending `--`, active South selection, `Pass`, or one numeric
  value from 7 through 13.
- Accepted simulated numeric bid states store a preferred trump/Tarneeb suit
  alongside the bid value immediately; South numeric high bids store South's
  selected suit after the post-bidding `Set` action and before the final summary.
- Pending `--` values are valid only before that player's bid turn resolves.
- Pending `--` and `Pass` states do not store a preferred trump/Tarneeb suit.
- Active South selection state carries only the draft bid value during
  in-progress bidding; post-bidding South suit selection is a separate draft.
- South bid state can be committed only from the active South turn using `Pass`
  or a currently legal numeric value; no in-progress Tarneeb suit is required.
- East, North, and West bid values are generated turn resolutions and are not
  interactive.
- Numeric bid values must be higher than the previous highest numeric bid.
- All-pass terminal bidding before any numeric bid must produce no
  `postBiddingSummary` and must schedule the automatic redeal outcome.

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
- South displays exactly 13 exposed cards only after all four hands have been
  dealt and the South reveal flip has completed.
- South ranks and suits are not visible while any hand remains undealt, while
  the South station is showing 13 backs, or while the South reveal flip is in
  progress.
- If South receives its 13-card stack before the full deal completes, South
  displays that received stack as fanned backs until final reveal begins.
- West, North, and East each display or represent exactly 13 hidden card backs
  once their stack arrives.
- Simulated card ranks and suits are not visible.
- Hearts and Diamonds use `suitWarm`, resolved through `color.card.suit.red`.
- Clubs and Spades use `suitNeutral`, resolved through
  `color.card.suit.black`.
- All colored, typographic, station-outline, title-shadow, bidding summary,
  South reveal timing, and undealt-deck layout/stack UI values reference tokens from
  `specs/007-mvp/design-tokens.md`; no concrete color or undealt-deck stack
  geometry values are defined in this design.
- The `Bidding` area is visible in `dealt` only after the South reveal flip
  completes and while bidding is active or fading out, and hidden in
  `notStarted`.
- The `Bidding` area is labeled `Bidding`.
- The bid table shows South, East, North, and West.
- Bid entries begin as `--`.
- The South bid value is rendered as bid chips only when it is South's turn.
- The South bid chips contain only `Pass` and the currently legal numeric bid
  values through 13.
- The South Tarneeb suit selector is absent during in-progress bidding and
  visible only after bidding when South is the numeric high bidder and the final
  summary is waiting on South's suit choice.
- The South `Bid` button is visible while bidding is in progress.
- The South `Bid` button is disabled while it is not South's turn and enabled on
  South's turn only when the draft value is `Pass` or a currently legal numeric
  value.
- The South `Bid` button disappears completely after bidding completes.
- The `Bidding` area enters a one-second fade-out when bidding completes and is
  hidden after the fade-out completes.
- The post-bidding summary is hidden before bidding completes and while the
  `Bidding` area is fading out.
- When a numeric high bid exists, the post-bidding summary displays the correct
  high-bidding team, bid value, and Tarneeb suit symbol.
- When no numeric high bid exists, the post-bidding summary is hidden.
- When no numeric high bid exists because all four players passed, the next
  visible completed hand comes from an automatic fresh deal with the dealer
  advanced counterclockwise.
- Simulated bid value display updates take at least one second before the value
  changes.
- Bid value changes use a one-second tokenized fade/color transition, with the
  current highest numeric bid in the `New Game` button yellow and any
  superseded previous high bid transitioning to white.
- Simulated numeric bid recommendations include preferred suit and confidence
  metadata, and accepted numeric bids store preferred trump/Tarneeb suit
  alongside the bid value for summary display.
- Weak long-suit simulated hands without aces, outside winners, or strong top
  trump control do not produce default/balanced recommendations above 7.
- Strong but not 10-safe five-card trump hands with side winners do not produce
  default/balanced recommendations above 9.
- Ace-led five-card trump hands without king or queen support do not produce
  default/balanced recommendations above 7 unless additional strong evidence is
  present.
- Strong but not 10-safe six-card trump hands with ace-queen support but no king
  do not produce default/balanced recommendations above 9 from length, side
  winners, and singleton value alone.
- Five-card ace-king-queen-ten trump hands without outside aces do not produce
  default/balanced recommendations above 9 from trump texture and a void alone.
- Five-card ace-king-queen-jack trump hands missing ten, without outside aces,
  do not produce default/balanced recommendations above 9 from trump texture,
  one outside king, and one singleton alone.
- Five-card ace-king-ten trump hands missing queen and jack do not produce
  default/balanced recommendations above 8 from one outside ace and one
  singleton alone.
- Five-card ace-queen-ten trump hands missing king and jack do not produce
  default/balanced recommendations above 8 from one outside ace and one
  singleton alone.
- Six-card ace-king-queen-jack trump hands without outside aces do not produce
  default/balanced recommendations above 10 from trump texture and one side king
  alone.
- Four-card ace-low trump hands with only one outside ace do not open at 7 by
  default.
- Five-card king-queen-ten trump hands missing the ace do not produce
  default/balanced recommendations above 7 from one outside ace plus side kings.
- Six-card ace-jack trump hands without king, queen, or ten support do not
  produce default/balanced recommendations above 9 from one outside ace, one
  outside king, and a void alone.
- Four-card ace-king-jack, ace-king-low, and ace-queen-jack trump hands do not
  produce default/balanced recommendations above 8 from ordinary outside support.
- Four-card ace-king-jack trump hands do not produce default/balanced
  recommendations above 9 from two outside aces plus side king/queen honors.
- Four-card ace-queen-low and four-card ace-jack-ten trump hands without outside
  ace support do not open by default.
- Four-card ace-jack-ten-low trump hands with no outside aces or kings, no
  void or singleton support, and only ordinary outside queen/jack support do not
  open by default.
- Shallow three-card king-queen or four-card ace-jack-low trump candidates do
  not produce default/balanced recommendations above 7 from two outside aces and
  one outside king alone.
- Five-card ace-king-queen trump hands missing jack and ten, with no outside
  aces, do not produce default/balanced recommendations above 8.
- Five-card ace-king-jack trump hands missing queen and ten, with only one
  outside ace and no short-suit support, do not produce default/balanced
  recommendations above 8.
- Six-card ace-king-queen trump hands missing jack and ten do not produce
  default/balanced recommendations above 11 from two outside aces and one outside
  king alone.
- Six-card ace-king-queen trump hands missing jack and ten do not produce
  default/balanced recommendations above 9 when they have no outside aces, no
  outside kings, and no void or singleton support.
- Six-card ace-king-queen trump hands missing jack and ten do not produce
  default/balanced recommendations above 10 from one outside king plus void or
  singleton support.
- Six-card ace-jack-ten trump hands missing king and queen do not produce
  default/balanced recommendations above 9 from two outside aces or protected
  side honors alone.
- Six-card ace-king-queen trump hands missing jack and ten do not produce
  default/balanced recommendations above 9 when they have no outside aces, even
  if ordinary side kings are present.
- Six-card ace-king-queen-ten trump hands missing jack do not produce
  default/balanced recommendations above 10 from only one outside ace plus
  ordinary side queen/king support.
- Six-card king-queen trump hands missing ace, jack, and ten do not produce
  default/balanced recommendations above 8 from side kings/queens and a void
  when no outside aces are present.
- Five-card king-queen trump hands missing ace, jack, and ten do not produce
  default/balanced recommendations above 7 from one outside ace, one outside
  king, and a singleton alone.
- Five-card ace-queen-ten trump hands missing king and jack do not produce
  default/balanced recommendations above 10 from three outside aces and one
  outside king alone.
- Four-card ace-king-ten or ace-queen texture hands do not produce
  default/balanced recommendations above 8 from ordinary outside support.
- Four-card ace-king-jack-ten trump hands without outside aces do not produce
  default/balanced recommendations above 7.
- Four-card ace-king-low trump hands without outside aces do not produce
  default/balanced recommendations above 7 from ordinary outside king support.
- Five-card ace-jack-ten trump hands missing king and queen, with no outside
  aces, resolve to `Pass` by default.
- Five-card ace-ten trump hands missing king, queen, and jack, with no outside
  aces and no short-suit support, resolve to `Pass` by default.
- Five-card ace-low trump hands do not produce default/balanced recommendations
  above 7 from two outside aces and one outside king alone.
- Seven-card ace-queen-ten or ace-queen trump hands missing adjacent high trump
  controls do not produce default/balanced recommendations above 10 without
  reliable outside winners or stronger trump texture.
- Seven-card ace-king-queen-ten trump hands missing jack do not produce
  default/balanced recommendations above 10 without outside aces or outside
  kings.
- Seven-card ace-low trump hands do not produce default/balanced recommendations
  above 8 from length plus only one outside ace.
- Seven-card ace-jack-low trump hands missing king, queen, and ten do not
  produce default/balanced recommendations above 8 from length plus only one
  outside ace.
- Four-card ace-king-queen-ten trump hands missing jack do not produce
  default/balanced recommendations above 8 from one outside ace and ordinary
  side honor support.
- Eight-card ace-queen-jack-ten trump hands missing king do not produce
  default/balanced recommendations above 11 without outside aces or outside
  kings.
- Simulated players pass by default when their partner is currently the highest
  bidder, raising only with clearly stronger independent trump potential.
- The bidding service rejects one-trick simulated raises over a partner even when
  the value came from an override, stale recommendation, or deterministic test
  recommender.
- South numeric bid records store the Tarneeb suit selected by South during the
  active bidding turn; South `Pass` records store no suit.
- Completed deals log exactly one readable 13-card console entry for each of
  South, East, North, and West.
- Exposed and hidden player cards use the same base card size.
- Player stations preserve the table-surrounding relationship.
- The status label appears above the bottom control row only after the South
  reveal flip completes and `phase = dealt`.
- The status label displays `Deal complete` after the South reveal completes and
  before bidding completes, then `Bidding complete` after bidding completes.
- Tapping `New Game` returns display state to `notStarted`, clears all hands,
  clears all bid values, clears the post-bidding summary, hides completion text
  and bidding UI, selects a dealer, shows the dealer badge, and restores the
  squared undealt deck stack at the very center of the card table.

## 9. Edge Cases

| Edge Case | Expected Handling |
| --- | --- |
| User taps `Deal` repeatedly in `notStarted` | Prevent overlapping deals; each accepted tap should result in one complete valid deal. |
| User taps `Deal` repeatedly in `dealt` | Previous hands, bids, and post-bidding summary are cleared/replaced, dealer rotation advances once per accepted replacement deal, and the result is another valid completed deal with fresh pending bid values. |
| User taps `Deal` during the deal animation | Ignore or disable the action until the animation resolves; do not create overlapping animations or advance dealer more than once. |
| User taps `New Game` during the deal animation | Ignore or disable the action until the animation resolves; do not leave partial hands on screen. |
| User taps `New Game` in `notStarted` | Remain in `notStarted`; do not start a deal. Whether the dealer is re-randomized is ambiguous. |
| User taps `New Game` in `dealt` | Reset to `notStarted`, select a dealer, clear hands, bids, and post-bidding summary, hide the status label, hide the `Bidding` area, show the dealer badge, and restore the squared undealt deck stack at the very center of the card table. |
| User taps `New Game` repeatedly | Remain in or return to the launch state without producing partial hands or a completed deal. |
| Random dealer selection returns an invalid seat | Invalid internal state; select only South, East, North, or West. |
| Dealer rotation advances from West | Wrap to South. |
| Dealer indication changes a station outline to blue | Invalid MVP 007 display; dealer indication must use the badge and all station outlines remain default. |
| Undealt deck stack is placed outside table or too close to edge | Invalid MVP 007 display; keep it inside the circular table with a buffer. |
| Undealt deck stack is offset away from the table center before deal | Invalid MVP 007 display; keep its center point aligned with the circular table center within layout tolerance. |
| Undealt deck stack renders with visible fan, spread, or rotation before deal | Invalid MVP 007 display; use tokenized squared-stack geometry with zero stack offset and zero rotation. |
| Shuffle returns same order by chance | Valid if the deck was actually passed through the shuffle operation; tests should not fail solely because random order matches source order. |
| Shuffle implementation loses or duplicates cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 007 scope. |
| Deck creation contains a duplicate or missing card | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 007 scope. |
| Deal assignment leaves undealt cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 007 scope. |
| Any player receives fewer or more than 13 cards | Internal validation should prevent rendering a completed deal; user-facing error handling is out of MVP 007 scope. |
| Simulated hand exposes card data in UI | Invalid MVP behavior; hidden players must show only `card_back.png` backs or equivalent hidden-card representation. |
| Initial deck stack exposes card data in UI | Invalid MVP behavior; the stack must not reveal ranks or suits. |
| Animated 13-card stack exposes card data in UI | Invalid MVP behavior; the moving stack must use hidden card backs only. |
| South hand exposes rank or suit before all four hands are dealt | Invalid MVP behavior; South cards must remain hidden until every station has received its 13-card stack. |
| South received stack disappears after arriving before the fourth deal movement | Invalid MVP behavior; keep the received South stack visible as fanned hidden backs until final South expansion begins. |
| South hand exposes rank or suit before the South reveal flip completes | Invalid MVP behavior; the reveal must show 13 backs first, then flip face-up left-to-right over 1.5 seconds. |
| Deal animation target order does not start at dealer's right | Invalid MVP 007 animation; use the dealer-relative counterclockwise target order. |
| Deal animation completes with center stack still visible | Invalid MVP 007 display; center stack must be gone after all 52 cards have been dealt. |
| `Deal complete` appears before the South reveal flip completes | Invalid MVP 007 display; status must wait until South cards have flipped face-up. |
| Bidding area appears before the South reveal flip completes | Invalid MVP 007 display; bidding UI is visible only after deal completion and the South reveal. |
| Bidding area missing after South reveal while bidding is active | Invalid MVP 007 display; show the bordered `Bidding` area under South after the reveal completes until terminal fade-out completes. |
| Bidding area overlaps South hand, status label, or bottom controls | Layout must adjust spacing or scrolling so South cards, bid controls, status label, `New Game`, and `Deal` remain usable. |
| Bid entry is not initialized as `--` | Invalid MVP 007 state; all four bid entries begin pending after the South reveal completes. |
| South bid selector appears outside South's turn | Invalid MVP 007 display; South bid chips are visible only on the active South turn. |
| South Tarneeb suit selector appears during in-progress bidding or when South is not the numeric high bidder | Invalid MVP 007 display; the South suit selector appears only after the `Bidding` area fades out, only when South is the numeric high bidder, and only until South taps `Set`. |
| South `Bid` button is hidden while bidding is in progress | Invalid MVP 007 display; the button must remain visible during in-progress bidding. |
| South `Bid` button is enabled outside South's turn | Invalid MVP 007 display; the button must be disabled unless South is the active bidding turn. |
| South `Bid` button is disabled for an active-turn legal bid draft | Invalid MVP 007 display; active South `Pass` and legal numeric bid drafts can be submitted without selecting a Tarneeb suit during in-progress bidding. |
| South `Bid` button remains visible after bidding is complete | Invalid MVP 007 display; hide the button completely when terminal bidding state is reached and fade the `Bidding` area away. |
| South bid selector contains an invalid value | Invalid MVP 007 state; selector options must be only `Pass` and currently legal numeric values through 13. |
| South post-bidding Tarneeb suit selector contains an invalid value | Invalid MVP 007 state; selector options must be only `♠`, `♣`, `♥`, and `♦`. |
| Simulated bid recommendation returns an invalid value | Invalid MVP 007 state; reject values outside `Pass` and 7 through 13. |
| Simulated weak long-suit hand recommends above 7 from length alone | Invalid PRD-017 calibration; the normal/balanced evaluator must reduce or gate length value when aces, outside winners, and strong trump control are absent. |
| Simulated five-card ace-high trump hand with side winners recommends 10 without enough extra control | Invalid PRD-017 calibration; the normal/balanced evaluator must cap strong but not 10-safe hands below 10. |
| Simulated five-card ace-led trump hand without king or queen support recommends above 7 from one outside ace and length | Invalid PRD-017 calibration; the normal/balanced evaluator must treat the hand as uncertain unless additional strong evidence is present. |
| Simulated six-card ace-queen trump hand without king support recommends 10 from length, outside winners, and singleton value | Invalid PRD-017 calibration; the normal/balanced evaluator must cap strong but not 10-safe six-card hands below 10 unless stronger 10-level trump control is present. |
| Simulated five-card ace-king-queen-ten trump hand without outside aces recommends 10 from top trump texture and a void | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this strong but not 10-safe shape below 10 unless extra support is present. |
| Simulated five-card ace-king-queen-jack trump hand missing ten recommends 10 without outside aces | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-10-safe shape at 9 unless extra trump length, the trump ten, reliable outside winners, stronger short-suit shape, or partnership context is present. |
| Simulated five-card trump hand with fewer than three top trump controls and fewer than three reliable outside winners recommends 10 from two outside aces | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-10-safe shape at 9 unless stronger trump controls, three reliable outside winners, or exceptional partnership context is present. |
| Simulated five-card ace-king-ten trump hand missing queen and jack recommends 9 from one outside ace and one singleton | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-9-safe shape at 8 unless stronger support is present. |
| Simulated five-card ace-queen-ten trump hand missing king and jack recommends 9 from one outside ace and one singleton | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-9-safe shape at 8 unless stronger support is present. |
| Simulated six-card ace-king-queen-jack trump hand without outside aces recommends 11 from trump texture and one side king | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-11-safe shape at 10 unless stronger support is present. |
| Simulated four-card ace-low trump hand opens at 7 from only one outside ace | Invalid PRD-017 calibration; the normal/balanced evaluator must pass unless stronger trump texture, outside winners, shape, or partnership context supports opening. |
| Simulated five-card king-queen-ten trump hand missing the ace recommends 8 from one outside ace and side kings | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this missing-ace shape at 7 unless stronger support is present. |
| Simulated six-card ace-jack trump hand missing king, queen, and ten recommends 10 from one outside ace, one outside king, and a void | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-10-safe shape below 10 unless stronger support is present. |
| Simulated four-card ace-king-jack, ace-king-low, or ace-queen-jack trump hand recommends 9 from ordinary outside support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap these short-trump shapes at 8 unless stronger support is present. |
| Simulated four-card ace-king-jack trump hand recommends 10 from two outside aces plus side king/queen honors | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this short-trump shape at 9 unless extra trump length, queen or ten trump support, exceptional short-suit shape, or partnership context is present. |
| Simulated four-card ace-queen-low or ace-jack-ten trump hand opens at 7 without outside ace support | Invalid PRD-017 calibration; the normal/balanced evaluator must pass unless stronger trump texture, outside ace support, useful short-suit shape, extra length, or partnership context supports opening. |
| Simulated four-card ace-jack-ten-low trump hand opens at 7 with no outside aces or kings, no void or singleton support, and only ordinary outside queen/jack support | Invalid PRD-017 calibration; the normal/balanced evaluator must pass unless stronger trump texture, outside ace or king support, useful short-suit shape, extra length, or partnership context supports opening. |
| Simulated shallow three-card king-queen or four-card ace-jack-low trump candidate recommends 8 from two outside aces and one outside king | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this shallow-trump shape at 7 unless stronger trump length, stronger top trump texture, additional reliable outside winners, useful short-suit shape, or partnership context is present. |
| Simulated five-card ace-king-queen trump hand missing jack and ten recommends 9 with no outside aces | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-9-safe shape at 8 unless stronger support is present. |
| Simulated five-card ace-king-jack trump hand missing queen and ten recommends 9 from one outside ace and no short-suit support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-9-safe shape at 8 unless queen or ten trump texture, extra trump length, additional outside winners, useful short-suit shape, or partnership context is present. |
| Simulated six-card ace-king-queen trump hand missing jack and ten recommends 12 from two outside aces and one outside king | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-12-safe shape at 11 unless stronger support is present. |
| Simulated seven-card ace-king-queen trump hand missing jack and ten recommends 12 from at most one outside ace | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-12-safe shape at 11 unless the trump jack or ten, extra trump length, multiple reliable outside winners, useful short-suit shape backed by enough trump control, or exceptional partnership context is present. |
| Simulated six-card ace-king-queen trump hand missing jack and ten recommends 10 with no outside aces, outside kings, voids, or singletons | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-10-safe shape at 9 unless stronger trump texture, reliable outside winners, useful short-suit shape, extra trump length, or partnership context is present. |
| Simulated six-card ace-king-queen trump hand missing jack and ten recommends 11 from one outside king plus void or singleton support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-11-safe shape at 10 unless stronger trump texture, reliable outside aces, additional side winners, extra trump length, or partnership context is present. |
| Simulated six-card ace-king-queen trump hand missing jack and ten recommends 11 from only one outside ace plus ordinary side king/queen support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-11-safe shape at 10 unless the trump jack or ten, extra trump length, multiple outside aces, additional protected side winners, useful short-suit shape, or partnership context is present. |
| Simulated six-card ace-king-low trump hand missing queen, jack, and ten recommends 10 from one outside ace plus ordinary side king/queen support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-10-safe shape at 9 unless stronger trump texture, multiple outside aces, additional protected side winners, useful short-suit shape, or partnership context is present. |
| Simulated six-card ace-king or ace-king-ten trump hand with queen and jack absent recommends 9 with no reliable outside winners | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-9-safe shape at 8 unless stronger trump texture, protected outside winners, multiple outside aces, exceptional short-suit shape, extra trump length, or partnership context is present. |
| Simulated six-card king-queen trump hand missing ace, jack, and ten recommends 9 from side kings/queens and a void with no outside aces | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this missing-ace shape at 8 unless the trump ace, stronger protected trump texture, reliable outside aces, additional side winners, extra trump length, or partnership context is present. |
| Simulated six-card king-queen-jack or king-queen-jack-ten trump hand missing ace recommends 9 from one outside ace plus ordinary side support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this missing-ace shape at 8 unless the trump ace, extra trump length, multiple outside aces, stronger protected side winners, useful short-suit shape backed by enough trump control, or partnership context is present. |
| Simulated seven-card ace-king-queen-jack-ten trump hand recommends 13 from only two outside aces | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-13-safe shape at 12 because 13 requires at least eight trump cards plus near-commanding texture. |
| Simulated five-card king-queen trump hand missing ace, jack, and ten recommends 8 from one outside ace, one outside king, and a singleton | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this missing-ace texture at 7 unless stronger support is present. |
| Simulated five-card ace-queen-ten trump hand missing king and jack recommends 11 from three outside aces and one outside king | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this not-11-safe shape at 10 unless stronger support is present. |
| Simulated four-card ace-king-ten or ace-queen texture hand recommends 9 from ordinary outside support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap short-trump textures below 9 unless stronger support is present. |
| Simulated four-card ace-king-jack-ten trump hand recommends 8 with no outside aces | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this short-trump shape at 7 unless stronger support is present. |
| Simulated four-card ace-king-low trump hand recommends 8 with no outside aces and ordinary outside kings | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this short-trump shape at 7 unless stronger support is present. |
| Simulated four-card ace-king-queen-ten trump hand missing jack recommends 9 from one outside ace and ordinary side honor support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this short-trump shape at 8 unless extra trump length, the trump jack, multiple outside aces, exceptional side certainty, or partnership context is present. |
| Simulated four-card ace-king-queen-jack trump hand missing ten recommends 9 from one outside ace and ordinary side honor support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this short-trump shape at 8 unless extra trump length, the trump ten, multiple outside aces, exceptional side certainty, or partnership context is present. |
| Simulated five-card ace-jack-ten trump hand missing king and queen opens at 7 with no outside aces | Invalid PRD-017 calibration; the normal/balanced evaluator must pass unless stronger trump texture, outside ace support, shape, extra length, or partnership context supports opening. |
| Simulated five-card ace-ten trump hand missing king, queen, and jack opens at 7 with no outside aces or short-suit support | Invalid PRD-017 calibration; the normal/balanced evaluator must pass unless stronger trump texture, outside ace support, useful short-suit shape, extra length, or partnership context supports opening. |
| Simulated five-card ace-low trump hand recommends 8 from two outside aces and one outside king | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this weak-trump-control shape at 7 unless stronger support is present. |
| Simulated seven-card ace-queen-ten or ace-queen trump hand recommends 11 while missing adjacent high trump controls and reliable outside winners | Invalid PRD-017 calibration; the normal/balanced evaluator must cap these long-but-texture-limited hands at 10 unless stronger support is present. |
| Simulated seven-card ace-jack-low trump hand missing king, queen, and ten recommends 9 from length plus one outside ace | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this length-heavy weak-texture shape at 8 unless protected king/queen trump texture, multiple reliable outside winners, useful short-suit shape backed by enough trump control, or partnership context is present. |
| Simulated seven-card king-queen-low trump hand missing ace, jack, and ten recommends 9 from length plus one outside ace and ordinary side support | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this missing-ace long suit at 8 unless the trump ace, protected jack or ten support, multiple outside aces, additional reliable side winners, useful short-suit shape, or partnership context is present. |
| Simulated eight-card ace-queen-jack-ten trump hand missing king recommends 12 without outside aces or outside kings | Invalid PRD-017 calibration; the normal/balanced evaluator must cap this long-but-not-12-safe shape at 11 unless the trump king, reliable outside winners, stronger side-suit support, useful short-suit shape, or partnership context is present. |
| Simulated player raises while partner is highest without clearly stronger trump potential | Invalid PRD-017 partner context; display `Pass` unless the hand has an adjusted recommendation at least two tricks higher plus strong independent trump control. |
| Bidding service accepts a simulated one-trick raise over that player's partner from an override, stale recommendation, or deterministic recommender | Invalid PRD-017 service resolution; display `Pass` and store no preferred suit metadata for that resolved bid. |
| Simulated numeric recommendation is not higher than the current high bid | Display `Pass` for that simulated player. |
| Accepted simulated numeric bid has no preferred trump/Tarneeb suit, or South final summary is shown without South's selected suit | Invalid Phase 2 bid state; simulated numeric bids require an evaluator preferred suit before acceptance, and South numeric high bids require the post-bidding `Set` action before the final summary appears. |
| `Pass` or pending state contains a preferred trump/Tarneeb suit | Invalid Phase 2 bid state; preferred suit metadata belongs only to accepted numeric bid records. |
| South commits `Pass` | Store South as `Pass` without preferred suit metadata and do not show the post-bidding suit-setting panel for that bid. |
| Simulated bid display updates immediately | Invalid MVP 007 display; wait at least one second before applying the simulated player's bid value. |
| Player bids `13` | Set all other players to `Pass` and end bidding. |
| Bidding completes but status remains `Deal complete` | Invalid MVP 007 display; update the status label to `Bidding complete`. |
| Bidding completes but the `Bidding` area stays visible after the fade duration | Invalid MVP 007 display; remove the `Bidding` area after the one-second fade-out. |
| Post-bidding summary appears before the `Bidding` area fade completes | Invalid MVP 007 display; wait until the terminal fade-out completes. |
| Numeric high bid exists but post-bidding summary is absent | Invalid MVP 007 display; show the high-bidding team, bid value, and `Tarneeb` suit symbol. |
| All players pass with no numeric high bid | Hide the `Bidding` area after the fade-out, do not show a high-bidding team or Tarneeb summary, advance the dealer counterclockwise, and start a fresh automatic deal. |
| All-pass automatic redeal reuses the abandoned hand or stale bid values | Invalid MVP 007 state; create and shuffle a fresh deck, replace hands and bid state, log the new hands, and initialize the new bidding table to `--`. |
| All-pass automatic redeal does not advance dealer | Invalid MVP 007 state; rotate dealer to the previous dealer's right using South -> East -> North -> West -> South order. |
| Post-bidding summary uses an invalid suit symbol | Invalid MVP 007 display; use only `♠`, `♣`, `♥`, or `♦`. |
| Post-bidding summary acts like a suit picker | Invalid MVP 007 display; the summary is non-interactive. |
| East, North, or West bid appears as an interactive control | Invalid MVP 007 display; only South is user-selectable. |
| Bid table attempts to start suit selection for East, North, West, or after the final summary is shown | Out of scope for MVP 007; only South receives a post-bidding suit-setting panel, only if South is the numeric high bidder, and the final summary is non-interactive. |
| Completed deal does not log all hands | Invalid developer diagnostics; log South, East, North, and West with 13 cards each after every completed deal. |
| Human hand sorting changes underlying ownership | Sorting must affect display only; it must not duplicate, remove, or reassign cards. |
| Small portrait screen cannot fit generous spacing | Compress spacing or allow scrolling while preserving the table relationship and bottom control usability. |
| Device rotates to landscape | App remains portrait. |
| South station expansion conflicts with bidding area, summary, or bottom controls | Layout must adjust spacing or scrolling so the South hand, `Bidding` area, post-bidding summary, status label, `New Game`, and `Deal` remain usable. |
| Card size calculation differs by station | Invalid if player hidden and exposed cards no longer share the same base dimensions. |
| Hidden stack overlap hides most cards | Acceptable only if the required hidden-card count is still represented and the stack remains visibly card-like. |
| Initial 52-card stack obscures the title before deal | Valid MVP 007 display; the title and deck stack share the table center, and the deck may layer above the title. |
| Appearance mode changes token rendering | `suitWarm` and `suitNeutral` must remain visually distinct in the supported appearance mode; do not invent appearance variants outside `design-tokens.md`. |
| `card_back.png` is missing from assets | Hidden player display and undealt deck stack cannot satisfy requirements; implementation should include and reference the asset by stable name. |
| A standard card face asset is missing or lacks `1x`, `2x`, or `3x` variants | Exposed South cards can appear blurry or fail to render; asset-catalog tests should require all 52 non-joker faces and all three scale variants. |
| Face-card rendering applies an additional rounded rectangle, clip, or border over xCards art | Invalid display; the xCards image already includes the card surface and native corner mask, so the SwiftUI face view should render the image directly with high-quality interpolation. |
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
| Deal animation presentation | Dealer-relative target order starts at dealer's right, uses four 13-card hidden stacks, decrements center-card count, keeps South card faces hidden until all hands are dealt, exposes South interim fanned-back state, exposes 1.5-second South backs/flip state, and exposes animation timing token keys. | PRD-005, PRD-015 |
| Replacement deal | Previous hands, bid values, and post-bidding summary are cleared/replaced, dealer rotates, fresh bidding state initializes as `--`, and another valid completed deal is produced from the visible `Deal` action. | PRD-008, PRD-009, PRD-012, PRD-014, PRD-016, PRD-018 |
| New Game reset | Visible `New Game` returns the presentation to `notStarted`, selects a dealer, clears hands, bid values, and post-bidding summary, hides status and bidding UI, shows the dealer badge, and restores the squared undealt deck stack at the very center of the table without dealing. | PRD-001, PRD-008, PRD-012, PRD-013, PRD-014, PRD-016, PRD-018 |
| South sorting | Visible South cards sort Hearts, Clubs, Diamonds, Spades and 2 through Ace after the South reveal flip completes. | PRD-006 |
| Card face assets | Every standard 52-card face maps to a stable `card_face_<rank><suit>` asset with `1x`, `2x`, and `3x` variants; joker face assets are absent. | PRD-006 |
| Suit presentation | Hearts/Diamonds map to `suitWarm` and red xCards face artwork; Clubs/Spades map to `suitNeutral` and dark xCards face artwork. | PRD-006, NFR-005 |
| Token boundary | Presentation values expose semantic roles or token keys instead of concrete color values. | PRD-006, PRD-010, PRD-014, NFR-003, NFR-005 |
| Table title presentation | Title maps to table-title font, fixed font size, tracking range, text color/opacity tokens, and shadow tokens. | PRD-001, PRD-010 |
| Card size config | Exposed and hidden player cards share the same base dimensions when represented in presentation config. | PRD-006, PRD-007, PRD-011 |
| Undealt deck stack presentation | Initial stack represents 52 hidden cards, uses hidden-card asset, is visible only before deal, appears at the very center of the card table, uses the tokenized squared-stack geometry, stays inside the table buffer, and exposes no ranks/suits. | PRD-005, PRD-010, PRD-014 |
| Dealer badge presentation | Current dealer station shows a circular `D` badge using dealer badge tokens, all station outlines remain default, and the badge remains visible until the next deal request advances the dealer. | PRD-005, PRD-014, NFR-005 |
| Bid state model | Bid states support pending `--`, active South bid draft selection, `Pass`, numeric bids 7 through 13, and a separate post-bidding South suit-setting draft when South is the numeric high bidder; accepted numeric bid records store preferred trump/Tarneeb suit alongside the bid value before the final summary appears. | PRD-016, NFR-004 |
| Bidding turn order | First bid turn starts to the dealer's right and advances counterclockwise. | PRD-016, NFR-003 |
| Simulated bid recommendation | Simulated turns use deterministic hand-strength recommendations, accept only numeric values higher than the current highest bid and passing the partner-raise service guard, otherwise display `Pass`, store preferred trump/Tarneeb suit plus confidence metadata on accepted numeric bid records, include the conservative regression fixtures listed in section 5.6, including shallow trump, short four-card trump, missing-ace, five-card ace-king-ten/ace-queen-ten/ace-king-jack/ace-king-queen/ace-king-queen-jack/ace-jack-ten/ace-ten/ace-low/king-queen, six-card ace-king-queen, six-card ace-king-queen-jack, six-card king-queen missing-ace no-9 including jack/ten texture with limited outside aces, seven-card near-commanding no-13, seven-card ace-queen, eight-card ace-queen-jack-ten, short-trump strong-outside honor cases, four-card ace-jack-ten-low no-open-seven, and partner-raise override cases, and apply partner-winning pass/raise rules. | PRD-016, PRD-017, NFR-003 |
| Bidding terminal rules | A bid of `13` ends bidding and sets others to `Pass`; bidding also ends when only the highest bidder remains non-pass or when all players pass before any numeric bid; terminal state drives `Bidding complete`, hides the South `Bid` button, fades the `Bidding` area out, then either displays the numeric high-bid summary or starts the all-pass automatic redeal. | PRD-016, PRD-018 |
| South bid presentation | South shows `--` until active, exposes legal bid chips plus `Pass`, keeps the South `Bid` button visible-disabled during in-progress non-South turns, enables it for active-turn `Pass` or legal numeric submissions, commits only when `Bid` is tapped, hides the button when bidding completes, and never shows an in-progress suit selector. | PRD-016 |
| Bid token boundary | Bidding panel, post-bidding summary, bid selector, South post-bidding Tarneeb suit selector, South `Bid`/`Set` buttons, pending value, current-highest value, final summary suit chip, bid fade/color presentation, and bidding-area fade expose semantic roles or token keys instead of concrete color values. | PRD-016, PRD-018, NFR-003, NFR-005 |
| Post-bidding summary | Summary derives `East-West` or `North-South`, high bid value, and Tarneeb suit symbol from the highest bidder's accepted bid record after the terminal fade completes and, for a South high bid, only after South taps `Set`; the final Tarneeb symbol appears in a compact white chip with black/red suit coloring, and all-pass terminal bidding keeps the summary hidden. | PRD-018, NFR-003 |
| All-pass automatic redeal | Four passes before any numeric bid abandon the hand, advance dealer counterclockwise, create and validate a fresh deal, log the new hands, and start a fresh bidding round initialized to `--`. | PRD-016, PRD-018, PRD-019 |
| Hand logging | Completed deals, including all-pass automatic redeals, log one readable 13-card hand entry for South, East, North, and West through a replaceable logging destination. | PRD-019, NFR-003 |
| Hidden hand presentation | Simulated hands expose hidden count/back presentation but no rank or suit values. | PRD-007 |
| Action labels | Visible/accessibility labels use `Deal` and `New Game`, and never `Deal Cards` or `New Deal`. | PRD-001, PRD-008, PRD-009, PRD-012, PRD-013 |

Shuffle tests should not depend on random output being different on every run.
Use a deterministic injected shuffler for exact chunk assignment tests.

### 10.2 UI Tests

UI tests should verify user-facing behavior and layout-critical elements.

| Scenario | Assertions | Requirements Covered |
| --- | --- | --- |
| Initial launch | App remains portrait; `طرنيب`, bottom `New Game` and `Deal`, four stations, central table, dealer badge, and very-centered squared undealt deck stack are visible; dealt hands, bidding area, and post-bidding summary are absent. | PRD-001, PRD-002, PRD-010, PRD-011, PRD-012, PRD-014, PRD-016, PRD-018 |
| Old labels absent | `Deal Cards` and `New Deal` are absent before and after deal. | PRD-012 |
| Central table geometry | Circular table is visible and its diameter is half the screen width within a defined test tolerance. | PRD-010 |
| Table title placement | `طرنيب` appears centered on the card table and not as a top page title. | PRD-001, PRD-010 |
| Undealt deck stack | Stack represents 52 hidden cards, sits at the very center of the card table, uses the tokenized squared-stack geometry, stays inside the table buffer, may obscure the title before deal, and reveals no ranks or suits. | PRD-010, PRD-014 |
| Station layout | North above, West left, South below, East right; stations read as rounded squares around the table; only the current dealer shows the circular badge. | PRD-002, PRD-011, PRD-014 |
| Deal action | Tapping `Deal` keeps South card faces hidden while stacks are dealt, keeps South's received stack visible as fanned backs if it arrives before the fourth movement, removes the undealt deck stack after the fourth movement, reveals South with 13 backs and a 1.5-second left-to-right flip, keeps station outlines default, keeps the current dealer badge visible, then displays `Deal complete` and shows the `Bidding` area. | PRD-005, PRD-006, PRD-008, PRD-010, PRD-014, PRD-016 |
| Deal animation | After tapping `Deal`, a transient 13-card hidden stack appears from the table center, exposes dealer-relative counterclockwise target order metadata, keeps South ranks/suits hidden until all hands are dealt, keeps South's received stack visible as fanned backs when applicable, then resolves through the 1.5-second South backs/flip reveal to the completed deal state. | PRD-005, PRD-015 |
| South expansion | After all hands are dealt, South station expands below the card table with 13 backs, flips those cards face-up left-to-right over 1.5 seconds, and does not cover the bottom control area. | PRD-006, PRD-011, PRD-012 |
| Simulated hands | West, North, and East each show or represent 13 hidden card backs; ranks and suits are absent for those seats. | PRD-007 |
| Status placement | `Deal complete` appears above the bottom control row only after the South reveal flip completes, then changes to `Bidding complete` after terminal bidding state. | PRD-008, PRD-012, PRD-016 |
| Bidding area | After the South reveal flip completes, a bordered `Bidding` area appears under South, contains South/East/North/West, begins with `--` values, and does not overlap South cards or bottom controls. | PRD-016, PRD-011 |
| South bid selector/button | South bid chips appear only on South's turn; no Tarneeb suit selector appears during in-progress bidding; the South `Bid` button is visible-disabled during in-progress non-South turns, enabled for active-turn `Pass` or legal numeric submissions, commits the selected value when tapped, and disappears after bidding completes. | PRD-016 |
| Simulated bid values | East, North, and West resolve non-interactive values from hand-strength recommendations after at least one second, showing `Pass` when a numeric recommendation is not higher than the current high bid or fails the partner-raise service guard, and defaulting to `Pass` when partner is currently highest unless the stronger-trump raise rule is satisfied. | PRD-016, PRD-017 |
| Bid fade/color animation | Bid entries use a one-second fade/color transition when displayed values change, keep the current highest numeric bid yellow, and transition superseded previous high bids to white. | PRD-016 |
| Bidding area terminal fade | When bidding completes, the `Bidding` area fades out over one second and is removed from layout. | PRD-018 |
| Post-bidding summary | After the terminal fade, a numeric high bid displays the high-bidding team, high bid value, and `Tarneeb` with the preferred suit symbol stored on the accepted bid record; if South is the high bidder, the post-bidding suit-setting panel appears first with white suit chips and a `Set` button, then the final summary appears. All-pass completion shows no summary. | PRD-018 |
| All-pass automatic redeal | After four passes before any numeric bid, the summary remains hidden, the dealer badge advances counterclockwise, a fresh deal animation runs automatically, new hands are logged, and the fresh bidding table begins at `--`. | PRD-016, PRD-018, PRD-019 |
| Replacement deal | Tapping `Deal` after completion rotates dealer, replaces the previous completed deal, bid state, and post-bidding summary with another valid displayed deal initialized to `--`, and keeps old labels absent. | PRD-009, PRD-012, PRD-014, PRD-016, PRD-018 |
| New Game reset | Tapping `New Game` after completion clears dealt cards, bidding UI, and post-bidding summary, selects a dealer, hides status text, restores the squared undealt deck stack at the table center, shows the dealer badge, and leaves `Deal` ready for a new first deal. | PRD-013, PRD-014, PRD-016, PRD-018 |
| New Game on launch | Tapping `New Game` before dealing leaves the initial table unchanged and does not deal hands. | PRD-013 |
| Prohibited controls | Post-summary editable Trump/Tarneeb suit selector, play-card, trick, scoring, winning-bid trick flow, and game-over UI are absent; the only interactive suit control is South's post-bidding suit-setting panel when South is the numeric high bidder. | PRD-008, PRD-016, PRD-018 |
| Small screen | On the smallest supported simulator, labels, cards, hidden backs, bidding area or post-bidding summary, in-progress South `Bid` button, status label, and bottom controls remain usable. | PRD-011, PRD-016, PRD-018, NFR-005 |
| Responsiveness | Deal, replacement deal, and all-pass automatic redeal remain responsive while preserving the 1.5-second South reveal. | NFR-002 |

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
- Dealer rotation follows South, East, North, West for replacement deals and
  all-pass automatic redeals where state or test metadata exposes it.
- Player stations read as rounded squares surrounding the table: North top, West
  left, South bottom, East right.
- Hearts and Diamonds render through xCards face artwork with red suit marks and
  still expose the `suitWarm` role for presentation metadata.
- Clubs and Spades render through xCards face artwork with dark suit marks and
  still expose the `suitNeutral` role for presentation metadata.
- Table, text, station, dealer badge, card, action, bidding area,
  post-bidding summary, bid selector, South post-bidding Tarneeb suit selector,
  South `Bid`/`Set` buttons, bid fade/color animation, bidding-area fade
  animation, South reveal flip animation, title, and title-shadow styling matches
  token usage from
  `specs/007-mvp/design-tokens.md`.
- East, North, and West stations look compact compared with the expanded South
  station after the South reveal.
- South card faces stay hidden until all four hands have been dealt.
- If South receives cards before the full deal completes, the received South
  stack remains visible as fanned hidden backs until final South expansion.
- The South station expands below the card table with 13 backs after all hands
  are dealt, then flips those cards face-up left-to-right over 1.5 seconds.
- After the South reveal completes, exposed cards remain readable.
- Hidden card backs are the same base size as exposed player cards and are large
  enough to resemble cards.
- Exposed cards use xCards face assets, keep the asset-native card corners, avoid
  an additional rounded-rectangle face shell, and remain readable.
- The bordered `Bidding` area appears under the South station after the South
  reveal flip completes.
- The bid table shows South, East, North, and West.
- All bid entries initially show `--`.
- The South bid selector appears only when South's bidding turn is active.
- The South `Bid` button is visible while bidding is in progress, disabled
  outside South's turn, enabled only for active-turn `Pass` or legal numeric
  submissions, and hidden when bidding completes.
- The South bid selector includes only `Pass` and currently legal numeric bids
  through 13.
- No Tarneeb suit selector appears during the in-progress bidding round.
- If South wins the bidding numerically, the post-bidding suit-setting panel
  appears after the `Bidding` area fade, includes only `♠`, `♣`, `♥`, and `♦`,
  uses white suit chips with black spades/clubs and red hearts/diamonds, and
  enables the `Set` button only after South selects a suit.
- South numeric bid drafts can be submitted with `Bid` without selecting a
  Tarneeb suit during in-progress bidding.
- South `Pass` submissions do not require or store a Tarneeb suit.
- East, North, and West show non-interactive legal bid values after simulated
  turn resolution, with at least one second before each displayed update.
- Bid value changes visibly fade over one second, keep the current highest
  numeric bid yellow, and transition superseded previous high bids to white.
- When bidding completes, the `Bidding` area fades out over one second and is
  removed from layout.
- When bidding completes with a numeric high bid, the post-bidding summary shows
  `East-West` or `North-South`, the high bid value, and `Tarneeb` with one of
  `♠`, `♣`, `♥`, or `♦` from the high bidder's accepted bid record; the suit
  symbol appears in a compact white chip with black/red suit coloring and waits
  for South's post-bidding `Set` action when South is the high bidder.
- When all players pass before any numeric bid, no post-bidding summary appears,
  the dealer advances counterclockwise, a fresh deal starts automatically, and
  the next bidding table begins with all entries as `--`.
- The bidding area and post-bidding summary do not visually compete with the
  cards or bottom actions.
- `Deal complete` appears above the bottom control row after the South reveal
  completes until bidding completes, then `Bidding complete` appears in the same
  status position.
- The bottom control row shows `New Game` next to `Deal` before and after dealing.
- Tapping `New Game` after a deal restores the launch state with no dealt hands,
  no bidding area, no post-bidding summary, a dealer badge on the selected
  dealer, and the undealt deck stack visible in the very center of the card
  table.
- Completed deals, including all-pass automatic redeals, write one readable
  console log entry for each player's 13-card hand.
- Small-screen layout remains usable and avoids incoherent overlap.
- Deal, replacement-deal, and all-pass automatic-redeal interactions remain
  responsive.

### 10.4 Full Verification

Before marking MVP 007 done:

1. Run the full domain unit suite.
2. Run presentation-mapping unit tests for token usage, action labels, card size,
   table-title presentation, dealer state, deck stack state, bidding
   presentation, all-pass automatic redeal presentation, post-bidding summary
   presentation, hand logging, and reset presentation state.
3. Run the full UI suite on a primary portrait simulator.
4. Run layout-focused UI tests on the smallest supported simulator available to
   the project.
5. Perform manual visual QA for token-backed styling, title treatment,
   dealer badge treatment, very-centered squared undealt deck stack, card sizing,
   compact stations, South expansion, bidding area, post-bidding summary, South
   bid selector, South post-bidding Tarneeb suit selector, South `Bid`/`Set` button, bottom
   control, and portrait behavior.

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
| PRD-008 Deal Completion State | Dealt screen, bidding area, bottom deal control, prohibited UI, state transitions. |
| PRD-009 Replacement Deal | Replacement-deal design, edge cases, tests. |
| PRD-010 Central Card Table | Circular table view, table-title presentation, undealt deck stack, geometry UI tests. |
| PRD-011 Station Layout and Visual Sizing | Station layout, shared card sizing, compact stations, South expansion, small-screen testing. |
| PRD-012 Bottom Controls | Bottom controls presentation, state transitions, action label tests. |
| PRD-013 New Game Reset | Bottom controls presentation, reset state transition, edge cases, unit/UI reset tests. |
| PRD-014 Dealer Selection and Rotation | Dealer selection abstraction, dealer badge presentation, very-centered squared deck stack placement, replacement rotation, all-pass automatic-redeal rotation, unit/UI dealer tests. |
| PRD-016 Bidding Round | Bid state model, bidding service, bidding presentation, bidding area UI, South bid selector/button, South post-bidding Tarneeb suit-setting panel, simulated recommendation resolution, all-pass automatic-redeal outcome, bid fade/color animation, terminal bidding-area fade, bid tests. |
| PRD-017 Automated Simulated Bidding | Automated bid evaluator, per-suit `expectedTricks` diagnostics, conservative `safeBidCeiling` selection, high-bid structural gates, conditional side-honor treatment, short-suit eligibility, regression fixtures as generalized evaluator examples, simulated recommendation flow, service-level one-trick partner-raise rejection, accepted bid preferred-suit/confidence storage, partner-context pass/raise rules, deterministic recommendation tests, and deterministic simulation reporting for bid distribution tuning. |
| PRD-018 Post-Bidding Summary | Post-bidding summary model, summary presentation, team/bid/Tarneeb symbol mapping, terminal bidding-area fade, all-pass no-summary automatic redeal behavior, reset/replacement clearing behavior, UI tests. |
| PRD-019 Deal Hand Console Logging | Deal hand logging, hand log sink, console-only diagnostic behavior, all-pass automatic redeal hand logging, replaceable logging destination tests. |
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
| Dealer badge token source | Requirements say the badge should match the Deal button color and use a white `D`; this design carries forward `color.dealerBadge.background` and `color.dealerBadge.text` in the MVP 007 token file. |
| Bidding area dimensions | Requirements specify a bordered area under South but do not define width, height, border stroke width, row layout, or exact spacing. |
| Bid table row order | Requirements require one value per player but do not define display order; this design uses South, East, North, West by default. |
| South draft default | Requirements do not specify the initial selected option when South's turn becomes active; default to `Pass` unless implementation chooses another legal draft value. |
| South Tarneeb suit control style | Requirements require South to choose a Tarneeb suit after bidding when South is the numeric high bidder but do not mandate picker, segmented control, or menu styling beyond the current chip direction; this design uses tokenized post-bidding suit selector semantics and keeps it visible only until South taps `Set`. |
| Simulated turn timing | Requirements specify at least one second before each simulated bid display update; exact easing or progress indication during that wait is not specified. |
| Bid fade/color timing | Requirements specify a one-second fade/color transition but do not define easing; use bid animation and current-highest value color tokens for the concrete implementation. |
| Bidding-area terminal fade easing | Requirements specify one second for hiding the bidding area but do not define easing; use the tokenized duration and a standard platform fade unless product specifies otherwise. |
| Post-bidding summary layout | Requirements define summary content but do not define exact row/column layout; this design uses tokenized compact summary styling under South. |
| Automated bid formula weights | Requirements define evaluator factors but do not specify exact point weights. Implementation should keep the evaluator deterministic and conservative by separating optimistic `expectedTricks` from `safeBidCeiling`, making high bids pass structural gates, treating side kings/queens as conditional support, allowing short-suit value only with enough trump control, and satisfying regression fixtures through generalized diagnostics rather than exact-hand overrides. |
| Partner-raise enforcement location | Requirements now require the bidding service to re-apply the partner-raise threshold for simulated bids, including override and stale recommendation paths; exact helper boundaries are implementation-specific as long as rejected one-trick partner raises resolve to `Pass` and store no preferred suit metadata. |
| Console hand log format | Requirements require readable rank/suit output but do not define exact punctuation or order; tests should assert seat labels and 13 readable cards per seat rather than a brittle full string. |
| Dealer affects assignment | Requirements do not specify whether dealer changes card assignment order; this design preserves the carried-forward chunk assignment order and treats dealer as indication/rotation only. |
| New Game while notStarted | Requirements say tapping `New Game` in the initial screen remains `notStarted`, but do not specify whether dealer should re-randomize. |
| Replacement and all-pass redeal dealer visibility | Replacement deals and all-pass automatic redeals use transient animation state; exact visual timing for the rotated dealer badge before the final replacement or automatic deal appears is not otherwise specified. |
| Dealer's right | Requirements do not define table-perspective handedness; this design interprets dealer's right as the next seat in the counterclockwise dealer rotation order. |
| Deal animation timing | Requirements define the South reveal total duration as 1.5 seconds but do not define easing, pause timing, or whether the center stack visibly decrements during each flight; use `animation.deal.*` tokens. |
| South interim fanned stack spread | Requirements say South's received stack should remain visible as slightly fanned backs before final reveal when South is dealt early, but do not define exact fan angle, overlap, or offset; match the hidden-back treatment used for dealt stations unless product specifies tighter geometry. |
| Station dimensions | Requirements specify rounded squares but do not define side length, corner radius, stroke width, padding, or compact size ratios. |
| South station shape after expansion | Requirements say stations are rounded squares and South expands for the post-deal reveal; they do not specify whether expanded South must remain square or become a rounded rectangle. |
| Table-title tracking value | Requirements provide a range, not a single required value. |
| Hidden hand stack spread | Requirements allow hidden hands to use compact overlap but do not define offset, overlap, or whether all backs must be individually visible. |
| Automated token verification | Requirements ask for visual distinction and token-backed values, but XCTest may not inspect rendered token output directly without additional test tooling. |
| Automated geometric verification | Requirements specify table/station relationships but do not provide exact coordinates, size ratios, or tolerances. |
| Dynamic Type and accessibility | Requirements limit accessibility beyond standard iOS controls, so custom VoiceOver wording, Dynamic Type scaling targets, and contrast ratios are not fully specified. |
| Error handling UX | Requirements keep error handling out of scope beyond preventing invalid completed states; no user-facing error screen is specified for internal validation failures. |
| Font fallback | Requirements specify `SF Arabic Rounded Bold` but do not specify an approved fallback if that font is unavailable on a target device. |
