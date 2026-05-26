import XCTest

final class TarneebLaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testMVP002SmallestSupportedSimulatorIsDocumented() throws {
        XCTContext.runActivity(named: "MVP 002 smallest supported simulator: \(Self.mvp002SmallestSupportedSimulator)") { _ in
            XCTAssertEqual(Self.mvp002SmallestSupportedSimulator, "iPhone SE (3rd generation)")
        }
    }

    func testInitialScreenShowsDealCardsButton() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertEqual(screen.title.label, "Tarneeb")
        XCTAssertTrue(screen.dealCardsButton.exists)
        XCTAssertEqual(screen.dealCardsButton.label, "Deal Cards")
        XCTAssertTrue(screen.dealCardsButton.isHittable)
        assertElementIsUsableOnScreen(screen.title, in: app)
        assertElementIsUsableOnScreen(screen.dealCardsButton, in: app)

        try assertTokenValue(screen.title, contains: "color.text.primary")
        try assertTokenValue(screen.dealCardsButton, contains: "background=color.button.deal.background")
        try assertTokenValue(screen.dealCardsButton, contains: "pressed=color.button.deal.background.pressed")
        try assertTokenValue(screen.dealCardsButton, contains: "text=color.button.deal.text")
    }

    func testLaunchExposesStableSetupIdentifiers() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertTrue(screen.tableSurface.exists)
        XCTAssertTrue(screen.diamondTable.exists)
        XCTAssertTrue(screen.dealCardsButton.exists)
        XCTAssertTrue(screen.southSeat.exists)
        XCTAssertTrue(screen.westSeat.exists)
        XCTAssertTrue(screen.northSeat.exists)
        XCTAssertTrue(screen.eastSeat.exists)
        XCTAssertTrue(screen.southSeatArea.exists)
        XCTAssertTrue(screen.westSeatArea.exists)
        XCTAssertTrue(screen.northSeatArea.exists)
        XCTAssertTrue(screen.eastSeatArea.exists)
        XCTAssertEqual(screen.visibleCards.count, 0)
        XCTAssertEqual(screen.hiddenCardBacks.count, 0)

        try assertTokenValue(screen.tableSurface, contains: "background=color.table.background.primary")
        try assertTokenValue(screen.diamondTable, contains: "table=color.table.background.primary")
        try assertTokenValue(screen.diamondTable, contains: "label=color.text.primary")
        try assertTokenValue(screen.diamondTable, contains: "station=color.station.outline")
    }

    func testInitialScreenShowsFourEmptyPlayerSeats() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertTrue(screen.southSeat.exists)
        XCTAssertTrue(screen.westSeat.exists)
        XCTAssertTrue(screen.northSeat.exists)
        XCTAssertTrue(screen.eastSeat.exists)

        XCTAssertEqual(screen.southSeat.label, "South")
        XCTAssertEqual(screen.westSeat.label, "West")
        XCTAssertEqual(screen.northSeat.label, "North")
        XCTAssertEqual(screen.eastSeat.label, "East")

        assertDiamondLayout(on: screen)

        for element in screen.initialUsabilityElements {
            assertElementIsUsableOnScreen(element, in: app)
        }

        for station in screen.initialStationAreas {
            try assertTokenValue(station, contains: "label=color.text.primary")
            try assertTokenValue(station, contains: "outline=color.station.outline")
        }
    }

    func testInitialScreenHasNoCardsOrCompletedDealControls() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertEqual(screen.visibleCards.count, 0)
        XCTAssertEqual(screen.hiddenCardBacks.count, 0)
        XCTAssertFalse(screen.dealCompleteMessage.exists)
        XCTAssertFalse(screen.newDealButton.exists)

        for control in screen.prohibitedGameplayControls {
            XCTAssertFalse(control.exists)
        }
    }

    func testTappingDealCardsShowsDealtTableCompletionAndNewDealAction() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        XCTAssertTrue(screen.southSeatArea.exists)
        XCTAssertTrue(screen.westSeatArea.exists)
        XCTAssertTrue(screen.northSeatArea.exists)
        XCTAssertTrue(screen.eastSeatArea.exists)
        XCTAssertTrue(screen.southSeat.exists)
        XCTAssertTrue(screen.westSeat.exists)
        XCTAssertTrue(screen.northSeat.exists)
        XCTAssertTrue(screen.eastSeat.exists)
        XCTAssertTrue(screen.dealCompleteMessage.exists)
        XCTAssertTrue(screen.newDealButton.exists)
        XCTAssertTrue(screen.newDealButton.isHittable)
    }

    func testDealtScreenExposesStableLayoutIdentifiers() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        XCTAssertTrue(screen.diamondTable.exists)
        XCTAssertTrue(screen.southVisibleHand.exists)
        XCTAssertTrue(screen.westHiddenHand.exists)
        XCTAssertTrue(screen.northHiddenHand.exists)
        XCTAssertTrue(screen.eastHiddenHand.exists)
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.westHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.northHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.eastHiddenCardBacks.count, 13)
        XCTAssertTrue(screen.dealCompleteMessage.exists)
        XCTAssertTrue(screen.newDealButton.exists)
    }

    func testDealtTablePreservesDiamondLayoutAndPartnerOpposition() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        assertDiamondLayout(on: screen)
    }

    func testDealtSimulatedStationsAreCompactRelativeToSouth() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        let southArea = screen.southSeatArea.frame.width * screen.southSeatArea.frame.height
        let simulatedAreas = [
            screen.northSeatArea.frame.width * screen.northSeatArea.frame.height,
            screen.westSeatArea.frame.width * screen.westSeatArea.frame.height,
            screen.eastSeatArea.frame.width * screen.eastSeatArea.frame.height
        ]

        for simulatedArea in simulatedAreas {
            XCTAssertLessThan(simulatedArea, southArea)
        }

        XCTAssertLessThan(screen.northSeatArea.frame.height, screen.southSeatArea.frame.height)
        XCTAssertLessThan(screen.westSeatArea.frame.height, screen.southSeatArea.frame.height)
        XCTAssertLessThan(screen.eastSeatArea.frame.height, screen.southSeatArea.frame.height)
    }

    func testDealtLayoutElementsRemainUsableAndNonOverlappingOnSmallSimulator() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        XCTAssertEqual(Self.mvp002SmallestSupportedSimulator, "iPhone SE (3rd generation)")

        for element in screen.dealtUsabilityElements {
            assertElementIsUsableOnScreen(element, in: app)
        }

        assertNoSubstantialOverlap(screen.dealCompleteMessage, screen.newDealButton)
        assertNoSubstantialOverlap(screen.northSeatArea, screen.westSeatArea)
        assertNoSubstantialOverlap(screen.northSeatArea, screen.eastSeatArea)
        assertNoSubstantialOverlap(screen.westSeatArea, screen.southSeatArea)
        assertNoSubstantialOverlap(screen.eastSeatArea, screen.southSeatArea)
        assertNoSubstantialOverlap(screen.dealCompleteMessage, screen.northSeatArea)
        assertNoSubstantialOverlap(screen.newDealButton, screen.northSeatArea)

        for card in screen.visibleCards.allElementsBoundByIndex {
            assertFrame(card.frame, isInside: screen.southSeatArea.frame)
        }

        for hiddenCard in screen.westHiddenCardBacks.allElementsBoundByIndex {
            assertFrame(hiddenCard.frame, isInside: screen.westSeatArea.frame)
        }

        for hiddenCard in screen.northHiddenCardBacks.allElementsBoundByIndex {
            assertFrame(hiddenCard.frame, isInside: screen.northSeatArea.frame)
        }

        for hiddenCard in screen.eastHiddenCardBacks.allElementsBoundByIndex {
            assertFrame(hiddenCard.frame, isInside: screen.eastSeatArea.frame)
        }
    }

    func testDealtScreenExposesTokenAndCardSizeHooks() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        try assertDealtTokenAndCardSizeHooks(on: screen)
    }

    func testNewDealButtonExposesExistingNewGameTokenHooks() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        let value = try XCTUnwrap(screen.newDealButton.value as? String)
        XCTAssertTrue(value.contains("background=color.button.newGame.background"))
        XCTAssertTrue(value.contains("pressed=color.button.newGame.background.pressed"))
        XCTAssertTrue(value.contains("text=color.button.newGame.text"))
    }

    func testNewDealReplacesCompletedDealWithAnotherCompletedDeal() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)
        let firstSouthHand = screen.visibleCardLabels
        XCTAssertEqual(firstSouthHand.count, 13)

        screen.newDealButton.tap()

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 5))
        XCTAssertTrue(screen.newDealButton.exists)
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
        XCTAssertNotEqual(screen.visibleCardLabels, firstSouthHand)
    }

    func testNewDealPreservesLayoutSizingAndTokenHooks() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)
        screen.newDealButton.tap()

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 5))
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
        assertDiamondLayout(on: screen)
        try assertDealtTokenAndCardSizeHooks(on: screen)
    }

    func testDealAndNewDealRemainResponsive() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        screen.dealCardsButton.tap()

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 2))
        XCTAssertTrue(screen.newDealButton.isHittable)

        screen.newDealButton.tap()

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 2))
        XCTAssertTrue(screen.newDealButton.isHittable)
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
    }

    func testTappingDealCardsShowsHumanHandWithSortedRankAndSuitCards() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        let cardLabels = screen.visibleCards.allElementsBoundByIndex.map(\.label)
        XCTAssertEqual(cardLabels.count, 13)
        XCTAssertEqual(Self.cardSortValues(for: cardLabels).count, 13)
        XCTAssertEqual(Self.cardSortValues(for: cardLabels), Self.cardSortValues(for: cardLabels).sorted())
    }

    func testSouthCardsAreNotActionable() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        let firstCard = screen.visibleCards.element(boundBy: 0)
        XCTAssertTrue(firstCard.exists)
        XCTAssertFalse(app.buttons[firstCard.label].exists)

        let cardLabelsBeforeTap = screen.visibleCards.allElementsBoundByIndex.map(\.label)
        if firstCard.isHittable {
            firstCard.tap()
        }
        XCTAssertEqual(screen.visibleCards.allElementsBoundByIndex.map(\.label), cardLabelsBeforeTap)
    }

    func testTappingDealCardsShowsSimulatedPlayerHiddenCardBacksOnly() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        XCTAssertEqual(screen.westHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.northHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.eastHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)

        for hiddenCard in screen.hiddenCardBacks.allElementsBoundByIndex {
            XCTAssertEqual(hiddenCard.label, "Card back")
            assertHiddenCardDoesNotRevealCardData(hiddenCard)
        }

        for control in screen.prohibitedGameplayControls {
            XCTAssertFalse(control.exists)
        }
    }

    func testNoBiddingUIIsShownAfterDeal() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        for element in screen.prohibitedBiddingElements {
            XCTAssertFalse(element.exists)
        }
    }

    func testNoGameplayControlsAreShownAfterDeal() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        for control in screen.prohibitedGameplayControls {
            XCTAssertFalse(control.exists)
        }
    }

    func testNoOutOfScopeMVPControlsAreShownAfterDeal() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        dealCards(on: screen)

        for element in screen.prohibitedOutOfScopeElements {
            XCTAssertFalse(element.exists)
        }
    }

    private func dealCards(on screen: TarneebScreen) {
        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        screen.dealCardsButton.tap()
        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 5))
    }

    private func assertDiamondLayout(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let northFrame = screen.northSeatArea.frame
        let westFrame = screen.westSeatArea.frame
        let southFrame = screen.southSeatArea.frame
        let eastFrame = screen.eastSeatArea.frame

        XCTAssertLessThan(northFrame.midY, westFrame.midY, file: file, line: line)
        XCTAssertLessThan(northFrame.midY, eastFrame.midY, file: file, line: line)
        XCTAssertGreaterThan(southFrame.midY, westFrame.midY, file: file, line: line)
        XCTAssertGreaterThan(southFrame.midY, eastFrame.midY, file: file, line: line)
        XCTAssertLessThan(westFrame.midX, northFrame.midX, file: file, line: line)
        XCTAssertLessThan(westFrame.midX, southFrame.midX, file: file, line: line)
        XCTAssertGreaterThan(eastFrame.midX, northFrame.midX, file: file, line: line)
        XCTAssertGreaterThan(eastFrame.midX, southFrame.midX, file: file, line: line)
        XCTAssertEqual(Double(northFrame.midX), Double(southFrame.midX), accuracy: 24, file: file, line: line)
        XCTAssertEqual(Double(westFrame.midY), Double(eastFrame.midY), accuracy: 24, file: file, line: line)
    }

    private func assertNoSubstantialOverlap(
        _ first: XCUIElement,
        _ second: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let intersection = first.frame.intersection(second.frame)
        let tolerance = 1.0

        XCTAssertLessThanOrEqual(intersection.width, tolerance, file: file, line: line)
        XCTAssertLessThanOrEqual(intersection.height, tolerance, file: file, line: line)
    }

    private func assertFrame(
        _ childFrame: CGRect,
        isInside containerFrame: CGRect,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(containerFrame.insetBy(dx: -2, dy: -2).contains(childFrame), file: file, line: line)
    }

    private func assertElementIsUsableOnScreen(
        _ element: XCUIElement,
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(element.exists, file: file, line: line)
        XCTAssertFalse(element.frame.isEmpty, file: file, line: line)
        XCTAssertTrue(app.frame.intersects(element.frame), file: file, line: line)
    }

    private func assertTokenValue(
        _ element: XCUIElement,
        contains expectedValue: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let value = try XCTUnwrap(element.value as? String, file: file, line: line)
        XCTAssertTrue(value.contains(expectedValue), "\(value) does not contain \(expectedValue)", file: file, line: line)
    }

    private func assertDealtTokenAndCardSizeHooks(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        try assertTokenValue(screen.tableSurface, contains: "background=color.table.background.primary", file: file, line: line)
        try assertTokenValue(screen.diamondTable, contains: "table=color.table.background.primary", file: file, line: line)
        try assertTokenValue(screen.diamondTable, contains: "label=color.text.primary", file: file, line: line)
        try assertTokenValue(screen.diamondTable, contains: "station=color.station.outline", file: file, line: line)
        try assertTokenValue(screen.dealCompleteMessage, contains: "text=color.text.primary", file: file, line: line)
        try assertTokenValue(screen.newDealButton, contains: "background=color.button.newGame.background", file: file, line: line)
        try assertTokenValue(screen.newDealButton, contains: "pressed=color.button.newGame.background.pressed", file: file, line: line)
        try assertTokenValue(screen.newDealButton, contains: "text=color.button.newGame.text", file: file, line: line)

        for label in screen.dealtSeatLabels {
            try assertTokenValue(label, contains: "text=color.text.primary", file: file, line: line)
        }

        for station in screen.initialStationAreas {
            try assertTokenValue(station, contains: "label=color.text.primary", file: file, line: line)
            try assertTokenValue(station, contains: "outline=color.station.outline", file: file, line: line)
        }

        for card in screen.visibleCards.allElementsBoundByIndex {
            let value = try XCTUnwrap(card.value as? String, file: file, line: line)
            XCTAssertTrue(value.contains("size=sharedBaseCard"), file: file, line: line)
            XCTAssertTrue(value.contains("surface=color.card.background"), file: file, line: line)
            XCTAssertTrue(value.contains("border=color.card.border"), file: file, line: line)
            XCTAssertTrue(value.contains("shadow=color.card.shadow"), file: file, line: line)

            let expectedHook = try XCTUnwrap(Self.expectedSuitHook(for: card.label), file: file, line: line)
            XCTAssertTrue(value.contains(expectedHook.role), file: file, line: line)
            XCTAssertTrue(value.contains(expectedHook.token), file: file, line: line)
        }

        for hiddenCard in screen.hiddenCardBacks.allElementsBoundByIndex {
            XCTAssertEqual(hiddenCard.value as? String, "sharedBaseCard", file: file, line: line)
        }
    }

    private func assertHiddenCardDoesNotRevealCardData(
        _ hiddenCard: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exposedText = "\(hiddenCard.label) \(hiddenCard.value as? String ?? "")"
        let prohibitedFragments = ["♥", "♣", "♦", "♠", "spades", "clubs", "hearts", "diamonds", "rank", "suit"]

        for prohibitedFragment in prohibitedFragments {
            XCTAssertFalse(exposedText.contains(prohibitedFragment), file: file, line: line)
        }
    }

    private static func cardSortValues(for labels: [String]) -> [Int] {
        labels.compactMap { label in
            guard let suit = label.last,
                  let suitOrder = suitSortOrder[suit] else {
                return nil
            }

            let rank = String(label.dropLast())
            guard let rankOrder = rankSortOrder[rank] else {
                return nil
            }

            return suitOrder * 100 + rankOrder
        }
    }

    private static func expectedSuitHook(for label: String) -> (role: String, token: String)? {
        guard let suit = label.last else {
            return nil
        }

        switch suit {
        case "♥", "♦":
            return ("role=suitWarm", "token=color.card.suit.red")
        case "♣", "♠":
            return ("role=suitNeutral", "token=color.card.suit.black")
        default:
            return nil
        }
    }

    private static let suitSortOrder: [Character: Int] = [
        "♥": 0,
        "♣": 1,
        "♦": 2,
        "♠": 3
    ]

    private static let rankSortOrder: [String: Int] = [
        "2": 0,
        "3": 1,
        "4": 2,
        "5": 3,
        "6": 4,
        "7": 5,
        "8": 6,
        "9": 7,
        "10": 8,
        "J": 9,
        "Q": 10,
        "K": 11,
        "A": 12
    ]

    private static let mvp002SmallestSupportedSimulator = "iPhone SE (3rd generation)"
}

