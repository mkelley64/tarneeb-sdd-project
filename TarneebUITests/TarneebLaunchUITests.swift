import XCTest
import UIKit

private func waitForInteractiveOpening(_ app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
    let deal = app.buttons["tarneeb-deal-button"]
    let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: deal)
    XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 6), .completed, file: file, line: line)
}

final class TarneebFullMatchUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testExpertBiddingFromDealReachesLegalCardPlayWithoutOverrides() {
        let app = XCUIApplication()
        app.launchArguments += ["-tarneeb.aiSkill", "expert"]
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "sweep"
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = "south"
        app.launch()
        waitForInteractiveOpening(app)
        app.buttons["tarneeb-deal-button"].tap()
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 35))
        let legal = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@ AND enabled == true", "tarneeb-live-card-")).firstMatch
        XCTAssertTrue(legal.waitForExistence(timeout: 15))
        app.terminate()
    }

    func testAISkillMenuOffersAllLevelsOnOpeningLiveAndResultScreens() {
        for (key, value) in [("TARNEEB_OPENING_FIXTURE", "1"), ("TARNEEB_LIVE_FIXTURE", "balanced"),
                             ("TARNEEB_RESULT_FIXTURE", "round-made")] {
            let app = XCUIApplication()
            app.launchEnvironment[key] = value
            app.launch()
            if key == "TARNEEB_OPENING_FIXTURE" { waitForInteractiveOpening(app) }
            let options = app.buttons["tarneeb-game-options"]
            XCTAssertTrue(options.waitForExistence(timeout: 8))
            options.tap()
            let skill = app.buttons["AI skill"]
            XCTAssertTrue(skill.waitForExistence(timeout: 3), app.debugDescription)
            skill.tap()
            for label in ["Standard", "Advanced", "Expert"] {
                XCTAssertTrue(app.buttons[label].waitForExistence(timeout: 3), app.debugDescription)
            }
            for text in ["All AI players, including North.", "Applies to the next new game."] {
                let explanation = app.buttons[text]
                XCTAssertTrue(explanation.exists)
                XCTAssertTrue(app.frame.contains(explanation.frame))
            }
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = "AI skill \(key)"
            screenshot.lifetime = .keepAlways
            add(screenshot)
            app.buttons["Standard"].tap()
            app.terminate()
        }
    }

    func testMixedSuitHandFromDealThroughRoundResults() {
        let app = XCUIApplication()
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = "west"
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = "east:pass,north:pass,west:pass"
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = "0"
        app.launch()
        waitForInteractiveOpening(app)
        app.buttons["tarneeb-deal-button"].tap()
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 30))
        app.buttons["7"].tap()
        app.buttons["tarneeb-bid-button-south"].tap()
        let set = app.buttons["tarneeb-post-bidding-suit-button-south"]
        XCTAssertTrue(set.waitForExistence(timeout: 20))
        app.buttons["tarneeb-bid-suit-option-spades"].tap()
        set.tap()
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 5))
        let cards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-"))
        for remaining in stride(from: 13, through: 2, by: -1) {
            let legal = cards.matching(NSPredicate(format: "enabled == true")).firstMatch
            XCTAssertTrue(legal.waitForExistence(timeout: 20))
            XCTAssertEqual(cards.count, remaining)
            if remaining == 13 || remaining == 7 || remaining == 2 {
                capture("Mixed hand \(remaining) cards", app)
            }
            legal.doubleTap()
            expectation(for: NSPredicate { _, _ in cards.count < remaining }, evaluatedWith: cards)
            waitForExpectations(timeout: 6)
        }
        XCTAssertTrue(app.otherElements["tarneeb-round-result"].waitForExistence(timeout: 25))
        XCTAssertTrue(app.buttons["tarneeb-next-hand"].isHittable)
        XCTAssertFalse(app.buttons["tarneeb-new-match"].exists)
        XCTAssertEqual(cards.count, 0)
        capture("Mixed hand round result", app)
        app.buttons["tarneeb-last-trick"].tap()
        XCTAssertTrue(app.buttons["tarneeb-close-last-trick"].waitForExistence(timeout: 3))
        for seat in ["south", "east", "north", "west"] {
            XCTAssertTrue(app.otherElements["tarneeb-recalled-\(seat)"].exists)
        }
        capture("Mixed hand result recall", app)
    }

    func testOpeningThroughTwoCompleteHandsMatchWinAndNewGame() {
        let app = XCUIApplication()
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "sweep"
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = "west"
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = "east:pass,north:pass,west:pass"
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = "0"
        app.launchEnvironment["TARNEEB_SAVE_TEST_ID"] = UUID().uuidString
        app.launch()
        let cards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-"))
        let ownTricks = app.staticTexts["tarneeb-live-south-tricks"]
        waitForInteractiveOpening(app)
        capture("01 Opening", app)
        app.buttons["tarneeb-deal-button"].tap()

        for round in 1...2 {
            let bid = app.buttons["tarneeb-bid-button-south"]
            XCTAssertTrue(bid.waitForExistence(timeout: 30))
            XCTAssertTrue(bid.isHittable)
            if round == 1 {
                XCTAssertTrue(app.otherElements["tarneeb-opening-station-west"].label.contains("dealer"))
            } else {
                XCTAssertTrue(app.otherElements["tarneeb-opening-south-dealer"].exists)
            }
            XCTAssertTrue(app.staticTexts["North South score \((round - 1) * 16)"].exists)
            capture("Round \(round) bidding", app)
                app.buttons["7"].tap()
            bid.tap()
            let set = app.buttons["tarneeb-post-bidding-suit-button-south"]
            XCTAssertTrue(set.waitForExistence(timeout: 20))
            app.buttons["tarneeb-bid-suit-option-spades"].tap()
            capture("Round \(round) trump", app)
            set.tap()
            XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.staticTexts["tarneeb-live-contract-bid"].label, "You bid 7")
            if round == 1 {
                XCTAssertTrue(app.otherElements["tarneeb-live-station-west"].label.contains("dealer"))
            } else {
                XCTAssertTrue(app.staticTexts["tarneeb-live-dealer-south"].exists)
                XCTAssertFalse(app.otherElements["tarneeb-live-station-west"].label.contains("dealer"))
            }
            XCTAssertEqual(cards.count, 13)
            XCTAssertEqual(ownTricks.value as? String, "0")

            for (index, rank) in ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"].enumerated() {
                let card = app.buttons["tarneeb-live-card-spades-\(rank)"]
                expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: card)
                waitForExpectations(timeout: 25)
                if index == 0 {
                    card.tap()
                    expectation(for: NSPredicate(format: "value == %@", "Selected"), evaluatedWith: card)
                    waitForExpectations(timeout: 3)
                    capture("Round \(round) selected card", app)
                }
                if index == 5 {
                    card.press(forDuration: 0.05, thenDragTo: app.otherElements["tarneeb-live-trick"])
                } else {
                    card.doubleTap()
                }
                if index < 11 {
                    expectation(for: NSPredicate(format: "value == %@", "\(index + 1)"), evaluatedWith: ownTricks)
                    waitForExpectations(timeout: 25)
                    XCTAssertEqual(cards.count, 12 - index)
                    let expectedProgress = index < 5 ? "\(index + 1) / 7 tricks" : (index == 5 ? "One more trick" : "Contract secured")
                    XCTAssertEqual(app.staticTexts["tarneeb-contract-progress"].label, expectedProgress)
                    XCTAssertTrue((app.staticTexts["tarneeb-contract-progress"].value as? String ?? "").contains("\(index + 1) of 7"))
                    if index == 5 {
                        capture("Round \(round) mid-hand", app)
                        app.buttons["tarneeb-last-trick"].tap()
                        let close = app.buttons["tarneeb-close-last-trick"]
                        XCTAssertTrue(close.waitForExistence(timeout: 3))
                        capture("Round \(round) recall", app)
                        close.tap()
                        XCUIDevice.shared.press(.home)
                        app.activate()
                        XCTAssertEqual(ownTricks.value as? String, "6")
                    }
                }
            }
            // The final ace is played automatically; no fixture skips tricks or scoring.
            let result = app.otherElements["tarneeb-round-result"]
            XCTAssertTrue(result.waitForExistence(timeout: 25))
            XCTAssertEqual(cards.count, 0)
            XCTAssertTrue(app.staticTexts["North South score \(round * 16)"].exists)
            XCTAssertTrue(app.staticTexts["East West score 0"].exists)
            XCTAssertTrue(app.staticTexts["North-South round change +16"].exists)
            capture("Round \(round) result", app)
            if round == 1 {
                XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "You brought it home.")
                let next = app.buttons["tarneeb-next-hand"]
                XCTAssertTrue(next.isHittable)
                next.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5)).tap()
                XCTAssertTrue(app.otherElements["tarneeb-opening-table"].waitForExistence(timeout: 5))
            } else {
                XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "You + Partner win")
                XCTAssertFalse(app.buttons["tarneeb-next-hand"].exists)
            }
        }

        app.terminate()
        app.launchEnvironment.removeValue(forKey: "TARNEEB_OPENING_FIXTURE")
        app.launch()
        XCTAssertTrue(app.buttons["tarneeb-new-match"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["North South score 32"].exists)
        XCTAssertFalse(app.alerts["Match storage"].exists)
        app.buttons["tarneeb-new-match"].coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
        XCTAssertTrue(app.staticTexts["East West score 0"].exists)
        XCTAssertEqual(app.otherElements["tarneeb-opening-deck"].value as? String, "52 cards")
        capture("New game after match", app)
    }

    private func capture(_ name: String, _ app: XCUIApplication) {
        if !name.contains("recall") {
            let target = app.staticTexts["tarneeb-match-target"]
            XCTAssertTrue(target.waitForExistence(timeout: 5))
            XCTAssertEqual(target.label, "First to 31")
            XCTAssertTrue(app.frame.contains(target.frame))
        }
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}

final class TarneebContinuedPlayUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launch(_ fixture: String, key: String = "TARNEEB_LIVE_FIXTURE", saved: Bool = false, maximumText: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        if maximumText { app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launchEnvironment[key] = fixture
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = "1"
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = "west"
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = "east:pass,north:pass,west:pass"
        if saved { app.launchEnvironment["TARNEEB_SAVE_TEST_ID"] = UUID().uuidString }
        app.launch()
        return app
    }

    private func relaunchSaved(_ app: XCUIApplication) {
        app.terminate()
        for key in ["TARNEEB_LIVE_FIXTURE", "TARNEEB_OPENING_FIXTURE", "TARNEEB_RESULT_FIXTURE"] {
            app.launchEnvironment.removeValue(forKey: key)
        }
        app.launch()
        XCTAssertFalse(app.alerts["Match storage"].exists)
    }

    private func verifyRecall(_ app: XCUIApplication) {
        let recall = app.buttons["tarneeb-last-trick"]
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: recall)
        waitForExpectations(timeout: 5)
        recall.tap()
        let close = app.buttons["tarneeb-close-last-trick"]
        XCTAssertTrue(close.waitForExistence(timeout: 3))
        for seat in ["south", "east", "north", "west"] {
            let recalled = app.otherElements["tarneeb-recalled-\(seat)"]
            XCTAssertTrue(recalled.exists)
            if !app.frame.contains(recalled.frame), app.scrollViews.firstMatch.exists {
                app.scrollViews.firstMatch.swipeUp()
            }
            XCTAssertTrue(app.frame.contains(recalled.frame))
        }
        if !close.isHittable, app.scrollViews.firstMatch.exists { app.scrollViews.firstMatch.swipeDown() }
        XCTAssertTrue(app.frame.contains(close.frame))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Last trick recall"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testMaximumTextRecallKeepsWinnerCardsAndCloseReachable() {
        let app = launch("1", maximumText: true)
        XCTAssertTrue(app.buttons["tarneeb-live-card-spades-2"].waitForExistence(timeout: 6))
        app.buttons["tarneeb-live-card-spades-2"].doubleTap()
        expectation(for: NSPredicate(format: "value == %@", "1"), evaluatedWith: app.staticTexts["tarneeb-live-south-tricks"])
        waitForExpectations(timeout: 25)
        verifyRecall(app)
        XCTAssertTrue(app.staticTexts["You won the trick"].isHittable)
        for seat in ["south", "east", "north", "west"] {
            let recalled = app.otherElements["tarneeb-recalled-\(seat)"]
            XCTAssertTrue(recalled.label.contains(seat.capitalized))
        }
        app.buttons["tarneeb-close-last-trick"].tap()
        XCTAssertTrue(app.buttons["tarneeb-live-card-spades-3"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["tarneeb-live-south-tricks"].value as? String, "1")
    }

    func testRecallPausesSurvivesBackgroundAndResumesWithoutPlaying() {
        let app = launch("1")
        XCTAssertFalse(app.buttons["tarneeb-last-trick"].isEnabled)
        app.buttons["tarneeb-live-card-spades-2"].doubleTap()
        let count = app.staticTexts["tarneeb-live-south-tricks"]
        expectation(for: NSPredicate(format: "value == %@", "1"), evaluatedWith: count)
        waitForExpectations(timeout: 12)
        verifyRecall(app)
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(app.buttons["tarneeb-close-last-trick"].waitForExistence(timeout: 3))
        app.buttons["tarneeb-close-last-trick"].tap()
        XCTAssertTrue(app.buttons["tarneeb-live-card-spades-3"].waitForExistence(timeout: 3))
        XCTAssertEqual(count.value as? String, "1")
        app.buttons["tarneeb-live-card-spades-3"].doubleTap()
        expectation(for: NSPredicate(format: "value == %@", "2"), evaluatedWith: count)
        waitForExpectations(timeout: 12)
    }

    func testLiveMatchRestoresFromDiskWithoutFixture() {
        let app = launch("balanced", saved: true)
        app.buttons["tarneeb-live-card-spades-A"].doubleTap()
        expectation(for: NSPredicate(format: "value == %@", "1"), evaluatedWith: app.staticTexts["tarneeb-live-south-tricks"])
        waitForExpectations(timeout: 12)
        relaunchSaved(app)
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 12)
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-A"].exists)
        XCTAssertEqual(app.staticTexts["tarneeb-live-south-tricks"].value as? String, "1")
        XCTAssertEqual(app.staticTexts["tarneeb-live-status"].label, "Your turn")
        verifyRecall(app)
        app.buttons["tarneeb-close-last-trick"].tap()
    }

    func testBiddingAndTrumpSelectionRestoreFromDisk() {
        let app = launch("1", key: "TARNEEB_OPENING_FIXTURE", saved: true)
        waitForInteractiveOpening(app)
        app.buttons["tarneeb-deal-button"].tap()
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 25))
        relaunchSaved(app)
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 5))
        app.buttons["7"].tap()
        app.buttons["tarneeb-bid-button-south"].tap()
        XCTAssertTrue(app.buttons["tarneeb-post-bidding-suit-button-south"].waitForExistence(timeout: 20))
        relaunchSaved(app)
        let set = app.buttons["tarneeb-post-bidding-suit-button-south"]
        XCTAssertTrue(set.waitForExistence(timeout: 5))
        app.buttons["tarneeb-bid-suit-option-spades"].tap()
        set.tap()
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 5))
    }

    func testMatchResultRecallAndResetSurviveRelaunch() {
        let app = launch("match-win", key: "TARNEEB_RESULT_FIXTURE", saved: true)
        XCTAssertTrue(app.buttons["tarneeb-new-match"].waitForExistence(timeout: 5))
        relaunchSaved(app)
        XCTAssertTrue(app.staticTexts["North South score 32"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.otherElements["tarneeb-round-result"].value as? String, "Saved result")
        verifyRecall(app)
        app.buttons["tarneeb-close-last-trick"].tap()
        app.buttons["tarneeb-new-match"].tap()
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        relaunchSaved(app)
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
    }
}

