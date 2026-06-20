# Tarneeb iOS MVP 008 Requirements

## 1. Purpose

Build an iOS application MVP for the card game Tarneeb that allows one human player to start a game by dealing cards and then enter a simple bidding round. The other three players are simulated seats. This MVP ends after a valid deal is completed, the bidding round resolves with a numeric high bid, the bidding area fades away, any required South Tarneeb suit selection is resolved, and a post-bidding summary displays the high-bidding player, bid value, and preferred Tarneeb suit symbol, while allowing the player to request a replacement deal or reset the screen to a launch state. If all four players pass before any numeric bid is accepted, the hand is abandoned and a new deal starts automatically with the dealer advanced counterclockwise to the previous dealer's right. If South wins the bidding with a numeric bid, South chooses the Tarneeb suit after the bidding area fades and before the final summary appears. Post-summary editable Trump/Tarneeb suit selection, trick play, scoring, multiplayer, persistence, and advanced gameplay AI beyond bidding personality are not included.

This MVP 008 revision carries forward the MVP 002 card readability and station sizing requirements, the MVP 003 portrait card-table changes, and the MVP 004 dealer selection, dealer indication, dealer-station squared undealt deck placement, counterclockwise dealer rotation, and sequential deal animation. It adds a simplified Tarneeb bidding round after the deal, including player stations that act as information surfaces for each seat's current bid/pass state, a bordered `Bidding` action area under the South player station, sequential counterclockwise bidding, a South player bid-chip selector when it is South's turn, a South `Bid` button that remains visible during in-progress bidding and is disabled unless it is South's turn with a valid submission, a post-bidding South Tarneeb suit-setting panel with suit chips and a `Set` button only when South has the numeric high bid, automated simulated bid choices based on each simulated player's dealt hand, the current bidding context, and Phase 3 personality adjustments applied to the normal hand-strength estimate, delayed South-card reveal so South's card faces remain hidden until all hands are dealt, South's received stack remains visible as fanned card backs until reveal time, and South's cards then flip face-up left-to-right over 1.5 seconds using xCards face artwork with native card corners and complete scale variants, a one-second fade from the bidding area to either a post-bidding summary for numeric high bids, a South suit-setting panel when South's high bid still needs a suit, or an automatic redeal for all-pass bidding rounds, and console logging of each player's hand after each completed deal.

## 2. Source Rules

This MVP is based on the Tarneeb rules published by Jawaker:

- Tarneeb is a four-player partnership card game.
- Players sit across from each other, forming two teams.
- The game uses a standard 52-card deck with no jokers.
- Play proceeds counterclockwise.
- Each player is dealt 13 cards.
- After the deal, players bid using values from 7 through 13 tricks or pass.
- The highest valid bid would normally determine the bidder who chooses the Tarneeb suit.
- In this MVP, bidding starts with the player to the dealer's right and proceeds counterclockwise.
- In the common version described by the local rules, once a player passes they cannot reenter bidding for that hand.
- Good bidding begins with hand evaluation: high cards, long suits, side-suit winners, likely trump strength, partner bids, and conservative risk management.
- In this MVP, simulated numeric bids store an automated preferred Tarneeb suit when they are accepted. If South has the numeric high bid, South chooses the Tarneeb suit in a short post-bidding setting step before the final non-interactive Tarneeb summary is displayed.

Reference: https://blog.jawaker.com/en/tarneeb-rules-en/

## 3. Revision Inputs

### 3.1 MVP 002 Requirements Carried Forward

- Rank and suit for Hearts and Diamonds must be red.
- Clubs and Spades must use black or another high-contrast dark color that is clearly distinct from red.
- Player stations must preserve the four-seat relationship: North at the top, West on the left, South at the bottom, and East on the right.
- East, North, and West player stations must be compact and only large enough to contain the player label and hidden card array.
- Exposed cards must mimic standard playing cards, be large enough to read, and fit comfortably within the player station area.
- Hidden cards must use the same base size and aspect ratio as exposed cards.

### 3.2 MVP 003 Product Feedback Carried Forward

- The large title at the top is in the wrong place.
- Player stations should be square and surround a table.
- Deal and replacement-deal actions should use `Deal`, not `New Deal` or `Deal Cards`.
- The `Deal` button should be at the very bottom, with the `Deal complete` label above it.
- A separate `New Game` button should sit next to `Deal` and reset the whole game to a launch state.

### 3.3 MVP 003 Requirement Changes Carried Forward

- The app should be locked in portrait orientation.
- A circle should represent a card table in the center of the screen.
- The card table diameter should be half the screen width.
- Player stations should be rounded squares surrounding the card table.
- When cards are dealt, South's received 13-card stack should remain visible as a slightly fanned stack of card backs if it arrives before the full deal is complete; the South station should expand below the card table only after all four hands have been dealt, first displaying 13 card backs and then flipping them face-up left-to-right over 1.5 seconds.
- When the game begins, the deck should be represented as a squared stack of 52 hidden cards inside the current dealer's player station.
- When the cards are dealt, the undealt deck stack should disappear after the fourth 13-card stack has left the dealer station.
- The Arabic title `طرنيب` should be centered on the card table; before the deal, it may be visually obscured by the initial deck stack.
- The `طرنيب` title should use the tokenized table-title style defined in `design-tokens.md`, including the specified Arabic rounded font, 26pt size, tracking range, text color/opacity, and subtle shadow.
- Initial and replacement deal actions should both be labeled `Deal`.
- The `Deal` button should be at the very bottom of the screen.
- The `Deal complete` label should appear above the bottom control row after a completed deal.
- The `New Game` button should appear next to `Deal` at the bottom of the screen and restore the app to the same not-started state shown at launch.

### 3.4 MVP 004 Requirement Changes Integrated

- For a new game, one of the four players should be selected as the dealer.
- New-game dealer selection should be random.
- Before the deal, the undealt 52-card deck should always be displayed inside the current dealer's player station.
- The undealt deck should have a squared appearance before the deal.
- The undealt deck should remain inside the dealer station and maintain an appropriate buffer from the station edge.
- The selected dealer should be indicated before bidding by a small `D` pill beside the player name using the same blue color as the `Deal` button.
- The dealer indicator must not overlay or obscure the player name.
- Once bidding starts, the `D` pill may disappear because dealer identity remains available through game state/test metadata and does not affect other MVP 008 gameplay.
- During active bidding, the current bidder's active outline should use the active station outline token while dealer state remains testable through metadata.
- Within a game, the dealer should rotate counterclockwise between deals.
- The counterclockwise dealer rotation order should be South, East, North, West, then back to South.

### 3.5 MVP 004 Deal Animation Requirement Change

- When `Deal` is pressed, a 13-card hidden stack should move from the current dealer's player station to the player on the dealer's right.
- After a 13-card stack arrives at West, North, or East, that simulated player station should animate to its final dealt size and show the final enclosed 13-card hidden-card display for that station.
- If South receives a 13-card stack before all four hands have been dealt, South's card ranks and suits should remain hidden, but the received stack should remain visible as a slightly fanned stack of card backs like the other dealt stations.
- The deal animation should continue counterclockwise around the table until all four players have received 13 cards.
- When all 52 cards have been dealt, the dealer-station source deck stack should be gone, South's station should expand to hold 13 card backs, and South's cards should flip face-up from left to right over 1.5 seconds.
- The completed deal state should be shown only after the South reveal flip finishes.

### 3.6 MVP 008 Bidding Requirement Changes

- After the cards are dealt, a bidding round should be shown based on Tarneeb bid values.
- The bidding UI should appear after the completed deal state is reached.
- A bordered area should appear under the South player station after the deal.
- The bordered area should be labeled `Bidding`.
- Each player station should show that seat's current bid value or `Pass` as a compact information-surface chip after the deal.
- Each station bid value should begin as `--`.
- Bidding should start with the player to the dealer's right and proceed counterclockwise around the table.
- For simulated turns, the app should generate an automated bid recommendation from the simulated player's hand and the current bidding context.
- A simulated numeric recommendation should be set only if it is larger than the previous highest numeric bid; otherwise that simulated player should be set to `Pass`.
- If a player has already selected `Pass`, that player should not be eligible to bid again during the same bidding round.
- Each simulated player bid update should take at least one second before the displayed value changes.
- Phase 2 bidding state should store each bidder's preferred trump/Tarneeb suit alongside that bidder's resolved bid when the bidder makes a numeric bid.
- `Pass` and pending `--` states should not store a preferred trump/Tarneeb suit. South's in-progress bid selection does not show or store a preferred suit. If South becomes the numeric high bidder, South's accepted bid may temporarily lack a preferred suit until South completes the post-bidding suit-setting step.
- If a player bids `13`, all other players should be set to `Pass` and the bidding round should end.
- Bidding should continue until every player except the current highest bidder has `Pass` for their selection.
- If all four players select `Pass` before any numeric bid is accepted, the bidding round should end without a post-bidding summary and a new deal should start automatically with the dealer advanced to the player on the previous dealer's right.
- While bidding is in progress, the South `Bid` button should always be visible in the `Bidding` area, positioned below the South player station bid value and any active South bid chips.
- The South `Bid` button should be disabled unless it is South's turn and South has a valid submission.
- The `Bidding` area should extend vertically as necessary to contain the South `Bid` button and active bid chips without overlap.
- When it is South's turn to bid, South's station bid value should remain `--` until submitted and a bid-chip selector should appear in the `Bidding` action area with `Pass` and the currently legal numeric values through `13`; the current legal minimum is `7` when no numeric bid exists, otherwise one more than the current highest numeric bid.
- The in-progress `Bidding` area should not show a Tarneeb suit selector. South selects only a bid value while bidding is active.
- If South selects `Pass`, no South Tarneeb suit should be stored for that submission.
- If South selects a legal numeric bid, the South `Bid` button should submit that numeric bid without requiring a suit during the in-progress bidding round.
- When South selects a bid value and taps `Bid`, the bid-chip selector should disappear, South's station bid value should be replaced by the selected bid value, and the South `Bid` button should return to its disabled state unless bidding returns to South.
- If South is the numeric high bidder when bidding completes, the app should show a post-bidding South Tarneeb suit-setting panel after the `Bidding` area fades out and before the final summary appears.
- The post-bidding South Tarneeb suit-setting panel should show the high-bidding player, bid value, a `Tarneeb` label, suit chips for `♠`, `♣`, `♥`, and `♦`, and a button labeled `Set`.
- The post-bidding `Set` button should be disabled until South selects a suit. When South selects a suit and taps `Set`, the selected suit should be stored alongside South's accepted bid and the final post-bidding summary should appear.
- Bid value changes should use a one-second fade and color transition.
- The current highest numeric bid value should remain displayed in the same yellow used for the `New Game` button.
- If a higher numeric bid is accepted, the previous highest numeric bid value should transition from yellow to white while the new highest numeric bid remains yellow.
- `Pass` values and numeric values that are no longer the current highest bid should display in white after any transition completes.
- When the bidding round is complete, the status label above the bottom control row should update from `Deal complete` to `Bidding complete`.
- When the bidding round is complete, the `Bidding` area should fade out over one second and then disappear.
- When the bidding round is complete with a numeric high bid, a post-bidding summary should appear after the fade-out completes.
- The post-bidding summary should show the actual high-bidding player as `South`, `East`, `North`, or `West`, the high bid value, and a `Tarneeb` label containing the symbol for the high bidder's preferred suit. The suit symbol should display in a compact white chip, using black for Spades/Clubs and red for Hearts/Diamonds.
- The South `Bid` button should disappear with the `Bidding` area when bidding completes.
- After every completed deal, the app should log each player's full 13-card hand to the console for debugging.
- This MVP requires basic card-strength-based bid recommendations for simulated players, post-bidding South Tarneeb suit setting only when South wins the bidding, and a displayed preferred Tarneeb suit summary after bidding, but does not require changing the Tarneeb suit after the final summary, trick play, scoring, learning-based AI, opponent modeling, or Monte Carlo-style search.

### 3.7 Phase 2 Bid Suit Storage Requirement

- Phase 2 extends bidding state so every accepted numeric bid is stored as a bid record containing the bidder seat, bid number, and preferred trump/Tarneeb suit.
- The preferred trump/Tarneeb suit should be stored for simulated players using the same hand-evaluation approach already used to produce automated bid recommendations.
- The preferred trump/Tarneeb suit should be stored for South from South's explicit post-bidding suit selection when South is the numeric high bidder.
- `Pass` and pending `--` bid states must not carry a preferred trump/Tarneeb suit. South's accepted numeric high bid may remain without a preferred suit only during the short post-bidding suit-setting step.
- The post-bidding summary must read the high bidder's stored preferred trump/Tarneeb suit from the bid record or recommendation metadata after any required South suit-setting step has completed.

### 3.8 MVP 008 Design Improvement Requirements

- Player stations should show only the seat label; team names should be reserved for bidding and contract result surfaces.
- Dealer indication must use a small blue `D` pill beside the player name before bidding starts and must not use an overlaid badge or station-level dealer ring. During active bidding only, the current bidder's player station may use the active station outline token and a small active-turn indicator to make the turn easy to spot.
- The circular card table should have subtle tokenized felt depth, such as an inner ring or center surface treatment, while preserving the required half-screen table diameter, centered title, and dealer-station deck placement.
- Player stations should act as information surfaces during bidding, showing the seat label, active-turn emphasis when applicable, and a compact bid/pass chip for that seat; the pre-bidding dealer pill may disappear once bidding starts.
- The `Bidding` area should show the current bidding turn in a compact status indicator and avoid duplicating the four-player bid list that is already visible on the stations.
- The South in-progress bid controls should sit in a contained action tray under the current-turn indicator, with all bid chips fitting on one compact line on supported screens and the existing `Bid` button state behavior preserved.
- The post-bidding South suit-setting panel should read as a single `Contract` result surface, and the final post-bidding summary should fit on one line in the format `Contract [High Bidder]: [Bid value] Tarneeb: [suit]` without adding new gameplay controls, with `Contract` aligned left, `[High Bidder]: [Bid value]` centered, and `Tarneeb: [suit]` aligned right.
- The bottom status/control area should visually separate itself from the felt surface and present `Deal complete` or `Bidding complete` as a compact status pill above the `New Game` and `Deal` actions.

## 4. MVP Scope

### In Scope

- Launch an iOS app locked to portrait orientation.
- Show a start screen for a single human player.
- Display a circular card table centered on the screen with a diameter equal to half the screen width.
- Display the Arabic title `طرنيب` centered on the card table.
- Randomly select one of the four players as dealer when a new game begins.
- Display a squared stack of 52 hidden cards inside the current dealer's player station before a deal completes.
- Keep the undealt deck stack inside the dealer station with an appropriate buffer from the station edge.
- Animate the deal in four 13-card stack movements from the dealer station, starting with the player on the dealer's right and continuing counterclockwise around the table.
- Create four player seats:
  - South: Human player
  - West: Simulated player
  - North: Simulated player
  - East: Simulated player
- Display player stations as rounded squares surrounding the card table:
  - North above the table
  - West left of the table
  - South below the table
  - East right of the table
- Display only the seat label in each player station; do not display the partnership/team name in the station.
- Highlight only the active bidding seat during bidding with the active station outline token and a small active-turn indicator; do not use the station outline to indicate the dealer.
- Create two partnerships:
  - Team A: South + North
  - Team B: East + West
- Create a standard 52-card deck excluding jokers.
- Shuffle the deck.
- Deal 13 cards to each of the four players in 13-card chunks.
- Reveal simulated stations as final 13-card hidden-card displays after their animated 13-card stacks arrive.
- Keep the human player's card ranks and suits hidden until all four hands have been dealt.
- If South receives a 13-card stack before the full deal completes, keep the received South stack visible as a slightly fanned stack of card backs until the final South expansion and reveal begins.
- After all four hands have been dealt, expand the South station below the card table to display 13 card backs, then flip them face-up from left to right over 1.5 seconds to reveal the human player's 13-card hand.
- Display the human player's revealed 13-card hand only after the South flip animation completes.
- Display a bordered `Bidding` area under the South player station after the deal.
- Display one compact bid/pass chip in each player station for South, East, North, and West after the deal.
- Display the current bidding turn in a compact `Bidding` area status indicator.
- Render station bid chips with tokenized emphasis for pending, resolved, and current highest bid.
- Initialize all station bid values to `--`.
- Run bidding in counterclockwise order starting with the player to the dealer's right.
- Generate simulated player bid recommendations from hand strength and bidding context, accepting only numeric recommendations that exceed the current highest numeric bid and converting lower or equal recommendations to `Pass`.
- Delay each simulated player bid update for at least one second before applying the displayed value.
- Store each accepted numeric bid's preferred trump/Tarneeb suit alongside that bidder's resolved bid value, and retain confidence score as internal metadata so the terminal summary can display the high bidder's preferred suit.
- Allow the South player to choose from `Pass` and the currently legal numeric bids through `13` using bid chips when it is South's turn.
- Keep South's bid chips and `Bid` button in a contained action tray that can wrap bid chips without horizontal overflow.
- If South becomes the numeric high bidder, allow the South player to choose a Tarneeb suit from `♠`, `♣`, `♥`, and `♦` in a post-bidding suit-setting panel before the final summary appears.
- Store South's explicitly selected Tarneeb suit alongside South's numeric bid value when South taps `Set` in the post-bidding suit-setting panel.
- Display the South `Bid` button at all times while bidding is in progress.
- Position the South `Bid` button below the South player bid value, extending the `Bidding` area vertically as necessary.
- Enable the South `Bid` button only while it is South's turn with a valid selected bid value; show it disabled otherwise.
- Hide the South `Bid` button completely when bidding is complete.
- Hide the full `Bidding` area with a one-second fade transition when bidding is complete.
- Display a compact `Contract` post-bidding summary after the `Bidding` area fade completes and any required South suit-setting step is complete, grouping the high-bidding player, high bid value, and `Tarneeb` suit symbol when a numeric high bid exists.
- Replace the South bid-chip selector with the selected bid value after the human player taps `Bid`.
- Animate bid value changes with a one-second fade and color transition.
- Keep the current highest numeric bid displayed in the same yellow used for the `New Game` button, and transition any superseded previous high bid from yellow to white when a higher bid is accepted.
- Display simulated players as having 13 hidden cards each after the deal.
- Remove the undealt 52-card deck stack after the deal.
- Display the dealer before bidding using a small blue `D` pill beside the dealer's player name.
- Keep player station outlines at the default station outline color for dealer indication.
- Hide the dealer `D` pill once bidding starts; keep dealer identity testable through station metadata until the next deal request advances the dealer.
- Rotate the dealer counterclockwise within a game using the order South, East, North, West.
- Show a status label above the bottom control row.
- Style the status label as a compact status pill separated from the table surface.
- Display `Deal complete` after the deal completes and before the bidding round is complete.
- Update the status label to `Bidding complete` when the bidding round is complete.
- Log every player's 13-card hand to the console after each completed deal.
- Use a bottom `Deal` action for both the first deal and replacement deals.
- Display a bottom `New Game` action next to `Deal`.
- Reset the app to a launch state when `New Game` is tapped.
- Prevent gameplay beyond the simplified post-deal bidding display.
- Display South card faces with imported xCards face artwork that shows red Hearts and Diamonds and dark Spades and Clubs.
- Provide every standard 52-card face asset in the app asset catalog with stable `card_face_<rank><suit>` names and `1x`, `2x`, and `3x` scale variants.
- Render face artwork directly, preserving the asset's native card corner shape without applying a separate rounded-rectangle card face, clip, or border over the image.
- Scale exposed face artwork with high-quality image interpolation so card ranks and suits remain sharp at the shared card display size.
- Keep East, North, and West stations compact while preserving readable labels and hidden card backs.
- Use the same readable standard-card base size for exposed cards and hidden cards.

### Out of Scope

- Changing the Tarneeb suit after the final post-bidding summary appears.
- Enforcing a complete sequential increasing auction.
- Playing tricks.
- Determining trick winners.
- Scoring.
- Ending a full game.
- Online multiplayer.
- Local multiplayer.
- User accounts.
- Saved games.
- Learning-based, opponent-modeling, Monte Carlo, or other advanced AI behavior beyond the basic simulated bidding evaluator.
- Animations beyond the specified 13-card stack deal sequence and bid value fade/color transitions.
- Sound effects.
- Landscape layout support.
- Accessibility beyond standard iOS controls for this MVP.
- Error handling beyond preventing invalid completed deal states and invalid bid values.
- Custom card art beyond the provided card back and imported standard xCards 52-card face artwork.

## 5. Product Requirements

### PRD-001: App Launch

As a human player, I want to open the app and see a clear way to start a new Tarneeb deal.

#### Acceptance Criteria

- Given the app is launched, when the initial screen appears, then the app title `طرنيب` is centered on the card table and the undealt deck appears in the dealer station without obscuring the title.
- Given the app is launched, when the initial screen appears, then the user sees a primary action labeled `Deal`.
- Given the app is launched, then no cards are dealt until the user taps `Deal`.
- Given the app is launched, then the app is locked in portrait orientation.
- Given the app is launched, when the initial screen appears, then the user sees a reset action labeled `New Game` next to `Deal`.
- Given the app is launched, when the initial screen appears, then exactly one player is selected as the dealer.
- Given the app is launched, when the initial screen appears, then the dealer is selected randomly from South, East, North, and West.

### PRD-002: Player Seats

As a human player, I want the table to contain four Tarneeb seats so the deal matches the real game structure. Player seats exist as empty seats before the first deal.

#### Acceptance Criteria

- Given the table is displayed, then exactly four player seats exist.
- Given the four seats exist, then they are labeled `South`, `West`, `North`, and `East`.
- Given the four seats exist, then `South` is assigned to the human player.
- Given the four seats exist, then `West`, `North`, and `East` are assigned to simulated players.
- Given the four seats exist, then `South` and `North` are partners.
- Given the four seats exist, then `East` and `West` are partners.
- Given the four seats are displayed, then each seat is represented by a rounded-square player station.

### PRD-003: Deck Creation

As a human player, I want the app to use a valid Tarneeb deck so the deal is correct.

#### Acceptance Criteria

- Given a new deal is started, then the app creates one standard 52-card deck.
- Given the deck is created, then it contains exactly four suits: spades, clubs, hearts, and diamonds.
- Given the deck is created, then each suit contains exactly thirteen ranks: 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K, A.
- Given the deck is created, then it contains no jokers.
- Given the deck is created, then every card is unique.

### PRD-004: Shuffle

As a human player, I want the cards shuffled before dealing so each deal is randomized. Use the standard Swift shuffle method.

#### Acceptance Criteria

- Given a new deal is started, then the deck is shuffled before cards are assigned to players.
- Given two separate deals are started, then the app should not intentionally preserve the same card order.
- Given the deck is shuffled, then the deck still contains exactly 52 unique cards.

### PRD-005: Deal Cards

As a human player, I want each player to receive 13 cards, in a 13-card chunk, so the Tarneeb deal is complete.

#### Acceptance Criteria

- Given the user taps `Deal`, when the deal completes, then each of the four players has exactly 13 cards.
- Given the user taps `Deal`, then the app animates four 13-card stack movements from the current dealer's station before the deal is complete.
- Given the deal animation begins, then the first 13-card stack moves to the player on the current dealer's right.
- Given each 13-card stack arrives at West, North, or East, then that simulated player station animates to its final dealt size and displays its enclosed 13-card hidden-card presentation.
- Given a 13-card stack arrives at South before all four hands have been dealt, then South's card ranks and suits remain hidden from the user, but the South station keeps that received stack visible as a slightly fanned stack of card backs.
- Given the first animated stack has arrived, then the next 13-card stack moves counterclockwise to the next station.
- Given the deal completes, then all 52 cards have been assigned to players.
- Given all 52 cards have been assigned, then South's station expands to hold 13 hidden card backs before any South rank or suit is visible.
- Given South's station has expanded with 13 hidden card backs, then the cards flip face-up from left to right over 1.5 seconds.
- Given the deal completes, then no card appears in more than one player's hand.
- Given the deal completes, then no cards remain undealt.
- Given the deal completes, then the app records the deal state as `Dealt`.
- Given the deal completes, then the undealt 52-card deck stack is no longer visible.
- Given the deal completes, then all player station outlines remain the default station outline color.
- Given the deal completes and bidding starts, then the dealer `D` pill is hidden while dealer identity remains available in station metadata until the next deal request advances the dealer.

### PRD-015: Deal Animation

As a human player, I want the deal to visibly travel around the table so the transition from undealt deck to four completed hands feels like a real Tarneeb deal.

#### Acceptance Criteria

- Given the current dealer is selected, when `Deal` is tapped, then the first animated 13-card stack starts at the dealer station and targets the player on the dealer's right.
- Given an animated stack has arrived at West, North, or East, then the target station animates to its final dealt size and shows its final 13-card hidden-card display.
- Given South is a target before the fourth stack has arrived, then South keeps the received 13-card stack visible as a slightly fanned stack of hidden backs and must not reveal card faces until every hand has been dealt.
- Given a station has received its animated stack, then the next 13-card stack starts from the dealer station and targets the next player counterclockwise.
- Given the fourth 13-card stack has arrived, then South's reveal animation begins by expanding the South station with 13 card backs, followed by a 1.5-second left-to-right flip to exposed card faces.
- Given the current dealer is South, then the animation target order is East, North, West, South.
- Given the current dealer is East, then the animation target order is North, West, South, East.
- Given the current dealer is North, then the animation target order is West, South, East, North.
- Given the current dealer is West, then the animation target order is South, East, North, West.
- Given the fourth 13-card stack arrives, then the dealer-station source deck stack is removed and the completed deal state is displayed only after South's left-to-right reveal flip completes.
- Given a deal animation is in progress, then overlapping `Deal` or `New Game` actions are prevented until the animation resolves.

### PRD-006: Human Hand Display

As a human player, I want to see my own cards after the deal and clearly distinguish card suits.

#### Acceptance Criteria

- Given the deal animation is in progress, then the South player's card ranks and suits are not visible until all four hands have been assigned.
- Given South has received its 13-card stack and other hands are still being dealt, then the South station displays a slightly fanned stack of card backs rather than disappearing or leaving the station empty.
- Given all four hands have been assigned, then the South station expands below the card table to display 13 hidden card backs before revealing the human hand.
- Given the South station has expanded with 13 card backs, then the South cards flip face-up from left to right over 1.5 seconds.
- Given the South flip animation completes, then the South player's 13 cards are visible to the user.
- Given the deal completes, then the South station remains expanded below the card table to display the revealed cards.
- Given the South hand is visible, then each card displays its suit and rank using the imported xCards face asset for that card.
- Given the South hand is visible, then each face asset is referenced by a stable name in the form `card_face_<rank><suit>`, where Ten uses `T` and suits use `C`, `D`, `H`, and `S`.
- Given the app asset catalog is inspected, then every standard 52-card face asset has `1x`, `2x`, and `3x` variants and no joker face assets are included.
- Given the South hand is visible, then Hearts and Diamonds display rank and suit in red.
- Given the South hand is visible, then Clubs and Spades display rank and suit in black or another high-contrast dark color that is clearly distinct from red.
- Given the South hand is visible, then the face artwork preserves the asset's native card corner shape and is not wrapped in an additional rounded-rectangle card face, clip, or border.
- Given the South hand is visible, then the face artwork is scaled with high-quality interpolation so ranks, suits, and card edges do not appear blurry on supported device sizes.
- Given the South hand is visible, then the hand is sorted by suit in this order: Hearts, Clubs, Diamonds, Spades.
- Given cards share the same suit, then the cards are sorted by rank from 2 through Ace.
- Given the South hand is visible, then exposed cards use a standard playing-card aspect ratio and are large enough for rank and suit to be readable on supported device sizes.
- Given the South hand is visible, then exposed cards fit within the South player station without overlapping unrelated UI.
- Given the South hand is visible, then a subtle tokenized baseline rail or soft background distinguishes the human player's hand from the rest of the table without creating a separate card panel or making cards harder to read.
- Given the South hand is visible, then the user cannot select, play, discard, or otherwise act on a card in this MVP.

### PRD-007: Simulated Player Display

As a human player, I want simulated players' hands hidden so the table resembles a real card game.

#### Acceptance Criteria

- Given the deal completes, then West, North, and East each display 13 hidden card backs using the `card_back.png` image.
- Given the simulated player cards are displayed, then their ranks and suits are not visible to the human player.
- Given the simulated player cards are displayed, then the app does not expose controls for simulated player actions.
- Given hidden cards are displayed, then each hidden card uses the same base size and aspect ratio as the exposed South cards.
- Given a simulated player station is displayed, then it is compact and only large enough to contain the player label and hidden card array.
- Given hidden cards are displayed in a spread stack, then the spread must still represent 13 hidden cards without revealing rank or suit information.

### PRD-008: Deal Completion State

As a human player, I want to know when the deal has completed and then see the bidding round begin.

#### Acceptance Criteria

- Given all cards have been dealt and the South reveal flip completes, then the app displays `Deal complete`.
- Given `Deal complete` is displayed, then it appears above the bottom control row.
- Given the bidding round completes, then the status label above the bottom control row updates from `Deal complete` to `Bidding complete`.
- Given the deal is complete, then the post-deal `Bidding` area is shown under the South player station.
- Given South's reveal flip has not completed, then the post-deal `Bidding` area is not yet shown.
- Given the deal is complete, then no trick-play, scoring, or game-over controls are shown; the only Tarneeb-suit control allowed in this MVP is the post-bidding South suit-setting panel shown when South has the numeric high bid.
- Given the deal is complete, then the user may start a replacement deal using the bottom `Deal` action.
- Given the deal is complete, then the user may reset to a launch state using the bottom `New Game` action.

### PRD-009: Replacement Deal

As a human player, I want to start over with a fresh deal.

#### Acceptance Criteria

- Given a deal is complete, when the user taps `Deal`, then the previous hands are cleared.
- Given a deal is complete, when the user taps `Deal`, then the previous bid values are cleared before the replacement deal completes.
- Given a replacement deal starts within the same game, then the dealer advances counterclockwise from the previous dealer.
- Given a replacement deal starts, then a fresh 52-card deck is created or the previous full deck is reset.
- Given a replacement deal starts, then the deck is shuffled before dealing.
- Given the replacement deal completes, then each player again has exactly 13 cards.
- Given the replacement deal completes, then the `Bidding` area appears with all bid values initialized to `--` before the fresh bidding round proceeds.
- Given the replacement deal completes, then the portrait table layout, rounded-square stations, and card sizing requirements still apply.
- Given the replacement deal completes, then the available action remains labeled `Deal`.

### PRD-010: Central Card Table

As a human player, I want the screen to include a central card table so the seats are easy to understand.

#### Acceptance Criteria

