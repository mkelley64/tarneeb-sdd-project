# Tarneeb iOS MVP 008 Design Tokens

## Design Goals

The visual design should feel:
- Clean and readable on iPhone and iPad
- Inspired by a classic casino card table
- High contrast for accessibility
- Comfortable in low-light environments
- Focused on the cards and gameplay state

The design system should avoid overly saturated colors except for action states and critical highlights.

---

# Core Color Palette

## Table Surface

### Primary Table Green

| Token | Value | Usage |
|---|---|---|
| `color.table.background.primary` | `#1E5A3C` | Main game table background |
| `color.table.background.secondary` | `#17452E` | Gradient or darker table sections |
| `color.table.felt.highlight` | `#2B7A52` | Subtle lighting or active table areas |

### Rationale

These greens resemble real casino felt while maintaining enough darkness for bright cards and white overlays to stand out clearly.

---

# Card Colors

## Card Background

| Token | Value | Usage |
|---|---|---|
| `color.card.background` | `#FDFDFB` | Fallback/generated face-up card background and presentation metadata |
| `color.card.border` | `#D7D7D2` | Fallback/generated card border only; do not layer this border over xCards face artwork |
| `color.card.shadow` | `#00000022` | Card elevation shadow |

---

## Red Suit Color

| Token | Value | Usage |
|---|---|---|
| `color.card.suit.red` | `#C62828` | Hearts and diamonds text/suits |
| `color.card.suit.red.dark` | `#8E1B1B` | Pressed/high contrast red state |

### Rationale

This red is darker than pure iOS system red, improving readability against a white card background and reducing eye strain.

---

## Card Face Asset Rendering

- Production exposed South cards use imported xCards face artwork rather than generated text-only card faces.
- Each standard 52-card face asset must be available as `card_face_<rank><suit>` with `1x`, `2x`, and `3x` scale variants.
- Ten uses `T`; suits use `C`, `D`, `H`, and `S`; joker assets are not part of this MVP.
- The face image owns its white card surface, border impression, and corner mask. Do not apply a separate rounded-rectangle face background, border, or clipping radius over the xCards image.
- Use high-quality image interpolation/antialiasing when scaling face assets down to the shared card size.
- Hidden/generated card backs may still use card background, border, shadow, and corner tokens as needed to match the existing back artwork and stack presentation.

---

## Black Suit Color

| Token | Value | Usage |
|---|---|---|
| `color.card.suit.black` | `#1A1A1A` | Spades and clubs text/suits |
| `color.card.suit.black.soft` | `#2E2E2E` | Secondary dark card accents |

### Rationale

Avoiding absolute black creates a softer premium appearance while maintaining excellent contrast.

---

# Player Station Colors

## Station Outlines

| Token | Value | Usage |
|---|---|---|
| `color.station.outline` | `#F5F5F5` | Player zone outlines |
| `color.station.outline.active` | `#FFB300` | Active bidding-turn player highlight; must match `color.button.newGame.background` |
| `color.station.outline.inactive` | `#FFFFFF66` | Dimmed inactive player station |

### Dealer Indication Usage

- Use a small beside-name `D` pill to indicate the dealer before bidding starts.
- Dealer indication uses `color.dealerBadge.background` as the pill background so it stays synchronized with the `Deal` button, and `color.dealerBadge.text` for the white `D`.
- Non-dealer station outlines remain `color.station.outline`.
- During active bidding only, the current bidder may use `color.station.outline.active` plus a small active-turn indicator.

---

## Dealer Pill Colors

| Token | Value | Usage |
|---|---|---|
| `color.dealerBadge.background` | `#1976D2` | Dealer pill background color; must match `color.button.deal.background` |
| `color.dealerBadge.text` | `#FFFFFF` | Dealer pill `D` text color |

### Dealer Pill Usage

- Show the pill beside the current dealer's player name before bidding starts without overlaying or obscuring the name.
- Keep `color.dealerBadge.background` synchronized with `color.button.deal.background`.
- Hide the pill once bidding starts while dealer state remains exposed in accessibility metadata.

---

## Game Text

| Token | Value | Usage |
|---|---|---|
| `color.text.primary` | `#FFFFFF` | Main table text |
| `color.text.secondary` | `#D9D9D9` | Secondary labels |
| `color.text.disabled` | `#FFFFFF66` | Disabled or inactive labels |
| `color.text.warning` | `#FFD166` | Warnings or important notices |

### Recommended Text Usage

- Use primary white for scores and active game information.
- Use secondary white for instructional text.
- Avoid using pure bright colors for large text blocks.

---

# Bidding Area Colors

## Bidding Panel

| Token | Value | Usage |
|---|---|---|
| `color.bidArea.background` | `#123A2A` | Bordered post-reveal `Bidding` area background under the South station |
| `color.bidArea.border` | `#E8DFC866` | Border for the post-reveal `Bidding` area |
| `color.bidArea.label` | `#E8DFC8` | `Bidding` label text |
| `color.bidArea.table.divider` | `#FFFFFF2E` | Subtle divider or chip outline used by the bidding panel and station bid chips |
| `color.bidArea.value.text` | `#FFFFFF` | Bid value text for all players |
| `color.bidArea.value.pending.text` | `#FFFFFF99` | Pending `--` bid value text before a player resolves a bid |
| `color.bidArea.value.highest.text` | `#FFB300` | Current highest numeric bid value text; must match `color.button.newGame.background` |
| `color.bidArea.seat.text` | `#D9D9D9` | Seat labels associated with station bid metadata or compact bid surfaces |

