# Tarneeb iOS MVP 003 Implementation Tasks

This task list is derived from `requirements.md`, `design.md`, and the token
source referenced by the design, `design-tokens.md`. It is an implementation
plan only; no code is included here.

Acceptance criteria are referenced as `PRD-### AC#`, where `AC#` is the
acceptance criterion order within that product requirement. Non-functional
requirements are referenced as `NFR-###`.

All color, typography, and title-shadow implementation work must use
`specs/003-mvp/design-tokens.md` as the source of truth. Do not introduce
concrete color, font, tracking, or shadow values outside the token source. If
implementation needs a value that is not already represented, update the token
spec before adding or consuming that value.

## 1. Project, Test, and Token Source Setup

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T001 | Confirm the iOS SwiftUI app target still launches the Tarneeb app. | PRD-001 AC1, PRD-001 AC2, NFR-001 | The app target builds and launches to a SwiftUI root screen. |
| T002 | Confirm the unit test target can test domain logic, presentation mapping, token roles, card sizing, deck stack state, title presentation, action labels, and reset state without loading SwiftUI views. | PRD-003 AC1-AC5, PRD-004 AC1-AC3, PRD-005 AC1-AC6, PRD-006 AC3-AC8, PRD-010 AC3-AC7, PRD-012 AC4-AC8, PRD-013 AC1-AC7, NFR-003 | Unit tests can run for deck, deal, sort, token role, card sizing, central deck stack, table title, action-label, and launch-reset logic. |
| T003 | Confirm the UI test target can launch the app and query stable labels or identifiers. | PRD-001 AC1-AC5, PRD-002 AC1-AC2, PRD-010 AC1-AC7, PRD-011 AC1-AC9, PRD-012 AC1-AC8, PRD-013 AC1-AC7, NFR-003 | UI tests can find the table, title, bottom controls, player stations, card stack, South cards, hidden hands, completion message, and reset state. |
| T004 | Add or verify stable accessibility identifiers for the circular card table, table title, initial deck stack, each player station, South hand, simulated hidden hands, completion label, bottom `New Game` button, and bottom `Deal` button. | PRD-010 AC1-AC7, PRD-011 AC1-AC9, PRD-012 AC1-AC8, PRD-013 AC1-AC7, NFR-003 | UI tests can target all layout-critical MVP 003 elements without brittle text-only queries. |
| T005 | Add or verify stable test hooks for suit presentation roles, token keys, title typography tokens, title shadow tokens, deck stack count, card size categories, and layout metrics. | PRD-006 AC4-AC8, PRD-007 AC4-AC6, PRD-010 AC1-AC7, PRD-011 AC8-AC9, NFR-003, NFR-005 | Tests can inspect semantic roles and metadata without relying only on screenshots. |
| T006 | Identify the smallest supported simulator to use for MVP 003 layout verification. | PRD-011 AC9, NFR-005 | The chosen simulator is documented in test output or manual QA notes; if product does not specify one, use the smallest simulator supported by the project. |
| T007 | Define an implementation test tolerance for UI geometry checks that need it. | PRD-010 AC2, PRD-011 AC1-AC4, NFR-003 | Geometry-based UI tests have an explicit tolerance for table diameter, relative station positions, and bottom control placement. |
| T008 | Add or verify a single design-token implementation source that covers every token named in `design.md` section 2.5. | PRD-006 AC4-AC5, PRD-010 AC3, PRD-012 AC1-AC8, NFR-005 | A token test or inspection proves all required token keys are available from one token source. |
| T009 | Add a guard that concrete color, font, tracking, or title-shadow values are not introduced outside the token source. | PRD-006 AC4-AC5, PRD-010 AC3, PRD-012 AC1-AC8, NFR-003, NFR-005 | A unit test, static check, or documented review check fails if UI/presentation code defines raw visual values outside the token source. |
| T010 | Verify `card_back.png` is available through the app asset catalog under the expected asset name. | PRD-007 AC1, PRD-010 AC5 | Asset or UI test confirms hidden card backs can render for simulated hands and the initial central deck stack. |

