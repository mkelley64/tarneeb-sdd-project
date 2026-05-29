import XCTest

final class TarneebLaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
    }

    func testMVP003SmallestSupportedSimulatorIsDocumented() throws {
        XCTContext.runActivity(named: "MVP 003 smallest supported simulator: \(Self.mvp003SmallestSupportedSimulator)") { _ in
            XCTAssertEqual(Self.mvp003SmallestSupportedSimulator, "iPhone SE (3rd generation)")
        }
    }

    func testInitialScreenShowsPortraitTableTitleDeckStackStationsAndBottomDeal() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertEqual(screen.title.label, "طرنيب")
        XCTAssertTrue(screen.tableSurface.exists)
        XCTAssertTrue(screen.tableScene.exists)
        XCTAssertTrue(screen.cardTable.exists)
        XCTAssertTrue(screen.centralDeckStack.exists)
        XCTAssertEqual(screen.deckStackCards.count, 52)
        XCTAssertTrue(screen.dealButton.exists)
        XCTAssertEqual(screen.dealButton.label, "Deal")
        XCTAssertTrue(screen.dealButton.isHittable)
        XCTAssertTrue(screen.newGameButton.exists)
        XCTAssertEqual(screen.newGameButton.label, "New Game")
        XCTAssertTrue(screen.newGameButton.isHittable)
        XCTAssertGreaterThan(app.frame.height, app.frame.width)

        XCTAssertEqual(screen.visibleCards.count, 0)
        XCTAssertEqual(screen.hiddenCardBacks.count, 0)
        XCTAssertFalse(screen.dealCompleteMessage.exists)
        XCTAssertFalse(screen.oldDealCardsButton.exists)
        XCTAssertFalse(screen.oldNewDealButton.exists)

        XCTAssertEqual(screen.southSeat.label, "South")
        XCTAssertEqual(screen.westSeat.label, "West")
        XCTAssertEqual(screen.northSeat.label, "North")
        XCTAssertEqual(screen.eastSeat.label, "East")

        assertTableDiameter(on: screen, in: app)
        assertTableTitleIsOnCardTable(on: screen)
        assertInitialDeckStackSitsBelowTitle(on: screen)
        assertStationsSurroundTable(on: screen)
        assertInitialStationsAreRoundedSquares(on: screen)
        assertBottomDealButtonIsAtBottom(on: screen, in: app)

        for element in screen.initialUsabilityElements {
            assertElementIsUsableOnScreen(element, in: app)
        }
    }

    func testInitialScreenExposesMVP003TokenAndLayoutHooks() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))

        try assertTokenValue(screen.tableSurface, contains: "background=color.table.background.primary")
        try assertTokenValue(screen.tableScene, contains: "table=color.table.background.primary")
        try assertTokenValue(screen.tableScene, contains: "label=color.text.primary")
        try assertTokenValue(screen.tableScene, contains: "station=color.station.outline")
        try assertTokenValue(screen.cardTable, contains: "shape=circle")
        try assertTokenValue(screen.cardTable, contains: "surface=color.table.background.secondary")
        try assertTokenValue(screen.title, contains: "font=typography.tableTitle.font")
        try assertTokenValue(screen.title, contains: "fontName=SF Arabic Rounded Bold")
        try assertTokenValue(screen.title, contains: "fontSize=typography.tableTitle.fontSize")
        try assertTokenValue(screen.title, contains: "pointSize=26.0")
        try assertTokenValue(screen.title, contains: "trackingMin=typography.tableTitle.tracking.min")
        try assertTokenValue(screen.title, contains: "trackingMax=typography.tableTitle.tracking.max")
        try assertTokenValue(screen.title, contains: "textColor=color.tableTitle.text")
        try assertTokenValue(screen.title, contains: "textOpacity=effect.tableTitle.text.opacity")
        try assertTokenValue(screen.title, contains: "textOpacityValue=0.92")
        try assertTokenValue(screen.title, contains: "shadowColor=effect.tableTitle.shadow.color")
        try assertTokenValue(screen.title, contains: "usesShadow=true")
        try assertTokenValue(screen.title, contains: "shadowOpacityValue=0.25")
        try assertTokenValue(screen.centralDeckStack, contains: "count=52")
        try assertTokenValue(screen.centralDeckStack, contains: "asset=card_back")
        try assertTokenValue(screen.centralDeckStack, contains: "layout=stacked")
        try assertTokenValue(screen.centralDeckStack, contains: "placement=belowTitle")
        try assertTokenValue(screen.centralDeckStack, contains: "stackOffset=0.0")
        try assertTokenValue(screen.centralDeckStack, contains: "verticalOffset=")
        try assertTokenValue(screen.centralDeckStack, contains: "rotation=0")
        try assertTokenValue(screen.dealButton, contains: "background=color.button.deal.background")
        try assertTokenValue(screen.dealButton, contains: "pressed=color.button.deal.background.pressed")
        try assertTokenValue(screen.dealButton, contains: "text=color.button.deal.text")
        try assertTokenValue(screen.newGameButton, contains: "background=color.button.newGame.background")
        try assertTokenValue(screen.newGameButton, contains: "pressed=color.button.newGame.background.pressed")
        try assertTokenValue(screen.newGameButton, contains: "text=color.button.newGame.text")

        for station in screen.stationAreas {
            try assertTokenValue(station, contains: "shape=roundedSquare")
            try assertTokenValue(station, contains: "label=color.text.primary")
            try assertTokenValue(station, contains: "outline=color.station.outline")
        }
    }

    func testAppRemainsPortraitWhenDeviceRotates() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(app.frame.height, app.frame.width)

        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(app.frame.height, app.frame.width)
    }

    func testTappingDealShowsDealtTableAndHidesCentralDeckStack() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        XCTAssertTrue(screen.cardTable.exists)
        XCTAssertFalse(screen.centralDeckStack.exists)
        XCTAssertEqual(screen.deckStackCards.count, 0)
        XCTAssertTrue(screen.southVisibleHand.exists)
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.westHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.northHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.eastHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
        XCTAssertTrue(screen.dealCompleteMessage.exists)
        XCTAssertTrue(screen.dealButton.exists)
        XCTAssertEqual(screen.dealButton.label, "Deal")
        XCTAssertTrue(screen.newGameButton.exists)
        XCTAssertEqual(screen.newGameButton.label, "New Game")

        assertStationsSurroundTable(on: screen)
        assertSouthStationExpandedBelowTable(on: screen)
        assertCompletionAppearsAboveBottomDeal(on: screen)
        assertBottomDealButtonIsAtBottom(on: screen, in: app)
    }

    func testDealtScreenExposesTokenAndCardSizeHooks() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        try assertTokenValue(screen.dealCompleteMessage, contains: "text=color.text.primary")
        try assertTokenValue(screen.dealButton, contains: "background=color.button.deal.background")
        try assertTokenValue(screen.dealButton, contains: "pressed=color.button.deal.background.pressed")
        try assertTokenValue(screen.dealButton, contains: "text=color.button.deal.text")
        try assertTokenValue(screen.newGameButton, contains: "background=color.button.newGame.background")
        try assertTokenValue(screen.newGameButton, contains: "pressed=color.button.newGame.background.pressed")
        try assertTokenValue(screen.newGameButton, contains: "text=color.button.newGame.text")

        for label in screen.seatLabels {
            try assertTokenValue(label, contains: "text=color.text.primary")
        }

        for station in screen.stationAreas {
            try assertTokenValue(station, contains: "label=color.text.primary")
            try assertTokenValue(station, contains: "outline=color.station.outline")
        }

        for card in screen.visibleCards.allElementsBoundByIndex {
            let value = try XCTUnwrap(card.value as? String)
            XCTAssertTrue(value.contains("size=sharedBaseCard"))
            XCTAssertTrue(value.contains("surface=color.card.background"))
            XCTAssertTrue(value.contains("border=color.card.border"))
            XCTAssertTrue(value.contains("shadow=color.card.shadow"))

            let expectedHook = try XCTUnwrap(Self.expectedSuitHook(for: card.label))
            XCTAssertTrue(value.contains(expectedHook.role))
            XCTAssertTrue(value.contains(expectedHook.token))
            XCTAssertFalse(value.contains("#"))
        }

        for hiddenCard in screen.hiddenCardBacks.allElementsBoundByIndex {
            XCTAssertEqual(hiddenCard.value as? String, "sharedBaseCard")
        }
    }

    func testSouthCardsAreSortedAndNotActionable() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        let cardLabels = screen.visibleCards.allElementsBoundByIndex.map(\.label)
        XCTAssertEqual(cardLabels.count, 13)
        XCTAssertEqual(Self.cardSortValues(for: cardLabels).count, 13)
        XCTAssertEqual(Self.cardSortValues(for: cardLabels), Self.cardSortValues(for: cardLabels).sorted())

        let firstCard = screen.visibleCards.element(boundBy: 0)
        XCTAssertTrue(firstCard.exists)
        XCTAssertFalse(app.buttons[firstCard.label].exists)

        let cardLabelsBeforeTap = screen.visibleCards.allElementsBoundByIndex.map(\.label)
        if firstCard.isHittable {
            firstCard.tap()
        }
        XCTAssertEqual(screen.visibleCards.allElementsBoundByIndex.map(\.label), cardLabelsBeforeTap)
    }

    func testSimulatedHandsShowHiddenCardBacksOnly() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        for hiddenCard in screen.hiddenCardBacks.allElementsBoundByIndex {
            XCTAssertEqual(hiddenCard.label, "Card back")
            assertHiddenCardDoesNotRevealCardData(hiddenCard)
        }

        for hiddenHand in [screen.westHiddenHand, screen.northHiddenHand, screen.eastHiddenHand] {
            try assertTokenValue(hiddenHand, contains: "count=13")
            try assertTokenValue(hiddenHand, contains: "asset=card_back")
            try assertTokenValue(hiddenHand, contains: "hidden=true")
        }
    }

    func testDealButtonReplacesCompletedDealWithAnotherCompletedDeal() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        deal(on: screen)
        let firstSouthHand = screen.visibleCardLabels
        XCTAssertEqual(firstSouthHand.count, 13)

        screen.dealButton.tap()

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 5))
        XCTAssertTrue(screen.dealButton.exists)
        XCTAssertEqual(screen.dealButton.label, "Deal")
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
        XCTAssertFalse(screen.centralDeckStack.exists)
        XCTAssertNotEqual(screen.visibleCardLabels, firstSouthHand)
        XCTAssertFalse(screen.oldDealCardsButton.exists)
        XCTAssertFalse(screen.oldNewDealButton.exists)
    }

    func testNewGameButtonResetsToOriginalLaunchStateAfterDeal() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        screen.newGameButton.tap()

        XCTAssertTrue(screen.centralDeckStack.waitForExistence(timeout: 5))
        XCTAssertEqual(screen.deckStackCards.count, 52)
        XCTAssertEqual(screen.visibleCards.count, 0)
        XCTAssertEqual(screen.hiddenCardBacks.count, 0)
        XCTAssertFalse(screen.dealCompleteMessage.exists)
        XCTAssertTrue(screen.dealButton.exists)
        XCTAssertTrue(screen.newGameButton.exists)
        XCTAssertEqual(screen.dealButton.label, "Deal")
        XCTAssertEqual(screen.newGameButton.label, "New Game")

        assertTableTitleIsOnCardTable(on: screen)
        assertInitialDeckStackSitsBelowTitle(on: screen)
        assertInitialStationsAreRoundedSquares(on: screen)
    }

    func testDealAndReplacementDealRemainResponsive() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        screen.dealButton.tap()

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 2))
        XCTAssertTrue(screen.dealButton.isHittable)
        XCTAssertTrue(screen.newGameButton.isHittable)

        screen.dealButton.tap()

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 2))
        XCTAssertTrue(screen.dealButton.isHittable)
        XCTAssertTrue(screen.newGameButton.isHittable)
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
    }

    func testPrimaryLayoutElementsRemainUsableAndNonOverlapping() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        for element in screen.dealtUsabilityElements {
            assertElementIsUsableOnScreen(element, in: app)
        }

        assertNoSubstantialOverlap(screen.dealCompleteMessage, screen.dealButton)
        assertNoSubstantialOverlap(screen.dealButton, screen.southSeatArea)
        assertNoSubstantialOverlap(screen.northSeatArea, screen.cardTable)
        assertNoSubstantialOverlap(screen.southSeatArea, screen.cardTable)
        assertNoSubstantialOverlap(screen.westSeatArea, screen.eastSeatArea)

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

    func testOldDealLabelsAndProhibitedGameplayControlsAreAbsent() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertFalse(screen.oldDealCardsButton.exists)
        XCTAssertFalse(screen.oldNewDealButton.exists)

        deal(on: screen)

        XCTAssertFalse(screen.oldDealCardsButton.exists)
        XCTAssertFalse(screen.oldNewDealButton.exists)
        for element in screen.prohibitedOutOfScopeElements {
            XCTAssertFalse(element.exists)
        }
    }

    private func deal(on screen: TarneebScreen) {
        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        screen.dealButton.tap()
        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 5))
    }

    private func assertTableDiameter(
        on screen: TarneebScreen,
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let widthRatio = screen.cardTable.frame.width / app.frame.width
        XCTAssertGreaterThanOrEqual(widthRatio, 0.45, file: file, line: line)
        XCTAssertLessThanOrEqual(widthRatio, 0.55, file: file, line: line)
        let aspectRatio = screen.cardTable.frame.width / screen.cardTable.frame.height
        XCTAssertGreaterThanOrEqual(aspectRatio, 0.95, file: file, line: line)
        XCTAssertLessThanOrEqual(aspectRatio, 1.08, file: file, line: line)
    }

    private func assertTableTitleIsOnCardTable(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(screen.cardTable.frame.insetBy(dx: -4, dy: -4).contains(screen.title.frame), file: file, line: line)
    }

    private func assertInitialDeckStackSitsBelowTitle(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(screen.cardTable.frame.insetBy(dx: -4, dy: -4).contains(screen.centralDeckStack.frame), file: file, line: line)
        XCTAssertGreaterThan(screen.centralDeckStack.frame.minY, screen.title.frame.maxY, file: file, line: line)
        assertNoSubstantialOverlap(screen.title, screen.centralDeckStack, file: file, line: line)
    }

    private func assertStationsSurroundTable(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let tableFrame = screen.cardTable.frame
        let northFrame = screen.northSeatArea.frame
        let westFrame = screen.westSeatArea.frame
        let southFrame = screen.southSeatArea.frame
        let eastFrame = screen.eastSeatArea.frame

        XCTAssertLessThan(northFrame.midY, tableFrame.midY, file: file, line: line)
        XCTAssertGreaterThan(southFrame.midY, tableFrame.midY, file: file, line: line)
        XCTAssertLessThan(westFrame.midX, tableFrame.midX, file: file, line: line)
        XCTAssertGreaterThan(eastFrame.midX, tableFrame.midX, file: file, line: line)
        XCTAssertEqual(Double(northFrame.midX), Double(tableFrame.midX), accuracy: 30, file: file, line: line)
        XCTAssertEqual(Double(southFrame.midX), Double(tableFrame.midX), accuracy: 30, file: file, line: line)
        XCTAssertEqual(Double(westFrame.midY), Double(eastFrame.midY), accuracy: 30, file: file, line: line)
    }

    private func assertInitialStationsAreRoundedSquares(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for station in screen.stationAreas {
            XCTAssertEqual(Double(station.frame.width), Double(station.frame.height), accuracy: 8, file: file, line: line)
        }
    }

    private func assertSouthStationExpandedBelowTable(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThan(screen.southSeatArea.frame.minY, screen.cardTable.frame.midY, file: file, line: line)
        XCTAssertGreaterThan(screen.southSeatArea.frame.height, screen.northSeatArea.frame.height, file: file, line: line)
        XCTAssertGreaterThan(screen.southSeatArea.frame.height, screen.westSeatArea.frame.height, file: file, line: line)
        XCTAssertGreaterThan(screen.southSeatArea.frame.height, screen.eastSeatArea.frame.height, file: file, line: line)
    }

    private func assertCompletionAppearsAboveBottomDeal(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertLessThan(screen.dealCompleteMessage.frame.midY, screen.dealButton.frame.midY, file: file, line: line)
    }

    private func assertBottomDealButtonIsAtBottom(
        on screen: TarneebScreen,
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThan(screen.dealButton.frame.maxY, app.frame.maxY - 70, file: file, line: line)
        XCTAssertGreaterThan(screen.newGameButton.frame.maxY, app.frame.maxY - 70, file: file, line: line)
        XCTAssertEqual(Double(screen.newGameButton.frame.midY), Double(screen.dealButton.frame.midY), accuracy: 4, file: file, line: line)
        XCTAssertLessThan(screen.newGameButton.frame.maxX, screen.dealButton.frame.minX, file: file, line: line)
        assertNoSubstantialOverlap(screen.newGameButton, screen.dealButton, file: file, line: line)
    }

    private func assertNoSubstantialOverlap(
        _ first: XCUIElement,
        _ second: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let intersection = first.frame.intersection(second.frame)
        let tolerance = 2.0

        XCTAssertLessThanOrEqual(intersection.width, tolerance, file: file, line: line)
        XCTAssertLessThanOrEqual(intersection.height, tolerance, file: file, line: line)
    }

    private func assertFrame(
        _ childFrame: CGRect,
        isInside containerFrame: CGRect,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(containerFrame.insetBy(dx: -3, dy: -3).contains(childFrame), file: file, line: line)
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

    private static let mvp003SmallestSupportedSimulator = "iPhone SE (3rd generation)"
}

