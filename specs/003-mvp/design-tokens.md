# Tarneeb Game Design Tokens

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
| `color.card.background` | `#FDFDFB` | Face-up card background |
| `color.card.border` | `#D7D7D2` | Card border |
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
| `color.station.outline.active` | `#FFFFFF` | Active player highlight |
| `color.station.outline.inactive` | `#FFFFFF66` | Dimmed inactive player station |

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

### Rationale

The condensed heavy title treatment keeps the brand mark readable inside the circular table while avoiding a large page-level heading. Tracking should stay within `+2` to `+4` so the title feels intentional without becoming loose or decorative.

### Shadow Usage

- The title shadow is part of the specified title style.
- The shadow should be subtle and only improve readability against the table surface or overlapping card stack.
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
- The card table title should remain readable against the table surface with the specified subtle shadow.

---

# Layout Recommendations

## Card Spacing

- Standard card gap: `8pt`
- Player station padding: `16pt`
- Primary action button height: `52pt`
- Corner radius for controls: `14pt`

---

# Suggested SwiftUI Token Structure

```swift
struct GameColors {
    static let tableGreen = Color(hex: "#1E5A3C")
    static let tableGreenDark = Color(hex: "#17452E")

    static let suitRed = Color(hex: "#C62828")
    static let suitBlack = Color(hex: "#1A1A1A")

    static let stationOutline = Color(hex: "#F5F5F5")
    static let tableTitle = Color(hex: "#E8DFC8").opacity(0.92)
    static let tableTitleShadow = Color.black.opacity(0.25)

    static let dealBlue = Color(hex: "#1976D2")
    static let newGameAmber = Color(hex: "#FFB300")
}

struct GameTypography {
    static let tableTitleFontName = "SF Arabic Rounded Bold"
    static let tableTitleFontSize = 26
    static let tableTitleTrackingRange = 2...4
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
