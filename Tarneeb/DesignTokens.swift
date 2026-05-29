enum GameColorToken: String, CaseIterable, Equatable, Hashable {
    case tableBackgroundPrimary = "color.table.background.primary"
    case tableBackgroundSecondary = "color.table.background.secondary"
    case tableFeltHighlight = "color.table.felt.highlight"
    case cardBackground = "color.card.background"
    case cardBorder = "color.card.border"
    case cardShadow = "color.card.shadow"
    case cardSuitRed = "color.card.suit.red"
    case cardSuitRedDark = "color.card.suit.red.dark"
    case cardSuitBlack = "color.card.suit.black"
    case cardSuitBlackSoft = "color.card.suit.black.soft"
    case stationOutline = "color.station.outline"
    case stationOutlineActive = "color.station.outline.active"
    case stationOutlineInactive = "color.station.outline.inactive"
    case textPrimary = "color.text.primary"
    case textSecondary = "color.text.secondary"
    case textDisabled = "color.text.disabled"
    case textWarning = "color.text.warning"
    case tableTitleText = "color.tableTitle.text"
    case tableTitleShadow = "effect.tableTitle.shadow.color"
    case buttonDealBackground = "color.button.deal.background"
    case buttonDealBackgroundPressed = "color.button.deal.background.pressed"
    case buttonDealText = "color.button.deal.text"
    case buttonNewGameBackground = "color.button.newGame.background"
    case buttonNewGameBackgroundPressed = "color.button.newGame.background.pressed"
    case buttonNewGameText = "color.button.newGame.text"
    case buttonDestructiveBackground = "color.button.destructive.background"
    case buttonDestructiveText = "color.button.destructive.text"

    var hexValue: String {
        switch self {
        case .tableBackgroundPrimary:
            return "#1E5A3C"
        case .tableBackgroundSecondary:
            return "#17452E"
        case .tableFeltHighlight:
            return "#2B7A52"
        case .cardBackground:
            return "#FDFDFB"
        case .cardBorder:
            return "#D7D7D2"
        case .cardShadow:
            return "#00000022"
        case .cardSuitRed:
            return "#C62828"
        case .cardSuitRedDark:
            return "#8E1B1B"
        case .cardSuitBlack:
            return "#1A1A1A"
        case .cardSuitBlackSoft:
            return "#2E2E2E"
        case .stationOutline:
            return "#F5F5F5"
        case .stationOutlineActive:
            return "#FFFFFF"
        case .stationOutlineInactive:
            return "#FFFFFF66"
        case .textPrimary:
            return "#FFFFFF"
        case .textSecondary:
            return "#D9D9D9"
        case .textDisabled:
            return "#FFFFFF66"
        case .textWarning:
            return "#FFD166"
        case .tableTitleText:
            return "#E8DFC8"
        case .tableTitleShadow:
            return "#000000"
        case .buttonDealBackground:
            return "#1976D2"
        case .buttonDealBackgroundPressed:
            return "#1257A0"
        case .buttonDealText:
            return "#FFFFFF"
        case .buttonNewGameBackground:
            return "#FFB300"
        case .buttonNewGameBackgroundPressed:
            return "#CC8A00"
        case .buttonNewGameText:
            return "#1A1A1A"
        case .buttonDestructiveBackground:
            return "#B71C1C"
        case .buttonDestructiveText:
            return "#FFFFFF"
        }
    }
}

enum GameColorRole: String, CaseIterable, Equatable, Hashable {
    case tableSurface
    case tableSurfaceSecondary
    case tableHighlight
    case cardFace
    case cardBorder
    case cardShadow
    case suitWarm
    case suitWarmEmphasis
    case suitNeutral
    case suitNeutralSecondary
    case stationOutline
    case stationOutlineActive
    case stationOutlineInactive
    case textPrimary
    case textSecondary
    case textDisabled
    case textWarning
    case tableTitleText
    case tableTitleShadow
    case dealActionBackground
    case dealActionPressedBackground
    case dealActionText
    case newDealActionBackground
    case newDealActionPressedBackground
    case newDealActionText

