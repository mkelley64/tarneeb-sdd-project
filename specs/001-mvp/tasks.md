# Tarneeb iOS MVP Implementation Tasks

This task list is derived from `requirements.md` and `design.md`. It is an
implementation plan only; no code is included here.

Acceptance criteria are referenced as `PRD-### AC#`, where `AC#` is the
acceptance criterion order within that product requirement.

## 1. Project and Test Setup

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T001 | Confirm or create the iOS SwiftUI app target. | PRD-001 AC1, PRD-001 AC2, NFR-001 | The app can launch to a SwiftUI root screen. |
| T002 | Confirm or create a unit test target for domain, deck, shuffle, player setup, and deal logic. | PRD-003 AC1-AC5, PRD-004 AC1-AC3, PRD-005 AC1-AC5, NFR-003 | Unit tests can run without loading SwiftUI views. |
| T003 | Confirm or create a UI test target for launch, deal, hidden-hand, completion, prohibited-control, and new-deal flows. | PRD-001 AC1-AC3, PRD-006 AC1-AC4, PRD-007 AC1-AC3, PRD-008 AC1-AC4, PRD-009 AC1-AC4 | UI tests can launch the app and query visible labels, buttons, cards, and hidden card backs. |

## 2. Domain Model

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T004 | Define suit values for spades, clubs, hearts, and diamonds. | PRD-003 AC2, PRD-006 AC2 | Unit tests can enumerate exactly four allowed suits. |
| T005 | Define suit display symbols for visible human cards. | PRD-006 AC2 | Unit tests can map each suit to the required visible symbol. |
| T006 | Define rank values 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K, and A. | PRD-003 AC3, PRD-006 AC2 | Unit tests can enumerate exactly thirteen ranks. |
| T007 | Define rank display labels using numbers and letters. | PRD-006 AC2 | Unit tests can map each rank to its visible label. |
| T008 | Define the card model with suit, rank, and stable suit-rank identity. | PRD-003 AC5 | Unit tests verify card identity is stable and derived from suit and rank. |
| T009 | Define seat values for south, west, north, and east. | PRD-002 AC1, PRD-002 AC2 | Unit tests can enumerate exactly four seat values and user-facing labels. |
| T010 | Define player type values for human and simulated. | PRD-002 AC3, PRD-002 AC4 | Unit tests can inspect human and simulated player types. |
| T011 | Define team values for Team A and Team B. | PRD-002 AC5, PRD-002 AC6 | Unit tests can inspect team membership. |
| T012 | Define the player model with id, seat, type, team, and hand. | PRD-002 AC1-AC6, PRD-005 AC1 | Unit tests can create a player and inspect all required fields. |
| T013 | Define game phase values `notStarted` and `dealt` only. | PRD-005 AC5 | Unit tests verify only the two MVP phases are represented. |
| T014 | Define the game state model with phase, exactly four players, and optional retained deck. | PRD-002 AC1, PRD-005 AC5 | Unit tests can create not-started and dealt states with the required fields. |

## 3. Initial Player Setup

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T015 | Add a unit test that app initial state contains exactly four empty player seats. | PRD-001 AC3, PRD-002 AC1 | Initial-state test fails unless four players exist before the first deal and all hands are empty. |
| T016 | Implement initial player setup for South, East, North, and West. | PRD-002 AC1, PRD-002 AC2 | `testPlayersAreCreatedForAllSeats` passes. |
| T017 | Assign South as the only human player. | PRD-002 AC3, PRD-002 AC4 | `testSouthPlayerIsHuman` and `testOtherPlayersAreSimulated` pass. |
| T018 | Assign South/North to Team A and East/West to Team B. | PRD-002 AC5, PRD-002 AC6 | `testTeamsAreAssignedCorrectly` passes. |
| T019 | Verify initial player hands are empty before `Deal Cards`. | PRD-001 AC3 | Unit tests verify no card is assigned before the deal action. |

## 4. Deck and Shuffle

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T020 | Add a unit test for canonical deck size. | PRD-003 AC1 | `testDeckContains52Cards` fails until deck creation returns exactly 52 cards. |
| T021 | Implement canonical deck creation from the four suits and thirteen ranks. | PRD-003 AC1, PRD-003 AC2, PRD-003 AC3 | `testDeckContains52Cards` passes. |
| T022 | Add a unit test that the deck contains only allowed suits and ranks. | PRD-003 AC2, PRD-003 AC3, PRD-003 AC4 | `testDeckContainsNoJokers` fails for any joker or unsupported value. |
| T023 | Add a unit test that every card identity in the deck is unique. | PRD-003 AC5, NFR-004 | `testDeckContainsUniqueCards` passes. |
| T024 | Add a shuffle wrapper or service backed by Swift's standard shuffle method in production. | PRD-004 AC1, PRD-004 AC2 | Code review or test seam verifies production deal flow uses the standard Swift shuffle path. |
| T025 | Allow deterministic shuffle injection for tests. | PRD-004 AC1, NFR-003 | Deal tests can use a known card order without asserting random output. |
| T026 | Add shuffle preservation tests for card count and uniqueness. | PRD-004 AC3 | A shuffled deck still contains exactly 52 unique cards. |