### Bidding Panel Usage

- The bidding area appears only after a completed deal.
- The bidding area remains visible only while bidding is active or while its terminal fade-out is running.
- The bidding area must read as a bordered panel under the South station, not as a floating modal.
- The bidding area should remain visually quieter than the cards and bottom actions.
- The bid panel border should separate bidding from the South hand without competing with active-turn emphasis.
- The bid panel header may include a compact current-turn status pill using existing bidding-area divider/border tokens.
- Station bid/pass values render as compact chips inside the player stations. Active-turn and current-highest chips should use existing amber/highest-bid token emphasis without introducing a new color family.
- Pending values display as `--` and should use the pending value token until their turn resolves.
- The current highest numeric bid value should use `color.bidArea.value.highest.text`.
- `Pass` values and numeric bid values that are no longer the current highest bid should use `color.bidArea.value.text`.
- When a higher numeric bid is accepted, the superseded previous high bid should transition from `color.bidArea.value.highest.text` to `color.bidArea.value.text`.
- When bidding reaches a terminal state, fade the entire bidding panel out using `animation.bid.area.fadeOut.duration`, then remove it from the layout before either showing the numeric high-bid summary or starting the all-pass automatic redeal.
- Accepted bid preferred trump/Tarneeb suit storage is internal bid-record state
  and does not add extra visible values to resolved in-progress station bid chips.
- No Tarneeb suit selector appears during the in-progress bidding round.
- If South is the numeric high bidder, style the post-bidding South suit-setting
  panel with `color.bidSuitSelector.*`, `layout.bidSuitSelector.*`,
  `effect.bidSuitSelector.*`, and the shared bid/Set button tokens.
- Do not render stored preferred suits as editable controls in the `Bidding`
  panel; the resolved suit symbol appears in the post-bidding summary after any
  required South `Set` action.

## Post-Bidding Summary

| Token | Value | Usage |
|---|---|---|
| `color.postBiddingSummary.background` | `#123A2A` | Compact summary surface shown after the `Bidding` area fades away |
| `color.postBiddingSummary.border` | `#E8DFC866` | Border for the post-bidding result summary |
| `color.postBiddingSummary.label.text` | `#D9D9D9` | Labels such as `Tarneeb`; also available for the South post-bidding `Contract` suit-setting panel |
| `color.postBiddingSummary.team.text` | `#FFFFFF` | High-bidding player value text for the South post-bidding `Contract` suit-setting panel or metadata surfaces, not repeated in the final Tarneeb ribbon |
| `color.postBiddingSummary.bid.text` | `#FFB300` | High bid value text for the South post-bidding `Contract` suit-setting panel or station metadata; must match `color.button.newGame.background` |
| `color.postBiddingSummary.tarneeb.text` | `#FFFFFF` | Tarneeb label/fallback symbol text; final suit symbols use card suit color tokens |

### Post-Bidding Summary Usage

- The post-bidding summary appears only after the one-second bidding-panel fade-out completes.
- The summary is shown only when bidding completes with a numeric high bid.
- All-pass terminal bidding must not use post-bidding summary color or layout tokens because no summary is shown before the automatic redeal.
- The final summary ribbon must display only a `Tarneeb` label with the preferred suit symbol; the high-bidding player and high bid value remain visible on the winning station and available in summary metadata.
- The South post-bidding suit-setting panel remains a compact `Contract` surface for choosing the suit when South is the numeric high bidder, using the bidder/bid/Tarneeb token roles above.
- The high bid value, where shown in the station bid chip or South `Contract` panel, uses the same amber as the current-highest bid and `New Game` button.
- The preferred suit symbol uses the high bidder's accepted bid record as its
  source. The final symbol is displayed in a compact white chip using
  `color.card.background` for the chip fill, `color.button.newGame.background`
  for its border, and the proper card suit color token: black for Spades/Clubs
  and red for Hearts/Diamonds.
- The summary is non-interactive and must not become a suit picker.

---

# Form Control Colors

## Bid Selector

| Token | Value | Usage |
|---|---|---|
| `color.bidSelector.background` | `#FDFDFB` | South bid chip/action tray background |
| `color.bidSelector.border` | `#D7D7D2` | South bid chip/action tray border |
| `color.bidSelector.text` | `#1A1A1A` | South bid chip value text |
| `color.bidSelector.focusRing` | `#1976D2` | Focus or active state ring for the South bid chips |

### Bid Selector Usage

- The selector tokens style South's bid chips/action tray.
- The bid chips appear only while South's bidding turn is active.
- The chip options are `Pass` plus the currently legal numeric values through `13`.
- Bid chips should wrap inside the South action tray on narrow screens rather than overflowing horizontally.
- Simulated bid values for East, North, and West are displayed as non-interactive table values after their turns resolve.

## Automated Bid Calibration Boundary

The conservative automated-bidding calibration is game-logic behavior, not a
visual token set.

- Do not introduce color, layout, typography, or animation tokens for evaluator
  scoring weights.
- Per-suit `expectedTricks`, conservative `safeBidCeiling`, side-winner
  treatment, short-suit eligibility, high-bid gate results, partner-awareness
  pass/raise rules, regression hand outcomes, and deterministic multi-deal
  simulation reports belong in automated bidding tests and domain-level
  recommendation diagnostics, not in SwiftUI styling.
