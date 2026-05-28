# Tarneeb iOS MVP 002 Implementation Tasks

This task list is derived from `requirements.md`, `design.md`, and
`design-tokens.md`. It is an implementation plan only; no code is included here.

Acceptance criteria are referenced as `PRD-### AC#`, where `AC#` is the
acceptance criterion order within that product requirement. Non-functional
requirements are referenced as `NFR-###`.

All color implementation work must use `specs/002-mvp/design-tokens.md` as the
source of truth. Do not introduce concrete color values outside the token source.
If implementation needs a color that is not already represented, update the token
spec before adding or consuming that color.

## 1. Project, Test, and Token Source Setup

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T001 | Confirm the iOS SwiftUI app target still launches the Tarneeb app. | PRD-001 AC1, PRD-001 AC2, NFR-001 | The app target builds and launches to a SwiftUI root screen. |
| T002 | Confirm the unit test target can test domain logic, presentation mapping, token roles, and card sizing without loading SwiftUI views. | PRD-003 AC1-AC5, PRD-004 AC1-AC3, PRD-005 AC1-AC5, PRD-006 AC3-AC7, PRD-007 AC4, NFR-003 | Unit tests can run for deck, deal, sort, token role, token key, and card sizing logic. |
| T003 | Confirm the UI test target can launch the app and query stable labels or identifiers. | PRD-001 AC1-AC3, PRD-002 AC1-AC2, PRD-010 AC1-AC7, NFR-003 | UI tests can find the title, actions, seats, cards, hidden backs, and completion message. |
| T004 | Add or verify stable accessibility identifiers for layout-critical UI elements. | PRD-010 AC1-AC7, NFR-003 | UI tests can target North, West, South, East, South cards, hidden stacks, and action buttons without brittle text-only queries. |
| T005 | Add or verify stable test hooks for suit presentation roles, token keys, and card size categories. | PRD-006 AC3-AC7, PRD-007 AC4, NFR-003, NFR-005 | Tests can inspect `suitWarm`, `suitNeutral`, token keys, and shared card sizing without relying only on screenshots. |
| T006 | Identify the smallest supported simulator to use for MVP 002 layout verification. | PRD-010 AC7, NFR-005 | The chosen simulator is documented in test output or manual QA notes; if unspecified by product, use the smallest simulator supported by the project. |
| T007 | Add or verify a single design-token implementation source that covers every token named in `design.md` section 2.5 and 4.4. | PRD-006 AC3, PRD-006 AC4, PRD-008 AC4, NFR-005 | A token test or inspection proves all required token keys are available from one token source. |
| T008 | Add a guard that concrete color values are not introduced outside the token source. | PRD-006 AC3, PRD-006 AC4, NFR-003, NFR-005 | A unit test, static check, or documented review check fails if UI/presentation code defines raw color values outside the token source. |
| T009 | Verify the `New Deal` action uses the existing `newGame` button tokens until the token spec is renamed or aliased. | PRD-008 AC4, PRD-009 AC5, NFR-005 | Token usage tests or UI inspection confirm `New Deal` resolves through `color.button.newGame.*`. |