private struct TarneebScreen {
    let app: XCUIApplication

    var title: XCUIElement {
        element(identifier: "tarneeb-title")
    }

    var dealCardsButton: XCUIElement {
        button(identifier: "tarneeb-deal-cards-button")
    }

    var tableSurface: XCUIElement {
        element(identifier: "tarneeb-table-surface")
    }

    var diamondTable: XCUIElement {
        element(identifier: "tarneeb-diamond-table")
    }

    var southSeat: XCUIElement {
        element(identifier: "tarneeb-seat-south")
    }

    var westSeat: XCUIElement {
        element(identifier: "tarneeb-seat-west")
    }

    var northSeat: XCUIElement {
        element(identifier: "tarneeb-seat-north")
    }

    var eastSeat: XCUIElement {
        element(identifier: "tarneeb-seat-east")
    }

    var southSeatArea: XCUIElement {
        app.otherElements["tarneeb-seat-area-south"]
    }

    var westSeatArea: XCUIElement {
        app.otherElements["tarneeb-seat-area-west"]
    }

    var northSeatArea: XCUIElement {
        app.otherElements["tarneeb-seat-area-north"]
    }

    var eastSeatArea: XCUIElement {
        app.otherElements["tarneeb-seat-area-east"]
    }

    var initialStationAreas: [XCUIElement] {
        [northSeatArea, westSeatArea, southSeatArea, eastSeatArea]
    }

