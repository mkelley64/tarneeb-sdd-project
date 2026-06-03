# Tarneeb iOS MVP 004 Implementation Tasks

This task list is derived from `requirements.md`, `design.md`, and the token
source referenced by the design, `design-tokens.md`. It is an implementation
plan only; no code is included here.

Acceptance criteria are referenced as `PRD-### AC#`, where `AC#` is the
acceptance criterion order within that product requirement. Non-functional
requirements are referenced as `NFR-###`.

All color, typography, title-shadow, dealer-badge, and undealt-deck stack/placement
implementation work must use `specs/004-mvp/design-tokens.md` as the source of
truth. Do not introduce concrete color, font, tracking, shadow, undealt-deck
anchor, offset, stack-rotation, stack-offset, or edge-buffer values outside the token
source. If implementation needs a value that is not already represented, update
the token spec before adding or consuming that value.

## 1. Project, Test, and Token Source Setup

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T001 | Confirm the iOS SwiftUI app target still launches the Tarneeb app. | PRD-001 AC1, PRD-001 AC2, PRD-001 AC4, NFR-001 | The app target builds and launches to a SwiftUI root screen in portrait. |
| T002 | Confirm the unit test target can test domain logic, dealer logic, presentation mapping, token roles, card sizing, deck stack state, title presentation, dealer badge state, action labels, and reset state without loading SwiftUI views. | PRD-003 AC1-AC5, PRD-004 AC1-AC3, PRD-005 AC1-AC8, PRD-009 AC1-AC7, PRD-014 AC1-AC14, NFR-003, NFR-004 | Unit tests can run for deck, deal, sort, dealer selection, dealer rotation, token role, card sizing, tokenized deck stack stack/placement, table title, dealer badge, action-label, and reset logic. |
| T003 | Confirm the UI test target can launch the app and query stable labels or identifiers. | PRD-001 AC1-AC7, PRD-010 AC1-AC9, PRD-011 AC1-AC9, PRD-012 AC1-AC8, PRD-014 AC3-AC9, NFR-003 | UI tests can find the table, title element, bottom controls, player stations, dealer badge, very-centered squared undealt deck stack, South cards, hidden hands, and completion message without requiring the pre-deal title to be unobscured. |
| T004 | Add or verify stable accessibility identifiers for the circular card table, table title, undealt deck stack, dealer badge, each player station, South hand, simulated hidden hands, completion label, bottom `New Game` button, and bottom `Deal` button. | PRD-010 AC1-AC9, PRD-011 AC1-AC9, PRD-012 AC1-AC8, PRD-014 AC3-AC9, NFR-003 | UI tests can target all layout-critical MVP 004 elements without brittle text-only queries. |
| T005 | Add or verify stable test hooks for suit presentation roles, token keys, title typography tokens, title shadow tokens, dealer badge tokens, dealer seat, deck stack count, undealt-deck stack/placement tokens, card size categories, and layout metrics. | PRD-006 AC4-AC8, PRD-007 AC4-AC6, PRD-010 AC1-AC9, PRD-014 AC1-AC9, NFR-003, NFR-005 | Tests can inspect semantic roles and metadata without relying only on screenshots. |
| T006 | Identify the smallest supported simulator to use for MVP 004 layout verification. | PRD-011 AC9, NFR-005 | The chosen simulator is documented in test output or manual QA notes; if product does not specify one, use the smallest simulator supported by the project. |
| T007 | Define implementation tolerances for UI geometry checks that need them. | PRD-010 AC2, PRD-010 AC4-AC7, PRD-011 AC1-AC4, PRD-014 AC3-AC7, NFR-003 | Geometry-based UI tests have explicit tolerances for table diameter, station positions, very-centered deck placement, allowed title overlap, dealer badge placement, deck stack bounds, edge buffer, and bottom controls. |
| T008 | Add or verify a single design-token implementation source that covers every token named in `design.md` section 2.5. | PRD-006 AC4-AC5, PRD-010 AC3-AC7, PRD-012 AC1-AC8, PRD-014 AC5-AC9, NFR-005 | A token test or inspection proves all required token keys are available from one token source, including `layout.undealtDeck.*` tokens. |
| T009 | Verify `color.dealerBadge.background` resolves to the same visual value as the `Deal` button background token and `color.dealerBadge.text` resolves to the required white text token. | PRD-014 AC7, NFR-005 | Token tests prove the dealer badge tokens match `color.button.deal.background` and white text without hardcoded UI colors. |
| T010 | Add a guard that concrete color, font, tracking, title-shadow, dealer-badge, or undealt-deck stack/placement values are not introduced outside the token source. | PRD-006 AC4-AC5, PRD-010 AC3-AC7, PRD-014 AC5-AC7, NFR-003, NFR-005 | A unit test, static check, or documented review check fails if UI/presentation code defines raw visual or undealt-deck layout/stack values outside the token source. |
| T011 | Verify `card_back.png` is available through the app asset catalog under the expected asset name. | PRD-007 AC1, PRD-010 AC8, PRD-014 AC3 | Asset or UI test confirms hidden card backs can render for simulated hands and the undealt deck stack. |