## 2. Baseline Domain and Deal Correctness

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T011 | Verify the app model includes only spades, clubs, hearts, and diamonds. | PRD-003 AC2 | Unit tests enumerate exactly four allowed suits. |
| T012 | Verify the app model includes only ranks 2 through Ace. | PRD-003 AC3 | Unit tests enumerate exactly thirteen allowed ranks. |
| T013 | Verify card identity is stable and derived from suit and rank. | PRD-003 AC5 | Unit tests prove duplicate suit-rank pairs cannot appear as unique identities. |
| T014 | Verify canonical deck creation returns one 52-card deck. | PRD-003 AC1 | `testDeckContains52Cards` passes. |
| T015 | Verify the canonical deck contains no jokers or unsupported card values. | PRD-003 AC2, PRD-003 AC3, PRD-003 AC4 | `testDeckContainsNoJokers` and allowed-value tests pass. |
| T016 | Verify every canonical deck card is unique. | PRD-003 AC5, NFR-004 | `testDeckContainsUniqueCards` passes. |
| T017 | Verify the model contains exactly four seats: South, West, North, and East. | PRD-002 AC1, PRD-002 AC2 | Unit tests enumerate exactly four seat values and labels. |
| T018 | Verify South is the only human player. | PRD-002 AC3, PRD-002 AC4 | Player setup tests pass for human and simulated assignments. |
| T019 | Verify South/North and East/West team assignments. | PRD-002 AC5, PRD-002 AC6 | Team assignment tests pass. |
| T020 | Verify game state includes only `notStarted` and `dealt` MVP phases. | PRD-005 AC5 | Unit tests or compiler-enforced model review confirm no extra gameplay phases are introduced. |
| T021 | Verify the initial app state contains four empty player seats. | PRD-001 AC3, PRD-002 AC1, PRD-002 AC2 | Initial-state tests pass with four seats and zero dealt cards before `Deal`. |
| T022 | Verify production deal flow shuffles before assigning cards. | PRD-004 AC1, PRD-009 AC3 | A test shuffler or spy proves shuffle is invoked before assignment. |
| T023 | Verify shuffle preserves card count and uniqueness. | PRD-004 AC3, NFR-004 | Shuffle preservation tests pass with 52 unique cards after shuffle. |
| T024 | Verify separate deals do not intentionally preserve the same card order. | PRD-004 AC2 | A test or code review check confirms production replacement deals pass through the shuffler rather than reusing prior order. |
| T025 | Verify the deal service assigns four 13-card chunks in South, East, North, West model order. | PRD-005 AC1, PRD-005 AC2 | Deterministic-shuffle unit test verifies chunk ownership by seat. |
| T026 | Verify each completed deal assigns exactly 13 cards to each player. | PRD-005 AC1 | Deal tests pass for all four hand counts. |
| T027 | Verify every completed deal assigns all 52 cards. | PRD-005 AC2, PRD-005 AC4 | Deal tests pass for 52 total dealt cards and zero undealt cards. |
| T028 | Verify no completed deal contains duplicate assigned cards. | PRD-005 AC3, NFR-004 | Duplicate-card validation tests pass. |
| T029 | Verify completed deals record game phase as `Dealt`. | PRD-005 AC5 | Phase tests pass after a valid deal. |
| T030 | Verify invalid internal deal states cannot be exposed as valid completed deals. | PRD-005 AC1-AC5, NFR-004 | Tests cover missing cards, duplicate cards, incorrect hand counts, and undealt cards without adding user-facing error UI. |
| T031 | Verify replacement deals clear or replace the previous hands before rendering the new completed deal. | PRD-009 AC1 | Unit or UI tests confirm previous hand data is not current after the replacement `Deal` action. |
| T032 | Verify replacement deals start from a fresh or fully reset 52-card deck. | PRD-009 AC2 | Unit tests confirm the replacement path uses a complete valid deck. |
| T033 | Verify replacement deals shuffle before assigning replacement cards. | PRD-009 AC3, PRD-004 AC1 | Spy shuffler test confirms shuffle invocation in the replacement-deal path. |
| T034 | Verify replacement deals complete with 13 cards for each player. | PRD-009 AC4 | Unit or UI tests confirm each player again has 13 cards after replacement `Deal`. |