- Given the table is displayed, then a circular card table appears in the center area of the screen.
- Given the circular card table is displayed, then its diameter is half the screen width.
- Given the circular card table is displayed, then its center area reserves four subtle seat-matched target slots for future trick-play cards.
- Given the center target slots are displayed, then they are non-interactive in MVP 008 and expose tokenized station-to-center played-card flight metadata for future trick-play animation.
- Given the initial table is displayed, then the Arabic title `طرنيب` appears centered on the card table.
- Given the initial deck stack is displayed, then its center point aligns with the center point of the circular card table within layout tolerance.
- Given the initial deck stack is displayed, then it remains inside the circular card table with an appropriate buffer from the table edge.
- Given the initial table is displayed, then a squared stack of 52 hidden cards appears inside the current dealer's player station.
- Given the initial deck stack is displayed with the `طرنيب` title, then the deck may visually overlap or obscure the title before the deal.
- Given the initial deck stack is displayed, then it does not reveal any card ranks or suits.
- Given the deal completes, then the undealt deck stack disappears.

### PRD-011: Station Layout and Visual Sizing

As a human player, I want the player stations to surround the card table so the seats resemble a four-player card table.

#### Acceptance Criteria

- Given the table is displayed, then player stations surround the circular card table.
- Given the table is displayed, then North is above the table, West is left of the table, South is below the table, and East is right of the table.
- Given the table is displayed, then South and North appear opposite each other as partners.
- Given the table is displayed, then East and West appear opposite each other as partners.
- Given the table is displayed before a deal, then all player stations are rounded squares.
- Given the table is displayed after a deal, then the South station expands below the card table to fit the revealed human hand.
- Given the table is displayed after a deal, then a bordered `Bidding` area appears under the expanded South station without covering the South hand or bottom controls.
- Given the table is displayed after a deal, then East, North, and West stations remain visually compact when screen space allows.
- Given the table is displayed, then required labels, cards, message text, and bottom controls remain usable and do not overlap each other.
- Given the table is displayed on a small supported simulator, then all four player stations, the status label, and the available bottom controls remain usable.

### PRD-012: Bottom Controls

As a human player, I want the deal and reset actions to remain easy to reach and consistently named.

#### Acceptance Criteria

- Given the initial screen is displayed, then the `Deal` button appears at the very bottom of the screen.
- Given the deal completes, then the `Deal` button remains at the very bottom of the screen.
- Given the deal completes, then the `Deal complete` label appears above the bottom control row.
- Given the status label is visible, then it is presented as a compact pill separated from the felt surface instead of a loose text label.
- Given the bidding round completes, then the same status label above the bottom control row displays `Bidding complete`.
- Given any MVP screen is displayed, then no action is labeled `Deal Cards`.
- Given any MVP screen is displayed, then no action is labeled `New Deal`.
- Given the initial screen is displayed, then the `New Game` button appears next to `Deal` in the bottom control row.
- Given the deal completes, then the `New Game` button remains next to `Deal` in the bottom control row.
- Given any MVP screen is displayed, then the reset action is labeled `New Game`, not `New Deal`.

### PRD-013: New Game Reset

As a human player, I want to reset the table to a new launch state without immediately dealing.

#### Acceptance Criteria

- Given the app is in the dealt state, when the user taps `New Game`, then the game phase returns to `notStarted`.
- Given the app resets to `notStarted`, then all player hands are cleared.
- Given the app resets to `notStarted`, then the same four seats remain visible as South, West, North, and East.
- Given the app resets to `notStarted`, then a dealer is selected for the new game.
- Given the app resets to `notStarted`, then the squared 52-card undealt deck stack is visible again inside the selected dealer's player station.
- Given the app resets to `notStarted`, then the South visible cards and simulated hidden hands are no longer displayed.
- Given the app resets to `notStarted`, then the `Bidding` area and all bid values are no longer displayed.
- Given the app resets to `notStarted`, then neither `Deal complete` nor `Bidding complete` is displayed.
- Given the initial screen is displayed, when the user taps `New Game`, then the screen remains in `notStarted` and no deal starts.

### PRD-014: Dealer Selection and Rotation

As a human player, I want to see which player is dealing so the table state resembles a real Tarneeb game.

#### Acceptance Criteria

- Given a new game begins, then exactly one of South, East, North, and West is selected as dealer.
- Given a new game begins, then the dealer selection is random.
- Given a dealer is selected before a deal, then the undealt 52-card deck stack appears inside that dealer's player station.
- Given the undealt deck stack is displayed, then the stack remains inside the dealer station with an appropriate buffer from the station edge.
- Given the undealt deck stack is displayed before the deal, then it has a squared appearance.
- Given a dealer is selected, then the app displays a small `D` pill beside the dealer's player name before bidding starts.
- Given the dealer pill is displayed, then the pill uses the same blue color as the `Deal` button, uses white `D` text, and does not overlay the player name.
- Given a deal completes and bidding starts, then the dealer pill disappears while dealer identity remains testable through station metadata until the next deal request advances the dealer.
- Given the current dealer is also the active bidder, then the active bidding outline may temporarily take visual priority while dealer state remains testable.
- Given a replacement deal starts within the same game, then the dealer rotates counterclockwise from the previous dealer.
- Given the current dealer is South, then the next dealer is East.
- Given the current dealer is East, then the next dealer is North.
- Given the current dealer is North, then the next dealer is West.
- Given the current dealer is West, then the next dealer is South.

### PRD-016: Bidding Round

As a human player, I want to enter my bid after the deal and see automated simulated bids for the other players.

#### Acceptance Criteria

- Given the deal completes, then a bidding round is displayed.
- Given the bidding round is displayed, then a bordered area appears under the South player station.
- Given the bordered bidding area appears, then it is labeled `Bidding`.
- Given the `Bidding` area appears, then it contains a table with one entry each for South, East, North, and West.
- Given station bid chips first appear after the deal, then each player entry shows `--`.
- Given bidding starts, then the first bidding turn belongs to the player on the dealer's right.
- Given bidding is in progress, then turns proceed counterclockwise around the table.
- Given a simulated player takes a turn, then the app generates a bid recommendation from that player's hand and the current bidding context.
- Given a simulated player recommendation is `Pass`, then that player's bid value becomes `Pass`.
- Given a simulated player recommends a number larger than the current highest numeric bid, then that number becomes the player's bid value.
- Given a simulated player recommends a number equal to or lower than the current highest numeric bid, then that player's bid value becomes `Pass`.
- Given any player resolves a numeric bid, then that player's bid state stores the preferred trump/Tarneeb suit alongside the bid value.
- Given any player resolves `Pass` or remains pending as `--`, then that bid state stores no preferred trump/Tarneeb suit.
- Given South is shown as the active South selection, then South may have a draft Tarneeb suit selection, but no preferred suit is stored on South's resolved bid state until South commits a numeric bid.
- Given a simulated player bid value is ready to resolve, then at least one second passes before the displayed bid value changes.
- Given a player has already bid `Pass`, then that player cannot bid again during the same bidding round.
- Given the current highest bidder has not been outbid, then that player does not receive another bidding turn.
- Given any player bids `13`, then all other players' bid values become `Pass` and the bidding round ends.
- Given at least one player has a numeric bid, then bidding continues until every player except the current highest bidder has `Pass`.
- Given every player passes before any numeric bid is accepted, then the bidding round ends with no highest bidder and no post-bidding summary.
- Given every player passes before any numeric bid is accepted, then a new deal commences automatically after the terminal bidding transition.
- Given an all-pass bidding round starts a new deal automatically, then the dealer advances to the player on the previous dealer's right using the counterclockwise dealer rotation order.
- Given an all-pass automatic new deal completes, then the fresh bidding round starts with all bid values reset to `--`.
- Given bidding is in progress, then the South `Bid` button is always visible under the South player bid value.
- Given bidding is in progress and it is not South's turn to bid, then the South `Bid` button is visible in a disabled state.
- Given it is South's turn to bid, then South's active bid controls are shown as bid chips and the South `Bid` button becomes available for valid South submissions.
- Given the South bid chips are shown, then they contain `Pass` plus numeric values from the current legal minimum through `13`.
- Given no numeric bid exists, then the South bid-chip numeric values start at `7`.
- Given a current highest numeric bid exists, then the South bid-chip numeric values start at one more than the current highest numeric bid.
- Given it is South's turn to bid, then the in-progress `Bidding` area does not show a South Tarneeb suit selector.
- Given South's selected bid value is numeric, then the South `Bid` button is enabled without requiring a Tarneeb suit during in-progress bidding.
- Given South's selected bid value is `Pass`, then the South `Bid` button is enabled without requiring a Tarneeb suit.
- Given the user selects `Pass` for South and taps `Bid`, then the South bid chips are replaced by `Pass`, no preferred trump/Tarneeb suit is stored for South, and the South `Bid` button becomes disabled unless bidding returns to South.
- Given the user selects a numeric South bid and taps `Bid`, then the South bid chips are replaced by the selected bid value, no preferred trump/Tarneeb suit is stored yet, and the South `Bid` button becomes disabled unless bidding returns to South.
- Given bidding completes with South as the numeric high bidder, then a post-bidding South Tarneeb suit-setting panel appears after the `Bidding` area fade-out completes.
- Given the post-bidding South Tarneeb suit-setting panel appears, then it displays the high-bidding player, bid value, a `Tarneeb` label, suit chips for spades, clubs, hearts, and diamonds, and a `Set` button.
- Given no post-bidding South Tarneeb suit has been selected, then the `Set` button is disabled.
- Given South selects a post-bidding Tarneeb suit, then the `Set` button is enabled.
- Given South taps `Set`, then the selected suit is stored alongside South's accepted bid state and the final post-bidding summary appears.
- Given the South `Bid` button is positioned under the South station bid value and any active bid chips, then the `Bidding` area extends vertically as necessary so the button does not overlap South hand, status label, or bottom controls.
- Given a player's bid value changes from `--`, the South active bid-chip selection, or any previous value, then the displayed value is applied with a one-second fade and color transition.
- Given a numeric bid is the current highest bid, then that bid value remains displayed in the same yellow used for the `New Game` button.
- Given a higher numeric bid is accepted, then the previous highest numeric bid transitions from yellow to white while the new highest numeric bid remains yellow.
- Given the bidding round reaches any terminal state, then the status label changes to `Bidding complete`.
- Given the bidding round reaches any terminal state, then the `Bidding` area begins a one-second fade-out transition.
- Given the `Bidding` area fade-out completes, then the full `Bidding` area and South `Bid` button disappear completely.
- Given the bidding round reaches a terminal state with a numeric highest bid, then a post-bidding summary appears after the `Bidding` area fade-out completes.
- Given the post-bidding summary appears, then it is laid out on one line in the format `Contract [High Bidder]: [Bid value] Tarneeb: [suit]`, with `Contract` aligned left, `[High Bidder]: [Bid value]` centered, and `Tarneeb: [suit]` aligned right.
- Given the post-bidding summary appears, then it displays the actual high-bidding player as `South`, `East`, `North`, or `West`.
- Given the post-bidding summary appears, then it displays the highest bid value.
- Given the post-bidding summary appears, then it displays a `Tarneeb` label with the high bidder's preferred suit symbol in a compact white chip.
- Given the preferred suit is spades, clubs, hearts, or diamonds, then the summary symbol is `♠`, `♣`, `♥`, or `♦` respectively.
- Given the preferred suit is spades or clubs, then the summary symbol is black.
- Given the preferred suit is hearts or diamonds, then the summary symbol is red.
- Given the bidding round reaches a terminal state with no numeric highest bid, then the `Bidding` area still fades out and disappears, no high-bidding player or Tarneeb suit summary is displayed, and an automatic new deal begins.
- Given a replacement deal completes, then the fresh bidding round starts with all bid values reset to `--`.
- Given South is not the numeric high bidder awaiting post-bidding suit selection, then no interactive Tarneeb suit selector is enabled.
- Given the final post-bidding summary is displayed, then the app does not show an interactive Tarneeb suit selector in this MVP.
- Given the bidding round is displayed, then the app does not start trick play in this MVP.

### PRD-017: Automated Simulated Bidding

As a human player, I want simulated players to make plausible Tarneeb bids based on their cards instead of random bid attempts.

#### Acceptance Criteria