## 2. Baseline Domain and Deal Correctness

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T010 | Verify the app model includes only spades, clubs, hearts, and diamonds. | PRD-003 AC2 | Unit tests enumerate exactly four allowed suits. |
| T011 | Verify the app model includes only ranks 2 through Ace. | PRD-003 AC3 | Unit tests enumerate exactly thirteen allowed ranks. |
| T012 | Verify card identity is stable and derived from suit and rank. | PRD-003 AC5 | Unit tests prove duplicate suit-rank pairs cannot appear as unique identities. |
| T013 | Verify canonical deck creation returns one 52-card deck. | PRD-003 AC1 | `testDeckContains52Cards` passes. |
| T014 | Verify the canonical deck contains no jokers or unsupported card values. | PRD-003 AC2, PRD-003 AC3, PRD-003 AC4 | `testDeckContainsNoJokers` and allowed-value tests pass. |
| T015 | Verify every canonical deck card is unique. | PRD-003 AC5, NFR-004 | `testDeckContainsUniqueCards` passes. |
| T016 | Verify the model contains exactly four seats: South, West, North, and East. | PRD-002 AC1, PRD-002 AC2 | Unit tests enumerate exactly four seat values and labels. |
| T017 | Verify South is the only human player. | PRD-002 AC3, PRD-002 AC4 | Player setup tests pass for human and simulated assignments. |
| T018 | Verify South/North and East/West team assignments. | PRD-002 AC5, PRD-002 AC6 | Team assignment tests pass. |
| T019 | Verify game state includes only `notStarted` and `dealt` MVP phases. | PRD-005 AC5 | Unit tests or compiler-enforced model review confirm no extra gameplay phases are introduced. |
| T020 | Verify the initial app state contains four empty player seats. | PRD-001 AC3, PRD-002 AC1 | Initial-state tests pass with four seats and zero cards before `Deal Cards`. |
| T021 | Verify production deal flow shuffles before assigning cards. | PRD-004 AC1, PRD-009 AC3 | A test shuffler or spy proves shuffle is invoked before assignment. |
| T022 | Verify shuffle preserves card count and uniqueness. | PRD-004 AC3, NFR-004 | Shuffle preservation tests pass with 52 unique cards after shuffle. |
| T023 | Verify the deal service assigns four 13-card chunks in South, East, North, West model order. | PRD-005 AC1, PRD-005 AC2 | Deterministic-shuffle unit test verifies chunk ownership by seat. |
| T024 | Verify each completed deal assigns exactly 13 cards to each player. | PRD-005 AC1 | Deal tests pass for all four hand counts. |
| T025 | Verify every completed deal assigns all 52 cards. | PRD-005 AC2, PRD-005 AC4 | Deal tests pass for 52 total dealt cards and zero undealt cards. |
| T026 | Verify no completed deal contains duplicate assigned cards. | PRD-005 AC3, NFR-004 | Duplicate-card validation tests pass. |
| T027 | Verify completed deals record game phase as `Dealt`. | PRD-005 AC5 | Phase tests pass after a valid deal. |
| T028 | Verify invalid internal deal states cannot be exposed as valid completed deals. | PRD-005 AC1-AC5, NFR-004 | Tests cover missing cards, duplicate cards, and incorrect hand counts without adding user-facing error UI. |

## 3. Presentation Mapping and Token Roles

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T029 | Add or verify a presentation mapping for suit symbols. | PRD-006 AC2 | Unit tests map each suit to a visible symbol. |
| T030 | Add or verify a presentation mapping for rank labels. | PRD-006 AC2 | Unit tests map each rank to the required number or letter label. |
| T031 | Add a unit test that Hearts and Diamonds map to `suitWarm`. | PRD-006 AC3, NFR-005 | `testSuitPresentationColors` fails if Hearts or Diamonds do not use `suitWarm`. |
| T032 | Implement or verify the `suitWarm` presentation role resolves to `color.card.suit.red`. | PRD-006 AC3, NFR-005 | Token role tests pass for Hearts and Diamonds without exposing concrete color values from card presentation. |
| T033 | Add a unit test that Clubs and Spades map to `suitNeutral`. | PRD-006 AC4, NFR-005 | `testSuitPresentationColors` fails if Clubs or Spades do not use `suitNeutral`. |
| T034 | Implement or verify the `suitNeutral` presentation role resolves to `color.card.suit.black`. | PRD-006 AC4, NFR-005 | Token role tests pass for Clubs and Spades without exposing concrete color values from card presentation. |
| T035 | Add a unit test that card presentation exposes `suitColorRole` and `suitColorToken`. | PRD-006 AC3, PRD-006 AC4, NFR-003, NFR-005 | Card presentation tests fail if a card lacks either the semantic role or token key. |
| T036 | Verify card presentation never emits concrete color values. | PRD-006 AC3, PRD-006 AC4, NFR-003, NFR-005 | Presentation mapping tests prove cards expose roles and token keys only. |
| T037 | Add a unit test for South-hand suit sort order Hearts, Clubs, Diamonds, Spades. | PRD-006 AC5 | Sort test fails unless suit order matches the requirement. |
| T038 | Add a unit test for South-hand rank sort order 2 through Ace within each suit. | PRD-006 AC6 | Sort test fails unless rank order matches the requirement. |
| T039 | Implement or verify display-only South-hand sorting. | PRD-006 AC5, PRD-006 AC6 | Sort tests pass and card ownership is unchanged. |
| T040 | Add a unit test for exposed card presentation values: card identity, rank text, suit symbol, token role, token key, and accessibility label. | PRD-006 AC2-AC4, NFR-003 | Card presentation tests pass without SwiftUI view inspection. |
| T041 | Add a presentation configuration for shared exposed and hidden card base dimensions. | PRD-006 AC7, PRD-007 AC4, PRD-010 AC6 | Unit tests can compare one shared card size source for both card faces and backs. |
| T042 | Verify the shared card size uses a standard-card aspect ratio. | PRD-006 AC7, PRD-007 AC4 | Unit test or presentation-config test verifies approximately 5:7 width-to-height behavior. |
| T043 | Add a hidden-hand presentation model that represents 13 hidden cards without card identities. | PRD-007 AC1, PRD-007 AC2, PRD-007 AC6 | Unit tests verify hidden count/back representation and no rank/suit/card identity exposure. |
| T044 | Add or verify hidden-stack offset configuration for compact simulated hands. | PRD-007 AC5, PRD-007 AC6 | Unit tests or snapshot/manual QA can confirm the stack is compact and still represents 13 hidden cards. |