## 3. Presentation Mapping and Token Roles

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T035 | Add or verify a presentation mapping for suit symbols. | PRD-006 AC3 | Unit tests map each suit to a visible symbol. |
| T036 | Add or verify a presentation mapping for rank labels. | PRD-006 AC3 | Unit tests map each rank to the required number or letter label. |
| T037 | Add a unit test that Hearts and Diamonds map to `suitWarm`. | PRD-006 AC4, NFR-005 | Suit presentation tests fail if Hearts or Diamonds do not use `suitWarm`. |
| T038 | Implement or verify the `suitWarm` presentation role resolves to `color.card.suit.red`. | PRD-006 AC4, NFR-005 | Token role tests pass for Hearts and Diamonds without exposing concrete color values from card presentation. |
| T039 | Add a unit test that Clubs and Spades map to `suitNeutral`. | PRD-006 AC5, NFR-005 | Suit presentation tests fail if Clubs or Spades do not use `suitNeutral`. |
| T040 | Implement or verify the `suitNeutral` presentation role resolves to `color.card.suit.black`. | PRD-006 AC5, NFR-005 | Token role tests pass for Clubs and Spades without exposing concrete color values from card presentation. |
| T041 | Add a unit test that card presentation exposes `suitColorRole` and `suitColorToken`. | PRD-006 AC4, PRD-006 AC5, NFR-003, NFR-005 | Card presentation tests fail if a card lacks either the semantic role or token key. |
| T042 | Verify card presentation never emits concrete color values. | PRD-006 AC4, PRD-006 AC5, NFR-003, NFR-005 | Presentation mapping tests prove cards expose roles and token keys only. |
| T043 | Add a unit test for South-hand suit sort order Hearts, Clubs, Diamonds, Spades. | PRD-006 AC6 | Sort test fails unless suit order matches the requirement. |
| T044 | Add a unit test for South-hand rank sort order 2 through Ace within each suit. | PRD-006 AC7 | Sort test fails unless rank order matches the requirement. |
| T045 | Implement or verify display-only South-hand sorting. | PRD-006 AC6, PRD-006 AC7 | Sort tests pass and card ownership is unchanged. |
| T046 | Add a unit test for exposed card presentation values: card identity, rank text, suit symbol, token role, token key, and accessibility label. | PRD-006 AC3-AC5, NFR-003 | Card presentation tests pass without SwiftUI view inspection. |
| T047 | Add or verify a presentation configuration for shared player-card base dimensions. | PRD-006 AC8, PRD-007 AC4, PRD-011 AC8 | Unit tests can compare one shared card size source for exposed cards and simulated hidden backs. |
| T048 | Verify the shared player-card size uses a standard-card aspect ratio. | PRD-006 AC8, PRD-007 AC4 | Unit test or presentation-config test verifies approximately 5:7 width-to-height behavior. |
| T049 | Add or verify hidden-hand presentation for simulated seats. | PRD-007 AC1, PRD-007 AC2, PRD-007 AC6 | Unit tests verify hidden count/back representation and no rank/suit/card identity exposure. |
| T050 | Add or verify hidden-stack offset configuration for compact simulated hands. | PRD-007 AC5, PRD-007 AC6 | Unit tests or snapshot/manual QA can confirm the stack is compact and still represents 13 hidden cards. |
| T051 | Add a central deck stack presentation model derived from `phase = notStarted`. | PRD-010 AC5, PRD-010 AC6 | Unit tests verify the initial stack represents 52 hidden cards and exposes no ranks or suits. |
| T052 | Verify central deck stack presentation is visible only before a completed deal. | PRD-005 AC6, PRD-010 AC7 | Unit tests verify stack visibility is true in `notStarted` and false in `dealt`. |
| T053 | Add deck stack layout metadata for the initial 52-card stack. | PRD-010 AC5 | Unit tests or UI metadata verify the stack is configured as non-fanned with zero spread and no rotation. |
| T054 | Add a table title presentation model for text, font token, 26pt font-size token, tracking token range, text color/opacity tokens, shadow tokens, and accessibility identifier. | PRD-001 AC1, PRD-010 AC3 | Unit tests verify title presentation uses only `design-tokens.md` token keys and static text `طرنيب`. |
| T055 | Verify the table title presentation remains visible above the initial central deck stack. | PRD-010 AC4 | Presentation or UI geometry test confirms the stack sits below the title and does not overlap it in the initial state. |
| T056 | Add layout metric presentation for table diameter. | PRD-010 AC2 | Unit or UI test metadata verifies table diameter is calculated as half the current screen width. |
| T057 | Add layout metric presentation for station placement around the table. | PRD-011 AC1-AC4 | Unit or UI test metadata verifies North, West, South, and East relative positions. |
| T058 | Add presentation state for the visible action labels `New Game` and `Deal`. | PRD-001 AC2, PRD-001 AC5, PRD-008 AC5-AC6, PRD-009 AC6, PRD-012 AC4-AC8, PRD-013 AC7 | Unit tests verify visible and accessibility action labels emit `New Game` and `Deal`, never `Deal Cards` or `New Deal`. |
| T059 | Map visible `Deal` buttons to primary deal tokens and visible `New Game` buttons to secondary new-game tokens. | PRD-012 AC1-AC8, NFR-005 | Token tests verify `Deal` controls use `color.button.deal.*` and `New Game` controls use `color.button.newGame.*`. |