## 2. Baseline Domain, Dealer, and Deal Correctness

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T012 | Verify the app model includes only spades, clubs, hearts, and diamonds. | PRD-003 AC2 | Unit tests enumerate exactly four allowed suits. |
| T013 | Verify the app model includes only ranks 2 through Ace. | PRD-003 AC3 | Unit tests enumerate exactly thirteen allowed ranks. |
| T014 | Verify card identity is stable and derived from suit and rank. | PRD-003 AC5 | Unit tests prove duplicate suit-rank pairs cannot appear as unique identities. |
| T015 | Verify canonical deck creation returns one 52-card deck. | PRD-003 AC1 | `testDeckContains52Cards` passes. |
| T016 | Verify the canonical deck contains no jokers or unsupported card values. | PRD-003 AC2, PRD-003 AC3, PRD-003 AC4 | `testDeckContainsNoJokers` and allowed-value tests pass. |
| T017 | Verify every canonical deck card is unique. | PRD-003 AC5, NFR-004 | `testDeckContainsUniqueCards` passes. |
| T018 | Verify the model contains exactly four seats: South, West, North, and East. | PRD-002 AC1, PRD-002 AC2 | Unit tests enumerate exactly four seat values and labels. |
| T019 | Verify South is the only human player. | PRD-002 AC3, PRD-002 AC4 | Player setup tests pass for human and simulated assignments. |
| T020 | Verify South/North and East/West team assignments. | PRD-002 AC5, PRD-002 AC6 | Team assignment tests pass. |
| T021 | Verify game state includes only `notStarted` and `dealt` MVP phases. | PRD-005 AC5, PRD-013 AC1 | Unit tests or compiler-enforced model review confirm no extra gameplay phases are introduced. |
| T022 | Add or verify `dealerSeat` on game state. | PRD-001 AC6, PRD-014 AC1 | Unit tests prove game state stores exactly one dealer seat. |
| T023 | Verify dealer seats are limited to South, East, North, and West. | PRD-001 AC6, PRD-014 AC1 | Unit tests reject missing, duplicate, or invalid dealer values. |
| T024 | Add or verify an injectable random dealer selector for new games. | PRD-001 AC7, PRD-014 AC2, NFR-003 | Unit tests can force each dealer seat without relying on real randomness. |
| T025 | Verify new-game dealer selection produces exactly one dealer. | PRD-001 AC6, PRD-014 AC1 | Unit tests pass for exactly one selected dealer in `notStarted`. |
| T026 | Verify production new-game dealer selection does not hard-code one seat. | PRD-001 AC7, PRD-014 AC2 | Unit or code-review test proves production uses the random selector abstraction. |
| T027 | Verify dealer rotation from South to East. | PRD-009 AC2, PRD-014 AC10, PRD-014 AC11 | Rotation unit test passes for South -> East. |
| T028 | Verify dealer rotation from East to North. | PRD-009 AC2, PRD-014 AC10, PRD-014 AC12 | Rotation unit test passes for East -> North. |
| T029 | Verify dealer rotation from North to West. | PRD-009 AC2, PRD-014 AC10, PRD-014 AC13 | Rotation unit test passes for North -> West. |
| T030 | Verify dealer rotation from West to South. | PRD-009 AC2, PRD-014 AC10, PRD-014 AC14 | Rotation unit test passes for West -> South. |
| T031 | Verify initial app state contains four empty player seats and a selected dealer. | PRD-001 AC3, PRD-001 AC6, PRD-002 AC1, PRD-002 AC2, PRD-014 AC1 | Initial-state tests pass with four seats, zero dealt cards, and one dealer before `Deal`. |
| T032 | Verify production deal flow shuffles before assigning cards. | PRD-004 AC1, PRD-009 AC4 | A test shuffler or spy proves shuffle is invoked before assignment. |
| T033 | Verify shuffle preserves card count and uniqueness. | PRD-004 AC3, NFR-004 | Shuffle preservation tests pass with 52 unique cards after shuffle. |
| T034 | Verify separate deals do not intentionally preserve the same card order. | PRD-004 AC2 | A test or code review check confirms production replacement deals pass through the shuffler rather than reusing prior order. |
| T035 | Verify the deal service assigns four 13-card chunks in carried-forward South, East, North, West model order. | PRD-005 AC1, PRD-005 AC2 | Deterministic-shuffle unit test verifies chunk ownership by seat. |
| T036 | Verify dealer selection and rotation do not alter card assignment order for MVP 004. | PRD-005 AC1-AC4, PRD-014 AC1-AC2, PRD-014 AC10 | Unit tests prove dealer state and chunk assignment are independent until a future requirement says otherwise. |
| T037 | Verify each completed deal assigns exactly 13 cards to each player. | PRD-005 AC1 | Deal tests pass for all four hand counts. |
| T038 | Verify every completed deal assigns all 52 cards. | PRD-005 AC2, PRD-005 AC4 | Deal tests pass for 52 total dealt cards and zero undealt cards. |
| T039 | Verify no completed deal contains duplicate assigned cards. | PRD-005 AC3, NFR-004 | Duplicate-card validation tests pass. |
| T040 | Verify completed deals record game phase as `Dealt`. | PRD-005 AC5 | Phase tests pass after a valid deal. |
| T041 | Verify invalid internal deal states cannot be exposed as valid completed deals. | PRD-005 AC1-AC5, NFR-004 | Tests cover missing cards, duplicate cards, incorrect hand counts, and undealt cards without adding user-facing error UI. |
| T042 | Verify replacement deals clear or replace the previous hands before rendering the new completed deal. | PRD-009 AC1 | Unit or UI tests confirm previous hand data is not current after the replacement `Deal` action. |
| T043 | Verify replacement deals rotate dealer before the replacement deal is completed. | PRD-009 AC2, PRD-014 AC10-AC14 | Unit tests prove accepted replacement deals advance `dealerSeat` once. |
| T044 | Verify replacement deals start from a fresh or fully reset 52-card deck. | PRD-009 AC3 | Unit tests confirm the replacement path uses a complete valid deck. |
| T045 | Verify replacement deals shuffle before assigning replacement cards. | PRD-009 AC4, PRD-004 AC1 | Spy shuffler test confirms shuffle invocation in the replacement-deal path. |
| T046 | Verify replacement deals complete with 13 cards for each player. | PRD-009 AC5 | Unit or UI tests confirm each player again has 13 cards after replacement `Deal`. |