final class TarneebRoundResultUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launch(_ fixture: String, reducedMotion: Bool = false, maximumText: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        if maximumText {
            app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        }
        app.launchEnvironment["TARNEEB_RESULT_FIXTURE"] = fixture
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reducedMotion ? "1" : "0"
        app.launch()
        XCTAssertTrue(app.otherElements["tarneeb-round-result"].waitForExistence(timeout: 5))
        return app
    }

    private func verifyVisibleResult(_ app: XCUIApplication, command: String) {
        let button = app.buttons[command]
        XCTAssertTrue(button.isHittable)
        XCTAssertGreaterThanOrEqual(button.frame.height, 48)
        XCTAssertGreaterThan(button.frame.width, app.frame.width * 0.8)
        XCTAssertTrue(app.frame.contains(button.frame))
        XCTAssertTrue(app.frame.contains(app.staticTexts["tarneeb-result-title"].frame))
        XCTAssertTrue(app.staticTexts["North-South bid"].exists)
        XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", "Bid 7, Tarneeb ")).firstMatch.exists)
        XCTAssertFalse(app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] %@", "trump")).firstMatch.exists)
        XCTAssertFalse(app.scrollViews.firstMatch.exists)
        for text in app.staticTexts.allElementsBoundByIndex where text.isHittable {
            XCTAssertTrue(app.frame.contains(text.frame), text.label)
        }
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = app.staticTexts["tarneeb-result-title"].label
        shot.lifetime = .keepAlways
        add(shot)
    }

    func testRoundResultWaitsForNextHandAndPreservesScores() {
        let app = launch("round-made", reducedMotion: true)
        XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "You brought it home.")
        XCTAssertTrue(app.staticTexts["North South score 16"].exists)
        XCTAssertTrue(app.staticTexts["North-South round change +16"].exists)
        verifyVisibleResult(app, command: "tarneeb-next-hand")
        let autoAdvance = expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: app.otherElements["tarneeb-opening-table"])
        autoAdvance.isInverted = true
        waitForExpectations(timeout: 3)
        app.buttons["tarneeb-next-hand"].coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5)).tap()
        XCTAssertTrue(app.otherElements["tarneeb-opening-table"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["North South score 16"].exists)
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 25))
        XCTAssertFalse(app.buttons["tarneeb-next-hand"].exists)
    }

    func testMissedContractRetainsNegativeScoresAfterBackgrounding() {
        let app = launch("round-missed")
        XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "The contract slipped away.")
        XCTAssertTrue(app.staticTexts["North South score -7"].exists)
        XCTAssertTrue(app.staticTexts["East West score 16"].exists)
        verifyVisibleResult(app, command: "tarneeb-next-hand")
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(app.buttons["tarneeb-next-hand"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["North South score -7"].exists)
        XCTAssertTrue(app.staticTexts["East West score 16"].exists)
    }

    func testPlayerMatchWinShowsFinalScoresAndResets() {
        let app = launch("match-win")
        XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "You + Partner win")
        XCTAssertTrue(app.staticTexts["North South score 32"].exists)
        XCTAssertFalse(app.buttons["tarneeb-next-hand"].exists)
        verifyVisibleResult(app, command: "tarneeb-new-match")
        app.buttons["tarneeb-new-match"].coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
        XCTAssertTrue(app.staticTexts["East West score 0"].exists)
        XCTAssertEqual(app.otherElements["tarneeb-opening-deck"].value as? String, "52 cards")
    }

    func testSuccessfulDefenseShowsRealOpponentPenaltyAndKaboot() {
        let app = launch("round-defense")
        XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "You held the line.")
        XCTAssertTrue(app.staticTexts["CONTRACT DEFEATED"].exists)
        XCTAssertTrue(app.staticTexts["North South score 16"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["East West score -9"].exists)
        XCTAssertTrue(app.staticTexts["North-South round change +16"].exists)
        XCTAssertTrue(app.staticTexts["East-West round change -9"].exists)
        XCTAssertTrue(app.staticTexts["East-West took 0 of 13 tricks"].exists)
        XCTAssertTrue(app.staticTexts["You + Partner took 13 defending tricks."].exists)
        XCTAssertTrue(app.staticTexts["Kaboot · 13 defending tricks · +16 points"].exists)
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = "Successful defense — actual engine"; shot.lifetime = .keepAlways; add(shot)
        app.buttons["tarneeb-next-hand"].tap()
        XCTAssertTrue(app.otherElements["tarneeb-opening-table"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["North South score 16"].exists)
        XCTAssertTrue(app.staticTexts["East West score -9"].exists)
    }

    func testImmediateNextHandCancelsOutcomePresentationWithoutReplay() {
        let app = launch("round-made")
        app.buttons["tarneeb-next-hand"].tap()
        XCTAssertTrue(app.otherElements["tarneeb-opening-table"].waitForExistence(timeout: 5))
        XCUIDevice.shared.press(.home); app.activate()
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 25))
        XCTAssertTrue(app.staticTexts["North South score 16"].exists)
        XCTAssertFalse(app.buttons["tarneeb-next-hand"].exists)
    }

    func testOpponentMatchWinWithReducedMotionShowsCorrectWinner() {
        let app = launch("match-loss", reducedMotion: true)
        XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "East + West win")
        XCTAssertTrue(app.staticTexts["East West score 32"].exists)
        XCTAssertTrue(app.staticTexts["North South score -14"].exists)
        XCTAssertFalse(app.buttons["tarneeb-next-hand"].exists)
        verifyVisibleResult(app, command: "tarneeb-new-match")
    }

    func testMaximumTextPlayerVictoryKeepsFactsAndNewGameReachable() {
        let app = launch("match-win", reducedMotion: true, maximumText: true)
        XCTAssertTrue(app.staticTexts["North South score 32"].isHittable)
        verifyVisibleResult(app, command: "tarneeb-new-match")
        app.buttons["tarneeb-new-match"].tap()
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
    }

    func testMaximumTextOpponentVictoryKeepsFactsAndNewGameReachable() {
        let app = launch("match-loss", reducedMotion: true, maximumText: true)
        XCTAssertTrue(app.staticTexts["East West score 32"].isHittable)
        XCTAssertTrue(app.staticTexts["North South score -14"].isHittable)
        verifyVisibleResult(app, command: "tarneeb-new-match")
        app.buttons["tarneeb-new-match"].tap()
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["East West score 0"].exists)
    }
}