## 5. Deal Service

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T027 | Add a unit test that the deal service returns a completed deal from fresh setup. | PRD-004 AC1, PRD-005 AC1, PRD-005 AC5 | Test fails until one UI-independent service call can return a valid dealt state. |
| T028 | Implement the deal service entry point for deck creation, standard shuffle, 13-card chunk assignment, and dealt game state. | PRD-004 AC1, PRD-005 AC1, PRD-005 AC5 | A completed deal can be requested from one UI-independent service. |
| T029 | Assign shuffled cards as four 13-card chunks in South, East, North, West order. | PRD-005 AC1, PRD-005 AC2 | Deterministic-shuffle test verifies exact chunk ownership by seat. |
| T030 | Add or complete the test that each player receives exactly 13 cards. | PRD-005 AC1, PRD-009 AC4 | `testDealGivesEachPlayer13Cards` passes. |
| T031 | Add or complete the test that all 52 cards are assigned. | PRD-005 AC2, PRD-005 AC4 | `testDealUsesAll52Cards` passes and no undealt cards remain. |
| T032 | Add or complete the test that no dealt card appears in more than one hand. | PRD-005 AC3, NFR-004 | `testDealHasNoDuplicateCards` passes. |
| T033 | Mark the game phase as `dealt` only after a valid deal. | PRD-005 AC5 | `testGamePhaseIsDealtAfterDeal` passes. |
| T034 | Validate completed-deal invariants internally before exposing dealt state. | PRD-005 AC1-AC5, NFR-004 | Invalid internal deals cannot be represented as valid completed deals; no user-facing error UI is added. |

## 6. Presentation State

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T035 | Create presentation state with phase `notStarted`, four empty seats, and no visible cards. | PRD-001 AC3, PRD-002 AC1 | Unit tests verify initial state contains seats but no dealt cards. |
| T036 | Connect the `Deal Cards` action to the deal service. | PRD-001 AC2, PRD-005 AC1 | Unit or UI tests verify the action moves from `notStarted` to `dealt`. |
| T037 | Prevent overlapping deal requests from repeated rapid taps. | PRD-005 AC1, PRD-005 AC3, NFR-004 | Repeated deal taps produce one valid final dealt state with no duplicate or partial hands. |
| T038 | Connect the `New Deal` action to clear prior hands and produce a fresh valid deal. | PRD-008 AC4, PRD-009 AC1-AC4 | `testNewDealResetsAndDealsAgain` passes. |
| T039 | Ensure presentation state exposes no bidding, passing, trump, play-card, trick, scoring, or game-over actions. | PRD-006 AC4, PRD-007 AC3, PRD-008 AC2, PRD-008 AC3 | Tests or code review verify only deal and new-deal actions exist for MVP gameplay. |

## 7. Initial Screen UI

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T040 | Build the initial screen with app title `Tarneeb`. | PRD-001 AC1 | UI test verifies the title is visible on launch. |
| T041 | Add the primary `Deal Cards` button. | PRD-001 AC2 | UI test verifies `Deal Cards` is visible and tappable. |
| T042 | Render four empty player areas before the first deal. | PRD-001 AC3, PRD-002 AC1, PRD-002 AC2 | UI test verifies South, West, North, and East are visible before dealing. |
| T043 | Ensure no visible cards or hidden card backs appear before `Deal Cards`. | PRD-001 AC3 | UI test verifies no card elements are present on initial launch. |

## 8. Dealt Table UI

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T044 | Build a dealt table screen with four visible player areas. | PRD-002 AC1, PRD-002 AC2 | UI test verifies South, West, North, and East areas are visible after dealing. |
| T045 | Render the South hand with exactly 13 visible cards. | PRD-006 AC1 | `testTappingDealCardsShowsHumanHand` verifies 13 South cards. |
| T046 | Render rank and suit symbol for each South card. | PRD-006 AC2 | UI test verifies each visible South card exposes a number/letter rank and suit symbol. |
| T047 | Sort the South hand by Hearts, Clubs, Diamonds, Spades and rank 2 through Ace. | PRD-006 AC3 | Unit or UI test verifies the displayed South hand order without changing card ownership. |
| T048 | Ensure South cards are not selectable, playable, discardable, or otherwise actionable. | PRD-006 AC4 | Interaction test verifies tapping a South card causes no gameplay state change. |
| T049 | Add `card_back.png` as the hidden-card asset for simulated players. | PRD-007 AC1 | Asset or UI test verifies hidden cards render from `card_back.png`. |
| T050 | Render West, North, and East with 13 hidden card backs each. | PRD-007 AC1 | UI test verifies each simulated player area displays 13 hidden card backs. |
| T051 | Ensure simulated player ranks and suits are not visible. | PRD-007 AC2 | UI test verifies simulated areas expose no card rank or suit values. |
| T052 | Ensure simulated player areas expose no action controls. | PRD-007 AC3 | UI test verifies simulated controls are absent. |
| T053 | Display a completion message such as `Deal complete` after all cards are dealt. | PRD-008 AC1 | UI test verifies the completion message appears after dealing. |
| T054 | Add a `New Deal` action on the dealt screen. | PRD-008 AC4, PRD-009 AC1 | UI test verifies `New Deal` is visible and tappable after dealing. |