## 3. Presentation Mapping and Token Roles

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T047 | Add or verify a presentation mapping for suit symbols. | PRD-006 AC3 | Unit tests map each suit to a visible symbol. |
| T048 | Add or verify a presentation mapping for rank labels. | PRD-006 AC3 | Unit tests map each rank to the required number or letter label. |
| T049 | Add a unit test that Hearts and Diamonds map to `suitWarm`. | PRD-006 AC4, NFR-005 | Suit presentation tests fail if Hearts or Diamonds do not use `suitWarm`. |
| T050 | Implement or verify the `suitWarm` presentation role resolves to `color.card.suit.red`. | PRD-006 AC4, NFR-005 | Token role tests pass for Hearts and Diamonds without exposing concrete color values from card presentation. |
| T051 | Add a unit test that Clubs and Spades map to `suitNeutral`. | PRD-006 AC5, NFR-005 | Suit presentation tests fail if Clubs or Spades do not use `suitNeutral`. |
| T052 | Implement or verify the `suitNeutral` presentation role resolves to `color.card.suit.black`. | PRD-006 AC5, NFR-005 | Token role tests pass for Clubs and Spades without exposing concrete color values from card presentation. |
| T053 | Add a unit test that card presentation exposes `suitColorRole` and `suitColorToken`. | PRD-006 AC4, PRD-006 AC5, NFR-003, NFR-005 | Card presentation tests fail if a card lacks either the semantic role or token key. |
| T054 | Verify card presentation never emits concrete color values. | PRD-006 AC4, PRD-006 AC5, NFR-003, NFR-005 | Presentation mapping tests prove cards expose roles and token keys only. |
| T055 | Add a unit test for South-hand suit sort order Hearts, Clubs, Diamonds, Spades. | PRD-006 AC6 | Sort test fails unless suit order matches the requirement. |
| T056 | Add a unit test for South-hand rank sort order 2 through Ace within each suit. | PRD-006 AC7 | Sort test fails unless rank order matches the requirement. |
| T057 | Implement or verify display-only South-hand sorting. | PRD-006 AC6, PRD-006 AC7 | Sort tests pass and card ownership is unchanged. |
| T058 | Add a unit test for exposed card presentation values: card identity, rank text, suit symbol, token role, token key, and accessibility label. | PRD-006 AC3-AC5, NFR-003 | Card presentation tests pass without SwiftUI view inspection. |
| T059 | Add or verify a presentation configuration for shared player-card base dimensions. | PRD-006 AC8, PRD-007 AC4, PRD-011 AC8 | Unit tests can compare one shared card size source for exposed cards and simulated hidden backs. |
| T060 | Verify the shared player-card size uses a standard-card aspect ratio. | PRD-006 AC8, PRD-007 AC4 | Unit test or presentation-config test verifies approximately 5:7 width-to-height behavior. |
| T061 | Add or verify hidden-hand presentation for simulated seats. | PRD-007 AC1, PRD-007 AC2, PRD-007 AC6 | Unit tests verify hidden count/back representation and no rank/suit/card identity exposure. |
| T062 | Add or verify hidden-stack offset configuration for compact simulated hands. | PRD-007 AC5, PRD-007 AC6 | Unit tests or snapshot/manual QA can confirm the stack is compact and still represents 13 hidden cards. |
| T063 | Add an undealt deck stack presentation model derived from `phase = notStarted` with very-centered table placement and stack metadata. | PRD-010 AC4, PRD-010 AC6, PRD-010 AC8, PRD-014 AC3, PRD-014 AC5 | Unit tests verify the initial stack represents 52 hidden cards, exposes no ranks or suits, is placed at the very center of the card table, and exposes token-backed stack metadata. |
| T064 | Verify undealt deck stack presentation is visible only before a completed deal. | PRD-005 AC6, PRD-010 AC9 | Unit tests verify stack visibility is true in `notStarted` and false in `dealt`. |
| T065 | Add deck stack layout metadata for the initial 52-card stack. | PRD-010 AC4-AC7, PRD-014 AC3-AC5 | Unit tests or UI metadata verify the stack uses `layout.undealtDeck.*` center, stack, and edge-buffer tokens, remains inside the table buffer, and may overlap the title. |
| T066 | Add a table title presentation model for text, font token, 26pt font-size token, tracking token range, text color/opacity tokens, shadow tokens, and accessibility identifier. | PRD-001 AC1, PRD-010 AC3 | Unit tests verify title presentation uses only `design-tokens.md` token keys and static text `طرنيب`. |
| T067 | Verify the table title presentation remains present and centered while allowing the undealt deck stack to obscure it before deal. | PRD-010 AC7 | Presentation or UI metadata confirms title center placement is independent from the deck stack, and tests do not require the title to be visually unobscured while the pre-deal deck is present. |
| T068 | Add layout metric presentation for table diameter. | PRD-010 AC2 | Unit or UI test metadata verifies table diameter is calculated as half the current screen width. |
| T069 | Add layout metric presentation for station placement around the table. | PRD-011 AC1-AC4 | Unit or UI test metadata verifies North, West, South, and East relative positions. |
| T070 | Add layout metric presentation for very-centered squared undealt deck placement and dealer badge placement. | PRD-010 AC4-AC7, PRD-014 AC3-AC7 | Unit tests verify the undealt stack center aligns with the table center, uses the tokenized squared-stack geometry, stays inside the table buffer, allows title overlap, and dealer badge placement is upper-left within the selected station. |
| T071 | Add presentation state for the visible action labels `New Game` and `Deal`. | PRD-001 AC2, PRD-001 AC5, PRD-008 AC5-AC6, PRD-009 AC7, PRD-012 AC4-AC8, PRD-013 AC8 | Unit tests verify visible and accessibility action labels emit `New Game` and `Deal`, never `Deal Cards` or `New Deal`. |
| T072 | Map visible `Deal` buttons to primary deal tokens and visible `New Game` buttons to secondary new-game tokens. | PRD-012 AC1-AC8, NFR-005 | Token tests verify `Deal` controls use `color.button.deal.*` and `New Game` controls use `color.button.newGame.*`. |
| T073 | Add dealer badge presentation roles. | PRD-014 AC6-AC9, NFR-005 | Unit tests verify the dealer maps to badge background/text tokens, all station outlines remain default, and the badge remains on the current dealer until the next deal request advances the dealer. |
| T074 | Verify dealer badge tokens resolve through `color.dealerBadge.background` and `color.dealerBadge.text`. | PRD-014 AC7, NFR-005 | Token role tests prove dealer badge presentation references the badge tokens only and that the background matches the `Deal` button token. |
| T075 | Verify dealer badge state is exposed for tests without adding gameplay instructions to visible UI. | PRD-014 AC1, PRD-014 AC6-AC9, NFR-003 | Presentation tests can identify the selected dealer, badge state, badge token keys, and default outline state through metadata or accessibility values. |

