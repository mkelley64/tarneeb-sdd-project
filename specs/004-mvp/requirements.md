# Tarneeb iOS MVP 004 Requirements

## 1. Purpose

Build an iOS application MVP for the card game Tarneeb that allows one human player to start a game by dealing cards. The other three players are simulated seats. This MVP ends immediately after a valid deal is completed and displayed, while allowing the player to request a replacement deal or reset the screen to a launch state. No bidding, trump/Tarneeb suit selection, trick play, scoring, multiplayer, persistence, or AI decision-making is included.

This 004 revision keeps the original deal-only gameplay boundary, carries forward the MVP 002 card readability and station sizing requirements, carries forward the MVP 003 portrait card-table changes, and adds dealer selection, dealer indication, very-centered squared undealt deck placement, counterclockwise dealer rotation, and a sequential deal animation.

## 2. Source Rules

This MVP is based on the Tarneeb rules published by Jawaker:

- Tarneeb is a four-player partnership card game.
- Players sit across from each other, forming two teams.
- The game uses a standard 52-card deck with no jokers.
- Play proceeds counterclockwise.
- Each player is dealt 13 cards.

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
- When cards are dealt, the South station should expand below the card table to display the revealed cards.
- When the game begins, the deck should be represented as a squared stack of 52 hidden cards at the very center of the card table.
- When the cards are dealt, the undealt deck stack should disappear.
- The Arabic title `طرنيب` should be centered on the card table; before the deal, it may be visually obscured by the initial deck stack.
- The `طرنيب` title should use the tokenized table-title style defined in `design-tokens.md`, including the specified Arabic rounded font, 26pt size, tracking range, text color/opacity, and subtle shadow.
- Initial and replacement deal actions should both be labeled `Deal`.
- The `Deal` button should be at the very bottom of the screen.
- The `Deal complete` label should appear above the bottom control row after a completed deal.
- The `New Game` button should appear next to `Deal` at the bottom of the screen and restore the app to the same not-started state shown at launch.

### 3.4 MVP 004 Requirement Changes Integrated

- For a new game, one of the four players should be selected as the dealer.
- New-game dealer selection should be random.
- Before the deal, the undealt 52-card deck should always be displayed at the very center of the card table.
- The undealt deck should have a squared appearance before the deal.
- The undealt deck should remain on the card table and maintain an appropriate buffer from the card table edge.
- Do not change the selected dealer's station outline color to indicate the dealer.
- The selected dealer should be indicated by a small circular badge in the upper-left corner of the dealer's player station.
- The dealer badge should use the same color as the `Deal` button and contain a white `D`.
- The dealer badge should remain visible on the current dealer's station until the next deal request advances the dealer.
- Within a game, the dealer should rotate counterclockwise between deals.
- The counterclockwise dealer rotation order should be South, East, North, West, then back to South.

### 3.5 MVP 004 Deal Animation Requirement Change

- When `Deal` is pressed, a 13-card hidden stack should move from the center of the card table to the player on the dealer's right.
- After the 13-card stack arrives, that player station should animate to its final dealt size and reveal the final enclosed 13-card display for that station.
- The deal animation should continue counterclockwise around the table until all four players have received 13 cards.
- When all 52 cards have been dealt, the center deck stack should be gone and the completed deal state should be shown.

## 4. MVP Scope

### In Scope

- Launch an iOS app locked to portrait orientation.
- Show a start screen for a single human player.
- Display a circular card table centered on the screen with a diameter equal to half the screen width.
- Display the Arabic title `طرنيب` centered on the card table.
- Randomly select one of the four players as dealer when a new game begins.
- Display a squared stack of 52 hidden cards at the very center of the card table before a deal completes.
- Keep the undealt deck stack inside the card table with an appropriate buffer from the table edge.
- Animate the deal in four 13-card stack movements from the table center, starting with the player on the dealer's right and continuing counterclockwise around the table.
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
- Create two partnerships:
  - Team A: South + North
  - Team B: East + West
