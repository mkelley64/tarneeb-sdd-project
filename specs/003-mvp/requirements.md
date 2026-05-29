# Tarneeb iOS MVP 003 Requirements

## 1. Purpose

Build an iOS application MVP for the card game Tarneeb that allows one human player to start a game by dealing cards. The other three players are simulated seats. This MVP ends immediately after a valid deal is completed and displayed, while allowing the player to request a replacement deal or reset the screen to the original launch state. No bidding, trump/Tarneeb suit selection, trick play, scoring, multiplayer, persistence, or AI decision-making is included.

This 003 revision keeps the original deal-only gameplay boundary, carries forward the MVP 002 card readability and station sizing requirements, and incorporates product feedback about portrait orientation, a central card table, rounded-square player stations, initial deck presentation, title placement, title styling, and bottom controls.

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

### 3.2 MVP 003 Product Feedback Addressed

- The large title at the top is in the wrong place.
- Player stations should be square and surround a table.
- Deal and replacement-deal actions should use `Deal`, not `New Deal` or `Deal Cards`.
- The `Deal` button should be at the very bottom, with the `Deal complete` label above it.
- A separate `New Game` button should sit next to `Deal` and reset the whole game to the original launch state.

### 3.3 MVP 003 Requirement Changes Integrated

- The app should be locked in portrait orientation.
- A circle should represent a card table in the center of the screen.
- The card table diameter should be half the screen width.
- Player stations should be rounded squares surrounding the card table.
- When cards are dealt, the South station should expand below the card table to display the revealed cards.
- When the game begins, the deck should be represented as a non-fanned stack of 52 hidden cards just below the title on the card table.
- When the cards are dealt, the central deck stack should disappear.
- The Arabic title `طرنيب` should be centered on the card table and remain visible above the initial deck stack.
- The `طرنيب` title should use the tokenized table-title style defined in `design-tokens.md`, including the specified Arabic rounded font, 26pt size, tracking range, text color/opacity, and subtle shadow.
- Initial and replacement deal actions should both be labeled `Deal`.
- The `Deal` button should be at the very bottom of the screen.
- The `Deal complete` label should appear above the bottom control row after a completed deal.
- The `New Game` button should appear next to `Deal` at the bottom of the screen and restore the app to the same not-started state shown at launch.

## 4. MVP Scope

### In Scope

- Launch an iOS app locked to portrait orientation.
- Show a start screen for a single human player.
- Display a circular card table centered on the screen with a diameter equal to half the screen width.
- Display the Arabic title `طرنيب` centered on the card table.
- Display a non-fanned stack of 52 hidden cards just below the title on the card table before a deal completes.
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
- Display the human player's 13-card hand after the deal.
- Expand the South station below the card table after the deal to display the human player's revealed cards.
- Display simulated players as having 13 hidden cards each after the deal.
- Remove the central 52-card deck stack after the deal.
- Show that the deal is complete.
- Place the `Deal complete` label above the bottom control row after the deal.
- Use a bottom `Deal` action for both the first deal and replacement deals.
- Display a bottom `New Game` action next to `Deal`.
- Reset the app to the original launch state when `New Game` is tapped.
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
- Animations beyond basic dealing feedback.
- Sound effects.
- Landscape layout support.
- Accessibility beyond standard iOS controls for this MVP.
- Error handling beyond preventing invalid completed deal states.
- Custom card art beyond the provided card back and simple rank/suit card faces.

## 5. Product Requirements

### PRD-001: App Launch

As a human player, I want to open the app and see a clear way to start a new Tarneeb deal.

#### Acceptance Criteria