- Given a simulated bidding turn begins, then the bid generator receives the simulated player's seat, full 13-card hand, partner seat, current highest bid value, current highest bidder, and all prior bid states.
- Given the bid generator evaluates a hand, then it considers each suit as a possible future Tarneeb suit.
- Given the bid generator evaluates a possible Tarneeb suit, then the evaluation considers high cards, candidate trump length, candidate trump high-card strength, side-suit winners, voids or singletons in non-trump suits, and a conservative risk penalty.
- Given the bid generator evaluates a possible Tarneeb suit, then the evaluation produces both `expectedTricks` and `safeBidCeiling` values for that suit.
- Given `expectedTricks` and `safeBidCeiling` differ, then the actual numeric bid recommendation must be based on `safeBidCeiling`; `expectedTricks` may be retained as diagnostic or personality-input metadata but must not by itself set the bid.
- Given the bid generator compares candidate Tarneeb suits, then it selects the bid from the suit with the best legal `safeBidCeiling`, using deterministic tie-breaking when candidates are otherwise equivalent.
- Given no candidate suit has a `safeBidCeiling` of at least 7, then the bid generator recommends `Pass`, even if a raw or optimistic `expectedTricks` estimate is 7 or higher.
- Given a candidate suit has a `safeBidCeiling` of at least 7, then any numeric recommendation must be between 7 and that `safeBidCeiling`, inclusive, before legal current-high-bid and partner-raise filtering is applied.
- Given the bid generator evaluates candidate Tarneeb suit length, then length must be treated as supporting evidence rather than enough evidence by itself for high bids.
- Given the bid generator evaluates side aces, then side aces may count as reliable outside winners, subject to risk and suit-distribution context.
- Given the bid generator evaluates side kings or queens, then those honors must be treated as conditional support rather than guaranteed tricks unless protected by stronger cards, length, or other context that makes them likely to stand.
- Given the bid generator evaluates voids or singletons, then short-suit value may increase the estimate only when the candidate Tarneeb suit has enough length and top control to use trump for ruffs without losing control.
- Given the bid generator would recommend 9 or higher, then the recommendation must pass a structural gate requiring stronger trump texture, multiple reliable outside winners, useful short-suit shape backed by trump control, or partnership context beyond suit length alone.
- Given the bid generator would recommend 10 or higher, then the recommendation must pass a stronger structural gate requiring real trump control such as ace-king support, multiple protected top trump honors, or equivalent compensating length plus reliable outside winners.
- Given the bid generator would recommend 11 or higher, then the recommendation must require strong independent trump control and multiple reliable supporting winners; ordinary side king/queen support or a singleton must not be enough.
- Given the bid generator would recommend 12 or 13, then the recommendation must require near-commanding trump control and exceptional support, such as extra trump length, multiple sure outside winners, or very low risk from missing top trump honors.
- Given the bid generator would recommend 13, then the recommendation must require a near-commanding candidate Tarneeb suit with at least eight trump cards; a seven-card suit must stay below 13 even with ace-king-queen-jack-ten texture and two outside aces.
- Given a candidate's optimistic `expectedTricks` comes mainly from trump length, side honors, or short-suit shape, then the `safeBidCeiling` must apply a conservative risk budget before the hand can cross a 9-, 10-, or 11-bid threshold.
- Given a six-card candidate Tarneeb suit is headed by ace-jack-ten but missing king and queen, then two outside aces or protected side honors alone should not raise the `safeBidCeiling` to 10 unless the hand has stronger protected trump texture, exceptional side certainty, or partnership context.
- Given a six-card candidate Tarneeb suit is headed by ace-king-queen but missing both jack and ten, with no outside aces, then ordinary side kings should not raise the `safeBidCeiling` to 10 or higher.
- Given a six-card candidate Tarneeb suit is headed by ace-king-queen-ten but missing jack, with only one outside ace and ordinary side queen/king support, then the `safeBidCeiling` should remain below 11 unless the hand has extra trump length, the trump jack, multiple outside aces, or exceptional partnership context.
- Given a seven-card candidate Tarneeb suit is headed by ace-king-queen-ten but missing jack, with no outside aces and no outside kings, then the `safeBidCeiling` should remain below 11 because trump length alone does not make an 11-trick commitment safe.
- Given a seven-card candidate Tarneeb suit is headed only by the ace with low remaining trump cards, and the hand has at most one outside ace, then the `safeBidCeiling` should remain below 9 unless the hand has stronger trump texture, multiple reliable outside winners, or partnership context.
- Given a seven-card candidate Tarneeb suit is headed by ace-jack but missing king, queen, and ten, with at most one outside ace, then the `safeBidCeiling` should remain below 9 unless the hand has protected king/queen trump texture, multiple reliable outside winners, or exceptional partnership context.
- Given a six-card candidate Tarneeb suit is missing the ace and has only king-queen top trump control, then the `safeBidCeiling` should remain below 9 when the hand has at most one outside ace; jack or ten texture and ordinary side king/queen support are not enough without the trump ace, extra trump length, multiple outside aces, stronger protected side winners, useful short-suit shape backed by enough trump control, or partnership context.
- Given a four-card candidate Tarneeb suit is headed by ace-king-queen-ten but missing jack, with at most one outside ace and only ordinary side honor support, then the `safeBidCeiling` should remain below 9 unless the hand has extra trump length, the trump jack, multiple outside aces, exceptional side certainty, or exceptional partnership context.
- Given the requirements include exact 13-card hand examples, then those examples are regression cases for the generalized `expectedTricks`/`safeBidCeiling` evaluator and high-bid gates; the implementation must not hard-code exact hands, player seats, or exact card lists as bidding overrides.
- Given a hand has a long candidate Tarneeb suit but no aces, no outside winners, and weak top control in the candidate suit, then the normal evaluator must not recommend a bid above 7.
- Given the normal evaluator receives `2♦ 4♦ 2♠ 3♠ 2♥ 8♠ Q♠ K♦ 10♦ 5♦ 7♣ 3♣ J♦` with no current highest bid, then the balanced/default recommendation must be `Pass` or at most `7`, not `8` or higher.
- Given a hand has a five-card candidate Tarneeb suit with ace support plus side winners, but lacks enough extra top trump control or partnership information to make a 10-trick commitment safe, then the normal evaluator should cap the recommendation below 10.
- Given the normal evaluator receives `7♥ 6♦ 8♦ 4♠ 10♠ A♠ J♠ 10♦ A♥ K♥ 4♣ Q♠ 5♥` with no current highest bid, then the balanced/default recommendation should be at most `9`, not `10` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by the ace but lacks king or queen support in that candidate suit, then the normal evaluator should treat the hand as uncertain and avoid recommending above 7 unless the hand has additional strong evidence such as multiple outside aces, stronger trump intermediates, or useful distribution.
- Given the normal evaluator receives `3♠ 6♥ 9♦ 2♣ 3♥ 2♠ J♦ 9♠ A♣ 2♦ 5♦ J♠ A♠` with no current highest bid, then the balanced/default recommendation should be `Pass` or at most `7`, not `8` or higher.
- Given a hand has a six-card candidate Tarneeb suit and would otherwise reach a 10-trick recommendation mostly from length, side winners, and short-suit value, then the normal evaluator should cap the recommendation below 10 unless the candidate suit has stronger 10-level trump control, such as ace-king support or all three top honors.
- Given the normal evaluator receives `K♣ A♦ 10♥ 10♠ 2♠ 8♣ 3♦ 6♦ Q♦ 2♦ 4♦ A♠ 4♠` with no current highest bid, then the balanced/default recommendation should be at most `9`, not `10` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-jack but missing king, queen, and ten support, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as multiple outside aces, stronger side-suit winners, enough protected trump texture, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `3♦ 10♠ 3♥ A♦ 4♦ J♦ 4♥ A♠ 6♥ 8♦ 9♦ K♠ 7♠` with no current highest bid, then the balanced/default recommendation should be at most `9`, not `10` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king but the remaining candidate trump cards are low, and the only clear outside winner is one ace, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as queen, jack, or ten trump texture, a second outside winner, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `3♦ Q♣ 5♠ 5♣ 3♥ 7♠ 4♠ A♣ 4♦ 10♥ 2♦ K♦ A♦` with no current highest bid, then the balanced/default recommendation should be at most `8`, not `9` or higher.
- Given a hand has exactly five cards in its candidate Tarneeb suit, then the normal evaluator should cap the recommendation below 10 unless the hand has at least three top trump controls, at least three reliable outside winners, or exceptional partnership context; two top trump controls plus two outside aces are not enough by themselves to justify a 10-level commitment.
- Given the normal evaluator receives `8♥ A♦ A♥ 4♦ 8♣ 2♦ 2♥ 3♥ K♥ J♠ A♠ 8♦ 10♠`, `Q♣ 4♦ Q♥ A♣ A♦ A♠ 10♦ 7♣ K♦ 9♥ 7♥ 9♦ 3♥`, or `K♣ 3♠ 9♣ J♦ 5♦ 6♠ 3♣ J♣ A♣ 8♥ A♠ A♥ 4♠` with no current highest bid, then the balanced/default recommendation should prefer the five-card candidate suit but be at most `9`, not `10` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by king-queen-ten but missing the ace, and the outside support is only one ace plus side kings, then the normal evaluator should avoid recommending `8` unless the hand has stronger supporting evidence such as multiple outside aces, extra trump length, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `2♣ K♦ Q♦ 10♦ K♠ 8♥ 3♦ 4♥ 7♦ 6♥ 10♣ K♣ A♠` with no current highest bid, then the balanced/default recommendation should be `Pass` or at most `7`, not `8` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king but the remaining candidate trump cards are low, and the hand has two outside aces, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as queen, jack, or ten trump texture, additional outside winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♣ A♠ K♠ 6♠ 10♣ 2♠ 10♦ A♥ 7♠ 5♥ 9♣ 4♠ A♣` with no current highest bid, then the balanced/default recommendation should be at most `10`, not `11` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-jack-ten but missing queen, with only one outside ace and one outside king, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as extra trump length, the trump queen, multiple outside aces, reliable side-suit winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `A♥ J♥ Q♦ A♠ 3♣ 8♠ 10♥ 8♦ 3♥ 10♦ 2♥ K♠ K♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `10`, not `11` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king, with queen and jack both absent and no reliable outside winners, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as queen or jack trump support, protected outside winners, multiple outside aces, exceptional short-suit shape, extra trump length, or partnership context.
- Given the normal evaluator receives `10♦ 7♠ A♦ Q♥ 3♦ 3♥ J♥ J♠ 2♦ 8♦ K♦ Q♣ 8♥`, `5♣ 4♣ A♣ 8♦ Q♠ 6♣ 7♣ K♣ 3♠ J♥ 7♦ 7♥ 4♠`, or `8♦ 7♥ 6♣ K♣ A♣ 2♥ J♦ 5♥ 10♣ 8♣ Q♠ 2♣ 5♠` with no current highest bid, then the balanced/default recommendation should prefer the six-card ace-king candidate suit but be at most `8`, not `9` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-ten but missing queen and jack, with only one outside ace, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as the trump queen or jack, multiple outside aces, reliable side-suit winners, useful short-suit shape, extra trump length, or partnership context.
- Given the normal evaluator receives `A♥ Q♥ K♦ 2♦ 3♠ 7♥ 6♣ J♣ 7♦ 8♦ 10♦ 10♣ A♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `9`, not `10` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-ten but missing queen and jack, with no outside aces and only side kings as support, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as queen or jack trump support, reliable outside aces, stronger side-suit winners, useful short-suit shape, extra trump length, or partnership context.
- Given the normal evaluator receives `4♦ K♠ 6♥ J♠ 10♦ K♦ A♦ K♣ 8♦ 8♣ 4♣ 8♠ 5♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `9`, not `10` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king-ten, even with multiple outside honors, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as longer trump, queen or jack trump support, multiple outside aces, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `9♠ 8♣ 10♥ 2♥ 8♠ J♣ 4♠ A♥ 4♣ K♥ K♣ A♣ K♦` with no current highest bid, then the balanced/default recommendation should be at most `9`, not `10` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king-jack, and the outside support is only one ace plus one king, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as extra trump length, queen or ten trump support, multiple outside aces, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `J♣ A♣ 5♦ J♦ 6♣ K♠ K♥ 9♥ 8♠ 8♦ 6♠ J♥ A♥` with no current highest bid, then the balanced/default recommendation should be at most `8`, not `9` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king-jack, even with two outside aces and side king/queen honors, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as extra trump length, queen or ten trump support, exceptional short-suit shape, or partnership context.
- Given the normal evaluator receives `A♥ A♦ K♠ 6♦ Q♥ J♣ Q♦ 4♠ 6♣ K♦ 10♥ A♣ K♣` with no current highest bid, then the balanced/default recommendation should prefer clubs but be at most `9`, not `10` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-queen-jack, and the outside support is only one ace plus one king, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as extra trump length, king or ten trump support, multiple outside aces, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `A♣ 5♦ K♠ 5♣ 4♥ Q♣ 2♥ J♥ A♥ 8♠ 7♣ 2♠ J♣` with no current highest bid, then the balanced/default recommendation should be at most `8`, not `9` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king with low remaining candidate trump cards, and the outside support is one ace plus side queens, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as extra trump length, queen, jack, or ten trump support, multiple outside aces, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `6♦ Q♥ 9♠ 8♠ 10♥ 6♠ A♠ 5♦ K♠ Q♣ 7♥ 8♣ A♣` with no current highest bid, then the balanced/default recommendation should be at most `8`, not `9` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king with low remaining candidate trump cards, even with two outside aces, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as queen, jack, or ten trump support, extra trump length, useful short-suit shape, additional reliable side winners, or partnership context.
- Given the normal evaluator receives `6♠ 5♥ 8♥ 9♠ 2♦ Q♥ J♣ A♦ 4♣ 4♦ A♠ A♥ K♦` with no current highest bid, then the balanced/default recommendation should be at most `8`, not `9` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-queen but missing king, jack, and ten, with no outside aces or kings and only ordinary outside queen or low-card support, then the normal evaluator should not open the bidding at `7` unless the hand has stronger supporting evidence such as extra trump length, stronger trump texture, multiple outside winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `9♥ 2♥ Q♠ 6♠ 8♦ Q♣ 4♥ 2♣ 8♣ 6♦ 5♥ A♠ 4♠` with no current highest bid, then the balanced/default recommendation should treat spades as the best candidate suit but recommend `Pass`, not `7` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-jack-ten but missing king and queen, with no outside aces, no void or singleton support, and only ordinary outside king or queen support, then the normal evaluator should not open the bidding at `7` unless the hand has stronger supporting evidence such as extra trump length, stronger top trump texture, outside ace support, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `7♥ J♣ K♠ Q♦ 7♠ 9♥ 7♦ 6♣ 10♣ A♣ 3♠ 6♠ 4♥` with no current highest bid, then the balanced/default recommendation should treat clubs as the best candidate suit but recommend `Pass`, not `7` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-jack-ten plus one low trump, with no outside aces, no outside kings, no void or singleton support, and only ordinary outside queen/jack support, then the normal evaluator should not open the bidding at `7` unless the hand has stronger supporting evidence such as extra trump length, stronger top trump texture, outside ace or king support, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `J♣ A♣ J♠ 5♥ Q♦ 8♥ 9♦ 2♦ 5♣ J♦ 5♠ 3♠ 10♣` with no current highest bid, then the balanced/default recommendation should treat clubs as the best candidate suit but recommend `Pass`, not `7` or higher.
- Given a hand's best candidate Tarneeb suits are no stronger than a three-card king-queen candidate missing ace and ten or a four-card ace-jack-low candidate missing king, queen, and ten, then two outside aces and one outside king should not justify an 8 bid by default; the normal evaluator should cap the recommendation below 8 unless the hand has stronger trump length, stronger top trump texture, additional reliable outside winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `7♥ J♦ Q♣ K♥ J♠ A♦ 6♠ 8♦ 5♣ 5♦ 8♠ A♠ Q♥` with no current highest bid, then the balanced/default recommendation should be `Pass` or at most `7`, not `8` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by a lone ace with low remaining candidate trump cards, and the hand has only one clear outside ace, then the normal evaluator should not open the bidding at `7` unless the hand has stronger supporting evidence such as king, queen, jack, or ten trump texture, multiple outside winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `5♥ 10♠ 8♠ 8♣ 6♠ 6♦ 8♦ J♠ A♥ A♣ 7♠ 7♣ 3♣` with no current highest bid, then the balanced/default recommendation should be `Pass`, not `7` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-queen-ten but has no outside aces, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as extra trump length, additional outside winners that are likely to stand, useful short-suit shape with enough trump depth, or partnership context.
- Given the normal evaluator receives `Q♣ 10♠ Q♦ 4♣ 5♣ K♠ J♣ A♠ 5♦ K♦ Q♠ 7♠ 7♣` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `9`, not `10` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-queen-jack but missing ten, with no outside aces, only one outside king, and one singleton as support, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as extra trump length, the trump ten, reliable outside winners, stronger short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♥ J♥ J♣ Q♦ 4♣ A♥ Q♠ K♥ 8♦ K♣ 2♥ 4♦ 9♣` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `9`, not `10` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-queen but missing both jack and ten, and the hand has no outside aces, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as extra trump length, reliable outside winners, useful short-suit shape with enough trump depth, or partnership context.
- Given the normal evaluator receives `7♠ 8♠ Q♦ 9♦ A♥ 2♦ 9♣ Q♥ K♥ 7♣ 2♥ 9♥ 5♣` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `8`, not `9` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-queen but missing both jack and ten, even with two outside aces, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as extra trump length, jack or ten trump support, additional reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♥ J♠ 2♦ Q♦ A♦ A♣ A♥ 9♦ 3♥ K♥ 7♦ Q♠ 9♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `10`, not `11` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-jack but missing both queen and ten, with only one outside ace and no void or singleton support, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as queen or ten trump texture, extra trump length, additional outside winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `J♠ 3♥ 6♠ J♥ 9♠ 8♦ 4♦ K♥ 9♣ 9♦ A♣ A♥ 4♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `8`, not `9` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-queen but missing both jack and ten, even with two outside aces and one outside king, then the normal evaluator should cap the recommendation below 12 unless the hand has stronger supporting evidence such as extra trump length, stronger trump texture, additional reliable outside winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `7♦ Q♦ 3♥ A♠ 5♣ K♣ K♦ 4♦ 6♠ 5♦ 10♣ A♦ A♣` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `11`, not `12` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-queen but missing both jack and ten, with no outside aces, no outside kings, and no void or singleton support, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as stronger trump texture, reliable outside winners, useful short-suit shape, extra trump length, or partnership context.
- Given the normal evaluator receives `J♠ Q♥ 3♦ 10♠ 3♥ A♦ 6♦ J♣ Q♦ K♦ Q♣ 2♦ 10♥` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `9`, not `10` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-queen but missing both jack and ten, with no outside aces and only one outside king plus void or singleton support, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as stronger trump texture, reliable outside aces, additional side winners, extra trump length, or partnership context.
- Given the normal evaluator receives `7♠ 10♠ 5♠ 8♦ K♣ A♦ 8♠ 2♦ 9♣ Q♦ K♦ 6♠ 5♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `10`, not `11` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-queen but missing both jack and ten, with no outside aces and only side kings as support, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as the trump jack or ten, reliable outside aces, stronger side-suit winners, useful short-suit shape, extra trump length, or partnership context.
- Given the normal evaluator receives `A♣ 5♥ 3♣ K♣ 10♥ Q♣ K♦ 7♣ K♠ 8♣ 4♥ 5♠ 10♠` with no current highest bid, then the balanced/default recommendation should prefer clubs but be at most `10`, not `11` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-jack but missing queen and ten, with no outside aces, no outside kings, and no void or singleton support, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as the trump queen or ten, reliable outside winners, useful short-suit shape, extra trump length, or partnership context.
- Given the normal evaluator receives `5♠ 4♦ J♠ Q♦ 8♠ K♠ 3♥ 3♣ 9♣ A♠ 4♠ 10♦ J♣` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `9`, not `10` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by king-queen but missing ace, jack, and ten, with no outside aces and only side kings/queens plus a void as support, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as the trump ace, stronger protected trump texture, reliable outside aces, additional side winners, extra trump length, or partnership context.
- Given the normal evaluator receives `9♥ 6♦ 6♠ K♠ 4♥ 10♠ 7♦ K♦ 7♥ Q♥ 3♥ Q♦ K♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `8`, not `9` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by king-queen but missing ace, jack, and ten, with one outside ace and one outside king, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as the trump ace, protected jack or ten support, multiple outside aces, stronger side-suit winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♣ 6♣ 2♣ 10♥ 3♥ A♠ 7♣ 8♣ K♥ 5♦ J♥ Q♠ Q♣` with no current highest bid, then the balanced/default recommendation should prefer clubs but be at most `8`, not `9` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by king-queen but missing ace, jack, and ten, with only one outside ace, one outside king, and one singleton as support, then the normal evaluator should cap the recommendation below 8 unless the hand has stronger supporting evidence such as extra trump length, stronger trump texture, multiple outside aces, more reliable side winners, useful short-suit shape with enough trump depth, or partnership context.
- Given the normal evaluator receives `10♥ K♠ Q♠ 7♠ K♦ 2♦ 2♠ 7♦ 6♣ 3♣ 5♦ A♣ Q♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be `Pass` or at most `7`, not `8` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-queen-ten but missing king and jack, even with three outside aces and one outside king, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as extra trump length, stronger trump texture, additional protected trump control, useful short-suit shape with enough trump depth, or partnership context.
- Given the normal evaluator receives `5♠ A♠ A♦ 4♦ 2♥ 10♦ A♥ A♣ 9♥ K♣ 7♣ Q♦ 2♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `10`, not `11` or higher.
- Given a hand has only a four-card candidate Tarneeb suit, even when headed by ace-king-ten or supported by ace-queen plus outside ace/king strength, then the normal evaluator should cap the recommendation below 9 unless the hand has stronger supporting evidence such as extra trump length, stronger trump texture, multiple outside aces, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `3♠ K♥ 3♦ 5♣ 8♥ A♣ 2♠ 9♣ 6♠ 10♥ 8♣ Q♣ A♥` with no current highest bid, then the balanced/default recommendation should be at most `8`, not `9` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king-jack-ten, with no outside aces and only ordinary outside king support, then the normal evaluator should cap the recommendation below 8 unless the hand has stronger supporting evidence such as extra trump length, multiple outside aces, stronger side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `10♣ 8♠ 5♠ 9♠ 3♥ J♣ K♦ A♣ J♥ 6♥ 4♦ J♦ K♣` with no current highest bid, then the balanced/default recommendation should prefer clubs but be `Pass` or at most `7`, not `8` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king with low remaining trump cards, no outside aces, and only ordinary outside king support, then the normal evaluator should cap the recommendation below 8 unless the hand has stronger supporting evidence such as extra trump length, stronger trump texture, multiple outside aces, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `7♠ K♣ 9♣ 3♦ 9♠ 2♥ 4♦ 6♥ Q♥ K♥ 10♣ K♦ A♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be `Pass` or at most `7`, not `8` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-jack-ten but missing king and queen, with no outside aces and only ordinary outside king or queen support, then the normal evaluator should recommend `Pass` unless the hand has stronger supporting evidence such as stronger trump texture, outside ace support, useful short-suit shape, extra trump length, or partnership context.
- Given the normal evaluator receives `A♦ 10♦ 2♣ Q♣ J♦ 9♥ Q♠ 4♥ 7♦ K♥ 9♦ 5♣ K♠` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be `Pass`, not `7` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-ten but missing king, queen, and jack, with no outside aces, no void or singleton support, and only ordinary outside king or jack support, then the normal evaluator should recommend `Pass` unless the hand has stronger supporting evidence such as stronger trump texture, outside ace support, useful short-suit shape, extra trump length, or partnership context.
- Given the normal evaluator receives `9♠ 6♥ 10♠ 8♥ 8♣ J♦ J♣ 7♦ K♣ K♦ 3♠ A♠ 7♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be `Pass`, not `7` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed only by the ace, with no king, queen, jack, or ten in that suit, then two outside aces and one outside king should not justify an 8 bid by default; the normal evaluator should cap the recommendation below 8 unless the hand has stronger trump texture, extra trump length, useful short-suit shape with enough trump control, or partnership context.
- Given the normal evaluator receives `A♣ 6♥ 5♥ 8♥ 3♠ 4♦ 3♣ 4♠ A♦ 6♦ A♥ 4♥ K♣` with no current highest bid, then the balanced/default recommendation should prefer hearts but be `Pass` or at most `7`, not `8` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-queen-ten but missing king and jack, with no outside aces or outside kings, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as stronger trump texture, reliable outside winners, useful short-suit shape with enough trump control, or partnership context.
- Given the normal evaluator receives `2♦ 5♠ Q♦ A♦ 8♦ 10♦ 6♠ 2♠ 10♥ 2♥ 3♦ 4♦ 9♥` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `10`, not `11` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-king but missing queen, jack, and ten, with no outside aces and only one outside king, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as queen, jack, or ten trump support, reliable outside aces, stronger side-suit winners, extra trump length, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `A♥ 10♦ 3♥ 6♥ 8♠ K♠ 2♥ 10♣ 8♦ K♥ 9♥ 9♣ 4♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `9`, not `10` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-king-ten but missing both queen and jack, with only one outside ace, then the normal evaluator should cap the recommendation below 12 unless the hand has stronger supporting evidence such as queen or jack trump support, multiple outside aces, reliable side-suit winners, extra trump length, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `4♥ 10♦ 3♦ Q♣ 6♦ K♦ 5♦ A♦ 7♣ 7♠ 6♣ A♣ 8♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `11`, not `12` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed only by ace-ten, missing king, queen, and jack, with one outside ace and one outside king, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as protected king, queen, or jack trump support, multiple outside aces, stronger side-suit winners, extra trump length, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `8♥ 6♣ A♥ K♦ 4♣ 10♣ 3♥ 7♣ 3♣ 9♣ 6♥ Q♦ A♣` with no current highest bid, then the balanced/default recommendation should prefer clubs but be at most `10`, not `11` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-queen but missing king, jack, and ten, with only one outside ace and one singleton, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as stronger trump texture, multiple outside aces, reliable side winners, useful short-suit shape with enough trump control, or partnership context.
- Given the normal evaluator receives `A♠ 7♠ A♣ 4♣ 3♠ 5♠ 9♠ 7♥ 4♥ J♦ Q♠ 4♠ 3♥` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `10`, not `11` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-queen-jack but missing king and ten, with only one outside ace, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as the trump king or ten, multiple outside aces, reliable side-suit winners, extra trump length, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `4♥ 3♠ Q♥ 8♥ 3♣ 9♥ A♥ 5♣ J♥ A♠ 8♦ 5♦ 3♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `10`, not `11` or higher.
- Given a hand has an eight-card candidate Tarneeb suit headed only by the ace, with no king, queen, jack, or ten and no outside aces, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as protected top trump honors, reliable outside aces, stronger side-suit winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `8♠ 6♠ 2♠ 4♦ 5♠ 4♠ 5♥ 9♠ 3♦ A♠ K♦ 5♣ 3♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `9`, not `10` or higher.
- Given a hand has an eight-card candidate Tarneeb suit headed by ace-queen-jack-ten but missing king, with no outside aces or outside kings and only one singleton as support, then the normal evaluator should cap the recommendation below 12 unless the hand has stronger supporting evidence such as the trump king, reliable outside winners, stronger side-suit support, useful short-suit shape with enough trump control, or partnership context.
- Given the normal evaluator receives `7♦ 4♥ 7♥ 9♦ 5♥ Q♦ 2♥ J♦ 6♦ A♦ 2♦ 10♦ 5♠` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `11`, not `12` or higher.
- Given a hand has an eight-card candidate Tarneeb suit headed by ace-queen-ten but missing king and jack, with only one outside ace, then the normal evaluator should cap the recommendation below 13 unless the hand has stronger supporting evidence such as the trump king or jack, multiple outside aces, reliable side-suit winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `4♥ 2♠ Q♠ 7♦ 3♥ 7♠ A♠ Q♥ 8♥ 7♥ 10♥ 2♥ A♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `11`, not `12` or `13`.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-king-ten but missing both queen and jack, with no outside aces and only side kings or queens as support, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger supporting evidence such as queen or jack trump support, reliable outside aces, stronger side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♥ 9♥ 10♥ 8♥ 7♥ K♦ A♥ 3♦ K♠ 4♠ Q♣ Q♦ 3♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `10`, not `11` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-king-ten but missing both queen and jack, with no outside aces and only side king/queen support, then the normal evaluator should cap the recommendation below 12 even when the hand has a side-suit void unless it has stronger trump texture, reliable outside aces, stronger side winners, or partnership context.
- Given the normal evaluator receives `K♥ 5♠ Q♥ K♠ 4♠ A♠ 10♠ 4♥ 9♥ 3♠ K♦ Q♦ 6♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `11`, not `12` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king with only low remaining trump cards, no outside aces, and no outside kings, then the normal evaluator should cap the recommendation below 10 even when the hand has useful short-suit shape.
- Given the normal evaluator receives `7♥ 4♥ K♥ 2♣ 2♠ 8♣ A♥ 6♥ 5♥ J♠ 5♠ 10♠ Q♠` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `9`, not `10` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-jack but missing queen and ten, with only one outside ace and no outside king support, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger supporting evidence such as the trump queen or ten, multiple outside aces, reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♥ 7♣ 4♥ 10♣ 9♥ 3♥ 2♠ A♥ A♦ 8♣ 6♦ 7♠ J♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `9`, not `10` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by king-queen-jack-ten but missing ace, with no outside aces and only ordinary side king/queen support, then the normal evaluator should cap the recommendation below 10 unless the hand has the trump ace, stronger protected trump texture, reliable outside aces, additional side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♣ Q♠ 9♥ 9♠ 10♠ 5♣ K♠ 7♠ J♠ 5♠ K♦ 4♣ 5♥` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `9`, not `10` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king with only low remaining trump cards, two outside aces, and one outside king, then the normal evaluator should cap the recommendation below 10 unless the hand has stronger trump texture such as queen, jack, or ten support, additional reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♥ 10♥ A♥ A♦ 9♦ A♣ 8♦ 3♥ 6♦ K♦ 9♠ J♠ 4♣` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `9`, not `10` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-king-queen but missing jack and ten, with no outside aces and no outside kings, then the normal evaluator should cap the recommendation below 11 unless the hand has stronger trump texture, reliable outside winners, useful short-suit shape, extra trump length, or partnership context.
- Given the normal evaluator receives `8♠ Q♠ 9♣ 7♥ 3♥ 10♦ J♣ 7♠ 6♠ A♠ K♠ 5♦ 2♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `10`, not `11` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king with only low remaining trump cards, one outside ace, and ordinary side king/queen support, then the normal evaluator should cap the recommendation below 10 unless the hand has queen, jack, or ten trump support, multiple outside aces, additional protected side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♠ 8♦ A♦ A♥ 8♥ K♣ 4♥ 2♦ 5♦ J♠ 7♦ 7♠ K♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `9`, not `10` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-king-queen-jack but missing ten, with no outside aces and only one outside king, then the normal evaluator should cap the recommendation below 12 unless the hand has the trump ten, reliable outside aces, additional side winners, stronger short-suit shape, or partnership context.
- Given the normal evaluator receives `K♠ Q♦ A♦ 3♦ 10♣ 9♠ 9♦ 4♦ 4♣ 8♠ K♦ J♦ 6♣` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `11`, not `12` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-king-jack but missing queen and ten, with no outside aces and only side kings or queens as support, then the normal evaluator should cap the recommendation below 11 unless the hand has queen or ten trump support, reliable outside aces, additional side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `2♦ 2♠ J♠ 6♣ Q♦ K♥ 7♠ 9♠ 2♥ A♠ K♠ 8♠ K♦` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `10`, not `11` or higher.
- Given the normal evaluator receives `8♥ 3♠ 5♣ 4♥ 7♣ A♦ 2♥ 7♥ 8♦ A♥ K♣ 10♠ K♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `9`, not `10` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-jack-ten but missing queen, with no outside aces and only one outside king, then the normal evaluator should cap the recommendation below 11 unless the hand has the trump queen, reliable outside aces, additional side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♦ 7♥ 4♦ K♠ 5♦ 2♦ 5♠ 7♠ 9♥ 10♠ 9♦ J♠ A♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `10`, not `11` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by king-queen-ten but missing ace and jack, even with two outside aces, then the normal evaluator should cap the recommendation below 9 unless the hand has the trump ace or jack, extra trump length, multiple reliable side winners beyond aces, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `J♣ Q♦ 3♣ 5♠ A♣ 8♠ Q♠ 10♠ 4♦ A♦ 3♥ K♠ 2♣` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `8`, not `9` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-queen but the remaining trump cards are low, with only one outside ace and no outside kings, then the normal evaluator should cap the recommendation below 10 unless the hand has jack or ten trump support, extra trump length, additional reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `6♥ 2♠ 2♦ 8♣ 9♣ A♦ K♦ 8♠ A♣ 5♦ Q♦ 3♣ Q♣` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `9`, not `10` or higher.
- Given a hand has an eight-card candidate Tarneeb suit headed by ace-queen-jack-ten but missing king, with only one outside ace and no outside kings, then the normal evaluator should cap the recommendation below 13 unless the hand has the trump king, multiple outside aces, reliable side winners, near-certain trump control, or exceptional partnership context.
- Given the normal evaluator receives `10♥ J♥ 2♥ A♣ 2♦ 4♥ 9♦ Q♥ 10♦ 4♣ 9♥ 6♥ A♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `12`, not `13`.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-queen with low remaining trump cards and missing king, jack, and ten, then two outside aces and side kings should not justify a 10 bid by default; the normal evaluator should cap the recommendation below 10 unless the hand has stronger trump texture, extra trump length, exceptional short-suit shape, or partnership context.
- Given the normal evaluator receives `A♦ 7♠ 8♠ 5♦ K♥ 4♥ 7♣ A♣ Q♠ 3♥ 9♠ K♦ A♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `9`, not `10` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by a lone ace with low remaining trump cards, then three outside aces should not justify a 9 bid by default; the normal evaluator should cap the recommendation below 9 unless the hand has stronger trump texture, extra trump length, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `A♠ 4♥ 10♠ 3♥ 8♠ 5♥ 10♦ 5♦ A♦ 8♣ A♥ A♣ 10♣` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `8`, not `9` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by king-queen-jack but missing ace and ten, with only one outside ace and one outside king, then the normal evaluator should cap the recommendation below 9 unless the hand has the trump ace or ten, extra trump length, multiple outside aces, stronger side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♠ Q♦ J♦ 10♣ 8♣ 2♦ 6♠ 8♠ A♣ 5♣ 6♦ K♦ 9♣` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `8`, not `9` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king-jack but missing queen and ten, with no outside aces and only one outside king, then the normal evaluator should cap the recommendation below 8 unless the hand has extra trump length, the trump queen or ten, reliable outside aces, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `8♥ 8♦ 6♦ Q♠ 2♦ J♥ 9♣ K♥ 2♠ 5♦ K♣ 9♦ A♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be `Pass` or at most `7`, not `8` or higher.
- Given a hand has an eight-card candidate Tarneeb suit headed by ace-jack-ten but missing king and queen, with no outside aces or outside kings, then the normal evaluator should cap the recommendation below 11 unless the hand has protected king or queen trump support, reliable outside winners, stronger side-suit support, useful short-suit shape with enough trump control, or partnership context.
- Given the normal evaluator receives `5♦ A♦ 6♦ 6♥ 2♠ J♦ 8♦ 3♦ 6♠ J♠ 4♦ 10♦ 9♥` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `10`, not `11` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king-queen-ten, with no outside aces and only one outside king, then the normal evaluator should cap the recommendation below 8 unless the hand has extra trump length, multiple outside aces, exceptional short-suit shape, or partnership context.
- Given the normal evaluator receives `6♦ 3♦ Q♠ 10♠ 7♥ 9♥ K♦ 9♦ 5♥ 10♥ A♠ K♠ 8♥` with no current highest bid, then the balanced/default recommendation should prefer spades but be `Pass` or at most `7`, not `8` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-queen-jack but missing king and ten, even with two outside aces, then the normal evaluator should cap the recommendation below 10 unless the hand has extra trump length, the trump king or ten, additional protected side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `2♥ J♥ A♠ A♣ 4♥ A♥ 3♠ 8♣ 10♣ 5♠ 8♠ Q♥ 4♠` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `9`, not `10` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-jack-ten but missing king and queen, with no outside aces and only one outside king, then the normal evaluator should cap the recommendation below 10 unless the hand has protected king or queen trump support, reliable outside aces, stronger side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `3♦ 5♣ 4♣ K♣ A♦ 9♦ 8♦ 10♦ 10♥ J♠ J♦ 6♦ Q♥` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `9`, not `10` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-king-queen but missing jack and ten, with at most one outside ace even when ordinary outside king support is present, then the normal evaluator should cap the recommendation below 12 unless the hand has the trump jack or ten, extra trump length, multiple reliable outside winners, useful short-suit shape backed by enough trump control, or exceptional partnership context.
- Given the normal evaluator receives `7♥ 10♠ 6♠ 2♠ A♥ K♥ 4♥ Q♥ 9♥ 7♠ 3♥ A♠ 7♦` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `11`, not `12` or higher.
- Given the normal evaluator receives `6♣ 4♥ 3♣ 2♥ 8♥ A♠ K♥ Q♥ A♥ 5♥ 4♦ 10♣ K♣` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `11`, not `12` or higher.
- Given the normal evaluator receives `A♠ K♥ 8♣ 7♠ Q♥ A♥ 4♠ 7♥ 4♣ 7♣ 8♥ 2♥ 4♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `11`, not `12` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by king-queen-jack-ten but missing ace, even with two outside aces, then the normal evaluator should cap the recommendation below 9 unless the hand has the trump ace, extra trump length, multiple reliable side winners beyond aces, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `5♠ 4♠ 8♣ 6♥ A♣ K♥ A♠ 10♠ J♥ 2♣ 10♥ 3♣ Q♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `8`, not `9` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-jack but missing queen and ten, even with two outside aces and one outside king, then the normal evaluator should cap the recommendation below 12 unless the hand has the trump queen or ten, extra trump length, additional reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♠ 4♦ 9♠ A♦ 5♥ A♥ 2♥ 3♦ J♦ Q♣ A♣ 7♦ K♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `11`, not `12` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-jack but missing queen and ten, with no outside aces and only one outside king, then the normal evaluator should cap the recommendation below 10 unless the hand has the trump queen or ten, reliable outside aces, additional side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `9♠ 4♠ A♠ K♥ 5♠ K♠ 8♥ J♠ 4♣ 7♣ J♦ 2♥ 9♣` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `9`, not `10` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-queen-jack but missing ten, with only one outside ace and limited side support, then the normal evaluator should cap the recommendation below 10 unless the hand has extra trump length, the trump ten, additional reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♣ 8♠ 6♦ 8♣ J♠ A♠ J♦ 2♠ 6♠ K♦ Q♦ 9♥ A♦` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `9`, not `10` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by king-queen-jack but missing ace and ten, with no outside aces and only side kings as support, then the normal evaluator should cap the recommendation below 10 unless the hand has the trump ace or ten, multiple outside aces, stronger side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♠ K♣ 5♠ 5♦ 4♠ K♠ K♦ J♠ Q♣ 7♦ 5♥ 8♠ 6♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `9`, not `10` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by king-queen-jack but missing ace and ten, with only one outside ace and no outside kings, then the normal evaluator should cap the recommendation below 9 unless the hand has the trump ace or ten, extra trump length, multiple outside aces, stronger side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♦ Q♣ K♦ 6♣ 9♦ J♦ 2♠ 2♦ A♥ 9♥ 10♠ 4♦ 7♣` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `8`, not `9` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-jack but missing queen and ten, even with two outside aces and one outside king, then the normal evaluator should cap the recommendation below 11 unless the hand has the trump queen or ten, extra trump length, additional reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `7♥ A♠ 4♦ 2♠ 4♣ A♣ 9♥ 7♦ K♠ A♥ K♥ J♥ 2♣` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `10`, not `11` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-queen-ten but missing jack, even with two outside aces and one outside king, then the normal evaluator should cap the recommendation below 12 unless the hand has extra trump length, the trump jack, additional reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♣ 10♣ J♠ A♣ A♦ A♠ K♣ 8♣ K♦ 10♦ 2♠ 8♠ 9♠` with no current highest bid, then the balanced/default recommendation should prefer clubs but be at most `11`, not `12` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-queen with low remaining trump cards, with only one outside ace and side kings, then the normal evaluator should cap the recommendation below 10 unless the hand has jack or ten trump support, extra trump length, additional reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♦ 3♥ K♠ A♠ 7♣ 7♥ 9♣ K♥ 5♠ Q♠ A♥ 6♦ 6♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `9`, not `10` or higher.
- Given the normal evaluator receives `3♠ A♥ K♦ 4♣ J♦ K♣ 9♠ 2♠ Q♦ 8♦ J♣ A♦ 9♥` with no current highest bid, then the balanced/default recommendation should prefer diamonds but be at most `9`, not `10` or higher.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-jack-ten but missing king and queen, even with two outside aces and ordinary side king/queen support, then the normal evaluator should cap the recommendation below 9 unless the hand has extra trump length, protected king or queen trump support, stronger side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♣ Q♣ 9♣ 4♣ J♥ 5♠ 10♥ 10♦ 8♠ A♥ A♦ A♠ 8♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `8`, not `9` or higher.
- Given a hand has a seven-card candidate Tarneeb suit headed by ace-queen-jack-ten but missing king, with only one outside ace and one outside king, then the normal evaluator should cap the recommendation below 12 unless the hand has the trump king, extra trump length, multiple outside aces, reliable side winners, or exceptional partnership context.
- Given the normal evaluator receives `6♣ A♣ 8♠ K♥ Q♣ 8♣ 10♣ A♠ J♣ 4♦ 7♦ 3♥ 3♣` with no current highest bid, then the balanced/default recommendation should prefer clubs but be at most `11`, not `12` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-queen-ten but missing king and jack, even with two outside aces and side king/queen support, then the normal evaluator should cap the recommendation below 11 unless the hand has the trump king or jack, extra trump length, additional reliable side winners, stronger short-suit shape, or partnership context.
- Given the normal evaluator receives `A♦ A♥ Q♣ 4♠ A♠ 4♦ 2♥ 6♥ K♦ 9♥ Q♥ 7♦ 10♥` with no current highest bid, then the balanced/default recommendation should prefer hearts but be at most `10`, not `11` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-queen-ten but missing jack, with no outside aces and only side kings as support, then the normal evaluator should cap the recommendation below 11 unless the hand has the trump jack, reliable outside aces, additional side winners, extra trump length, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `K♠ 4♣ K♦ K♣ Q♣ 10♣ 10♠ 7♣ 8♠ J♠ 3♦ A♣ 2♥` with no current highest bid, then the balanced/default recommendation should prefer clubs but be at most `10`, not `11` or higher.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-king-queen-jack but missing ten, with one outside ace plus ordinary side king/queen support, then the normal evaluator should cap the recommendation below 11 unless the hand has the trump ten, extra trump length, multiple outside aces, near-certain side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♣ K♦ 9♠ A♠ 5♦ 10♥ 8♦ Q♠ 2♣ 3♦ J♠ A♣ K♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `10`, not `11` or higher.
- Given a hand has an eight-card candidate Tarneeb suit headed by ace-king-queen-jack but missing ten, with no outside aces or outside kings, then the normal evaluator should cap the recommendation below 13 unless the hand has the trump ten, near-certain trump control, reliable outside winners, or exceptional partnership context.
- Given the normal evaluator receives `7♦ K♣ 10♥ 9♣ 7♣ Q♣ 8♣ 10♠ 5♣ J♣ A♣ 4♠ 8♠` with no current highest bid, then the balanced/default recommendation should prefer clubs but be at most `12`, not `13`.
- Given a hand has a five-card candidate Tarneeb suit headed by ace-queen-jack but missing king and ten, even with two outside aces and side kings, then the normal evaluator should cap the recommendation below 11 unless the hand has the trump king or ten, extra trump length, additional protected side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `8♠ A♣ A♦ K♦ K♣ 10♦ A♠ 5♠ J♠ 6♥ 5♣ K♥ Q♠` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `10`, not `11` or higher.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-ten but missing king, queen, and jack, with only one outside ace and ordinary side queen support, then the normal evaluator should cap the recommendation below 9 unless the hand has protected top trump honors, multiple outside aces, reliable side winners, useful short-suit shape, or partnership context.
- Given the normal evaluator receives `Q♦ 9♠ 5♠ A♠ 6♠ 7♦ 7♥ 2♥ A♣ 4♠ 10♠ 4♣ 6♦` with no current highest bid, then the balanced/default recommendation should prefer spades but be at most `8`, not `9` or higher.
- Given the bid generator estimates fewer than seven likely team tricks, then it recommends `Pass`.
- Given the best candidate `safeBidCeiling` is below 7, then the bid generator recommends `Pass` even when a more optimistic `expectedTricks` estimate reaches seven or more.
- Given the best candidate `safeBidCeiling` is seven or more, then the bid generator recommends a bid from 7 through 13 that does not exceed that `safeBidCeiling`.
- Given the bid generator recommends a numeric bid, then the recommendation also includes a preferred Tarneeb suit representing the strongest evaluated candidate suit.
- Given the bid generator recommends `Pass`, then the preferred Tarneeb suit is empty.
- Given the bid generator produces any recommendation, then it includes a confidence value in the range 0 through 1 and diagnostic metadata sufficient to explain the selected suit, `expectedTricks`, `safeBidCeiling`, and any high-bid gate that capped the recommendation.
- Given the simulated player's partner is the current highest bidder, then the simulated player must recommend `Pass` by default.
- Given the simulated player's partner is the current highest bidder, then the simulated player may raise only when its hand has clearly stronger trump potential than the partner's current commitment requires.
- Given the simulated player's partner is the current highest bidder, then a raise must require both a numeric recommendation at least two tricks above the current highest bid and evidence of strong independent trump control, such as the trump ace or multiple protected top honors in the preferred Tarneeb suit.
- Given the simulated player's partner is the current highest bidder at `8`, then a six-card ace-king-jack candidate suit with low remaining trump cards, no outside aces, and only one outside king should not be considered clearly strong enough to raise that partner to `10`.
- Given North receives `Q♥ 7♦ 8♣ 8♥ 7♥ 6♠ 2♠ A♠ 5♠ 2♣ J♠ K♦ K♠` while South is the current highest bidder at `8`, then North's balanced/default recommendation should resolve to `Pass`, not a `10` bid with spades as the preferred suit.
- Given the simulated player's partner is the current highest bidder at `8`, then an eight-card ace-queen-jack-ten candidate suit missing king, with only one outside ace, should not raise the partner directly to `13` unless the hand has near-certain trump control and stronger outside support.
- Given North receives `10♥ J♥ 2♥ A♣ 2♦ 4♥ 9♦ Q♥ 10♦ 4♣ 9♥ 6♥ A♥` while South is the current highest bidder at `8`, then North's balanced/default recommendation should not resolve to `13` with hearts as the preferred suit.
- Given the simulated player's partner is the current highest bidder at `8`, then a five-card ace-queen-jack candidate suit missing king and ten, even with two outside aces, should not raise the partner to `10` unless the hand has stronger independent trump length or control.
- Given South receives `2♥ J♥ A♠ A♣ 4♥ A♥ 3♠ 8♣ 10♣ 5♠ 8♠ Q♥ 4♠` while North is the current highest bidder at `8`, then South's balanced/default recommendation should resolve to `Pass`, not a `10` bid with hearts as the preferred suit.
- Given the simulated player's partner is the current highest bidder at `8`, then a seven-card ace-jack-ten candidate suit missing king and queen, with no outside aces and only one outside king, should not raise the partner to `10`.
- Given East receives `3♦ 5♣ 4♣ K♣ A♦ 9♦ 8♦ 10♦ 10♥ J♠ J♦ 6♦ Q♥` while West is the current highest bidder at `8`, then East's balanced/default recommendation should resolve to `Pass`, not a `10` bid with diamonds as the preferred suit.
- Given the simulated player's partner is the current highest bidder at `7`, then a five-card ace-king-jack candidate suit missing queen and ten, even with two outside aces and one outside king, should not raise the partner to `11` unless the hand has stronger trump texture, extra trump length, or exceptional outside support.
- Given West receives `7♥ A♠ 4♦ 2♠ 4♣ A♣ 9♥ 7♦ K♠ A♥ K♥ J♥ 2♣` while East is the current highest bidder at `7`, then West's balanced/default recommendation should not resolve to `11` with hearts as the preferred suit.
- Given the simulated player's partner is the current highest bidder at `9`, then a five-card ace-king-queen-ten candidate suit missing jack, even with two outside aces and one outside king, should not raise the partner to `12` unless the hand has extra trump length or near-certain side winners.
- Given West receives `Q♣ 10♣ J♠ A♣ A♦ A♠ K♣ 8♣ K♦ 10♦ 2♠ 8♠ 9♠` while East is the current highest bidder at `9`, then West's balanced/default recommendation should not resolve to `12` with clubs as the preferred suit.
- Given the simulated player's partner is the current highest bidder at `8`, then a five-card ace-king-queen-jack candidate suit missing ten should not raise the partner directly to `11` based only on one outside ace, ordinary side king/queen support, and one singleton.
- Given West receives `Q♣ K♦ 9♠ A♠ 5♦ 10♥ 8♦ Q♠ 2♣ 3♦ J♠ A♣ K♠` while East is the current highest bidder at `8`, then West's balanced/default recommendation should not resolve to `11` with spades as the preferred suit; if it raises at all, the resolved recommendation should be at most `10`.
- Given the bid generator would recommend 12 or 13, then that recommendation should require substantially stronger hand evidence than a minimum 7 or 8 bid.
- Given two recommendations are otherwise tied, then the implementation should choose deterministically so tests can assert the result.
- Given bidding implementation Phase 3 is enabled, then each simulated player has a bidding personality profile.
- Given a simulated player's personality profile is applied, then the personality starts from the normal per-suit `expectedTricks` and `safeBidCeiling` values produced by the hand-strength evaluator before legal-bid enforcement.
- Given a simulated player has a conservative, balanced, or aggressive personality, then the profile may adjust thresholding or rounding inside the candidate suit's `safeBidCeiling`; even an aggressive personality must not bid above the generalized safe ceiling or bypass the high-bid gates.
- Given a personality-adjusted recommendation is generated, then it must still include preferred Tarneeb suit and confidence metadata for numeric recommendations.
- Given a personality-adjusted recommendation is generated, then it must still be passed through the normal safe-ceiling and legal-bid rules and must not allow an equal-or-lower bid, a bid below 7, a bid above 13, a high bid without the required structural gate, or reentry after `Pass`.
- Given a simulated bid recommendation is generated, then the bidding service still applies the normal legal-bid rules from PRD-016 before displaying the value.
- Given a simulated bid recommendation would raise the simulated player's partner by only one trick, then the bidding service must resolve that recommendation to `Pass` unless the partner-raise threshold is met, even if the value came from an injected override, stale recommendation, or test-controlled recommender.
- Given West is the current highest bidder at `7` and East's simulated recommendation is `8`, then East's displayed bid must resolve to `Pass` unless East's recommendation independently satisfies the partner-raise requirements.
- Given a simulated bid recommendation becomes an accepted numeric bid, then the accepted bid stores the preferred trump/Tarneeb suit alongside the bid value and retains the confidence value as internal metadata.
- Given a simulated bid recommendation resolves to `Pass` because it is `Pass`, lower than the current highest bid, or equal to the current highest bid, then no preferred trump/Tarneeb suit is stored on that player's resolved bid state.
- Given South commits a numeric bid, then the accepted South bid may temporarily have no preferred Tarneeb suit until South wins the auction and completes the post-bidding `Set` step.
- Given bidding completes with South as the numeric high bidder, then the app stops at `Bidding complete`, fades out the `Bidding` area, shows the post-bidding suit-setting panel, and then stores South's selected suit when South taps `Set`.
- Given bidding completes with any numeric high bid, then the app does not use the preferred Tarneeb suit to start trick play.
- Given bidding completes with all four players passing before any numeric bid is accepted, then the app does not stop for a post-bidding summary and instead starts the automatic all-pass redeal.
- Given a six-card candidate Tarneeb suit is headed by ace-king-queen but missing both jack and ten, with only one outside ace and ordinary side king/queen support, then the `safeBidCeiling` should remain below 11 unless the hand has extra trump length, the trump jack or ten, multiple outside aces, additional protected side winners, useful short-suit shape backed by enough trump control, or exceptional partnership context.
- Given a seven-card candidate Tarneeb suit is headed by king-queen with low remaining trump cards and is missing ace, jack, and ten, with at most one outside ace and ordinary side king support, then the `safeBidCeiling` should remain below 9 unless the hand has the trump ace, protected jack or ten support, multiple outside aces, additional reliable side winners, useful short-suit shape backed by enough trump control, or partnership context.
- Given a four-card candidate Tarneeb suit is headed by ace-king-queen-jack but missing ten, with at most one outside ace and ordinary side honor support, then the `safeBidCeiling` should remain below 9 unless the hand has extra trump length, the trump ten, multiple outside aces, exceptional side certainty, or exceptional partnership context.
- Given a six-card candidate Tarneeb suit is headed by ace-king with low remaining trump cards, with only one outside ace and ordinary side king/queen support, then the `safeBidCeiling` should remain below 10 unless the hand has queen, jack, or ten trump support, multiple outside aces, additional protected side winners, useful short-suit shape backed by enough trump control, or partnership context.
- Given a hand has a six-card candidate Tarneeb suit headed by ace-king-queen but missing both jack and ten, with only one outside ace and ordinary side king/queen support, then the normal evaluator should cap the recommendation below 11 unless the hand has extra trump length, the trump jack or ten, multiple outside aces, additional protected side winners, useful short-suit shape, or partnership context.
- Given a hand has a seven-card candidate Tarneeb suit headed by king-queen with low remaining trump cards and missing ace, jack, and ten, with at most one outside ace and ordinary side king support, then the normal evaluator should cap the recommendation below 9 unless the hand has the trump ace, protected jack or ten support, multiple outside aces, additional reliable side winners, useful short-suit shape, or partnership context.
- Given a hand has only a four-card candidate Tarneeb suit headed by ace-king-queen-jack but missing ten, with at most one outside ace and ordinary side honor support, then the normal evaluator should cap the recommendation below 9 unless the hand has extra trump length, the trump ten, multiple outside aces, exceptional side certainty, or partnership context.