- Create a standard 52-card deck excluding jokers.
- Shuffle the deck.
- Deal 13 cards to each of the four players in 13-card chunks.
- Reveal each station's final 13-card display after its animated 13-card stack arrives.
- Display the human player's 13-card hand after the deal.
- Expand the South station below the card table after the deal to display the human player's revealed cards.
- Display simulated players as having 13 hidden cards each after the deal.
- Remove the undealt 52-card deck stack after the deal.
- Display the dealer using a small circular `D` badge in the upper-left corner of the dealer's player station.
- Keep player station outlines at the default station outline color for dealer indication.
- Keep the dealer badge visible on the current dealer's station until the next deal request advances the dealer.
- Rotate the dealer counterclockwise within a game using the order South, East, North, West.
- Show that the deal is complete.
- Place the `Deal complete` label above the bottom control row after the deal.
- Use a bottom `Deal` action for both the first deal and replacement deals.
- Display a bottom `New Game` action next to `Deal`.
- Reset the app to a launch state when `New Game` is tapped.
- Prevent gameplay beyond the completed deal.
- Display card faces with red Hearts and Diamonds and dark Spades and Clubs.
- Keep East, North, and West stations compact while preserving readable labels and hidden card backs.
- Use the same readable standard-card base size for exposed cards and hidden cards.

### Out of Scope

- Bidding.
- Passing.
- Choosing the Tarneeb suit.
- Playing tricks.
- Determining trick winners.
- Scoring.
- Ending a full game.
- Online multiplayer.
- Local multiplayer.
- User accounts.
- Saved games.
- Advanced AI behavior.
- Animations beyond the specified 13-card stack deal sequence.
- Sound effects.
- Landscape layout support.
- Accessibility beyond standard iOS controls for this MVP.
- Error handling beyond preventing invalid completed deal states.
- Custom card art beyond the provided card back and simple rank/suit card faces.

## 5. Product Requirements

### PRD-001: App Launch

As a human player, I want to open the app and see a clear way to start a new Tarneeb deal.

#### Acceptance Criteria

- Given the app is launched, when the initial screen appears, then the app title `طرنيب` is centered on the card table; it may be visually obscured by the undealt deck before the deal.
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
- Given the user taps `Deal`, then the app animates four 13-card stack movements from the center of the card table before the deal is complete.
- Given the deal animation begins, then the first 13-card stack moves to the player on the current dealer's right.
- Given each 13-card stack arrives at a station, then that station animates to its final dealt size and displays its enclosed 13-card hand presentation.
- Given the first animated stack has arrived, then the next 13-card stack moves counterclockwise to the next station.
- Given the deal completes, then all 52 cards have been assigned to players.
- Given the deal completes, then no card appears in more than one player's hand.
- Given the deal completes, then no cards remain undealt.
- Given the deal completes, then the app records the deal state as `Dealt`.
- Given the deal completes, then the undealt 52-card deck stack is no longer visible.
- Given the deal completes, then all player station outlines remain the default station outline color.
- Given the deal completes, then the dealer badge remains visible on the current dealer's station until the next deal request advances the dealer.

### PRD-015: Deal Animation

As a human player, I want the deal to visibly travel around the table so the transition from undealt deck to four completed hands feels like a real Tarneeb deal.

#### Acceptance Criteria

- Given the current dealer is selected, when `Deal` is tapped, then the first animated 13-card stack starts at the center deck and targets the player on the dealer's right.
- Given the first animated stack has arrived, then the target station animates to its final dealt size and shows its final 13-card hand display.
- Given a station has received its animated stack, then the next 13-card stack starts from the center deck and targets the next player counterclockwise.
- Given the current dealer is South, then the animation target order is East, North, West, South.
- Given the current dealer is East, then the animation target order is North, West, South, East.
- Given the current dealer is North, then the animation target order is West, South, East, North.
- Given the current dealer is West, then the animation target order is South, East, North, West.
- Given the fourth 13-card stack arrives, then the center deck stack is removed and the completed deal state is displayed.
- Given a deal animation is in progress, then overlapping `Deal` or `New Game` actions are prevented until the animation resolves.