- Exact regression hands should validate the generalized evaluator diagnostics;
  they must not introduce hand-specific visual styling, token branches, or UI
  explanations.
- The visible output of the calibration remains the existing station bid states:
  `--`, `Pass`, numeric values from `7` through `13`, current-highest bid color,
  and the existing one-second bid value transition.
- A weak long-suit hand with no aces, no outside winners, and weak top trump
  control should visually resolve through the normal table value path as `Pass`
  or at most `7`; it should not require a special warning color or explanatory UI.
- A strong but not 10-safe five-card trump hand should visually resolve through
  the normal table value path as at most `9`; it should not require a special cap
  indicator, warning color, or explanatory UI.
- An ace-led five-card trump hand without king or queen support should visually
  resolve through the normal table value path as `Pass` or at most `7`; it should
  not require a special uncertainty color, cap indicator, or explanatory UI.
- A strong but not 10-safe six-card trump hand with ace-queen support but no king
  should visually resolve through the normal table value path as at most `9`; it
  should not require a special cap indicator, warning color, or explanatory UI.
- A strong but not 10-safe five-card ace-king-queen-ten trump hand with no
  outside aces should visually resolve through the normal table value path as at
  most `9`; it should not require a special cap indicator, warning color, or
  explanatory UI.
- A five-card ace-king-queen-jack trump hand missing ten with no outside aces
  should visually resolve through the normal table value path as at most `9`;
  it should not require a special cap indicator, warning color, or explanatory
  UI.
- A five-card ace-king-ten trump hand missing queen and jack with one outside
  ace and one singleton should visually resolve through the normal table value
  path as at most `8`; it should not require a special cap indicator, warning
  color, or explanatory UI.
- A five-card ace-queen-ten trump hand missing king and jack with one outside
  ace and one singleton should visually resolve through the normal table value
  path as at most `8`; it should not require a special cap indicator, warning
  color, or explanatory UI.
- A six-card ace-king-queen-jack trump hand without outside aces should visually
  resolve through the normal table value path as at most `10`; it should not
  require a special cap indicator, warning color, or explanatory UI.
- A four-card ace-low trump hand with only one outside ace should visually
  resolve through the normal table value path as `Pass`; it should not require a
  special weak-opening indicator or explanatory UI.
- A five-card king-queen-ten trump hand missing the ace with only one outside ace
  and side kings should visually resolve through the normal table value path as
  at most `7`; it should not require a special missing-ace indicator or
  explanatory UI.
- A six-card ace-jack trump hand without king, queen, or ten support should
  visually resolve through the normal table value path as at most `9`; it should
  not require a special cap indicator, warning color, or explanatory UI.
- Four-card ace-king-jack, ace-king-low, and ace-queen-jack trump hands with
  ordinary outside support should visually resolve through the normal table value
  path as at most `8` where specified by the regression fixtures; they should
  not require special cap indicators, warning colors, or explanatory UI.
- A four-card ace-king-jack trump hand with two outside aces plus side king/queen
  honors should visually resolve through the normal table value path as at most
  `9`; it should not require special strong-side-honor indicators, warning
  colors, or explanatory UI.
- Four-card ace-queen-low and ace-jack-ten trump hands without outside ace
  support should visually resolve through the normal table value path as `Pass`;
  they should not require special weak-opening indicators or explanatory UI.
- Four-card ace-jack-ten-low trump hands without outside aces or kings, without
  void or singleton support, and with only ordinary outside queen/jack support
  should visually resolve through the normal table value path as `Pass`; they
  should not require special weak-opening indicators or explanatory UI.
- Shallow three-card king-queen or four-card ace-jack-low trump candidates with
  two outside aces and one outside king should visually resolve through the
  normal table value path as at most `7`; they should not require special
  shallow-trump indicators, warning colors, or explanatory UI.
- Five-card ace-king-queen trump hands missing jack and ten with no outside aces
  should visually resolve through the normal table value path as at most `8`;
  they should not require special cap indicators, warning colors, or explanatory
  UI.
- Five-card ace-king-jack trump hands missing queen and ten with one outside ace
  and no short-suit support should visually resolve through the normal table
  value path as at most `8`; they should not require special cap indicators,
  warning colors, or explanatory UI.
- Six-card ace-king-queen trump hands missing jack and ten with two outside aces
  and one outside king should visually resolve through the normal table value
  path as at most `11`; they should not require special cap indicators, warning
  colors, or explanatory UI.
- Six-card ace-king-queen trump hands missing jack and ten with no outside aces,
  no outside kings, and no void or singleton support should visually resolve
  through the normal table value path as at most `9`; they should not require
  special cap indicators, warning colors, or explanatory UI.
- Six-card ace-king-queen trump hands missing jack and ten with one outside king
  plus void or singleton support should visually resolve through the normal table
  value path as at most `10`; they should not require special cap indicators,
  warning colors, or explanatory UI.
- Six-card ace-king-queen trump hands missing jack and ten with only one outside
  ace plus ordinary side king/queen support should visually resolve through the
  normal table value path as at most `10`; they should not require special cap
  indicators, warning colors, or explanatory UI.