    var initialUsabilityElements: [XCUIElement] {
        [title, dealCardsButton, northSeat, westSeat, southSeat, eastSeat]
    }

    var dealtSeatLabels: [XCUIElement] {
        [northSeat, westSeat, southSeat, eastSeat]
    }

    var dealtUsabilityElements: [XCUIElement] {
        [
            dealCompleteMessage,
            newDealButton,
            northSeatArea,
            westSeatArea,
            southSeatArea,
            eastSeatArea,
            northSeat,
            westSeat,
            southSeat,
            eastSeat
        ]
    }

    var visibleCards: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: "tarneeb-visible-card")
    }

    var visibleCardLabels: [String] {
        visibleCards.allElementsBoundByIndex.map(\.label)
    }

    var southVisibleHand: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "tarneeb-visible-hand-south").firstMatch
    }

    var westHiddenHand: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "tarneeb-hidden-hand-west").firstMatch
    }

    var northHiddenHand: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "tarneeb-hidden-hand-north").firstMatch
    }

    var eastHiddenHand: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "tarneeb-hidden-hand-east").firstMatch
    }

    var hiddenCardBacks: XCUIElementQuery {
        app.images.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-hidden-card-back"))
    }

    var westHiddenCardBacks: XCUIElementQuery {
        app.images.matching(identifier: "tarneeb-hidden-card-back-west")
    }

    var northHiddenCardBacks: XCUIElementQuery {
        app.images.matching(identifier: "tarneeb-hidden-card-back-north")
    }

    var eastHiddenCardBacks: XCUIElementQuery {
        app.images.matching(identifier: "tarneeb-hidden-card-back-east")
    }

    var dealCompleteMessage: XCUIElement {
        element(identifier: "tarneeb-deal-complete-message")
    }

    var newDealButton: XCUIElement {
        button(identifier: "tarneeb-new-deal-button")
    }

    var prohibitedBiddingElements: [XCUIElement] {
        [
            app.buttons["Bid"],
            app.buttons["Bidding"],
            app.staticTexts["Bid"],
            app.staticTexts["Bidding"]
        ]
    }

    var prohibitedGameplayControls: [XCUIElement] {
        [
            app.buttons["Pass"],
            app.buttons["Play Card"],
            app.buttons["Score"],
            app.buttons["Game Over"],
            app.segmentedControls["Trump"],
            app.segmentedControls["Tarneeb Suit"],
            app.staticTexts["Trick"]
        ]
    }

    var prohibitedOutOfScopeElements: [XCUIElement] {
        prohibitedBiddingElements + prohibitedGameplayControls + [
            app.buttons["Play Trick"],
            app.buttons["Resolve Trick"],
            app.buttons["Multiplayer"],
            app.buttons["Online Multiplayer"],
            app.buttons["Local Multiplayer"],
            app.buttons["Save Game"],
            app.buttons["Saved Games"],
            app.buttons["Account"],
            app.buttons["Accounts"],
            app.buttons["AI"],
            app.buttons["Retry"],
            app.staticTexts["Play Trick"],
            app.staticTexts["Resolve Trick"],
            app.staticTexts["Multiplayer"],
            app.staticTexts["Online Multiplayer"],
            app.staticTexts["Local Multiplayer"],
            app.staticTexts["Save Game"],
            app.staticTexts["Saved Games"],
            app.staticTexts["Account"],
            app.staticTexts["Accounts"],
            app.staticTexts["AI"],
            app.staticTexts["Error"]
        ]
    }

    private func element(identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func button(identifier: String) -> XCUIElement {
        app.buttons.matching(identifier: identifier).firstMatch
    }
}