final class TarneebOpeningTableUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launch(reducedMotion: Bool = false, dealer: String = "west", bids: String = "east:pass,north:pass,west:pass", fixture: String = "1") -> XCUIApplication {
        let app = XCUIApplication()
        if name.contains("testIndividualFaceDownHandBeforeFlipPreservesFaceUpGeometry") || name.contains("B2BiddingSuitPacking") || name.contains("B2RepresentativeDistributions") {
            app.launchEnvironment["TARNEEB_CAPTURE_DEAL"] = "1"
        }
        if name.contains("DealBidTrumpAndLivePlayWithoutScrolling") {
            app.launchEnvironment["TARNEEB_AUDIT_BIDDING_PUBLICATIONS"] = "1"
        }
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = fixture
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = dealer
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = bids
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reducedMotion ? "1" : "0"
        app.launch()
        XCTAssertTrue(app.otherElements["tarneeb-opening-table"].waitForExistence(timeout: 5))
        waitForInteractiveOpening(app)
        return app
    }

    private func waitForBid(_ app: XCUIApplication) {
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 45))
        let cards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-"))
        XCTAssertEqual(cards.count, 13)
        for card in cards.allElementsBoundByIndex { XCTAssertTrue(app.frame.contains(card.frame)) }
        XCTAssertTrue(app.frame.contains(app.buttons["tarneeb-bid-button-south"].frame))
        XCTAssertFalse(app.otherElements["tarneeb-opening-deck"].exists)
        XCTAssertFalse(app.scrollViews.firstMatch.exists)
    }

    func testB2BiddingSuitPackingPersistsThroughRevealTrumpAndPlay() {
        verifyB2PhaseContinuity(fixture: "b2")
    }

    func testB2RepresentativeDistributionsKeepAbsoluteHandPositionsAcrossPhases() {
        for fixture in ["4-4-3-2", "6-3-2-2", "7-3-2-1", "8-2-2-1", "5-5-3-0"] {
            verifyB2PhaseContinuity(fixture: fixture)
        }
    }

    private func verifyB2PhaseContinuity(fixture: String) {
        let app = launch(fixture: fixture)
        defer { app.terminate() }
        app.buttons["tarneeb-deal-button"].tap()
        let hand = app.otherElements["tarneeb-opening-hand"]
        expectation(for: NSPredicate { _, _ in
            (hand.value as? String ?? "").contains("state=settlingBacks")
        }, evaluatedWith: hand)
        waitForExpectations(timeout: 25)
        let advance = app.buttons["tarneeb-deal-phase-continue"]
        advance.tap()
        expectation(for: NSPredicate(format: "value == %@", "spread-settled-backs"), evaluatedWith: advance)
        waitForExpectations(timeout: 5)
        let cards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-"))
        let backFrames = Dictionary(uniqueKeysWithValues: cards.allElementsBoundByIndex.map { ($0.identifier, $0.frame) })
        XCTAssertEqual(backFrames.count, 13)
        advance.tap()
        expectation(for: NSPredicate(format: "value == %@", "reveal-settled-faces"), evaluatedWith: advance)
        waitForExpectations(timeout: 5)
        advance.tap()
        waitForBid(app)
        let bidding = Dictionary(uniqueKeysWithValues: cards.allElementsBoundByIndex.map { ($0.identifier, $0.frame) })
        let upperY = bidding.values.map(\.midY).min()!
        let counts = [bidding.values.filter { abs($0.midY - upperY) < 1 }.count,
                      bidding.values.filter { $0.midY > upperY + 60 }.count]
        XCTAssertEqual(counts.sorted(), [6, 7])
        let fallback = ["8-2-2-1", "5-5-3-0"].contains(fixture)
        for suit in ["hearts", "clubs", "diamonds", "spades"] where !fallback {
            let suitFrames = bidding.filter { $0.key.contains("-\(suit)-") }.values
            XCTAssertLessThanOrEqual((suitFrames.map(\.midY).max() ?? 0) - (suitFrames.map(\.midY).min() ?? 0), 0.5)
        }
        if fallback {
            let suits = ["hearts", "clubs", "diamonds", "spades"]
            let distribution = fixture.split(separator: "-").compactMap { Int($0) }
            let orderedIDs = zip(suits, distribution).flatMap { suit, count in
                Array(["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"].prefix(count)).map { "tarneeb-opening-card-\(suit)-\($0)" }
            }
            for (index, id) in orderedIDs.enumerated() {
                XCTAssertEqual(bidding[id]!.midY, index < 7 ? upperY : upperY + 78, accuracy: 0.5)
            }
        }
        for (id, frame) in bidding {
            if fixture == "b2" {
                let upper = id.contains("-hearts-") || id.contains("-diamonds-")
                XCTAssertEqual(frame.midY, upper ? upperY : upperY + 78, accuracy: 0.5)
            }
            XCTAssertEqual(frame.midX, backFrames[id]!.midX, accuracy: 0.5)
            XCTAssertEqual(frame.midY, backFrames[id]!.midY, accuracy: 0.5)
            XCTAssertTrue(app.frame.contains(frame))
            XCTAssertFalse(app.buttons[id].exists)
        }
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "B2 bidding phase continuity \(fixture)"
        shot.lifetime = .keepAlways
        add(shot)
        app.buttons["7"].tap()
        app.buttons["tarneeb-bid-button-south"].tap()
        let confirmTrump = app.buttons["tarneeb-post-bidding-suit-button-south"]
        XCTAssertTrue(confirmTrump.waitForExistence(timeout: 25))
        for card in cards.allElementsBoundByIndex {
            XCTAssertEqual(card.frame.midX, bidding[card.identifier]!.midX, accuracy: 0.5)
            XCTAssertEqual(card.frame.midY, bidding[card.identifier]!.midY, accuracy: 0.5)
        }
        app.buttons["tarneeb-bid-suit-option-spades"].tap()
        confirmTrump.tap()
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 5))
        let live = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).allElementsBoundByIndex
        XCTAssertEqual(live.count, 13)
        for card in live {
            let openingID = card.identifier.replacingOccurrences(of: "tarneeb-live-card-", with: "tarneeb-opening-card-")
            XCTAssertEqual(card.frame.midX, bidding[openingID]!.midX, accuracy: 0.5)
            XCTAssertEqual(card.frame.midY, bidding[openingID]!.midY, accuracy: 0.5)
            XCTAssertEqual(card.frame.width, bidding[openingID]!.width, accuracy: 0.5)
            XCTAssertEqual(card.frame.height, bidding[openingID]!.height, accuracy: 0.5)
            XCTAssertTrue(card.isHittable)
        }
    }

    func testIndividualFaceDownHandBeforeFlipPreservesFaceUpGeometry() {
        let app = launch()
        app.buttons["tarneeb-deal-button"].tap()
        let hand = app.otherElements["tarneeb-opening-hand"]
        expectation(for: NSPredicate { _, _ in
            let value = hand.value as? String ?? ""
            return value.contains("state=settlingBacks") && value.contains("faceDown=13;revealed=0") && value.contains("established=52")
        }, evaluatedWith: hand)
        waitForExpectations(timeout: 25)
        let cards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-"))
        XCTAssertEqual(cards.count, 13)
        XCTAssertEqual(Set(cards.allElementsBoundByIndex.map { $0.label }), ["Face-down card"])
        let stackedFrames = cards.allElementsBoundByIndex.map { $0.frame }
        for frame in stackedFrames {
            XCTAssertEqual(frame.midX, stackedFrames[0].midX, accuracy: 0.5)
            XCTAssertEqual(frame.midY, stackedFrames[0].midY, accuracy: 0.5)
        }
        let advance = app.buttons["tarneeb-deal-phase-continue"]
        advance.tap()
        expectation(for: NSPredicate(format: "value == %@", "spread-settled-backs"), evaluatedWith: advance)
        waitForExpectations(timeout: 5)
        let backFrames = cards.allElementsBoundByIndex.map { $0.frame }
        for frame in backFrames {
            XCTAssertEqual(frame.width, 64, accuracy: 0.5)
            XCTAssertEqual(frame.height, 90, accuracy: 0.5)
            XCTAssertTrue(app.frame.contains(frame))
        }
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = "13 individual face-down cards before flip"; shot.lifetime = .keepAlways; add(shot)
        advance.tap()
        expectation(for: NSPredicate(format: "value == %@", "reveal-settled-faces"), evaluatedWith: advance)
        waitForExpectations(timeout: 5)
        advance.tap()
        waitForBid(app)
        XCTAssertEqual(cards.count, 13)
        for (card, frame) in zip(cards.allElementsBoundByIndex, backFrames) {
            // The existing border and raster rounding extend accessibility bounds; hand centers stay within half a point.
            XCTAssertEqual(card.frame.midX, frame.midX, accuracy: 0.5)
            XCTAssertEqual(card.frame.midY, frame.midY, accuracy: 0.5)
            XCTAssertEqual(card.frame.width, frame.width + 1, accuracy: 0.5)
            XCTAssertEqual(card.frame.height, frame.height + 1, accuracy: 0.5)
            XCTAssertTrue(app.frame.contains(card.frame))
        }
        XCTAssertFalse(cards.allElementsBoundByIndex.contains { $0.label == "Face-down card" })
        for seat in ["north", "east", "west"] {
            XCTAssertFalse((app.otherElements["tarneeb-opening-station-\(seat)"].value as? String ?? "").contains("cards"))
        }
    }

    func testDealBidTrumpAndLivePlayWithoutScrolling() { verifyOpening(reducedMotion: false) }
    func testReducedMotionDealBidTrumpAndLivePlayWithoutScrolling() { verifyOpening(reducedMotion: true) }

    private func verifyOpening(reducedMotion: Bool) {
        let app = launch(reducedMotion: reducedMotion)
        let score = app.staticTexts["North South score 0"]
        XCTAssertTrue(score.exists)
        XCTAssertTrue(app.staticTexts["East West score 0"].exists)
        XCTAssertFalse(score.frame.intersects(app.buttons["tarneeb-game-options"].frame))
        let opening = XCTAttachment(screenshot: app.screenshot())
        opening.name = "Finished opening table"
        opening.lifetime = .keepAlways
        add(opening)
        XCTAssertEqual(app.otherElements["tarneeb-opening-deck"].value as? String, "52 cards")
        XCTAssertGreaterThanOrEqual(app.buttons["tarneeb-deal-button"].frame.height, 44)
        app.buttons["tarneeb-deal-button"].coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5)).tap()
        XCTAssertFalse(app.buttons["tarneeb-deal-button"].isEnabled)
        waitForBid(app)
        XCTAssertEqual(app.staticTexts["tarneeb-opening-status"].label, "طلب · Bidding")
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "Opening readable hand and bidding"
        shot.lifetime = .keepAlways
        add(shot)
        app.buttons["7"].tap()
        XCTAssertEqual(app.buttons["tarneeb-bid-button-south"].label, "Bid 7")
        XCTAssertFalse(app.buttons["tarneeb-bid-suit-option-spades"].exists)
        let auctionCards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-")).allElementsBoundByIndex.map(\.frame)
        let auctionStations = ["north", "east", "south", "west"].map { app.otherElements["tarneeb-opening-station-\($0)"].frame }
        let auctionScoreFrame = score.frame
        app.buttons["tarneeb-bid-button-south"].tap()
        let set = app.buttons["tarneeb-post-bidding-suit-button-south"]
        XCTAssertTrue(set.waitForExistence(timeout: 25))
        let audit = app.otherElements["tarneeb-opening-table"].value as? String ?? ""
        let observed = audit.split(separator: ";").first { $0.hasPrefix("completedSouthBidPublications=") }.flatMap { Int($0.split(separator: "=").last ?? "") } ?? 0
        XCTAssertGreaterThan(observed, 0, "Regression must observe completed-bid publications, not just the settled chooser")
        XCTAssertTrue(audit.contains("missingTrumpChooserPublications=0"), audit)
        XCTAssertTrue(audit.contains("fadingTrumpChooserPublications=0"), audit)
        XCTAssertFalse(app.staticTexts["Preparing the table"].exists)
        let chooserCards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-")).allElementsBoundByIndex.map(\.frame)
        XCTAssertEqual(chooserCards.count, auctionCards.count)
        for (before, after) in zip(auctionCards, chooserCards) {
            XCTAssertEqual(after.midX, before.midX, accuracy: 0.5)
            XCTAssertEqual(after.midY, before.midY, accuracy: 0.5)
            XCTAssertEqual(after.width, before.width, accuracy: 0.5)
            XCTAssertEqual(after.height, before.height, accuracy: 0.5)
        }
        for (seat, before) in zip(["north", "east", "south", "west"], auctionStations) {
            let after = app.otherElements["tarneeb-opening-station-\(seat)"].frame
            // Resolved bid text changes semantic vertical bounds; the station axis stays fixed.
            XCTAssertEqual(after.midX, before.midX, accuracy: 0.5)
        }
        XCTAssertEqual(score.frame.midX, auctionScoreFrame.midX, accuracy: 0.5)
        XCTAssertEqual(score.frame.midY, auctionScoreFrame.midY, accuracy: 0.5)
        XCTAssertEqual(score.frame.width, auctionScoreFrame.width, accuracy: 0.5)
        XCTAssertEqual(score.frame.height, auctionScoreFrame.height, accuracy: 0.5)
        XCTAssertEqual(app.staticTexts["tarneeb-suit-heading"].label, "Tarneeb")
        XCTAssertTrue(app.frame.contains(app.staticTexts["tarneeb-suit-heading"].frame))
        let north = app.otherElements["tarneeb-opening-station-north"]
        XCTAssertFalse(app.staticTexts["tarneeb-suit-heading"].frame.intersects(north.frame))
        XCTAssertFalse(app.staticTexts["Trump"].exists)
        XCTAssertFalse(set.isEnabled)
        for suit in ["clubs", "diamonds", "hearts", "spades"] {
            let button = app.buttons["tarneeb-bid-suit-option-\(suit)"]
            XCTAssertTrue(button.isHittable)
            XCTAssertTrue(app.frame.contains(button.frame))
            XCTAssertGreaterThanOrEqual(button.frame.height, 44)
            XCTAssertFalse(button.frame.intersects(north.frame))
        }
        app.buttons["tarneeb-bid-suit-option-spades"].tap()
        XCTAssertTrue(set.isEnabled)
        let trump = XCTAttachment(screenshot: app.screenshot())
        trump.name = "Visible Tarneeb controls"
        trump.lifetime = .keepAlways
        add(trump)
        let biddingCards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-")).allElementsBoundByIndex.map(\.frame)
        set.tap()
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.otherElements["tarneeb-opening-table"].exists)
        XCTAssertFalse(app.staticTexts["Preparing the table"].exists)
        let liveCards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).allElementsBoundByIndex.map(\.frame)
        XCTAssertEqual(liveCards.count, biddingCards.count)
        for (bidding, live) in zip(biddingCards, liveCards) {
            XCTAssertEqual(live.width, bidding.width, accuracy: 0.5)
            XCTAssertEqual(live.height, bidding.height, accuracy: 0.5)
            XCTAssertTrue(app.frame.contains(live), "Transition must preserve the approved readable hand geometry")
        }
        let settled = XCTAttachment(screenshot: app.screenshot()); settled.name = reducedMotion ? "Reduced Motion bid-to-play settled" : "Normal bid-to-play settled"; settled.lifetime = .keepAlways; add(settled)
        XCTAssertTrue(app.staticTexts["Tarneeb spades"].exists)
        XCTAssertFalse(app.staticTexts["Trump spades"].exists)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 13)
    }

    func testBackgroundDuringDealSettlesAndNewGameResets() {
        let app = launch()
        app.buttons["tarneeb-deal-button"].tap()
        XCUIDevice.shared.press(.home)
        app.activate()
        waitForBid(app)
        XCTAssertFalse(app.otherElements["tarneeb-opening-packet"].exists)
        app.buttons["tarneeb-game-options"].tap()
        app.buttons["New Game"].tap()
        XCTAssertTrue(app.alerts.buttons["Keep Playing"].waitForExistence(timeout: 3))
        tapAlert("Keep Playing", app: app)
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 3))
        app.buttons["tarneeb-game-options"].tap()
        app.buttons["New Game"].tap()
        tapAlert("Cancel Game", app: app)
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].isEnabled)
        XCTAssertEqual(app.otherElements["tarneeb-opening-deck"].value as? String, "52 cards")
    }

    func testAllPassRedealsAndReturnsToBidding() {
        let app = launch(reducedMotion: true)
        app.buttons["tarneeb-deal-button"].tap()
        waitForBid(app)
        app.buttons["tarneeb-pass-button-south"].tap()
        // Observe the durable dealer rotation rather than a brief reduced-motion packet.
        expectation(for: NSPredicate(format: "label CONTAINS %@", "West"), evaluatedWith: app.otherElements["tarneeb-opening-station-west"])
        waitForExpectations(timeout: 25)
        waitForBid(app)
    }

    func testRaisedBidGridOnlyOffersLegalValues() {
        let app = launch(reducedMotion: true, dealer: "south", bids: "east:8,north:pass,west:pass")
        app.buttons["tarneeb-deal-button"].tap()
        waitForBid(app)
        XCTAssertEqual(app.staticTexts["tarneeb-opening-status"].label, "طلب · East leads with 8")
        XCTAssertFalse(app.buttons["7"].exists)
        XCTAssertFalse(app.buttons["8"].exists)
        XCTAssertTrue(app.buttons["9"].exists)
        app.buttons["13"].tap()
        app.buttons["tarneeb-bid-button-south"].tap()
        XCTAssertTrue(app.buttons["tarneeb-post-bidding-suit-button-south"].waitForExistence(timeout: 8))
    }

    func testBidGridHasSeparatePassAndExplicitConfirmation() {
        let app = launch(reducedMotion: true)
        app.buttons["tarneeb-deal-button"].tap()
        waitForBid(app)
        XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].isEnabled)
        XCTAssertTrue(app.buttons["tarneeb-pass-button-south"].isHittable)
        let grid = app.otherElements["tarneeb-bid-grid"]
        XCTAssertTrue(grid.frame.contains(app.buttons["tarneeb-pass-button-south"].frame))
        XCTAssertTrue(grid.frame.contains(app.buttons["tarneeb-bid-button-south"].frame))
        XCTAssertGreaterThanOrEqual(app.buttons["tarneeb-pass-button-south"].frame.height, 44)
        XCTAssertGreaterThanOrEqual(app.buttons["tarneeb-bid-button-south"].frame.height, 44)
        for bid in ["7", "10", "11", "12", "13"] {
            let option = app.buttons["tarneeb-bid-option-\(bid)"]
            XCTAssertTrue(option.isHittable)
            XCTAssertGreaterThanOrEqual(option.frame.height, 44)
            XCTAssertTrue(app.frame.contains(option.frame))
            option.tap()
            XCTAssertEqual(app.buttons["tarneeb-bid-button-south"].label, "Bid \(bid)")
            XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].isEnabled)
            XCTAssertFalse(app.buttons["tarneeb-post-bidding-suit-button-south"].exists)
        }
    }

    private func tapAlert(_ title: String, app: XCUIApplication) {
        let button = app.alerts.buttons[title]
        var previousFrame: CGRect?
        expectation(for: NSPredicate { _, _ in
            guard button.exists, button.isHittable else { return false }
            let frame = button.frame
            defer { previousFrame = frame }
            return previousFrame == frame
        }, evaluatedWith: button)
        waitForExpectations(timeout: 4)
        button.tap()
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: button)
        waitForExpectations(timeout: 4)
    }
}