## 4. Presentation State and Action Flow

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T076 | Verify presentation state starts with `notStarted`, four empty seats, one selected dealer, visible very-centered squared undealt deck stack, visible dealer badge, present centered table title, visible `New Game` and `Deal` actions, and no dealt card presentations. | PRD-001 AC3, PRD-001 AC5-AC7, PRD-002 AC1, PRD-010 AC3-AC8, PRD-012 AC1, PRD-012 AC6, PRD-014 AC1-AC9 | Unit tests pass for initial presentation state without requiring the pre-deal title to be visually unobscured by the deck. |
| T077 | Connect the visible `Deal` action in `notStarted` to the first-deal path. | PRD-001 AC2, PRD-005 AC1-AC8 | Unit or UI tests verify tapping `Deal` transitions to a valid dealt display, hides the undealt stack, keeps station outlines default, and keeps the current dealer badge visible. |
| T078 | Prevent overlapping deal requests from repeated rapid `Deal` taps before the first deal completes. | PRD-005 AC1-AC8, NFR-002, NFR-004 | Repeated-tap tests end in one valid completed deal with no duplicate or partial hands, default station outlines, and one current dealer badge. |
| T079 | Connect the visible `Deal` action in `dealt` to the replacement-deal path. | PRD-008 AC5, PRD-009 AC1-AC7, PRD-014 AC10-AC14 | Unit or UI tests verify tapping `Deal` after completion rotates dealer and produces another valid completed deal. |
| T080 | Ensure replacement `Deal` keeps the undealt deck stack hidden after the completed replacement deal. | PRD-005 AC6, PRD-010 AC9 | Unit or UI tests verify the undealt stack remains absent after replacement deals. |
| T081 | Ensure replacement `Deal` keeps all station outlines default and shows exactly one current dealer badge after completion. | PRD-005 AC7-AC8, PRD-014 AC8-AC9 | Unit or UI tests verify no station outline is used for dealer indication and exactly one badge remains visible after replacement deal completion. |
| T082 | Ensure replacement `Deal` reapplies portrait table layout, rounded-square station behavior, shared card sizing, and token-backed suit presentation. | PRD-009 AC6, PRD-011 AC1-AC9, NFR-005 | UI or presentation tests verify layout, sizing, and token expectations still hold after replacement `Deal`. |
| T083 | Connect the visible `New Game` action in dealt state to the launch-state reset path. | PRD-008 AC6, PRD-012 AC6-AC8, PRD-013 AC1-AC7, PRD-014 AC1-AC9 | Unit or UI tests verify `New Game` clears dealt hands, hides `Deal complete`, selects a dealer, shows the dealer badge, restores the very-centered squared undealt stack, and returns to `notStarted`. |
| T084 | Connect the visible `New Game` action in initial state without starting a deal. | PRD-013 AC8 | Unit or UI tests verify tapping `New Game` from `notStarted` leaves phase `notStarted` and no hands are dealt. |
| T085 | Preserve the ambiguity around whether `New Game` in `notStarted` re-randomizes dealer. | PRD-013 AC8 | Tests assert only required behavior: no deal starts and state remains `notStarted`; they do not require re-randomization unless product clarifies it. |
| T086 | Ensure presentation state exposes no bidding, passing, trump, play-card, trick, scoring, game-over, persistence, account, multiplayer, AI, or sound actions. | PRD-006 AC10, PRD-007 AC3, PRD-008 AC3, PRD-008 AC4 | Tests or code review verify only MVP deal/reset actions exist. |

## 5. Portrait Orientation

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T087 | Implement portrait-only orientation support using the project-appropriate iOS mechanism. | PRD-001 AC4, NFR-001 | Build settings, app configuration, or runtime policy restricts the app to portrait. |
| T088 | Add a UI test or configuration verification that the app launches in portrait. | PRD-001 AC4, NFR-001 | Orientation test or inspection confirms portrait on launch. |
| T089 | Add a UI test or manual verification that device rotation does not switch the app to landscape. | PRD-001 AC4, NFR-001 | Rotation verification confirms the app remains portrait. |
| T090 | Verify no landscape-only layout branch or landscape-only UI is introduced. | PRD-001 AC4, NFR-001 | Code review or test coverage confirms MVP 004 remains portrait-only. |

