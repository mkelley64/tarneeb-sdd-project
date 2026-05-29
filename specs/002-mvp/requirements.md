# Tarneeb iOS MVP 002 Requirements

## 1. Purpose

Build an iOS application MVP for the card game Tarneeb that allows one human player to start a game by dealing cards. The other three players are simulated seats. This MVP ends immediately after a valid deal is completed and displayed. No bidding, trump/Tarneeb suit selection, trick play, scoring, multiplayer, persistence, or AI decision-making is included.

This 002 revision keeps the original MVP gameplay boundary and incorporates product feedback about card readability, player station placement, simulated player station size, and hidden card sizing.

## 2. Source Rules

This MVP is based on the Tarneeb rules published by Jawaker:

- Tarneeb is a four-player partnership card game.
- Players sit across from each other, forming two teams.
- The game uses a standard 52-card deck with no jokers.
- Play proceeds counterclockwise.
- Each player is dealt 13 cards.

Reference: https://blog.jawaker.com/en/tarneeb-rules-en/

## 3. Revision Inputs

### 3.1 Product Feedback Addressed

- Black cards and red cards are hard to distinguish.
- Player stations are not positioned correctly.
- East, North, and West stations could be much smaller.
- Hidden cards are too small.

### 3.2 Requirement Changes Integrated

- Rank and suit for Hearts and Diamonds must be red.
- Player stations must be positioned in a diamond pattern, with North at the top, West on the left, South at the bottom, and East on the right.
- East, North, and West player stations must be just large enough to contain the player label and hidden card array. Hidden cards may be displayed as a slightly spread stack.
- Exposed cards must mimic the dimensions of standard playing cards, be large enough to read, and still fit comfortably within the player station area.
- Hidden cards must use the same base size as exposed cards.

## 4. MVP Scope

### In Scope

- Launch an iOS app.
- Show a start screen for a single human player.
- Create four player seats:
  - South: Human player
  - West: Simulated player
  - North: Simulated player
  - East: Simulated player
- Create two partnerships:
  - Team A: South + North
  - Team B: East + West
- Create a standard 52-card deck excluding jokers.
- Shuffle the deck.
- Deal 13 cards to each of the four players in 13-card chunks.
- Display the human player's 13-card hand.
- Display simulated players as having 13 hidden cards each.
- Show that the deal is complete.
- Prevent gameplay beyond the completed deal.
- Display card faces with red Hearts and Diamonds and dark Spades and Clubs.
- Arrange player stations in a diamond pattern: North top, West left, South bottom, East right.
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
- Accessibility beyond standard iOS controls for this MVP.
- Error handling beyond preventing invalid completed deal states.
- Custom card art beyond the provided card back and simple rank/suit card faces.

## 5. Product Requirements

### PRD-001: App Launch

As a human player, I want to open the app and see a clear way to start a new Tarneeb deal.

#### Acceptance Criteria

- Given the app is launched, when the initial screen appears, then the user sees the app title `Tarneeb`.
- Given the app is launched, when the initial screen appears, then the user sees a primary action labeled `Deal Cards`.
- Given the app is launched, then no cards are dealt until the user taps `Deal Cards`.

### PRD-002: Player Seats

As a human player, I want the table to contain four Tarneeb seats so the deal matches the real game structure. Player seats exist as empty seats before the first deal.

#### Acceptance Criteria

- Given the table is displayed, then exactly four player seats exist.
- Given the four seats exist, then they are labeled `South`, `West`, `North`, and `East`.
- Given the four seats exist, then `South` is assigned to the human player.
- Given the four seats exist, then `West`, `North`, and `East` are assigned to simulated players.
- Given the four seats exist, then `South` and `North` are partners.
- Given the four seats exist, then `East` and `West` are partners.

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

- Given the user taps `Deal Cards`, when the deal completes, then each of the four players has exactly 13 cards.
- Given the deal completes, then all 52 cards have been assigned to players.
- Given the deal completes, then no card appears in more than one player's hand.
- Given the deal completes, then no cards remain undealt.
- Given the deal completes, then the app records the deal state as `Dealt`.

### PRD-006: Human Hand Display

As a human player, I want to see my own cards after the deal and clearly distinguish card suits.

#### Acceptance Criteria

- Given the deal completes, then the South player's 13 cards are visible to the user.
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

- Given all cards have been dealt, then the app displays a message such as `Deal complete`.
- Given the deal is complete, then no bidding UI is shown.
- Given the deal is complete, then no gameplay controls are shown.
- Given the deal is complete, then the user may start a new deal using a `New Deal` action.

### PRD-009: New Deal

As a human player, I want to start over with a fresh deal.

#### Acceptance Criteria

- Given a deal is complete, when the user taps `New Deal`, then the previous hands are cleared.
- Given a new deal starts, then a fresh 52-card deck is created or the previous full deck is reset.
- Given a new deal starts, then the deck is shuffled before dealing.
- Given the new deal completes, then each player again has exactly 13 cards.
- Given the new deal completes, then the diamond table layout and card sizing requirements still apply.