- Six-card ace-king-low trump hands missing queen, jack, and ten with one outside
  ace plus ordinary side king/queen support should visually resolve through the
  normal table value path as at most `9`; they should not require special cap
  indicators, warning colors, or explanatory UI.
- Six-card king-queen trump hands missing ace, jack, and ten with no outside
  aces and only side kings/queens plus a void should visually resolve through
  the normal table value path as at most `8`; they should not require special
  missing-ace indicators, warning colors, or explanatory UI.
- Six-card king-queen-jack or king-queen-jack-ten trump hands missing the ace
  with at most one outside ace and ordinary side support should visually resolve
  through the normal table value path as at most `8`; they should not require
  special missing-ace indicators, warning colors, or explanatory UI.
- Seven-card ace-king-queen-jack-ten trump hands with two outside aces should
  visually resolve through the normal table value path as at most `12`, not `13`;
  they should not require special near-commanding indicators, warning colors, or
  explanatory UI.
- Five-card king-queen trump hands missing ace, jack, and ten should visually
  resolve through the normal table value path as at most `7`; they should not
  require special missing-ace indicators, warning colors, or explanatory UI.
- Five-card ace-queen-ten trump hands missing king and jack with three outside
  aces and one outside king should visually resolve through the normal table
  value path as at most `10`; they should not require special cap indicators,
  warning colors, or explanatory UI.
- Four-card ace-king-ten, ace-king-jack-ten, ace-king-low, or ace-queen texture
  hands should visually resolve through the normal table value path at the
  specified capped value; they should not require special short-trump indicators,
  warning colors, or explanatory UI.
- Four-card ace-king-queen-ten trump hands missing jack with at most one outside
  ace and ordinary side honor support should visually resolve through the normal
  table value path as at most `8`; they should not require special short-trump
  indicators, warning colors, or explanatory UI.
- Four-card ace-king-queen-jack trump hands missing ten with at most one outside
  ace and ordinary side honor support should visually resolve through the normal
  table value path as at most `8`; they should not require special short-trump
  indicators, warning colors, or explanatory UI.
- Five-card ace-jack-ten trump hands missing king and queen with no outside aces
  should visually resolve through the normal table value path as `Pass`; they
  should not require a special weak-opening indicator or explanatory UI.
- Five-card ace-ten trump hands missing king, queen, and jack with no outside
  aces and no short-suit support should visually resolve through the normal
  table value path as `Pass`; they should not require a special weak-opening
  indicator or explanatory UI.
- Five-card ace-low trump hands with two outside aces and one outside king
  should visually resolve through the normal table value path as at most `7`;
  they should not require special cap indicators, warning colors, or explanatory
  UI.
- Seven-card ace-queen-ten or ace-queen trump hands missing adjacent high trump
  controls should visually resolve through the normal table value path as at
  most `10`; they should not require special long-suit cap indicators, warning
  colors, or explanatory UI.
- Seven-card ace-jack-low trump hands missing king, queen, and ten with only one
  outside ace should visually resolve through the normal table value path as at
  most `8`; they should not require special long-suit cap indicators, warning
  colors, or explanatory UI.
- Seven-card king-queen-low trump hands missing ace, jack, and ten with at most
  one outside ace and ordinary side support should visually resolve through the
  normal table value path as at most `8`; they should not require special
  long-suit or missing-ace indicators, warning colors, or explanatory UI.
- Eight-card ace-queen-jack-ten trump hands missing king and lacking outside
  aces or outside kings should visually resolve through the normal table value
  path as at most `11`; they should not require special long-suit cap
  indicators, warning colors, or explanatory UI.
- When a simulated player passes because their partner is currently highest, the
  table should show the normal `Pass` value styling; no partner-awareness token
  or special visual affordance is introduced for MVP 008.
- When the bidding service rejects an override, stale recommendation, or
  deterministic recommender value because it would raise the simulated player's
  partner by only one trick, the table should show the normal `Pass` value
  styling and no preferred-suit styling; no service-guard token is introduced.

## Bid Suit Selector

| Token | Value | Usage |
|---|---|---|
| `color.bidSuitSelector.background` | `#FDFDFB` | Post-bidding South Tarneeb suit chip background |
| `color.bidSuitSelector.border` | `#D7D7D2` | Post-bidding South Tarneeb suit chip border |
| `color.bidSuitSelector.text` | `#1A1A1A` | Unselected Spades/Clubs option text; Hearts/Diamonds use the card red suit token |
| `color.bidSuitSelector.selected.background` | `#1976D2` | Legacy selected-fill fallback; current selected suit chips keep the white card background and use the amber border |
| `color.bidSuitSelector.selected.text` | `#FFFFFF` | Legacy selected-text fallback; current selected suit chips keep the proper card suit color |
| `color.bidSuitSelector.focusRing` | `#1976D2` | Focus or active state ring for the post-bidding South Tarneeb suit selector |

### Bid Suit Selector Usage

- The suit selector is used only for South's post-bidding Tarneeb suit choice
  when South is the numeric high bidder.
- The suit selector appears only after the `Bidding` area fades out and only
  until South taps `Set`.
- The suit selector offers exactly `♠`, `♣`, `♥`, and `♦`.
- Suit chips use a white background; Spades/Clubs use black suit text and
  Hearts/Diamonds use red suit text to match playing cards.
- Numeric South bid drafts do not require a selected suit before the in-progress
  South `Bid` button is enabled.
