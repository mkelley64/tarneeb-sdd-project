# Tarneeb Experience Review

Date: September 14, 2026

## Assessment

The app has a recognizable identity and a substantial gameplay foundation, but the presentation still feels like a functional prototype. The largest opportunities are card readability, screen-space allocation, physical continuity of motion, and clear rewards for successful play. Sound will help, but cannot compensate for a cramped hand or an unclear trick.

Recommended direction: a premium, tactile tabletop game. Keep the Arabic title, green felt, traditional cards, and counterclockwise flow. Make the cards and current decision dominant; reduce the number of station boxes, chips, borders, and persistent inactive controls.

This is a review and proposal, not an approved replacement specification. No application code was changed.

## Scope and Evidence

- Reviewed the current working tree, including the existing uncommitted gameplay changes, MVP 011 requirements, presentation implementation, design tokens, and UI tests.
- Built the app and inspected launch, dealing, bidding, trump selection, and an opening trick on the iPhone 17 Pro / iOS 26.2 simulator.
- Ran the unit-test target: 152 passed, zero failed or skipped. The full UI regression suite was not run. These passing tests do not establish visual or experiential quality.
- Used a launch override selecting West as dealer and scripted opponent passes to reach South's trump selection predictably. The dealt hand was not a fixed snapshot fixture.
- Observed screenshots and accessibility state, and inspected animation implementation. This was not a frame-by-frame recording or frame-rate measurement.
- Did not complete a whole match, validate every supported device, run VoiceOver end to end, or assess physical-device sound/haptic behavior.
- Distinguish defects from design constraints: several uncomfortable choices faithfully implement older requirements. They need explicit specification changes, not silent implementation overrides.

## Findings

### 1. P1: The current decision can be below the visible screen

On the tested device, the bid selector and later trump selector were partly hidden below the scroll viewport at their initial presentation. Reaching them scrolled the score toward the status-bar area. The entire table and hand occupy a ScrollView while New Game and a disabled Deal button retain a fixed footer. Equal-width suit lanes further increase hand height when suits are unevenly distributed.

Impact: players must navigate the screen to make a routine decision, losing simultaneous access to table context. This is a core usability problem, not just an aesthetic preference.

Recommendation: keep the hand and phase-appropriate action area visible without vertical scrolling on supported phone sizes. Move New Game into a secondary menu after starting; replace the opening Deal control with bidding/trump/play controls as appropriate. Allocate layout from available height as well as width.

Evidence: [main layout](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:33), [suit lanes](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:942), [footer](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:1473).

### 2. P1: Cards are too small for the primary interaction

Visible cards are 36 x 50.4 points. In the simulator, rank and suit indices are tiny and court-card artwork dominates the available detail. A single club occupied one narrow lane while six spades occupied three rows, leaving substantial unused space elsewhere in the hand. Card play is double-tap or drag, without a single-tap selection/inspection state.

Recommendation: separate hand, played-card, and opponent-back sizes. Prototype larger high-index card faces with prominent rank/suit corners, a readable central symbol, and restrained court artwork. Use a compact two-row hand or shallow overlapping spread with every identifying index exposed. Prototype approximately 56-64-point face widths, but validate the fit rather than enshrining those numbers immediately. Give selection an enlarged preview/lift and generous effective touch targets.

Evidence: [card dimensions](/Users/mkelley/tarneeb-sdd-project/Tarneeb/DesignTokens.swift:815), [face rendering and gestures](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:1018).

### 3. P1: The trick is visually crowded and its motion lacks a source

The four played cards visibly overlap in a very small center region. The table is fixed to half the screen width; its play area and slots are smaller fractions again, while card faces retain their fixed dimensions. The implemented play transition fades/scales a card at its destination rather than moving it from the player's hand or station. This does not deliver the source-to-table motion described in the requirements.

Recommendation: enlarge the useful play surface and place opponent stations around its perimeter. Keep every played rank/suit identifiable. Animate each card from its actual origin to its own destination; preserve its identity, size, and orientation throughout the transition. Do not solve this merely by extending duration.

Evidence: [played-card transition](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:390), [table geometry](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:2394), [slot sizing](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:2450), [required South movement](/Users/mkelley/tarneeb-sdd-project/specs/011-mvp/requirements.md:947).

### 4. P2: The reveal is a crossfade, not a card flip