### PRD-010: Table Layout and Visual Sizing

As a human player, I want the table layout to resemble a four-player card table so the seats are easy to understand.

#### Acceptance Criteria

- Given the table is displayed, then player stations are positioned in a diamond pattern.
- Given the diamond table is displayed, then North is at the top, West is on the left, South is at the bottom, and East is on the right.
- Given the table is displayed, then South and North appear opposite each other as partners.
- Given the table is displayed, then East and West appear opposite each other as partners.
- Given the table is displayed after a deal, then East, North, and West stations are visually smaller than the South station when screen space allows.
- Given the table is displayed, then required labels, cards, message text, and deal actions remain usable and do not overlap each other.
- Given the table is displayed on a small supported simulator, then all four player stations, the deal completion message, and the available action button remain usable.

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

No other game phases should be implemented for MVP 002.

### 6.4 Seat Order

The game model must preserve the Tarneeb counterclockwise seat order. Recommended model order:

1. South: Human
2. East: Simulated
3. North: Simulated
4. West: Simulated

The visual layout must use a diamond table arrangement:

- North at the top.
- West on the left.
- South at the bottom.
- East on the right.

The model order and visual placement are related but separate concerns.

### 6.5 Dealing Behavior

The implementation must produce four hands of 13 cards each. The MVP does not require a visible card-by-card dealing animation. It is acceptable to shuffle once and assign cards into four 13-card hands.

Recommended deterministic dealing algorithm after shuffle:

1. Create the 52-card deck.
2. Shuffle the deck.
3. Assign cards to seats in 13-card chunks.
4. Mark the game phase as `dealt`.

### 6.6 Card Presentation Rules

- Exposed cards must show rank and suit.
- Hearts and Diamonds must render rank and suit in red.
- Clubs and Spades must render rank and suit in black or another high-contrast dark color that is clearly distinct from red.
- Exposed cards and hidden card backs must share the same base dimensions.
- Cards should use a standard playing-card aspect ratio, approximately 5:7 width to height.
- Card sizing may adapt to device size, but exposed card text must remain readable and hidden cards must not be scaled smaller than exposed cards.
- Hidden cards must use the provided `card_back.png` asset.
- Hidden card stacks may overlap slightly to conserve space.

### 6.7 Layout Behavior

- The table must be arranged as a diamond with a clear center table area.
- The South station may be wider or taller than simulated stations because it displays the human player's full visible hand.
- North, West, and East stations must be compact and sized around their label plus hidden card array.
- The layout must avoid overlapping labels, card faces, card backs, completion message text, and action buttons.
- On smaller supported screens, the layout may scale spacing or use scrolling if needed, but it must preserve the North, West, South, and East relationship.

## 7. UI Requirements

### 7.1 Initial Screen

The initial screen must include:

- App title: `Tarneeb`
- Primary button: `Deal Cards`
- Four player station labels arranged in the required diamond pattern.
- No visible cards before the first deal.

### 7.2 Dealt Table Screen

After dealing, the screen must include:

- Four visible player areas arranged in the required diamond pattern.
- South human player hand with 13 visible cards.
- West, North, and East simulated players with 13 hidden card backs each.
- Red rank and suit styling for Hearts and Diamonds.
- Dark rank and suit styling for Clubs and Spades.
- Exposed and hidden cards using the same base size and standard-card aspect ratio.
- Compact West, North, and East stations.
- Deal completion message.
- `New Deal` action.

### 7.3 Prohibited MVP UI

The MVP must not show:

- Bid controls.
- Pass controls.
- Trump/Tarneeb suit selector.
- Play-card controls.
- Trick area.
- Scoreboard.
- Game-over state.

## 8. Non-Functional Requirements

### NFR-001: Platform

- The app must target iOS.
- SwiftUI is recommended unless the implementation plan specifies otherwise.

### NFR-002: Responsiveness

- The deal should complete quickly enough to feel immediate to the user.
- The UI must remain responsive after dealing.
- Visual layout and card sizing changes must not introduce noticeable blocking during deal or new deal actions.

### NFR-003: Testability

- Deck creation, shuffle preservation of uniqueness, player setup, and dealing must be testable independently of the UI.
- The card dealing logic should be isolated from SwiftUI views.
- Card presentation mapping for suit color should be testable independently where practical.
- Layout-critical UI elements should have stable accessibility identifiers or labels so UI tests can verify visibility and interaction.

### NFR-004: Reliability

- The app must never produce duplicate cards in a completed deal.
- The app must never produce fewer or more than 13 cards per player in a completed deal.
- The app must never include jokers.

### NFR-005: Visual Usability

- Red suits and black/dark suits must be visually distinguishable.
- Exposed card ranks and suits must be readable on supported device sizes.
- Hidden card backs must be large enough to resemble cards rather than unreadable icons.
- Required UI must remain usable on at least one small-screen simulator supported by the project.

## 9. Edge Cases and Constraints