## 4. Presentation State and Action Flow

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T060 | Verify presentation state starts with `notStarted`, four empty seats, visible central deck stack, visible table title, visible `New Game` and `Deal` actions, and no dealt card presentations. | PRD-001 AC3, PRD-001 AC5, PRD-002 AC1, PRD-010 AC3, PRD-010 AC5, PRD-012 AC1, PRD-012 AC6 | Unit tests pass for initial presentation state. |
| T061 | Connect the visible `Deal` action in `notStarted` to the first-deal path. | PRD-001 AC2, PRD-005 AC1-AC6 | Unit or UI tests verify tapping `Deal` transitions to a valid dealt display and hides the central stack. |
| T062 | Prevent overlapping deal requests from repeated rapid `Deal` taps before the first deal completes. | PRD-005 AC1-AC6, NFR-002, NFR-004 | Repeated-tap tests end in one valid completed deal with no duplicate or partial hands. |
| T063 | Connect the visible `Deal` action in `dealt` to the replacement-deal path. | PRD-008 AC5, PRD-009 AC1-AC6 | Unit or UI tests verify tapping `Deal` after completion produces another valid completed deal. |
| T064 | Ensure replacement `Deal` keeps the central deck stack hidden. | PRD-005 AC6, PRD-010 AC7 | Unit or UI tests verify the central stack remains absent after replacement deals. |
| T065 | Ensure replacement `Deal` reapplies portrait table layout, rounded-square station behavior, shared card sizing, and token-backed suit presentation. | PRD-009 AC5, PRD-011 AC1-AC9, NFR-005 | UI or presentation tests verify layout, sizing, and token expectations still hold after replacement `Deal`. |
| T066 | Connect the visible `New Game` action in all MVP phases to the launch-state reset path. | PRD-001 AC5, PRD-008 AC6, PRD-012 AC6-AC8, PRD-013 AC1-AC7 | Unit or UI tests verify `New Game` clears dealt hands, hides `Deal complete`, restores the central deck stack, returns to `notStarted`, and does not deal from the initial state. |

## 5. Portrait Orientation

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T067 | Implement portrait-only orientation support using the project-appropriate iOS mechanism. | PRD-001 AC4, NFR-001 | Build settings, app configuration, or runtime policy restricts the app to portrait. |
| T068 | Add a UI test or configuration verification that the app launches in portrait. | PRD-001 AC4, NFR-001 | Orientation test or inspection confirms portrait on launch. |
| T069 | Add a UI test or manual verification that device rotation does not switch the app to landscape. | PRD-001 AC4, NFR-001 | Rotation verification confirms the app remains portrait. |
| T070 | Verify no landscape-only layout branch or landscape-only UI is introduced. | PRD-001 AC4, NFR-001 | Code review or test coverage confirms MVP 003 remains portrait-only. |