### PRD-018: Post-Bidding Summary

As a human player, I want the completed bidding area to clear away and show the high-bidding player, bid, and Tarneeb suit symbol so I can understand the auction result.

#### Acceptance Criteria

- Given the bidding round reaches a terminal state, then the visible `Bidding` area fades out over one second.
- Given the one-second fade-out completes, then the `Bidding` area is no longer visible.
- Given the one-second fade-out completes and a numeric high bid exists, then a post-bidding summary is displayed.
- Given the post-bidding summary displays, then it displays the actual high-bidding player as `South`, `East`, `North`, or `West`.
- Given the post-bidding summary displays a high-bidding player, then it also displays the high bid value.
- Given the post-bidding summary displays a high-bidding player, then it also displays a `Tarneeb` label with the preferred suit symbol for the highest bidder.
- Given the preferred suit is spades, then the `Tarneeb` label includes `♠`.
- Given the preferred suit is clubs, then the `Tarneeb` label includes `♣`.
- Given the preferred suit is hearts, then the `Tarneeb` label includes `♥`.
- Given the preferred suit is diamonds, then the `Tarneeb` label includes `♦`.
- Given bidding completes with no numeric high bid, then no high-bidding player or Tarneeb suit summary is displayed.
- Given bidding completes with no numeric high bid because all four players passed before any numeric bid was accepted, then a new deal starts automatically after the bidding-area fade-out.
- Given an all-pass automatic new deal starts, then any previous post-bidding summary remains hidden and the dealer is the player on the previous dealer's right.
- Given the post-bidding summary is displayed, then it is not interactive and does not allow Tarneeb suit selection.
- Given a replacement deal starts, then any previous post-bidding summary disappears and the new bidding round begins with the `Bidding` area visible again after the deal.
- Given `New Game` is tapped, then any post-bidding summary disappears with the rest of the dealt-state UI.

### PRD-019: Deal Hand Console Logging

As a developer, I want each player's dealt hand logged after the deal so bidding behavior can be debugged against the actual cards.

#### Acceptance Criteria

- Given any deal completes, then the app writes one console log entry for South's 13-card hand.
- Given any deal completes, then the app writes one console log entry for East's 13-card hand.
- Given any deal completes, then the app writes one console log entry for North's 13-card hand.
- Given any deal completes, then the app writes one console log entry for West's 13-card hand.
- Given a hand is logged, then the log entry includes the seat label and all 13 cards in a readable rank-and-suit format.
- Given a replacement deal completes, then the app logs all four new hands again.
- Given the app logs hands, then the logs are written only to the console and are not displayed in the game UI.
- Given the hand logging implementation is tested, then the logging destination can be replaced or captured without requiring UI tests to read the Xcode console.

## 6. Functional Specification

### 6.1 Card Model

A card must contain:

- `suit`: one of `spades`, `clubs`, `hearts`, `diamonds`
- `rank`: one of `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `J`, `Q`, `K`, `A`
- A stable identity derived from suit and rank, such as `spades-A`

### 6.2 Player Model

A player must contain:

- `id`: stable unique identifier
- `seat`: one of `south`, `west`, `north`, `east`
- `type`: `human` or `simulated`
- `team`: `teamA` or `teamB`
- `hand`: list of cards

### 6.3 Game State Model

The game state must contain:

- `phase`: one of `notStarted`, `dealt`
- `players`: exactly four players
- `dealerSeat`: one of `south`, `west`, `north`, `east`
- `deck`: source deck before or during dealing, if retained by implementation
- `bids`: structured bid states keyed by seat after the deal completes; accepted numeric bid states include the bid value and preferred trump/Tarneeb suit
- `biddingTurnSeat`: the current seat whose bidding turn is active, if bidding is still in progress
- `southDraftBidValue`: the South player's in-progress bid selection while South's turn is active, if any
- `southDraftTarneebSuit`: the South player's post-bidding Tarneeb suit selection while South is the numeric high bidder and the final summary has not yet been produced
- `highestBidSeat`: the seat with the current highest numeric bid, if any numeric bid has been accepted
- `highestBidValue`: the current highest numeric bid from 7 through 13, if any numeric bid has been accepted
- `bidRecommendations`: optional internal recommendation metadata keyed by seat, including the recommended bid, preferred Tarneeb suit, and confidence
- `postBiddingSummary`: optional terminal summary containing the high-bidding player label, high bid value, and preferred Tarneeb suit symbol when a numeric high bid exists

Each bid state must be one of:

- `pending`, displayed as `--`
- `activeSouthSelection`, displayed as the South bid-chip selector when it is South's turn
- `pass`, displayed as `Pass`
- a numeric bid from 7 through 13 with a stored preferred trump/Tarneeb suit, except that South's numeric high bid may be pending suit selection until the post-bidding `Set` action

Only accepted numeric bid states may carry committed preferred trump/Tarneeb suit metadata. `pending`, `pass`, and `activeSouthSelection` states must not carry preferred trump/Tarneeb suit metadata. South's committed numeric high bid receives its preferred suit only after the post-bidding `Set` action.

Each accepted numeric bid state should contain:

- `value`: a numeric bid from 7 through 13
- `preferredTarneebSuit`: one of `spades`, `clubs`, `hearts`, or `diamonds`; for simulated numeric bids this comes from the automated evaluator, and for South numeric high bids this comes from South's post-bidding `Set` action
- `confidence`: optional internal confidence value from 0 through 1 when the bid came from an automated recommendation

Each simulated bid recommendation should contain:

- `bid`: `Pass` or a numeric bid from 7 through 13
- `preferredTarneebSuit`: one of `spades`, `clubs`, `hearts`, or `diamonds` when the recommendation is numeric; empty when the recommendation is `Pass`
- `confidence`: a value from 0 through 1

Each post-bidding summary should contain:

- `highBidderSeat`: the seat that made the accepted high bid
- `highBidderLabel`: `South`, `East`, `North`, or `West`
- `bidValue`: numeric bid from 7 through 13
- `tarneebSuit`: one of `spades`, `clubs`, `hearts`, or `diamonds`
- `tarneebSymbol`: `♠`, `♣`, `♥`, or `♦`

No post-summary editable Tarneeb suit selection, trick-play, scoring, or game-over phase should be implemented for MVP 008. The only interactive Tarneeb suit control in MVP 008 is South's post-bidding suit-setting panel when South is the numeric high bidder.

### 6.4 Seat Order

The game model must preserve the Tarneeb counterclockwise seat order. Recommended model order:

1. South: Human
2. East: Simulated
3. North: Simulated
4. West: Simulated

The visual layout must surround the central card table:

- North above the table.
- West left of the table.
- South below the table.
- East right of the table.

The model order and visual placement are related but separate concerns.

Dealer rotation must use the same counterclockwise model order:

1. South
2. East
3. North
4. West
5. South, repeating

### 6.5 Dealer Behavior

At the start of a new game, the implementation must randomly select one of the four seats as `dealerSeat`. Exactly one dealer may be selected at a time.

Before a deal completes:

- The selected dealer station must show a small `D` pill beside the player name.
- The dealer pill must use the same blue color as the `Deal` button, use white `D` text, and must not overlay or obscure the player name.
- If the selected dealer is also the active bidder after a deal, the active bidding outline is used for turn state and the pre-bidding dealer pill is hidden.
- The undealt 52-card deck stack must appear inside the selected dealer's player station.
- The undealt deck stack must have a squared appearance before the deal.
- The undealt deck stack must remain inside the dealer station with an appropriate buffer from the station edge.

After a deal completes:

- The dealer pill must be hidden once bidding starts.
- The undealt deck stack must disappear.
- The selected dealer must remain in game state and station metadata for rotation purposes.

When a replacement deal starts within the same game, the dealer must advance counterclockwise from the previous dealer before that replacement deal is dealt.

### 6.6 Dealing Behavior

The implementation must produce four hands of 13 cards each. The MVP does not require a visible card-by-card dealing animation. It is acceptable to shuffle once and assign cards into four 13-card hands.

Recommended deterministic dealing algorithm after shuffle:

1. Ensure a valid `dealerSeat` exists.
2. Create the 52-card deck.
3. Shuffle the deck.
4. Assign cards to seats in 13-card chunks.
5. Mark the game phase as `dealt`.
6. Hide the undealt deck stack.
7. Keep player station outlines at the default station outline color.
8. Hide the pre-bidding dealer pill while keeping the current dealer in state/metadata until the next deal request advances the dealer.
9. Initialize the post-deal bidding round with each player bid state set to `pending`, displayed as `--`.
10. Set the first bidding turn to the player on the dealer's right.
11. Log each player's 13-card hand to the console in readable seat/rank/suit form.

### 6.7 Card Presentation Rules

- Exposed cards must show rank and suit through imported xCards face artwork.
- Hearts and Diamonds must render rank and suit in red through the card face asset.
- Clubs and Spades must render rank and suit in black or another high-contrast dark color through the card face asset.
- Exposed cards and hidden card backs must share the same base dimensions.
- Cards should use a standard playing-card aspect ratio, approximately 5:7 width to height.
- Card sizing may adapt to device size, but exposed card text must remain readable and hidden cards must not be scaled smaller than exposed cards.
- Each exposed standard card face must resolve to a stable `card_face_<rank><suit>` asset with complete `1x`, `2x`, and `3x` image variants.
- Exposed card faces must use the face asset directly and preserve the asset's native corner mask; no separate tokenized rounded rectangle, clipping mask, or border may be layered over the face image.
- Exposed card faces must use high-quality image interpolation when scaled to the shared card size so the imported artwork remains crisp.
- Hidden cards must use the provided `card_back.png` asset.
- Hidden card stacks may overlap slightly to conserve space.
- The initial undealt deck stack must represent 52 hidden cards without revealing rank or suit information.

### 6.8 Layout Behavior

- The app must be locked to portrait orientation.
- The screen must include a circular card table centered in the main table area.
- The circular card table diameter must be half the screen width.
- The circular table center must reserve a clear play area with four subtle target slots corresponding to South, West, North, and East for future trick-play cards.
- The play area target slots must be non-interactive in MVP 008 and must not introduce play-card controls, trick resolution, or scoring.
- The Arabic title `طرنيب` must be centered on the card table.
- The title must remain centered on the table and unobscured by the undealt deck before the deal.
- Before a deal completes, a squared stack of 52 hidden cards must appear inside the selected dealer's player station.
- The undealt deck stack must stay inside the dealer station with an appropriate buffer from the station edge.
- After a deal completes, the undealt deck stack must disappear.
- Player stations must be rounded squares surrounding the card table.
- The dealer station outline must remain the default station outline color.
- The dealer station must display a small `D` pill beside the player name before bidding starts, using the same blue color as the `Deal` button.
- The dealer pill must disappear once bidding starts while dealer identity remains testable through station metadata.
- The South station may expand below the card table after a deal because it displays the human player's full visible hand.
- The visible South hand should include a subtle tokenized ownership rail or soft baseline treatment behind the cards so the human hand reads as the player's area without becoming a separate card panel.
- A bordered `Bidding` area must appear under the South station after a deal.
- The `Bidding` area must be visually separate from the South hand and bottom controls.
- The `Bidding` area must contain a table with entries for South, East, North, and West.
- Each bid entry must begin as `--`.
- The South bid-chip selector must appear only while it is South's turn.
- The South Tarneeb suit selector must not appear during in-progress bidding; it appears only after bidding when South is the numeric high bidder and the final summary is waiting on South's suit choice.
- A `Bid` button must always be visible while bidding is in progress.
- The South `Bid` button must be positioned below the South player bid value.
- The South `Bid` button must be enabled only while it is South's turn and South has selected a valid bid value.
- The `Bidding` area may extend vertically as necessary to contain the South `Bid` button without overlap.
- The South `Bid` button must disappear completely when bidding is complete.
- The South bid chips must contain `Pass` and the currently legal numeric bids through `13`.
- North, West, and East stations must be compact and sized around their label plus hidden card array.
- The bottom controls must include `Deal` and `New Game` in both initial and dealt states.
- The bottom `Deal` and `New Game` buttons must appear in the bottom control row at the very bottom of the screen.
- The status label must appear above the bottom control row after a deal completes.
- The status label must use a compact pill treatment with tokenized fill and border opacity.
- The status label must display `Deal complete` after the deal completes and before bidding completes.
- The status label must display `Bidding complete` after the bidding round reaches a terminal state.
- When bidding completes, the `Bidding` area must fade out over one second before it is removed.
- After the `Bidding` area is removed, a post-bidding summary must appear when a numeric high bid exists.
- The post-bidding summary must display the high-bidding player, high bid value, and `Tarneeb` suit symbol.
- The post-bidding summary must be visually separate from the South hand and bottom controls.
- If all four players pass before any numeric bid is accepted, no post-bidding summary should appear and the next deal should start automatically after the terminal bidding transition.
- Tapping `New Game` must restore the launch state without immediately dealing.
- The layout must avoid overlapping labels, card faces, card backs, station bid chips, status label text, and action buttons.
- On smaller supported screens, the layout may scale spacing or use scrolling if needed, but it must preserve the North, West, South, and East relationship around the card table and keep the bid controls and bottom controls usable.

### 6.9 Bidding Behavior

After a deal completes, the implementation must display a simple bidding round based on Tarneeb legal bid values.

Bid values:

- `Pass`
- `7`
- `8`
- `9`
- `10`
- `11`
- `12`
- `13`

South bid behavior:

- The South player must see `--` until South's bidding turn becomes active.
- When South's turn becomes active, the South bid-chip selector must appear while South's table value remains pending until submission.
- When South's turn becomes active, the `Bidding` area must not show a Tarneeb suit selector.
- A `Bid` button must remain visible under the South player bid value whenever bidding is in progress.
- The `Bid` button must be disabled when South's turn is not active.
- The `Bid` button must be enabled when South's turn is active and the selected South bid can be validly submitted.
- The South bid chips must always include `Pass`.
- If no numeric bid exists, the South bid chips must offer numeric bids from `7` through `13`.
- If a current highest numeric bid exists, the South bid chips must offer numeric bids from one more than the current highest bid through `13`.
- The post-bidding South Tarneeb suit selector must offer spades, clubs, hearts, and diamonds, displayed using the corresponding suit symbols or labels, only when South is the numeric high bidder.
- If South selects `Pass`, the selected Tarneeb suit must not be required and must not be stored when `Pass` is submitted.
- If South selects a numeric bid, the South `Bid` button may submit that bid without a Tarneeb suit during in-progress bidding.
- If South selects `Pass` and taps `Bid`, South's table entry must become `Pass`.
- If South selects a numeric bid and taps `Bid`, South's table entry must become that numeric bid and the current highest bid must update to South if the bid is accepted.
- After South taps `Bid`, the South bid chips must be replaced by the selected bid value and the `Bid` button must become disabled unless bidding returns to South.
- If South remains the numeric high bidder after bidding completes, the post-bidding suit-setting panel must appear with suit chips and a `Set` button; tapping `Set` stores South's selected suit and produces the final summary.
- When bidding is complete, the `Bid` button must disappear completely rather than remain visible in a disabled state.

Simulated bid behavior:

- Simulated players must see `--` until their bidding turn resolves.
- On each simulated bidding turn, the app must evaluate that player's hand and current bidding context to produce a bid recommendation.
- If the recommendation is `Pass`, the simulated player's bid value becomes `Pass`.
- If the recommendation is a numeric bid larger than the current highest numeric bid, that number becomes the simulated player's bid value and the current highest bid is updated to that simulated player.
- If the recommendation is a numeric bid equal to or lower than the current highest numeric bid, the simulated player's bid value becomes `Pass`.
- Each simulated player bid must take at least one second to update the displayed bid value.
- Simulated bid values must consider basic card strength and partnership context, but do not need to consider score, opponent modeling, or trick-play simulation in MVP 008.
- Accepted simulated numeric bids must store the preferred trump/Tarneeb suit alongside the resolved bid value and retain confidence metadata internally so the high bidder's preferred suit can be shown in the post-bidding summary, without starting post-bidding interactive Tarneeb suit selection in MVP 008.
- Replacement deals and all-pass automatic redeals must reset all bid values to `--` before starting a fresh bidding round.

Bidding progression:

- Bidding must start with the player to the dealer's right.
- Bidding must proceed counterclockwise around the table.
- After each non-terminal bid value is resolved, bidding advances to the next counterclockwise seat that is still eligible to bid.
- A player who has passed must not be eligible to bid again in the same bidding round.
- The current highest bidder must not receive another bidding turn unless another player later outbids them.
- If a player bids `13`, all other players' bid values must be set to `Pass` and bidding must end.
- If at least one numeric bid exists, bidding must end when every player except the current highest bidder has `Pass`.
- If all four players pass before any numeric bid is accepted, bidding must end with no highest bidder.
- If all four players pass before any numeric bid is accepted, the current hand must be abandoned and a new deal must commence automatically after the terminal bidding fade.
- The dealer for an all-pass automatic redeal must be the player on the previous dealer's right, using the same counterclockwise dealer rotation order as manual replacement deals.
- The all-pass automatic redeal must create and shuffle a fresh valid 52-card deck, deal 13 cards to each player, log the new hands, and start a fresh bidding round after the deal animation completes.
- Bid value changes must use a one-second fade and color transition.
- The current highest numeric bid must remain displayed in the same yellow used for the `New Game` button.
- When a higher numeric bid is accepted, the previously highest numeric bid must transition from yellow to white while the new highest numeric bid remains yellow.
- When bidding reaches a terminal state, the `Bidding` area must fade out over one second.
- The post-bidding summary must appear only after the one-second `Bidding` area fade-out completes.
- The post-bidding summary must use the highest bidder's partnership to derive the team label.
- The post-bidding summary must use the highest bidder's preferred trump/Tarneeb suit stored alongside the accepted bid to derive the suit symbol.
- If no stored preferred Tarneeb suit exists for a numeric highest bid, the state is invalid for MVP 008 because every accepted numeric bid must store a preferred suit.
- If no numeric highest bid exists because all four players passed, the post-bidding summary must remain hidden and the automatic redeal path must run instead.

Auction limitations for MVP 008:

- The app lets South choose a Tarneeb suit while submitting a numeric South bid and displays the high bidder's preferred Tarneeb suit symbol after bidding, but does not provide editable post-bidding Tarneeb suit selection.
- The app does not proceed into trick play after bidding.

### 6.10 Automated Bid Recommendation Behavior

The automated bid recommendation behavior implements basic hand-strength bidding for simulated players. It replaces random simulated bid attempts with deterministic hand evaluation.

Recommendation input must include:

- Simulated player seat.
- Simulated player hand.
- Partner seat.
- Current highest bid value, if any.
- Current highest bidder, if any.
- Prior bid states for all four players.

The evaluator should inspect each suit as a possible future Tarneeb suit and estimate likely tricks from:

- High-card strength, especially aces and kings.
- Queen and jack support, especially when protected by higher cards or suit length.
- Candidate Tarneeb suit length.
- Candidate Tarneeb suit high cards.
- Side-suit winners outside the candidate Tarneeb suit.
- Voids and singletons in non-Tarneeb suits when paired with enough candidate Tarneeb cards.
- Conservative risk penalties to avoid overbidding weak or uncertain hands.

The evaluator must convert the estimated strength to one of:

- `Pass`, when the hand does not support a minimum bid of 7.
- A numeric bid from 7 through 13.

The evaluator should be conservative:

- Bids of 7 or 8 may come from modest but plausible strength.
- Bids of 9 through 11 should require clearly above-average strength and should be biased downward when the hand has only moderate trump depth or uncertain intermediate trump winners.
- Bids of 12 or 13 should require exceptional strength.
- The normal estimate must use a conservative baseline so an ordinary or weak hand does not reach a numeric bid mostly from baseline value.
- Candidate Tarneeb suit length bonuses must be reduced or gated when the candidate suit is missing the ace or lacks multiple protected top honors.
- A candidate Tarneeb suit missing the ace should receive a meaningful risk penalty, especially before recommending 8 or higher.
- A candidate Tarneeb suit with exactly five cards, even when it contains the ace, should not by itself justify a 10 bid unless it also has very strong supporting trump control, outside winners, and low distribution risk.
- A candidate Tarneeb suit with exactly six cards should still require stronger 10-level trump control before recommending 10; ace-queen without the king is not enough by itself, even with outside winners and a singleton.
- A candidate Tarneeb suit with exactly six cards headed by ace-jack and no king, queen, or ten should not by itself justify a 10 bid from one outside ace, one outside king, and a void; 10 or higher should require multiple outside aces, stronger side-suit winners, protected trump texture, useful short-suit shape with enough trump control, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-king but otherwise low trump cards should not by itself justify a 9 bid from only one outside ace; 9 or higher should require stronger trump texture, another outside winner, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-king-ten but missing both queen and jack should not by itself justify a 9 bid from one outside ace and one singleton alone; 9 or higher should require stronger trump texture, multiple outside aces, stronger side-suit winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-queen-ten but missing both king and jack should not by itself justify a 9 bid from one outside ace and one singleton alone; 9 or higher should require stronger trump texture, multiple outside aces, stronger side-suit winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by king-queen-ten but missing the ace should not by itself justify an 8 bid from side kings and only one outside ace; 8 or higher should require multiple outside aces, extra trump length, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king but otherwise low trump cards should not by itself justify an 11 bid from two outside aces; 11 or higher should require stronger trump texture, additional outside winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-jack-ten but missing queen should not by itself justify an 11 bid from only one outside ace and one outside king; 11 or higher should require extra trump length, the trump queen, multiple outside aces, reliable side-suit winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king, with queen and jack both absent and no reliable outside winners, should not by itself justify a 9 bid; 9 or higher should require queen or jack trump support, protected outside winners, multiple outside aces, exceptional short-suit shape, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-ten but missing queen and jack should not by itself justify a 10 bid from only one outside ace; 10 or higher should require the trump queen or jack, multiple outside aces, reliable side-suit winners, useful short-suit shape, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-queen-jack but no outside aces should not by itself justify an 11 bid from trump texture and one side king alone; 11 or higher should require an outside ace, stronger side-suit winners, extra trump length, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-king-ten should not by itself justify a 10 bid from outside honors; 10 or higher should require longer trump, queen or jack trump support, multiple outside aces, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-king-jack should not by itself justify a 9 bid from one outside ace and one outside king; 9 or higher should require extra trump length, queen or ten trump support, multiple outside aces, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-king-jack should not by itself justify a 10 bid even with two outside aces plus side king/queen honors; 10 or higher should require extra trump length, queen or ten trump support, exceptional short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-queen-jack should not by itself justify a 9 bid from one outside ace and one outside king; 9 or higher should require extra trump length, king or ten trump support, multiple outside aces, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-king and otherwise low cards should not by itself justify a 9 bid from one outside ace and side queens; 9 or higher should require extra trump length, queen, jack, or ten trump support, multiple outside aces, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-king and otherwise low cards should not by itself justify a 9 bid even with two outside aces; 9 or higher should require queen, jack, or ten trump support, extra trump length, useful short-suit shape, additional reliable side winners, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-queen but missing king, jack, and ten should not by itself justify opening at 7 when the hand has no outside aces or kings and only ordinary outside queen or low-card support; a numeric opening should require extra trump length, stronger trump texture, multiple outside winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-jack-ten but missing king and queen should not by itself justify opening at 7 when the hand has no outside aces, no void or singleton support, and only ordinary outside king or queen support; a numeric opening should require extra trump length, stronger top trump texture, outside ace support, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-jack-ten plus one low trump should not by itself justify opening at 7 when the hand has no outside aces or kings, no void or singleton support, and only ordinary outside queen/jack support; a numeric opening should require extra trump length, stronger top trump texture, outside ace or king support, useful short-suit shape, or relevant partnership context.
- A hand whose strongest candidates are only shallow three-card king-queen texture or four-card ace-jack-low texture should not by itself justify an 8 bid from two outside aces and one outside king; 8 or higher should require stronger trump length, stronger top trump texture, additional reliable outside winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed only by the ace should not by itself justify opening at 7 when the remaining trump cards are low and the hand has only one outside ace; a numeric opening should require stronger trump texture, multiple outside winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-king-queen-ten should not by itself justify a 10 bid when the hand has no outside aces; 10 or higher should require longer trump, reliable outside winners, useful short-suit shape supported by enough trump depth, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-king-queen-jack but missing ten should not by itself justify a 10 bid when the hand has no outside aces, only one outside king, and one singleton; 10 or higher should require extra trump length, the trump ten, reliable outside winners, stronger short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-king-queen but missing both jack and ten should not by itself justify a 9 bid when the hand has no outside aces; 9 or higher should require extra trump length, reliable outside winners, useful short-suit shape supported by enough trump depth, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-king-queen but missing both jack and ten should not by itself justify an 11 bid even with two outside aces; 11 or higher should require extra trump length, jack or ten trump support, additional reliable side winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-king-jack but missing both queen and ten should not by itself justify a 9 bid when the hand has only one outside ace and no void or singleton support; 9 or higher should require queen or ten trump texture, extra trump length, additional outside winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-queen but missing both jack and ten should not by itself justify a 12 bid even with two outside aces and one outside king; 12 or higher should require extra trump length, stronger trump texture, additional reliable outside winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-queen but missing both jack and ten should not by itself justify a 10 bid when the hand has no outside aces, no outside kings, and no void or singleton support; 10 or higher should require stronger trump texture, reliable outside winners, useful short-suit shape, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-queen but missing both jack and ten should not by itself justify an 11 bid when the hand has no outside aces and only one outside king plus void or singleton support; 11 or higher should require stronger trump texture, reliable outside aces, additional side winners, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-queen but missing both jack and ten should not by itself justify an 11 bid when the hand has no outside aces and only side kings as support; 11 or higher should require the trump jack or ten, reliable outside aces, stronger side-suit winners, useful short-suit shape, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-queen but missing both jack and ten should not by itself justify an 11 bid when the hand has only one outside ace and ordinary side king/queen support; 11 or higher should require the trump jack or ten, extra trump length, multiple outside aces, additional protected side winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king and otherwise low cards should not by itself justify a 10 bid when the hand has only one outside ace and ordinary side king/queen support; 10 or higher should require queen, jack, or ten trump support, multiple outside aces, additional protected side winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-jack but missing queen and ten should not by itself justify a 10 bid when the hand has no outside aces, no outside kings, and no void or singleton support; 10 or higher should require the trump queen or ten, reliable outside winners, useful short-suit shape, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king or ace-king-ten, with queen and jack both absent and no reliable outside winners, should not by itself justify a 9 bid from length, ordinary side honors, or ordinary short-suit value; 9 or higher should require queen or jack trump support, protected outside winners, multiple outside aces, exceptional short-suit shape, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by ace-king-ten but missing queen and jack should not by itself justify a 10 bid when the hand has no outside aces and only side kings as support; 10 or higher should require queen or jack trump support, reliable outside aces, stronger side-suit winners, useful short-suit shape, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by king-queen but missing ace, jack, and ten should not by itself justify a 9 bid when the hand has no outside aces and only side kings/queens plus a void; 9 or higher should require the trump ace, stronger protected trump texture, reliable outside aces, additional side winners, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly six cards headed by king-queen but missing ace, jack, and ten should not by itself justify a 9 bid when the hand has one outside ace and one outside king; 9 or higher should require the trump ace, protected jack or ten support, multiple outside aces, stronger side-suit winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by king-queen but missing ace, jack, and ten should not by itself justify an 8 bid from one outside ace, one outside king, and a singleton; 8 or higher should require extra trump length, stronger trump texture, multiple outside aces, more reliable side winners, useful short-suit shape supported by enough trump depth, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-queen-ten but missing king and jack should not by itself justify an 11 bid from three outside aces and one outside king; 11 or higher should require extra trump length, stronger trump texture, additional protected trump control, useful short-suit shape supported by enough trump depth, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards should not by itself justify a 9 bid from ace-king-ten trump texture, ace-queen trump texture, or ordinary outside ace/king support; 9 or higher should require longer trump, stronger trump texture, multiple outside aces, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-king-queen-jack but missing ten should not by itself justify a 9 bid when the hand has at most one outside ace and ordinary side honor support; 9 or higher should require longer trump, the trump ten, multiple outside aces, exceptional side certainty, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-king-jack-ten should not by itself justify an 8 bid when the hand has no outside aces and only ordinary outside king support; 8 or higher should require extra trump length, multiple outside aces, stronger side winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly four cards headed by ace-king and otherwise low cards should not by itself justify an 8 bid when the hand has no outside aces and only ordinary outside king support; 8 or higher should require extra trump length, stronger trump texture, multiple outside aces, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-jack-ten but missing king and queen should not by itself justify opening at 7 when the hand has no outside aces and only ordinary outside king or queen support; a numeric opening should require stronger trump texture, outside ace support, useful short-suit shape, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed by ace-ten but missing king, queen, and jack should not by itself justify opening at 7 when the hand has no outside aces, no void or singleton support, and only ordinary outside king or jack support; a numeric opening should require stronger trump texture, outside ace support, useful short-suit shape, extra trump length, or relevant partnership context.
- A candidate Tarneeb suit with exactly five cards headed only by the ace and missing king, queen, jack, and ten should not by itself justify an 8 bid from two outside aces and one outside king; 8 or higher should require stronger trump texture, extra trump length, useful short-suit shape supported by enough trump control, or relevant partnership context.
- A candidate Tarneeb suit with exactly seven cards headed by ace-queen-ten but missing king and jack should not by itself justify an 11 bid when the hand has no outside aces or outside kings; 11 or higher should require stronger trump texture, reliable outside winners, useful short-suit shape supported by enough trump control, or relevant partnership context.
- A candidate Tarneeb suit with exactly seven cards headed by ace-king but missing queen, jack, and ten should not by itself justify a 10 bid when the hand has no outside aces and only one outside king; 10 or higher should require queen, jack, or ten trump support, reliable outside aces, stronger side-suit winners, extra trump length, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly seven cards headed by king-queen and otherwise low cards, missing ace, jack, and ten, should not by itself justify a 9 bid when the hand has at most one outside ace and ordinary side king support; 9 or higher should require the trump ace, protected jack or ten support, multiple outside aces, additional reliable side winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly seven cards headed by ace-king-ten but missing queen and jack should not by itself justify a 12 bid when the hand has only one outside ace; 12 or higher should require queen or jack trump support, multiple outside aces, reliable side-suit winners, extra trump length, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly seven cards headed only by ace-ten and missing king, queen, and jack should not by itself justify an 11 bid when the hand has one outside ace and one outside king; 11 or higher should require protected king, queen, or jack trump support, multiple outside aces, stronger side-suit winners, extra trump length, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly seven cards headed by ace-queen but missing king, jack, and ten should not by itself justify an 11 bid from one outside ace and one singleton; 11 or higher should require stronger trump texture, multiple outside aces, reliable side winners, useful short-suit shape supported by enough trump control, or relevant partnership context.
- A candidate Tarneeb suit with exactly seven cards headed by ace-queen-jack but missing king and ten should not by itself justify an 11 bid when the hand has only one outside ace; 11 or higher should require the trump king or ten, multiple outside aces, reliable side-suit winners, extra trump length, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly eight cards headed only by the ace and missing king, queen, jack, and ten should not by itself justify a 10 bid when the hand has no outside aces; 10 or higher should require protected top trump honors, reliable outside aces, stronger side-suit winners, useful short-suit shape, or relevant partnership context.
- A candidate Tarneeb suit with exactly eight cards headed by ace-queen-jack-ten but missing king should not by itself justify a 12 bid when the hand has no outside aces or outside kings and only one singleton as support; 12 or higher should require the trump king, reliable outside winners, stronger side-suit support, useful short-suit shape backed by enough trump control, or relevant partnership context.
- A candidate Tarneeb suit with exactly eight cards headed by ace-queen-ten but missing king and jack should not by itself justify a 13 bid when the hand has only one outside ace; 13 should require near-certain trump control, multiple outside winners, or exceptional support beyond length.
- A candidate Tarneeb suit with exactly seven cards headed by ace-king-queen-jack-ten should not by itself justify a 13 bid from only two outside aces; 13 should require at least eight trump cards plus near-commanding texture.
- Side-suit aces and kings should contribute to the estimate, but their value should be discounted when they are not enough to make the full team trick commitment likely.
- Voids and singletons should receive bonus value only when the candidate Tarneeb suit has enough length and top-card control to make ruffing likely.
- A six-card candidate Tarneeb suit headed only by medium honors such as K/J/10, with no aces and no outside winners, must not produce a normal recommendation above 7.
- The hand `7♥ 6♦ 8♦ 4♠ 10♠ A♠ J♠ 10♦ A♥ K♥ 4♣ Q♠ 5♥` should be treated as a strong but not 10-safe spade candidate and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `K♣ A♦ 10♥ 10♠ 2♠ 8♣ 3♦ 6♦ Q♦ 2♦ 4♦ A♠ 4♠` should be treated as a strong but not 10-safe diamond candidate and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `3♦ 10♠ 3♥ A♦ 4♦ J♦ 4♥ A♠ 6♥ 8♦ 9♦ K♠ 7♠` should be treated as a six-card ace-jack diamond candidate with insufficient protected trump texture for 10, even with one outside ace, one outside king, and a club void, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `3♦ Q♣ 5♠ 5♣ 3♥ 7♠ 4♠ A♣ 4♦ 10♥ 2♦ K♦ A♦` should be treated as a five-card ace-king diamond candidate with insufficient extra texture for 9 and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `J♦ 5♥ A♠ K♥ Q♦ 4♠ 8♦ 10♥ 4♣ 10♦ 4♦ 6♥ A♥` should be treated as a five-card ace-king-ten heart candidate missing queen and jack, with one outside ace and one singleton as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `3♠ Q♣ J♠ 10♣ 4♣ A♣ A♦ 7♥ 7♠ 9♠ 8♣ 2♥ Q♠` should be treated as a five-card ace-queen-ten club candidate missing king and jack, with one outside ace and one singleton as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `2♣ K♦ Q♦ 10♦ K♠ 8♥ 3♦ 4♥ 7♦ 6♥ 10♣ K♣ A♠` should be treated as a five-card king-queen-ten diamond candidate missing the ace, with only one outside ace and side kings as insufficient support for 8, and should produce a balanced/default recommendation no higher than 7 with no current highest bid.
- The hand `Q♣ A♠ K♠ 6♠ 10♣ 2♠ 10♦ A♥ 7♠ 5♥ 9♣ 4♠ A♣` should be treated as a six-card ace-king spade candidate with insufficient extra texture for 11 and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `A♥ J♥ Q♦ A♠ 3♣ 8♠ 10♥ 8♦ 3♥ 10♦ 2♥ K♠ K♥` should be treated as a six-card ace-king-jack-ten heart candidate missing queen, with only one outside ace and one outside king as insufficient support for 11, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `A♥ Q♥ K♦ 2♦ 3♠ 7♥ 6♣ J♣ 7♦ 8♦ 10♦ 10♣ A♦` should be treated as a six-card ace-king-ten diamond candidate missing queen and jack, with only one outside ace as insufficient support for 10, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `J♥ 9♦ 4♥ 8♦ 4♣ K♠ A♥ Q♥ 3♦ K♥ 5♠ J♠ 3♥` should be treated as a six-card ace-king-queen-jack heart candidate with no outside aces and only one side king, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `9♠ 8♣ 10♥ 2♥ 8♠ J♣ 4♠ A♥ 4♣ K♥ K♣ A♣ K♦` should be treated as a four-card ace-king-ten heart candidate with insufficient extra trump length or texture for 10 and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `J♣ A♣ 5♦ J♦ 6♣ K♠ K♥ 9♥ 8♠ 8♦ 6♠ J♥ A♥` should be treated as a four-card ace-king-jack heart candidate with insufficient trump length and only one outside ace plus one outside king, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `A♥ A♦ K♠ 6♦ Q♥ J♣ Q♦ 4♠ 6♣ K♦ 10♥ A♣ K♣` should be treated as a four-card ace-king-jack club candidate with strong outside honors but insufficient trump length for 10, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `A♣ 5♦ K♠ 5♣ 4♥ Q♣ 2♥ J♥ A♥ 8♠ 7♣ 2♠ J♣` should be treated as a four-card ace-queen-jack club candidate with insufficient trump length and only one outside ace plus one outside king, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `6♦ Q♥ 9♠ 8♠ 10♥ 6♠ A♠ 5♦ K♠ Q♣ 7♥ 8♣ A♣` should be treated as a four-card ace-king-low spade candidate with insufficient trump texture and only one outside ace plus side queens, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `6♠ 5♥ 8♥ 9♠ 2♦ Q♥ J♣ A♦ 4♣ 4♦ A♠ A♥ K♦` should be treated as a four-card ace-king-low diamond candidate with insufficient trump texture, where two outside aces alone are insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `9♥ 2♥ Q♠ 6♠ 8♦ Q♣ 4♥ 2♣ 8♣ 6♦ 5♥ A♠ 4♠` should be treated as a four-card ace-queen-low spade candidate with no outside aces or kings and only ordinary outside queen support, and should produce a balanced/default recommendation of `Pass` with no current highest bid.
- The hand `7♥ J♣ K♠ Q♦ 7♠ 9♥ 7♦ 6♣ 10♣ A♣ 3♠ 6♠ 4♥` should be treated as a four-card ace-jack-ten club candidate missing king and queen, with no outside aces, no void or singleton support, and only ordinary outside king/queen support, and should produce a balanced/default recommendation of `Pass` with no current highest bid.
- The hand `J♣ A♣ J♠ 5♥ Q♦ 8♥ 9♦ 2♦ 5♣ J♦ 5♠ 3♠ 10♣` should be treated as a four-card ace-jack-ten club candidate missing king and queen, with no outside aces or kings, no void or singleton support, and only ordinary outside queen/jack support, and should produce a balanced/default recommendation of `Pass` with no current highest bid.
- The hand `7♥ J♦ Q♣ K♥ J♠ A♦ 6♠ 8♦ 5♣ 5♦ 8♠ A♠ Q♥` should be treated as having only shallow trump candidates: hearts as three-card king-queen texture and spades as four-card ace-jack-low texture, with two outside aces and one outside king as insufficient support for 8, and should produce a balanced/default recommendation no higher than 7 with no current highest bid.
- The hand `5♥ 10♠ 8♠ 8♣ 6♠ 6♦ 8♦ J♠ A♥ A♣ 7♠ 7♣ 3♣` should be treated as a four-card ace-low clubs candidate with insufficient trump texture and only one outside ace, and should produce a balanced/default recommendation of `Pass` with no current highest bid.
- The hand `Q♣ 10♠ Q♦ 4♣ 5♣ K♠ J♣ A♠ 5♦ K♦ Q♠ 7♠ 7♣` should be treated as a strong five-card ace-king-queen-ten spade candidate that is still not 10-safe without outside aces or extra trump length, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `Q♥ J♥ J♣ Q♦ 4♣ A♥ Q♠ K♥ 8♦ K♣ 2♥ 4♦ 9♣` should be treated as a five-card ace-king-queen-jack heart candidate missing ten, with no outside aces, only one outside king, and one singleton as insufficient support for 10, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `7♠ 8♠ Q♦ 9♦ A♥ 2♦ 9♣ Q♥ K♥ 7♣ 2♥ 9♥ 5♣` should be treated as a five-card ace-king-queen heart candidate missing jack and ten, with no outside aces and no strong side winners as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `J♠ 3♥ 6♠ J♥ 9♠ 8♦ 4♦ K♥ 9♣ 9♦ A♣ A♥ 4♥` should be treated as a five-card ace-king-jack heart candidate missing queen and ten, with only one outside ace and no void or singleton support as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `7♦ Q♦ 3♥ A♠ 5♣ K♣ K♦ 4♦ 6♠ 5♦ 10♣ A♦ A♣` should be treated as a six-card ace-king-queen diamond candidate missing jack and ten, with two outside aces and one outside king as still insufficient support for 12, and should produce a balanced/default recommendation no higher than 11 with no current highest bid.
- The hand `J♠ Q♥ 3♦ 10♠ 3♥ A♦ 6♦ J♣ Q♦ K♦ Q♣ 2♦ 10♥` should be treated as a six-card ace-king-queen diamond candidate missing jack and ten, with no outside aces, no outside kings, and no void or singleton support as insufficient support for 10, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `7♠ 10♠ 5♠ 8♦ K♣ A♦ 8♠ 2♦ 9♣ Q♦ K♦ 6♠ 5♦` should be treated as a six-card ace-king-queen diamond candidate missing jack and ten, with no outside aces and only one outside king plus a heart void as insufficient support for 11, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `A♣ 5♥ 3♣ K♣ 10♥ Q♣ K♦ 7♣ K♠ 8♣ 4♥ 5♠ 10♠` should be treated as a six-card ace-king-queen club candidate missing jack and ten, with no outside aces and only side kings as insufficient support for 11, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `5♠ 4♦ J♠ Q♦ 8♠ K♠ 3♥ 3♣ 9♣ A♠ 4♠ 10♦ J♣` should be treated as a six-card ace-king-jack spade candidate missing queen and ten, with no outside aces, no outside kings, and no short-suit support as insufficient support for 10, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `9♥ 6♦ 6♠ K♠ 4♥ 10♠ 7♦ K♦ 7♥ Q♥ 3♥ Q♦ K♥` should be treated as a six-card king-queen heart candidate missing ace, jack, and ten, with no outside aces and only side kings/queens plus a club void as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `10♥ K♠ Q♠ 7♠ K♦ 2♦ 2♠ 7♦ 6♣ 3♣ 5♦ A♣ Q♦` should be treated as a five-card king-queen diamond candidate missing ace, jack, and ten, with one outside ace, one outside king, and a singleton as insufficient support for 8, and should produce a balanced/default recommendation no higher than 7 with no current highest bid.
- The hand `5♠ A♠ A♦ 4♦ 2♥ 10♦ A♥ A♣ 9♥ K♣ 7♣ Q♦ 2♦` should be treated as a five-card ace-queen-ten diamond candidate missing king and jack, with three outside aces and one outside king as still insufficient support for 11, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `3♠ K♥ 3♦ 5♣ 8♥ A♣ 2♠ 9♣ 6♠ 10♥ 8♣ Q♣ A♥` should be treated as a short four-card candidate Tarneeb hand, with hearts as ace-king-ten texture or clubs as ace-queen texture plus outside ace/king support, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `10♣ 8♠ 5♠ 9♠ 3♥ J♣ K♦ A♣ J♥ 6♥ 4♦ J♦ K♣` should be treated as a four-card ace-king-jack-ten club candidate with no outside aces and only ordinary outside king support, and should produce a balanced/default recommendation no higher than 7 with no current highest bid.
- The hand `7♠ K♣ 9♣ 3♦ 9♠ 2♥ 4♦ 6♥ Q♥ K♥ 10♣ K♦ A♦` should be treated as a four-card ace-king diamond candidate with low remaining trump cards, no outside aces, and only ordinary outside king support, and should produce a balanced/default recommendation no higher than 7 with no current highest bid.
- The hand `A♦ 10♦ 2♣ Q♣ J♦ 9♥ Q♠ 4♥ 7♦ K♥ 9♦ 5♣ K♠` should be treated as a five-card ace-jack-ten diamond candidate missing king and queen, with no outside aces and only ordinary outside king or queen support, and should produce a balanced/default recommendation of `Pass` with no current highest bid.
- The hand `9♠ 6♥ 10♠ 8♥ 8♣ J♦ J♣ 7♦ K♣ K♦ 3♠ A♠ 7♠` should be treated as a five-card ace-ten spade candidate missing king, queen, and jack, with no outside aces, no void or singleton support, and only ordinary outside king or jack support, and should produce a balanced/default recommendation of `Pass` with no current highest bid.
- The hand `A♣ 6♥ 5♥ 8♥ 3♠ 4♦ 3♣ 4♠ A♦ 6♦ A♥ 4♥ K♣` should be treated as a five-card ace-low heart candidate missing king, queen, jack, and ten, with two outside aces and one outside king as insufficient support for 8, and should produce a balanced/default recommendation no higher than 7 with no current highest bid.
- The hand `2♦ 5♠ Q♦ A♦ 8♦ 10♦ 6♠ 2♠ 10♥ 2♥ 3♦ 4♦ 9♥` should be treated as a seven-card ace-queen-ten diamond candidate missing king and jack, with no outside aces or outside kings as insufficient support for 11, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `4♥ 10♦ 3♦ Q♣ 6♦ K♦ 5♦ A♦ 7♣ 7♠ 6♣ A♣ 8♦` should be treated as a seven-card ace-king-ten diamond candidate missing queen and jack, with only one outside ace as insufficient support for 12, and should produce a balanced/default recommendation no higher than 11 with no current highest bid.
- The hand `A♠ 7♠ A♣ 4♣ 3♠ 5♠ 9♠ 7♥ 4♥ J♦ Q♠ 4♠ 3♥` should be treated as a seven-card ace-queen spade candidate missing king, jack, and ten, with only one outside ace and one singleton as insufficient support for 11, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `A♦ 2♦ 4♦ A♣ 2♥ 8♦ 7♦ 6♦ 7♥ 8♠ J♦ 4♠ 4♥` should be treated as a seven-card ace-jack-low diamond candidate missing king, queen, and ten, with only one outside ace as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `7♦ 4♥ 7♥ 9♦ 5♥ Q♦ 2♥ J♦ 6♦ A♦ 2♦ 10♦ 5♠` should be treated as an eight-card ace-queen-jack-ten diamond candidate missing king, with no outside aces or outside kings and only one singleton as insufficient support for 12, and should produce a balanced/default recommendation no higher than 11 with no current highest bid.
- The hand `K♣ 6♣ 2♣ 10♥ 3♥ A♠ 7♣ 8♣ K♥ 5♦ J♥ Q♠ Q♣` should be treated as a six-card king-queen club candidate missing ace, jack, and ten, with one outside ace and one outside king as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `A♣ K♥ 10♣ 5♥ Q♠ 3♦ 2♥ 6♠ 7♠ 10♥ Q♥ J♥ K♠` should be treated as a six-card king-queen-jack-ten heart candidate missing the trump ace, with one outside ace and ordinary side support as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `9♦ J♦ 3♥ 3♦ 2♣ J♠ A♠ J♥ 5♦ K♠ Q♦ Q♠ K♦` should be treated as a six-card king-queen-jack diamond candidate missing the trump ace, with one outside ace and ordinary side support as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `Q♣ 5♥ A♠ K♠ 3♣ Q♦ 8♦ J♣ 7♠ K♣ 2♦ 10♣ 7♣` should be treated as a six-card king-queen-jack-ten club candidate missing the trump ace, with one outside ace and ordinary side support as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `A♣ 7♦ 3♣ 10♠ 4♠ 9♠ K♠ 3♠ K♣ Q♣ 9♣ Q♠ K♦` should be treated as a six-card king-queen-ten spade candidate missing the trump ace, with one outside ace and ordinary side support as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `Q♦ K♦ J♦ 5♣ 5♥ 2♥ 8♦ K♠ 10♦ K♣ Q♥ A♥ 3♦` should be treated as a six-card king-queen-jack-ten diamond candidate missing the trump ace, with one outside ace and ordinary side support as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `3♥ A♦ 9♦ J♠ K♦ 7♥ 6♦ 9♣ Q♥ 8♣ J♥ K♥ 10♥` should be treated as a six-card king-queen-jack-ten heart candidate missing the trump ace, with one outside ace and ordinary side support as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.
- The hand `A♣ A♥ K♦ 4♦ J♦ 4♣ Q♦ 7♦ 8♠ 8♥ Q♥ A♦ 10♦` should be treated as a seven-card ace-king-queen-jack-ten diamond candidate with two outside aces as insufficient support for 13, and should produce a balanced/default recommendation no higher than 12 with no current highest bid.
- The hand `Q♥ J♠ 2♦ Q♦ A♦ A♣ A♥ 9♦ 3♥ K♥ 7♦ Q♠ 9♥` should be treated as a five-card ace-king-queen heart candidate missing jack and ten, with two outside aces as insufficient support for 11, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `8♠ 6♠ 2♠ 4♦ 5♠ 4♠ 5♥ 9♠ 3♦ A♠ K♦ 5♣ 3♠` should be treated as an eight-card ace-low spade candidate missing king, queen, jack, and ten, with no outside aces and only one outside king as insufficient support for 10, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `A♥ 10♦ 3♥ 6♥ 8♠ K♠ 2♥ 10♣ 8♦ K♥ 9♥ 9♣ 4♥` should be treated as a seven-card ace-king heart candidate missing queen, jack, and ten, with no outside aces and only one outside king as insufficient support for 10, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `8♥ 6♣ A♥ K♦ 4♣ 10♣ 3♥ 7♣ 3♣ 9♣ 6♥ Q♦ A♣` should be treated as a seven-card ace-ten club candidate missing king, queen, and jack, with one outside ace and one outside king as insufficient support for 11, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `4♦ K♠ 6♥ J♠ 10♦ K♦ A♦ K♣ 8♦ 8♣ 4♣ 8♠ 5♦` should be treated as a six-card ace-king-ten diamond candidate missing queen and jack, with no outside aces and only side kings as insufficient support for 10, and should produce a balanced/default recommendation no higher than 9 with no current highest bid.
- The hand `4♥ 3♠ Q♥ 8♥ 3♣ 9♥ A♥ 5♣ J♥ A♠ 8♦ 5♦ 3♥` should be treated as a seven-card ace-queen-jack heart candidate missing king and ten, with one outside ace as insufficient support for 11, and should produce a balanced/default recommendation no higher than 10 with no current highest bid.
- The hand `4♥ 2♠ Q♠ 7♦ 3♥ 7♠ A♠ Q♥ 8♥ 7♥ 10♥ 2♥ A♥` should be treated as an eight-card ace-queen-ten heart candidate missing king and jack, with one outside ace as insufficient support for 13, and should produce a balanced/default recommendation no higher than 11 with no current highest bid.
- The hand `4♣ Q♥ A♦ 7♣ K♥ K♠ Q♦ 10♦ J♠ A♥ K♦ 6♣ 10♠` should be treated as a four-card ace-king-queen-ten diamond candidate missing jack, with only one outside ace and ordinary side honor support as insufficient support for 9, and should produce a balanced/default recommendation no higher than 8 with no current highest bid.

Partner context rules:

- If the simulated player's partner is currently the highest bidder, the evaluator should recommend `Pass` by default.
- The evaluator may recommend raising a partner only when the simulated player's own preferred Tarneeb suit and hand strength show clearly stronger trump potential than the partner's current commitment requires.
- Raising a partner should require the adjusted recommendation to be at least two tricks above the current highest bid and should require strong independent trump control in the simulated player's preferred suit.
- The evaluator must not raise a partner from marginal extra side winners, suit length alone, or a recommendation that only barely exceeds the partner's current high bid.
- The bidding service must re-apply the partner-raise threshold before accepting a simulated numeric bid so injected overrides, stale recommendations, or deterministic test recommenders cannot bypass the partner-awareness rule.

Recommendation output must include:

- Recommended bid value.
- Preferred Tarneeb suit for numeric recommendations.
- Empty preferred Tarneeb suit for `Pass`.
- Confidence from 0 through 1.

The bidding service must still enforce the legal bidding rules after receiving a recommendation. A numeric recommendation that is not higher than the current highest bid resolves to `Pass`, a simulated numeric recommendation that fails the partner-raise threshold resolves to `Pass`, and a previously passed player must not be offered another turn.

The preferred suit metadata must be stored alongside accepted simulated numeric bids. If South makes the winning numeric bid, the app must store South's explicitly selected Tarneeb suit with South's accepted bid after the post-bidding `Set` action and before showing the final summary. Bid states that resolve to `Pass` must not retain a preferred suit.

Bidding implementation Phase 3 must add simulated-player personality on top of the normal estimate:

- The normal estimate is the baseline likely-tricks value produced by the existing hand-strength evaluator before personality and legal-bid filtering.
- Each simulated seat must have a bidding personality profile available to the bid recommender.
- A balanced personality should use the normal estimate without intentional upward or downward bias.
- A conservative personality should tend to round down, pass marginal hands, or require stronger evidence before raising.
- An aggressive personality should be allowed to round up or take marginal numeric bids more often, but only within the legal 7 through 13 range.
- Personality may affect bid threshold, rounding, and confidence, but must not change the preferred suit candidate selected by the hand evaluator unless the underlying normal estimates are tied.
- Personality adjustments must be deterministic or injectable so automated tests can assert the recommendation for a given hand, context, and personality.
- The bidding service must continue to enforce all legal bidding rules after personality is applied.

## 7. UI Requirements

### 7.1 Initial Screen

The initial screen must include:

- Portrait orientation only.
- A circular card table centered in the main table area.
- A card table diameter equal to half the screen width.
- App title `طرنيب` centered on the card table.
- Exactly one randomly selected dealer.
- A small `D` pill beside the selected dealer's player name, using the same blue color as the `Deal` button and white `D` text.
- Default station outlines for non-dealer player stations.
- A squared stack of 52 hidden cards inside the selected dealer's player station, with a buffer from the station edge.
- Four rounded-square player station labels surrounding the card table.
- North above the table, West left of the table, South below the table, and East right of the table.
- Bottom control row with reset button `New Game` and primary button `Deal`.
- No visible dealt player hands before the first deal.
- No visible `Bidding` area before the first deal.
- No `Deal Cards` or `New Deal` action labels.

### 7.2 Dealt Table Screen

After dealing, the screen must include:

- Portrait orientation only.
- The circular card table and surrounding player stations.
- No undealt 52-card deck stack.
- South human player station expanded below the card table with 13 visible cards.
- A bordered `Bidding` area under the South player station.
- A `Bidding` label inside or attached to the bordered bidding area.
- Station bid chips showing South, East, North, and West bid/pass state.
- Station bid values initialized as `--`.
- South bid chips containing `Pass` and the currently legal numeric bids through `13` only while it is South's turn.
- A post-bidding South Tarneeb suit selector containing `♠`, `♣`, `♥`, and `♦` only when South is the numeric high bidder and no final summary has been produced yet.
- A South `Bid` button positioned below the South player bid value.
- The South `Bid` button visible in a disabled state when it is not South's turn and bidding is still in progress.
- The South `Bid` button enabled only while it is South's turn and South has selected a valid bid value.
- No South `Bid` button after bidding is complete.
- Simulated bid values resolved turn-by-turn from automated hand-strength recommendations that become either `Pass` or a numeric bid higher than the current highest bid.
- At least one second before each simulated player bid value updates.
- A one-second fade and color transition when any player's bid value changes.
- The current highest numeric bid displayed in the same yellow used for the `New Game` button, with any superseded previous high bid transitioning from yellow to white when a higher numeric bid is accepted.
- A one-second fade-out transition that hides the full `Bidding` area when bidding completes.
- A post-bidding summary displayed after the `Bidding` area fade-out completes when a numeric high bid exists.
- The post-bidding summary displays the actual high-bidding player, the high bid value, and a `Tarneeb` label with `♠`, `♣`, `♥`, or `♦` in a compact white chip using the proper black/red suit color.
- If South is the highest bidder, the post-bidding summary appears only after South selects a Tarneeb suit and taps `Set`.
- No post-bidding summary when all four players pass before any numeric bid is accepted; instead, a fresh deal starts automatically with the dealer advanced counterclockwise.
- West, North, and East simulated players with 13 hidden card backs each.
- All player station outlines remain the default station outline color.
- The pre-bidding dealer pill is hidden while bidding is active; the current dealer remains available through station metadata until the next deal request advances the dealer.
- Red rank and suit styling for Hearts and Diamonds.
- Dark rank and suit styling for Clubs and Spades.
- Exposed and hidden cards using the same base size and standard-card aspect ratio.
- Compact West, North, and East stations.
- Status label above the bottom control row, displaying `Deal complete` until bidding completes and `Bidding complete` after bidding completes.
- Bottom buttons labeled `New Game` and `Deal`.
- No `Deal Cards` or `New Deal` action labels.

### 7.3 Prohibited MVP UI

The MVP must not show:

- Interactive Trump/Tarneeb suit selectors except South's post-bidding suit-setting panel when South has the numeric high bid.
- Play-card controls.
- Trick area.
- Scoreboard.
- Game-over state.
- Landscape-only layout.

## 8. Non-Functional Requirements

### NFR-001: Platform

- The app must target iOS.
- The app must be locked to portrait orientation for MVP 008.
- SwiftUI is recommended unless the implementation plan specifies otherwise.

### NFR-002: Responsiveness

- The deal should complete responsively while preserving the specified 1.5-second South reveal flip.
- The UI must remain responsive after dealing.
- Visual layout and card sizing changes must not introduce noticeable blocking during deal, replacement deal, or reset actions.

### NFR-003: Testability

- Deck creation, shuffle preservation of uniqueness, player setup, and dealing must be testable independently of the UI.
- The card dealing logic should be isolated from SwiftUI views.
- The automated bid recommendation logic should be isolated from SwiftUI views.
- Card presentation mapping for suit color should be testable independently where practical.
- Layout-critical UI elements should have stable accessibility identifiers or labels so UI tests can verify visibility and interaction.
- The initial 52-card deck stack should be exposed in a way that UI tests can verify its presence before a deal, dealer-station placement, squared-stack geometry appearance, station-edge buffer, and absence after a deal.
- Dealer selection, dealer rotation, dealer pill visibility, and dealer metadata should be testable independently of SwiftUI where practical.
- Bid recommendation generation, allowed bid values, bidding turn order, highest-bid tracking, South bid selection state, post-bidding South Tarneeb suit selection state, and bidding completion rules should be testable independently of SwiftUI where practical.
- Bid recommendation diagnostics should be testable independently of SwiftUI, including per-suit `expectedTricks`, `safeBidCeiling`, selected preferred suit, side-winner treatment, high-bid gate results, partner-raise filtering, and final legal recommendation.
- Automated multi-deal bidding simulation should be deterministic when supplied with an injected random source or seed and should produce a report suitable for tuning bid distribution and finding suspect aggressive or conservative bids.
- Post-bidding summary derivation should be testable independently of SwiftUI where practical.
- Deal hand console logging should use a replaceable or injectable logging destination so tests can capture logged hands without reading the Xcode console.
- The bottom `Deal`, `New Game`, `Deal complete`, and `Bidding complete` controls or labels should be exposed in a way that UI tests can verify their relative placement and reset behavior.
- The `Bidding` area, station bid chips, South bid chips, post-bidding South Tarneeb suit selector, South `Bid` button, and post-bidding `Set` button should be exposed in a way that UI tests can verify visibility, allowed values, enabled/disabled active-turn behavior, selected bid and suit updates, simulated-bid timing, fade/color timing, terminal fade-out, and terminal button disappearance.
- The post-bidding summary should be exposed in a way that UI tests can verify the high-bidding player, bid value, and Tarneeb suit symbol.
- South reveal state should be exposed in a way that UI tests can verify South card faces remain hidden until all four hands are dealt, South's received stack remains visible as fanned card backs before final reveal, South backs appear before faces, the reveal proceeds left-to-right over 1.5 seconds, and `Deal complete`/`Bidding` wait until the reveal finishes.

### NFR-004: Reliability

- The app must never produce duplicate cards in a completed deal.
- The app must never produce fewer or more than 13 cards per player in a completed deal.
- The app must never include jokers.
- The app must never show an invalid completed bid value outside `Pass` and 7 through 13.
- The app may show `--` only for pending bid entries before that player's bid value resolves.
- South numeric bid submission may commit during bidding without a selected Tarneeb suit, but South's final high-bid summary must never appear until South has selected and set a Tarneeb suit.
- South `Pass` submission must never store a preferred Tarneeb suit.
- A post-bidding summary with a high-bidding player must never appear unless a numeric high bid exists.
- A post-bidding summary must never display a Tarneeb symbol outside `♠`, `♣`, `♥`, and `♦`.

### NFR-005: Visual Usability

- Red suits and black/dark suits must be visually distinguishable.
- Exposed card ranks and suits must be readable on supported device sizes.
- Hidden card backs must be large enough to resemble cards rather than unreadable icons.
- Required UI must remain usable on at least one small-screen simulator supported by the project.
- The central table, dealer-station squared deck stack, rounded-square stations, dealer pill, `Bidding` area, post-bidding summary, South `Bid` button, bottom controls, and status label must not overlap incoherently.

## 9. Edge Cases and Constraints

- If a replacement deal is requested after a completed deal, the previous hands must be cleared before the replacement deal is shown.
- If a replacement deal is requested after a completed deal, the previous bid values and any post-bidding summary must be cleared and replaced with a fresh post-deal bidding round initialized to `--` when the replacement deal completes.
- If `New Game` is requested after a completed deal, the previous hands, bid values, and post-bidding summary must be cleared, the game phase must return to `notStarted`, any status label text such as `Deal complete` or `Bidding complete` must be hidden, the `Bidding` area must be hidden, a dealer must be selected for the new game, the dealer pill must appear beside the selected dealer's name, and the squared undealt deck stack must reappear inside the selected dealer's player station.
- If `New Game` is requested from the initial screen, the app should remain in `notStarted` and should not start a deal.
- If the app is in the initial `notStarted` state, the `Bidding` area must not be visible.
- If random dealer selection is performed, the selected dealer must always be one of South, East, North, or West.
- If automated bid recommendation is performed, every recommendation must be either `Pass` or a number from 7 through 13.
- If automated bid recommendation is performed, each suit's `expectedTricks` and `safeBidCeiling` must be computed independently before choosing a preferred Tarneeb suit.
- If a candidate suit's optimistic `expectedTricks` is higher than its `safeBidCeiling`, the recommendation must not exceed the `safeBidCeiling`.
- If no candidate suit reaches a `safeBidCeiling` of 7, the recommendation must be `Pass` even when side honors or length make the raw estimate look playable.
- If a candidate suit fails the 9+, 10+, 11+, 12+, or 13 structural gate, the recommendation must be capped below that level rather than patched by a hand-specific exception.
- If side kings or queens are unprotected, isolated, or likely to lose to aces or trumping, they must not be counted as sure winners.
- If a void or singleton is present but candidate trump control is weak or shallow, short-suit shape must not inflate the `safeBidCeiling` to a high bid.
- If an exact regression hand is added to the requirements, the fix must be expressed as a generalized trump-quality, outside-winner, short-suit, partnership, or high-bid-gate rule rather than a direct exact-hand lookup.
- If automated bid recommendation is performed for a weak long-suit hand with no aces and no outside winners, the normal/balanced evaluator must not inflate the bid above 7 from suit length alone.
- If automated bid recommendation is performed for a strong but not 10-safe five-card trump hand with moderate trump depth, the normal/balanced evaluator should not inflate the recommendation to 10 from side winners and a singleton alone.
- If automated bid recommendation is performed for any exactly five-card candidate trump suit, the normal/balanced evaluator should not allow a 10-level bid unless the candidate has at least three top trump controls, at least three reliable outside winners, or exceptional partnership context; two top trump controls plus two outside aces must remain capped below 10.
- If automated bid recommendation is performed for a strong but not 10-safe six-card trump hand with ace-queen trump support but no king, the normal/balanced evaluator should not inflate the recommendation to 10 from length, outside winners, and a singleton alone.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-jack without king, queen, or ten support, with one outside ace, one outside king, and a void, the normal/balanced evaluator should not inflate the recommendation to 10 without multiple outside aces, stronger side-suit winners, protected trump texture, useful short-suit shape with enough trump control, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king with only low remaining trump cards and a single outside ace, the normal/balanced evaluator should not inflate the recommendation to 9 without stronger supporting trump texture, another outside winner, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-ten but missing queen and jack, with one outside ace and one singleton, the normal/balanced evaluator should not inflate the recommendation to 9 without stronger trump texture, multiple outside aces, stronger side-suit winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-queen-ten but missing king and jack, with one outside ace and one singleton, the normal/balanced evaluator should not inflate the recommendation to 9 without stronger trump texture, multiple outside aces, stronger side-suit winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by king-queen-ten but missing the ace, with only one outside ace and side kings, the normal/balanced evaluator should not inflate the recommendation to 8 without multiple outside aces, extra trump length, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king with only low remaining trump cards and two outside aces, the normal/balanced evaluator should not inflate the recommendation to 11 without stronger supporting trump texture, additional outside winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king, with queen and jack both absent and no reliable outside winners, the normal/balanced evaluator should not inflate the recommendation to 9 without queen or jack trump support, protected outside winners, multiple outside aces, exceptional short-suit shape, extra trump length, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-ten but missing queen and jack, with only one outside ace, the normal/balanced evaluator should not inflate the recommendation to 10 without the trump queen or jack, multiple outside aces, reliable side-suit winners, useful short-suit shape, extra trump length, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-queen-jack with no outside aces and only one side king, the normal/balanced evaluator should not inflate the recommendation to 11 without an outside ace, stronger side-suit winners, extra trump length, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king-ten with outside honors but no extra trump length or queen/jack trump support, the normal/balanced evaluator should not inflate the recommendation to 10 without longer trump, stronger trump texture, multiple outside aces, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king-jack with only one outside ace and one outside king, the normal/balanced evaluator should not inflate the recommendation to 9 without extra trump length, queen or ten trump support, multiple outside aces, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king-jack with two outside aces plus side king/queen honors, the normal/balanced evaluator should not inflate the recommendation to 10 without extra trump length, queen or ten trump support, exceptional short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-queen-jack with only one outside ace and one outside king, the normal/balanced evaluator should not inflate the recommendation to 9 without extra trump length, king or ten trump support, multiple outside aces, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king with low remaining trump cards, one outside ace, and side queens, the normal/balanced evaluator should not inflate the recommendation to 9 without extra trump length, queen, jack, or ten trump support, multiple outside aces, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king with low remaining trump cards and two outside aces, the normal/balanced evaluator should not inflate the recommendation to 9 without queen, jack, or ten trump support, extra trump length, useful short-suit shape, additional reliable side winners, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-queen but missing king, jack, and ten, with no outside aces or kings and only ordinary outside queen or low-card support, the normal/balanced evaluator should not open at 7 without extra trump length, stronger trump texture, multiple outside winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-jack-ten but missing king and queen, with no outside aces, no void or singleton support, and only ordinary outside king or queen support, the normal/balanced evaluator should not open at 7 without extra trump length, stronger top trump texture, outside ace support, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-jack-ten plus one low trump, with no outside aces or kings, no void or singleton support, and only ordinary outside queen/jack support, the normal/balanced evaluator should not open at 7 without extra trump length, stronger top trump texture, outside ace or king support, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a hand whose strongest candidates are only shallow three-card king-queen texture or four-card ace-jack-low texture, with two outside aces and one outside king, the normal/balanced evaluator should not inflate the recommendation to 8 without stronger trump length, stronger top trump texture, additional reliable outside winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed only by the ace with low remaining trump cards and only one outside ace, the normal/balanced evaluator should not open at 7 without stronger trump texture, multiple outside winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-queen-ten with no outside aces, the normal/balanced evaluator should not inflate the recommendation to 10 without extra trump length, reliable outside winners, useful short-suit shape supported by enough trump depth, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-queen-jack but missing ten, with no outside aces, only one outside king, and one singleton, the normal/balanced evaluator should not inflate the recommendation to 10 without extra trump length, the trump ten, reliable outside winners, stronger short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-queen but missing jack and ten, with no outside aces, the normal/balanced evaluator should not inflate the recommendation to 9 without extra trump length, reliable outside winners, useful short-suit shape supported by enough trump depth, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-queen but missing jack and ten, with two outside aces, the normal/balanced evaluator should not inflate the recommendation to 11 without extra trump length, jack or ten trump support, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-jack but missing queen and ten, with only one outside ace and no void or singleton support, the normal/balanced evaluator should not inflate the recommendation to 9 without queen or ten trump texture, extra trump length, additional outside winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-queen but missing jack and ten, with two outside aces and one outside king, the normal/balanced evaluator should not inflate the recommendation to 12 without extra trump length, stronger trump texture, additional reliable outside winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-queen but missing jack and ten, with no outside aces, no outside kings, and no void or singleton support, the normal/balanced evaluator should not inflate the recommendation to 10 without stronger trump texture, reliable outside winners, useful short-suit shape, extra trump length, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-queen but missing jack and ten, with no outside aces and only one outside king plus void or singleton support, the normal/balanced evaluator should not inflate the recommendation to 11 without stronger trump texture, reliable outside aces, additional side winners, extra trump length, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-queen but missing jack and ten, with no outside aces and only side kings as support, the normal/balanced evaluator should not inflate the recommendation to 11 without the trump jack or ten, reliable outside aces, stronger side-suit winners, useful short-suit shape, extra trump length, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-ten but missing queen and jack, with no outside aces and only side kings as support, the normal/balanced evaluator should not inflate the recommendation to 10 without queen or jack trump support, reliable outside aces, stronger side-suit winners, useful short-suit shape, extra trump length, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king or ace-king-ten, with queen and jack both absent and no reliable outside winners, the normal/balanced evaluator should not inflate the recommendation to 9 from length, ordinary side honors, or ordinary short-suit value.
- If automated bid recommendation is performed for a six-card trump hand headed by king-queen but missing ace, jack, and ten, with no outside aces and only side kings/queens plus a void as support, the normal/balanced evaluator should not inflate the recommendation to 9 without the trump ace, stronger protected trump texture, reliable outside aces, additional side winners, extra trump length, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by king-queen but missing ace, jack, and ten, with one outside ace and one outside king, the normal/balanced evaluator should not inflate the recommendation to 9 without the trump ace, protected jack or ten support, multiple outside aces, stronger side-suit winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand missing the trump ace and headed by king-queen with optional jack or ten texture, with at most one outside ace and ordinary side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 9 without the trump ace, extra trump length, multiple outside aces, stronger protected side winners, useful short-suit shape backed by enough trump control, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by king-queen but missing ace, jack, and ten, with one outside ace, one outside king, and one singleton, the normal/balanced evaluator should not inflate the recommendation to 8 without extra trump length, stronger trump texture, multiple outside aces, more reliable side winners, useful short-suit shape supported by enough trump depth, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-queen-ten but missing king and jack, with three outside aces and one outside king, the normal/balanced evaluator should not inflate the recommendation to 11 without extra trump length, stronger trump texture, additional protected trump control, useful short-suit shape supported by enough trump depth, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand with ace-king-ten texture, ace-queen texture, or ordinary outside ace/king support, the normal/balanced evaluator should not inflate the recommendation to 9 without extra trump length, stronger trump texture, multiple outside aces, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king-jack-ten with no outside aces and only ordinary outside king support, the normal/balanced evaluator should not inflate the recommendation to 8 without extra trump length, multiple outside aces, stronger side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king with low remaining trump cards, no outside aces, and only ordinary outside king support, the normal/balanced evaluator should not inflate the recommendation to 8 without extra trump length, stronger trump texture, multiple outside aces, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-jack-ten but missing king and queen, with no outside aces and only ordinary outside king or queen support, the normal/balanced evaluator should not open at 7 without stronger trump texture, outside ace support, useful short-suit shape, extra trump length, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-ten but missing king, queen, and jack, with no outside aces, no void or singleton support, and only ordinary outside king or jack support, the normal/balanced evaluator should not open at 7 without stronger trump texture, outside ace support, useful short-suit shape, extra trump length, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed only by the ace and missing king, queen, jack, and ten, with two outside aces and one outside king, the normal/balanced evaluator should not inflate the recommendation to 8 without stronger trump texture, extra trump length, useful short-suit shape supported by enough trump control, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-queen-ten but missing king and jack, with no outside aces or outside kings, the normal/balanced evaluator should not inflate the recommendation to 11 without stronger trump texture, reliable outside winners, useful short-suit shape supported by enough trump control, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-king but missing queen, jack, and ten, with no outside aces and only one outside king, the normal/balanced evaluator should not inflate the recommendation to 10 without queen, jack, or ten trump support, reliable outside aces, stronger side-suit winners, extra trump length, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-king-ten but missing queen and jack, with only one outside ace, the normal/balanced evaluator should not inflate the recommendation to 12 without queen or jack trump support, multiple outside aces, reliable side-suit winners, extra trump length, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed only by ace-ten and missing king, queen, and jack, with one outside ace and one outside king, the normal/balanced evaluator should not inflate the recommendation to 11 without protected king, queen, or jack trump support, multiple outside aces, stronger side-suit winners, extra trump length, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-queen but missing king, jack, and ten, with only one outside ace and one singleton, the normal/balanced evaluator should not inflate the recommendation to 11 without stronger trump texture, multiple outside aces, reliable side winners, useful short-suit shape supported by enough trump control, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-queen-jack but missing king and ten, with only one outside ace, the normal/balanced evaluator should not inflate the recommendation to 11 without the trump king or ten, multiple outside aces, reliable side-suit winners, extra trump length, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for an eight-card trump hand headed only by the ace and missing king, queen, jack, and ten, with no outside aces, the normal/balanced evaluator should not inflate the recommendation to 10 without protected top trump honors, reliable outside aces, stronger side-suit winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for an eight-card trump hand headed by ace-queen-jack-ten but missing king, with no outside aces or outside kings and only one singleton as support, the normal/balanced evaluator should not inflate the recommendation to 12 without the trump king, reliable outside winners, stronger side-suit support, useful short-suit shape backed by enough trump control, or partnership context.
- If automated bid recommendation is performed for an eight-card trump hand headed by ace-queen-ten but missing king and jack, with only one outside ace, the normal/balanced evaluator should not inflate the recommendation to 13 without near-certain trump control, multiple outside winners, or exceptional support beyond length.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-king-queen-jack-ten, with two outside aces, the normal/balanced evaluator should not inflate the recommendation to 13 because 13 requires at least eight trump cards plus near-commanding texture.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-king-ten but missing queen and jack, with no outside aces and only side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 11 without stronger trump texture, reliable outside aces, stronger side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-king-ten but missing queen and jack, with no outside aces and only side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 12 from a side-suit void alone without stronger trump texture, reliable outside aces, stronger side winners, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king with only low remaining trump cards, no outside aces, and no outside kings, the normal/balanced evaluator should not inflate the recommendation to 10 from short-suit shape alone without stronger trump texture, reliable outside winners, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-jack but missing queen and ten, with only one outside ace and no outside king support, the normal/balanced evaluator should not inflate the recommendation to 10 without the trump queen or ten, multiple outside aces, reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by king-queen-jack-ten but missing ace, with no outside aces and only ordinary side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 10 without the trump ace, stronger protected trump texture, reliable outside aces, additional side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king with only low remaining trump cards, two outside aces, and one outside king, the normal/balanced evaluator should not inflate the recommendation to 10 without queen, jack, or ten trump support, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-king-queen but missing jack and ten, with no outside aces and no outside kings, the normal/balanced evaluator should not inflate the recommendation to 11 without stronger trump texture, reliable outside winners, useful short-suit shape, extra trump length, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king with only low remaining trump cards, one outside ace, and ordinary side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 10 without queen, jack, or ten trump support, multiple outside aces, additional protected side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-king-queen-jack but missing ten, with no outside aces and only one outside king, the normal/balanced evaluator should not inflate the recommendation to 12 without the trump ten, reliable outside aces, additional side winners, stronger short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-king-jack but missing queen and ten, with no outside aces and only side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 11 without queen or ten trump support, reliable outside aces, additional side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-jack-ten but missing queen, with no outside aces and only one outside king, the normal/balanced evaluator should not inflate the recommendation to 11 without the trump queen, reliable outside aces, additional side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by king-queen-ten but missing ace and jack, even with two outside aces, the normal/balanced evaluator should not inflate the recommendation to 9 without the trump ace or jack, extra trump length, multiple reliable side winners beyond aces, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-queen with low remaining trump cards and only one outside ace, the normal/balanced evaluator should not inflate the recommendation to 10 without jack or ten trump support, extra trump length, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for an eight-card trump hand headed by ace-queen-jack-ten but missing king, with only one outside ace and no outside kings, the normal/balanced evaluator should not inflate the recommendation to 13 without the trump king, multiple outside aces, reliable side winners, near-certain trump control, or exceptional partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-queen with low remaining trump cards and missing king, jack, and ten, two outside aces and side kings should not inflate the recommendation to 10 without stronger trump texture, extra trump length, exceptional short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by a lone ace with low remaining trump cards, three outside aces should not inflate the recommendation to 9 without stronger trump texture, extra trump length, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by king-queen-jack but missing ace and ten, with only one outside ace and one outside king, the normal/balanced evaluator should not inflate the recommendation to 9 without the trump ace or ten, extra trump length, multiple outside aces, stronger side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king-jack but missing queen and ten, with no outside aces and only one outside king, the normal/balanced evaluator should not inflate the recommendation to 8 without extra trump length, the trump queen or ten, reliable outside aces, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for an eight-card trump hand headed by ace-jack-ten but missing king and queen, with no outside aces or outside kings, the normal/balanced evaluator should not inflate the recommendation to 11 without protected king or queen trump support, reliable outside winners, stronger side-suit support, useful short-suit shape backed by enough trump control, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king-queen-ten, with no outside aces and only one outside king, the normal/balanced evaluator should not inflate the recommendation to 8 without extra trump length, multiple outside aces, exceptional short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king-queen-ten but missing jack, with at most one outside ace and ordinary side honor support, the normal/balanced evaluator should not inflate the recommendation to 9 without extra trump length, the trump jack, multiple outside aces, exceptional side certainty, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-queen-jack but missing king and ten, even with two outside aces, the normal/balanced evaluator should not inflate the recommendation to 10 without extra trump length, the trump king or ten, additional protected side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-jack-ten but missing king and queen, with no outside aces and only one outside king, the normal/balanced evaluator should not inflate the recommendation to 10 without protected king or queen trump support, reliable outside aces, stronger side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-jack but missing king, queen, and ten, with at most one outside ace, the normal/balanced evaluator should not inflate the recommendation to 9 without protected king/queen trump texture, multiple reliable outside winners, useful short-suit shape backed by enough trump control, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-king-queen but missing jack and ten, with at most one outside ace even when ordinary outside king support is present, the normal/balanced evaluator should not inflate the recommendation to 12 without the trump jack or ten, extra trump length, multiple reliable outside winners, useful short-suit shape backed by enough trump control, or exceptional partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by king-queen-jack-ten but missing ace, even with two outside aces, the normal/balanced evaluator should not inflate the recommendation to 9 without the trump ace, extra trump length, multiple reliable side winners beyond aces, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-jack but missing queen and ten, even with two outside aces and one outside king, the normal/balanced evaluator should not inflate the recommendation to 12 without the trump queen or ten, extra trump length, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-jack but missing queen and ten, with no outside aces and only one outside king, the normal/balanced evaluator should not inflate the recommendation to 10 without the trump queen or ten, reliable outside aces, additional side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-queen-jack but missing ten, with only one outside ace and limited side support, the normal/balanced evaluator should not inflate the recommendation to 10 without extra trump length, the trump ten, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by king-queen-jack but missing ace and ten, with no outside aces and only side kings as support, the normal/balanced evaluator should not inflate the recommendation to 10 without the trump ace or ten, multiple outside aces, stronger side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by king-queen-jack but missing ace and ten, with only one outside ace and no outside kings, the normal/balanced evaluator should not inflate the recommendation to 9 without the trump ace or ten, extra trump length, multiple outside aces, stronger side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-jack but missing queen and ten, even with two outside aces and one outside king, the normal/balanced evaluator should not inflate the recommendation to 11 without the trump queen or ten, extra trump length, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-queen-ten but missing jack, even with two outside aces and one outside king, the normal/balanced evaluator should not inflate the recommendation to 12 without extra trump length, the trump jack, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-queen with low remaining trump cards, with only one outside ace and side kings, the normal/balanced evaluator should not inflate the recommendation to 10 without jack or ten trump support, extra trump length, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-jack-ten but missing king and queen, even with two outside aces plus ordinary side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 9 without extra trump length, stronger top trump texture, exceptional short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by ace-queen-jack-ten but missing king, with only one outside ace and one outside king, the normal/balanced evaluator should not inflate the recommendation to 12 without the trump king, additional reliable outside winners, stronger side support, useful short-suit shape backed by enough trump control, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-queen-ten but missing king and jack, even with two outside aces and ordinary side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 11 without the trump king or jack, extra trump length, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-queen-ten but missing jack, with no outside aces and only side kings as support, the normal/balanced evaluator should not inflate the recommendation to 11 without the trump jack, reliable outside aces, additional side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-king-queen-jack but missing ten, with only one outside ace plus ordinary side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 11 without extra trump length, the trump ten, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for an eight-card trump hand headed by ace-king-queen-jack but missing ten, with no outside aces or outside kings, the normal/balanced evaluator should not inflate the recommendation to 13 without the trump ten, reliable outside winners, near-certain trump control, or exceptional partnership context.
- If automated bid recommendation is performed for a five-card trump hand headed by ace-queen-jack but missing king and ten, even with two outside aces and side kings, the normal/balanced evaluator should not inflate the recommendation to 11 without extra trump length, the trump king or ten, additional protected side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-ten but missing king, queen, and jack, with only one outside ace and ordinary side queen support, the normal/balanced evaluator should not inflate the recommendation to 9 without protected king, queen, or jack trump support, multiple outside aces, stronger side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a six-card trump hand headed by ace-king-queen but missing jack and ten, with only one outside ace and ordinary side king/queen support, the normal/balanced evaluator should not inflate the recommendation to 11 without the trump jack or ten, extra trump length, multiple outside aces, additional protected side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a seven-card trump hand headed by king-queen with low remaining trump cards and missing ace, jack, and ten, with at most one outside ace and ordinary side king support, the normal/balanced evaluator should not inflate the recommendation to 9 without the trump ace, protected jack or ten support, multiple outside aces, additional reliable side winners, useful short-suit shape, or partnership context.
- If automated bid recommendation is performed for a four-card trump hand headed by ace-king-queen-jack but missing ten, with at most one outside ace and ordinary side honor support, the normal/balanced evaluator should not inflate the recommendation to 9 without extra trump length, the trump ten, multiple outside aces, exceptional side certainty, or partnership context.
- If the current highest bidder is the simulated player's partner, the recommendation must be `Pass` unless the simulated player's hand supports a clearly stronger independent trump plan and an adjusted recommendation at least two tricks higher than the partner's current high bid.
- If the bidding service receives a simulated numeric recommendation that would raise the simulated player's partner by only one trick, the displayed value must be `Pass`, even when the recommendation came from an override or other non-default recommender path.
- If the current highest bidder is the simulated player's partner at 8, a six-card trump hand headed by ace-king-jack with low remaining trump cards, no outside aces, and only one outside king must not raise the partner to 10.
- If the current highest bidder is the simulated player's partner at 8, a five-card trump hand with fewer than three top trump controls and fewer than three reliable outside winners must not raise the partner to 10 based only on two outside aces, ordinary side honors, or a singleton.
- If the current highest bidder is the simulated player's partner at 8, an eight-card trump hand headed by ace-queen-jack-ten but missing king, with only one outside ace, must not raise the partner directly to 13 without near-certain trump control and stronger outside support.
- If the current highest bidder is the simulated player's partner, a five-card ace-queen-jack trump hand missing king and ten must not raise from 8 to 10 based only on two outside aces.
- If the current highest bidder is the simulated player's partner, a seven-card ace-jack-ten trump hand missing king and queen must not raise from 8 to 10 with no outside aces and only one outside king.
- If the current highest bidder is the simulated player's partner, a five-card ace-king-jack trump hand missing queen and ten must not raise from 7 to 11 based only on outside aces and a side king.
- If the current highest bidder is the simulated player's partner, a five-card ace-king-queen-ten trump hand missing jack must not raise from 9 to 12 based only on outside aces and a side king.
- If the current highest bidder is the simulated player's partner, a five-card ace-king-queen-jack trump hand missing ten must not raise from 8 to 11 based only on one outside ace, ordinary side king/queen support, and singleton shape.
- If an automated numeric recommendation is less than or equal to the current highest numeric bid, the displayed bid value must be `Pass`.
- If an automated numeric recommendation is greater than the current highest numeric bid, the displayed bid value must be that number.
- If an automated recommendation is numeric, it must include a preferred Tarneeb suit and confidence metadata.
- If an automated recommendation is `Pass`, it must not include a preferred Tarneeb suit.
- If a simulated player has already passed, that player must not be allowed to submit a later numeric bid in the same bidding round.
- If a player bids `13`, all other players must display `Pass` and no later bidding turns may occur.
- If all four players pass before any numeric bid is accepted, the app must not display a high-bidding player, bid value, or Tarneeb suit summary, and must automatically begin the next deal with the dealer advanced counterclockwise.
- If the current dealer rotates after West, the next dealer must wrap to South.
- If the app creates or resets a deck for a replacement deal, the completed deal must still contain exactly 52 unique assigned cards.
- If the app creates or resets a deck for an all-pass automatic redeal, the completed deal must still contain exactly 52 unique assigned cards.
- If hidden card backs are visually overlapped, no rank or suit information may be exposed for simulated players.
- If South receives a 13-card stack before every hand has been dealt, no South rank or suit information may be exposed before the fourth stack arrives, and the received stack must remain visible as fanned card backs until the final South expansion begins.
- If the South reveal flip is in progress, `Deal complete`, the `Bidding` area, and automated bidding must wait until the flip completes.
- The initial undealt 52-card deck stack must be centered inside the selected dealer's station and remain inside the station with an appropriate edge buffer; it must not overlap or obscure the `طرنيب` title before the deal.
- Dealer indication must not change any player station outline to blue.
- The current dealer pill must be visible before bidding starts, hidden once bidding starts, and move only when the next deal request or new game selects the next dealer.
- If a small portrait screen cannot fit the full table without adjustment, the UI may reduce spacing or allow scrolling, but it must keep all required controls, stations, and bid controls usable.
- If the South station expands after a deal, it must not make the `Bidding` area, South `Bid` button, bottom `Deal`, `New Game`, or status label unusable.
- If the South bid chips are used, they must not allow values outside `Pass` and the currently legal numeric bid range through 13.
- If South's post-bidding Tarneeb suit selector is used, it must not allow values outside spades, clubs, hearts, and diamonds.
- If South selects a numeric bid but no Tarneeb suit during in-progress bidding, the South `Bid` button may commit the bid; the suit is required only if South later becomes the numeric high bidder.
- If South selects `Pass`, the South `Bid` button may submit without a Tarneeb suit and South's resolved `Pass` state must not store a preferred suit.
- If South changes from a numeric draft bid to `Pass`, any draft Tarneeb suit must not be committed.
- If South changes from `Pass` to a numeric draft bid, no Tarneeb suit is required until South wins the bidding and reaches the post-bidding suit-setting panel.
- If bidding is in progress and it is not South's turn, the South bid chips must not be visible and the South `Bid` button must remain visible but disabled.
- If simulated player bidding is in progress, each simulated bid display update must take at least one second and must not block bottom controls or reset/deal responsiveness.
- If bidding completes by `13`, all-pass, or only-highest-bidder-remains terminal state, the status label must display `Bidding complete`.
- If bidding completes by `13`, all-pass, or only-highest-bidder-remains terminal state, the `Bidding` area must fade out over one second before disappearing.
- If bidding completes by `13`, all-pass, or only-highest-bidder-remains terminal state, the South `Bid` button must disappear completely with the `Bidding` area.
- If bidding completes with a numeric high bid, the post-bidding summary must display the correct high-bidding player label, numeric bid, and Tarneeb suit symbol.
- If bidding completes with no numeric high bid, no high-bidding player or Tarneeb suit symbol may be displayed.
- If a numeric bid is accepted, the resolved bid state must store the preferred trump/Tarneeb suit alongside the bid value.
- If a bid resolves to `Pass` or remains pending, the bid state must not store a preferred trump/Tarneeb suit.
- If a completed deal logs hands to the console, the log must include exactly four seat-specific hand entries with 13 cards each.
- If card size adapts to screen size, hidden card backs and exposed card faces must adapt together so they remain the same base size.
- If color values are implemented through system colors, the visual distinction between red suits and black/dark suits must remain clear in the supported appearance mode.
- If a device is physically rotated, the app should remain in portrait orientation for MVP 008.

## 10. Suggested Test Cases

### Unit Tests

1. `testDeckContains52Cards`
   - Verify a new deck contains exactly 52 cards.

2. `testDeckContainsNoJokers`
   - Verify no card has a joker rank or suit.

3. `testDeckContainsUniqueCards`
   - Verify each suit-rank combination appears exactly once.

4. `testPlayersAreCreatedForAllSeats`
   - Verify South, East, North, and West players exist.

5. `testSouthPlayerIsHuman`
   - Verify South is the only human player.

6. `testOtherPlayersAreSimulated`
   - Verify West, North, and East are simulated.

7. `testTeamsAreAssignedCorrectly`
   - Verify South + North are Team A and East + West are Team B.

8. `testDealGivesEachPlayer13Cards`
   - Verify all four players receive exactly 13 cards.

9. `testDealUsesAll52Cards`
   - Verify all cards are assigned after dealing.

10. `testDealHasNoDuplicateCards`
    - Verify no dealt card appears in more than one hand.

11. `testGamePhaseIsDealtAfterDeal`
    - Verify the game phase changes from `notStarted` to `dealt`.

12. `testHumanHandSortsBySuitThenRank`
    - Verify the visible South hand sort order is Hearts, Clubs, Diamonds, Spades and 2 through Ace within each suit.

13. `testSuitPresentationColors`
    - Verify Hearts and Diamonds map to red presentation styling and Clubs and Spades map to black or dark presentation styling.

14. `testHiddenAndExposedCardsShareBaseSize`
    - Verify presentation configuration uses the same base dimensions for hidden card backs and exposed cards, if such configuration is modeled outside SwiftUI.

15. `testInitialDeckStackRepresents52HiddenCards`
    - Verify the initial presentation model represents 52 hidden cards in the undealt deck stack inside the selected dealer station with squared-stack geometry metadata, if modeled outside SwiftUI.

16. `testNewGameResetsPresentationToLaunchState`
    - Complete a deal, invoke the reset action, and verify the phase returns to `notStarted`, hands are cleared, a dealer is selected, the dealer pill appears beside the selected dealer station name, the squared undealt deck stack is visible inside the selected dealer station, and the status label is hidden.

17. `testNewGameSelectsExactlyOneDealer`
    - Verify a new game selects exactly one dealer from South, East, North, and West.

18. `testDealerSelectionUsesRandomSource`
    - Verify new-game dealer selection can use an injected random source and does not hard-code one seat.

19. `testDealerRotatesCounterclockwise`
    - Verify dealer rotation proceeds South, East, North, West, then South.

20. `testDealerPillPresentationState`
    - Verify the selected dealer uses a small blue `D` pill beside the player name before bidding, the pill uses the `Deal` button color and white text, the indicator does not obscure the player name, and dealer metadata remains available after the pill hides during bidding.

21. `testAllowedBidValues`
    - Verify the completed bid value model accepts only `Pass` and numeric bids 7 through 13, with `--` represented only as a pending bid state.

22. `testBiddingInitializesAllEntriesAsPending`
    - Complete a deal and verify South, East, North, and West bid entries begin as `--`.

23. `testBiddingStartsToDealersRight`
    - Verify the first bidding turn is assigned to the player on the dealer's right.

24. `testBiddingAdvancesCounterclockwise`
    - Resolve a bid turn and verify the next active turn follows the counterclockwise seat order.

25. `testSimulatedBidUsesRecommendationWhenHigherThanCurrentBid`
    - Inject a simulated numeric recommendation higher than the current highest bid and verify it becomes that player's bid.

26. `testSimulatedBidPassesWhenRecommendationIsNotHigher`
    - Inject a simulated numeric recommendation equal to or lower than the current highest bid and verify the displayed bid becomes `Pass`.

27. `testBidOfThirteenEndsBidding`
    - Resolve any player bid as `13` and verify all other players are set to `Pass` and bidding ends.

28. `testBiddingEndsWhenOnlyHighestBidderHasNumericBid`
    - Verify bidding ends when every player except the current highest bidder has `Pass`.

29. `testSouthBidOptionsUseCurrentLegalMinimum`
    - Verify South's legal numeric options start at `7` when no numeric bid exists, otherwise one more than the current highest bid.

30. `testSouthNumericBidCanCommitWithoutTarneebSuitDuringBidding`
    - Advance bidding to South's turn, select a numeric bid without a Tarneeb suit, and verify South can commit the bid during the in-progress bidding round.

31. `testSouthPostBiddingSetStoresSelectedTarneebSuit`
    - Resolve bidding with South as the numeric high bidder, select a Tarneeb suit in the post-bidding panel, tap `Set`, and verify the accepted South bid stores the selected suit alongside the bid value.

32. `testSouthPassStoresNoTarneebSuit`
    - Resolve South's turn with `Pass` and verify South's resolved bid stores no preferred Tarneeb suit.

33. `testSouthBidSubmissionReplacesSelector`
    - Resolve South's turn and verify the selected value replaces the bid-chip selector state and the `Bid` button remains visible but disabled.

34. `testReplacementDealResetsBiddingToPending`
    - Complete a deal, start a replacement deal, and verify the fresh bidding round starts with all bid entries reset to `--`.

35. `testBiddingCompletionUpdatesStatusLabel`
    - Resolve bidding to a terminal state and verify the status label changes from `Deal complete` to `Bidding complete`.

36. `testBiddingCompletionHidesSouthBidButton`
    - Resolve bidding to a terminal state and verify the South `Bid` button no longer appears.

37. `testWeakSimulatedHandRecommendsPass`
    - Give a simulated player a weak 13-card hand and verify the automated bid recommendation is `Pass`.

38. `testWeakLongSuitWithoutAcesDoesNotOverbid`
    - Give the normal/balanced evaluator the hand `2♦ 4♦ 2♠ 3♠ 2♥ 8♠ Q♠ K♦ 10♦ 5♦ 7♣ 3♣ J♦` with no current highest bid and verify the recommendation is `Pass` or no higher than `7`.

39. `testFiveCardTrumpWithSideWinnersDoesNotOverbidTen`
    - Give the normal/balanced evaluator the hand `7♥ 6♦ 8♦ 4♠ 10♠ A♠ J♠ 10♦ A♥ K♥ 4♣ Q♠ 5♥` with no current highest bid and verify the recommendation is no higher than `9`.

40. `testSixCardTrumpAceQueenDoesNotOverbidTen`
    - Give the normal/balanced evaluator the hand `K♣ A♦ 10♥ 10♠ 2♠ 8♣ 3♦ 6♦ Q♦ 2♦ 4♦ A♠ 4♠` with no current highest bid and verify the recommendation is no higher than `9`.

41. `testSixCardAceKingQueenJackTrumpWithoutOutsideAcesDoesNotOverbidEleven`
    - Give the normal/balanced evaluator the hand `J♥ 9♦ 4♥ 8♦ 4♣ K♠ A♥ Q♥ 3♦ K♥ 5♠ J♠ 3♥` with no current highest bid and verify the recommendation prefers hearts but is no higher than `10`.

42. `testStrongLongSuitRecommendsNumericBidAndPreferredSuit`
    - Give a simulated player a strong long suit with high cards and verify the recommendation is numeric, records that suit as preferred Tarneeb, and includes confidence.

43. `testAcceptedNumericBidStoresPreferredTrumpSuit`
    - Resolve numeric bids for simulated players and South and verify each accepted numeric bid state stores the bid value with a preferred trump/Tarneeb suit, while `Pass` and pending states store no preferred suit.

44. `testAutomatedBidRecommendationConsidersCurrentHighestBid`
    - Verify a recommendation that does not exceed the current highest bid resolves as `Pass`.

45. `testAutomatedBidRecommendationPassesWhenPartnerIsHighestByDefault`
    - Verify a simulated player recommends `Pass` when its partner is currently highest unless the simulated hand has clearly stronger independent trump potential and an adjusted recommendation at least two tricks above the current high bid.

46. `testAutomatedBidRecommendationRaisesPartnerOnlyWithStrongTrumpPotential`
    - Give a simulated player whose partner is currently highest both a side-winner-heavy marginal hand and a stronger independent trump-control hand, and verify only the clearly stronger trump-control hand may raise.

47. `testBiddingServiceRejectsOneTrickPartnerRaiseOverride`
    - Give the bidding service a state where West is the current highest bidder at `7`, East receives an injected or deterministic simulated recommendation of `8`, and verify East resolves to `Pass` with no accepted preferred suit metadata.

48. `testFiveCardAceKingLowTrumpDoesNotOverbidNine`
    - Give the evaluator `3♦ Q♣ 5♠ 5♣ 3♥ 7♠ 4♠ A♣ 4♦ 10♥ 2♦ K♦ A♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `8`.