### PRD-006: Human Hand Display

As a human player, I want to see my own cards after the deal and clearly distinguish card suits.

#### Acceptance Criteria

- Given the deal completes, then the South player's 13 cards are visible to the user.
- Given the deal completes, then the South station expands below the card table to display the revealed cards.
- Given the South hand is visible, then each card displays its suit and rank using a suit symbol plus a number or rank letter.
- Given the South hand is visible, then Hearts and Diamonds display rank and suit in red.
- Given the South hand is visible, then Clubs and Spades display rank and suit in black or another high-contrast dark color that is clearly distinct from red.
- Given the South hand is visible, then the hand is sorted by suit in this order: Hearts, Clubs, Diamonds, Spades.
- Given cards share the same suit, then the cards are sorted by rank from 2 through Ace.
- Given the South hand is visible, then exposed cards use a standard playing-card aspect ratio and are large enough for rank and suit to be readable on supported device sizes.
- Given the South hand is visible, then exposed cards fit within the South player station without overlapping unrelated UI.
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

As a human player, I want to know when the deal has completed.

#### Acceptance Criteria

- Given all cards have been dealt, then the app displays `Deal complete`.
- Given `Deal complete` is displayed, then it appears above the bottom control row.
- Given the deal is complete, then no bidding UI is shown.
- Given the deal is complete, then no gameplay controls are shown.
- Given the deal is complete, then the user may start a replacement deal using the bottom `Deal` action.
- Given the deal is complete, then the user may reset to a launch state using the bottom `New Game` action.

### PRD-009: Replacement Deal

As a human player, I want to start over with a fresh deal.

#### Acceptance Criteria

- Given a deal is complete, when the user taps `Deal`, then the previous hands are cleared.
- Given a replacement deal starts within the same game, then the dealer advances counterclockwise from the previous dealer.
- Given a replacement deal starts, then a fresh 52-card deck is created or the previous full deck is reset.
- Given a replacement deal starts, then the deck is shuffled before dealing.
- Given the replacement deal completes, then each player again has exactly 13 cards.
- Given the replacement deal completes, then the portrait table layout, rounded-square stations, and card sizing requirements still apply.
- Given the replacement deal completes, then the available action remains labeled `Deal`.

### PRD-010: Central Card Table

As a human player, I want the screen to include a central card table so the seats are easy to understand.

#### Acceptance Criteria

- Given the table is displayed, then a circular card table appears in the center area of the screen.
- Given the circular card table is displayed, then its diameter is half the screen width.
- Given the initial table is displayed, then the Arabic title `طرنيب` appears centered on the card table.
- Given the initial deck stack is displayed, then its center point aligns with the center point of the circular card table within layout tolerance.
- Given the initial deck stack is displayed, then it remains inside the circular card table with an appropriate buffer from the table edge.
- Given the initial table is displayed, then a squared stack of 52 hidden cards appears at the very center of the card table.
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
- Given the table is displayed after a deal, then East, North, and West stations remain visually compact when screen space allows.
- Given the table is displayed, then required labels, cards, message text, and bottom controls remain usable and do not overlap each other.
- Given the table is displayed on a small supported simulator, then all four player stations, the deal completion message, and the available bottom controls remain usable.

### PRD-012: Bottom Controls

As a human player, I want the deal and reset actions to remain easy to reach and consistently named.

#### Acceptance Criteria

- Given the initial screen is displayed, then the `Deal` button appears at the very bottom of the screen.
- Given the deal completes, then the `Deal` button remains at the very bottom of the screen.
- Given the deal completes, then the `Deal complete` label appears above the bottom control row.
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
- Given the app resets to `notStarted`, then the squared 52-card undealt deck stack is visible again at the very center of the card table.
- Given the app resets to `notStarted`, then the South visible cards and simulated hidden hands are no longer displayed.
- Given the app resets to `notStarted`, then the `Deal complete` label is no longer displayed.
- Given the initial screen is displayed, when the user taps `New Game`, then the screen remains in `notStarted` and no deal starts.