## 6. Initial Table Scene UI

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T071 | Build or update the root screen into a main table scene plus bottom control area. | PRD-010 AC1, PRD-012 AC1, PRD-012 AC6 | UI test or snapshot verifies the table scene and bottom `New Game` plus `Deal` controls render on launch. |
| T072 | Render a circular card table in the center area of the initial screen. | PRD-010 AC1 | UI test, view metadata, screenshot, or manual QA confirms a circle is visible. |
| T073 | Size the circular card table to half the screen width. | PRD-010 AC2 | UI geometry test or accessibility metadata verifies the diameter within the defined tolerance. |
| T074 | Render `طرنيب` centered on the circular card table. | PRD-001 AC1, PRD-010 AC3 | UI test verifies the title is located within the card table rather than as a top page title. |
| T075 | Apply the table-title font and 26pt font-size tokens to the `طرنيب` title. | PRD-001 AC1, PRD-010 AC3 | Unit/view-inspection/snapshot/manual QA verifies the title uses `typography.tableTitle.font` and `typography.tableTitle.fontSize`. |
| T076 | Apply table-title tracking within the token range. | PRD-001 AC1, PRD-010 AC3 | Unit/view-inspection/snapshot/manual QA verifies tracking is within the token-defined range. |
| T077 | Apply the table-title text color and opacity tokens. | PRD-001 AC1, PRD-010 AC3, NFR-005 | Token test or UI inspection verifies the title uses `color.tableTitle.text` and `effect.tableTitle.text.opacity`. |
| T078 | Apply the table-title shadow tokens. | PRD-001 AC1, PRD-010 AC3, NFR-005 | Token test or manual QA verifies shadow values come from `effect.tableTitle.shadow.*`. |
| T079 | Render a non-fanned 52-card hidden deck stack just below the table title before the first deal. | PRD-010 AC5 | UI test or accessibility metadata verifies the stack is present, below-title, hidden-card-only, count 52, and has no spread or rotation. |
| T080 | Ensure the initial deck stack does not obscure the `طرنيب` title. | PRD-010 AC4 | UI geometry check or manual QA confirms the stack sits below the title without overlapping it. |
| T081 | Ensure the initial deck stack reveals no ranks, suits, or card identities. | PRD-010 AC6 | UI/accessibility tests verify no rank/suit/card identity values appear in the stack. |
| T082 | Render four player stations on launch. | PRD-002 AC1, PRD-002 AC2 | UI test finds exactly South, West, North, and East station identifiers. |
| T083 | Render all launch player stations as rounded squares. | PRD-002 AC7, PRD-011 AC5 | UI test, snapshot, or manual QA confirms rounded-square station appearance before deal. |
| T084 | Position launch player stations around the circular card table. | PRD-011 AC1, PRD-011 AC2 | UI geometry test, screenshot, or manual QA confirms North above, West left, South below, East right. |
| T085 | Verify South/North and East/West appear opposite each other around the table. | PRD-011 AC3, PRD-011 AC4 | Layout test or manual QA confirms partner opposition. |
| T086 | Render the initial bottom controls as `New Game` and `Deal` at the bottom of the screen. | PRD-001 AC2, PRD-001 AC5, PRD-012 AC1, PRD-012 AC6 | UI test finds `New Game` and `Deal` in the bottom control area on launch. |
| T087 | Verify no visible dealt player hands appear before the first `Deal`. | PRD-001 AC3 | UI test confirms South visible cards and simulated hidden hands are absent before the first deal. |
| T088 | Verify `Deal Cards` and `New Deal` labels are absent on launch while `New Game` remains present. | PRD-012 AC4, PRD-012 AC5, PRD-012 AC8 | UI test confirms old action labels are absent and the reset action is labeled `New Game`. |