    var token: GameColorToken {
        switch self {
        case .tableSurface:
            return .tableBackgroundPrimary
        case .tableSurfaceSecondary:
            return .tableBackgroundSecondary
        case .tableHighlight:
            return .tableFeltHighlight
        case .cardFace:
            return .cardBackground
        case .cardBorder:
            return .cardBorder
        case .cardShadow:
            return .cardShadow
        case .suitWarm:
            return .cardSuitRed
        case .suitWarmEmphasis:
            return .cardSuitRedDark
        case .suitNeutral:
            return .cardSuitBlack
        case .suitNeutralSecondary:
            return .cardSuitBlackSoft
        case .stationOutline:
            return .stationOutline
        case .stationOutlineActive:
            return .stationOutlineActive
        case .stationOutlineInactive:
            return .stationOutlineInactive
        case .textPrimary:
            return .textPrimary
        case .textSecondary:
            return .textSecondary
        case .textDisabled:
            return .textDisabled
        case .textWarning:
            return .textWarning
        case .tableTitleText:
            return .tableTitleText
        case .tableTitleShadow:
            return .tableTitleShadow
        case .dealActionBackground:
            return .buttonDealBackground
        case .dealActionPressedBackground:
            return .buttonDealBackgroundPressed
        case .dealActionText:
            return .buttonDealText
        case .newDealActionBackground:
            return .buttonNewGameBackground
        case .newDealActionPressedBackground:
            return .buttonNewGameBackgroundPressed
        case .newDealActionText:
            return .buttonNewGameText
        }
    }
}

enum GameTypographyToken: String, CaseIterable, Equatable, Hashable {
    case tableTitleFont = "typography.tableTitle.font"
    case tableTitleFontSize = "typography.tableTitle.fontSize"
    case tableTitleTrackingMinimum = "typography.tableTitle.tracking.min"
    case tableTitleTrackingMaximum = "typography.tableTitle.tracking.max"

    var stringValue: String {
        switch self {
        case .tableTitleFont:
            return "SF Arabic Rounded Bold"
        case .tableTitleFontSize:
            return "26pt"
        case .tableTitleTrackingMinimum:
            return "+2"
        case .tableTitleTrackingMaximum:
            return "+4"
        }
    }

    var numericValue: Double? {
        switch self {
        case .tableTitleFont:
            return nil
        case .tableTitleFontSize:
            return 26
        case .tableTitleTrackingMinimum:
            return 2
        case .tableTitleTrackingMaximum:
            return 4
        }
    }
}

enum GameEffectToken: String, CaseIterable, Equatable, Hashable {
    case tableTitleTextOpacity = "effect.tableTitle.text.opacity"
    case tableTitleShadowOpacity = "effect.tableTitle.shadow.opacity"
    case tableTitleShadowBlurRadius = "effect.tableTitle.shadow.blurRadius"

    var value: Double {
        switch self {
        case .tableTitleTextOpacity:
            return 0.92
        case .tableTitleShadowOpacity:
            return 0.25
        case .tableTitleShadowBlurRadius:
            return 4
        }
    }
}

enum CardSizeCategory: String, CaseIterable, Equatable, Hashable {
    case sharedBaseCard
}

struct CardSizeConfiguration: Equatable {
    let category: CardSizeCategory
    let baseCardWidth: Double
    let baseCardHeight: Double
    let cornerRadius: Double
    let rankFontPointSize: Double
    let hiddenStackOffset: Double
    let deckStackOffset: Double

    static let sharedBase = CardSizeConfiguration(
        category: .sharedBaseCard,
        baseCardWidth: 36,
        baseCardHeight: 50.4,
        cornerRadius: 6,
        rankFontPointSize: 12,
        hiddenStackOffset: 2.5,
        deckStackOffset: 0
    )

    var aspectRatio: Double {
        baseCardWidth / baseCardHeight
    }

    func hiddenStackWidth(for count: Int) -> Double {
        guard count > 0 else {
            return 0
        }

        return baseCardWidth + hiddenStackOffset * Double(count - 1)
    }

    func deckStackWidth(for count: Int) -> Double {
        guard count > 0 else {
            return 0
        }

        return baseCardWidth + deckStackOffset * Double(count - 1)
    }
}