### PRD-014: Dealer Selection and Rotation

As a human player, I want to see which player is dealing so the table state resembles a real Tarneeb game.

#### Acceptance Criteria

- Given a new game begins, then exactly one of South, East, North, and West is selected as dealer.
- Given a new game begins, then the dealer selection is random.
- Given a dealer is selected before a deal, then the undealt 52-card deck stack appears at the very center of the card table.
- Given the undealt deck stack is displayed, then the stack remains inside the circular card table with an appropriate buffer from the table edge.
- Given the undealt deck stack is displayed before the deal, then it has a squared appearance.
- Given a dealer is selected, then the app displays a small circular badge in the upper-left corner of the dealer's player station.
- Given the dealer badge is displayed, then the badge uses the same color as the `Deal` button and contains a white `D`.
- Given a deal completes, then all player station outlines remain the default station outline color.
- Given a deal completes, then the dealer badge remains visible on the current dealer's station until the next deal request advances the dealer.
- Given a replacement deal starts within the same game, then the dealer rotates counterclockwise from the previous dealer.
- Given the current dealer is South, then the next dealer is East.
- Given the current dealer is East, then the next dealer is North.
- Given the current dealer is North, then the next dealer is West.
- Given the current dealer is West, then the next dealer is South.

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

No other game phases should be implemented for MVP 004 unless the replacement-dealer visibility ambiguity in section 12 is resolved by a later requirement.

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

- The selected dealer station must show a small circular badge in its upper-left corner.
- The dealer badge must use the same color as the `Deal` button and contain a white `D`.
- The selected dealer station outline must remain the default station outline color.
- The undealt 52-card deck stack must appear at the very center of the card table.
- The undealt deck stack must have a squared appearance before the deal.
- The undealt deck stack must remain inside the circular card table with an appropriate buffer from the table edge.

After a deal completes:

- All player station outlines must remain the default station outline color.
- The dealer badge must remain visible on the current dealer's station until the next deal request advances the dealer.
- The undealt deck stack must disappear.
- The selected dealer must remain in game state for rotation purposes and badge display.

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
8. Keep the current dealer badge visible until the next deal request advances the dealer.

### 6.7 Card Presentation Rules

- Exposed cards must show rank and suit.
- Hearts and Diamonds must render rank and suit in red.
- Clubs and Spades must render rank and suit in black or another high-contrast dark color that is clearly distinct from red.
- Exposed cards and hidden card backs must share the same base dimensions.
- Cards should use a standard playing-card aspect ratio, approximately 5:7 width to height.
- Card sizing may adapt to device size, but exposed card text must remain readable and hidden cards must not be scaled smaller than exposed cards.
- Hidden cards must use the provided `card_back.png` asset.
- Hidden card stacks may overlap slightly to conserve space.
- The initial undealt deck stack must represent 52 hidden cards without revealing rank or suit information.

### 6.8 Layout Behavior

- The app must be locked to portrait orientation.
- The screen must include a circular card table centered in the main table area.
- The circular card table diameter must be half the screen width.
- The Arabic title `طرنيب` must be centered on the card table.
- The title must remain centered on the table, but the initial undealt deck stack may overlap or obscure it before the deal.
- Before a deal completes, a squared stack of 52 hidden cards must appear at the very center of the card table.
- The undealt deck stack must stay inside the circular card table with an appropriate buffer from the table edge.
- After a deal completes, the undealt deck stack must disappear.
- Player stations must be rounded squares surrounding the card table.
- The dealer station outline must remain the default station outline color.
- The dealer station must display a small circular badge in the upper-left corner, using the same color as the `Deal` button and a white `D`.
- The dealer badge must remain visible on the current dealer's station until the next deal request advances the dealer.
- The South station may expand below the card table after a deal because it displays the human player's full visible hand.
- North, West, and East stations must be compact and sized around their label plus hidden card array.
- The bottom controls must include `Deal` and `New Game` in both initial and dealt states.
- The bottom `Deal` and `New Game` buttons must appear in the bottom control row at the very bottom of the screen.
- The `Deal complete` label must appear above the bottom control row after a deal completes.
- Tapping `New Game` must restore the launch state without immediately dealing.
- The layout must avoid overlapping labels, card faces, card backs, completion message text, and action buttons.
- On smaller supported screens, the layout may scale spacing or use scrolling if needed, but it must preserve the North, West, South, and East relationship around the card table and keep the bottom controls usable.