- The post-bidding `Set` button is disabled until South selects a suit.
- South `Pass` submissions do not require or store a selected suit.
- Simulated preferred suits are stored on accepted numeric bid records but are not rendered as interactive controls.

---

# Card Table Title

## Tarneeb Title

| Token | Value | Usage |
|---|---|---|
| `typography.tableTitle.font` | `SF Arabic Rounded Bold` | Font token for the `طرنيب` title centered on the card table |
| `typography.tableTitle.fontSize` | `26pt` | Fixed point size for the `طرنيب` title centered on the card table |
| `typography.tableTitle.tracking.min` | `+2` | Minimum tracking for the card table title |
| `typography.tableTitle.tracking.max` | `+4` | Maximum tracking for the card table title |
| `color.tableTitle.text` | `#E8DFC8` | Text color for the `طرنيب` title on the card table |
| `effect.tableTitle.text.opacity` | `0.92` | Text opacity for the `طرنيب` title on the card table |
| `effect.tableTitle.shadow.color` | `#000000` | Subtle title shadow color |
| `effect.tableTitle.shadow.opacity` | `0.25` | Subtle title shadow opacity |
| `effect.tableTitle.shadow.blurRadius` | `4` | Subtle title shadow blur radius |
| `effect.bidButton.disabled.opacity` | `0.55` | Disabled opacity for the South `Bid` button outside South's turn or while South has an invalid draft submission |
| `effect.bidSuitSelector.disabled.opacity` | `0.55` | Disabled opacity for inactive or unavailable South Tarneeb suit selector states |
| `effect.table.centerSurface.opacity` | `0.16` | Opacity for the subtle darker center surface on the circular table |
| `effect.table.innerRing.opacity` | `0.38` | Opacity for the subtle inner ring on the circular table |
| `effect.table.rail.highlight.opacity` | `0.42` | Outer rail highlight opacity for subtle table depth |
| `effect.table.rail.innerBevel.opacity` | `0.28` | Inner bevel opacity for the felt rail treatment |
| `effect.table.rail.shadow.opacity` | `0.24` | Shadow opacity for table rail depth |
| `effect.table.rail.shadow.radius` | `6` | Shadow radius for table rail depth |
| `effect.table.playArea.shadow.opacity` | `0.16` | Shadow opacity for the reserved center play area |
| `effect.southHand.rail.background.opacity` | `0.14` | Soft background opacity for the South hand ownership rail |
| `effect.southHand.rail.stroke.opacity` | `0.36` | Baseline stroke opacity for the South hand ownership rail |
| `effect.station.background.default.opacity` | `0.08` | Default player-station background fill opacity |
| `effect.station.background.active.opacity` | `0.24` | Active bidding-turn player-station background fill opacity |
| `effect.bidArea.turnPill.background.opacity` | `0.22` | Current-turn pill background opacity in the `Bidding` header |
| `effect.bidArea.cell.default.background.opacity` | `0.06` | Default bid-cell background opacity |
| `effect.bidArea.cell.active.background.opacity` | `0.10` | Active-turn bid-cell background opacity |
| `effect.bidArea.cell.highest.background.opacity` | `0.14` | Current-highest bid-cell background opacity |
| `effect.bidArea.actionTray.background.opacity` | `0.10` | South bid action tray background opacity |
| `effect.phaseStatus.background.opacity` | `0.72` | Compact bottom phase-status pill background opacity |
| `effect.statusPill.border.opacity` | `0.55` | Bottom status pill border opacity |
| `effect.bottomControl.separator.opacity` | `0.35` | Top separator opacity for the bottom control area |

### Rationale

The condensed heavy title treatment keeps the brand mark readable inside the circular table while avoiding a large page-level heading. Tracking should stay within `+2` to `+4` so the title feels intentional without becoming loose or decorative.

### Shadow Usage

- The title shadow is part of the specified title style.
- The center play area and South hand rail should stay subtle enough to support
  gameplay readability; they must not compete with card faces, active bidder
  emphasis, or the current-highest bid color.
- The shadow should be subtle and only improve readability against the table surface when the title is not covered by the deck.
- The shadow must not create a glow effect.

---

# Action Button Colors

## Primary Action Buttons

### Deal Button

| Token | Value | Usage |
|---|---|---|
| `color.button.deal.background` | `#1976D2` | Deal button background |
| `color.button.deal.background.pressed` | `#1257A0` | Pressed state |
| `color.button.deal.text` | `#FFFFFF` | Deal button text |

### Rationale

Blue contrasts strongly with the green table and avoids confusion with card suit colors.

---

### Bid Button

| Token | Value | Usage |
|---|---|---|
| `color.button.bid.background` | `#1976D2` | South `Bid` button background while South's bidding turn has a valid submission |
| `color.button.bid.background.pressed` | `#1257A0` | Pressed state for the South `Bid` button |
| `color.button.bid.text` | `#FFFFFF` | South `Bid` button text |

### Bid Button Usage

- The South `Bid` button appears while bidding is in progress.
- The South `Bid` button is enabled only while South's bidding turn is active
  with a valid submission: `Pass`, or a legal numeric bid.
- The South `Bid` button disappears after the bidding round reaches a terminal state.
- The post-bidding South `Set` button uses the same button token family and is
  enabled only after South selects a Tarneeb suit.
- The bid button color matches the primary deal action to signal an active game action without introducing a new hue.