## 6. Initial Table Scene UI

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T091 | Build or update the root screen into a main table scene plus bottom control area. | PRD-010 AC1, PRD-012 AC1, PRD-012 AC6 | UI test or snapshot verifies the table scene and bottom `New Game` plus `Deal` controls render on launch. |
| T092 | Render a circular card table in the center area of the initial screen. | PRD-010 AC1 | UI test, view metadata, screenshot, or manual QA confirms a circle is visible. |
| T093 | Size the circular card table to half the screen width. | PRD-010 AC2 | UI geometry test or accessibility metadata verifies the diameter within the defined tolerance. |
| T094 | Render `طرنيب` centered on the circular card table. | PRD-001 AC1, PRD-010 AC3 | UI test verifies the title is located within the card table rather than as a top page title. |
| T095 | Apply the table-title font and 26pt font-size tokens to the `طرنيب` title. | PRD-001 AC1, PRD-010 AC3 | Unit/view-inspection/snapshot/manual QA verifies the title uses `typography.tableTitle.font` and `typography.tableTitle.fontSize`. |
| T096 | Apply table-title tracking within the token range. | PRD-001 AC1, PRD-010 AC3 | Unit/view-inspection/snapshot/manual QA verifies tracking is within the token-defined range. |
| T097 | Apply the table-title text color and opacity tokens. | PRD-001 AC1, PRD-010 AC3, NFR-005 | Token test or UI inspection verifies the title uses `color.tableTitle.text` and `effect.tableTitle.text.opacity`. |
| T098 | Apply the table-title shadow tokens. | PRD-001 AC1, PRD-010 AC3, NFR-005 | Token test or manual QA verifies shadow values come from `effect.tableTitle.shadow.*`. |
| T099 | Render exactly one dealer badge on launch. | PRD-001 AC6, PRD-014 AC1, PRD-014 AC6 | UI test finds exactly one small circular `D` badge on the selected dealer station before deal. |
| T100 | Render the dealer badge using token-backed dealer badge colors and default station outlines. | PRD-014 AC7-AC8, NFR-005 | UI inspection, snapshot, or metadata verifies the badge uses `color.dealerBadge.background` and `color.dealerBadge.text`, and no station outline changes to blue for dealer indication. |
| T101 | Render a squared 52-card hidden undealt deck stack at the very center of the card table before the first deal. | PRD-010 AC4, PRD-010 AC6, PRD-014 AC3, PRD-014 AC5 | UI test or accessibility metadata verifies the stack is present, hidden-card-only, count 52, and center-aligned to the card table. |
| T102 | Ensure the undealt deck stack stays inside the circular table with an edge buffer. | PRD-010 AC5, PRD-014 AC4 | UI geometry test, metadata, or manual QA confirms the squared stack bounds are inside the table and not flush to the edge. |
| T103 | Ensure the undealt deck stack may obscure the `طرنيب` title before the deal. | PRD-010 AC7 | UI geometry check, metadata, screenshot, or manual QA confirms title/deck overlap is allowed while both remain centered on the table, and no test rejects the deck layering above the title. |
| T104 | Ensure the undealt deck stack uses tokenized squared-stack geometry. | PRD-010 AC6, PRD-014 AC5, NFR-005 | UI test or metadata verifies zero stack rotation and offset values come from `layout.undealtDeck.stack.*` tokens. |
| T105 | Ensure the undealt deck stack reveals no ranks, suits, or card identities. | PRD-010 AC8 | UI/accessibility tests verify no rank/suit/card identity values appear in the stack. |
| T106 | Render four player stations on launch. | PRD-002 AC1, PRD-002 AC2 | UI test finds exactly South, West, North, and East station identifiers. |
| T107 | Render all launch player stations as rounded squares. | PRD-002 AC7, PRD-011 AC5 | UI test, snapshot, or manual QA confirms rounded-square station appearance before deal. |
| T108 | Position launch player stations around the circular card table. | PRD-011 AC1, PRD-011 AC2 | UI geometry test, screenshot, or manual QA confirms North above, West left, South below, East right. |
| T109 | Verify South/North and East/West appear opposite each other around the table. | PRD-011 AC3, PRD-011 AC4 | Layout test or manual QA confirms partner opposition. |
| T110 | Render the initial bottom controls as `New Game` and `Deal` at the bottom of the screen. | PRD-001 AC2, PRD-001 AC5, PRD-012 AC1, PRD-012 AC6 | UI test finds `New Game` and `Deal` in the bottom control area on launch. |
| T111 | Verify no visible dealt player hands appear before the first `Deal`. | PRD-001 AC3 | UI test confirms South visible cards and simulated hidden hands are absent before the first deal. |
| T112 | Verify `Deal Cards` and `New Deal` labels are absent on launch while `New Game` remains present. | PRD-012 AC4, PRD-012 AC5, PRD-012 AC8 | UI test confirms old action labels are absent and the reset action is labeled `New Game`. |

## 7. Dealt Table Scene UI

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T113 | Tap `Deal` and render a valid dealt table screen. | PRD-005 AC1-AC8, PRD-008 AC1 | UI test verifies the app reaches the dealt state after tapping `Deal` with valid hands, hidden undealt stack, default outlines, and current dealer badge. |
| T114 | Hide the undealt 52-card deck stack after the deal completes. | PRD-005 AC6, PRD-010 AC9 | UI test verifies the initial undealt stack is absent after deal. |
| T115 | Keep default station outlines and the current dealer badge after deal. | PRD-005 AC7-AC8, PRD-014 AC8-AC9 | UI or presentation test verifies station outlines remain default in `dealt` and exactly one current dealer badge remains visible. |
| T116 | Keep the circular card table visible after deal. | PRD-010 AC1, PRD-011 AC1 | UI test or manual QA confirms the table remains in the dealt screen. |
| T117 | Keep player stations surrounding the card table after deal. | PRD-011 AC1, PRD-011 AC2 | UI geometry test, screenshot, or manual QA confirms the station relationship after deal. |
| T118 | Expand the South station below the card table after deal. | PRD-006 AC2, PRD-011 AC6 | UI geometry test or manual QA confirms South expands below the table to contain the human hand. |
| T119 | Render exactly 13 South cards after a completed deal. | PRD-006 AC1, PRD-005 AC1 | UI test verifies 13 visible South card elements. |
| T120 | Render rank and suit symbol on every exposed South card. | PRD-006 AC3 | UI test or presentation test verifies each visible card exposes rank and suit. |
| T121 | Render Hearts and Diamonds rank/suit text using `suitWarm` resolved to `color.card.suit.red`. | PRD-006 AC4, NFR-005 | Unit role tests plus visual/UI verification confirm Hearts and Diamonds use the required token-backed role. |
| T122 | Render Clubs and Spades rank/suit text using `suitNeutral` resolved to `color.card.suit.black`. | PRD-006 AC5, NFR-005 | Unit role tests plus visual/UI verification confirm Clubs and Spades use the required token-backed role. |
| T123 | Verify exposed card surfaces use `color.card.background`, `color.card.border`, and `color.card.shadow`. | PRD-006 AC8, NFR-005 | UI inspection, snapshot, or manual QA confirms face-up card styling uses card surface tokens. |
| T124 | Verify the displayed South hand is sorted by suit then rank. | PRD-006 AC6, PRD-006 AC7 | Unit or UI test verifies visible ordering. |
| T125 | Render exposed South cards using the shared standard-card base size and aspect ratio. | PRD-006 AC8 | UI test, snapshot, or manual QA confirms readable standard-card proportions. |
| T126 | Ensure exposed South cards fit within the expanded South station without overlapping unrelated UI. | PRD-006 AC9, PRD-011 AC8 | UI test or manual QA confirms South hand does not cover labels, completion message, or the bottom controls. |
| T127 | Ensure South cards are not selectable, playable, discardable, or otherwise actionable. | PRD-006 AC10 | Interaction test taps South cards and verifies no gameplay state change or play controls appear. |
| T128 | Render West, North, and East with 13 hidden card backs each after a completed deal. | PRD-007 AC1 | UI test verifies each simulated station represents 13 hidden backs. |
| T129 | Ensure simulated stations do not reveal rank, suit, or card identity values. | PRD-007 AC2 | UI test verifies simulated areas expose no rank/suit labels and hidden presentation exposes no card IDs. |
| T130 | Ensure simulated stations expose no action controls. | PRD-007 AC3 | UI test confirms no simulated play, pass, bid, or other action controls exist. |
| T131 | Render hidden backs at the same base size and aspect ratio as exposed South cards. | PRD-007 AC4, PRD-006 AC8 | UI/snapshot/manual QA or presentation test confirms shared player-card sizing. |
| T132 | Keep West, North, and East stations compact after deal when screen space allows. | PRD-007 AC5, PRD-011 AC7 | UI/snapshot/manual QA confirms simulated stations fit their labels and hidden arrays without large empty panels. |
| T133 | Verify any simulated spread stack still represents 13 hidden cards without revealing card data. | PRD-007 AC6 | UI test or accessibility metadata verifies hidden count and no rank/suit exposure. |
| T134 | Display `Deal complete` after all cards are dealt. | PRD-008 AC1 | UI test finds the completion message after dealing. |
| T135 | Position `Deal complete` above the bottom control row. | PRD-008 AC2, PRD-012 AC3 | UI geometry test or manual QA confirms the completion label is above `New Game` and `Deal`. |
| T136 | Keep the dealt-state bottom controls labeled `New Game` and `Deal` at the bottom of the screen. | PRD-012 AC2, PRD-012 AC7, PRD-009 AC7 | UI test verifies both bottom actions remain visible after a completed deal. |
| T137 | Verify `Deal Cards` and `New Deal` labels are absent after a completed deal while `New Game` remains present. | PRD-012 AC4, PRD-012 AC5, PRD-012 AC8 | UI test confirms old labels are absent after dealing and the reset action is labeled `New Game`. |
| T138 | Tap `Deal` after completion and render another valid completed deal. | PRD-008 AC5, PRD-009 AC1-AC7, PRD-014 AC10-AC14 | UI test verifies replacement deal behavior, valid hands, old labels absent, dealer rotation, current dealer badge update, and undealt stack still hidden. |