- Given the app is launched, when the initial screen appears, then the user sees the app title `طرنيب` centered on the card table.
- Given the app is launched, when the initial screen appears, then the user sees a primary action labeled `Deal`.
- Given the app is launched, then no cards are dealt until the user taps `Deal`.
- Given the app is launched, then the app is locked in portrait orientation.
- Given the app is launched, when the initial screen appears, then the user sees a reset action labeled `New Game` next to `Deal`.

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
- Given the deal completes, then all 52 cards have been assigned to players.
- Given the deal completes, then no card appears in more than one player's hand.
- Given the deal completes, then no cards remain undealt.
- Given the deal completes, then the app records the deal state as `Dealt`.
- Given the deal completes, then the central 52-card deck stack is no longer visible.

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
- Given the deal is complete, then the user may reset to the original launch state using the bottom `New Game` action.

### PRD-009: Replacement Deal

As a human player, I want to start over with a fresh deal.

#### Acceptance Criteria

- Given a deal is complete, when the user taps `Deal`, then the previous hands are cleared.
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
- Given the initial deck stack is displayed, then it sits below the `طرنيب` title without overlapping it.
- Given the initial table is displayed, then a non-fanned stack of 52 hidden cards appears just below the title on the card table.
- Given the initial deck stack is displayed, then it does not reveal any card ranks or suits.
- Given the deal completes, then the central deck stack disappears.

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

As a human player, I want to reset the table to its original launch state without immediately dealing.

#### Acceptance Criteria

- Given the app is in the dealt state, when the user taps `New Game`, then the game phase returns to `notStarted`.
- Given the app resets to `notStarted`, then all player hands are cleared.
- Given the app resets to `notStarted`, then the same four seats remain visible as South, West, North, and East.
- Given the app resets to `notStarted`, then the non-fanned 52-card central deck stack is visible again just below the `طرنيب` title.
- Given the app resets to `notStarted`, then the South visible cards and simulated hidden hands are no longer displayed.
- Given the app resets to `notStarted`, then the `Deal complete` label is no longer displayed.
- Given the initial screen is displayed, when the user taps `New Game`, then the screen remains in the original launch state and no deal starts.

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
- `deck`: source deck before or during dealing, if retained by implementation

No other game phases should be implemented for MVP 003.

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

### 6.5 Dealing Behavior

The implementation must produce four hands of 13 cards each. The MVP does not require a visible card-by-card dealing animation. It is acceptable to shuffle once and assign cards into four 13-card hands.

Recommended deterministic dealing algorithm after shuffle:

1. Create the 52-card deck.
2. Shuffle the deck.
3. Assign cards to seats in 13-card chunks.
4. Mark the game phase as `dealt`.
5. Hide the central deck stack.

### 6.6 Card Presentation Rules

- Exposed cards must show rank and suit.
- Hearts and Diamonds must render rank and suit in red.
- Clubs and Spades must render rank and suit in black or another high-contrast dark color that is clearly distinct from red.
- Exposed cards and hidden card backs must share the same base dimensions.
- Cards should use a standard playing-card aspect ratio, approximately 5:7 width to height.
- Card sizing may adapt to device size, but exposed card text must remain readable and hidden cards must not be scaled smaller than exposed cards.
- Hidden cards must use the provided `card_back.png` asset.
- Hidden card stacks may overlap slightly to conserve space.
- The initial central deck stack must represent 52 hidden cards without revealing rank or suit information.

### 6.7 Layout Behavior

- The app must be locked to portrait orientation.
- The screen must include a circular card table centered in the main table area.
- The circular card table diameter must be half the screen width.
- The Arabic title `طرنيب` must be centered on the card table.
- The title must remain visible above the initial deck stack.
- Before a deal completes, a non-fanned stack of 52 hidden cards must appear just below the title on the card table.
- After a deal completes, the central deck stack must disappear.
- Player stations must be rounded squares surrounding the card table.
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
- A non-fanned stack of 52 hidden cards just below the title on the card table.
- Four rounded-square player station labels surrounding the card table.
- North above the table, West left of the table, South below the table, and East right of the table.
- Bottom control row with reset button `New Game` and primary button `Deal`.
- No visible dealt player hands before the first deal.
- No `Deal Cards` or `New Deal` action labels.

### 7.2 Dealt Table Screen

After dealing, the screen must include:

- Portrait orientation only.
- The circular card table and surrounding player stations.
- No central 52-card deck stack.
- South human player station expanded below the card table with 13 visible cards.
- West, North, and East simulated players with 13 hidden card backs each.
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
- The app must be locked to portrait orientation for MVP 003.
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
- The initial 52-card deck stack should be exposed in a way that UI tests can verify its presence before a deal and absence after a deal.
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
- The central table, rounded-square stations, bottom deal control, and completion label must not overlap incoherently.

## 9. Edge Cases and Constraints

- If a replacement deal is requested after a completed deal, the previous hands must be cleared before the replacement deal is shown.
- If `New Game` is requested after a completed deal, the previous hands must be cleared, the game phase must return to `notStarted`, `Deal complete` must be hidden, and the central deck stack must reappear below the title.
- If `New Game` is requested from the initial screen, the app should remain in the original launch state and should not start a deal.
- If the app creates or resets a deck for a replacement deal, the completed deal must still contain exactly 52 unique assigned cards.
- If hidden card backs are visually overlapped, no rank or suit information may be exposed for simulated players.
- The initial 52-card deck stack must not overlap the `طرنيب` title.
- If a small portrait screen cannot fit the full table without adjustment, the UI may reduce spacing or allow scrolling, but it must keep all required controls and stations usable.
- If the South station expands after a deal, it must not make the bottom `Deal`, `New Game`, or `Deal complete` controls unusable.
- If card size adapts to screen size, hidden card backs and exposed card faces must adapt together so they remain the same base size.
- If color values are implemented through system colors, the visual distinction between red suits and black/dark suits must remain clear in the supported appearance mode.
- If a device is physically rotated, the app should remain in portrait orientation for MVP 003.

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
    - Verify the initial presentation model represents 52 hidden cards in the central deck stack, if modeled outside SwiftUI.

16. `testNewGameResetsPresentationToLaunchState`
    - Complete a deal, invoke the reset action, and verify the phase returns to `notStarted`, hands are cleared, the central deck stack is visible, and the completion label is hidden.

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
   - Launch app and verify a non-fanned 52-card hidden deck stack is visible just below the title on the card table.

7. `testInitialScreenShowsRoundedSquarePlayerStationsAroundTable`
   - Launch app and verify South, West, North, and East stations are rounded squares surrounding the table in the required relationship.

8. `testTappingDealShowsHumanHand`
   - Tap `Deal` and verify 13 human cards are visible.

9. `testTappingDealHidesCentralDeckStack`
   - Tap `Deal` and verify the initial central deck stack is no longer visible.

10. `testSouthStationExpandsAfterDeal`
    - Tap `Deal` and verify the South station expands below the card table to display the revealed cards.

11. `testTappingDealShowsSimulatedPlayerCounts`
    - Tap `Deal` and verify West, North, and East each show 13 hidden cards.

12. `testCardSuitColorsAreVisible`
    - Tap `Deal` and verify red suit styling for Hearts and Diamonds and dark styling for Clubs and Spades using view inspection, snapshot comparison, or equivalent UI verification.

13. `testHiddenCardsUseReadableCardSize`
    - Tap `Deal` and verify hidden card backs use the same base size as exposed South cards.

14. `testSimulatedStationsAreCompact`
    - Tap `Deal` and verify East, North, and West stations occupy only the space needed for labels and hidden card arrays when compared with South.

15. `testDealCompleteAppearsAboveBottomDealButton`
    - Tap `Deal` and verify `Deal complete` appears above the bottom control row.

16. `testNoGameplayControlsAreShownAfterDeal`
    - Tap `Deal` and verify bid, pass, trump selection, play-card, trick, and scoring controls are absent.

17. `testDealButtonResetsAndDealsAgain`
    - Complete a deal, tap `Deal`, and verify a replacement valid deal is displayed.

18. `testNewGameButtonResetsToOriginalLaunchState`
    - Complete a deal, tap `New Game`, and verify dealt cards disappear, `Deal complete` disappears, the central deck stack returns below the title, and the screen remains ready to deal.

