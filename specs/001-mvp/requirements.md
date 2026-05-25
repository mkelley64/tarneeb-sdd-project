# Tarneeb iOS MVP Requirements

## 1. Purpose

Build an iOS application MVP for the card game Tarneeb that allows one human player to start a game by dealing cards. The other three players are simulated seats. This MVP ends immediately after a valid deal is completed and displayed. No bidding, trump/Tarneeb suit selection, trick play, scoring, multiplayer, persistence, or AI decision-making is included.

## 2. Source Rules

This MVP is based on the Tarneeb rules published by Jawaker:

- Tarneeb is a four-player partnership card game.
- Players sit across from each other, forming two teams.
- The game uses a standard 52-card deck with no jokers.
- Play proceeds counterclockwise.
- Each player is dealt 13 cards.

Reference: https://blog.jawaker.com/en/tarneeb-rules-en/

## 3. MVP Scope

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
- Deal 13 cards to each of the four players in 13 card chunks.
- Display the human player’s 13-card hand.
- Display simulated players as having 13 hidden cards each.
- Show that the deal is complete.
- Prevent gameplay beyond the completed deal.

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
- Error handling

## 4. Product Requirements

### PRD-001: App Launch

As a human player, I want to open the app and see a clear way to start a new Tarneeb deal.

#### Acceptance Criteria

- Given the app is launched, when the initial screen appears, then the user sees the app title `Tarneeb`.
- Given the app is launched, when the initial screen appears, then the user sees a primary action labeled `Deal Cards`.
- Given the app is launched, then no cards are dealt until the user taps `Deal Cards`.

### PRD-002: Player Seats

As a human player, I want the table to contain four Tarneeb seats so the deal matches the real game structure. Player seats exist as empty seats before the first deal.

#### Acceptance Criteria

- Given a new deal is started, then exactly four player seats exist.
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

As a human player, I want the cards shuffled before dealing so each deal is randomized.  Use the standard swift shuffle method.

#### Acceptance Criteria

- Given a new deal is started, then the deck is shuffled before cards are assigned to players.
- Given two separate deals are started, then the app should not intentionally preserve the same card order.
- Given the deck is shuffled, then the deck still contains exactly 52 unique cards.

### PRD-005: Deal Cards

As a human player, I want each player to receive 13 cards, in a 13-card chunk, so the Tarneeb deal is complete.

#### Acceptance Criteria

- Given the user taps `Deal Cards`, when the deal completes, then each of the four players has exactly 13 cards.
- Given the deal completes, then all 52 cards have been assigned to players.
- Given the deal completes, then no card appears in more than one player’s hand.
- Given the deal completes, then no cards remain undealt.
- Given the deal completes, then the app records the deal state as `Dealt`.

### PRD-006: Human Hand Display

As a human player, I want to see my own cards after the deal.

#### Acceptance Criteria

- Given the deal completes, then the South player’s 13 cards are visible to the user.
- Given the South hand is visible, then each card displays its suit and rank.  Use symbols for suits, and numbers/letters for rank.
- Given the South hand is visible,the hand will be sorted by suit (Hearts, Clubs, Diamonds, Spades) and rank (2 through Ace) for readability.
- Given the South hand is visible, then the user cannot select, play, discard, or otherwise act on a card in this MVP.

### PRD-007: Simulated Player Display

As a human player, I want simulated players’ hands hidden so the table resembles a real card game.  Use the card_back.png image for hidden cards

#### Acceptance Criteria

- Given the deal completes, then West, North, and East each display 13 hidden card backs.
- Given the simulated player cards are displayed, then their ranks and suits are not visible to the human player.
- Given the simulated player cards are displayed, then the app does not expose controls for simulated player actions.

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

## 5. Functional Specification

### 5.1 Card Model

A card must contain:

- `suit`: one of `spades`, `clubs`, `hearts`, `diamonds`
- `rank`: one of `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `J`, `Q`, `K`, `A`
- A stable identity derived from suit and rank, such as `spades-A`

### 5.2 Player Model

A player must contain:

- `id`: stable unique identifier
- `seat`: one of `south`, `west`, `north`, `east`
- `type`: `human` or `simulated`
- `team`: `teamA` or `teamB`
- `hand`: list of cards

### 5.3 Game State Model

The game state must contain:

- `phase`: one of `notStarted`, `dealt`
- `players`: exactly four players
- `deck`: source deck before or during dealing, if retained by implementation

No other game phases should be implemented for MVP.

### 5.4 Seat Order

The table must represent seats in counterclockwise order. Recommended order:

1. South: Human
2. East: Simulated
3. North: Simulated
4. West: Simulated

The visual layout may place the human player at the bottom of the screen, with simulated players on the left, top, and right.

### 5.5 Dealing Behavior

The implementation must produce four hands of 13 cards each. The MVP does not require a visible card-by-card dealing animation. It is acceptable to shuffle once and assign cards into four 13-card hands.

Recommended deterministic dealing algorithm after shuffle:

1. Create the 52-card deck.
2. Shuffle the deck.
3. Assign cards to seats in 13 card chunks.
4. Mark the game phase as `dealt`.

## 6. UI Requirements

### 6.1 Initial Screen

The initial screen must include:

- App title: `Tarneeb`
- Primary button: `Deal Cards`
- No visible cards before the first deal

### 6.2 Dealt Table Screen

After dealing, the screen must include:

- Four visible player areas.
- South human player hand with 13 visible cards.
- West, North, and East simulated players with hidden cards.
- Deal completion message.
- `New Deal` action.

### 6.3 Prohibited MVP UI

The MVP must not show:

- Bid controls.
- Pass controls.
- Trump/Tarneeb suit selector.
- Play-card controls.
- Trick area.
- Scoreboard.
- Game-over state.

## 7. Non-Functional Requirements

### NFR-001: Platform

- The app must target iOS.
- SwiftUI is recommended unless the implementation plan specifies otherwise.

### NFR-002: Responsiveness

- The deal should complete quickly enough to feel immediate to the user.
- The UI must remain responsive after dealing.

### NFR-003: Testability

- Deck creation, shuffle preservation of uniqueness, player setup, and dealing must be testable independently of the UI.
- The card dealing logic should be isolated from SwiftUI views.

### NFR-004: Reliability

- The app must never produce duplicate cards in a completed deal.
- The app must never produce fewer or more than 13 cards per player in a completed deal.
- The app must never include jokers.

## 8. Suggested Test Cases

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

### UI Tests

1. `testInitialScreenShowsDealCardsButton`
   - Launch app and verify `Deal Cards` is visible.

2. `testTappingDealCardsShowsHumanHand`
   - Tap `Deal Cards` and verify 13 human cards are visible.

3. `testTappingDealCardsShowsSimulatedPlayerCounts`
   - Tap `Deal Cards` and verify West, North, and East each show 13 hidden cards.

4. `testNoGameplayControlsAreShownAfterDeal`
   - Tap `Deal Cards` and verify bid, pass, trump selection, play-card, trick, and scoring controls are absent.

5. `testNewDealResetsAndDealsAgain`
   - Complete a deal, tap `New Deal`, and verify a new valid deal is displayed.

## 9. Definition of Done

The MVP is complete when:

- A user can launch the iOS app.
- A user can tap `Deal Cards`.
- The app creates four Tarneeb seats with one human and three simulated players.
- The app creates and shuffles a valid 52-card deck without jokers.
- The app deals exactly 13 unique cards to each player.
- The human player can see only their own hand.
- Simulated players’ cards remain hidden.
- The app clearly indicates that the deal is complete.
- No bidding, Tarneeb suit selection, trick play, scoring, or other gameplay is implemented.
- Automated tests verify the core dealing requirements.