## 8. Layout, Small-Screen, and Responsiveness Verification

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T139 | Ensure labels, cards, message text, very-centered squared undealt deck stack, table title, player stations, dealer badge, and bottom controls do not incoherently overlap on the primary simulator, except for the allowed pre-deal deck/title overlap. | PRD-006 AC9, PRD-010 AC4-AC7, PRD-011 AC8, PRD-012 AC1-AC3, PRD-014 AC3-AC7, NFR-005 | UI test, snapshot, or manual QA confirms required elements remain readable and usable, while the title remains present and centered but may be obscured by the deck before deal. |
| T140 | Ensure the bottom controls remain usable when the South station expands after deal. | PRD-006 AC2, PRD-011 AC6, PRD-012 AC2, PRD-012 AC7 | UI test or manual QA confirms South expansion does not block `New Game` or `Deal`. |
| T141 | Verify launch layout remains usable on the chosen small-screen simulator. | PRD-010 AC4-AC7, PRD-011 AC9, PRD-014 AC3-AC7, NFR-005 | Small-screen UI test or manual QA confirms the table, title element, very-centered squared undealt stack, dealer badge, stations, and bottom controls are present before deal, while allowing the deck to obscure the centered title. |
| T142 | Verify dealt layout remains usable on the chosen small-screen simulator. | PRD-011 AC9, NFR-005 | Small-screen UI test confirms stations, South cards, hidden backs, completion message, and bottom controls are usable after deal. |
| T143 | Verify dealing completes quickly enough to feel immediate. | PRD-005 AC1, NFR-002 | UI test timing or manual QA confirms no noticeable blocking during deal. |
| T144 | Verify UI remains responsive after first deal, replacement deal, dealer rotation, and `New Game` reset. | PRD-008 AC5-AC6, PRD-009 AC1-AC2, PRD-013 AC1-AC8, PRD-014 AC7-AC13, NFR-002 | UI test continues interacting after first deal, replacement deal, rotation, and reset without long waits. |
| T145 | Verify visual layout, card sizing, token resolution, dealer badge rendering, and squared undealt deck stack rendering do not introduce noticeable blocking. | PRD-006 AC8, PRD-007 AC4, PRD-010 AC4-AC7, PRD-011 AC8, PRD-014 AC3-AC7, NFR-002 | Manual QA or UI timing confirms MVP 004 rendering remains responsive. |

## 9. Prohibited UI and Scope Guards

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T146 | Verify no bidding UI appears after a completed deal. | PRD-008 AC3 | UI test confirms bid controls are absent. |
| T147 | Verify no gameplay controls appear after a completed deal. | PRD-008 AC4 | UI test confirms pass, trump/Tarneeb selector, play-card, trick, score, and game-over controls are absent. |
| T148 | Verify no simulated player action controls appear. | PRD-007 AC3, PRD-008 AC4 | UI test confirms simulated stations expose no controls. |
| T149 | Verify dealer indication does not introduce bidding, trump, trick, scoring, multiplayer, or AI behavior. | PRD-008 AC3, PRD-008 AC4, PRD-014 AC1-AC14 | Code review and UI tests confirm dealer work remains table-state indication and rotation only. |
| T150 | Verify no out-of-scope persistence, accounts, multiplayer, advanced AI, sound, landscape UI, or custom card art is introduced. | PRD-008 AC3, PRD-008 AC4, NFR-001 | Code review and UI tests confirm the app remains a portrait deal-only MVP. |