final class TarneebLiveTableUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchLiveTable(reducedMotion: Bool = false, fixture: String = "1") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["TARNEEB_LIVE_FIXTURE"] = fixture
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reducedMotion ? "1" : "0"
        app.launch()
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 5))
        return app
    }

    func testB2DistributionMatrixAndPackedHandStability() {
        for fixture in ["4-4-3-2", "5-4-3-1", "6-3-2-2", "7-3-2-1",
                        "8-2-2-1", "10-1-1-1", "13-0-0-0", "4-3-3-3", "5-5-3-0"] {
            let app = launchLiveTable(fixture: fixture)
            let cards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-"))
            XCTAssertEqual(cards.count, 13)
            let elements = cards.allElementsBoundByIndex
            let upperY = elements.map { $0.frame.midY }.min()!
            let upper = elements.filter { abs($0.frame.midY - upperY) < 1 }
            let lower = elements.filter { $0.frame.midY > upperY + 60 }
            XCTAssertEqual([upper.count, lower.count].sorted(), [6, 7])
            let fallback = ["8-2-2-1", "10-1-1-1", "13-0-0-0", "5-5-3-0"].contains(fixture)
            for suit in ["spades", "clubs", "hearts", "diamonds"] where !fallback {
                XCTAssertFalse(upper.contains { $0.identifier.contains("-\(suit)-") } && lower.contains { $0.identifier.contains("-\(suit)-") })
            }
            for card in elements {
                // Accessibility includes the one-point face border and pixel rounding.
                XCTAssertEqual(card.frame.width, 65, accuracy: 0.5)
                XCTAssertEqual(card.frame.height, 91, accuracy: 0.5)
                XCTAssertTrue(app.frame.contains(card.frame))
                XCTAssertTrue(card.isHittable)
            }
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = "B2 distribution \(fixture)"
            shot.lifetime = .keepAlways
            add(shot)
            if fixture == "4-4-3-2" {
                let initialY = Dictionary(uniqueKeysWithValues: elements.map { ($0.identifier, $0.frame.midY) })
                for remaining in stride(from: 13, through: 2, by: -1) {
                    let legal = cards.matching(NSPredicate(format: "enabled == true")).firstMatch
                    XCTAssertTrue(legal.waitForExistence(timeout: 20))
                    XCTAssertEqual(cards.count, remaining)
                    for card in cards.allElementsBoundByIndex {
                        XCTAssertEqual(card.frame.midY, remaining > 7 ? initialY[card.identifier]! : upperY, accuracy: 0.5)
                    }
                    legal.tap()
                    expectation(for: NSPredicate(format: "value == %@", "Selected"), evaluatedWith: legal)
                    waitForExpectations(timeout: 3)
                    // Accessibility bounds include the original button and lifted face.
                    let expectedMinY = (remaining > 7 ? initialY[legal.identifier]! : upperY) - 45.5 - 12
                    expectation(for: NSPredicate { _, _ in abs(legal.frame.minY - expectedMinY) <= 2 }, evaluatedWith: legal)
                    waitForExpectations(timeout: 3)
                    if remaining == 13 {
                        legal.press(forDuration: 0.05, thenDragTo: app.otherElements["tarneeb-live-trick"])
                    } else { legal.doubleTap() }
                    expectation(for: NSPredicate { _, _ in cards.count < remaining }, evaluatedWith: cards)
                    waitForExpectations(timeout: 6)
                }
                XCTAssertTrue(app.otherElements["tarneeb-round-result"].waitForExistence(timeout: 25))
            }
            app.terminate()
        }
    }

    func testReadableHandSelectionAndOneCompleteTrick() {
        verifyOneTrick(reducedMotion: false)
    }

    func testShortHandStaysInUpperRow() { verifyShortHand(reducedMotion: false) }
    func testReducedMotionShortHandStaysInUpperRow() { verifyShortHand(reducedMotion: true) }

    private func verifyShortHand(reducedMotion: Bool) {
        let app = launchLiveTable(reducedMotion: reducedMotion)
        let cards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-"))
        let upperY = cards.element(boundBy: 0).frame.midY
        let upperMinY = cards.element(boundBy: 0).frame.minY
        let originalSize = cards.element(boundBy: 0).frame.size
        for remaining in stride(from: 13, through: 2, by: -1) {
            let legal = cards.matching(NSPredicate(format: "enabled == true")).firstMatch
            XCTAssertTrue(legal.waitForExistence(timeout: 20))
            XCTAssertEqual(cards.count, remaining)
            if remaining == 8 {
                XCTAssertGreaterThan(cards.element(boundBy: 7).frame.midY, upperY + 60)
            }
            if remaining <= 7 {
                for card in cards.allElementsBoundByIndex {
                    XCTAssertEqual(card.frame.midY, upperY, accuracy: 0.5)
                    XCTAssertEqual(card.frame.width, originalSize.width, accuracy: 0.5)
                    XCTAssertEqual(card.frame.height, originalSize.height, accuracy: 0.5)
                    XCTAssertTrue(app.frame.contains(card.frame))
                }
                XCTAssertTrue(legal.isHittable)
                if remaining == 7 || remaining == 2 {
                    let shot = XCTAttachment(screenshot: app.screenshot())
                    shot.name = "Upper anchored South hand \(remaining) cards"
                    shot.lifetime = .keepAlways
                    add(shot)
                }
                legal.tap()
                expectation(for: NSPredicate(format: "value == %@", "Selected"), evaluatedWith: legal)
                waitForExpectations(timeout: 3)
                expectation(for: NSPredicate { _, _ in legal.frame.minY <= upperMinY - 11 }, evaluatedWith: legal)
                waitForExpectations(timeout: 3)
            }
            legal.doubleTap()
            expectation(for: NSPredicate { _, _ in cards.count < remaining }, evaluatedWith: cards)
            waitForExpectations(timeout: 6)
            if remaining == 2 {
                XCTAssertEqual(cards.count, 1)
                XCTAssertEqual(cards.firstMatch.frame.midY, upperY, accuracy: 0.5)
                let shot = XCTAttachment(screenshot: app.screenshot())
                shot.name = "Upper anchored final South card before automatic play"
                shot.lifetime = .keepAlways
                add(shot)
            }
        }
        XCTAssertTrue(app.otherElements["tarneeb-round-result"].waitForExistence(timeout: 25))
    }

    func testContractMilestoneAcknowledgesSeventhTrickWithoutStoppingPlay() {
        verifyContractMilestone(reducedMotion: false)
    }

    func testReducedMotionContractMilestonePreservesProgress() {
        verifyContractMilestone(reducedMotion: true)
    }

    private func verifyContractMilestone(reducedMotion: Bool) {
        let app = launchLiveTable(reducedMotion: reducedMotion, fixture: "contract-six")
        let progress = app.staticTexts["tarneeb-contract-progress"]
        XCTAssertEqual(progress.label, "One more trick")
        XCTAssertTrue((progress.value as? String ?? "").contains("6 of 7"))
        XCTAssertTrue(app.frame.contains(progress.frame))
        XCTAssertFalse(progress.frame.intersects(app.staticTexts["tarneeb-live-contract-bid"].frame))
        let before = XCTAttachment(screenshot: app.screenshot())
        before.name = "One trick from contract"
        before.lifetime = .keepAlways
        add(before)
        app.buttons["tarneeb-live-card-spades-8"].doubleTap()
        expectation(for: NSPredicate(format: "label == %@", "Contract secured"), evaluatedWith: progress)
        waitForExpectations(timeout: 12)
        XCTAssertTrue((progress.value as? String ?? "").contains("7 of 7"))
        expectation(for: NSPredicate(format: "label == %@", "Your turn"), evaluatedWith: app.staticTexts["tarneeb-live-status"])
        waitForExpectations(timeout: 8)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 6)
        let after = XCTAttachment(screenshot: app.screenshot())
        after.name = "Contract secured and play continues"
        after.lifetime = .keepAlways
        add(after)
        app.buttons["tarneeb-live-card-spades-9"].doubleTap()
        expectation(for: NSPredicate(format: "value CONTAINS %@", "8 of 7"), evaluatedWith: progress)
        waitForExpectations(timeout: 12)
        XCTAssertEqual(progress.label, "Contract secured")
    }

    func testLastCardPlaysAutomaticallyAfterPreviousTrickCollection() {
        let app = launchLiveTable(fixture: "last-two")
        let cards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-"))
        XCTAssertEqual(cards.count, 2)
        app.buttons["tarneeb-live-card-spades-K"].doubleTap()
        XCTAssertTrue(app.staticTexts["North South score 16"].waitForExistence(timeout: 25))
    }

    func testLastCardPlaysAutomaticallyWithReducedMotionAndResume() {
        let app = launchLiveTable(reducedMotion: true, fixture: "last-one")
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(app.staticTexts["North South score 16"].waitForExistence(timeout: 20))
    }

    func testReducedMotionCompletesTheSameTrick() {
        verifyOneTrick(reducedMotion: true)
    }

    private func verifyOneTrick(reducedMotion: Bool) {
        let app = launchLiveTable(reducedMotion: reducedMotion)
        let score = app.staticTexts["North South score 0"]
        XCTAssertTrue(score.exists)
        XCTAssertTrue(app.staticTexts["East West score 0"].exists)
        XCTAssertTrue(app.frame.contains(score.frame))
        XCTAssertFalse(score.frame.intersects(app.buttons["tarneeb-last-trick"].frame))
        let cards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-"))
        XCTAssertEqual(cards.count, 13)
        let ownTricks = app.staticTexts["tarneeb-live-south-tricks"]
        XCTAssertTrue(ownTricks.exists)
        XCTAssertEqual(ownTricks.value as? String, "0")
        XCTAssertTrue(app.frame.contains(ownTricks.frame))
        for card in cards.allElementsBoundByIndex {
            XCTAssertTrue(app.frame.contains(card.frame))
            XCTAssertGreaterThanOrEqual(card.frame.width, 44)
            XCTAssertGreaterThanOrEqual(card.frame.height, 44)
            XCTAssertTrue(card.isHittable)
        }
        let button = app.buttons["tarneeb-play-card"]
        XCTAssertFalse(button.exists)
        let first = app.buttons["tarneeb-live-card-spades-2"]
        let originalY = first.frame.minY
        first.tap()
        expectation(for: NSPredicate(format: "value == %@", "Selected"), evaluatedWith: first)
        waitForExpectations(timeout: 3)
        XCTAssertEqual(cards.count, 13)
        XCTAssertLessThan(first.frame.minY, originalY)
        XCTAssertEqual(first.value as? String, "Selected")
        let lifted = NSPredicate { _, _ in first.frame.minY <= originalY - 11 }
        expectation(for: lifted, evaluatedWith: first)
        waitForExpectations(timeout: 3)
        let selected = XCTAttachment(screenshot: app.screenshot())
        selected.name = "Readable selected hand"
        selected.lifetime = .keepAlways
        add(selected)
        first.doubleTap()
        XCTAssertTrue(app.staticTexts["tarneeb-live-status"].waitForExistence(timeout: 8))
        let completed = NSPredicate(format: "label == %@", "1 / 7 tricks")
        expectation(for: completed, evaluatedWith: app.staticTexts["tarneeb-contract-progress"])
        waitForExpectations(timeout: 12)
        expectation(for: NSPredicate(format: "value == %@", "1"), evaluatedWith: ownTricks)
        waitForExpectations(timeout: 5)
        XCTAssertEqual(ownTricks.value as? String, "1")
        XCTAssertFalse(ownTricks.frame.intersects(app.staticTexts["tarneeb-live-status"].frame))
        XCTAssertEqual(cards.count, 12)
        XCTAssertFalse(first.exists)
        XCTAssertFalse(button.exists)
        expectation(for: NSPredicate(format: "label == %@", "Your turn"), evaluatedWith: app.staticTexts["tarneeb-live-status"])
        waitForExpectations(timeout: 5)
        XCTAssertEqual(app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-played-")).count, 0)
        XCTAssertTrue(app.otherElements["tarneeb-live-station-south"].label.contains("playing"))
        XCTAssertEqual(ownTricks.value as? String, "1")
        XCTAssertEqual(cards.count, 12)
        app.buttons["tarneeb-live-card-spades-3"].doubleTap()
        expectation(for: NSPredicate(format: "value == %@", "2"), evaluatedWith: ownTricks)
        waitForExpectations(timeout: 12)
        XCTAssertEqual(cards.count, 11)
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-3"].exists)
    }

    func testOptionsConfirmationResumesAndResetReturnsToOpeningDeal() {
        let app = launchLiveTable()
        app.buttons["tarneeb-game-options"].tap()
        app.buttons["New Game"].tap()
        if app.buttons["Keep Playing"].exists {
            tapSettledConfirmation("Keep Playing", in: app)
        } else {
            // The modal can make underlying semantic elements non-hittable.
            // Tap outside using screen coordinates rather than a hidden label.
            // Large accessibility text can expand the popover nearly edge-to-edge.
            let outside = app.coordinate(withNormalizedOffset: CGVector(dx: 0.005, dy: 0.25))
            XCTAssertFalse(app.buttons["Cancel Game"].frame.contains(outside.screenPoint))
            outside.tap()
            expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.buttons["Cancel Game"])
            waitForExpectations(timeout: 4)
        }
        let card = app.buttons["tarneeb-live-card-spades-2"]
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: card)
        waitForExpectations(timeout: 4)
        card.tap()
        expectation(for: NSPredicate(format: "value == %@", "Selected"), evaluatedWith: card)
        waitForExpectations(timeout: 3)
        XCTAssertFalse(app.buttons["tarneeb-play-card"].exists)
        app.buttons["tarneeb-game-options"].tap()
        app.buttons["New Game"].tap()
        tapSettledConfirmation("Cancel Game", in: app)
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.otherElements["tarneeb-live-table"].exists)
    }

    private func tapSettledConfirmation(_ title: String, in app: XCUIApplication) {
        let button = app.buttons[title]
        var previousFrame: CGRect?
        // Older runtimes publish sheet button frames before their presentation finishes.
        let settled = NSPredicate { _, _ in
            guard button.exists, button.isHittable else { return false }
            let frame = button.frame
            defer { previousFrame = frame }
            return previousFrame == frame
        }
        expectation(for: settled, evaluatedWith: button)
        waitForExpectations(timeout: 4)
        button.tap()
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: button)
        waitForExpectations(timeout: 4)
    }

    func testBackgroundingDuringPlayResumesWithoutDuplicatingCards() {
        let app = launchLiveTable()
        app.buttons["tarneeb-live-card-spades-2"].doubleTap()
        XCUIDevice.shared.press(.home)
        app.activate()
        let completed = NSPredicate(format: "label == %@", "1 / 7 tricks")
        expectation(for: completed, evaluatedWith: app.staticTexts["tarneeb-contract-progress"])
        waitForExpectations(timeout: 12)
        expectation(for: NSPredicate(format: "label == %@", "Your turn"), evaluatedWith: app.staticTexts["tarneeb-live-status"])
        waitForExpectations(timeout: 5)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 12)
        XCTAssertEqual(app.staticTexts["tarneeb-live-status"].label, "Your turn")
    }

    func testMixedSuitHandAndDragPlayRespectFollowingSuit() {
        let app = launchLiveTable(fixture: "balanced")
        let initial = XCTAttachment(screenshot: app.screenshot())
        initial.name = "Mixed-suit live table"
        initial.lifetime = .keepAlways
        add(initial)
        let draggedCard = app.buttons["tarneeb-live-card-spades-2"]
        draggedCard.press(forDuration: 0.05, thenDragTo: app.otherElements["tarneeb-live-trick"])
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: draggedCard)
        waitForExpectations(timeout: 4)
        let turn = NSPredicate(format: "label == %@", "Your turn")
        expectation(for: turn, evaluatedWith: app.staticTexts["tarneeb-live-status"])
        waitForExpectations(timeout: 25)
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-2"].exists)
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-6"].isEnabled)
        XCTAssertTrue(app.buttons["tarneeb-live-card-diamonds-3"].isEnabled)
        XCTAssertEqual(app.staticTexts["tarneeb-live-south-tricks"].value as? String, "0")
        app.buttons["tarneeb-live-card-spades-6"].doubleTap()
        XCTAssertTrue(app.buttons["tarneeb-live-card-spades-6"].exists)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 12)
        XCTAssertEqual(app.staticTexts["tarneeb-live-status"].label, "Your turn")
    }

    func testRapidRepeatedPlayThenNextLeadKeepsOneCardPerTurn() {
        let app = launchLiveTable(reducedMotion: true)
        let first = app.buttons["tarneeb-live-card-spades-2"]
        first.doubleTap()
        if first.exists { first.doubleTap() }
        expectation(for: NSPredicate(format: "label == %@", "Your turn"), evaluatedWith: app.staticTexts["tarneeb-live-status"])
        waitForExpectations(timeout: 12)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 12)
        app.buttons["tarneeb-live-card-spades-3"].doubleTap()
        expectation(for: NSPredicate(format: "value CONTAINS %@", "2 of 7"), evaluatedWith: app.staticTexts["tarneeb-contract-progress"])
        waitForExpectations(timeout: 12)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 11)
    }

    func testPartnerWinAndNextLeadFromActualBalancedHand() {
        let app = launchLiveTable(fixture: "balanced")
        let cards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-"))
        for remaining in stride(from: 13, through: 10, by: -1) {
            let legal = cards.matching(NSPredicate(format: "enabled == true")).firstMatch
            XCTAssertTrue(legal.waitForExistence(timeout: 20))
            XCTAssertEqual(cards.count, remaining)
            legal.doubleTap()
            expectation(for: NSPredicate { _, _ in cards.count < remaining }, evaluatedWith: cards)
            waitForExpectations(timeout: 6)
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = "Balanced hand step \(14 - remaining)"
            shot.lifetime = .keepAlways
            add(shot)
        }
        expectation(for: NSPredicate(format: "value CONTAINS %@", "2 of 7"), evaluatedWith: app.staticTexts["tarneeb-contract-progress"])
        waitForExpectations(timeout: 12)
        XCTAssertEqual(app.staticTexts["tarneeb-live-team-tricks"].value as? String, "2")
        let coherent = XCTAttachment(screenshot: app.screenshot())
        coherent.name = "Partner win coherent contract and team totals"
        coherent.lifetime = .keepAlways
        add(coherent)
        let nextLegal = cards.matching(NSPredicate(format: "enabled == true")).firstMatch
        XCTAssertTrue(nextLegal.waitForExistence(timeout: 20))
        let partner = app.otherElements["tarneeb-live-station-north"]
        XCTAssertTrue(partner.label.contains("your partner"))
        XCTAssertFalse(partner.label.contains("0 tricks"), partner.label)
        XCTAssertEqual(app.staticTexts["North South score 0"].label, "North South score 0")
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "Partner ownership retained on next turn"
        shot.lifetime = .keepAlways
        add(shot)
    }

    func testQuickDragOutsideTableDoesNotPlayOrRemoveCard() {
        let app = launchLiveTable()
        let card = app.buttons["tarneeb-live-card-spades-2"]
        card.press(forDuration: 0.05, thenDragTo: app.staticTexts["tarneeb-live-south-tricks"])
        XCTAssertTrue(card.exists)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 13)
        XCTAssertEqual(app.staticTexts["tarneeb-live-south-tricks"].value as? String, "0")
        XCTAssertEqual(app.staticTexts["tarneeb-live-status"].label, "Your turn")
        card.doubleTap()
        expectation(for: NSPredicate(format: "value == %@", "1"), evaluatedWith: app.staticTexts["tarneeb-live-south-tricks"])
        waitForExpectations(timeout: 12)
    }
}