## 7. UI Requirements

### 7.1 Initial Screen

The initial screen must include:

- Portrait orientation only.
- A circular card table centered in the main table area.
- A card table diameter equal to half the screen width.
- App title `طرنيب` centered on the card table.
- Exactly one randomly selected dealer.
- A small circular dealer badge in the upper-left corner of the selected dealer station, using the `Deal` button color with a white `D`.
- Default station outlines for all player stations.
- A squared stack of 52 hidden cards at the very center of the card table, with a buffer from the table edge.
- Four rounded-square player station labels surrounding the card table.
- North above the table, West left of the table, South below the table, and East right of the table.
- Bottom control row with reset button `New Game` and primary button `Deal`.
- No visible dealt player hands before the first deal.
- No `Deal Cards` or `New Deal` action labels.

### 7.2 Dealt Table Screen

After dealing, the screen must include:

- Portrait orientation only.
- The circular card table and surrounding player stations.
- No undealt 52-card deck stack.
- South human player station expanded below the card table with 13 visible cards.
- West, North, and East simulated players with 13 hidden card backs each.
- All player station outlines remain the default station outline color.
- The current dealer station continues to show the small circular `D` badge until the next deal request advances the dealer.
- Red rank and suit styling for Hearts and Diamonds.
- Dark rank and suit styling for Clubs and Spades.
- Exposed and hidden cards using the same base size and standard-card aspect ratio.
- Compact West, North, and East stations.
- `Deal complete` label above the bottom control row.
- Bottom buttons labeled `New Game` and `Deal`.
- No `Deal Cards` or `New Deal` action labels.

### 7.3 Prohibited MVP UI

The MVP must not show:

- Bid controls.
- Pass controls.
- Trump/Tarneeb suit selector.
- Play-card controls.
- Trick area.
- Scoreboard.
- Game-over state.
- Landscape-only layout.

## 8. Non-Functional Requirements

### NFR-001: Platform

- The app must target iOS.
- The app must be locked to portrait orientation for MVP 004.
- SwiftUI is recommended unless the implementation plan specifies otherwise.

### NFR-002: Responsiveness

- The deal should complete quickly enough to feel immediate to the user.
- The UI must remain responsive after dealing.
- Visual layout and card sizing changes must not introduce noticeable blocking during deal, replacement deal, or reset actions.

### NFR-003: Testability

- Deck creation, shuffle preservation of uniqueness, player setup, and dealing must be testable independently of the UI.
- The card dealing logic should be isolated from SwiftUI views.
- Card presentation mapping for suit color should be testable independently where practical.
- Layout-critical UI elements should have stable accessibility identifiers or labels so UI tests can verify visibility and interaction.
- The initial 52-card deck stack should be exposed in a way that UI tests can verify its presence before a deal, very-centered table placement, squared-stack geometry appearance, table-edge buffer, and absence after a deal.
- Dealer selection, dealer rotation, and dealer badge state should be testable independently of SwiftUI where practical.
- The bottom `Deal`, `New Game`, and `Deal complete` controls should be exposed in a way that UI tests can verify their relative placement and reset behavior.

### NFR-004: Reliability

- The app must never produce duplicate cards in a completed deal.
- The app must never produce fewer or more than 13 cards per player in a completed deal.
- The app must never include jokers.

### NFR-005: Visual Usability

- Red suits and black/dark suits must be visually distinguishable.
- Exposed card ranks and suits must be readable on supported device sizes.
- Hidden card backs must be large enough to resemble cards rather than unreadable icons.
- Required UI must remain usable on at least one small-screen simulator supported by the project.
- The central table, very-centered squared deck stack, rounded-square stations, dealer badge, bottom controls, and completion label must not overlap incoherently.