## 4. Presentation State

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T045 | Verify presentation state starts with `notStarted`, four empty seats, and no card presentations. | PRD-001 AC3, PRD-002 AC1, PRD-002 AC2 | Unit tests pass for initial presentation state. |
| T046 | Connect or verify the `Deal Cards` action creates a valid dealt presentation state. | PRD-001 AC2, PRD-005 AC1-AC5 | Unit or UI tests verify tapping `Deal Cards` transitions to a valid dealt display. |
| T047 | Prevent overlapping deal requests from repeated rapid `Deal Cards` taps. | PRD-005 AC1-AC5, NFR-002, NFR-004 | Repeated-tap tests end in one valid completed deal with no duplicate or partial hands. |
| T048 | Connect or verify the `New Deal` action clears/replaces previous hands and creates a new valid deal. | PRD-008 AC4, PRD-009 AC1-AC4 | New-deal tests verify old hand data is not retained as current state. |
| T049 | Ensure the new-deal presentation path reapplies diamond layout, shared card sizing, and token-backed suit presentation. | PRD-009 AC5, PRD-010 AC1-AC7, NFR-005 | UI or presentation tests verify layout, card sizing, and token role expectations still hold after `New Deal`. |
| T050 | Ensure presentation state exposes no bidding, passing, trump, play-card, trick, scoring, or game-over actions. | PRD-006 AC9, PRD-007 AC3, PRD-008 AC2, PRD-008 AC3 | Tests or code review verify only deal and new-deal MVP actions exist. |

## 5. Initial Screen UI and Token Usage

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T051 | Verify the initial screen shows app title `Tarneeb`. | PRD-001 AC1 | UI test finds the title on launch. |
| T052 | Verify the initial screen shows a primary `Deal Cards` action. | PRD-001 AC2 | UI test finds and taps `Deal Cards`. |
| T053 | Render initial player stations in a diamond relationship before the first deal. | PRD-002 AC1, PRD-002 AC2, PRD-010 AC1, PRD-010 AC2 | UI test finds North, West, South, and East station identifiers on launch. |
| T054 | Apply token-backed table, label, station, and `Deal Cards` styling on the initial screen. | PRD-001 AC1, PRD-001 AC2, PRD-010 AC6, NFR-005 | UI inspection, snapshot, or manual QA confirms initial styling resolves through section 4.4 tokens. |
| T055 | Verify no visible card faces or hidden backs appear before `Deal Cards`. | PRD-001 AC3 | UI test confirms card elements are absent before the first deal. |
| T056 | Verify initial screen labels and action remain usable on the chosen small-screen simulator. | PRD-010 AC7, NFR-005 | Small-screen UI test or manual QA confirms launch UI usability. |