final class TarneebLaunchUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIDevice.shared.orientation = .portrait }

    private func launch(dealer: String = "west", bids: String = "east:pass,north:pass,west:pass", reducedMotion: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        if ["testSouthCardsStayUnrevealedWhileIndividualBacksAreVisible", "testSouthRevealShowsBacksThenFlipsBeforeCompletion", "testSouthIndividualBacksStayVisibleUntilFinalReveal"].contains(where: name.contains) {
            app.launchEnvironment["TARNEEB_CAPTURE_DEAL"] = "1"
        }
        if ["testSouthIndividualBacksStayVisibleUntilFinalReveal", "testDealPacketLandingsStaySequentialBeforeCompletion"].contains(where: name.contains) {
            app.launchEnvironment["TARNEEB_CAPTURE_DEAL"] = "1"
            app.launchEnvironment["TARNEEB_CAPTURE_PACKET_LANDINGS"] = "1"
        }
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = dealer
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = bids
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reducedMotion ? "1" : "0"
        app.launch()
        waitForInteractiveOpening(app)
        return app
    }
    private func cards(_ app: XCUIApplication) -> XCUIElementQuery {
        app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-"))
    }
    private func waitForBid(_ app: XCUIApplication) {
        let advance = app.buttons["tarneeb-deal-phase-continue"]
        if app.launchEnvironment["TARNEEB_CAPTURE_DEAL"] == "1" {
            // South may receive its thirteen first. Wait for all three external hands and the retained dealer hand.
            XCTAssertTrue(advance.waitForExistence(timeout: 25))
            XCTAssertEqual(advance.value as? String, "3-packets-landed-13-retained-stack")
            for phase in ["spread-settled-backs", "reveal-settled-faces"] {
                advance.tap()
                expectation(for: NSPredicate(format: "value == %@", phase), evaluatedWith: advance)
                waitForExpectations(timeout: 5)
            }
            advance.tap()
        }
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 35))
        XCTAssertEqual(cards(app).count, 13)
        XCTAssertFalse(app.otherElements["tarneeb-opening-deck"].exists)
    }
    private func deal(_ app: XCUIApplication) { app.buttons["tarneeb-deal-button"].tap(); waitForBid(app) }
    private func backs(_ app: XCUIApplication) {
        app.buttons["tarneeb-deal-button"].tap()
        let hand = app.otherElements["tarneeb-opening-hand"]
        expectation(for: NSPredicate(format: "value CONTAINS %@", "faceDown=13;revealed=0"), evaluatedWith: hand)
        waitForExpectations(timeout: 25)
        XCTAssertEqual(cards(app).count, 13)
        XCTAssertEqual(Set(cards(app).allElementsBoundByIndex.map(\.label)), ["Face-down card"])
    }
    private func shot(_ name: String, _ app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    private func chooseBid(_ app: XCUIApplication, _ bid: String = "7") {
        app.buttons["tarneeb-bid-option-\(bid)"].tap()
        app.buttons["tarneeb-bid-button-south"].tap()
        XCTAssertTrue(app.buttons["tarneeb-post-bidding-suit-button-south"].waitForExistence(timeout: 20))
    }
    private func reset(_ app: XCUIApplication, cancel: Bool) {
        app.buttons["tarneeb-game-options"].tap(); app.buttons["New Game"].tap()
        let button = app.alerts.buttons[cancel ? "Cancel Game" : "Keep Playing"]
        XCTAssertTrue(button.waitForExistence(timeout: 4))
        let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: button)
        XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 4), .completed)
        button.tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForNonExistence(timeout: 4))
    }

    func testIntroFinishesAndDoesNotReplayOnResume() {
        let app = launch()
        XCTAssertFalse(app.otherElements["tarneeb-launch-intro"].exists)
        XCUIDevice.shared.press(.home); app.activate()
        XCTAssertFalse(app.otherElements["tarneeb-launch-intro"].exists)
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].isHittable)
    }
    func testSupportedPortraitLayoutKeepsOpeningCommandsReachable() {
        let app = launch()
        for identifier in ["tarneeb-deal-button", "tarneeb-game-options"] {
            let button = app.buttons[identifier]
            XCTAssertTrue(app.frame.contains(button.frame))
            XCTAssertTrue(button.isHittable)
            XCTAssertGreaterThanOrEqual(button.frame.height, 44)
            XCTAssertGreaterThanOrEqual(button.frame.width, 44)
        }
    }
    func testInitialScreenShowsPortraitTableTitleDeckStackStationsAndBottomDeal() {
        let app = launch()
        XCTAssertEqual(app.staticTexts["tarneeb-table-title"].label, "طرنيب")
        XCTAssertEqual(app.otherElements["tarneeb-opening-deck"].value as? String, "52 cards")
        XCTAssertLessThan(app.frame.width, app.frame.height)
        for seat in ["south", "east", "north", "west"] { XCTAssertTrue(app.otherElements["tarneeb-opening-station-\(seat)"].exists) }
        XCTAssertTrue(app.otherElements["tarneeb-opening-station-north"].label.contains("partner"))
        XCTAssertTrue(app.otherElements["tarneeb-opening-station-west"].label.contains("dealer"))
        XCTAssertEqual(cards(app).count, 0)
        let deal = app.buttons["tarneeb-deal-button"]
        XCTAssertGreaterThanOrEqual(deal.frame.height, 44)
        XCTAssertGreaterThan(deal.frame.midY, app.frame.height * 0.8)
    }
    func testOpeningExposesSemanticSeatDealerAndScoreInformation() {
        let app = launch(dealer: "east")
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
        XCTAssertTrue(app.staticTexts["East West score 0"].exists)
        XCTAssertEqual(app.staticTexts["tarneeb-match-target"].label, "First to 31")
        XCTAssertTrue(app.otherElements["tarneeb-opening-station-east"].label.contains("dealer"))
        XCTAssertFalse(app.otherElements["tarneeb-opening-station-west"].label.contains("dealer"))
        XCTAssertEqual(app.buttons["tarneeb-game-options"].label, "Game options")
    }
    func testAppRemainsPortraitWhenDeviceRotates() {
        let app = launch(); let initial = app.frame
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertLessThan(app.frame.width, app.frame.height)
        XCTAssertEqual(app.frame.size, initial.size)
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].isHittable)
    }
    func testTappingDealShowsDealtTableAndHidesUndealtDeckStack() {
        let app = launch(); deal(app)
        XCTAssertTrue(app.otherElements["tarneeb-opening-hand"].exists)
        XCTAssertTrue(app.buttons["tarneeb-pass-button-south"].isHittable)
        XCTAssertFalse(app.buttons["tarneeb-deal-button"].exists)
        XCTAssertEqual(app.staticTexts["tarneeb-opening-status"].label, "طلب · Bidding")
    }
    func testDealPacketLandingsStaySequentialBeforeCompletion() {
        let app = launch(reducedMotion: false)
        app.buttons["tarneeb-deal-button"].tap()
        let advance = app.buttons["tarneeb-deal-phase-continue"]
        XCTAssertTrue(advance.waitForExistence(timeout: 8))
        for packet in 1...2 {
            XCTAssertEqual(advance.value as? String, "packet-\(packet)-landed")
            XCTAssertEqual(app.otherElements["tarneeb-opening-deck"].value as? String, "\(52 - packet * 13) cards")
            XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
            advance.tap()
            let phase = packet == 1 ? "packet-2-landed" : "3-packets-landed-13-retained-stack"
            expectation(for: NSPredicate(format: "value == %@", phase), evaluatedWith: advance)
            waitForExpectations(timeout: 8)
        }
        waitForBid(app)
        XCTAssertFalse(app.otherElements["tarneeb-opening-packet"].exists)
    }
    func testSouthCardsStayUnrevealedWhileIndividualBacksAreVisible() {
        let app = launch(reducedMotion: false); backs(app)
        XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
        shot("Migrated coverage · individual South backs", app)
        waitForBid(app)
    }
    func testSouthRevealShowsBacksThenFlipsBeforeCompletion() {
        let app = launch(reducedMotion: false); backs(app); waitForBid(app)
        XCTAssertFalse(cards(app).allElementsBoundByIndex.contains { $0.label == "Face-down card" })
        XCTAssertEqual(app.otherElements["tarneeb-opening-hand"].value as? String, "Face-up hand")
    }
    func testSouthIndividualBacksStayVisibleUntilFinalReveal() {
        let app = launch(reducedMotion: false); backs(app)
        let hand = app.otherElements["tarneeb-opening-hand"]
        XCTAssertTrue(hand.exists)
        XCTAssertTrue((hand.value as? String ?? "").contains("source=west"))
        XCTAssertTrue((hand.value as? String ?? "").contains("faceDown=13;revealed=0"))
        XCTAssertTrue((hand.value as? String ?? "").contains("spread=0.0"))
        let deck = app.otherElements["tarneeb-opening-deck"]
        XCTAssertTrue(deck.exists, "West must keep its remaining deck after the first South hand")
        let remaining = Int((deck.value as? String ?? "").split(separator: " ").first ?? "")
        XCTAssertNotNil(remaining)
        if let remaining { XCTAssertEqual(remaining, 39) }
        let packetAdvance = app.buttons["tarneeb-deal-phase-continue"]
        XCTAssertEqual(packetAdvance.value as? String, "packet-1-landed")
        let compact = cards(app).allElementsBoundByIndex.map(\.frame)
        for frame in compact {
            XCTAssertEqual(frame.midX, compact[0].midX, accuracy: 0.5)
            XCTAssertEqual(frame.midY, compact[0].midY, accuracy: 0.5)
        }
        XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
        shot("West dealer retains remaining deck while first South hand stays compact", app)
        packetAdvance.tap()
        expectation(for: NSPredicate(format: "value == %@", "packet-2-landed"), evaluatedWith: packetAdvance)
        waitForExpectations(timeout: 8)
        XCTAssertEqual(deck.value as? String, "26 cards")
        XCTAssertTrue((hand.value as? String ?? "").contains("faceDown=13;revealed=0"))
        XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
        packetAdvance.tap()
        let advance = packetAdvance
        expectation(for: NSPredicate(format: "value == %@", "3-packets-landed-13-retained-stack"), evaluatedWith: advance)
        waitForExpectations(timeout: 8)
        XCTAssertTrue((hand.value as? String ?? "").contains("packetsLanded=3;packetsIssued=3;retained=13;established=52;packetsInFlight=0"))
        XCTAssertFalse(deck.exists)
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "tarneeb-deal-stack-west").firstMatch.value as? String, "13 cards")
        XCTAssertEqual(Set(cards(app).allElementsBoundByIndex.map(\.label)), ["Face-down card"])
        XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
        waitForBid(app)
        XCTAssertEqual(cards(app).count, 13)
        for card in cards(app).allElementsBoundByIndex {
            XCTAssertEqual(card.frame.width, 65, accuracy: 0.5)
            XCTAssertEqual(card.frame.height, 91, accuracy: 0.5)
        }
    }
    func testDealtScreenKeepsCardSizeAndSemanticHandInformation() {
        let app = launch(); deal(app)
        for card in cards(app).allElementsBoundByIndex {
            XCTAssertEqual(card.frame.width, 65, accuracy: 0.5)
            XCTAssertEqual(card.frame.height, 91, accuracy: 0.5)
            XCTAssertTrue(card.label.contains(" of "))
            XCTAssertTrue(app.frame.contains(card.frame))
        }
        XCTAssertEqual(app.otherElements["tarneeb-opening-hand"].value as? String, "Face-up hand")
    }
    func testSouthCardsAreSortedAndNotActionable() {
        let app = launch(); deal(app)
        let expected = ["4 of hearts", "8 of hearts", "Q of hearts", "5 of clubs", "9 of clubs", "K of clubs", "3 of diamonds", "7 of diamonds", "J of diamonds", "2 of spades", "6 of spades", "10 of spades", "A of spades"]
        XCTAssertEqual(cards(app).allElementsBoundByIndex.map(\.label), expected)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-")).count, 0)
        cards(app).firstMatch.tap()
        XCTAssertEqual(cards(app).allElementsBoundByIndex.map(\.label), expected)
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-2"].exists)
    }
    func testSimulatedHandsKeepPrivateCardsAndHideOrdinaryRemainingCounts() {
        let app = launch(); deal(app)
        for seat in ["west", "north", "east"] {
            let station = app.otherElements["tarneeb-opening-station-\(seat)"]
            XCTAssertTrue(station.exists)
            XCTAssertFalse((station.value as? String ?? "").contains("cards"))
            XCTAssertFalse(station.label.contains(" of "))
        }
        XCTAssertEqual(cards(app).count, 13)
    }
    func testBidAreaAppearsAfterDealWithLegalValuesForAllPlayers() {
        let app = launch(dealer: "south", bids: "east:8,north:pass,west:pass"); deal(app)
        XCTAssertFalse(app.buttons["tarneeb-bid-option-7"].exists)
        XCTAssertFalse(app.buttons["tarneeb-bid-option-8"].exists)
        for bid in 9...13 { XCTAssertTrue(app.buttons["tarneeb-bid-option-\(bid)"].isHittable) }
        XCTAssertTrue((app.otherElements["tarneeb-opening-station-east"].value as? String ?? "").contains("8"))
        XCTAssertTrue((app.otherElements["tarneeb-opening-station-north"].value as? String ?? "").contains("Pass"))
    }
    func testSouthBidChipsShowAllowedValuesAndUpdateSelection() {
        let app = launch(); deal(app)
        let status = app.staticTexts["tarneeb-opening-status"].label
        for bid in ["7", "10", "13"] {
            app.buttons["tarneeb-bid-option-\(bid)"].tap()
            XCTAssertEqual(app.buttons["tarneeb-bid-button-south"].label, "Bid \(bid)")
            XCTAssertEqual(app.staticTexts["tarneeb-opening-status"].label, status)
            XCTAssertFalse(app.buttons["tarneeb-post-bidding-suit-button-south"].exists)
        }
        chooseBid(app, "13")
        XCTAssertEqual(app.staticTexts["tarneeb-opening-status"].label, "You won the bid: 13")
    }
    func testSouthPassRemainsReadonlyAfterLaterPlayerRaises() {
        let app = launch(bids: "east:8,north:pass,west:pass"); deal(app)
        app.buttons["tarneeb-pass-button-south"].tap()
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 25))
        XCTAssertEqual(app.staticTexts["tarneeb-live-contract-bid"].label, "East bids 8")
        XCTAssertFalse(app.buttons["tarneeb-pass-button-south"].exists)
        XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
    }
    func testAllPassBiddingAutomaticallyRedealsAndRotatesDealer() {
        let app = launch(); deal(app)
        app.buttons["tarneeb-pass-button-south"].tap()
        XCTAssertTrue(app.otherElements["tarneeb-opening-south-dealer"].waitForExistence(timeout: 25))
        waitForBid(app)
        XCTAssertFalse(app.otherElements["tarneeb-opening-station-west"].label.contains("dealer"))
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
    }
    func testDealButtonCannotStartASecondDealDuringOrAfterOpening() {
        let app = launch(reducedMotion: false)
        let button = app.buttons["tarneeb-deal-button"]
        button.doubleTap()
        waitForBid(app)
        XCTAssertEqual(cards(app).count, 13)
        XCTAssertFalse(button.exists)
        XCTAssertTrue(app.otherElements["tarneeb-opening-station-west"].label.contains("dealer"))
    }
    func testNewGameButtonResetsToOriginalLaunchStateAfterDeal() {
        let app = launch(); deal(app); reset(app, cancel: false)
        XCTAssertEqual(cards(app).count, 13)
        reset(app, cancel: true)
        waitForInteractiveOpening(app)
        XCTAssertEqual(app.otherElements["tarneeb-opening-deck"].value as? String, "52 cards")
        XCTAssertEqual(cards(app).count, 0)
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
    }
    func testOpeningDealLeavesOnlyPhaseAppropriateCommandsLive() {
        let app = launch(); deal(app)
        XCTAssertFalse(app.buttons["tarneeb-deal-button"].exists)
        XCTAssertTrue(app.buttons["tarneeb-game-options"].isHittable)
        XCTAssertTrue(app.buttons["tarneeb-pass-button-south"].isHittable)
        XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].isEnabled)
        XCTAssertFalse(app.buttons["tarneeb-post-bidding-suit-button-south"].exists)
        XCTAssertFalse(app.buttons["tarneeb-next-hand"].exists)
    }
    func testPrimaryLayoutElementsRemainUsableAndNonOverlapping() {
        let app = launch(); deal(app)
        let grid = app.otherElements["tarneeb-bid-grid"]
        XCTAssertTrue(app.frame.contains(grid.frame))
        XCTAssertFalse(grid.frame.intersects(app.otherElements["tarneeb-opening-hand"].frame))
        for button in app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-bid-option-")).allElementsBoundByIndex {
            XCTAssertTrue(button.isHittable); XCTAssertGreaterThanOrEqual(button.frame.height, 44)
        }
        chooseBid(app)
        let north = app.otherElements["tarneeb-opening-station-north"].frame
        XCTAssertFalse(north.intersects(app.staticTexts["tarneeb-suit-heading"].frame))
        for suit in ["spades", "hearts", "clubs", "diamonds"] {
            let button = app.buttons["tarneeb-bid-suit-option-\(suit)"]
            XCTAssertTrue(button.isHittable); XCTAssertGreaterThanOrEqual(button.frame.height, 44)
            XCTAssertFalse(north.intersects(button.frame))
        }
        shot("Migrated coverage · readable trump controls", app)
    }
    func testOldDealLabelsAndOutOfScopeControlsAreAbsent() {
        let app = launch(); deal(app)
        // Actual bidding/play/recall are approved features; retired MVP prohibitions do not apply.
        for title in ["Deal Cards", "New Deal", "Resolve Trick", "Play Trick", "Multiplayer", "Account", "Saved Games"] {
            XCTAssertFalse(app.buttons[title].exists)
        }
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].exists)
    }
}

final class TarneebReleaseLifecycleUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    private func launch(fixtureKey: String, fixture: String, reducedMotion: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment[fixtureKey] = fixture
        app.launchEnvironment["TARNEEB_SAVE_TEST_ID"] = UUID().uuidString
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = "west"
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = "east:pass,north:pass,west:pass"
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reducedMotion ? "1" : "0"
        app.launch()
        return app
    }
    private func resume(_ app: XCUIApplication) {
        app.terminate()
        for key in ["TARNEEB_OPENING_FIXTURE", "TARNEEB_LIVE_FIXTURE", "TARNEEB_RESULT_FIXTURE"] { app.launchEnvironment.removeValue(forKey: key) }
        app.launch()
        XCTAssertFalse(app.alerts["Match storage"].exists)
    }
    private func liveCards(_ app: XCUIApplication) -> XCUIElementQuery {
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-"))
    }
    private func waitForFirstTrick(_ app: XCUIApplication) {
        expectation(for: NSPredicate(format: "value == %@", "1"), evaluatedWith: app.staticTexts["tarneeb-live-team-tricks"])
        waitForExpectations(timeout: 20)
        XCTAssertEqual(liveCards(app).count, 12)
        XCTAssertTrue(app.staticTexts["0 tricks"].exists)
        XCTAssertTrue((app.staticTexts["tarneeb-contract-progress"].value as? String ?? "").contains("1 of 7"))
    }
    func testTerminateDuringDealRestoresOneAcceptedDeal() {
        let app = launch(fixtureKey: "TARNEEB_OPENING_FIXTURE", fixture: "1")
        waitForInteractiveOpening(app)
        app.buttons["tarneeb-deal-button"].doubleTap()
        resume(app)
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 30))
        XCTAssertEqual(app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-")).count, 13)
        XCTAssertFalse(app.otherElements["tarneeb-opening-packet"].exists)
        XCTAssertTrue(app.otherElements["tarneeb-opening-station-west"].label.contains("dealer"))
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
    }
    func testTerminateAfterCardInputRestoresCommittedPlayOnce() { verifyInterruptedPlay(reducedMotion: false) }
    func testReducedMotionTerminateAfterCardInputRestoresCommittedPlayOnce() { verifyInterruptedPlay(reducedMotion: true) }
    private func verifyInterruptedPlay(reducedMotion: Bool) {
        let app = launch(fixtureKey: "TARNEEB_LIVE_FIXTURE", fixture: "1", reducedMotion: reducedMotion)
        XCTAssertTrue(app.buttons["tarneeb-live-card-spades-2"].waitForExistence(timeout: 6))
        app.buttons["tarneeb-live-card-spades-2"].doubleTap()
        resume(app)
        waitForFirstTrick(app)
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-2"].exists)
        XCTAssertTrue(app.buttons["tarneeb-last-trick"].isHittable)
    }
    func testTerminateAfterResolvedTrickPreservesOwnershipAndRecall() {
        let app = launch(fixtureKey: "TARNEEB_LIVE_FIXTURE", fixture: "1")
        XCTAssertTrue(app.buttons["tarneeb-live-card-spades-2"].waitForExistence(timeout: 6))
        app.buttons["tarneeb-live-card-spades-2"].doubleTap()
        waitForFirstTrick(app)
        resume(app)
        waitForFirstTrick(app)
        let recall = app.buttons["tarneeb-last-trick"]
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: recall)
        waitForExpectations(timeout: 8)
        recall.tap()
        XCTAssertTrue(app.buttons["tarneeb-close-last-trick"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["You won the trick"].exists)
        app.buttons["tarneeb-close-last-trick"].tap()
        XCTAssertEqual(liveCards(app).count, 12)
    }
    func testTerminateResultRestoresSettledFactsAndNextHandOnce() {
        let app = launch(fixtureKey: "TARNEEB_RESULT_FIXTURE", fixture: "round-made")
        XCTAssertTrue(app.otherElements["tarneeb-round-result"].waitForExistence(timeout: 6))
        resume(app)
        let result = app.otherElements["tarneeb-round-result"]
        XCTAssertTrue(result.waitForExistence(timeout: 6))
        XCTAssertEqual(result.value as? String, "Saved result")
        XCTAssertTrue(app.staticTexts["North South score 16"].exists)
        app.buttons["tarneeb-next-hand"].doubleTap()
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 35))
        XCTAssertTrue(app.otherElements["tarneeb-opening-south-dealer"].exists)
        XCTAssertTrue(app.staticTexts["North South score 16"].exists)
    }
    func testLongerBackgroundAfterPlayResumesWithoutDuplicateActions() {
        let app = launch(fixtureKey: "TARNEEB_LIVE_FIXTURE", fixture: "1")
        XCTAssertTrue(app.buttons["tarneeb-live-card-spades-2"].waitForExistence(timeout: 6))
        app.buttons["tarneeb-live-card-spades-2"].doubleTap()
        XCUIDevice.shared.press(.home)
        Thread.sleep(forTimeInterval: 15)
        app.activate()
        waitForFirstTrick(app)
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-2"].exists)
    }
    func testRepeatedBidAndTrumpConfirmationMakeOneContract() {
        let app = launch(fixtureKey: "TARNEEB_OPENING_FIXTURE", fixture: "1", reducedMotion: true)
        waitForInteractiveOpening(app)
        app.buttons["tarneeb-deal-button"].doubleTap()
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 30))
        app.buttons["tarneeb-bid-option-7"].tap()
        app.buttons["tarneeb-bid-button-south"].doubleTap()
        XCTAssertTrue(app.buttons["tarneeb-post-bidding-suit-button-south"].waitForExistence(timeout: 20))
        app.buttons["tarneeb-bid-suit-option-spades"].tap()
        app.buttons["tarneeb-post-bidding-suit-button-south"].doubleTap()
        XCTAssertTrue(app.buttons["tarneeb-live-card-spades-2"].waitForExistence(timeout: 6))
        XCTAssertEqual(liveCards(app).count, 13)
        XCTAssertEqual(app.staticTexts["tarneeb-live-contract-bid"].label, "You bid 7")
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
    }
}

final class TarneebReleaseAccessibilityUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    private func shot(_ name: String, _ app: XCUIApplication) {
        let a = XCTAttachment(screenshot: app.screenshot()); a.name = name; a.lifetime = .keepAlways; add(a)
        let tree = XCTAttachment(string: app.debugDescription); tree.name = name + " accessibility hierarchy"; tree.lifetime = .keepAlways; add(tree)
    }
    private func verifyWithoutFeedback(sound: Bool, haptics: Bool, reducedMotion: Bool, maximumText: Bool = false) {
        let app = XCUIApplication()
        if maximumText {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        }
        app.launchArguments += ["-tarneeb.soundEnabled", sound ? "YES" : "NO", "-tarneeb.hapticsEnabled", haptics ? "YES" : "NO"]
        app.launchEnvironment["TARNEEB_LIVE_FIXTURE"] = "1"
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reducedMotion ? "1" : "0"
        app.launch()
        let first = app.buttons["tarneeb-live-card-spades-2"]
        XCTAssertTrue(first.waitForExistence(timeout: 6))
        XCTAssertEqual(first.label, "2 of spades")
        XCTAssertEqual(first.value as? String, "Playable")
        XCTAssertTrue(app.otherElements["tarneeb-live-station-north"].label.contains("your partner"))
        XCTAssertEqual(app.staticTexts["tarneeb-live-contract-bid"].label, "You bid 7")
        XCTAssertTrue(app.staticTexts["Tarneeb spades"].exists)
        XCTAssertEqual(app.staticTexts["tarneeb-live-status"].label, "Your turn")
        for label in ["North South score 0", "East West score 0"] {
            let score = app.staticTexts[label]
            XCTAssertTrue(score.isHittable)
            XCTAssertTrue(app.frame.contains(score.frame))
        }
        first.tap()
        expectation(for: NSPredicate(format: "value == %@", "Selected"), evaluatedWith: first)
        waitForExpectations(timeout: 3)
        first.tap()
        expectation(for: NSPredicate(format: "value == %@", "Playable"), evaluatedWith: first)
        waitForExpectations(timeout: 3)
        first.doubleTap()
        expectation(for: NSPredicate(format: "value == %@", "1"), evaluatedWith: app.staticTexts["tarneeb-live-team-tricks"])
        waitForExpectations(timeout: 20)
        XCTAssertEqual(app.staticTexts["tarneeb-live-south-tricks"].value as? String, "1")
        XCTAssertTrue((app.staticTexts["tarneeb-contract-progress"].value as? String ?? "").contains("1 of 7"))
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 12)
        XCTAssertGreaterThanOrEqual(app.buttons["tarneeb-last-trick"].frame.width, 44)
        XCTAssertGreaterThanOrEqual(app.buttons["tarneeb-last-trick"].frame.height, 44)
        shot("Essential facts sound=\(sound) haptics=\(haptics) reduceMotion=\(reducedMotion)", app)
        app.buttons["tarneeb-game-options"].tap()
        shot("Native feedback preferences sound=\(sound) haptics=\(haptics)", app)
    }
    func testEssentialInformationWithSoundOff() { verifyWithoutFeedback(sound: false, haptics: true, reducedMotion: false) }
    func testEssentialInformationWithHapticsOff() { verifyWithoutFeedback(sound: true, haptics: false, reducedMotion: false) }
    func testEssentialInformationWithBothOff() { verifyWithoutFeedback(sound: false, haptics: false, reducedMotion: false) }
    func testEssentialInformationWithBothOffAndReducedMotion() { verifyWithoutFeedback(sound: false, haptics: false, reducedMotion: true) }
    func testMaximumTextLiveFactsRemainVisibleWithBothOff() { verifyWithoutFeedback(sound: false, haptics: false, reducedMotion: true, maximumText: true) }
}

final class TarneebImmediateLaunchUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    private func launch(reduced: Bool = false, saveID: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        if let saveID {
            app.launchEnvironment["TARNEEB_SAVE_TEST_ID"] = saveID
            app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = "west"
        }
        else { app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1" }
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reduced ? "1" : "0"
        app.launch()
        return app
    }
    private func capture(_ name: String, _ app: XCUIApplication) {
        let image = XCTAttachment(screenshot: app.screenshot()); image.name = name; image.lifetime = .keepAlways; add(image)
    }
    func testFirstUsableOpeningAcceptsImmediateRepeatedDealWithoutIntro() {
        let app = launch()
        XCTAssertFalse(app.otherElements["tarneeb-launch-intro"].exists)
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].isHittable)
        capture("Immediate opening — first automation frame", app)
        app.buttons["tarneeb-deal-button"].doubleTap()
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 30))
        XCTAssertEqual(app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-")).count, 13)
        XCTAssertFalse(app.otherElements["tarneeb-opening-deck"].exists)
        capture("Immediate repeated Deal — one complete hand", app)
    }
    func testReducedMotionOpeningIsImmediatelyUsableWithoutArrivalCue() {
        let app = launch(reduced: true)
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].isHittable)
        XCTAssertEqual(app.otherElements["tarneeb-opening-table"].value as? String, "arrival=settled;cue=0")
        XCTAssertFalse(app.otherElements["tarneeb-launch-intro"].exists)
        capture("Immediate Reduced Motion opening", app)
    }
    func testWarmResumeDoesNotReplayArrivalOrFeedback() {
        let app = launch()
        let table = app.otherElements["tarneeb-opening-table"]
        XCUIDevice.shared.press(.home); app.activate()
        let settled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value BEGINSWITH %@", "arrival=settled"), object: table)
        XCTAssertEqual(XCTWaiter.wait(for: [settled], timeout: 3), .completed)
        let before = table.value as? String
        let replay = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in (table.value as? String) != before }, object: table)
        replay.isInverted = true
        XCTAssertEqual(XCTWaiter.wait(for: [replay], timeout: 1.2), .completed)
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].isHittable)
        capture("Warm resume — settled table, no arrival replay", app)
    }
    func testSavedReadyTableRestoresWithoutArrivalOrIntro() {
        let id = UUID().uuidString
        let first = launch(saveID: id)
        XCTAssertTrue(first.buttons["tarneeb-deal-button"].isHittable)
        first.buttons["tarneeb-deal-button"].tap()
        XCTAssertTrue(first.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 35))
        first.buttons["tarneeb-game-options"].tap(); first.buttons["New Game"].tap()
        XCTAssertTrue(first.buttons["Cancel Game"].waitForExistence(timeout: 3))
        first.buttons["Cancel Game"].tap()
        XCTAssertTrue(first.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(first.buttons["tarneeb-deal-button"].isHittable)
        first.terminate()
        let restored = launch(saveID: id)
        XCTAssertTrue(restored.buttons["tarneeb-deal-button"].isHittable)
        XCTAssertFalse(restored.otherElements["tarneeb-launch-intro"].exists)
        let table = restored.otherElements["tarneeb-opening-table"]
        XCTAssertEqual(table.value as? String, "arrival=settled;cue=0")
        let cue = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value CONTAINS %@", "cue=1"), object: table)
        cue.isInverted = true
        XCTAssertEqual(XCTWaiter.wait(for: [cue], timeout: 1.2), .completed)
        capture("Saved ready table — direct restoration", restored)
    }
}