---

## Secondary Action Buttons

### New Game Button

| Token | Value | Usage |
|---|---|---|
| `color.button.newGame.background` | `#FFB300` | New Game button background |
| `color.button.newGame.background.pressed` | `#CC8A00` | Pressed state |
| `color.button.newGame.text` | `#1A1A1A` | Button text |

### Rationale

Warm amber creates clear visual separation from gameplay actions while remaining highly visible on the dark green table.

---

## Destructive Buttons

| Token | Value | Usage |
|---|---|---|
| `color.button.destructive.background` | `#B71C1C` | Quit/forfeit/reset actions |
| `color.button.destructive.text` | `#FFFFFF` | Destructive button text |

---

# Accessibility Requirements

## Contrast

- All interactive text must maintain a minimum contrast ratio of 4.5:1.
- Critical gameplay information should target 7:1 contrast.
- Button text should always maintain accessibility contrast standards.
- The card table title should remain readable against the table surface with the specified subtle shadow; the undealt deck is positioned in the dealer station and should not cover the title.

---

# Layout Recommendations

## Card Spacing

- Standard card gap: `8pt`
- Player station padding: `16pt`
- Bidding area padding: `12pt`
- Bidding action row gap: `6pt`
- Primary action button height: `52pt`
- Corner radius for controls: `14pt`
- Bidding area corner radius: `10pt`
- Bid selector height: `36pt`
- Bid selector minimum width: `32pt`
- Bid selector option gap: `2pt`
- Bid suit selector height: `36pt`
- Bid suit selector minimum width: `132pt`
- Bid suit selector option minimum width: `36pt`
- Bid suit selector option gap: `4pt`
- Bid action button height: `36pt`
- Bid action button minimum width: `56pt`
- Post-bidding summary padding: `12pt`
- Post-bidding summary row gap: `6pt`

## Bidding Layout Tokens

| Token | Value | Usage |
|---|---|---|
| `layout.bidArea.padding` | `12pt` | Inner padding for the bordered `Bidding` area |
| `layout.bidArea.table.rowGap` | `6pt` | Legacy/shared row spacing token for bidding panel rows and compact bid surfaces |
| `layout.bidArea.cornerRadius` | `10pt` | Corner radius for the bordered `Bidding` panel |
| `layout.bidSelector.height` | `36pt` | Height for the active South bid chip/action tray |
| `layout.bidSelector.minimumWidth` | `32pt` | Minimum width for each numeric active South bid chip; the `Pass` chip may add horizontal allowance while staying in the same row |
| `layout.bidSelector.optionGap` | `2pt` | Compact gap between active South bid chips so `Pass` and 7-13 fit on one line on supported screens |
| `layout.bidSuitSelector.height` | `36pt` | Height for the post-bidding South Tarneeb suit selector |
| `layout.bidSuitSelector.minimumWidth` | `132pt` | Minimum width for the post-bidding South Tarneeb suit selector |
| `layout.bidSuitSelector.optionMinimumWidth` | `36pt` | Minimum width for each suit option touch target |
| `layout.bidSuitSelector.optionGap` | `4pt` | Gap between suit options in the selector |
| `layout.bidButton.height` | `36pt` | Height for the active South `Bid` button |
| `layout.bidButton.minimumWidth` | `56pt` | Minimum width for the active South `Bid` button |
| `layout.postBiddingSummary.padding` | `12pt` | Inner padding for the post-bidding result summary |
| `layout.postBiddingSummary.rowGap` | `6pt` | Vertical spacing between summary rows |
| `layout.postBiddingSummary.cornerRadius` | `10pt` | Corner radius for the post-bidding result summary |

---

## Pre-Deal Undealt Deck

The pre-deal undealt deck must sit at the exact visual center of the selected dealer station and use a squared-stack geometry. These tokens are the source of truth for that placement and stack geometry.

| Token | Value | Usage |
|---|---|---|
| `layout.undealtDeck.anchor.x` | `0.5` | Horizontal anchor at the center of the selected dealer station bounds |
| `layout.undealtDeck.anchor.y` | `0.5` | Vertical anchor at the center of the selected dealer station bounds |
| `layout.undealtDeck.centerOffset.x` | `0pt` | Horizontal offset from the dealer-station center; must remain zero for station-center placement |
| `layout.undealtDeck.centerOffset.y` | `0pt` | Vertical offset from the dealer-station center; must remain zero for station-center placement |
| `layout.undealtDeck.stack.rotation` | `0deg` | Card rotation for the squared deck stack |
| `layout.undealtDeck.stack.offset.x` | `0pt` | Per-card horizontal offset for the squared deck stack |
| `layout.undealtDeck.stack.offset.y` | `0pt` | Per-card vertical offset for the squared deck stack |
| `layout.undealtDeck.edgeBuffer.min` | `12pt` | Minimum visual buffer between the deck stack bounds and the dealer station edge |

### Undealt Deck Usage

- The deck stack should be squared: no visual fan, spread, or rotation before the deal.
- The deck still represents 52 hidden cards and must not reveal rank, suit, or card identity.
- The table title remains centered on the table and must not be obscured by the stacked undealt deck before the deal.
- If product wants a different stack offset or rotation later, update these tokens before changing implementation values.

---

## Deal Animation