## 6. Dealt Table Layout UI

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T057 | Build or verify a diamond table layout container. | PRD-010 AC1 | UI test or visual QA confirms the table is not rendered as a simple row/column list. |
| T058 | Position North at top, West at left, South at bottom, and East at right. | PRD-010 AC2 | UI test with frames, screenshot review, or manual QA confirms each station position. |
| T059 | Verify South and North appear opposite each other. | PRD-010 AC3 | Layout test or manual QA confirms partner opposition. |
| T060 | Verify East and West appear opposite each other. | PRD-010 AC4 | Layout test or manual QA confirms partner opposition. |
| T061 | Keep North, West, and East stations compact relative to South when screen space allows. | PRD-007 AC5, PRD-010 AC5 | Frame-based test, snapshot, or manual QA confirms simulated stations are smaller than South on a primary simulator. |
| T062 | Ensure labels, cards, message text, and action buttons do not incoherently overlap. | PRD-006 AC8, PRD-010 AC6, NFR-005 | UI test or manual QA confirms all required elements remain readable and usable. |
| T063 | Verify dealt table layout remains usable on the chosen small-screen simulator. | PRD-010 AC7, NFR-005 | Small-screen UI test confirms all four stations, completion message, and action button are usable. |
| T064 | Apply token-backed table, label, station, card, and action styling on the dealt table. | PRD-006 AC3, PRD-006 AC4, PRD-008 AC1, PRD-008 AC4, NFR-005 | UI inspection, snapshot, or manual QA confirms dealt styling resolves through section 4.4 tokens. |

## 7. Exposed South Card UI

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T065 | Render exactly 13 South cards after a completed deal. | PRD-006 AC1, PRD-005 AC1 | UI test verifies 13 visible South card elements. |
| T066 | Render rank and suit symbol on every exposed South card. | PRD-006 AC2 | UI test or presentation test verifies each visible card exposes rank and suit. |
| T067 | Render Hearts and Diamonds rank/suit text using `suitWarm` resolved to `color.card.suit.red`. | PRD-006 AC3, NFR-005 | Unit role tests plus visual/UI verification confirm Hearts and Diamonds use the required token-backed role. |
| T068 | Render Clubs and Spades rank/suit text using `suitNeutral` resolved to `color.card.suit.black`. | PRD-006 AC4, NFR-005 | Unit role tests plus visual/UI verification confirm Clubs and Spades use the required token-backed role. |
| T069 | Verify exposed card surfaces use `color.card.background`, `color.card.border`, and `color.card.shadow`. | PRD-006 AC7, NFR-005 | UI inspection, snapshot, or manual QA confirms face-up card styling uses the card surface tokens. |
| T070 | Verify the displayed South hand is sorted by suit then rank. | PRD-006 AC5, PRD-006 AC6 | Unit or UI test verifies visible ordering. |
| T071 | Render exposed South cards using the shared standard-card base size and aspect ratio. | PRD-006 AC7 | UI test, snapshot, or manual QA confirms readable standard-card proportions. |
| T072 | Ensure exposed South cards fit within the South station without overlapping unrelated UI. | PRD-006 AC8, PRD-010 AC6 | UI test or manual QA confirms South hand does not cover labels, message, or actions. |
| T073 | Ensure South cards are not selectable, playable, discardable, or otherwise actionable. | PRD-006 AC9 | Interaction test taps South cards and verifies no gameplay state change or play controls appear. |