- If a new deal is requested after a completed deal, the previous hands must be cleared before the replacement deal is shown.
- If the app creates or resets a deck for a new deal, the completed deal must still contain exactly 52 unique assigned cards.
- If hidden card backs are visually overlapped, no rank or suit information may be exposed for simulated players.
- If a small screen cannot fit the full table without adjustment, the UI may reduce spacing or allow scrolling, but it must keep all required controls and stations usable.
- If card size adapts to screen size, hidden card backs and exposed card faces must adapt together so they remain the same base size.
- If color values are implemented through system colors, the visual distinction between red suits and black/dark suits must remain clear in the supported appearance mode.

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

### UI Tests

1. `testInitialScreenShowsDealCardsButton`
   - Launch app and verify `Deal Cards` is visible.

2. `testInitialScreenShowsDiamondPlayerStations`
   - Launch app and verify South, West, North, and East labels are visible in the required diamond relationship.

3. `testTappingDealCardsShowsHumanHand`
   - Tap `Deal Cards` and verify 13 human cards are visible.

4. `testTappingDealCardsShowsSimulatedPlayerCounts`
   - Tap `Deal Cards` and verify West, North, and East each show 13 hidden cards.

5. `testCardSuitColorsAreVisible`
   - Tap `Deal Cards` and verify red suit styling for Hearts and Diamonds and dark styling for Clubs and Spades using view inspection, snapshot comparison, or equivalent UI verification.

6. `testHiddenCardsUseReadableCardSize`
   - Tap `Deal Cards` and verify hidden card backs use the same base size as exposed South cards.

7. `testSimulatedStationsAreCompact`
   - Tap `Deal Cards` and verify East, North, and West stations occupy only the space needed for labels and hidden card arrays when compared with South.

8. `testNoGameplayControlsAreShownAfterDeal`
   - Tap `Deal Cards` and verify bid, pass, trump selection, play-card, trick, and scoring controls are absent.

9. `testNewDealResetsAndDealsAgain`
   - Complete a deal, tap `New Deal`, and verify a new valid deal is displayed.

10. `testSmallScreenLayoutRemainsUsable`
    - Run on a small supported simulator and verify labels, visible cards, hidden cards, completion message, and available buttons are usable without incoherent overlap.

### Manual Visual QA

1. Verify Hearts and Diamonds are noticeably red and Clubs and Spades are noticeably black or dark.
2. Verify the table reads as a diamond: North top, West left, South bottom, East right.
3. Verify East, North, and West stations look compact compared with the South station.
4. Verify hidden card backs are the same base size as exposed cards and are large enough to resemble cards.
5. Verify exposed cards look like standard playing cards and remain readable.

## 11. Definition of Done

The MVP 002 revision is complete when:

- A user can launch the iOS app.
- A user can tap `Deal Cards`.
- The app creates four Tarneeb seats with one human and three simulated players.
- The app creates and shuffles a valid 52-card deck without jokers.
- The app deals exactly 13 unique cards to each player.
- The human player can see only their own hand.
- Simulated players' cards remain hidden.
- The app clearly indicates that the deal is complete.
- The app allows a completed deal to be replaced using `New Deal`.
- The app displays player stations in the required diamond layout.
- Hearts and Diamonds are rendered in red.
- Clubs and Spades are rendered in black or another high-contrast dark color.
- Hidden and exposed cards use the same readable standard-card base size.
- East, North, and West stations are compact while remaining usable.
- No bidding, Tarneeb suit selection, trick play, scoring, or other gameplay is implemented.
- Automated tests verify the core dealing requirements.
- Automated or manual visual checks verify the 002 layout and card readability changes.

## 12. Open Ambiguities

- Exact card dimensions in points are not specified. The implementation should choose responsive dimensions that approximate a 5:7 playing-card aspect ratio and satisfy readability on supported devices.
- The minimum required small-screen simulator is not specified. Use the smallest simulator supported by the project unless product specifies a stricter target.
- Exact red and black/dark color values are not specified. Use platform-appropriate colors unless product provides design tokens.
- Exact hidden card stack spread distance is not specified. The spread should conserve space while still representing 13 hidden cards.

## Product feedback

- Big title at the top is in the wrong place
- Player Stations should be square and surround a table
- New Deal and Deal Cards buttons should just say Deal
- Deal button should be at the very bottom, with Deal complete label above it

## Requirement changes

- App should be locked in the portrait orientation
- Add a circle to represent a card table in the center of the screen.  The diameter should be half the screen width.  The player stations should be round squares surrounding the card table, and should be represented as rounded squares.
- When the cards are dealt, the South station should expand below the card table to display the revealed cards
- When the game begins, the deck of cards should be represented as a stack of 52 hidden cards, slightly fanned, in the center of the card table.  When the cards are dealt, this stack should disappear.
- The Tarneeb title should be in the center of the card table.  It can be obscured by cards.
- New Deal and Deal Cards buttons should just say Deal
- Deal button should be at the very bottom, with Deal complete label above it