The deal animation uses four 13-card hidden stack movements. Each stack starts at the dealer station, targets the player on the dealer's right first, and then continues counterclockwise until all four stations have received 13 cards. Simulated stations reveal hidden backs after their stack arrives. If South receives its stack before the fourth movement, South keeps that stack visible as slightly fanned card backs while hiding all ranks and suits. After all four hands have been dealt, South expands with 13 backs and flips those cards face-up left-to-right over 1.5 seconds.

| Token | Value | Usage |
|---|---|---|
| `animation.deal.stack.flight.duration` | `0.36s` | Duration for one 13-card stack movement from the dealer station to a station |
| `animation.deal.station.expand.duration` | `0.16s` | Duration for simulated station reveal/expansion after stack arrival and South backs expansion after all stacks arrive |
| `animation.deal.step.pause.duration` | `0.06s` | Short pause before each stack flight starts |
| `animation.deal.southReveal.total.duration` | `1.5s` | Total duration from the first South card beginning its final reveal flip to the last South card completing its flip |
| `animation.deal.southReveal.flip.duration` | `0.18s` | Duration for one South card to flip from back to face during the final reveal |
| `animation.deal.southReveal.flip.stagger` | `0.11s` | Delay between each South card flip, applied left-to-right so 13 cards complete in 1.5 seconds |
| `animation.trick.playedCard.flight.duration` | `0.30s` | Future duration for a played card traveling from a station or hand to its matching center play-area slot |

### Deal Animation Usage

- The animated stack represents exactly 13 hidden cards and must not reveal rank, suit, or card identity.
- Animation target order starts at the current dealer's right and follows the counterclockwise dealer rotation order.
- The dealer-station source deck stack may decrement during the animation, but it must be gone when the fourth 13-card stack has arrived.
- South rank and suit values must not render during the four stack movements, even if South receives a stack before the fourth movement.
- If South receives a stack before the fourth movement completes, the South station keeps 13 hidden backs visible as a slightly fanned dealt stack until final South expansion begins.
- After the fourth stack arrives, South uses `animation.deal.station.expand.duration` to expand with 13 backs before any face values appear.
- South cards flip face-up left-to-right using `animation.deal.southReveal.total.duration`, `animation.deal.southReveal.flip.duration`, and `animation.deal.southReveal.flip.stagger`; the full first-card-start to last-card-complete reveal must take 1.5 seconds.

### Future Trick-Play Motion Usage

- MVP 008 does not implement playing cards into tricks, but the center play area
  reserves seat-matched target slots for that future phase.
- Future played cards should use `animation.trick.playedCard.flight.duration`
  when traveling from South, West, North, or East into the corresponding center
  slot.
- The motion should be quick and readable so it answers which seat acted without
  delaying trick resolution once trick play exists.
- `Deal complete`, bidding initialization, and the `Bidding` area wait until the South reveal flip completes.
- Overlapping `Deal` or `New Game` actions should be prevented while the deal animation is running.

---

## Bid Timing and Value Animation

Simulated East, North, and West turns wait before their displayed bid value changes.
Bid value changes then use a one-second fade out/in animation and color-state
update when a table entry changes from `--`, from the active South selector, or
from any previous visible value. The current highest numeric bid remains amber
using the same value as the `New Game` button; when a higher numeric bid is
accepted, the superseded previous high transitions to white.

| Token | Value | Usage |
|---|---|---|
| `animation.bid.simulatedTurn.delay` | `1.0s` | Minimum delay before a simulated player bid value updates |
| `animation.bid.value.fadeOut.duration` | `0.5s` | Fade-out portion of the one-second bid value transition |
| `animation.bid.value.fadeIn.duration` | `0.5s` | Fade-in portion of the one-second bid value transition |
| `animation.bid.area.fadeOut.duration` | `1.0s` | Fade-out duration for hiding the entire `Bidding` area after terminal bidding |

### Bid Timing and Value Animation Usage

- Use the simulated turn delay token before each East, North, or West bid value update.
- Use these tokens for bid value changes in the `Bidding` table.
- Use `color.bidArea.value.highest.text` for the current highest numeric bid before and after the one-second transition settles.
- If a newly accepted numeric bid becomes highest, update the previous highest bid from `color.bidArea.value.highest.text` to `color.bidArea.value.text` during the same one-second transition.
- Use `animation.bid.area.fadeOut.duration` when bidding completes to fade out the complete bidding panel before showing the post-bidding summary or starting the all-pass automatic redeal.
- Do not use the bid value fade tokens for the 13-card deal animation.
- An all-pass automatic redeal should reuse the existing `animation.deal.*` timing tokens for its fresh deal animation; no separate automatic-redeal timing tokens are introduced for MVP 008.
- If a player bids `13` and other values become `Pass`, each changed table entry should use the same fade out/in timing.

---

# Suggested SwiftUI Token Structure

