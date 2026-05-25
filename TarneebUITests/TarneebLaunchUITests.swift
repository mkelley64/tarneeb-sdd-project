import XCTest

final class TarneebLaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testInitialScreenShowsDealCardsButton() throws {
        let app = XCUIApplication()
        app.launch()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertTrue(screen.dealCardsButton.exists)
        XCTAssertTrue(screen.dealCardsButton.isHittable)
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
}

private struct TarneebScreen {
    let app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts["Tarneeb"]
    }

    var dealCardsButton: XCUIElement {
        app.buttons["Deal Cards"]
    }

    var southSeat: XCUIElement {
        app.staticTexts["South"]
    }

    var westSeat: XCUIElement {
        app.staticTexts["West"]
    }

    var northSeat: XCUIElement {
        app.staticTexts["North"]
    }

    var eastSeat: XCUIElement {
        app.staticTexts["East"]
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

    var visibleCards: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: "tarneeb-visible-card")
    }

    var visibleCardLabels: [String] {
        visibleCards.allElementsBoundByIndex.map(\.label)
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
        app.staticTexts["Deal complete"]
    }

    var newDealButton: XCUIElement {
        app.buttons["New Deal"]
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
}