## 8. Hidden Simulated Card UI

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T074 | Verify `card_back.png` is available through the app asset catalog under the expected asset name. | PRD-007 AC1 | Asset or UI test confirms hidden card backs can render. |
| T075 | Render West, North, and East with 13 hidden card backs each after a completed deal. | PRD-007 AC1 | UI test verifies each simulated station represents 13 hidden backs. |
| T076 | Ensure simulated stations do not reveal rank, suit, or card identity values. | PRD-007 AC2 | UI test verifies simulated areas expose no rank/suit labels and hidden presentation exposes no card IDs. |
| T077 | Ensure simulated stations expose no action controls. | PRD-007 AC3 | UI test confirms no simulated play, pass, bid, or other action controls exist. |
| T078 | Render hidden backs at the same base size and aspect ratio as exposed South cards. | PRD-007 AC4, PRD-006 AC7 | UI/snapshot/manual QA or presentation test confirms shared sizing. |
| T079 | Render hidden backs in compact station-sized stacks or arrays. | PRD-007 AC5, PRD-010 AC5 | UI/snapshot/manual QA confirms hidden hands fit compact North/West/East stations. |
| T080 | Verify any spread stack still represents 13 hidden cards without revealing card data. | PRD-007 AC6 | UI test or accessibility metadata verifies hidden count and no rank/suit exposure. |

## 9. Completion, New Deal, and Scope Guards

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T081 | Display a completion message such as `Deal complete` after all cards are dealt. | PRD-008 AC1 | UI test finds the completion message after dealing. |
| T082 | Verify no bidding UI appears after a completed deal. | PRD-008 AC2 | UI test confirms bid controls are absent. |
| T083 | Verify no gameplay controls appear after a completed deal. | PRD-008 AC3 | UI test confirms pass, trump/Tarneeb selector, play-card, trick, score, and game-over controls are absent. |
| T084 | Display a `New Deal` action after a completed deal. | PRD-008 AC4 | UI test finds and taps `New Deal`. |
| T085 | Style `New Deal` through `color.button.newGame.background`, `color.button.newGame.background.pressed`, and `color.button.newGame.text`. | PRD-008 AC4, PRD-009 AC5, NFR-005 | UI inspection, snapshot, or manual QA confirms `New Deal` uses the existing `newGame` tokens. |
| T086 | Verify `New Deal` clears previous hands before showing the replacement deal. | PRD-009 AC1 | Unit or UI test confirms previous hand data is not current after `New Deal`. |
| T087 | Verify `New Deal` starts from a fresh or fully reset 52-card deck. | PRD-009 AC2 | Unit test confirms the new-deal path uses a complete valid deck. |
| T088 | Verify `New Deal` shuffles before assigning replacement cards. | PRD-009 AC3, PRD-004 AC1 | Spy shuffler test confirms shuffle invocation in the new-deal path. |
| T089 | Verify `New Deal` completes with 13 cards for each player. | PRD-009 AC4 | Unit or UI test confirms each player again has 13 cards. |
| T090 | Verify `New Deal` preserves the diamond table layout, shared card sizing, and token-backed styling. | PRD-009 AC5, PRD-010 AC1-AC7, NFR-005 | UI test or manual QA confirms the second deal still satisfies layout, sizing, and token requirements. |
| T091 | Verify no out-of-scope gameplay, persistence, accounts, multiplayer, advanced AI, sound, or custom card art is introduced. | PRD-008 AC2, PRD-008 AC3 | Code review and UI tests confirm the app remains deal-only. |

## 10. Responsiveness and Visual Verification

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T092 | Verify dealing completes quickly enough to feel immediate. | PRD-005 AC1, NFR-002 | UI test timing or manual QA confirms no noticeable blocking during deal. |
| T093 | Verify UI remains responsive after dealing and after `New Deal`. | PRD-008 AC4, PRD-009 AC1, NFR-002 | UI test continues interacting after deal and after new deal without long waits. |
| T094 | Verify visual layout, card sizing, and token resolution do not introduce noticeable blocking. | PRD-006 AC7, PRD-007 AC4, PRD-010 AC6, NFR-002 | Manual QA or UI timing confirms layout and token-backed styling render promptly. |
| T095 | Perform manual visual QA for token-backed suit styling. | PRD-006 AC3, PRD-006 AC4, NFR-005 | Manual QA confirms `suitWarm` and `suitNeutral` are visually distinct and match the token spec. |
| T096 | Perform manual visual QA for table, card surface, text, station, and action token usage. | PRD-001 AC1, PRD-001 AC2, PRD-006 AC7, PRD-008 AC1, PRD-008 AC4, PRD-010 AC6, NFR-005 | Manual QA confirms every colored UI element uses the token mapping in `design.md` section 4.4. |
| T097 | Perform manual visual QA for diamond placement. | PRD-010 AC1-AC4 | Manual QA confirms North top, West left, South bottom, East right, with partners opposite. |
| T098 | Perform manual visual QA for compact simulated stations. | PRD-007 AC5, PRD-010 AC5 | Manual QA confirms North/West/East stations are compact compared with South where screen space allows. |
| T099 | Perform manual visual QA for hidden and exposed card size parity. | PRD-006 AC7, PRD-007 AC4, NFR-005 | Manual QA confirms hidden backs and exposed cards share readable standard-card base size. |
| T100 | Perform manual visual QA for small-screen usability. | PRD-006 AC8, PRD-010 AC6, PRD-010 AC7, NFR-005 | Manual QA confirms labels, cards, hidden backs, completion message, and actions remain usable on the chosen small-screen simulator. |