```swift
struct GameColors {
    static let tableGreen = Color(hex: "#1E5A3C")
    static let tableGreenDark = Color(hex: "#17452E")

    static let suitRed = Color(hex: "#C62828")
    static let suitBlack = Color(hex: "#1A1A1A")

    static let stationOutline = Color(hex: "#F5F5F5")
    static let stationOutlineActive = Color(hex: "#FFB300")
    static let dealerBadgeBackground = Color(hex: "#1976D2")
    static let dealerBadgeText = Color(hex: "#FFFFFF")
    static let tableTitle = Color(hex: "#E8DFC8").opacity(0.92)
    static let tableTitleShadow = Color.black.opacity(0.25)

    static let dealBlue = Color(hex: "#1976D2")
    static let newGameAmber = Color(hex: "#FFB300")

    static let bidAreaBackground = Color(hex: "#123A2A")
    static let bidAreaBorder = Color(hex: "#E8DFC8").opacity(0.4)
    static let bidAreaLabel = Color(hex: "#E8DFC8")
    static let bidAreaDivider = Color.white.opacity(0.18)
    static let bidAreaPendingValue = Color.white.opacity(0.6)
    static let bidAreaHighestValue = Color(hex: "#FFB300")
    static let postBiddingSummaryBackground = Color(hex: "#123A2A")
    static let postBiddingSummaryBorder = Color(hex: "#E8DFC8").opacity(0.4)
    static let postBiddingSummaryLabel = Color(hex: "#D9D9D9")
    static let postBiddingSummaryTeam = Color(hex: "#FFFFFF")
    static let postBiddingSummaryBid = Color(hex: "#FFB300")
    static let postBiddingSummaryTarneeb = Color(hex: "#FFFFFF")
    static let bidSelectorBackground = Color(hex: "#FDFDFB")
    static let bidSelectorBorder = Color(hex: "#D7D7D2")
    static let bidSelectorText = Color(hex: "#1A1A1A")
    static let bidSelectorFocusRing = Color(hex: "#1976D2")
    static let bidSuitSelectorBackground = Color(hex: "#FDFDFB")
    static let bidSuitSelectorBorder = Color(hex: "#D7D7D2")
    static let bidSuitSelectorText = Color(hex: "#1A1A1A")
    static let bidSuitSelectorSelectedBackground = Color(hex: "#1976D2")
    static let bidSuitSelectorSelectedText = Color(hex: "#FFFFFF")
    static let bidSuitSelectorFocusRing = Color(hex: "#1976D2")
    static let bidButtonBackground = Color(hex: "#1976D2")
    static let bidButtonText = Color(hex: "#FFFFFF")
    static let bidButtonDisabledOpacity = 0.55
    static let bidSuitSelectorDisabledOpacity = 0.55
    static let tableCenterSurfaceOpacity = 0.16
    static let tableInnerRingOpacity = 0.38
    static let tableRailHighlightOpacity = 0.42
    static let tableRailInnerBevelOpacity = 0.28
    static let tableRailShadowOpacity = 0.24
    static let tableRailShadowRadius = 6
    static let tablePlayAreaShadowOpacity = 0.16
    static let southHandRailBackgroundOpacity = 0.14
    static let southHandRailStrokeOpacity = 0.36
    static let stationBackgroundDefaultOpacity = 0.08
    static let stationBackgroundActiveOpacity = 0.24
    static let bidTurnPillBackgroundOpacity = 0.22
    static let bidCellDefaultBackgroundOpacity = 0.06
    static let bidCellActiveBackgroundOpacity = 0.10
    static let bidCellHighestBackgroundOpacity = 0.14
    static let bidActionTrayBackgroundOpacity = 0.10
    static let phaseStatusBackgroundOpacity = 0.72
    static let statusPillBorderOpacity = 0.55
    static let bottomControlSeparatorOpacity = 0.35
}

struct GameTypography {
    static let tableTitleFontName = "SF Arabic Rounded Bold"
    static let tableTitleFontSize = 26
    static let tableTitleTrackingRange = 2...4
}

struct UndealtDeckLayout {
    static let anchor = UnitPoint(x: 0.5, y: 0.5)
    static let centerOffset = CGSize(width: 0, height: 0)
    static let stackRotation = 0.0
    static let stackOffset = CGSize(width: 0, height: 0)
    static let minimumEdgeBuffer = 12
}

struct DealAnimationTiming {
    static let stackFlightDuration = 0.36
    static let stationExpandDuration = 0.16
    static let stepPauseDuration = 0.06
    static let southRevealTotalDuration = 1.5
    static let southRevealFlipDuration = 0.18
    static let southRevealFlipStagger = 0.11
}

struct TrickAnimationTiming {
    static let playedCardFlightDuration = 0.30
}

struct BidAnimationTiming {
    static let simulatedTurnDelay = 1.0
    static let valueFadeOutDuration = 0.5
    static let valueFadeInDuration = 0.5
    static let areaFadeOutDuration = 1.0
}

struct BidAreaLayout {
    static let padding = 12
    static let tableRowGap = 6
    static let cornerRadius = 10
    static let selectorHeight = 36
    static let selectorMinimumWidth = 82
    static let suitSelectorHeight = 36
    static let suitSelectorMinimumWidth = 132
    static let suitSelectorOptionMinimumWidth = 36
    static let suitSelectorOptionGap = 4
    static let bidButtonHeight = 36
    static let bidButtonMinimumWidth = 56
    static let postBiddingSummaryPadding = 12
    static let postBiddingSummaryRowGap = 6
    static let postBiddingSummaryCornerRadius = 10
}
```

---

# Visual Style Summary

## Overall Style

- Dark casino-inspired environment
- Bright readable cards
- Minimal neon or glow effects
- High readability during long play sessions
- Strong separation between gameplay actions and background elements

## Preferred UI Feel

- Professional card table
- Slightly modernized casino aesthetic
- Clean typography
- Calm visual hierarchy