## 10. Manual Visual QA

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T151 | Perform manual visual QA for portrait orientation and rotation behavior. | PRD-001 AC4, NFR-001 | Manual QA confirms the screen remains portrait when the device rotates. |
| T152 | Perform manual visual QA for circular table placement and approximate half-screen-width sizing. | PRD-010 AC1, PRD-010 AC2 | Manual QA confirms the table is circular, centered in the intended table area, and appears about half the screen width. |
| T153 | Perform manual visual QA for the table title treatment. | PRD-001 AC1, PRD-010 AC3, PRD-010 AC7, NFR-005 | Manual QA confirms the title is centered on the table, not a top title, uses token-backed title styling, and may be partially or fully obscured by the squared stack before deal. |
| T154 | Perform manual visual QA for random dealer indication before deal. | PRD-001 AC6-AC7, PRD-014 AC1-AC7, NFR-005 | Manual QA confirms exactly one station has the circular `D` dealer badge and the badge color matches the `Deal` button. |
| T155 | Perform manual visual QA for the initial undealt 52-card deck stack. | PRD-010 AC4-AC9, PRD-014 AC3-AC5 | Manual QA confirms the stack is squared, very centered in the table, hidden-card-only, inside the table buffer, may obscure the title, and disappears after deal. |
| T156 | Perform manual visual QA for dealer badge persistence and default station outlines after deal. | PRD-005 AC7-AC8, PRD-014 AC8-AC9 | Manual QA confirms station outlines remain default and the current dealer badge remains visible after deal. |
| T157 | Perform manual visual QA for rounded-square player stations surrounding the table. | PRD-002 AC7, PRD-011 AC1-AC5 | Manual QA confirms North top, West left, South bottom, East right, with partners opposite. |
| T158 | Perform manual visual QA for South station expansion. | PRD-006 AC2, PRD-011 AC6 | Manual QA confirms South expands below the table after deal and exposed cards remain readable. |
| T159 | Perform manual visual QA for compact simulated stations. | PRD-007 AC5, PRD-011 AC7 | Manual QA confirms North/West/East stations are compact compared with expanded South where screen space allows. |
| T160 | Perform manual visual QA for token-backed suit styling. | PRD-006 AC4, PRD-006 AC5, NFR-005 | Manual QA confirms `suitWarm` and `suitNeutral` are visually distinct and match the token spec. |
| T161 | Perform manual visual QA for hidden and exposed player-card size parity. | PRD-006 AC8, PRD-007 AC4, NFR-005 | Manual QA confirms hidden backs and exposed cards share readable standard-card base size. |
| T162 | Perform manual visual QA for bottom control placement. | PRD-008 AC2, PRD-012 AC1-AC8 | Manual QA confirms `Deal complete` appears above the bottom control row and `New Game` plus `Deal` remain reachable. |
| T163 | Perform manual visual QA for replacement dealer rotation. | PRD-009 AC2, PRD-014 AC10-AC14 | Manual QA or test metadata confirms replacement deals rotate dealer counterclockwise within the same game and the badge moves to the rotated dealer. |
| T164 | Perform manual visual QA for small-screen usability. | PRD-011 AC8, PRD-011 AC9, NFR-005 | Manual QA confirms all required labels, cards, hidden backs, very-centered squared deck stack, dealer badge, completion message, and bottom controls remain usable on the chosen small-screen simulator. |

## 11. Final Test Runs and Acceptance

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T165 | Run the full domain unit test suite. | PRD-002 AC1-AC6, PRD-003 AC1-AC5, PRD-004 AC1-AC3, PRD-005 AC1-AC5, PRD-009 AC1-AC5, PRD-014 AC1-AC14, NFR-003, NFR-004 | All domain unit tests pass. |
| T166 | Run presentation-mapping unit tests. | PRD-006 AC3-AC8, PRD-007 AC1-AC6, PRD-010 AC3-AC9, PRD-012 AC4-AC8, PRD-013 AC1-AC8, PRD-014 AC1-AC9, NFR-003, NFR-005 | Tests pass for token usage, action labels, dealer badge state, reset state, card size, title presentation, hidden hands, and very-centered squared undealt deck stack state. |
| T167 | Run orientation and primary UI tests on the primary simulator. | PRD-001 AC1-AC7, PRD-005 AC6-AC8, PRD-006 AC1-AC10, PRD-007 AC1-AC6, PRD-008 AC1-AC6, PRD-010 AC1-AC9, PRD-011 AC1-AC8, PRD-012 AC1-AC8, PRD-013 AC1-AC8, PRD-014 AC1-AC14 | All launch, portrait, table, dealer badge, deal, card display, hidden-hand, completion, reset, prohibited-control, and replacement-deal UI tests pass. |
| T168 | Run layout-focused UI tests on the chosen small-screen simulator. | PRD-010 AC4-AC7, PRD-011 AC9, PRD-014 AC3-AC7, NFR-005 | Small-screen test run passes for required stations, table, title, very-centered squared deck stack, dealer badge, cards, hidden backs, message, and bottom controls. |
| T169 | Perform final manual acceptance against the MVP 004 Definition of Done and token usage checklist. | PRD-001 through PRD-014, NFR-001 through NFR-005 | Manual checklist confirms portrait launch, bottom `New Game` plus `Deal`, central table, token-backed title, random dealer, very-centered squared deck stack, dealer badge persistence, default station outlines, rounded-square stations, valid deal, hidden simulated hands, South expansion, completion placement, replacement rotation, reset behavior, card readability, and no out-of-scope gameplay. |

## 12. Deal Animation Requirement Update Tasks