## 11. Final Test Runs and Acceptance

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T101 | Run the full domain unit test suite. | PRD-002 AC1-AC6, PRD-003 AC1-AC5, PRD-004 AC1-AC3, PRD-005 AC1-AC5, PRD-006 AC3-AC6, PRD-007 AC2, PRD-009 AC1-AC4, NFR-003, NFR-004 | All domain and presentation-mapping unit tests pass. |
| T102 | Run token boundary and token role tests. | PRD-006 AC3, PRD-006 AC4, PRD-008 AC4, NFR-003, NFR-005 | Tests pass for token availability, `suitWarm`, `suitNeutral`, `New Deal` token usage, and no concrete color values outside the token source. |
| T103 | Run the full UI test suite on the primary simulator. | PRD-001 AC1-AC3, PRD-006 AC1-AC9, PRD-007 AC1-AC6, PRD-008 AC1-AC4, PRD-009 AC1-AC5, PRD-010 AC1-AC6 | All launch, deal, card display, hidden-hand, prohibited-control, and new-deal UI tests pass. |
| T104 | Run layout-focused UI tests on the chosen small-screen simulator. | PRD-010 AC7, NFR-005 | Small-screen test run passes for required labels, cards, hidden backs, message, and action button. |
| T105 | Perform final manual acceptance against the MVP 002 Definition of Done and token usage checklist. | PRD-001 through PRD-010, NFR-002, NFR-005 | Manual checklist confirms launch, deal, hidden simulated hands, completion state, `New Deal`, diamond layout, token-backed suit styling, shared card sizing, compact simulated stations, and no out-of-scope gameplay. |

## 12. Suggested Implementation Order

1. Complete project, test, and token source setup tasks T001 through T009.
2. Verify or complete baseline domain and deal correctness tasks T010 through T028.
3. Implement presentation mapping and token role tasks T029 through T044.
4. Update presentation state tasks T045 through T050.
5. Update initial screen UI and token usage tasks T051 through T056.
6. Update dealt table layout UI tasks T057 through T064.
7. Update exposed South card UI tasks T065 through T073.
8. Update hidden simulated card UI tasks T074 through T080.
9. Complete completion, new-deal, and scope guard tasks T081 through T091.
10. Complete responsiveness and visual verification tasks T092 through T100.
11. Complete final test runs and acceptance tasks T101 through T105.

## 13. Ambiguities to Keep Flagged During Implementation

- Exact card dimensions in points are unspecified; choose responsive values that preserve an approximately 5:7 ratio and verify readability.
- The smallest supported simulator is unspecified; use the smallest simulator supported by the project unless product names a stricter target.
- `design-tokens.md` names the secondary action tokens `newGame`, while the MVP action label is `New Deal`; use the existing tokens unless product/design renames or aliases them.
- Appearance-specific token variants are not defined; do not invent alternate appearance-mode color values without updating `design-tokens.md` first.
- Exact hidden stack spread distance is unspecified; choose a compact spread that still represents 13 hidden cards.
- Automated rendered-token and geometry verification may require accessibility metadata, view inspection, snapshots, or manual QA because XCTest may not directly inspect rendered colors and positions robustly.