49. `testSixCardAceKingLowTrumpDoesNotOverbidEleven`
    - Give the evaluator `Q♣ A♠ K♠ 6♠ 10♣ 2♠ 10♦ A♥ 7♠ 5♥ 9♣ 4♠ A♣` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `10`.

50. `testFourCardAceKingTenTrumpDoesNotOverbidTen`
    - Give the evaluator `9♠ 8♣ 10♥ 2♥ 8♠ J♣ 4♠ A♥ 4♣ K♥ K♣ A♣ K♦` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `9`.

51. `testAutomatedBidPersonalityAdjustsNormalEstimate`
    - Give conservative, balanced, and aggressive personalities the same hand and bidding context, and verify each personality starts from the same normal estimated trick count before applying its bid-threshold or rounding adjustment.

52. `testAutomatedBidPersonalityStillObeysLegalRules`
    - Give an aggressive personality a marginal or equal-to-highest adjusted recommendation and verify legal bid filtering still converts invalid bids to `Pass` and prevents reentry after a previous `Pass`.

53. `testPassedPlayerCannotReenterBidding`
    - Resolve a simulated or South bid as `Pass`, later accept a higher bid by another player, and verify the passed player is not offered another turn.

54. `testPostBiddingSummaryUsesHighBidderPlayerAndBid`
    - Resolve bidding with South, East, North, and West as highest bidder and verify the terminal summary displays the actual high-bidding player label.