## 9. Edge Cases and Constraints

- If a replacement deal is requested after a completed deal, the previous hands must be cleared before the replacement deal is shown.
- If `New Game` is requested after a completed deal, the previous hands must be cleared, the game phase must return to `notStarted`, `Deal complete` must be hidden, a dealer must be selected for the new game, the dealer badge must appear on the selected dealer station, and the squared undealt deck stack must reappear at the very center of the card table.
- If `New Game` is requested from the initial screen, the app should remain in `notStarted` and should not start a deal.
- If random dealer selection is performed, the selected dealer must always be one of South, East, North, or West.
- If the current dealer rotates after West, the next dealer must wrap to South.
- If the app creates or resets a deck for a replacement deal, the completed deal must still contain exactly 52 unique assigned cards.
- If hidden card backs are visually overlapped, no rank or suit information may be exposed for simulated players.
- The initial undealt 52-card deck stack must be centered on the card table and remain inside the card table with an appropriate table-edge buffer; it may overlap or obscure the `طرنيب` title before the deal.
- Dealer indication must not change any player station outline to blue.
- The current dealer badge must remain visible after a completed deal and must move only when the next deal request advances the dealer.
- If a small portrait screen cannot fit the full table without adjustment, the UI may reduce spacing or allow scrolling, but it must keep all required controls and stations usable.
- If the South station expands after a deal, it must not make the bottom `Deal`, `New Game`, or `Deal complete` controls unusable.
- If card size adapts to screen size, hidden card backs and exposed card faces must adapt together so they remain the same base size.
- If color values are implemented through system colors, the visual distinction between red suits and black/dark suits must remain clear in the supported appearance mode.
- If a device is physically rotated, the app should remain in portrait orientation for MVP 004.

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
    - Verify the initial presentation model represents 52 hidden cards in the undealt deck stack at the very center of the card table with squared-stack geometry metadata, if modeled outside SwiftUI.

16. `testNewGameResetsPresentationToLaunchState`
    - Complete a deal, invoke the reset action, and verify the phase returns to `notStarted`, hands are cleared, a dealer is selected, the dealer badge appears on the selected dealer station, the squared undealt deck stack is visible at the very center of the card table, and the completion label is hidden.

17. `testNewGameSelectsExactlyOneDealer`
    - Verify a new game selects exactly one dealer from South, East, North, and West.

18. `testDealerSelectionUsesRandomSource`
    - Verify new-game dealer selection can use an injected random source and does not hard-code one seat.

19. `testDealerRotatesCounterclockwise`
    - Verify dealer rotation proceeds South, East, North, West, then South.

20. `testDealerBadgePresentationState`
    - Verify the selected dealer uses a small circular `D` badge, the badge uses the `Deal` button color with white text, the player station outline remains default, and the badge remains visible until the next deal request advances the dealer.

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

6. `testInitialScreenShowsDeckStackOnCardTable`
   - Launch app and verify a squared 52-card hidden deck stack is visible at the very center of the card table.

7. `testInitialScreenShowsExactlyOneDealerHighlight`
   - Launch app and verify exactly one station has the circular dealer `D` badge before the first deal.

8. `testInitialDeckStackStaysInsideTableWithEdgeBuffer`
   - Launch app and verify the undealt deck stack remains inside the circular card table with a buffer from the table edge.

9. `testInitialScreenShowsRoundedSquarePlayerStationsAroundTable`
   - Launch app and verify South, West, North, and East stations are rounded squares surrounding the table in the required relationship.

10. `testTappingDealShowsHumanHand`
   - Tap `Deal` and verify 13 human cards are visible.

11. `testTappingDealHidesCentralDeckStack`
   - Tap `Deal` and verify the initial undealt deck stack is no longer visible.

12. `testDealerBadgeRemainsUntilNextDeal`
    - Tap `Deal` and verify player station outlines remain default and the dealer badge remains visible until the next deal request advances the dealer.

13. `testSouthStationExpandsAfterDeal`
    - Tap `Deal` and verify the South station expands below the card table to display the revealed cards.