struct ButtonTokenSet: Equatable {
    let background: GameColorToken
    let pressedBackground: GameColorToken
    let text: GameColorToken

    static let deal = ButtonTokenSet(
        background: .buttonDealBackground,
        pressedBackground: .buttonDealBackgroundPressed,
        text: .buttonDealText
    )

    static let newGame = ButtonTokenSet(
        background: .buttonNewGameBackground,
        pressedBackground: .buttonNewGameBackgroundPressed,
        text: .buttonNewGameText
    )

    static let newDeal = newGame

    var accessibilityValue: String {
        "background=\(background.rawValue);pressed=\(pressedBackground.rawValue);text=\(text.rawValue)"
    }
}

struct TableTitlePresentation: Equatable {
    let text = "طرنيب"
    let fontToken = GameTypographyToken.tableTitleFont
    let fontSizeToken = GameTypographyToken.tableTitleFontSize
    let trackingMinimumToken = GameTypographyToken.tableTitleTrackingMinimum
    let trackingMaximumToken = GameTypographyToken.tableTitleTrackingMaximum
    let tracking: Double
    let textColorRole = GameColorRole.tableTitleText
    let textOpacityToken = GameEffectToken.tableTitleTextOpacity
    let shadowColorRole = GameColorRole.tableTitleShadow
    let shadowOpacityToken = GameEffectToken.tableTitleShadowOpacity
    let shadowBlurRadiusToken = GameEffectToken.tableTitleShadowBlurRadius
    let usesShadow: Bool

    init(
        tracking: Double = GameTypographyToken.tableTitleTrackingMinimum.numericValue ?? 2,
        usesShadow: Bool = true
    ) {
        let minimumTracking = GameTypographyToken.tableTitleTrackingMinimum.numericValue ?? tracking
        let maximumTracking = GameTypographyToken.tableTitleTrackingMaximum.numericValue ?? tracking
        self.tracking = min(max(tracking, minimumTracking), maximumTracking)
        self.usesShadow = usesShadow
    }

    var fontPointSize: Double {
        fontSizeToken.numericValue ?? 26
    }

    var accessibilityValue: String {
        [
            "font=\(fontToken.rawValue)",
            "fontName=\(fontToken.stringValue)",
            "fontSize=\(fontSizeToken.rawValue)",
            "pointSize=\(fontPointSize)",
            "tracking=\(tracking)",
            "trackingMin=\(trackingMinimumToken.rawValue)",
            "trackingMax=\(trackingMaximumToken.rawValue)",
            "textColor=\(textColorRole.token.rawValue)",
            "textOpacity=\(textOpacityToken.rawValue)",
            "textOpacityValue=\(textOpacityToken.value)",
            "shadowColor=\(shadowColorRole.token.rawValue)",
            "usesShadow=\(usesShadow)",
            "shadowOpacity=\(shadowOpacityToken.rawValue)",
            "shadowOpacityValue=\(shadowOpacityToken.value)",
            "shadowBlur=\(shadowBlurRadiusToken.rawValue)"
        ].joined(separator: ";")
    }
}

struct CardPresentation: Equatable {
    let cardID: String
    let displayLabel: String
    let rankText: String
    let suitSymbol: String
    let suitColorRole: GameColorRole
    let suitColorToken: GameColorToken
    let sortKey: Int
    let accessibilityLabel: String
    let sizeConfiguration: CardSizeConfiguration

    init(card: Card, sizeConfiguration: CardSizeConfiguration = .sharedBase) {
        self.cardID = card.id
        self.rankText = card.rank.displayLabel
        self.suitSymbol = card.suit.displaySymbol
        self.displayLabel = "\(card.rank.displayLabel)\(card.suit.displaySymbol)"
        self.suitColorRole = card.suit.colorRole
        self.suitColorToken = card.suit.colorToken
        self.sortKey = card.southHandSortKey
        self.accessibilityLabel = displayLabel
        self.sizeConfiguration = sizeConfiguration
    }

    var sizeCategory: CardSizeCategory {
        sizeConfiguration.category
    }