55. `testPostBiddingSummaryUsesPreferredSuitSymbol`
    - Resolve bidding with stored preferred suits for spades, clubs, hearts, and diamonds and verify the summary uses `♠`, `♣`, `♥`, and `♦`.

56. `testPostBiddingSummaryUsesSouthSelectedSuit`
    - Resolve bidding with South as the highest bidder and verify the summary uses South's selected Tarneeb suit symbol.

57. `testAllPassBiddingStartsAutomaticRedeal`
    - Resolve bidding with all four players passing before any numeric bid is accepted, and verify no high-bidding player or Tarneeb suit symbol is produced, the dealer advances counterclockwise to the player on the previous dealer's right, a fresh deal starts automatically, and the new bidding round begins with all bid entries reset to `--`.

58. `testAllPassAutomaticRedealUsesFreshDeckAndLogsHands`
    - Resolve an all-pass bidding round and verify the automatic redeal shuffles a valid 52-card deck, deals 13 cards to each player, and logs South, East, North, and West hands for the new deal.

59. `testDealLogsEachPlayerHand`
    - Complete a deal with an injected log destination and verify South, East, North, and West each produce one readable 13-card hand log entry.

60. `testFiveCardAceKingQueenTenTrumpWithoutOutsideAcesDoesNotOverbidTen`
    - Give the evaluator `Q♣ 10♠ Q♦ 4♣ 5♣ K♠ J♣ A♠ 5♦ K♦ Q♠ 7♠ 7♣` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `9`.

61. `testFourCardAceLowTrumpOneOutsideAceDoesNotOpenSeven`
    - Give the evaluator `5♥ 10♠ 8♠ 8♣ 6♠ 6♦ 8♦ J♠ A♥ A♣ 7♠ 7♣ 3♣` with no current highest bid and verify the balanced/default recommendation is `Pass`, not `7` or higher.

62. `testFiveCardKingQueenTenMissingAceDoesNotOverbidEight`
    - Give the evaluator `2♣ K♦ Q♦ 10♦ K♠ 8♥ 3♦ 4♥ 7♦ 6♥ 10♣ K♣ A♠` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `7`.

63. `testSixCardAceJackTrumpWithoutKingQueenTenDoesNotOverbidTen`
    - Give the evaluator `3♦ 10♠ 3♥ A♦ 4♦ J♦ 4♥ A♠ 6♥ 8♦ 9♦ K♠ 7♠` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `9`.

64. `testFourCardAceKingJackTrumpDoesNotOverbidNine`
    - Give the evaluator `J♣ A♣ 5♦ J♦ 6♣ K♠ K♥ 9♥ 8♠ 8♦ 6♠ J♥ A♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `8`.

65. `testFourCardAceKingLowTrumpWithSideQueensDoesNotOverbidNine`
    - Give the evaluator `6♦ Q♥ 9♠ 8♠ 10♥ 6♠ A♠ 5♦ K♠ Q♣ 7♥ 8♣ A♣` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `8`.

66. `testFourCardAceQueenJackTrumpDoesNotOverbidNine`
    - Give the evaluator `A♣ 5♦ K♠ 5♣ 4♥ Q♣ 2♥ J♥ A♥ 8♠ 7♣ 2♠ J♣` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `8`.

67. `testFiveCardAceQueenTenTrumpMissingKingJackDoesNotOverbidNine`
    - Give the evaluator `3♠ Q♣ J♠ 10♣ 4♣ A♣ A♦ 7♥ 7♠ 9♠ 8♣ 2♥ Q♠` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `8`.

68. `testFiveCardAceKingTenTrumpMissingQueenJackDoesNotOverbidNine`
    - Give the evaluator `J♦ 5♥ A♠ K♥ Q♦ 4♠ 8♦ 10♥ 4♣ 10♦ 4♦ 6♥ A♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `8`.

69. `testFiveCardAceKingQueenTrumpMissingJackTenWithoutOutsideAcesDoesNotOverbidNine`
    - Give the evaluator `7♠ 8♠ Q♦ 9♦ A♥ 2♦ 9♣ Q♥ K♥ 7♣ 2♥ 9♥ 5♣` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `8`.

70. `testSixCardAceKingQueenTrumpMissingJackTenWithTwoOutsideAcesDoesNotOverbidTwelve`
    - Give the evaluator `7♦ Q♦ 3♥ A♠ 5♣ K♣ K♦ 4♦ 6♠ 5♦ 10♣ A♦ A♣` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `11`.

71. `testFiveCardKingQueenTrumpMissingAceJackTenDoesNotOverbidEight`
    - Give the evaluator `10♥ K♠ Q♠ 7♠ K♦ 2♦ 2♠ 7♦ 6♣ 3♣ 5♦ A♣ Q♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is `Pass` or no higher than `7`.

72. `testFiveCardAceQueenTenTrumpMissingKingJackWithThreeOutsideAcesDoesNotOverbidEleven`
    - Give the evaluator `5♠ A♠ A♦ 4♦ 2♥ 10♦ A♥ A♣ 9♥ K♣ 7♣ Q♦ 2♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `10`.

73. `testFourCardAceKingTenOrAceQueenTextureDoesNotOverbidNine`
    - Give the evaluator `3♠ K♥ 3♦ 5♣ 8♥ A♣ 2♠ 9♣ 6♠ 10♥ 8♣ Q♣ A♥` with no current highest bid and verify the balanced/default recommendation is no higher than `8`.

74. `testFourCardAceKingJackTenWithoutOutsideAcesDoesNotOverbidEight`
    - Give the evaluator `10♣ 8♠ 5♠ 9♠ 3♥ J♣ K♦ A♣ J♥ 6♥ 4♦ J♦ K♣` with no current highest bid and verify the balanced/default recommendation prefers clubs but is `Pass` or no higher than `7`.

75. `testFourCardAceKingLowTrumpWithoutOutsideAcesDoesNotOverbidEight`
    - Give the evaluator `7♠ K♣ 9♣ 3♦ 9♠ 2♥ 4♦ 6♥ Q♥ K♥ 10♣ K♦ A♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is `Pass` or no higher than `7`.

76. `testFiveCardAceJackTenMissingKingQueenWithoutOutsideAcesDoesNotOpenSeven`
    - Give the evaluator `A♦ 10♦ 2♣ Q♣ J♦ 9♥ Q♠ 4♥ 7♦ K♥ 9♦ 5♣ K♠` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is `Pass`.

77. `testFiveCardAceLowTrumpWithTwoOutsideAcesDoesNotOverbidEight`
    - Give the evaluator `A♣ 6♥ 5♥ 8♥ 3♠ 4♦ 3♣ 4♠ A♦ 6♦ A♥ 4♥ K♣` with no current highest bid and verify the balanced/default recommendation prefers hearts but is `Pass` or no higher than `7`.

78. `testSevenCardAceQueenTenTrumpMissingKingJackWithoutOutsideWinnersDoesNotOverbidEleven`
    - Give the evaluator `2♦ 5♠ Q♦ A♦ 8♦ 10♦ 6♠ 2♠ 10♥ 2♥ 3♦ 4♦ 9♥` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `10`.

79. `testSevenCardAceQueenTrumpMissingKingJackTenWithOneOutsideAceDoesNotOverbidEleven`
    - Give the evaluator `A♠ 7♠ A♣ 4♣ 3♠ 5♠ 9♠ 7♥ 4♥ J♦ Q♠ 4♠ 3♥` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `10`.

80. `testFourCardAceKingJackTrumpWithStrongOutsideHonorsDoesNotOverbidTen`
    - Give the evaluator `A♥ A♦ K♠ 6♦ Q♥ J♣ Q♦ 4♠ 6♣ K♦ 10♥ A♣ K♣` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `9`.

81. `testFiveCardAceTenTrumpWithoutOutsideAcesDoesNotOpenSeven`
    - Give the evaluator `9♠ 6♥ 10♠ 8♥ 8♣ J♦ J♣ 7♦ K♣ K♦ 3♠ A♠ 7♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is `Pass`.

82. `testFiveCardAceKingQueenJackTrumpMissingTenDoesNotOverbidTen`
    - Give the evaluator `Q♥ J♥ J♣ Q♦ 4♣ A♥ Q♠ K♥ 8♦ K♣ 2♥ 4♦ 9♣` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `9`.

83. `testFourCardAceJackTenLowTrumpWithoutOutsideAcesOrKingsDoesNotOpenSeven`
    - Give the evaluator `J♣ A♣ J♠ 5♥ Q♦ 8♥ 9♦ 2♦ 5♣ J♦ 5♠ 3♠ 10♣` with no current highest bid and verify the balanced/default recommendation treats clubs as the best candidate but is `Pass`, not `7` or higher.

84. `testSixCardKingQueenTrumpWithoutAcesDoesNotOverbidNine`
    - Give the evaluator `9♥ 6♦ 6♠ K♠ 4♥ 10♠ 7♦ K♦ 7♥ Q♥ 3♥ Q♦ K♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `8`.

85. `testSixCardAceKingJackTenTrumpMissingQueenDoesNotOverbidEleven`
    - Give the evaluator `A♥ J♥ Q♦ A♠ 3♣ 8♠ 10♥ 8♦ 3♥ 10♦ 2♥ K♠ K♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `10`.

86. `testSixCardAceKingJackTrumpMissingQueenTenWithoutOutsideWinnersDoesNotOverbidTen`
    - Give the evaluator `5♠ 4♦ J♠ Q♦ 8♠ K♠ 3♥ 3♣ 9♣ A♠ 4♠ 10♦ J♣` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `9`.

87. `testFourCardAceKingLowTrumpWithTwoOutsideAcesDoesNotOverbidNine`
    - Give the evaluator `6♠ 5♥ 8♥ 9♠ 2♦ Q♥ J♣ A♦ 4♣ 4♦ A♠ A♥ K♦` with no current highest bid and verify the balanced/default recommendation is no higher than `8`.

88. `testSixCardAceKingTenTrumpMissingQueenJackDoesNotOverbidTen`
    - Give the evaluator `A♥ Q♥ K♦ 2♦ 3♠ 7♥ 6♣ J♣ 7♦ 8♦ 10♦ 10♣ A♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `9`.

89. `testSixCardAceKingQueenTrumpMissingJackTenWithSideKingsDoesNotOverbidEleven`
    - Give the evaluator `A♣ 5♥ 3♣ K♣ 10♥ Q♣ K♦ 7♣ K♠ 8♣ 4♥ 5♠ 10♠` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `10`.

90. `testSevenCardAceKingTenTrumpMissingQueenJackWithOneOutsideAceDoesNotOverbidTwelve`
    - Give the evaluator `4♥ 10♦ 3♦ Q♣ 6♦ K♦ 5♦ A♦ 7♣ 7♠ 6♣ A♣ 8♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `11`.

91. `testSixCardKingQueenTrumpWithOneOutsideAceDoesNotOverbidNine`
    - Give the evaluator `K♣ 6♣ 2♣ 10♥ 3♥ A♠ 7♣ 8♣ K♥ 5♦ J♥ Q♠ Q♣` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `8`.

92. `testFiveCardAceKingQueenTrumpMissingJackTenWithTwoOutsideAcesDoesNotOverbidEleven`
    - Give the evaluator `Q♥ J♠ 2♦ Q♦ A♦ A♣ A♥ 9♦ 3♥ K♥ 7♦ Q♠ 9♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `10`.

93. `testEightCardAceLowTrumpWithoutOutsideAcesDoesNotOverbidTen`
    - Give the evaluator `8♠ 6♠ 2♠ 4♦ 5♠ 4♠ 5♥ 9♠ 3♦ A♠ K♦ 5♣ 3♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `9`.

94. `testSevenCardAceKingLowTrumpWithoutOutsideAcesDoesNotOverbidTen`
    - Give the evaluator `A♥ 10♦ 3♥ 6♥ 8♠ K♠ 2♥ 10♣ 8♦ K♥ 9♥ 9♣ 4♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `9`.

95. `testSevenCardAceTenTrumpWithOneOutsideAceDoesNotOverbidEleven`
    - Give the evaluator `8♥ 6♣ A♥ K♦ 4♣ 10♣ 3♥ 7♣ 3♣ 9♣ 6♥ Q♦ A♣` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `10`.

96. `testSixCardAceKingTenTrumpWithoutOutsideAcesDoesNotOverbidTen`
    - Give the evaluator `4♦ K♠ 6♥ J♠ 10♦ K♦ A♦ K♣ 8♦ 8♣ 4♣ 8♠ 5♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `9`.

97. `testSevenCardAceQueenJackTrumpMissingKingTenDoesNotOverbidEleven`
    - Give the evaluator `4♥ 3♠ Q♥ 8♥ 3♣ 9♥ A♥ 5♣ J♥ A♠ 8♦ 5♦ 3♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `10`.

98. `testEightCardAceQueenTenTrumpMissingKingJackDoesNotOverbidThirteen`
    - Give the evaluator `4♥ 2♠ Q♠ 7♦ 3♥ 7♠ A♠ Q♥ 8♥ 7♥ 10♥ 2♥ A♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `11`.

99. `testSevenCardAceKingTenTrumpWithoutOutsideAcesDoesNotOverbidEleven`
    - Give the evaluator `K♥ 9♥ 10♥ 8♥ 7♥ K♦ A♥ 3♦ K♠ 4♠ Q♣ Q♦ 3♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `10`.

100. `testSevenCardAceKingTenTrumpWithVoidDoesNotOverbidTwelve`
    - Give the evaluator `K♥ 5♠ Q♥ K♠ 4♠ A♠ 10♠ 4♥ 9♥ 3♠ K♦ Q♦ 6♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `11`.

101. `testSixCardAceKingLowTrumpWithoutOutsideWinnersDoesNotOverbidTen`
    - Give the evaluator `7♥ 4♥ K♥ 2♣ 2♠ 8♣ A♥ 6♥ 5♥ J♠ 5♠ 10♠ Q♠` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `9`.

102. `testSixCardAceKingJackTrumpWithOneOutsideAceDoesNotOverbidTen`
    - Give the evaluator `K♥ 7♣ 4♥ 10♣ 9♥ 3♥ 2♠ A♥ A♦ 8♣ 6♦ 7♠ J♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `9`.

103. `testSevenCardKingQueenJackTenTrumpMissingAceDoesNotOverbidTen`
    - Give the evaluator `Q♣ Q♠ 9♥ 9♠ 10♠ 5♣ K♠ 7♠ J♠ 5♠ K♦ 4♣ 5♥` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `9`.

104. `testFiveCardAceKingLowTrumpWithTwoOutsideAcesDoesNotOverbidTen`
    - Give the evaluator `K♥ 10♥ A♥ A♦ 9♦ A♣ 8♦ 3♥ 6♦ K♦ 9♠ J♠ 4♣` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `9`.

105. `testSevenCardAceKingQueenTrumpWithoutOutsideWinnersDoesNotOverbidEleven`
    - Give the evaluator `8♠ Q♠ 9♣ 7♥ 3♥ 10♦ J♣ 7♠ 6♠ A♠ K♠ 5♦ 2♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `10`.

106. `testSixCardAceKingLowTrumpWithOneOutsideAceAndSideKingsDoesNotOverbidTen`
    - Give the evaluator `K♠ 8♦ A♦ A♥ 8♥ K♣ 4♥ 2♦ 5♦ J♠ 7♦ 7♠ K♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `9`.
    - Give the evaluator `8♥ 3♠ 5♣ 4♥ 7♣ A♦ 2♥ 7♥ 8♦ A♥ K♣ 10♠ K♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `9`.

107. `testSevenCardAceKingQueenJackTrumpWithoutOutsideAcesDoesNotOverbidTwelve`
    - Give the evaluator `K♠ Q♦ A♦ 3♦ 10♣ 9♠ 9♦ 4♦ 4♣ 8♠ K♦ J♦ 6♣` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `11`.

108. `testSevenCardAceKingJackTrumpWithoutOutsideAcesDoesNotOverbidEleven`
    - Give the evaluator `2♦ 2♠ J♠ 6♣ Q♦ K♥ 7♠ 9♠ 2♥ A♠ K♠ 8♠ K♦` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `10`.

109. `testAutomatedBidDoesNotRaisePartnerWithSixCardAceKingJackLowTrump`
    - Give North the hand `Q♥ 7♦ 8♣ 8♥ 7♥ 6♠ 2♠ A♠ 5♠ 2♣ J♠ K♦ K♠` while South is the current highest bidder at `8`, and verify North's balanced/default recommendation resolves to `Pass`, not a `10` bid with spades as the preferred suit.

110. `testSixCardAceKingJackTenTrumpWithoutOutsideAcesDoesNotOverbidEleven`
    - Give the evaluator `K♦ 7♥ 4♦ K♠ 5♦ 2♦ 5♠ 7♠ 9♥ 10♠ 9♦ J♠ A♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `10`.

111. `testFiveCardKingQueenTenTrumpWithTwoOutsideAcesDoesNotOverbidNine`
    - Give the evaluator `J♣ Q♦ 3♣ 5♠ A♣ 8♠ Q♠ 10♠ 4♦ A♦ 3♥ K♠ 2♣` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `8`.

112. `testFiveCardAceKingQueenLowTrumpWithOneOutsideAceDoesNotOverbidTen`
    - Give the evaluator `6♥ 2♠ 2♦ 8♣ 9♣ A♦ K♦ 8♠ A♣ 5♦ Q♦ 3♣ Q♣` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `9`.

113. `testEightCardAceQueenJackTenTrumpMissingKingDoesNotOverbidThirteen`
    - Give the evaluator `10♥ J♥ 2♥ A♣ 2♦ 4♥ 9♦ Q♥ 10♦ 4♣ 9♥ 6♥ A♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `12`.
    - Give the evaluator `A♣ A♥ K♦ 4♦ J♦ 4♣ Q♦ 7♦ 8♠ 8♥ Q♥ A♦ 10♦` with no current highest bid and verify the diamond evaluation is no higher than `12` and does not bid `13`.

114. `testAutomatedBidDoesNotRaisePartnerToThirteenWithEightCardAceQueenJackTenTrump`
    - Give North the hand `10♥ J♥ 2♥ A♣ 2♦ 4♥ 9♦ Q♥ 10♦ 4♣ 9♥ 6♥ A♥` while South is the current highest bidder at `8`, and verify North's balanced/default recommendation does not resolve to `13` with hearts as the preferred suit.

115. `testFiveCardAceQueenLowTrumpWithOutsideAcesDoesNotOverbidTen`
    - Give the evaluator `A♦ 7♠ 8♠ 5♦ K♥ 4♥ 7♣ A♣ Q♠ 3♥ 9♠ K♦ A♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `9`.

116. `testFourCardAceLowTrumpWithThreeOutsideAcesDoesNotOverbidNine`
    - Give the evaluator `A♠ 4♥ 10♠ 3♥ 8♠ 5♥ 10♦ 5♦ A♦ 8♣ A♥ A♣ 10♣` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `8`.

117. `testFiveCardKingQueenJackTrumpMissingAceTenDoesNotOverbidNine`
    - Give the evaluator `K♠ Q♦ J♦ 10♣ 8♣ 2♦ 6♠ 8♠ A♣ 5♣ 6♦ K♦ 9♣` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `8`.

118. `testFourCardAceKingJackTrumpWithoutOutsideAcesDoesNotOverbidEight`
    - Give the evaluator `8♥ 8♦ 6♦ Q♠ 2♦ J♥ 9♣ K♥ 2♠ 5♦ K♣ 9♦ A♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is `Pass` or no higher than `7`.

119. `testEightCardAceJackTenTrumpMissingKingQueenDoesNotOverbidEleven`
    - Give the evaluator `5♦ A♦ 6♦ 6♥ 2♠ J♦ 8♦ 3♦ 6♠ J♠ 4♦ 10♦ 9♥` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `10`.

120. `testFourCardAceKingQueenTenTrumpWithoutOutsideAcesDoesNotOverbidEight`
    - Give the evaluator `6♦ 3♦ Q♠ 10♠ 7♥ 9♥ K♦ 9♦ 5♥ 10♥ A♠ K♠ 8♥` with no current highest bid and verify the balanced/default recommendation prefers spades but is `Pass` or no higher than `7`.

121. `testFiveCardAceQueenJackTrumpWithTwoOutsideAcesDoesNotOverbidTen`
    - Give the evaluator `2♥ J♥ A♠ A♣ 4♥ A♥ 3♠ 8♣ 10♣ 5♠ 8♠ Q♥ 4♠` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `9`.