South's reveal replaces backs with faces using opacity and a small scale transition. Despite the naming and metadata, it has no actual turning-card geometry.

Recommendation: use a restrained one-axis flip with the face changing at the edge-on midpoint. Maintain consistent shadows and stable card positions. For Reduce Motion, use a short crossfade instead. Verify the visible reveal order, especially when cards occupy multiple rows.

Evidence: [reveal rendering](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:919), [flip requirement](/Users/mkelley/tarneeb-sdd-project/specs/011-mvp/requirements.md:404).

### 5. P2: Trick resolution does not provide a satisfying payoff

Completed tricks wait 0.75 seconds, fade for 0.20 seconds, then clear. They are not gathered toward the winner. Non-final rounds automatically advance after a two-second score interval. These code-defined timings leave little opportunity to understand a result, and the visual behavior does not clearly connect winning cards to the awarded trick.

Recommendation: briefly identify the winning card/player, gather the four cards, move them toward the winner, and update the visible trick tally on arrival. Show partnership progress against the contract. Give round results a readable summary and a Continue action, or an adjustable automatic pace with access to the previous result.

Evidence: [trick clearing](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:2022), [round advance](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:2061), [timing values](/Users/mkelley/tarneeb-sdd-project/Tarneeb/DesignTokens.swift:615).

### 6. P2: Status text describes the previous phase

During actual trick play, the footer still reads "Bidding complete." During bidding it reads "Deal complete." The status function checks bidding completion rather than providing current trick context.

Recommendation: replace retrospective status with useful current information: whose turn it is, the led suit, and contract progress. Avoid repeating information already obvious from the table.

Evidence: [status logic](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:2182).

### 7. P2: Accessibility metadata is serving tests instead of players

The accessibility tree exposes long implementation strings containing tokens, animation durations, and internal state. Hidden opponent cards are individually exposed. The center play area ignores its child elements, and playable cards are exposed as images with custom gestures rather than an explicit accessible Play action. No app-specific Reduce Motion handling was found.

Recommendation: provide concise spoken labels and values, hide decorative backs, expose each played card and its owner meaningfully, and add an explicit accessible Play action. Keep test instrumentation separate from spoken accessibility content. Validate VoiceOver and Reduce Motion on device before claiming support.

Evidence: [play-area accessibility](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:344), [card interaction metadata](/Users/mkelley/tarneeb-sdd-project/Tarneeb/ContentView.swift:1048).

### 8. P2: Existing animation tests can pass without proving motion

The deal-flight test waits for completion, then asserts metadata such as origin and target order. That verifies the reported presentation contract, not the pixels or path of the moving cards. The reviewed UI test file does not exercise a complete legal trick-play interaction and collection sequence.

Recommendation: retain model tests, but add deterministic visual checkpoints for motion start, midpoint, arrival, and collection. Verify card geometry and ownership independently of strings generated by the same implementation. Add real tap/drag UI paths, screenshots at constrained sizes, and a short recorded playthrough as a release check.

Evidence: [deal animation test](/Users/mkelley/tarneeb-sdd-project/TarneebUITests/TarneebLaunchUITests.swift:271).

### 9. Product gap: There is no coordinated sound or haptic layer

No game audio or explicit haptic implementation was found in the app source. Dealing, playing a card, winning a trick, and making a contract consequently lack distinct sensory feedback.

Recommended initial palette:

| Event | Sound | Haptic |
| --- | --- | --- |
| Deal packet arrives | Soft paper flutter and landing | Usually none |
| Human selects a card | Quiet selection tick | Light selection feedback |
| Card lands on felt | Short, soft card slap | Subtle impact for the human action |
| Bid/trump confirmed | Muted confirmation click | Light confirmation |
| Trick collected | Brief paper sweep | Optional subtle reward |
| Contract or game won | Short warm musical phrase | Distinct, restrained success feedback |

Synchronize feedback with visible events, especially landings. Use a few variations of frequently repeated sounds to avoid mechanical repetition. Provide independent sound/haptic settings, respect silent mode for optional effects, and avoid interrupting the user's music. Background music is not necessary for the first polish pass.