    var accessibilityValue: String {
        "role=\(suitColorRole.rawValue);token=\(suitColorToken.rawValue);size=\(sizeCategory.rawValue);surface=\(GameColorRole.cardFace.token.rawValue);border=\(GameColorRole.cardBorder.token.rawValue);shadow=\(GameColorRole.cardShadow.token.rawValue)"
    }
}

struct HiddenCardBackPresentation: Equatable, Identifiable {
    let index: Int
    let sizeConfiguration: CardSizeConfiguration

    var id: String {
        "hidden-card-back-\(index)"
    }

    var assetName: String {
        "card_back"
    }

    var accessibilityLabel: String {
        "Card back"
    }

    var accessibilityValue: String {
        sizeConfiguration.category.rawValue
    }
}

struct HiddenHandPresentation: Equatable {
    let seat: Seat
    let hiddenCards: [HiddenCardBackPresentation]
    let sizeConfiguration: CardSizeConfiguration

    init(
        seat: Seat,
        hiddenCardCount: Int,
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) {
        self.seat = seat
        self.hiddenCards = (0..<hiddenCardCount).map { index in
            HiddenCardBackPresentation(index: index, sizeConfiguration: sizeConfiguration)
        }
        self.sizeConfiguration = sizeConfiguration
    }

    var hiddenCardCount: Int {
        hiddenCards.count
    }

    var stackOffset: Double {
        sizeConfiguration.hiddenStackOffset
    }

    var stackWidth: Double {
        sizeConfiguration.hiddenStackWidth(for: hiddenCardCount)
    }
}

struct CentralDeckStackPresentation: Equatable {
    let hiddenCards: [HiddenCardBackPresentation]
    let sizeConfiguration: CardSizeConfiguration
    let isVisible: Bool

    init(
        phase: GamePhase,
        hiddenCardCount: Int = 52,
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) {
        self.isVisible = phase == .notStarted
        self.sizeConfiguration = sizeConfiguration
        self.hiddenCards = isVisible
            ? (0..<hiddenCardCount).map { index in
                HiddenCardBackPresentation(index: index, sizeConfiguration: sizeConfiguration)
            }
            : []
    }

    var hiddenCardCount: Int {
        hiddenCards.count
    }

    var stackOffset: Double {
        sizeConfiguration.deckStackOffset
    }

    var stackWidth: Double {
        sizeConfiguration.deckStackWidth(for: hiddenCardCount)
    }

    var verticalOffset: Double {
        sizeConfiguration.baseCardHeight * (11.0 / 12.0)
    }

    var accessibilityValue: String {
        "count=\(hiddenCardCount);asset=card_back;hidden=true;layout=stacked;placement=belowTitle;stackOffset=\(stackOffset);verticalOffset=\(verticalOffset);rotation=0;size=\(sizeConfiguration.category.rawValue)"
    }
}

enum SouthHandPresentation {
    static func sortedCards(from cards: [Card]) -> [Card] {
        cards.sorted { lhs, rhs in
            if lhs.suit.southDisplayOrder != rhs.suit.southDisplayOrder {
                return lhs.suit.southDisplayOrder < rhs.suit.southDisplayOrder
            }

            return lhs.rank.displayOrder < rhs.rank.displayOrder
        }
    }

    static func cardPresentations(
        from cards: [Card],
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) -> [CardPresentation] {
        sortedCards(from: cards).map { card in
            CardPresentation(card: card, sizeConfiguration: sizeConfiguration)
        }
    }
}

extension Suit {
    var colorRole: GameColorRole {
        switch self {
        case .hearts, .diamonds:
            return .suitWarm
        case .clubs, .spades:
            return .suitNeutral
        }
    }

    var colorToken: GameColorToken {
        colorRole.token
    }

    var southDisplayOrder: Int {
        switch self {
        case .hearts:
            return 0
        case .clubs:
            return 1
        case .diamonds:
            return 2
        case .spades:
            return 3
        }
    }
}

extension Rank {
    var displayOrder: Int {
        Rank.allCases.firstIndex(of: self) ?? 0
    }
}

private extension Card {
    var southHandSortKey: Int {
        suit.southDisplayOrder * 100 + rank.displayOrder
    }
}