122. `testAutomatedBidDoesNotRaisePartnerWithFiveCardAceQueenJackTrump`
    - Give South the hand `2♥ J♥ A♠ A♣ 4♥ A♥ 3♠ 8♣ 10♣ 5♠ 8♠ Q♥ 4♠` while North is the current highest bidder at `8`, and verify South's balanced/default recommendation resolves to `Pass`, not a `10` bid with hearts as the preferred suit.

123. `testSevenCardAceJackTenTrumpWithoutOutsideAcesDoesNotOverbidTen`
    - Give the evaluator `3♦ 5♣ 4♣ K♣ A♦ 9♦ 8♦ 10♦ 10♥ J♠ J♦ 6♦ Q♥` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `9`.
    - Give East that same hand while West is the current highest bidder at `8`, and verify East resolves to `Pass`, not a `10` bid with diamonds as the preferred suit.

124. `testSevenCardAceKingQueenTrumpMissingJackTenWithOneOutsideAceDoesNotOverbidTwelve`
    - Give the evaluator `7♥ 10♠ 6♠ 2♠ A♥ K♥ 4♥ Q♥ 9♥ 7♠ 3♥ A♠ 7♦` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `11`.
    - Give the evaluator `6♣ 4♥ 3♣ 2♥ 8♥ A♠ K♥ Q♥ A♥ 5♥ 4♦ 10♣ K♣` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `11`.
    - Give the evaluator `A♠ K♥ 8♣ 7♠ Q♥ A♥ 4♠ 7♥ 4♣ 7♣ 8♥ 2♥ 4♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `11`.

125. `testFiveCardKingQueenJackTenTrumpWithOutsideAcesDoesNotOverbidNine`
    - Give the evaluator `5♠ 4♠ 8♣ 6♥ A♣ K♥ A♠ 10♠ J♥ 2♣ 10♥ 3♣ Q♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `8`.

126. `testSixCardAceKingJackTrumpWithOutsideAcesDoesNotOverbidTwelve`
    - Give the evaluator `K♠ 4♦ 9♠ A♦ 5♥ A♥ 2♥ 3♦ J♦ Q♣ A♣ 7♦ K♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `11`.

127. `testSixCardAceKingJackTrumpWithoutOutsideAcesDoesNotOverbidTen`
    - Give the evaluator `9♠ 4♠ A♠ K♥ 5♠ K♠ 8♥ J♠ 4♣ 7♣ J♦ 2♥ 9♣` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `9`.

128. `testFiveCardAceKingQueenJackTrumpWithOneOutsideAceDoesNotOverbidTen`
    - Give the evaluator `Q♣ 8♠ 6♦ 8♣ J♠ A♠ J♦ 2♠ 6♠ K♦ Q♦ 9♥ A♦` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `9`.
    - Give the evaluator `3♠ A♥ K♦ 4♣ J♦ K♣ 9♠ 2♠ Q♦ 8♦ J♣ A♦ 9♥` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `9`.

129. `testSevenCardKingQueenJackTrumpMissingAceDoesNotOverbidTen`
    - Give the evaluator `Q♠ K♣ 5♠ 5♦ 4♠ K♠ K♦ J♠ Q♣ 7♦ 5♥ 8♠ 6♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `9`.

130. `testSixCardKingQueenJackTrumpWithOneOutsideAceDoesNotOverbidNine`
    - Give the evaluator `Q♦ Q♣ K♦ 6♣ 9♦ J♦ 2♠ 2♦ A♥ 9♥ 10♠ 4♦ 7♣` with no current highest bid and verify the balanced/default recommendation prefers diamonds but is no higher than `8`.
    - Give the evaluator the fresh simulation six-card missing-ace K-Q/J/10 hands from PRD-017 and verify each target suit's `safeBidCeiling` is no higher than `8`.

131. `testFiveCardAceKingJackTrumpWithOutsideAcesDoesNotOverbidEleven`
    - Give the evaluator `7♥ A♠ 4♦ 2♠ 4♣ A♣ 9♥ 7♦ K♠ A♥ K♥ J♥ 2♣` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `10`.
    - Give West that same hand while East is the current highest bidder at `7`, and verify West does not resolve to `11` with hearts as the preferred suit.

132. `testFiveCardAceKingQueenTenTrumpMissingJackDoesNotOverbidTwelve`
    - Give the evaluator `Q♣ 10♣ J♠ A♣ A♦ A♠ K♣ 8♣ K♦ 10♦ 2♠ 8♠ 9♠` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `11`.
    - Give West that same hand while East is the current highest bidder at `9`, and verify West does not resolve to `12` with clubs as the preferred suit.

133. `testFiveCardAceKingQueenLowTrumpWithSideKingsDoesNotOverbidTen`
    - Give the evaluator `K♦ 3♥ K♠ A♠ 7♣ 7♥ 9♣ K♥ 5♠ Q♠ A♥ 6♦ 6♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `9`.

134. `testFourCardAceJackTenTrumpWithOutsideAcesDoesNotOverbidNine`
    - Give the evaluator `K♣ Q♣ 9♣ 4♣ J♥ 5♠ 10♥ 10♦ 8♠ A♥ A♦ A♠ 8♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `8`.

135. `testSevenCardAceQueenJackTenTrumpMissingKingDoesNotOverbidTwelve`
    - Give the evaluator `6♣ A♣ 8♠ K♥ Q♣ 8♣ 10♣ A♠ J♣ 4♦ 7♦ 3♥ 3♣` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `11`.

136. `testSixCardAceQueenTenTrumpWithOutsideAcesDoesNotOverbidEleven`
    - Give the evaluator `A♦ A♥ Q♣ 4♠ A♠ 4♦ 2♥ 6♥ K♦ 9♥ Q♥ 7♦ 10♥` with no current highest bid and verify the balanced/default recommendation prefers hearts but is no higher than `10`.

137. `testSixCardAceKingQueenTenTrumpWithoutOutsideAcesDoesNotOverbidEleven`
    - Give the evaluator `K♠ 4♣ K♦ K♣ Q♣ 10♣ 10♠ 7♣ 8♠ J♠ 3♦ A♣ 2♥` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `10`.

138. `testFiveCardAceKingQueenJackTrumpWithSideHonorsDoesNotOverbidEleven`
    - Give the evaluator `Q♣ K♦ 9♠ A♠ 5♦ 10♥ 8♦ Q♠ 2♣ 3♦ J♠ A♣ K♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `10`.

139. `testAutomatedBidDoesNotRaisePartnerToElevenWithFiveCardAceKingQueenJackTrump`
    - Give West the hand `Q♣ K♦ 9♠ A♠ 5♦ 10♥ 8♦ Q♠ 2♣ 3♦ J♠ A♣ K♠` while East is the current highest bidder at `8`, and verify West does not resolve to `11`; if West raises numerically, verify the bid is no higher than `10` with spades as the preferred suit.

140. `testEightCardAceKingQueenJackTrumpMissingTenDoesNotOverbidThirteen`
    - Give the evaluator `7♦ K♣ 10♥ 9♣ 7♣ Q♣ 8♣ 10♠ 5♣ J♣ A♣ 4♠ 8♠` with no current highest bid and verify the balanced/default recommendation prefers clubs but is no higher than `12`.

141. `testFiveCardAceQueenJackTrumpWithSideKingsDoesNotOverbidEleven`
    - Give the evaluator `8♠ A♣ A♦ K♦ K♣ 10♦ A♠ 5♠ J♠ 6♥ 5♣ K♥ Q♠` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `10`.

142. `testSixCardAceTenTrumpWithOneOutsideAceDoesNotOverbidNine`
    - Give the evaluator `Q♦ 9♠ 5♠ A♠ 6♠ 7♦ 7♥ 2♥ A♣ 4♠ 10♠ 4♣ 6♦` with no current highest bid and verify the balanced/default recommendation prefers spades but is no higher than `8`.

143. `testBidRecommendationUsesSafeBidCeilingInsteadOfExpectedTricks`
    - Give the evaluator a deterministic candidate evaluation where the preferred suit has `expectedTricks` above 9 but `safeBidCeiling` of `8`, and verify the final balanced/default recommendation is no higher than `8`.

144. `testCandidateSuitsAreEvaluatedIndependently`
    - Give the evaluator a hand with at least two plausible candidate Tarneeb suits and verify diagnostics include a separate `expectedTricks`, `safeBidCeiling`, and risk summary for each suit before a preferred suit is selected.

145. `testPreferredSuitUsesBestSafeBidCeiling`
    - Give the evaluator a hand where one suit has a higher optimistic `expectedTricks` but a lower `safeBidCeiling` than another suit, and verify the preferred Tarneeb suit comes from the stronger legal `safeBidCeiling`.

146. `testHighBidGateCapsSideHonorInflation`
    - Give the evaluator a side-honor-heavy hand whose raw estimate reaches 10 or higher but whose candidate trump suit lacks the required top control, and verify the high-bid gate caps the recommendation below 10.

147. `testSideKingsAndQueensAreConditionalSupport`
    - Compare otherwise similar hands with protected versus unprotected side king/queen support and verify unprotected side honors do not count as sure winners or raise the `safeBidCeiling` by themselves.

148. `testShortSuitValueRequiresTrumpControl`
    - Compare otherwise similar hands with singleton or void shape and weak versus strong candidate trump control, and verify short-suit value does not raise the `safeBidCeiling` for the weak-control hand.

149. `testPersonalityCannotExceedSafeBidCeiling`
    - Give conservative, balanced, and aggressive personalities the same candidate diagnostics and verify none of them recommends above the selected suit's `safeBidCeiling` or bypasses high-bid gates.

150. `testRegressionHandsUseGeneralizedEvaluatorDiagnostics`
    - Run a representative set of exact-hand regression examples and verify each result includes generalized diagnostics such as selected suit, `expectedTricks`, `safeBidCeiling`, and gate/risk reasons rather than an exact-hand override reason.

151. `testBiddingSimulationReportSummarizesDistribution`
    - Run a deterministic multi-deal simulation using automated players for all seats and verify the report includes bid distribution, pass rate, high-bid samples, candidate suit, `expectedTricks`, `safeBidCeiling`, and any gate that capped each sampled high bid.

### UI Tests

1. `testInitialScreenShowsBottomControls`
   - Launch app and verify `New Game` and `Deal` are visible in the bottom control row.

2. `testInitialScreenDoesNotShowOldDealLabels`
   - Launch app and verify `Deal Cards` and `New Deal` are absent.

3. `testAppRemainsPortrait`
   - Launch app, attempt device rotation in UI test if supported, and verify the app remains in portrait orientation.

4. `testInitialScreenShowsCenteredCardTable`
   - Launch app and verify a circular card table is visible with a diameter equal to half the screen width within acceptable UI-test tolerance.

5. `testInitialScreenShowsTitleOnCardTable`
   - Launch app and verify `طرنيب` appears centered on the card table.

6. `testInitialScreenShowsDeckStackInDealerStation`
   - Launch app and verify a squared 52-card hidden deck stack is visible inside the selected dealer station.

7. `testInitialScreenShowsExactlyOneDealerHighlight`
   - Launch app and verify exactly one station has a small blue `D` pill beside the player name before the first deal.

8. `testInitialDeckStackStaysInsideDealerStationWithEdgeBuffer`
   - Launch app and verify the undealt deck stack remains inside the selected dealer station with a buffer from the station edge.

9. `testInitialScreenShowsRoundedSquarePlayerStationsAroundTable`
   - Launch app and verify South, West, North, and East stations are rounded squares surrounding the table in the required relationship.

10. `testTappingDealShowsHumanHandAfterSouthRevealFlip`
   - Tap `Deal` and verify South card faces are not visible while any hand remains undealt, South's received stack remains visible as fanned backs if South is dealt before the fourth stack, South shows 13 backs after all four hands are dealt, and 13 human card faces are visible only after the 1.5-second left-to-right reveal flip completes.

11. `testTappingDealHidesDealerStationDeckStack`
   - Tap `Deal` and verify the initial undealt deck stack is no longer visible.

12. `testDealerPillAppearsBeforeBiddingAndHidesDuringBidding`
    - Launch app and verify the selected dealer shows a small `D` pill beside the player name, then tap `Deal` and verify the pill hides once bidding starts while dealer metadata remains testable until the next deal request advances the dealer.

13. `testSouthStationExpandsAfterAllHandsDealt`
    - Tap `Deal` and verify the South station displays a fanned stack of backs if South receives cards before the full deal completes, then expands below the card table only after all four hands are dealt, initially holding 13 hidden card backs before the cards flip face-up over 1.5 seconds.

14. `testTappingDealShowsSimulatedPlayerCounts`
    - Tap `Deal` and verify West, North, and East each show 13 hidden cards.

15. `testCardSuitColorsAreVisible`
    - Tap `Deal` and verify red suit styling for Hearts and Diamonds and dark styling for Clubs and Spades using view inspection, snapshot comparison, or equivalent UI verification.

16. `testHiddenCardsUseReadableCardSize`
    - Tap `Deal` and verify hidden card backs use the same base size as exposed South cards.

17. `testSimulatedStationsAreCompact`
    - Tap `Deal` and verify East, North, and West stations occupy only the space needed for labels and hidden card arrays when compared with South.

18. `testDealCompleteAppearsAboveBottomDealButton`
    - Tap `Deal` and verify `Deal complete` appears above the bottom control row only after the South reveal flip completes.

19. `testBiddingAreaAppearsAfterDeal`
    - Tap `Deal` and verify a bordered `Bidding` area appears under the South station only after the South reveal flip completes.

20. `testBidTableShowsAllPlayers`
    - Tap `Deal` and verify station bid chips show South, East, North, and West bid/pass state.

21. `testBidTableInitializesWithPendingValues`
    - Tap `Deal` and verify South, East, North, and West initially show `--`.

22. `testSouthBidChipsAppearOnlyOnSouthTurn`
    - Verify the South `Bid` button is visible but disabled outside South's turn, then advance bidding to South's turn and verify the South bid chips appear.

23. `testSouthBidChipsShowCurrentLegalValues`
    - Advance bidding to South's turn and verify the South bid chips contain `Pass` plus only legal numeric bids from the current minimum through 13.

24. `testSouthTarneebSuitSelectorDoesNotAppearDuringBidding`
    - Verify the South Tarneeb suit selector is absent during non-South in-progress turns and remains absent during South's in-progress bidding turn.

25. `testSouthNumericBidDoesNotRequireSuitDuringBidding`
    - Advance bidding to South's turn, select a numeric bid, and verify `Bid` can be submitted without selecting a Tarneeb suit during the in-progress bidding round.

26. `testSouthBidSelectionUpdatesTableAfterBidButton`
    - Advance bidding to South's turn, select `Pass` or a numeric value, tap `Bid`, and verify the South table entry updates to the bid value and the `Bid` button returns to disabled state unless bidding returns to South.

27. `testBiddingCompletionUpdatesStatusLabel`
    - Complete bidding through a deterministic simulated or South bid sequence and verify the status label displays `Bidding complete`.

28. `testBiddingCompletionHidesSouthBidButton`
    - Complete bidding through a deterministic simulated or South bid sequence and verify the South `Bid` button disappears completely.

29. `testBiddingAreaFadesOutAfterCompletion`
    - Complete bidding through a deterministic sequence and verify the `Bidding` area is removed after the one-second fade-out.

30. `testPostBiddingSummaryDisplaysHighBidderBidAndTarneeb`
    - Complete bidding with a numeric high bid and verify the summary displays the high-bidding player label, the bid value, and the expected `Tarneeb` suit symbol in a compact white chip with black/red suit coloring.

30a. `testSouthPostBiddingSuitSelectionAppearsWhenSouthWins`
    - Complete bidding with South as the numeric high bidder, verify the post-bidding suit-setting panel appears after the `Bidding` area fades, verify its suit chips use white backgrounds with black spades/clubs and red hearts/diamonds, verify the button is labeled `Set`, and verify tapping `Set` stores the selected suit and shows the final summary.

31. `testAllPassBiddingStartsAutomaticRedeal`
    - Complete bidding with all four players passing before any numeric bid is accepted, verify no post-bidding summary appears, verify dealer metadata advances counterclockwise to the previous dealer's right, and verify a fresh deal animation and bidding round begin automatically.

32. `testSimulatedBidValuesAreShown`
    - Tap `Deal` and verify simulated turns resolve automated recommendations to `Pass` or numeric bids from 7 through 13 according to the current highest bid.

33. `testBidValueChangesAnimateWithFadeAndColor`
    - Verify bid value updates use a one-second fade and color transition through UI animation inspection, snapshot timing, or manual QA if automation cannot observe animation reliably, with the current highest numeric bid remaining in the `New Game` button yellow and any superseded previous high transitioning to white.

34. `testSimulatedBidUpdatesTakeAtLeastOneSecond`
    - Verify each West, North, and East bid display update occurs at least one second after that simulated player's turn begins.

35. `testNoUnsupportedGameplayControlsAreShownAfterDeal`
    - Tap `Deal` and verify unsupported play-card, trick, scoring, and post-summary trump editing controls are absent; South's post-bidding Tarneeb suit-setting panel is allowed only when South is the numeric high bidder.

36. `testDealButtonResetsAndDealsAgain`
    - Complete a deal, tap `Deal`, and verify a replacement valid deal is displayed.

37. `testReplacementDealRotatesDealer`
    - Complete a deal, start a replacement deal, and verify dealer state advances counterclockwise within the same game where exposed by UI or test metadata.

38. `testReplacementDealRefreshesBiddingArea`
    - Complete a deal, start a replacement deal, and verify the new completed deal displays a fresh `Bidding` area initialized to `--`.

39. `testNewGameButtonResetsToOriginalLaunchState`
    - Complete a deal, tap `New Game`, and verify dealt cards disappear, any `Deal complete` or `Bidding complete` status disappears, the `Bidding` area disappears, a dealer is selected, the dealer pill appears beside that station's name, the squared undealt deck stack returns inside that dealer station, and the screen remains ready to deal.

40. `testNewGameButtonDoesNotDealFromInitialState`
    - Launch app, tap `New Game`, and verify no hands are dealt and the initial deck stack remains visible.

41. `testSmallScreenLayoutRemainsUsable`
    - Run on a small supported simulator and verify labels, visible cards, hidden cards, bidding area, in-progress South `Bid` button, status label, and available buttons are usable without incoherent overlap.

### Manual Visual QA

1. Verify Hearts and Diamonds are noticeably red and Clubs and Spades are noticeably black or dark.
2. Verify the screen remains portrait when the device rotates.
3. Verify the circular card table is centered and appears about half the screen width.
4. Verify the `طرنيب` title is centered on the card table rather than placed as a large top title.
5. Verify exactly one player station has a small blue `D` pill beside the player name before bidding starts.
6. Verify the initial 52-card deck stack appears as a squared stack inside the selected dealer's player station.
7. Verify the initial deck stack remains inside the dealer station with a buffer from the station edge and does not obscure the table title.
8. Verify the dealer pill identifies the current dealer before bidding, any active bidding highlight is tied only to the current bidding turn, and dealer metadata remains testable until the next deal request advances the dealer.
9. Verify dealer rotation follows South, East, North, West within the same game.
10. Verify player stations read as rounded squares surrounding the table: North top, West left, South bottom, East right.
11. Verify East, North, and West stations look compact compared with the expanded South station after deal.
12. Verify South card faces remain hidden until all four hands are dealt, South's received stack stays visible as fanned backs if it arrives before the full deal completes, then the South station expands with 13 card backs and flips them face-up left-to-right over 1.5 seconds.
13. Verify hidden card backs are the same base size as exposed cards and are large enough to resemble cards.
14. Verify the bottom control row shows `New Game` next to `Deal` before and after dealing.
15. Verify `Deal complete` appears above the bottom control row only after the South reveal flip completes.
16. Verify a bordered `Bidding` area appears under the South station after the deal.
17. Verify the player stations contain bid/pass chips for South, East, North, and West while the `Bidding` area focuses on current turn and South action controls.
18. Verify all bid values begin as `--`.
19. Verify bidding starts with the player to the dealer's right and proceeds counterclockwise.
20. Verify the South `Bid` button is always visible during in-progress bidding, positioned below the South bid value, and disabled unless it is South's turn with a valid submission.
21. Verify the South bid chips allow `Pass` and only currently legal numeric bids through 13.
22. Verify no Tarneeb suit selector appears during the in-progress bidding round.
23. Verify selecting a numeric South bid allows `Bid` without requiring a Tarneeb suit during bidding.
24. Verify selecting `Pass` does not require or store a Tarneeb suit.
25. Verify tapping the South `Bid` button replaces the bid chips with the selected bid value and returns the button to disabled state unless bidding returns to South.
26. Verify simulated turns show `Pass` when the automated numeric recommendation is not higher than the current highest bid.
27. Verify weak simulated hands generally pass, weak long-suit hands without aces do not overbid above 7, and strong long-suit/high-card hands generally produce numeric recommendations.
28. Verify accepted simulated numeric bids store the preferred trump/Tarneeb suit alongside the bid value, South numeric high bids store South's selected suit after the post-bidding `Set` action, and accepted simulated numeric bids also retain confidence metadata without showing a post-summary interactive trump selector.
29. Verify each simulated bid update takes at least one second before the displayed value changes.
30. Verify bid value changes use a one-second fade and color transition, keep the current highest numeric bid in the `New Game` button yellow, and transition a superseded previous high bid to white.
31. Verify the status label updates from `Deal complete` to `Bidding complete` when the bidding round completes.
32. Verify the `Bidding` area fades out over one second after bidding completes.
33. Verify the South `Bid` button disappears completely with the `Bidding` area when the bidding round completes.
34. Verify the post-bidding summary displays the high-bidding player label, the bid value, and `Tarneeb` with the preferred suit symbol in a compact white chip using black for Spades/Clubs and red for Hearts/Diamonds.
35. Verify an all-pass bidding round shows no post-bidding summary, advances the dealer counterclockwise to the previous dealer's right, hides the dealer pill during the fresh bidding round, and starts a fresh deal automatically.
36. Verify the post-bidding South suit-setting panel appears only when South wins numerically, uses a `Set` button, and disappears after the final summary is shown.
37. Verify each player's full hand is logged to the console after a completed deal, including any all-pass automatic redeal.
38. Verify tapping `New Game` after a deal returns the app to the launch state with no dealt cards, no `Bidding` area, no post-bidding summary, a selected dealer, a dealer pill beside the selected station's name, and the squared undealt deck stack visible inside the selected dealer station.

## 11. Definition of Done

The MVP 008 revision is complete when:

- A user can launch the iOS app in portrait orientation.
- A user can tap `Deal`.
- The app creates four Tarneeb seats with one human and three simulated players.
- The app displays a central circular card table with a diameter equal to half the screen width.
- The app displays the `طرنيب` title centered on the card table.
- The app displays four rounded-square player stations surrounding the card table.
- The app randomly selects exactly one dealer for a new game.
- The app displays a squared stack of 52 hidden cards inside the selected dealer's station before the deal.
- The undealt deck stack remains inside the dealer station with an appropriate edge buffer.
- The selected dealer station displays a small blue `D` pill beside the player name using the same color as the `Deal` button and white `D` text.
- Player station outlines remain at the default station outline color for dealer indication.
- The app creates and shuffles a valid 52-card deck without jokers.
- The app deals exactly 13 unique cards to each player.
- The app logs South, East, North, and West hands to the console after each completed deal.
- The app animates four 13-card stack movements from the dealer station, starting with the player on the dealer's right and continuing counterclockwise.
- The undealt deck stack disappears after the deal.
- South card faces remain hidden until all four hands are dealt.
- If South receives its stack before the full deal completes, the South stack remains visible as fanned card backs until final reveal begins.
- After all four hands are dealt, South's station expands to hold 13 card backs and flips the cards face-up from left to right over 1.5 seconds.
- The dealer pill is visible before bidding starts and hidden once bidding starts; dealer identity remains in metadata until the next deal request advances the dealer.
- The dealer rotates counterclockwise within a game using South, East, North, West order.
- The South station remains expanded below the card table after the reveal flip completes.
- A bordered `Bidding` area appears under the South station after the deal.
- Player stations contain South, East, North, and West bid/pass values.
- All bid values begin as `--`.
- Bidding starts with the player to the dealer's right and proceeds counterclockwise.
- Simulated turns generate conservatively calibrated automated hand-strength recommendations, then show a numeric bid only when it is higher than the current highest bid and passes partner-raise rules; otherwise they show `Pass`.
- Accepted numeric bid states store preferred trump/Tarneeb suit alongside the bid value, and accepted simulated numeric bids retain confidence metadata for the post-bidding summary and future trump-selection work.
- Each simulated bid update takes at least one second before the displayed value changes.
- The South bid value can be selected from `Pass` and the currently legal numeric bids through 13 using bid chips only when it is South's turn.
- The South Tarneeb suit can be selected from `♠`, `♣`, `♥`, and `♦` only after bidding completes and only when South is the numeric high bidder.
- South numeric bids do not require a selected Tarneeb suit before the `Bid` button commits the in-progress bid.
- South `Pass` submissions do not require or store a Tarneeb suit.
- A South `Bid` button is always visible while bidding is in progress, is positioned below the South bid value, is enabled only while it is South's turn with a valid submission, and is disabled otherwise.
- After South submits a bid, the South bid chips are replaced by the selected bid value and the `Bid` button returns to disabled state unless bidding returns to South.
- If any player bids `13`, all other bid values become `Pass` and bidding ends.
- When bidding ends, the status label updates from `Deal complete` to `Bidding complete`.
- When bidding ends, the `Bidding` area fades out over one second and then disappears.
- When bidding ends with a numeric high bid by East, North, or West, the post-bidding summary displays the high-bidding player label, the high bid value, and `Tarneeb` with the preferred suit symbol.
- When bidding ends with South as the numeric high bidder, a post-bidding suit-setting panel appears first with suit chips and a `Set` button, then the final post-bidding summary appears after South sets the suit.
- When all four players pass before any numeric bid is accepted, no post-bidding summary appears and a fresh deal starts automatically with the dealer advanced counterclockwise to the previous dealer's right.
- When bidding ends, the South `Bid` button disappears completely with the `Bidding` area.
- Bid value changes use a one-second fade and color transition, with the current highest numeric bid remaining in the `New Game` button yellow and any superseded previous high transitioning to white.
- The human player can see only their own hand.
- Simulated players' cards remain hidden.
- The app clearly indicates that the deal is complete only after the South reveal flip completes.
- `Deal complete` appears above the bottom control row after the deal completes and before bidding completes.
- `Bidding complete` replaces `Deal complete` above the bottom control row when bidding completes.
- The bottom controls include `New Game` and `Deal`.
- The `Deal` action starts the first deal and replacement deals.
- The `New Game` action resets the app to a launch state without immediately dealing.
- The app displays player stations in the required table-surrounding layout.
- Hearts and Diamonds are rendered in red.
- Clubs and Spades are rendered in black or another high-contrast dark color.
- Hidden and exposed cards use the same readable standard-card base size.
- East, North, and West stations are compact while remaining usable.
- No post-summary editable Tarneeb suit selection, trick play, scoring, or other post-bidding gameplay is implemented.
- Automated tests verify the core dealing requirements.
- Automated tests verify the allowed bid values, bidding turn order, simulated bid resolution, simulated-player personality adjustments using the normal estimate, South bid submission, post-bidding South Tarneeb suit setting, and bidding completion rules.
- Automated tests verify post-bidding summary derivation, all-pass automatic redeal behavior, and hand logging.
- Automated or manual visual checks verify the 005 portrait table, rounded-square station, dealer selection, dealer pill, dealer-station squared undealt deck stack, bidding area, bottom controls, reset behavior, and card readability changes.
- Automated or manual visual checks verify the deal animation shows 13-card stacks moving from the dealer station, simulated stations showing hidden backs after arrival, South card faces remaining hidden until all four hands are dealt while any received South stack remains visible as fanned backs, South backs flipping face-up left-to-right over 1.5 seconds, and the source deck stack disappearing after all 52 cards are dealt.

## 12. Open Ambiguities

- Exact card dimensions in points are not specified. The implementation should choose responsive dimensions that approximate a 5:7 playing-card aspect ratio and satisfy readability on supported device sizes.
- The minimum required small-screen simulator is not specified. Use the smallest simulator supported by the project unless product specifies a stricter target.
- Exact red and black/dark color values are not specified. Use platform-appropriate colors unless product provides design tokens.
- Exact simulated hidden-hand stack spread distance is not specified. The spread should conserve space while still representing the required number of hidden cards.
- South reveal flip duration is specified as 1.5 seconds.
- Exact undealt deck stack offset and rotation are not specified beyond a squared appearance while still representing 52 hidden cards; MVP 008 uses tokenized zero offset and zero rotation.
- Exact rounded-square station dimensions and corner radius are not specified.
- Exact card table vertical position is not specified beyond being centered in the main table area.
- Exact tolerance for "half the screen width" is not specified for UI tests.
- Exact station-edge buffer for dealer-station undealt deck placement is not specified.
- Exact dealer pill padding is not specified beyond beside-name placement, `Deal` button color, white `D` text, and not obscuring the player name.
- The requirements place the `طرنيب` title at the card table center and the undealt deck stack inside the dealer station; the undealt deck must not obscure the title before the deal.
- It is not specified whether the dealer affects deal assignment order or only dealer indication and rotation.
- It is not specified whether tapping `New Game` while already in the initial `notStarted` state should re-randomize the dealer or keep the current selected dealer.
- It is not specified whether replacement deals or all-pass automatic redeals should show an intermediate pre-deal state with the next dealer pill and dealer-station squared undealt deck, or whether they remain immediate while dealer rotation is verified through state/test metadata.
- Exact deal-animation duration, easing curve, and whether the dealer-station source stack count visibly decrements during each flight are not specified.
- "Dealer's right" is interpreted as the next seat in the existing counterclockwise dealer rotation order.
- Existing requirements say dealer indication and rotation do not alter card assignment order; the animation follows dealer-relative visual order while the validated deal assignment remains the existing 13-card chunk assignment.
- It is not specified whether the bottom control row should be fixed to the safe-area bottom or to the bottom of scrollable content. Treat it as bottom safe-area aligned unless product specifies otherwise.
- It is not specified whether the 52-card undealt deck stack should animate away during deal. MVP 008 requires that it is present in the dealer station before deal, can decrement during the deal, and is absent after deal.
- Exact `Bidding` area dimensions, border color, table styling, and spacing below the South station are not specified.
- Exact aggregate bid metadata order is not specified. Use the existing counterclockwise model order South, East, North, West unless product specifies another order.
- Exact South Tarneeb suit selector control type is specified as a chip-style post-bidding selector for MVP 008, but exact chip dimensions beyond the tokenized minimums and compact summary symbol padding are not specified.
- Exact easing for bid value fade/color transitions is not specified; the transition duration is one second, the current highest numeric bid remains in the same yellow used for the `New Game` button, and any superseded previous high bid transitions to white.