14. `testTappingDealShowsSimulatedPlayerCounts`
    - Tap `Deal` and verify West, North, and East each show 13 hidden cards.

15. `testCardSuitColorsAreVisible`
    - Tap `Deal` and verify red suit styling for Hearts and Diamonds and dark styling for Clubs and Spades using view inspection, snapshot comparison, or equivalent UI verification.

16. `testHiddenCardsUseReadableCardSize`
    - Tap `Deal` and verify hidden card backs use the same base size as exposed South cards.

17. `testSimulatedStationsAreCompact`
    - Tap `Deal` and verify East, North, and West stations occupy only the space needed for labels and hidden card arrays when compared with South.

18. `testDealCompleteAppearsAboveBottomDealButton`
    - Tap `Deal` and verify `Deal complete` appears above the bottom control row.

19. `testNoGameplayControlsAreShownAfterDeal`
    - Tap `Deal` and verify bid, pass, trump selection, play-card, trick, and scoring controls are absent.

20. `testDealButtonResetsAndDealsAgain`
    - Complete a deal, tap `Deal`, and verify a replacement valid deal is displayed.

21. `testReplacementDealRotatesDealer`
    - Complete a deal, start a replacement deal, and verify dealer state advances counterclockwise within the same game where exposed by UI or test metadata.

22. `testNewGameButtonResetsToOriginalLaunchState`
    - Complete a deal, tap `New Game`, and verify dealt cards disappear, `Deal complete` disappears, a dealer is selected, the dealer badge appears on that station, the squared undealt deck stack returns to the very center of the card table, and the screen remains ready to deal.

23. `testNewGameButtonDoesNotDealFromInitialState`
    - Launch app, tap `New Game`, and verify no hands are dealt and the initial deck stack remains visible.

24. `testSmallScreenLayoutRemainsUsable`
    - Run on a small supported simulator and verify labels, visible cards, hidden cards, completion message, and available buttons are usable without incoherent overlap.

### Manual Visual QA

1. Verify Hearts and Diamonds are noticeably red and Clubs and Spades are noticeably black or dark.
2. Verify the screen remains portrait when the device rotates.
3. Verify the circular card table is centered and appears about half the screen width.
4. Verify the `طرنيب` title is centered on the card table rather than placed as a large top title.
5. Verify exactly one player station has the circular dealer `D` badge.
6. Verify the initial 52-card deck stack appears as a squared stack at the very center of the card table.
7. Verify the initial deck stack remains inside the circular table with a buffer from the table edge; title overlap or obscuring by the deck is allowed before the deal.
8. Verify all player station outlines remain default and the dealer badge remains visible until the next deal request advances the dealer.
9. Verify dealer rotation follows South, East, North, West within the same game.
10. Verify player stations read as rounded squares surrounding the table: North top, West left, South bottom, East right.
11. Verify East, North, and West stations look compact compared with the expanded South station after deal.
12. Verify the South station expands below the card table after deal and exposed cards remain readable.
13. Verify hidden card backs are the same base size as exposed cards and are large enough to resemble cards.
14. Verify the bottom control row shows `New Game` next to `Deal` before and after dealing.
15. Verify `Deal complete` appears above the bottom control row.
16. Verify tapping `New Game` after a deal returns the app to the launch state with no dealt cards, a selected dealer, a dealer badge on the selected station, and the squared undealt deck stack visible at the very center of the card table.

## 11. Definition of Done

The MVP 004 revision is complete when:

- A user can launch the iOS app in portrait orientation.
- A user can tap `Deal`.
- The app creates four Tarneeb seats with one human and three simulated players.
- The app displays a central circular card table with a diameter equal to half the screen width.
- The app displays the `طرنيب` title centered on the card table.
- The app displays four rounded-square player stations surrounding the card table.
- The app randomly selects exactly one dealer for a new game.
- The app displays a squared stack of 52 hidden cards at the very center of the card table before the deal.
- The undealt deck stack remains inside the circular card table with an appropriate edge buffer.
- The selected dealer station displays a small circular `D` badge in the upper-left corner, using the same color as the `Deal` button with white text.
- Player station outlines remain at the default station outline color for dealer indication.
- The app creates and shuffles a valid 52-card deck without jokers.
- The app deals exactly 13 unique cards to each player.
- The app animates four 13-card stack movements from the table center, starting with the player on the dealer's right and continuing counterclockwise.
- The undealt deck stack disappears after the deal.
- The dealer badge remains visible on the current dealer's station until the next deal request advances the dealer.
- The dealer rotates counterclockwise within a game using South, East, North, West order.
- The South station expands below the card table after the deal.
- The human player can see only their own hand.
- Simulated players' cards remain hidden.
- The app clearly indicates that the deal is complete.
- `Deal complete` appears above the bottom control row.
- The bottom controls include `New Game` and `Deal`.
- The `Deal` action starts the first deal and replacement deals.
- The `New Game` action resets the app to a launch state without immediately dealing.
- The app displays player stations in the required table-surrounding layout.
- Hearts and Diamonds are rendered in red.
- Clubs and Spades are rendered in black or another high-contrast dark color.
- Hidden and exposed cards use the same readable standard-card base size.
- East, North, and West stations are compact while remaining usable.
- No bidding, Tarneeb suit selection, trick play, scoring, or other gameplay is implemented.
- Automated tests verify the core dealing requirements.
- Automated or manual visual checks verify the 004 portrait table, rounded-square station, dealer selection, dealer badge, very-centered squared undealt deck stack, bottom controls, reset behavior, and card readability changes.
- Automated or manual visual checks verify the deal animation shows 13-card stacks moving from the table center, stations revealing after arrival, and the center stack disappearing after all 52 cards are dealt.

## 12. Open Ambiguities

- Exact card dimensions in points are not specified. The implementation should choose responsive dimensions that approximate a 5:7 playing-card aspect ratio and satisfy readability on supported device sizes.
- The minimum required small-screen simulator is not specified. Use the smallest simulator supported by the project unless product specifies a stricter target.
- Exact red and black/dark color values are not specified. Use platform-appropriate colors unless product provides design tokens.
- Exact simulated hidden-hand stack spread distance is not specified. The spread should conserve space while still representing the required number of hidden cards.
- Exact undealt deck stack offset and rotation are not specified beyond a squared appearance while still representing 52 hidden cards; MVP 004 uses tokenized zero offset and zero rotation.
- Exact rounded-square station dimensions and corner radius are not specified.
- Exact card table vertical position is not specified beyond being centered in the main table area.
- Exact tolerance for "half the screen width" is not specified for UI tests.
- Exact table-edge buffer for very-centered undealt deck placement is not specified.
- Exact dealer badge size, inset, and typography are not specified beyond small circular shape, upper-left station placement, `Deal` button color, and white `D`.
- The requirements place both the `طرنيب` title and the undealt deck stack at the card table center; the undealt deck may overlap or obscure the title before the deal.
- It is not specified whether the dealer affects deal assignment order or only dealer indication and rotation.
- It is not specified whether tapping `New Game` while already in the initial `notStarted` state should re-randomize the dealer or keep the current selected dealer.
- It is not specified whether replacement deals should show an intermediate pre-deal state with the next dealer badge and very-centered squared undealt deck, or whether replacement deals remain immediate while dealer rotation is verified through state/test metadata.
- Exact deal-animation duration, easing curve, and whether the center stack count visibly decrements during each flight are not specified.
- "Dealer's right" is interpreted as the next seat in the existing counterclockwise dealer rotation order.
- Existing requirements say dealer indication and rotation do not alter card assignment order; the animation follows dealer-relative visual order while the validated deal assignment remains the existing 13-card chunk assignment.
- It is not specified whether the bottom control row should be fixed to the safe-area bottom or to the bottom of scrollable content. Treat it as bottom safe-area aligned unless product specifies otherwise.
- It is not specified whether the 52-card undealt deck stack should animate away during deal. MVP 004 only requires that it is present before deal and absent after deal.