final class TarneebIconAppearanceUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    func testNativeHomeScreenIconAndAvailableCustomizationModes() throws {
        let app = XCUIApplication(); app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"; app.launch()
        XCUIDevice.shared.press(.home)
        let home = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let icon = home.icons["Tarneeb Royale"]
        XCTAssertTrue(icon.waitForExistence(timeout: 8), home.debugDescription)
        capture("Native Home Screen — current appearance", home)
        icon.press(forDuration: 1.2)
        let editHome = home.buttons["Edit Home Screen"]
        guard editHome.waitForExistence(timeout: 4) else {
            debug(home); throw XCTSkip("SpringBoard customization controls unavailable; current native icon capture retained")
        }
        editHome.tap()
        let edit = home.buttons["Edit"]
        guard edit.waitForExistence(timeout: 4) else { debug(home); throw XCTSkip("SpringBoard Edit button unavailable") }
        edit.tap()
        let customize = home.buttons["Customize"]
        guard customize.waitForExistence(timeout: 4) else { debug(home); throw XCTSkip("SpringBoard Customize menu unavailable") }
        customize.tap(); debug(home)
        for appearance in ["Default", "Dark", "Clear", "Tinted"] {
            let button = home.buttons[appearance]
            if button.waitForExistence(timeout: 2) {
                button.tap(); capture("Native Home Screen — selected \(appearance)", home)
            } else { print("NATIVE_ICON_MODE_UNAVAILABLE: \(appearance)") }
        }
        if home.buttons["Default"].exists { home.buttons["Default"].tap() }
        XCUIDevice.shared.press(.home)
    }
    private func capture(_ name: String, _ app: XCUIApplication) {
        let a = XCTAttachment(screenshot: app.screenshot()); a.name = name; a.lifetime = .keepAlways; add(a)
    }
    private func debug(_ app: XCUIApplication) {
        let a = XCTAttachment(string: app.debugDescription); a.name = "Native SpringBoard customization hierarchy"; a.lifetime = .keepAlways; add(a)
        print(app.debugDescription)
    }
}

final class TarneebDealLandingSequenceUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    func testNativeLandingSpreadRevealOrderForEveryDealer() { verify(reduced: false) }
    func testReducedMotionLandingSpreadRevealOrderForEveryDealer() { verify(reduced: true) }
    private func verify(reduced: Bool) {
        for dealer in ["south", "east", "north", "west"] {
            let app = XCUIApplication()
            app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"
            app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = dealer
            app.launchEnvironment["TARNEEB_CAPTURE_DEAL"] = "1"
            app.launchEnvironment["TARNEEB_CAPTURE_STATION_HANDOFF"] = "1"
            app.launchEnvironment["TARNEEB_CAPTURE_PACKET_LANDINGS"] = "1"
            app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reduced ? "1" : "0"
            app.launch()
            let anchor = app.descendants(matching: .any).matching(identifier: "tarneeb-deck-source").firstMatch
            let deck = app.otherElements["tarneeb-opening-deck"]
            XCTAssertEqual(deck.value as? String, "52 cards")
            XCTAssertTrue(deck.label.contains(dealer.capitalized))
            XCTAssertEqual(deck.frame.midX, anchor.frame.midX, accuracy: 0.5)
            // The squared packet includes its decorative lower backing cards (1.5 pt bounds offset).
            XCTAssertEqual(deck.frame.midY, anchor.frame.midY + 1.5, accuracy: 0.5)
            capture("\(dealer) \(reduced ? "RM" : "normal") - 52 card source at actual dealer", app)
            app.buttons["tarneeb-deal-button"].tap()
            let hand = app.otherElements["tarneeb-opening-hand"]
            let advance = app.buttons["tarneeb-deal-phase-continue"]
            XCTAssertTrue(advance.waitForExistence(timeout: 8))
            let orders = ["south": ["east","north","west"], "east": ["north","west","south"], "north": ["west","south","east"], "west": ["south","east","north"]]
            for packet in 1...2 {
                XCTAssertEqual(advance.value as? String, "packet-\(packet)-landed")
                XCTAssertTrue((hand.value as? String ?? "").contains("packetsLanded=\(packet);packetsIssued=\(packet);retained=0;established=\(packet * 13);packetsInFlight=0"))
                XCTAssertEqual(deck.value as? String, "\(52 - packet * 13) cards")
                XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
                for seat in orders[dealer]!.prefix(packet) where seat != "south" {
                    XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "tarneeb-deal-stack-\(seat)").firstMatch.value as? String, "13 cards")
                }
                let backs = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-"))
                if orders[dealer]!.prefix(packet).contains("south") {
                    XCTAssertEqual(backs.count, 13)
                    let frames = backs.allElementsBoundByIndex.map(\.frame)
                    for f in frames { XCTAssertEqual(f.midX, frames[0].midX, accuracy: 0.5); XCTAssertEqual(f.midY, frames[0].midY, accuracy: 0.5) }
                    XCTAssertEqual(Set(backs.allElementsBoundByIndex.map(\.label)), ["Face-down card"])
                }
                capture("\(dealer) \(reduced ? "RM" : "normal") - packet \(packet) native landing, source retains \(52 - packet * 13)", app)
                advance.tap()
                let phase = packet == 1 ? "packet-2-landed" : "3-packets-landed-13-retained-stack"
                expectation(for: NSPredicate(format: "value == %@", phase), evaluatedWith: advance)
                waitForExpectations(timeout: 8)
            }
            XCTAssertTrue(advance.waitForExistence(timeout: 25))
            XCTAssertEqual(advance.value as? String, "3-packets-landed-13-retained-stack")
            XCTAssertTrue((hand.value as? String ?? "").contains("packetsLanded=3;packetsIssued=3;retained=13;established=52;packetsInFlight=0"))
            XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
            XCTAssertEqual(app.staticTexts["tarneeb-phase-kicker"].label, "Dealing")
            let cards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-"))
            XCTAssertEqual(cards.count, 13)
            for seat in ["north", "east", "west"] {
                XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "tarneeb-deal-stack-\(seat)").firstMatch.value as? String, "13 cards")
            }
            let stack = cards.allElementsBoundByIndex.map(\.frame)
            for f in stack { XCTAssertEqual(f.midX, stack[0].midX, accuracy: 0.5); XCTAssertEqual(f.midY, stack[0].midY, accuracy: 0.5) }
            XCTAssertEqual(Set(cards.allElementsBoundByIndex.map(\.label)), ["Face-down card"])
            capture("\(dealer) \(reduced ? "RM" : "normal") - 3 packet landings and 13 retained, all hands compact", app)
            advance.tap()
            expectation(for: NSPredicate(format: "value == %@", "spread-settled-backs"), evaluatedWith: advance)
            waitForExpectations(timeout: 5)
            XCTAssertEqual(Set(cards.allElementsBoundByIndex.map(\.label)), ["Face-down card"])
            XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
            XCTAssertEqual(app.staticTexts["tarneeb-phase-kicker"].label, "Dealing")
            capture("\(dealer) \(reduced ? "RM" : "normal") - spread settled, all 13 face-down", app)
            let backs = cards.allElementsBoundByIndex.map(\.frame)
            advance.tap()
            expectation(for: NSPredicate(format: "value == %@", "reveal-settled-faces"), evaluatedWith: advance)
            waitForExpectations(timeout: 5)
            XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists)
            XCTAssertEqual(app.staticTexts["tarneeb-phase-kicker"].label, "Dealing")
            XCTAssertFalse(cards.allElementsBoundByIndex.contains { $0.label == "Face-down card" })
            for (card, back) in zip(cards.allElementsBoundByIndex, backs) {
                XCTAssertEqual(card.frame.midX, back.midX, accuracy: 0.5); XCTAssertEqual(card.frame.midY, back.midY, accuracy: 0.5)
            }
            capture("\(dealer) \(reduced ? "RM" : "normal") - reveal settled, bidding still gated", app)
            let expandedPackets = ["north", "east", "west"].map {
                app.descendants(matching: .any).matching(identifier: "tarneeb-deal-stack-\($0)").firstMatch.frame
            }
            advance.tap()
            expectation(for: NSPredicate(format: "value == %@", "station-handoff-settled"), evaluatedWith: advance)
            waitForExpectations(timeout: 5)
            XCTAssertFalse(app.buttons["tarneeb-bid-button-south"].exists, "Bidding remains gated until station geometry settles")
            let settledPackets = ["north", "east", "west"].map {
                app.descendants(matching: .any).matching(identifier: "tarneeb-deal-stack-\($0)").firstMatch.frame
            }
            for (expanded, settled) in zip(expandedPackets, settledPackets) {
                XCTAssertLessThan(settled.width, expanded.width * 0.6)
                XCTAssertTrue(app.frame.contains(settled))
            }
            capture("\(dealer) \(reduced ? "RM" : "normal") - station handoff settled, bidding still gated", app)
            advance.tap()
            expectation(for: NSPredicate(format: "value == %@", "bidding-published"), evaluatedWith: advance)
            waitForExpectations(timeout: 5)
            for (seat, settled) in zip(["north", "east", "west"], settledPackets) {
                let current = app.descendants(matching: .any).matching(identifier: "tarneeb-deal-stack-\(seat)").firstMatch.frame
                XCTAssertEqual(current.midX, settled.midX, accuracy: 0.5)
                XCTAssertEqual(current.midY, settled.midY, accuracy: 0.5, "Committing the deal must not replace packet geometry")
                XCTAssertEqual(current.width, settled.width, accuracy: 0.5)
            }
            advance.tap()
            XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 12))
            XCTAssertEqual(app.staticTexts["tarneeb-phase-kicker"].label, "Bidding")
            capture("\(dealer) \(reduced ? "RM" : "normal") - bidding enabled after completion", app)
            app.terminate()
        }
    }
    private func capture(_ name: String, _ app: XCUIApplication) {
        let a = XCTAttachment(screenshot: app.screenshot()); a.name = name; a.lifetime = .keepAlways; add(a)
    }
}

final class TarneebDealerNormalPacingUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    func testSouthDealerNormalPacing() { verify("south") }
    func testEastDealerNormalPacing() { verify("east") }
    func testNorthDealerNormalPacing() { verify("north") }
    func testWestDealerNormalPacing() { verify("west") }
    private func verify(_ dealer: String) {
        let app = XCUIApplication()
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = dealer
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = "0"
        // No boundary capture environment: the complete production-paced sequence runs uninterrupted.
        app.launch()
        let deck = app.otherElements["tarneeb-opening-deck"]
        XCTAssertEqual(deck.value as? String, "52 cards")
        XCTAssertTrue(deck.label.contains(dealer.capitalized))
        capture("\(dealer) normal unpaused - actual dealer source", app)
        app.buttons["tarneeb-deal-button"].tap()
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 35))
        XCTAssertEqual(app.staticTexts["tarneeb-phase-kicker"].label, "Bidding")
        XCTAssertFalse(app.buttons["tarneeb-deal-phase-continue"].exists)
        let cards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-"))
        XCTAssertEqual(cards.count, 13)
        XCTAssertFalse(cards.allElementsBoundByIndex.contains { $0.label == "Face-down card" })
        capture("\(dealer) normal unpaused - native completion enabled bidding", app)
        app.terminate()
    }
    private func capture(_ name: String, _ app: XCUIApplication) {
        let a = XCTAttachment(screenshot: app.screenshot()); a.name = name; a.lifetime = .keepAlways; add(a)
    }
}