## 7. Dealt Table Scene UI

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T089 | Tap `Deal` and render a valid dealt table screen. | PRD-005 AC1-AC6, PRD-008 AC1 | UI test verifies the app reaches the dealt state after tapping `Deal`. |
| T090 | Hide the central 52-card deck stack after the deal completes. | PRD-005 AC6, PRD-010 AC7 | UI test verifies the initial central stack is absent after deal. |
| T091 | Keep the circular card table visible after deal. | PRD-010 AC1, PRD-011 AC1 | UI test or manual QA confirms the table remains in the dealt screen. |
| T092 | Keep player stations surrounding the card table after deal. | PRD-011 AC1, PRD-011 AC2 | UI geometry test, screenshot, or manual QA confirms the station relationship after deal. |
| T093 | Expand the South station below the card table after deal. | PRD-006 AC2, PRD-011 AC6 | UI geometry test or manual QA confirms South expands below the table to contain the human hand. |
| T094 | Render exactly 13 South cards after a completed deal. | PRD-006 AC1, PRD-005 AC1 | UI test verifies 13 visible South card elements. |
| T095 | Render rank and suit symbol on every exposed South card. | PRD-006 AC3 | UI test or presentation test verifies each visible card exposes rank and suit. |
| T096 | Render Hearts and Diamonds rank/suit text using `suitWarm` resolved to `color.card.suit.red`. | PRD-006 AC4, NFR-005 | Unit role tests plus visual/UI verification confirm Hearts and Diamonds use the required token-backed role. |
| T097 | Render Clubs and Spades rank/suit text using `suitNeutral` resolved to `color.card.suit.black`. | PRD-006 AC5, NFR-005 | Unit role tests plus visual/UI verification confirm Clubs and Spades use the required token-backed role. |
| T098 | Verify exposed card surfaces use `color.card.background`, `color.card.border`, and `color.card.shadow`. | PRD-006 AC8, NFR-005 | UI inspection, snapshot, or manual QA confirms face-up card styling uses card surface tokens. |
| T099 | Verify the displayed South hand is sorted by suit then rank. | PRD-006 AC6, PRD-006 AC7 | Unit or UI test verifies visible ordering. |
| T100 | Render exposed South cards using the shared standard-card base size and aspect ratio. | PRD-006 AC8 | UI test, snapshot, or manual QA confirms readable standard-card proportions. |
| T101 | Ensure exposed South cards fit within the expanded South station without overlapping unrelated UI. | PRD-006 AC9, PRD-011 AC8 | UI test or manual QA confirms South hand does not cover labels, completion message, or the bottom controls. |
| T102 | Ensure South cards are not selectable, playable, discardable, or otherwise actionable. | PRD-006 AC10 | Interaction test taps South cards and verifies no gameplay state change or play controls appear. |
| T103 | Render West, North, and East with 13 hidden card backs each after a completed deal. | PRD-007 AC1 | UI test verifies each simulated station represents 13 hidden backs. |
| T104 | Ensure simulated stations do not reveal rank, suit, or card identity values. | PRD-007 AC2 | UI test verifies simulated areas expose no rank/suit labels and hidden presentation exposes no card IDs. |
| T105 | Ensure simulated stations expose no action controls. | PRD-007 AC3 | UI test confirms no simulated play, pass, bid, or other action controls exist. |
| T106 | Render hidden backs at the same base size and aspect ratio as exposed South cards. | PRD-007 AC4, PRD-006 AC8 | UI/snapshot/manual QA or presentation test confirms shared player-card sizing. |
| T107 | Keep West, North, and East stations compact after deal when screen space allows. | PRD-007 AC5, PRD-011 AC7 | UI/snapshot/manual QA confirms simulated stations fit their labels and hidden arrays without large empty panels. |
| T108 | Verify any simulated spread stack still represents 13 hidden cards without revealing card data. | PRD-007 AC6 | UI test or accessibility metadata verifies hidden count and no rank/suit exposure. |
| T109 | Display `Deal complete` after all cards are dealt. | PRD-008 AC1 | UI test finds the completion message after dealing. |
| T110 | Position `Deal complete` above the bottom control row. | PRD-008 AC2, PRD-012 AC3 | UI geometry test or manual QA confirms the completion label is above `New Game` and `Deal`. |
| T111 | Keep the dealt-state bottom controls labeled `New Game` and `Deal` at the bottom of the screen. | PRD-012 AC2, PRD-012 AC7, PRD-009 AC6 | UI test verifies both bottom actions remain visible after a completed deal. |
| T112 | Verify `Deal Cards` and `New Deal` labels are absent after a completed deal while `New Game` remains present. | PRD-012 AC4, PRD-012 AC5, PRD-012 AC8 | UI test confirms old labels are absent after dealing and the reset action is labeled `New Game`. |
| T113 | Tap `Deal` after completion and render another valid completed deal. | PRD-008 AC5, PRD-009 AC1-AC6 | UI test verifies replacement deal behavior, valid hands, old labels absent, and central stack still hidden. |