Apple recommends consistent, optional haptics that complement visual and audio feedback rather than overwhelming it: [Playing Haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics). Thumb-reachable controls and visible press feedback also support this direction: [Game Controls](https://developer.apple.com/design/human-interface-guidelines/game-controls).

### 10. Product gap: Opponent play is legal but strategically simplistic

Simulated trick play selects the first legal card after sorting toward low ranks and away from trump. The selector does not evaluate the current winning card, whether a partner is winning, or whether taking the trick helps fulfill the contract. This is separate from the more developed bidding logic.

Recommendation: after interaction polish, add bounded, testable tactical decisions using only information legitimately available to that player. Start with partner awareness, economical winning cards, and sensible trump use. Better audiovisual feedback will be more rewarding when decisions feel meaningful.

Evidence: [simulated choice](/Users/mkelley/tarneeb-sdd-project/Tarneeb/DomainModels.swift:1548), [card ordering](/Users/mkelley/tarneeb-sdd-project/Tarneeb/DomainModels.swift:2144).

## Proposed Delivery Order

1. **Readable layout prototype.** One complete portrait gameplay screen with larger card indices, compact opponents, an expanded trick area, and a fixed contextual action zone. Exercise opening deal, bidding, trump selection, and a skewed 13-card hand. Do not add sound yet.
2. **One polished trick.** Implement selection feedback, real source-to-destination motion, winner identification, collection, and synchronized sound/haptics. Treat this short repeated loop as the quality benchmark.
3. **Deal and round polish.** Apply the same card rendering and motion language to packet dealing and real flips. Add clear contract progress, readable round results, and a restrained match-win moment.
4. **Accessibility and resilience.** Finish Reduce Motion, spoken actions, large-text layout, sound preferences, lifecycle interruption behavior, and animation cancellation/reset checks.
5. **Replayability.** Improve tactical opponent behavior and difficulty before adding cosmetic themes or other peripheral features.

Keep the existing domain model where it works. Extract a focused presentation/motion coordinator from ContentView as needed, with stable card identities and measured source/destination anchors. Drive sound and haptics from explicit game/presentation events, not arbitrary view updates. This does not require a wholesale engine rewrite or a 3D table.

## Decisions to Confirm Before Implementation

- **Visual character:** recommended refined physical tabletop, rather than bright arcade styling.
- **Card input:** recommended tap to select/lift, then a clear Play action; keep drag as a shortcut. Immediate one-tap play is faster but less forgiving. Prototype both before settling.
- **Hand arrangement:** compare two shallow rows with a shallow overlapping spread using actual cards. Preserve identifying indices and touch accuracy rather than insisting on one arrangement in advance.
- **Pacing:** decide whether round results require Continue or use adjustable auto-advance. Keep normal play responsive rather than making every animation slow.
- **Spec changes:** explicitly supersede the half-screen table constraint, shared small card dimensions, persistent inactive Deal footer, suit-lane layout, and double-tap-only shortcut expectations where the new design conflicts. Current specs allow scrolling, so the proposed no-scroll core loop is a new product target.
- **Scope:** confirm phone-only priorities versus tablet layouts, and whether bilingual controls beyond the Arabic title are desired.
- **Assets:** choose or create licensed high-index card artwork and short sound samples. New visual values should be defined in the designated token specification first.

## Validation Strategy

- Keep deterministic engine tests for legal moves, following suit, winner resolution, scoring, dealer rotation, and reset behavior.
- Add hand fixtures for balanced suits, 7/6 distributions, missing suits, a single remaining card, and all legal/mostly illegal choices.
- Check the smallest supported phone, a modern phone, large text, and any supported tablet layout. Verify the hand, current trick, and primary decision remain readable and reachable together.
- Verify actual motion geometry at origin, midpoint, and destination; card conservation; no duplicates; no teleports; no hand reflow moving the source underneath an active animation.
- Check reset, background/foreground, and interruption during each animated stage. No stale sound, double score, orphaned card, or stuck input state should remain.
- Run VoiceOver and Reduce Motion checks. Test muted audio, music from another app, sound/haptic preferences, and repeated feedback on physical hardware.
- Play a complete match and ask a new player to identify their legal cards, the current winner, trump, and contract progress without explanation. Observe hesitation and mis-taps rather than judging only screenshots.

Success means the player can read the hand immediately, understand every movement, recognize who won each trick, and enjoy repeating the core interaction. More effects alone are not the acceptance criterion.