final class TarneebBuild3PolishUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    private func shot(_ name: String, _ app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Build3-\(name)"; attachment.lifetime = .keepAlways; add(attachment)
    }
    func testLiveWordmarkCenteredWithChangingScoreWidths() {
        var originalY: CGFloat?
        for score in ["0,0", "9,9", "15,-15", "-29,30"] {
            let app = XCUIApplication()
            app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"]
            app.launchEnvironment["TARNEEB_LIVE_FIXTURE"] = "balanced"
            app.launchEnvironment["TARNEEB_HEADER_SCORE"] = score
            app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = "1"
            app.launch()
            let title = app.staticTexts["tarneeb-live-wordmark"]
            XCTAssertTrue(title.waitForExistence(timeout: 8))
            XCTAssertEqual(title.frame.midX, app.frame.midX, accuracy: 0.5)
            if let originalY { XCTAssertEqual(title.frame.midY, originalY, accuracy: 0.5) }
            else { originalY = title.frame.midY }
            XCTAssertEqual(title.label, "طرنيب")
            shot("live-score-\(score)", app)
            app.terminate()
        }
    }
    func testEveryDealerDeckIsClearAndKeepsFirstDepartureOrigin() {
        for dealer in ["north", "east", "south", "west"] {
            let app = XCUIApplication()
            app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"]
            app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"
            app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = dealer
            app.launchEnvironment["TARNEEB_CAPTURE_DEAL"] = "1"
            app.launchEnvironment["TARNEEB_CAPTURE_PACKET_LANDINGS"] = "1"
            app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = "0"
            app.launch()
            waitForInteractiveOpening(app)
            let deck = app.otherElements["tarneeb-opening-deck"]
            XCTAssertTrue(deck.waitForExistence(timeout: 8))
            let before = deck.frame
            XCTAssertTrue(app.frame.contains(before))
            for station in ["north", "east", "west"] {
                let label = app.otherElements["tarneeb-opening-station-\(station)"]
                if label.exists { XCTAssertFalse(before.intersects(label.frame), "\(dealer) overlaps \(station)") }
            }
            shot("\(dealer)-ready-deck", app)
            app.buttons["tarneeb-deal-button"].tap()
            let advance = app.buttons["tarneeb-deal-phase-continue"]
            XCTAssertTrue(advance.waitForExistence(timeout: 12))
            XCTAssertEqual(advance.value as? String, "packet-1-landed")
            XCTAssertTrue(deck.exists)
            XCTAssertEqual(deck.frame.midX, before.midX, accuracy: 0.5)
            XCTAssertEqual(deck.frame.midY, before.midY, accuracy: 0.5)
            shot("\(dealer)-first-packet-landed", app)
            app.terminate()
        }
    }
    func testArabicTalabLabelAndAccessibleBiddingRemainReadable() {
        for (mode, category) in [("Normal", "UICTContentSizeCategoryL"), ("Maximum", "UICTContentSizeCategoryAccessibilityXXXL")] {
            let app = XCUIApplication()
            app.launchArguments = ["-UIPreferredContentSizeCategoryName", category]
            app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"
            app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = "west"
            app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = "east:pass,north:pass,west:pass"
            app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = "1"
            app.launch()
            app.buttons["tarneeb-deal-button"].tap()
            XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 30))
            let status = app.staticTexts["tarneeb-opening-status"]
            let kicker = app.staticTexts["tarneeb-phase-kicker"]
            XCTAssertEqual(status.label, "طلب · Bidding")
            XCTAssertTrue(status.isHittable)
            XCTAssertTrue(app.frame.contains(status.frame))
            XCTAssertLessThanOrEqual(status.frame.height, 32, "Arabic should match the adjacent approved 17-point English text")
            XCTAssertLessThanOrEqual(status.frame.maxY - kicker.frame.minY, 62, "Both lines must fit the existing phase banner")
            XCTAssertEqual(app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-opening-card-")).count, 13)
            shot(mode == "Normal" ? "Arabic-request-bidding-and-13-card-hand" : "Arabic-request-maximum-text-and-13-card-hand", app)
            app.terminate()
        }
    }
    func testAllPassRedealUsesTheRotatedDealerDepartureOrigin() {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"]
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = "west"
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = "east:pass,north:pass,west:pass"
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = "1"
        app.launchEnvironment["TARNEEB_CAPTURE_DEAL"] = "1"
        app.launchEnvironment["TARNEEB_CAPTURE_PACKET_LANDINGS"] = "1"
        app.launch()
        app.buttons["tarneeb-deal-button"].tap()
        let advance = app.buttons["tarneeb-deal-phase-continue"]
        XCTAssertTrue(advance.waitForExistence(timeout: 12))
        XCTAssertEqual(advance.value as? String, "packet-1-landed")
        for phase in ["packet-2-landed", "3-packets-landed-13-retained-stack", "spread-settled-backs", "reveal-settled-faces"] {
            advance.tap()
            expectation(for: NSPredicate(format: "value == %@", phase), evaluatedWith: advance)
            waitForExpectations(timeout: 12)
        }
        advance.tap()
        XCTAssertTrue(app.buttons["tarneeb-pass-button-south"].waitForExistence(timeout: 25))
        app.buttons["tarneeb-pass-button-south"].tap()
        XCTAssertTrue(advance.waitForExistence(timeout: 25))
        XCTAssertEqual(advance.value as? String, "packet-1-landed")
        let deck = app.otherElements["tarneeb-opening-deck"]
        let source = app.descendants(matching: .any).matching(identifier: "tarneeb-deck-source").firstMatch
        XCTAssertTrue(deck.label.contains("South"))
        XCTAssertEqual(deck.frame.midX, source.frame.midX, accuracy: 0.5)
        XCTAssertEqual(deck.frame.midY, source.frame.midY + 1.5, accuracy: 0.5)
        shot("all-pass-rotated-South-dealer-origin", app)
    }
}

final class TarneebCoachUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launch(coach: Bool, fixture: String = "contract-six", reduced: Bool = false, maximumText: Bool = false, saveID: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-tarneeb.coachEnabled", coach ? "YES" : "NO", "-tarneeb.aiSkill", "standard"]
        if !fixture.isEmpty { app.launchEnvironment["TARNEEB_LIVE_FIXTURE"] = fixture }
        if let saveID { app.launchEnvironment["TARNEEB_SAVE_TEST_ID"] = saveID }
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reduced ? "1" : "0"
        if maximumText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launch()
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 10))
        return app
    }
    private func capture(_ name: String, _ app: XCUIApplication) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    private func open(_ app: XCUIApplication) {
        let played = app.buttons["tarneeb-played-button"]
        let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: played)
        XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 15), .completed)
        played.tap()
        XCTAssertTrue(app.otherElements["tarneeb-played-tracker"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["tarneeb-tracker-close"].isHittable)
    }

    func testCoachOffEquivalentGeometryAndOptionsSwitchIndependentOfSkill() {
        let off = launch(coach: false, fixture: "4-4-3-2")
        XCTAssertFalse(off.buttons["tarneeb-played-button"].exists)
        let cardID = "tarneeb-live-card-spades-2"
        let handFrame = off.buttons[cardID].frame
        let scoreFrame = off.staticTexts["North South score 0"].frame
        let recallFrame = off.buttons["tarneeb-last-trick"].frame
        capture("Coach OFF baseline table", off)
        off.buttons["tarneeb-game-options"].tap()
        let coach = off.descendants(matching: .any)["tarneeb-coach-switch"]
        XCTAssertTrue(coach.waitForExistence(timeout: 3))
        XCTAssertTrue(off.descendants(matching: .any)["tarneeb-ai-skill"].exists)
        off.terminate()
        let on = launch(coach: true, fixture: "4-4-3-2")
        XCTAssertTrue(on.buttons["tarneeb-played-button"].exists)
        XCTAssertEqual(on.buttons[cardID].frame, handFrame)
        XCTAssertEqual(on.staticTexts["North South score 0"].frame, scoreFrame)
        XCTAssertEqual(on.buttons["tarneeb-last-trick"].frame, recallFrame)
        XCTAssertFalse(on.buttons["tarneeb-played-button"].frame.intersects(on.buttons["tarneeb-last-trick"].frame))
        XCTAssertFalse(on.buttons["tarneeb-played-button"].frame.intersects(on.staticTexts["tarneeb-live-south-tricks"].frame))
        capture("Coach ON entry without geometry change", on)
        on.terminate()
    }

    func testCoachModalPublicTruthPreservesSelectionBlocksInputAndReturnsClosed() {
        verifyPublicModal(reduced: false)
    }

    func testCoachReduceMotionModalPreservesPublicTruthAndSelection() {
        verifyPublicModal(reduced: true)
    }

    private func verifyPublicModal(reduced: Bool) {
        let app = launch(coach: true, reduced: reduced)
        let selected = app.buttons["tarneeb-live-card-spades-8"]
        selected.tap()
        expectation(for: NSPredicate(format: "value == %@", "Selected"), evaluatedWith: selected)
        waitForExpectations(timeout: 3)
        let original = selected.frame
        open(app)
        XCTAssertEqual(app.staticTexts["tarneeb-tracker-total"].label, "24 of 52 played · This hand")
        for suit in ["spades","hearts","clubs","diamonds"] {
            let summary = app.otherElements["tarneeb-tracker-suit-\(suit)"]
            XCTAssertTrue(summary.exists)
            XCTAssertTrue(summary.label.contains("6 played"))
            XCTAssertTrue(summary.label.contains("A, K, Q, J, 10, 9, 8"))
            XCTAssertTrue(summary.label.contains("7, 6, 5, 4, 3, 2"))
        }
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-8"].isHittable)
        XCTAssertFalse(app.buttons["tarneeb-game-options"].isHittable)
        capture("Coach public tracker six completed tricks", app)
        app.tapCoordinate(original.origin)
        XCTAssertTrue(app.buttons["tarneeb-tracker-close"].exists)
        app.buttons["tarneeb-tracker-close"].tap()
        XCTAssertTrue(selected.waitForExistence(timeout: 3))
        XCTAssertEqual(selected.value as? String, "Selected")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 7)
        selected.doubleTap()
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: app.buttons["tarneeb-played-button"])
        waitForExpectations(timeout: 15)
        open(app)
        XCTAssertEqual(app.staticTexts["tarneeb-tracker-total"].label, "28 of 52 played · This hand")
        capture("Coach public tracker seven completed tricks", app)
        app.buttons["tarneeb-tracker-close"].tap()
        app.terminate()
    }

    func testCoachBackgroundAndDiskRestoreRetainUsageButNeverReopen() {
        let id = UUID().uuidString
        let app = launch(coach: true, reduced: true, saveID: id)
        open(app)
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertFalse(app.otherElements["tarneeb-played-tracker"].exists)
        open(app)
        app.buttons["tarneeb-tracker-close"].tap()
        app.terminate()
        app.launchEnvironment.removeValue(forKey: "TARNEEB_LIVE_FIXTURE")
        app.launch()
        XCTAssertTrue(app.buttons["tarneeb-played-button"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.otherElements["tarneeb-played-tracker"].exists)
        for rank in ["8","9","10","J","Q","K"] {
            let card = app.buttons["tarneeb-live-card-spades-\(rank)"]
            XCTAssertTrue(card.waitForExistence(timeout: 12))
            let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: app.buttons["tarneeb-played-button"])
            XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 15), .completed)
            card.doubleTap()
        }
        let usage = app.staticTexts["tarneeb-coach-result"]
        XCTAssertTrue(usage.waitForExistence(timeout: 25))
        XCTAssertEqual(usage.label, "You checked the played-card tracker 2 times this hand.")
        capture("Coach neutral current-hand result", app)
        app.terminate()
    }

    func testCoachMaximumTextKeepsCloseFixedAndAllSuitSummariesReachable() {
        let app = launch(coach: true, maximumText: true)
        open(app)
        let close = app.buttons["tarneeb-tracker-close"]
        let fixed = close.frame
        XCTAssertGreaterThanOrEqual(fixed.width, 44)
        XCTAssertGreaterThanOrEqual(fixed.height, 44)
        let total = app.staticTexts["tarneeb-tracker-total"]
        XCTAssertEqual(total.label, "24 of 52 played · This hand")
        let font = UIFont.preferredFont(forTextStyle: .subheadline,
            compatibleWith: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge))
        let requiredHeight = (total.label as NSString).boundingRect(
            with: CGSize(width: total.frame.width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil).height
        XCTAssertGreaterThanOrEqual(total.frame.height + 2, ceil(requiredHeight), "The full summary must fit without truncation")
        XCTAssertTrue(app.frame.contains(total.frame))
        capture("Coach maximum text tracker top", app)
        let scroll = app.scrollViews.firstMatch
        XCTAssertLessThanOrEqual(total.frame.maxY, scroll.frame.minY + 1)
        for suit in ["spades","hearts","clubs","diamonds"] {
            let summary = app.otherElements["tarneeb-tracker-suit-\(suit)"]
            for _ in 0..<6 where !summary.isHittable { scroll.swipeUp() }
            XCTAssertTrue(summary.isHittable)
            XCTAssertEqual(close.frame, fixed)
        }
        let clarification = app.staticTexts["Not yet played does not identify who holds it."]
        for _ in 0..<12 {
            if clarification.isHittable && scroll.frame.insetBy(dx: -1, dy: -1).contains(clarification.frame) { break }
            scroll.swipeUp()
        }
        XCTAssertTrue(clarification.isHittable)
        XCTAssertTrue(scroll.frame.insetBy(dx: -1, dy: -1).contains(clarification.frame))
        XCTAssertEqual(close.frame, fixed)
        capture("Coach maximum text tracker bottom", app)
        close.tap()
        XCTAssertTrue(app.buttons["tarneeb-played-button"].exists)
        app.terminate()
    }
}

private extension XCUIApplication {
    func tapCoordinate(_ point: CGPoint) {
        coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: point.x, dy: point.y)).tap()
    }
}


final class TarneebPlayedCenterUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testPlayedStaysAtScreenMidpointWithAsymmetricNegativeAndDoubleDigitScores() {
        for (fixture, northSouth, eastWest) in [("4-4-3-2", 0, 0), ("last-two", 0, 0),
            ("round-made", 16, 0), ("round-missed", -7, 16), ("round-defense", 16, -9)] {
            let off = launch(fixture: fixture, coach: false)
            let baseline = frames(off, northSouth: northSouth, eastWest: eastWest)
            XCTAssertFalse(off.buttons["tarneeb-played-button"].exists)
            off.terminate()
            let on = launch(fixture: fixture, coach: true)
            let current = frames(on, northSouth: northSouth, eastWest: eastWest)
            for (name, frame) in baseline { XCTAssertEqual(current[name], frame, "Coach must preserve \(name) geometry: \(fixture)") }
            let played = on.buttons["tarneeb-played-button"].frame
            XCTAssertEqual(played.midX, on.frame.midX, accuracy: 0.5, "Center must follow the screen, regardless of footer widths")
            XCTAssertEqual(played.width, 76, accuracy: 1, "Accessibility bounds include the one-point border")
            XCTAssertEqual(played.height, 44, accuracy: 1, "Accessibility bounds include the one-point border")
            XCTAssertEqual(played.midY, current["recall"]!.midY, accuracy: 0.5, "Preserve the approved vertical position")
            for name in ["your team", "your tricks", "opponents", "recall"] {
                XCTAssertFalse(played.intersects(current[name]!), "Played must not cover \(name)")
            }
            let geometry = XCTAttachment(string: "screen=\(on.frame); Played=\(played); NS=\(northSouth); EW=\(eastWest); controls=\(current)")
            geometry.name = "Played geometry \(Int(on.frame.width))pt \(fixture)"; geometry.lifetime = .keepAlways; add(geometry)
            let shot = XCTAttachment(screenshot: on.screenshot())
            shot.name = "Played centered \(Int(on.frame.width))pt NS\(northSouth) EW\(eastWest) \(fixture)"
            shot.lifetime = .keepAlways; add(shot)
            on.terminate()
        }
    }

    private func frames(_ app: XCUIApplication, northSouth: Int, eastWest: Int) -> [String: CGRect] {
        let ns = app.staticTexts["North South score \(northSouth)"]
        let ew = app.staticTexts["East West score \(eastWest)"]
        XCTAssertTrue(ns.exists); XCTAssertTrue(ew.exists)
        let team = app.staticTexts["tarneeb-live-team-tricks"]
        let own = app.staticTexts["tarneeb-live-south-tricks"]
        let opponents = app.staticTexts["OPPONENTS"]
        XCTAssertTrue(team.exists); XCTAssertTrue(own.exists); XCTAssertTrue(opponents.exists)
        return ["NS score": ns.frame, "EW score": ew.frame, "your team": team.frame,
            "your tricks": own.frame, "opponents": opponents.frame, "recall": app.buttons["tarneeb-last-trick"].frame]
    }

    private func launch(fixture: String, coach: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-tarneeb.coachEnabled", coach ? "YES" : "NO", "-tarneeb.aiSkill", "standard"]
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = "1"
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = "east:pass,north:pass,west:pass"
        if fixture.hasPrefix("round-") {
            app.launchEnvironment["TARNEEB_RESULT_FIXTURE"] = fixture
        } else { app.launchEnvironment["TARNEEB_LIVE_FIXTURE"] = fixture }
        app.launch()
        if fixture.hasPrefix("round-") {
            let next = app.buttons["tarneeb-next-hand"]
            XCTAssertTrue(next.waitForExistence(timeout: 10)); next.tap()
            let bid = app.buttons["tarneeb-bid-button-south"]
            XCTAssertTrue(bid.waitForExistence(timeout: 30))
            let legalBid = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-bid-option-")).firstMatch
            XCTAssertTrue(legalBid.exists); legalBid.tap(); bid.tap()
            let trump = app.buttons["tarneeb-post-bidding-suit-button-south"]
            XCTAssertTrue(trump.waitForExistence(timeout: 20))
            app.buttons["tarneeb-bid-suit-option-spades"].tap(); trump.tap()
        }
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 10))
        return app
    }
}