## 9. Prohibited UI and Scope Guards

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T055 | Verify no bidding UI is shown after a completed deal. | PRD-008 AC2 | `testNoGameplayControlsAreShownAfterDeal` verifies bid controls are absent. |
| T056 | Verify no gameplay controls are shown after a completed deal. | PRD-008 AC3 | UI test verifies pass, trump/Tarneeb suit, play-card, trick, scoring, and game-over controls are absent. |
| T057 | Verify no card play, trick resolution, scoring, multiplayer, persistence, accounts, AI behavior, or user-facing error handling is introduced. | PRD-006 AC4, PRD-007 AC3, PRD-008 AC2, PRD-008 AC3 | Code review and tests confirm the app remains deal-only. |

## 10. New Deal Flow

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T058 | Add a UI test for tapping `New Deal` after a completed deal. | PRD-008 AC4, PRD-009 AC1 | Test fails until prior displayed hands are replaced after tapping `New Deal`. |
| T059 | Ensure `New Deal` clears previous hands before showing the new completed deal. | PRD-009 AC1 | UI or presentation-state test verifies prior hand data is not retained as current state. |
| T060 | Ensure `New Deal` uses a fresh 52-card deck or fully reset deck. | PRD-009 AC2 | Unit test verifies new deal starts from a complete valid deck. |
| T061 | Ensure `New Deal` shuffles before assigning cards. | PRD-009 AC3, PRD-004 AC1 | Unit test verifies the new-deal path goes through the Swift-shuffle-backed wrapper. |
| T062 | Ensure `New Deal` completes with 13 cards for each player. | PRD-009 AC4, PRD-005 AC1 | `testNewDealResetsAndDealsAgain` verifies each player again has 13 cards. |

## 11. Responsiveness and Final Verification

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T063 | Verify dealing completes quickly enough to feel immediate. | PRD-005 AC1, NFR-002 | Manual QA confirms no noticeable blocking during a deal. |
| T064 | Verify the UI remains responsive after dealing and after `New Deal`. | PRD-008 AC4, PRD-009 AC1, NFR-002 | Manual QA confirms the app remains interactive after each deal. |
| T065 | Verify required UI remains usable on at least one small-screen simulator. | PRD-001 AC1-AC3, PRD-006 AC1-AC4, PRD-007 AC1-AC3, PRD-008 AC1-AC4 | Manual QA confirms required labels, cards, hidden backs, completion message, and buttons remain usable. |
| T066 | Run the full domain unit test suite. | PRD-002 AC1-AC6, PRD-003 AC1-AC5, PRD-004 AC1-AC3, PRD-005 AC1-AC5, PRD-009 AC1-AC4 | All deck, shuffle, player setup, deal, phase, sorting, and new-deal unit tests pass. |
| T067 | Run the full UI test suite. | PRD-001 AC1-AC3, PRD-006 AC1-AC4, PRD-007 AC1-AC3, PRD-008 AC1-AC4, PRD-009 AC1-AC4 | All launch, deal, simulated-hand, prohibited-control, and new-deal UI tests pass. |
| T068 | Perform final manual acceptance against the Definition of Done. | PRD-001 through PRD-009 | Manual checklist confirms the MVP launches, deals, displays only South, hides simulated hands, shows completion, supports `New Deal`, and stops before gameplay. |

## 12. Suggested Implementation Order

1. Complete project and test setup tasks T001 through T003.
2. Implement domain model tasks T004 through T014.
3. Implement initial player setup tasks T015 through T019.
4. Implement deck and shuffle tasks T020 through T026.
5. Implement deal service tasks T027 through T034.
6. Implement presentation state tasks T035 through T039.
7. Implement initial and dealt UI tasks T040 through T054.
8. Add prohibited UI and scope guards T055 through T057.
9. Complete new-deal flow tasks T058 through T062.
10. Complete responsiveness and final verification tasks T063 through T068.