private struct TarneebScreen {
    let app: XCUIApplication

    var title: XCUIElement {
        element(identifier: "tarneeb-title")
    }

    var tableSurface: XCUIElement {
        element(identifier: "tarneeb-table-surface")
    }

    var tableScene: XCUIElement {
        element(identifier: "tarneeb-table-scene")
    }

    var cardTable: XCUIElement {
        element(identifier: "tarneeb-card-table")
    }

    var centralDeckStack: XCUIElement {
        element(identifier: "tarneeb-central-deck-stack")
    }

    var deckStackCards: XCUIElementQuery {
        app.images.matching(identifier: "tarneeb-deck-stack-card")
    }

    var bottomDealControl: XCUIElement {
        element(identifier: "tarneeb-bottom-deal-control")
    }

    var dealButton: XCUIElement {
        app.buttons.matching(identifier: "tarneeb-deal-button").firstMatch
    }

    var newGameButton: XCUIElement {
        app.buttons.matching(identifier: "tarneeb-new-game-button").firstMatch
    }

    var oldDealCardsButton: XCUIElement {
        app.buttons["Deal Cards"]
    }

    var oldNewDealButton: XCUIElement {
        app.buttons["New Deal"]
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

    var seatLabels: [XCUIElement] {
        [northSeat, westSeat, southSeat, eastSeat]
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

    var stationAreas: [XCUIElement] {
        [northSeatArea, westSeatArea, southSeatArea, eastSeatArea]
    }

    var initialUsabilityElements: [XCUIElement] {
        [title, cardTable, centralDeckStack, newGameButton, dealButton, northSeat, westSeat, southSeat, eastSeat]
    }

    var dealtUsabilityElements: [XCUIElement] {
        [
            dealCompleteMessage,
            newGameButton,
            dealButton,
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
        element(identifier: "tarneeb-visible-hand-south")
    }

    var westHiddenHand: XCUIElement {
        element(identifier: "tarneeb-hidden-hand-west")
    }

    var northHiddenHand: XCUIElement {
        element(identifier: "tarneeb-hidden-hand-north")
    }

    var eastHiddenHand: XCUIElement {
        element(identifier: "tarneeb-hidden-hand-east")
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
}