19. `testNewGameButtonDoesNotDealFromInitialState`
    - Launch app, tap `New Game`, and verify no hands are dealt and the initial deck stack remains visible.

20. `testSmallScreenLayoutRemainsUsable`
    - Run on a small supported simulator and verify labels, visible cards, hidden cards, completion message, and available buttons are usable without incoherent overlap.

### Manual Visual QA

1. Verify Hearts and Diamonds are noticeably red and Clubs and Spades are noticeably black or dark.
2. Verify the screen remains portrait when the device rotates.
3. Verify the circular card table is centered and appears about half the screen width.
4. Verify the `طرنيب` title is centered on the card table rather than placed as a large top title.
5. Verify the initial 52-card deck stack appears as a non-fanned stack just below the title on the card table and does not obscure the title.
6. Verify player stations read as rounded squares surrounding the table: North top, West left, South bottom, East right.
7. Verify East, North, and West stations look compact compared with the expanded South station after deal.
8. Verify the South station expands below the card table after deal and exposed cards remain readable.
9. Verify hidden card backs are the same base size as exposed cards and are large enough to resemble cards.
10. Verify the bottom control row shows `New Game` next to `Deal` before and after dealing.
11. Verify `Deal complete` appears above the bottom control row.
12. Verify tapping `New Game` after a deal returns the app to the original launch state with no dealt cards and the central deck stack visible again.

## 11. Definition of Done

The MVP 003 revision is complete when:

- A user can launch the iOS app in portrait orientation.
- A user can tap `Deal`.
- The app creates four Tarneeb seats with one human and three simulated players.
- The app displays a central circular card table with a diameter equal to half the screen width.
- The app displays the `طرنيب` title centered on the card table.
- The app displays four rounded-square player stations surrounding the card table.
- The app displays a non-fanned stack of 52 hidden cards just below the title on the card table before the deal.
- The app creates and shuffles a valid 52-card deck without jokers.
- The app deals exactly 13 unique cards to each player.
- The central deck stack disappears after the deal.
- The South station expands below the card table after the deal.
- The human player can see only their own hand.
- Simulated players' cards remain hidden.
- The app clearly indicates that the deal is complete.
- `Deal complete` appears above the bottom control row.
- The bottom controls include `New Game` and `Deal`.
- The `Deal` action starts the first deal and replacement deals.
- The `New Game` action resets the app to the original launch state without immediately dealing.
- The app displays player stations in the required table-surrounding layout.
- Hearts and Diamonds are rendered in red.
- Clubs and Spades are rendered in black or another high-contrast dark color.
- Hidden and exposed cards use the same readable standard-card base size.
- East, North, and West stations are compact while remaining usable.
- No bidding, Tarneeb suit selection, trick play, scoring, or other gameplay is implemented.
- Automated tests verify the core dealing requirements.
- Automated or manual visual checks verify the 003 portrait table, rounded-square station, deck stack, bottom controls, reset behavior, and card readability changes.

## 12. Open Ambiguities

- Exact card dimensions in points are not specified. The implementation should choose responsive dimensions that approximate a 5:7 playing-card aspect ratio and satisfy readability on supported device sizes.
- The minimum required small-screen simulator is not specified. Use the smallest simulator supported by the project unless product specifies a stricter target.
- Exact red and black/dark color values are not specified. Use platform-appropriate colors unless product provides design tokens.
- Exact simulated hidden-hand stack spread distance is not specified. The spread should conserve space while still representing the required number of hidden cards. The central deck stack remains non-fanned.
- Exact rounded-square station dimensions and corner radius are not specified.
- Exact card table vertical position is not specified beyond being centered in the main table area.
- Exact tolerance for "half the screen width" is not specified for UI tests.
- It is not specified whether the bottom control row should be fixed to the safe-area bottom or to the bottom of scrollable content. Treat it as bottom safe-area aligned unless product specifies otherwise.
- It is not specified whether the 52-card central deck stack should animate away during deal. MVP 003 only requires that it is present before deal and absent after deal.