| ID | Task | Supports | Testable Outcome |
| --- | --- | --- | --- |
| T170 | Add tokenized deal-animation timing values. | PRD-015 AC1-AC9, NFR-005 | Unit test verifies `animation.deal.*` token keys exist and expose positive durations. |
| T171 | Add a deal-animation presentation model for dealer-relative target order. | PRD-015 AC1, PRD-015 AC3-AC7 | Unit test verifies target order starts at the dealer's right and continues counterclockwise for all dealer seats. |
| T172 | Add a 13-card moving stack presentation model. | PRD-005 AC2-AC5, PRD-015 AC1-AC3 | Unit test verifies the moving stack represents 13 hidden `card_back` cards and exposes no rank or suit data. |
| T173 | Keep completed deal validation atomic while staging the result for animation. | PRD-005 AC1, PRD-005 AC6-AC12, PRD-015 AC8 | Existing and new unit tests verify the final state remains a valid completed deal with no partial domain phase. |
| T174 | Render a transient 13-card hidden stack moving from the center deck to the active target station, with accessibility metadata for the stack and target sequence. | PRD-015 AC1, PRD-015 AC3 | Unit and UI coverage verifies the animation model exposes center-deck origin, player-station destination, 13 hidden cards, table-scene overlay rendering, and counterclockwise target order; manual QA or accessibility inspection can observe the transient `tarneeb-deal-animation-stack` without making tests depend on catching a short-lived frame. |
| T175 | Reveal each station's final 13-card presentation only after its animated stack arrives. | PRD-005 AC4, PRD-006 AC1-AC2, PRD-007 AC1, PRD-015 AC2 | Unit/UI metadata and manual QA confirm station hand content appears as part of the arrival/reveal sequence and final display remains correct. |
| T176 | Remove the center deck stack after the fourth 13-card stack arrives. | PRD-005 AC6, PRD-015 AC8 | UI test verifies no undealt deck stack or animation stack remains after `Deal complete`, and the final display has 13 South cards plus 39 simulated hidden cards. |
| T177 | Prevent overlapping `Deal` and `New Game` actions during the deal animation. | PRD-015 AC9, NFR-002 | UI test, accessibility metadata, or code test verifies actions are ignored or disabled while animation is running, then restored after completion. |
| T178 | Apply the same deal animation to replacement deals after counterclockwise dealer rotation. | PRD-009 AC1-AC5, PRD-014 AC10-AC14, PRD-015 AC1-AC8 | UI test verifies a replacement deal still rotates dealer, exposes completed animation metadata, and ends in another valid completed deal. |
| T179 | Add stable UI accessibility hooks for animation state, completed-animation metadata, target order, moving stack count, and hidden-card-only metadata. | PRD-015 AC1-AC9, NFR-003 | UI tests assert durable metadata such as `lastDealAnimation=completed`, `start=dealerRight`, `direction=counterclockwise`, `cardsPerStack=13`, and target order without relying on fragile screenshots or timing-only observation. |
| T180 | Perform manual visual QA for the deal animation. | PRD-015 AC1-AC9 | Manual QA confirms the stack starts at center, visits stations in dealer-relative counterclockwise order, stations reveal after arrival, and the center stack disappears after all 52 cards are dealt. |
| T181 | Run final unit and UI acceptance after deal-animation changes. | PRD-001 through PRD-015, NFR-001 through NFR-005 | Full unit and UI suites pass on the primary simulator, with small-screen UI verification when practical. |

## 13. Suggested Implementation Order

1. Complete project, test, and token source setup tasks T001 through T011.
2. Verify or complete baseline domain, dealer, and deal correctness tasks T012 through T046.
3. Implement presentation mapping and token role tasks T047 through T075.
4. Update presentation state and action flow tasks T076 through T086.
5. Implement portrait orientation tasks T087 through T090.
6. Update initial table scene UI tasks T091 through T112.
7. Update dealt table scene UI tasks T113 through T138.
8. Complete layout, small-screen, and responsiveness verification tasks T139 through T145.
9. Complete prohibited UI and scope guard tasks T146 through T150.
10. Complete manual visual QA tasks T151 through T164.
11. Complete final test runs and acceptance tasks T165 through T169.
12. Complete deal animation requirement update tasks T170 through T181.

## 14. Ambiguities to Keep Flagged During Implementation

- Exact card dimensions in points are unspecified; choose responsive values that preserve an approximately 5:7 ratio and verify readability.
- The undealt 52-card deck stack card size is unspecified relative to player hidden cards; do not claim shared sizing unless implementation explicitly satisfies it.
- The smallest supported simulator is unspecified; use the smallest simulator supported by the project unless product names a stricter target.
- Portrait lock mechanism is unspecified; choose the project-appropriate iOS mechanism and verify behavior.
- "Very bottom" is unspecified relative to the safe area and scrollable content; verify bottom usability and keep the decision visible in tests or QA notes.
- Card table vertical position and geometry tolerances are unspecified; tests should verify required relationships and use documented tolerances.
- Very-centered deck edge buffer is tokenized in `design-tokens.md`; verify the stack remains inside the circular table without touching the edge.
- The requirements place both the `طرنيب` title and undealt deck stack at the table center and allow the deck to obscure the title before the deal; choose layering that preserves exact center placement and verify with UI geometry tests, metadata, snapshots, or manual QA.
- Dealer badge size, inset, font size, and z-order are unspecified; choose values that read as a small upper-left circular badge and verify with UI tests or metadata.
- Dealer assignment impact is unspecified; keep dealer as indication/rotation only and preserve the carried-forward chunk assignment order unless product clarifies otherwise.
- `New Game` behavior while already `notStarted` does not specify whether dealer re-randomizes; tests should only require no deal starts and phase remains `notStarted`.
- Replacement-dealer visibility is unspecified; replacement deals may rotate dealer in state and complete immediately unless product requires an intermediate visible pre-deal state.
- "Dealer's right" is interpreted as the next seat in the existing counterclockwise dealer rotation order.
- Exact deal-animation duration, easing, and center-stack decrement visuals are unspecified; use `animation.deal.*` tokens and verify the model, durable metadata, and final state.
- Automated UI tests may miss short-lived in-flight animation frames; prefer stable accessibility metadata and final-state assertions, with manual QA for frame-by-frame motion quality.
- Rounded-square station dimensions, corner radius, stroke width, and compact size ratios are unspecified; choose responsive values and verify rounded-square readability.
- South station shape after expansion is unspecified; it may become a larger rounded station if it still satisfies South expansion and usability requirements.
- The table-title tracking requirement provides a range, not a single value; choose a value inside the token range.
- The title shadow is part of the specified style; use only the tokenized shadow values.
- Hidden hand stack offsets are unspecified; choose compact values that still represent the required hidden-card counts. The undealt deck stack must use the tokenized squared-stack geometry.
- Exact final perception of "squared" is subjective; start from the `layout.undealtDeck.stack.*` tokens and adjust only by updating the token spec first.
- Automated rendered-token, font, shadow, dealer-badge, and geometry verification may require accessibility metadata, view inspection, snapshots, or manual QA because XCTest may not directly inspect rendered values robustly.
- Error handling UX remains out of scope beyond preventing invalid completed states; do not introduce a user-facing error flow without a future requirement.
- The specified table-title font fallback is unspecified; do not silently choose a different brand font from `SF Arabic Rounded Bold` without flagging it.