## 8. Layout, Small-Screen, and Responsiveness Verification

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T114 | Ensure labels, cards, message text, deck stack, table title, player stations, and bottom controls do not incoherently overlap on the primary simulator. | PRD-006 AC9, PRD-011 AC8, PRD-012 AC1-AC3, PRD-012 AC6-AC7, NFR-005 | UI test, snapshot, or manual QA confirms all required elements remain readable and usable. |
| T115 | Ensure the bottom controls remain usable when the South station expands after deal. | PRD-006 AC2, PRD-011 AC6, PRD-012 AC2, PRD-012 AC7 | UI test or manual QA confirms South expansion does not block `New Game` or `Deal`. |
| T116 | Verify launch layout remains usable on the chosen small-screen simulator. | PRD-011 AC9, NFR-005 | Small-screen UI test or manual QA confirms the table, title, deck stack, stations, and bottom controls are usable before deal. |
| T117 | Verify dealt layout remains usable on the chosen small-screen simulator. | PRD-011 AC9, NFR-005 | Small-screen UI test confirms stations, South cards, hidden backs, completion message, and bottom controls are usable after deal. |
| T118 | Verify dealing completes quickly enough to feel immediate. | PRD-005 AC1, NFR-002 | UI test timing or manual QA confirms no noticeable blocking during deal. |
| T119 | Verify UI remains responsive after first deal, replacement deal, and `New Game` reset. | PRD-008 AC5-AC6, PRD-009 AC1, PRD-013 AC1-AC7, NFR-002 | UI test continues interacting after first deal, replacement deal, and reset without long waits. |
| T120 | Verify visual layout, card sizing, token resolution, and deck stack rendering do not introduce noticeable blocking. | PRD-006 AC8, PRD-007 AC4, PRD-010 AC5, PRD-011 AC8, NFR-002 | Manual QA or UI timing confirms MVP 003 rendering remains responsive. |

## 9. Prohibited UI and Scope Guards

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T121 | Verify no bidding UI appears after a completed deal. | PRD-008 AC3 | UI test confirms bid controls are absent. |
| T122 | Verify no gameplay controls appear after a completed deal. | PRD-008 AC4 | UI test confirms pass, trump/Tarneeb selector, play-card, trick, score, and game-over controls are absent. |
| T123 | Verify no simulated player action controls appear. | PRD-007 AC3, PRD-008 AC4 | UI test confirms simulated stations expose no controls. |
| T124 | Verify no out-of-scope persistence, accounts, multiplayer, advanced AI, sound, landscape UI, or custom card art is introduced. | PRD-008 AC3, PRD-008 AC4, NFR-001 | Code review and UI tests confirm the app remains a portrait deal-only MVP. |

## 10. Manual Visual QA

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T125 | Perform manual visual QA for portrait orientation and rotation behavior. | PRD-001 AC4, NFR-001 | Manual QA confirms the screen remains portrait when the device rotates. |
| T126 | Perform manual visual QA for circular table placement and approximate half-screen-width sizing. | PRD-010 AC1, PRD-010 AC2 | Manual QA confirms the table is circular, centered in the intended table area, and appears about half the screen width. |
| T127 | Perform manual visual QA for the table title treatment. | PRD-001 AC1, PRD-010 AC3, PRD-010 AC4, NFR-005 | Manual QA confirms the title is centered on the table, not a top title, uses token-backed title styling, and remains visible above the initial deck stack. |
| T128 | Perform manual visual QA for the initial central 52-card deck stack. | PRD-010 AC5, PRD-010 AC6, PRD-010 AC7 | Manual QA confirms the stack is non-fanned, below the title, hidden-card-only, does not cover the title, and disappears after deal. |
| T129 | Perform manual visual QA for rounded-square player stations surrounding the table. | PRD-002 AC7, PRD-011 AC1-AC5 | Manual QA confirms North top, West left, South bottom, East right, with partners opposite. |
| T130 | Perform manual visual QA for South station expansion. | PRD-006 AC2, PRD-011 AC6 | Manual QA confirms South expands below the table after deal and exposed cards remain readable. |
| T131 | Perform manual visual QA for compact simulated stations. | PRD-007 AC5, PRD-011 AC7 | Manual QA confirms North/West/East stations are compact compared with expanded South where screen space allows. |
| T132 | Perform manual visual QA for token-backed suit styling. | PRD-006 AC4, PRD-006 AC5, NFR-005 | Manual QA confirms `suitWarm` and `suitNeutral` are visually distinct and match the token spec. |
| T133 | Perform manual visual QA for hidden and exposed player-card size parity. | PRD-006 AC8, PRD-007 AC4, NFR-005 | Manual QA confirms hidden backs and exposed cards share readable standard-card base size. |
| T134 | Perform manual visual QA for bottom control placement. | PRD-008 AC2, PRD-012 AC1-AC8 | Manual QA confirms `Deal complete` appears above the bottom control row and `New Game` plus `Deal` remain reachable. |
| T135 | Perform manual visual QA for small-screen usability. | PRD-011 AC8, PRD-011 AC9, NFR-005 | Manual QA confirms all required labels, cards, hidden backs, deck stack, completion message, and bottom controls remain usable on the chosen small-screen simulator. |

## 11. Final Test Runs and Acceptance

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T136 | Run the full domain unit test suite. | PRD-002 AC1-AC6, PRD-003 AC1-AC5, PRD-004 AC1-AC3, PRD-005 AC1-AC5, PRD-009 AC1-AC4, NFR-003, NFR-004 | All domain unit tests pass. |
| T137 | Run presentation-mapping unit tests. | PRD-006 AC3-AC8, PRD-007 AC1-AC6, PRD-010 AC3-AC7, PRD-012 AC4-AC8, PRD-013 AC1-AC7, NFR-003, NFR-005 | Tests pass for token usage, action labels, reset state, card size, title presentation, hidden hands, and deck stack state. |
| T138 | Run orientation and primary UI tests on the primary simulator. | PRD-001 AC1-AC5, PRD-005 AC6, PRD-006 AC1-AC10, PRD-007 AC1-AC6, PRD-008 AC1-AC6, PRD-010 AC1-AC7, PRD-011 AC1-AC8, PRD-012 AC1-AC8, PRD-013 AC1-AC7 | All launch, portrait, table, deal, card display, hidden-hand, completion, reset, prohibited-control, and replacement-deal UI tests pass. |
| T139 | Run layout-focused UI tests on the chosen small-screen simulator. | PRD-011 AC9, NFR-005 | Small-screen test run passes for required stations, table, title, deck stack, cards, hidden backs, message, and bottom controls. |
| T140 | Perform final manual acceptance against the MVP 003 Definition of Done and token usage checklist. | PRD-001 through PRD-013, NFR-001 through NFR-005 | Manual checklist confirms portrait launch, bottom `New Game` plus `Deal`, central table, token-backed title, initial deck stack, rounded-square stations, valid deal, hidden simulated hands, South expansion, completion placement, reset behavior, replacement deal, card readability, and no out-of-scope gameplay. |

## 12. Suggested Implementation Order

1. Complete project, test, and token source setup tasks T001 through T010.
2. Verify or complete baseline domain and deal correctness tasks T011 through T034.
3. Implement presentation mapping and token role tasks T035 through T059.
4. Update presentation state and action flow tasks T060 through T066.
5. Implement portrait orientation tasks T067 through T070.
6. Update initial table scene UI tasks T071 through T088.
7. Update dealt table scene UI tasks T089 through T113.
8. Complete layout, small-screen, and responsiveness verification tasks T114 through T120.
9. Complete prohibited UI and scope guard tasks T121 through T124.
10. Complete manual visual QA tasks T125 through T135.
11. Complete final test runs and acceptance tasks T136 through T140.

## 13. Ambiguities to Keep Flagged During Implementation

- Exact card dimensions in points are unspecified; choose responsive values that preserve an approximately 5:7 ratio and verify readability.
- The initial 52-card deck stack card size is unspecified relative to player hidden cards; do not claim shared sizing unless implementation explicitly satisfies it.
- The smallest supported simulator is unspecified; use the smallest simulator supported by the project unless product names a stricter target.
- Portrait lock mechanism is unspecified; choose the project-appropriate iOS mechanism and verify behavior.
- "Very bottom" is unspecified relative to the safe area and scrollable content; verify bottom usability and keep the decision visible in tests or QA notes.
- Card table vertical position and geometry tolerances are unspecified; tests should verify required relationships and use documented tolerances.
- Rounded-square station dimensions, corner radius, stroke width, and compact size ratios are unspecified; choose responsive values and verify rounded-square readability.
- South station shape after expansion is unspecified; it may become a larger rounded station if it still satisfies South expansion and usability requirements.
- The table-title tracking requirement provides a range, not a single value; choose a value inside the token range.
- The title shadow is part of the specified style; use only the tokenized shadow values.
- Hidden hand stack offsets are unspecified; choose compact values that still represent the required hidden-card counts. The central deck stack must remain non-fanned.
- Automated rendered-token, font, shadow, and geometry verification may require accessibility metadata, view inspection, snapshots, or manual QA because XCTest may not directly inspect rendered values robustly.
- Error handling UX remains out of scope beyond preventing invalid completed states; do not introduce a user-facing error flow without a future requirement.
- The specified table-title font fallback is unspecified; do not silently choose a different brand font from `SF Arabic Rounded Bold` without flagging it.
