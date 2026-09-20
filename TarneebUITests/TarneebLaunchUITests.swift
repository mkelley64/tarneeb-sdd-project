import XCTest

final class TarneebFullMatchUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testExpertBiddingFromDealReachesLegalCardPlayWithoutOverrides() {
        let app = XCUIApplication()
        app.launchArguments += ["-tarneeb.aiSkill", "expert"]
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "sweep"
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = "south"
        app.launch()
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
        app.buttons["tarneeb-deal-button"].tap()
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 30))
        app.buttons["tarneeb-opening-bid-picker"].tap()
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
            app.buttons["tarneeb-opening-bid-picker"].tap()
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
                waitForExpectations(timeout: 15)
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
                    waitForExpectations(timeout: 15)
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
                XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "Contract made")
                let next = app.buttons["tarneeb-next-hand"]
                XCTAssertTrue(next.isHittable)
                next.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5)).tap()
                XCTAssertTrue(app.otherElements["tarneeb-opening-table"].waitForExistence(timeout: 5))
            } else {
                XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "You and North win!")
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

    private func launch(_ fixture: String, key: String = "TARNEEB_LIVE_FIXTURE", saved: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
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
        app.buttons["tarneeb-last-trick"].tap()
        let close = app.buttons["tarneeb-close-last-trick"]
        XCTAssertTrue(close.waitForExistence(timeout: 3))
        for seat in ["south", "east", "north", "west"] {
            let recalled = app.otherElements["tarneeb-recalled-\(seat)"]
            XCTAssertTrue(recalled.exists)
            XCTAssertTrue(app.frame.contains(recalled.frame))
        }
        XCTAssertTrue(app.frame.contains(close.frame))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Last trick recall"
        screenshot.lifetime = .keepAlways
        add(screenshot)
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
        app.buttons["tarneeb-deal-button"].tap()
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 25))
        relaunchSaved(app)
        XCTAssertTrue(app.buttons["tarneeb-bid-button-south"].waitForExistence(timeout: 5))
        app.buttons["tarneeb-opening-bid-picker"].tap()
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

    private func launch(_ fixture: String, reducedMotion: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
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
        XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "Contract made")
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
        XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "Contract missed")
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
        XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "You and North win!")
        XCTAssertTrue(app.staticTexts["North South score 32"].exists)
        XCTAssertFalse(app.buttons["tarneeb-next-hand"].exists)
        verifyVisibleResult(app, command: "tarneeb-new-match")
        app.buttons["tarneeb-new-match"].coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertTrue(app.buttons["tarneeb-deal-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["North South score 0"].exists)
        XCTAssertTrue(app.staticTexts["East West score 0"].exists)
        XCTAssertEqual(app.otherElements["tarneeb-opening-deck"].value as? String, "52 cards")
    }

    func testOpponentMatchWinWithReducedMotionShowsCorrectWinner() {
        let app = launch("match-loss", reducedMotion: true)
        XCTAssertEqual(app.staticTexts["tarneeb-result-title"].label, "East-West win")
        XCTAssertTrue(app.staticTexts["East West score 32"].exists)
        XCTAssertTrue(app.staticTexts["North South score -14"].exists)
        XCTAssertFalse(app.buttons["tarneeb-next-hand"].exists)
        verifyVisibleResult(app, command: "tarneeb-new-match")
    }
}

final class TarneebOpeningTableUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launch(reducedMotion: Bool = false, dealer: String = "west", bids: String = "east:pass,north:pass,west:pass") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = dealer
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = bids
        app.launchEnvironment["TARNEEB_REDUCE_MOTION"] = reducedMotion ? "1" : "0"
        app.launch()
        XCTAssertTrue(app.otherElements["tarneeb-opening-table"].waitForExistence(timeout: 5))
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
        XCTAssertEqual(app.staticTexts["tarneeb-opening-status"].label, "Talab · Bidding")
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "Opening readable hand and bidding"
        shot.lifetime = .keepAlways
        add(shot)
        app.buttons["tarneeb-opening-bid-picker"].tap()
        app.buttons["7"].tap()
        XCTAssertEqual(app.buttons["tarneeb-bid-button-south"].label, "Bid 7")
        XCTAssertFalse(app.buttons["tarneeb-bid-suit-option-spades"].exists)
        app.buttons["tarneeb-bid-button-south"].tap()
        let set = app.buttons["tarneeb-post-bidding-suit-button-south"]
        XCTAssertTrue(set.waitForExistence(timeout: 25))
        XCTAssertEqual(app.staticTexts["tarneeb-suit-heading"].label, "Tarneeb")
        XCTAssertTrue(app.frame.contains(app.staticTexts["tarneeb-suit-heading"].frame))
        XCTAssertFalse(app.staticTexts["Trump"].exists)
        XCTAssertFalse(set.isEnabled)
        for suit in ["clubs", "diamonds", "hearts", "spades"] {
            let button = app.buttons["tarneeb-bid-suit-option-\(suit)"]
            XCTAssertTrue(button.isHittable)
            XCTAssertTrue(app.frame.contains(button.frame))
            XCTAssertGreaterThanOrEqual(button.frame.height, 44)
        }
        app.buttons["tarneeb-bid-suit-option-spades"].tap()
        XCTAssertTrue(set.isEnabled)
        let trump = XCTAttachment(screenshot: app.screenshot())
        trump.name = "Visible Tarneeb controls"
        trump.lifetime = .keepAlways
        add(trump)
        set.tap()
        XCTAssertTrue(app.otherElements["tarneeb-live-table"].waitForExistence(timeout: 5))
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
        app.buttons["tarneeb-bid-button-south"].tap()
        // Observe the durable dealer rotation rather than a brief reduced-motion packet.
        expectation(for: NSPredicate(format: "label == %@", "West"), evaluatedWith: app.otherElements["tarneeb-opening-station-west"])
        waitForExpectations(timeout: 25)
        waitForBid(app)
    }

    func testRaisedBidMenuOnlyOffersLegalValues() {
        let app = launch(reducedMotion: true, dealer: "south", bids: "east:8,north:pass,west:pass")
        app.buttons["tarneeb-deal-button"].tap()
        waitForBid(app)
        XCTAssertEqual(app.staticTexts["tarneeb-opening-status"].label, "Talab · East leads with 8")
        app.buttons["tarneeb-opening-bid-picker"].tap()
        XCTAssertFalse(app.buttons["7"].exists)
        XCTAssertFalse(app.buttons["8"].exists)
        XCTAssertTrue(app.buttons["9"].exists)
        app.buttons["13"].tap()
        app.buttons["tarneeb-bid-button-south"].tap()
        XCTAssertTrue(app.buttons["tarneeb-post-bidding-suit-button-south"].waitForExistence(timeout: 8))
    }

    func testTwoDigitBidValuesRemainOnOneLine() {
        let app = launch(reducedMotion: true)
        app.buttons["tarneeb-deal-button"].tap()
        waitForBid(app)
        let picker = app.buttons["tarneeb-opening-bid-picker"]
        let initialFrame = picker.frame
        let singleLineHeight = picker.staticTexts["Pass"].frame.height
        var singleDigitWidth: CGFloat = 0
        for bid in ["7", "10", "11", "12", "13", "Pass"] {
            picker.tap()
            app.buttons[bid].tap()
            let value = picker.staticTexts[bid]
            XCTAssertTrue(value.exists)
            XCTAssertLessThanOrEqual(value.frame.height, singleLineHeight + 1)
            if bid == "7" { singleDigitWidth = value.frame.width }
            if bid.count == 2 { XCTAssertGreaterThanOrEqual(value.frame.width, singleDigitWidth * 1.5) }
            XCTAssertEqual(picker.frame.width, initialFrame.width, accuracy: 1)
            XCTAssertEqual(picker.frame.height, initialFrame.height, accuracy: 1)
            XCTAssertTrue(picker.frame.contains(value.frame))
            XCTAssertEqual(app.buttons["tarneeb-bid-button-south"].label, bid == "Pass" ? "Pass" : "Bid \(bid)")
            if bid == "10" {
                let shot = XCTAttachment(screenshot: app.screenshot())
                shot.name = "Two-digit bid stays on one line"
                shot.lifetime = .keepAlways
                add(shot)
            }
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

    func testReadableHandSelectionAndOneCompleteTrick() {
        verifyOneTrick(reducedMotion: false)
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
        XCTAssertEqual(app.staticTexts["tarneeb-live-status"].label, "Your turn")
        XCTAssertEqual(app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-played-")).count, 0)
    }

    func testOptionsConfirmationResumesAndResetReturnsToOpeningDeal() {
        let app = launchLiveTable()
        app.buttons["tarneeb-game-options"].tap()
        app.buttons["New Game"].tap()
        if app.buttons["Keep Playing"].exists {
            tapSettledConfirmation("Keep Playing", in: app)
        } else {
            // iOS 26 presents this as a popover with tap-outside cancellation.
            app.staticTexts["tarneeb-contract-progress"].tap()
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
        waitForExpectations(timeout: 15)
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-2"].exists)
        XCTAssertFalse(app.buttons["tarneeb-live-card-spades-6"].isEnabled)
        XCTAssertTrue(app.buttons["tarneeb-live-card-diamonds-3"].isEnabled)
        XCTAssertEqual(app.staticTexts["tarneeb-live-south-tricks"].value as? String, "0")
        app.buttons["tarneeb-live-card-spades-6"].doubleTap()
        XCTAssertTrue(app.buttons["tarneeb-live-card-spades-6"].exists)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-live-card-")).count, 12)
        XCTAssertEqual(app.staticTexts["tarneeb-live-status"].label, "Your turn")
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
    func testIntroFinishesAndDoesNotReplayOnResume() {
        let app = XCUIApplication()
        app.launchEnvironment["TARNEEB_OPENING_FIXTURE"] = "1"
        app.launch()
        let deal = app.buttons["tarneeb-deal-button"]
        XCTAssertTrue(deal.waitForExistence(timeout: 5))
        XCTAssertTrue(deal.isHittable)
        XCTAssertFalse(app.otherElements["tarneeb-launch-intro"].exists)
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertFalse(app.otherElements["tarneeb-launch-intro"].exists)
        expectation(for: NSPredicate(format: "hittable == true"), evaluatedWith: deal)
        waitForExpectations(timeout: 3)
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
    }

    func testMVP007SmallestSupportedSimulatorIsDocumented() throws {
        XCTContext.runActivity(named: "MVP 007 smallest supported simulator: \(Self.mvp007SmallestSupportedSimulator)") { _ in
            XCTAssertEqual(Self.mvp007SmallestSupportedSimulator, "iPhone SE (3rd generation)")
        }
    }

    func testInitialScreenShowsPortraitTableTitleDeckStackStationsAndBottomDeal() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertEqual(screen.title.label, "طرنيب")
        XCTAssertTrue(screen.tableSurface.exists)
        XCTAssertTrue(screen.tableScene.exists)
        XCTAssertTrue(screen.cardTable.exists)
        XCTAssertTrue(screen.playArea.exists)
        XCTAssertTrue(screen.undealtDeckStack.exists)
        XCTAssertEqual(screen.deckStackCards.count, 52)
        XCTAssertEqual(screen.dealerStationAreas.count, 1)
        XCTAssertEqual(screen.dealerStationAreas.first?.identifier, "tarneeb-seat-area-south")
        XCTAssertEqual(screen.dealerPills.count, 1)
        XCTAssertTrue(screen.southDealerPill.exists)
        XCTAssertEqual(screen.southDealerPill.label, "D")
        assertSeatLabelPinnedToTop(screen.southSeat, in: screen.southSeatArea)
        assertStationContentBelowLabel(screen.undealtDeckStack, below: screen.southSeat)
        XCTAssertTrue(screen.dealButton.exists)
        XCTAssertEqual(screen.dealButton.label, "Deal")
        XCTAssertTrue(screen.dealButton.isHittable)
        XCTAssertTrue(screen.newGameButton.exists)
        XCTAssertEqual(screen.newGameButton.label, "New Game")
        XCTAssertFalse(screen.newGameButton.isEnabled)
        XCTAssertFalse(screen.gameScore.exists)
        XCTAssertGreaterThan(app.frame.height, app.frame.width)

        XCTAssertEqual(screen.visibleCards.count, 0)
        XCTAssertEqual(screen.hiddenCardBacks.count, 0)
        XCTAssertFalse(screen.bidArea.exists)
        XCTAssertFalse(screen.bidTable.exists)
        XCTAssertFalse(screen.southBidSelector.exists)
        XCTAssertFalse(screen.southTarneebSuitSelector.exists)
        XCTAssertFalse(screen.southBidButton.exists)
        XCTAssertFalse(screen.dealCompleteMessage.exists)
        XCTAssertFalse(screen.oldDealCardsButton.exists)
        XCTAssertFalse(screen.oldNewDealButton.exists)

        XCTAssertEqual(screen.southSeat.label, "South")
        XCTAssertEqual(screen.westSeat.label, "West")
        XCTAssertEqual(screen.northSeat.label, "North")
        XCTAssertEqual(screen.eastSeat.label, "East")

        assertTableDiameter(on: screen, in: app)
        assertTableTitleIsOnCardTable(on: screen)
        assertPlayAreaReservedAtTableCenter(on: screen)
        assertInitialDeckStackIsInDealerStation(on: screen)
        assertStationsSurroundTable(on: screen)
        assertInitialStationsAreRoundedSquares(on: screen)
        assertBottomDealButtonIsAtBottom(on: screen, in: app)

        for element in screen.initialUsabilityElements {
            assertElementIsUsableOnScreen(element, in: app)
        }
    }

    func testInitialScreenExposesMVP007TokenAndLayoutHooks() throws {
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))

        try assertTokenValue(screen.tableSurface, contains: "background=color.table.background.primary")
        try assertTokenValue(screen.tableScene, contains: "table=color.table.background.primary")
        try assertTokenValue(screen.tableScene, contains: "label=color.text.primary")
        try assertTokenValue(screen.tableScene, contains: "station=color.station.outline")
        try assertTokenValue(screen.cardTable, contains: "shape=circle")
        try assertTokenValue(screen.cardTable, contains: "surface=color.table.background.secondary")
        try assertTokenValue(screen.cardTable, contains: "dealer=south")
        try assertTokenValue(screen.cardTable, contains: "depth=railAndInnerBevel")
        try assertTokenValue(screen.cardTable, contains: "railHighlightOpacity=effect.table.rail.highlight.opacity")
        try assertTokenValue(screen.cardTable, contains: "railInnerBevelOpacity=effect.table.rail.innerBevel.opacity")
        try assertTokenValue(screen.cardTable, contains: "railShadowOpacity=effect.table.rail.shadow.opacity")
        try assertTokenValue(screen.cardTable, contains: "railShadowRadius=effect.table.rail.shadow.radius")
        try assertTokenValue(screen.cardTable, contains: "playArea=reservedForTrickPlay")
        try assertTokenValue(screen.cardTable, contains: "playAreaSlots=4")
        try assertTokenValue(screen.cardTable, contains: "titlePlacement=top")
        try assertTokenValue(screen.playArea, contains: "reservedFor=trickPlay")
        try assertTokenValue(screen.playArea, contains: "centerReserved=true")
        try assertTokenValue(screen.playArea, contains: "slotCount=4")
        try assertTokenValue(screen.playArea, contains: "surface=color.table.background.primary")
        try assertTokenValue(screen.playArea, contains: "border=color.table.felt.highlight")
        try assertTokenValue(screen.playArea, contains: "slotBorder=color.trickPlay.slot.border")
        try assertTokenValue(screen.playArea, contains: "shadowOpacity=effect.table.playArea.shadow.opacity")
        try assertTokenValue(screen.playArea, contains: "layout=tableCenter")
        try assertTokenValue(screen.playArea, contains: "activeTargetSlot=none")
        try assertTokenValue(screen.playArea, contains: "activeSlotTreatment=softRing")
        try assertTokenValue(screen.playArea, contains: "activeSlotOutline=color.trickPlay.activeSeat.outline")
        try assertTokenValue(screen.playArea, contains: "activeSlotOutlineOpacity=effect.trickPlay.activeSlot.outline.opacity")
        try assertTokenValue(screen.playArea, contains: "playedCardMotion=stationToCenter")
        try assertTokenValue(screen.playArea, contains: "playedCardTargets=south,west,north,east")
        try assertTokenValue(screen.playArea, contains: "playedCardTargetLayout=matchingSeatSlots")
        try assertTokenValue(screen.playArea, contains: "playedCardFlight=animation.trick.playedCard.flight.duration")
        try assertTokenValue(screen.playArea, contains: "playedCardFlightSeconds=0.3")
        try assertTokenValue(screen.southPlayAreaSlot, contains: "rotationDegrees=0")
        try assertTokenValue(screen.westPlayAreaSlot, contains: "rotationDegrees=0")
        try assertTokenValue(screen.northPlayAreaSlot, contains: "rotationDegrees=180")
        try assertTokenValue(screen.eastPlayAreaSlot, contains: "rotationDegrees=0")
        try assertTokenValue(screen.title, contains: "font=typography.tableTitle.font")
        try assertTokenValue(screen.title, contains: "fontName=SF Arabic Rounded Bold")
        try assertTokenValue(screen.title, contains: "fontSize=typography.tableTitle.fontSize")
        try assertTokenValue(screen.title, contains: "pointSize=26.0")
        try assertTokenValue(screen.title, contains: "trackingMin=typography.tableTitle.tracking.min")
        try assertTokenValue(screen.title, contains: "trackingMax=typography.tableTitle.tracking.max")
        try assertTokenValue(screen.title, contains: "textColor=color.tableTitle.text")
        try assertTokenValue(screen.title, contains: "textOpacity=effect.tableTitle.text.opacity")
        try assertTokenValue(screen.title, contains: "textOpacityValue=0.72")
        try assertTokenValue(screen.title, contains: "shadowColor=effect.tableTitle.shadow.color")
        try assertTokenValue(screen.title, contains: "usesShadow=true")
        try assertTokenValue(screen.title, contains: "shadowOpacityValue=0.38")
        try assertTokenValue(screen.title, contains: "shadowOffsetY=effect.tableTitle.shadow.offset.y")
        try assertTokenValue(screen.title, contains: "highlightColor=effect.tableTitle.highlight.color")
        try assertTokenValue(screen.title, contains: "highlightOpacity=effect.tableTitle.highlight.opacity")
        try assertTokenValue(screen.title, contains: "highlightOpacityValue=0.18")
        try assertTokenValue(screen.title, contains: "highlightBlur=effect.tableTitle.highlight.blurRadius")
        try assertTokenValue(screen.title, contains: "highlightOffsetY=effect.tableTitle.highlight.offset.y")
        try assertTokenValue(screen.title, contains: "style=embossedFelt")
        try assertTokenValue(screen.undealtDeckStack, contains: "count=52")
        try assertTokenValue(screen.undealtDeckStack, contains: "asset=card_back")
        try assertTokenValue(screen.undealtDeckStack, contains: "layout=squaredStack")
        try assertTokenValue(screen.undealtDeckStack, contains: "source=dealerStation")
        try assertTokenValue(screen.undealtDeckStack, contains: "dealerSeat=south")
        try assertTokenValue(screen.undealtDeckStack, contains: "placement=dealerStation")
        try assertTokenValue(screen.undealtDeckStack, contains: "anchor=stationCenter")
        try assertTokenValue(screen.undealtDeckStack, contains: "anchorX=layout.undealtDeck.anchor.x")
        try assertTokenValue(screen.undealtDeckStack, contains: "anchorXValue=0.5")
        try assertTokenValue(screen.undealtDeckStack, contains: "anchorY=layout.undealtDeck.anchor.y")
        try assertTokenValue(screen.undealtDeckStack, contains: "anchorYValue=0.5")
        try assertTokenValue(screen.undealtDeckStack, contains: "centerOffsetX=layout.undealtDeck.centerOffset.x")
        try assertTokenValue(screen.undealtDeckStack, contains: "centerOffsetXValue=0.0")
        try assertTokenValue(screen.undealtDeckStack, contains: "centerOffsetY=layout.undealtDeck.centerOffset.y")
        try assertTokenValue(screen.undealtDeckStack, contains: "centerOffsetYValue=0.0")
        try assertTokenValue(screen.undealtDeckStack, contains: "stackRotation=layout.undealtDeck.stack.rotation")
        try assertTokenValue(screen.undealtDeckStack, contains: "stackRotationValue=0.0")
        try assertTokenValue(screen.undealtDeckStack, contains: "stackOffsetX=layout.undealtDeck.stack.offset.x")
        try assertTokenValue(screen.undealtDeckStack, contains: "stackOffsetXValue=0.0")
        try assertTokenValue(screen.undealtDeckStack, contains: "stackOffsetY=layout.undealtDeck.stack.offset.y")
        try assertTokenValue(screen.undealtDeckStack, contains: "stackOffsetYValue=0.0")
        try assertTokenValue(screen.undealtDeckStack, contains: "edgeBuffer=layout.undealtDeck.edgeBuffer.min")
        try assertTokenValue(screen.undealtDeckStack, contains: "edgeBufferValue=12.0")
        try assertTokenValue(screen.undealtDeckStack, contains: "titleOverlapAllowed=false")
        try assertTokenValue(screen.dealButton, contains: "background=color.button.deal.background")
        try assertTokenValue(screen.dealButton, contains: "pressed=color.button.deal.background.pressed")
        try assertTokenValue(screen.dealButton, contains: "text=color.button.deal.text")
        try assertTokenValue(screen.newGameButton, contains: "background=color.button.newGame.background")
        try assertTokenValue(screen.newGameButton, contains: "pressed=color.button.newGame.background.pressed")
        try assertTokenValue(screen.newGameButton, contains: "text=color.button.newGame.text")

        try assertTokenValue(screen.southSeatArea, contains: "outline=color.station.outline")
        try assertTokenValue(screen.southSeatArea, contains: "dealerIndicator=pill")
        try assertTokenValue(screen.southSeatArea, contains: "dealerPillVisible=true")
        try assertTokenValue(screen.southSeatArea, contains: "dealerPillPlacement=besideName")
        try assertTokenValue(screen.southSeatArea, contains: "dealerPillText=D")
        try assertTokenValue(screen.southSeatArea, contains: "dealerPillBackground=color.dealerBadge.background")
        try assertTokenValue(screen.southSeatArea, contains: "dealerPillTextColor=color.dealerBadge.text")
        try assertTokenValue(screen.southSeatArea, contains: "dealerSeat=south")
        try assertTokenValue(screen.southDealerPill, contains: "dealerPillVisible=true")
        try assertTokenValue(screen.southDealerPill, contains: "dealerPillPlacement=besideName")

        for station in screen.stationAreas {
            try assertTokenValue(station, contains: "trickCounterReserved=true")
            try assertTokenValue(station, contains: "trickCounterVisible=false")
            try assertTokenValue(station, contains: "trickCount=none")
            try assertTokenValue(station, contains: "trickCountScope=individual")
            try assertTokenValue(station, contains: "partnershipTrickCount=none")
            try assertTokenValue(station, contains: "trickCounterHeaderOffset=layout.trickPlay.counter.headerOffset")
            try assertTokenValue(station, contains: "trickCounterStationEdgeOffset=layout.trickPlay.counter.stationEdgeOffset")
        }
        try assertTokenValue(screen.southSeatArea, contains: "trickCounterPlacement=stationBottomDock")
        try assertTokenValue(screen.northSeatArea, contains: "trickCounterPlacement=stationBottomDock")
        try assertTokenValue(screen.westSeatArea, contains: "trickCounterPlacement=stationBottomDock")
        try assertTokenValue(screen.eastSeatArea, contains: "trickCounterPlacement=stationBottomDock")

        for station in screen.nonDealerStationAreas {
            try assertTokenValue(station, contains: "shape=roundedSquare")
            try assertTokenValue(station, contains: "label=color.text.primary")
            try assertTokenValue(station, contains: "outline=color.station.outline")
            try assertTokenValue(station, contains: "dealerPillVisible=false")
        }
    }

    func testAppRemainsPortraitWhenDeviceRotates() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(app.frame.height, app.frame.width)

        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(app.frame.height, app.frame.width)
    }

    func testTappingDealShowsDealtTableAndHidesUndealtDeckStack() throws {
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        XCTAssertTrue(screen.cardTable.exists)
        XCTAssertTrue(screen.playArea.exists)
        XCTAssertFalse(screen.undealtDeckStack.exists)
        XCTAssertEqual(screen.deckStackCards.count, 0)
        XCTAssertTrue(screen.southVisibleHand.exists)
        try assertTokenValue(screen.southVisibleHand, contains: "layout=suitGroupedLanes")
        try assertTokenValue(screen.southVisibleHand, contains: "laneCount=4")
        try assertTokenValue(screen.southVisibleHand, contains: "suitLaneHeaders=visible")
        try assertTokenValue(screen.southVisibleHand, contains: "suitBoundarySpacing=8")
        try assertTokenValue(screen.southVisibleHand, contains: "ownership=player")
        try assertTokenValue(screen.southVisibleHand, contains: "ownershipSurface=baselineRail")
        try assertTokenValue(screen.southVisibleHand, contains: "ownershipBackgroundOpacity=effect.southHand.rail.background.opacity")
        try assertTokenValue(screen.southVisibleHand, contains: "ownershipStrokeOpacity=effect.southHand.rail.stroke.opacity")
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.westHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.northHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.eastHiddenCardBacks.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
        XCTAssertTrue(screen.dealCompleteMessage.exists)
        XCTAssertTrue(screen.bidArea.exists)
        XCTAssertTrue(screen.bidLabel.exists)
        XCTAssertTrue(screen.bidTable.exists)
        XCTAssertTrue(screen.southBidButton.exists)
        XCTAssertTrue(screen.southBidSelector.exists || screen.southStationBid.exists)
        if screen.southBidSelector.exists {
            assertSouthBidButtonAppearsInlineWithBidChoices(on: screen)
        }
        assertBidAreaShowsLegalValues(on: screen)
        XCTAssertTrue(screen.dealButton.exists)
        XCTAssertEqual(screen.dealButton.label, "Deal")
        XCTAssertFalse(screen.dealButton.isEnabled)
        XCTAssertTrue(screen.newGameButton.exists)
        XCTAssertEqual(screen.newGameButton.label, "New Game")
        XCTAssertTrue(screen.newGameButton.isEnabled)
        XCTAssertTrue(screen.gameScore.exists)
        try assertTokenValue(screen.gameScore, contains: "northSouth=0")
        try assertTokenValue(screen.gameScore, contains: "eastWest=0")
        try assertTokenValue(screen.gameScore, contains: "winningScore=31")
        try assertTokenValue(screen.gameScore, contains: "winner=none")
        XCTAssertEqual(screen.dealerStationAreas.count, 1)
        XCTAssertEqual(screen.dealerStationAreas.first?.identifier, "tarneeb-seat-area-south")
        XCTAssertEqual(screen.dealerPills.count, 0)

        assertStationsSurroundTable(on: screen)
        assertSouthStationExpandedBelowTable(on: screen)
        assertBidAreaAppearsUnderSouthStation(on: screen)
        assertBiddingDoesNotClaimTablePlayArea(on: screen)
        assertCompletionAppearsAboveBottomDeal(on: screen)
        assertBottomDealButtonIsAtBottom(on: screen, in: app)
    }

    func testDealAnimationShowsThirteenCardStacksFromDealerStationBeforeCompletion() throws {
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        screen.dealButton.tap()

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 8))
        try assertTokenValue(screen.cardTable, contains: "lastDealAnimation=completed")
        try assertTokenValue(screen.cardTable, contains: "start=dealerRight")
        try assertTokenValue(screen.cardTable, contains: "direction=counterclockwise")
        try assertTokenValue(screen.cardTable, contains: "origin=dealerStation")
        try assertTokenValue(screen.cardTable, contains: "cardsPerStack=13")
        try assertTokenValue(screen.cardTable, contains: "totalCards=52")
        try assertTokenValue(screen.cardTable, contains: "targetOrder=east,north,west,south")
        try assertTokenValue(screen.cardTable, contains: "flightDuration=animation.deal.stack.flight.duration")
        XCTAssertFalse(screen.dealAnimationStack.exists)
        XCTAssertFalse(screen.undealtDeckStack.exists)
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
    }

    func testSouthCardsStayUnrevealedWhileInterimFannedBacksAreVisible() throws {
        let app = launchApp(initialDealer: "west")
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        let initialDealerNameTopOffset = screen.westSeat.frame.minY - screen.westSeatArea.frame.minY
        assertSeatLabelPinnedToTop(screen.westSeat, in: screen.westSeatArea)
        screen.dealButton.tap()

        let fannedValue = try waitForTokenValue(screen.cardTable, contains: "southRevealState=fannedBacks", timeout: 3)
        XCTAssertTrue(fannedValue.contains("dealAnimation=running"))
        XCTAssertTrue(fannedValue.contains("southRevealRevealedCount=0"))
        XCTAssertTrue(fannedValue.contains("southInterimFannedBacksVisible=true"))
        XCTAssertTrue(fannedValue.contains("dealCompletionAvailable=false"))
        assertSeatLabelPinnedToTop(screen.westSeat, in: screen.westSeatArea)
        XCTAssertEqual(screen.westSeat.frame.minY - screen.westSeatArea.frame.minY, initialDealerNameTopOffset, accuracy: 2)
        XCTAssertTrue(screen.southHiddenHand.exists)
        XCTAssertEqual(screen.southHiddenCardBacks.count, 13)
        XCTAssertFalse(screen.dealCompleteMessage.exists)
        XCTAssertFalse(screen.bidArea.exists)
    }

    func testSouthRevealShowsBacksThenFlipsBeforeCompletion() throws {
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        screen.dealButton.tap()

        let revealValue = try waitForAnyTokenValue(
            screen.cardTable,
            containsAny: ["southRevealState=backsVisible", "southRevealState=flipping"],
            timeout: 5
        )
        XCTAssertFalse(revealValue.contains("dealCompletionAvailable=true"))
        XCTAssertTrue(screen.southRevealHand.exists)
        try assertTokenValue(screen.southRevealHand, contains: "backCount=13")
        try assertTokenValue(screen.southRevealHand, contains: "direction=leftToRight")
        try assertTokenValue(screen.southRevealHand, contains: "layout=suitGroupedLanes")
        try assertTokenValue(screen.southRevealHand, contains: "laneCount=4")
        try assertTokenValue(screen.southRevealHand, contains: "suitLaneHeaders=visible")
        try assertTokenValue(screen.southRevealHand, contains: "suitBoundarySpacing=8")
        try assertTokenValue(screen.southRevealHand, contains: "ownership=player")
        try assertTokenValue(screen.southRevealHand, contains: "ownershipSurface=baselineRail")
        try assertTokenValue(screen.southRevealHand, contains: "ownershipBackgroundOpacity=effect.southHand.rail.background.opacity")
        try assertTokenValue(screen.southRevealHand, contains: "ownershipStrokeOpacity=effect.southHand.rail.stroke.opacity")
        XCTAssertFalse(screen.dealCompleteMessage.exists)
        XCTAssertFalse(screen.bidArea.exists)

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 8))
        XCTAssertFalse(screen.southRevealHand.exists)
        XCTAssertTrue(screen.southVisibleHand.exists)
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertTrue(screen.bidArea.exists)
    }

    func testSouthInterimFannedBackStackStaysVisibleUntilFinalReveal() throws {
        let app = launchApp(initialDealer: "west")
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        screen.dealButton.tap()

        let fannedValue = try waitForTokenValue(screen.cardTable, contains: "southRevealState=fannedBacks", timeout: 3)
        XCTAssertTrue(fannedValue.contains("southInterimFannedBacksVisible=true"))
        XCTAssertTrue(screen.southHiddenHand.exists)
        XCTAssertEqual(screen.southHiddenCardBacks.count, 13)
        try assertTokenValue(screen.southHiddenHand, contains: "count=13")
        try assertTokenValue(screen.southSeatArea, contains: "shape=roundedSquare")
        XCTAssertFalse(screen.southRevealHand.exists)
        XCTAssertFalse(screen.visibleCardLabels.contains { $0.contains("♠") || $0.contains("♣") || $0.contains("♥") || $0.contains("♦") })

        let revealValue = try waitForAnyTokenValue(
            screen.cardTable,
            containsAny: ["southRevealState=backsVisible", "southRevealState=flipping"],
            timeout: 5
        )
        XCTAssertTrue(revealValue.contains("southRevealTotalDuration=animation.deal.southReveal.total.duration"))
        try assertTokenValue(screen.southSeatArea, contains: "shape=expandedRoundedStation")
        try assertTokenValue(screen.southRevealHand, contains: "totalDuration=animation.deal.southReveal.total.duration")
        try assertTokenValue(screen.southRevealHand, contains: "totalSeconds=1.5")
        try assertTokenValue(screen.southRevealHand, contains: "ownershipSurface=baselineRail")
    }

    func testDealtScreenExposesTokenAndCardSizeHooks() throws {
        let app = launchApp(initialDealer: "west")
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        try assertTokenValue(screen.dealCompleteMessage, contains: "text=color.text.primary")
        try assertTokenValue(screen.dealCompleteMessage, contains: "status=Deal complete")
        try assertTokenValue(screen.dealCompleteMessage, contains: "treatment=compactPhasePill")
        try assertTokenValue(screen.dealCompleteMessage, contains: "backgroundOpacity=effect.phaseStatus.background.opacity")
        try assertTokenValue(screen.dealButton, contains: "background=color.button.deal.background")
        try assertTokenValue(screen.dealButton, contains: "pressed=color.button.deal.background.pressed")
        try assertTokenValue(screen.dealButton, contains: "text=color.button.deal.text")
        try assertTokenValue(screen.newGameButton, contains: "background=color.button.newGame.background")
        try assertTokenValue(screen.newGameButton, contains: "pressed=color.button.newGame.background.pressed")
        try assertTokenValue(screen.newGameButton, contains: "text=color.button.newGame.text")
        try assertTokenValue(screen.bidArea, contains: "label=Bidding")
        try assertTokenValue(screen.bidArea, contains: "rows=south,east,north,west")
        try assertTokenValue(screen.bidArea, contains: "allowed=Pass,7,8,9,10,11,12,13")
        try assertTokenValue(screen.bidArea, contains: "currentTurn=south")
        try assertTokenValue(screen.bidArea, contains: "highestSeat=none")
        try assertTokenValue(screen.bidArea, contains: "highestBid=none")
        try assertTokenValue(screen.bidArea, contains: "southSuitOptions=spades,clubs,hearts,diamonds")
        try assertTokenValue(screen.bidArea, contains: "southDraftBid=Pass")
        try assertTokenValue(screen.bidArea, contains: "southDraftTarneebSuit=none")
        try assertTokenValue(screen.bidArea, contains: "southTarneebSuitSelectorVisible=false")
        try assertTokenValue(screen.bidArea, contains: "southTarneebSuitSelectorEnabled=false")
        try assertTokenValue(screen.bidArea, contains: "southBidButtonVisible=true")
        try assertTokenValue(screen.bidArea, contains: "southBidButtonEnabled=true")
        try assertTokenValue(screen.bidArea, contains: "areaTokens=background=color.bidArea.background")
        try assertTokenValue(screen.bidArea, contains: "highestValueText=color.bidArea.value.highest.text")
        try assertTokenValue(screen.bidArea, contains: "selectorTokens=background=color.bidSelector.background")
        try assertTokenValue(screen.bidArea, contains: "suitSelectorTokens=background=color.card.background")
        try assertTokenValue(screen.bidArea, contains: "border=color.card.border")
        try assertTokenValue(screen.bidArea, contains: "focusRing=color.button.newGame.background")
        try assertTokenValue(screen.bidArea, contains: "bidButtonTokens=background=color.button.bid.background")
        try assertTokenValue(screen.bidArea, contains: "simulatedBidDelay=animation.bid.simulatedTurn.delay")
        try assertTokenValue(screen.bidArea, contains: "simulatedBidDelaySeconds=1.0")
        try assertTokenValue(screen.bidArea, contains: "stationCuePulse=animation.bid.stationCue.pulse.duration")
        try assertTokenValue(screen.bidArea, contains: "stationCuePulseSeconds=0.24")
        try assertTokenValue(screen.bidArea, contains: "fadeOut=animation.bid.value.fadeOut.duration")
        try assertTokenValue(screen.bidArea, contains: "fadeTotalSeconds=1.0")
        try assertTokenValue(screen.bidLabel, contains: "text=color.bidArea.label")
        try assertTokenValue(screen.bidTable, contains: "display=station-surfaces")
        try assertTokenValue(screen.bidTable, contains: "rows=south,east,north,west")
        try assertTokenValue(screen.southBidSelector, contains: "selected=Pass")
        try assertTokenValue(screen.southBidSelector, contains: "allowed=Pass,7,8,9,10,11,12,13")
        try assertTokenValue(screen.southBidSelector, contains: "background=color.bidSelector.background")
        XCTAssertFalse(screen.southTarneebSuitSelector.exists)
        try assertTokenValue(screen.southBidButton, contains: "background=color.button.bid.background")
        try assertTokenValue(screen.southBidButton, contains: "enabled=true")
        try assertTokenValue(screen.southBidButton, contains: "selected=Pass")
        try assertTokenValue(screen.southBidButton, contains: "title=Bid")

        for label in screen.seatLabels {
            try assertTokenValue(label, contains: "text=color.text.primary")
        }

        for station in screen.stationAreas {
            try assertTokenValue(station, contains: "label=color.text.primary")
            try assertTokenValue(station, contains: "bidSurfaceVisible=true")
            try assertTokenValue(station, contains: "trickCounterReserved=true")
            try assertTokenValue(station, contains: "trickCounterVisible=false")
            try assertTokenValue(station, contains: "trickCount=none")
            try assertTokenValue(station, contains: "trickCountScope=individual")
            try assertTokenValue(station, contains: "partnershipTrickCount=none")
            try assertStationOutlineMatchesBiddingState(station)
        }
        try assertTokenValue(screen.southStationBid, contains: "value=--")
        try assertTokenValue(screen.eastStationBid, contains: "value=--")
        try assertTokenValue(screen.northStationBid, contains: "value=--")
        try assertTokenValue(screen.westStationBid, contains: "value=--")
        XCTAssertEqual(screen.dealerPills.count, 0)
        try assertTokenValue(screen.westSeatArea, contains: "dealerSeat=west")
        try assertTokenValue(screen.westSeatArea, contains: "dealerPillVisible=false")
        for station in [screen.southSeatArea, screen.northSeatArea, screen.eastSeatArea] {
            try assertTokenValue(station, contains: "dealerPillVisible=false")
        }

        for card in screen.visibleCards.allElementsBoundByIndex {
            let value = try XCTUnwrap(card.value as? String)
            XCTAssertTrue(value.contains("asset=card_face_"))
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
        let app = launchApp()
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
        let app = launchApp()
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
            try assertTokenValue(hiddenHand, contains: "layout=stackedFan")
            try assertTokenValue(hiddenHand, contains: "fanRotationStep=0.35")
        }
    }

    func testBidAreaAppearsAfterDealWithLegalValuesForAllPlayers() throws {
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        XCTAssertFalse(screen.bidArea.exists)

        deal(on: screen)

        XCTAssertTrue(screen.bidArea.exists)
        XCTAssertTrue(screen.bidTable.exists)
        try assertTokenValue(screen.bidTable, contains: "display=station-surfaces")
        XCTAssertEqual(screen.bidLabel.label, "Bidding")
        assertBidAreaAppearsUnderSouthStation(on: screen)
        assertBidAreaShowsLegalValues(on: screen)
        XCTAssertTrue(screen.southBidButton.exists)
        XCTAssertFalse(screen.southTarneebSuitSelector.exists)
        XCTAssertTrue(screen.southBidSelector.exists || screen.southStationBid.exists)
        if screen.southBidSelector.exists {
            assertSouthBidButtonAppearsInlineWithBidChoices(on: screen)
        }
        XCTAssertFalse(app.buttons.matching(identifier: "tarneeb-station-bid-east").firstMatch.exists)
        XCTAssertFalse(app.buttons.matching(identifier: "tarneeb-station-bid-north").firstMatch.exists)
        XCTAssertFalse(app.buttons.matching(identifier: "tarneeb-station-bid-west").firstMatch.exists)
        XCTAssertFalse(app.staticTexts["Winning Bid"].exists)
    }

    func testSouthBidChipsShowAllowedValuesAndUpdateSelection() throws {
        let app = launchApp(initialDealer: "west", simulatedBids: "east:Pass,north:Pass,west:Pass")
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        try assertTokenValue(screen.southBidSelector, contains: "selected=Pass")
        assertSouthBidButtonAppearsInlineWithBidChoices(on: screen)

        for optionLabel in ["Pass", "7", "8", "9", "10", "11", "12", "13"] {
            XCTAssertTrue(app.buttons[optionLabel].waitForExistence(timeout: 2), "Missing bid option \(optionLabel)")
        }

        app.buttons["10"].tap()

        XCTAssertTrue(screen.southBidSelector.waitForExistence(timeout: 2))
        try assertTokenValue(screen.southBidSelector, contains: "selected=10")
        try assertTokenValue(screen.bidArea, contains: "values=south:--")
        try assertTokenValue(screen.bidArea, contains: "southDraftBid=10")
        XCTAssertFalse(screen.southTarneebSuitSelector.exists)
        XCTAssertTrue(screen.southBidButton.isEnabled)
        try assertTokenValue(screen.bidArea, contains: "southDraftTarneebSuit=none")
        try assertTokenValue(screen.bidArea, contains: "southTarneebSuitSelectorEnabled=false")
        try assertTokenValue(screen.southBidButton, contains: "title=Bid")
        assertBidAreaShowsLegalValues(on: screen)

        screen.southBidButton.tap()

        XCTAssertTrue(screen.southStationBid.waitForExistence(timeout: 2))
        XCTAssertTrue(screen.southBidButton.exists)
        XCTAssertFalse(screen.southBidButton.isEnabled)
        XCTAssertFalse(screen.southBidSelector.exists)
        XCTAssertFalse(screen.southTarneebSuitSelector.exists)
        try assertTokenValue(screen.southStationBid, contains: "value=10")
        try assertTokenValue(screen.southStationBid, contains: "currentHighest=true")
        try assertTokenValue(screen.southStationBid, contains: "valueText=color.bidArea.value.highest.text")
        try assertTokenValue(screen.bidArea, contains: "status=inProgress")
        try assertTokenValue(screen.bidArea, contains: "highestSeat=south")
        try assertTokenValue(screen.bidArea, contains: "valueTextRoles=south:color.bidArea.value.highest.text")

        XCTAssertTrue(screen.biddingCompleteMessage.waitForExistence(timeout: 8))
        XCTAssertFalse(screen.southBidButton.exists)
        try assertTokenValue(screen.dealCompleteMessage, contains: "status=Bidding complete")
        try assertTokenValue(screen.dealCompleteMessage, contains: "treatment=compactPhasePill")
        XCTAssertTrue(screen.southTarneebSelection.waitForExistence(timeout: 4))
        try assertTokenValue(screen.tableScene, contains: "southTarneebSelectionVisible=true")
        try assertTokenValue(screen.southTarneebSelection, contains: "highBidder=South")
        try assertTokenValue(screen.southTarneebSelection, contains: "bid=10")
        try assertTokenValue(screen.southTarneebSelection, contains: "selected=none")
        try assertTokenValue(screen.postBiddingSouthSuitSelector, contains: "selected=none")
        try assertTokenValue(screen.postBiddingSouthSuitButton, contains: "enabled=false")
        assertPostBiddingSetButtonAppearsInlineWithSuitChoices(on: screen)
        try assertTokenValue(screen.southTarneebSuitOption("spades"), contains: "background=color.card.background")
        try assertTokenValue(screen.southTarneebSuitOption("spades"), contains: "border=color.card.border")
        try assertTokenValue(screen.southTarneebSuitOption("spades"), contains: "text=color.card.suit.black")
        try assertTokenValue(screen.southTarneebSuitOption("clubs"), contains: "background=color.card.background")
        try assertTokenValue(screen.southTarneebSuitOption("clubs"), contains: "text=color.card.suit.black")
        try assertTokenValue(screen.southTarneebSuitOption("hearts"), contains: "background=color.card.background")
        try assertTokenValue(screen.southTarneebSuitOption("hearts"), contains: "text=color.card.suit.red")
        try assertTokenValue(screen.southTarneebSuitOption("diamonds"), contains: "background=color.card.background")
        try assertTokenValue(screen.southTarneebSuitOption("diamonds"), contains: "text=color.card.suit.red")

        screen.southTarneebSuitOption("spades").tap()

        XCTAssertTrue(screen.postBiddingSouthSuitButton.isEnabled)
        try assertTokenValue(screen.southTarneebSelection, contains: "selected=spades")
        try assertTokenValue(screen.postBiddingSouthSuitSelector, contains: "selected=spades")
        try assertTokenValue(screen.southTarneebSuitOption("spades"), contains: "border=color.button.newGame.background")
        try assertTokenValue(screen.postBiddingSouthSuitButton, contains: "title=Set")

        screen.postBiddingSouthSuitButton.tap()

        XCTAssertTrue(screen.postBiddingSummary.waitForExistence(timeout: 2))
        XCTAssertFalse(screen.southTarneebSelection.exists)
        XCTAssertFalse(screen.southStationBid.exists)
        XCTAssertFalse(screen.eastStationBid.exists)
        XCTAssertFalse(screen.northStationBid.exists)
        XCTAssertFalse(screen.westStationBid.exists)
        try assertTokenValue(screen.postBiddingSummary, contains: "placement=outsideTableUpperLeft")
        try assertTokenValue(screen.postBiddingSummary, contains: "display=contractBox")
        try assertTokenValue(screen.postBiddingSummary, contains: "style=feltScoreboardPlaque")
        try assertTokenValue(screen.postBiddingSummary, contains: "highBidder=South")
        try assertTokenValue(screen.postBiddingSummary, contains: "bid=10")
        try assertTokenValue(screen.postBiddingSummary, contains: "tarneebLabel=Tarneeb")
        try assertTokenValue(screen.postBiddingSummary, contains: "tarneebSymbol=♠")
        try assertTokenValue(screen.postBiddingSummary, contains: "tarneebSymbolColor=color.card.suit.black")
        try assertTokenValue(screen.postBiddingSummary, contains: "tarneebSymbolBackground=color.card.background")
        try assertTokenValue(screen.postBiddingSummary, contains: "tarneebSymbolBorder=color.button.newGame.background")
        try assertTokenValue(screen.postBiddingSummary, contains: "tarneebSymbolChipTokens=background=color.card.background")
        try assertTokenValue(screen.postBiddingSummary, contains: "backgroundOpacity=effect.postBiddingSummary.background.opacity")
        try assertTokenValue(screen.postBiddingSummary, contains: "borderOpacity=effect.postBiddingSummary.border.opacity")
        try assertTokenValue(screen.postBiddingSummary, contains: "shadowOpacity=effect.postBiddingSummary.shadow.opacity")
        try assertTokenValue(screen.postBiddingSummary, contains: "suitChipHorizontalPadding=layout.postBiddingSummary.suitChip.padding.horizontal")
        assertContractBoxIsAnchoredOutsideUpperLeftTable(on: screen)
    }

    func testSouthPassRemainsReadonlyAfterLaterPlayerRaises() throws {
        let app = launchApp(initialDealer: "west", simulatedBids: "east:7,north:8,west:Pass")
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        XCTAssertTrue(screen.southBidSelector.exists)
        try assertTokenValue(screen.southBidSelector, contains: "selected=Pass")
        XCTAssertFalse(screen.southTarneebSuitSelector.exists)
        try assertTokenValue(screen.southBidButton, contains: "title=Bid")

        screen.southBidButton.tap()

        XCTAssertTrue(screen.southStationBid.waitForExistence(timeout: 2))
        XCTAssertFalse(screen.southBidSelector.exists)
        XCTAssertFalse(screen.southTarneebSuitSelector.exists)
        try assertTokenValue(screen.southStationBid, contains: "value=Pass")

        try waitForTokenValue(screen.tableScene, contains: "bidAreaVisible=false", timeout: 8)
        XCTAssertTrue(screen.biddingCompleteMessage.exists)
        XCTAssertFalse(screen.southBidSelector.exists)
        XCTAssertFalse(screen.southTarneebSuitSelector.exists)
        XCTAssertFalse(screen.southBidButton.exists)
    }

    func testAllPassBiddingAutomaticallyRedealsAndRotatesDealer() throws {
        let app = launchApp(initialDealer: "west", simulatedBids: "east:Pass,north:Pass,west:Pass")
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        try assertTokenValue(screen.bidArea, contains: "currentTurn=south")
        try assertTokenValue(screen.bidArea, contains: "values=south:--,east:--,north:--,west:--")
        try assertTokenValue(screen.bidArea, contains: "southDraftBid=Pass")

        screen.southBidButton.tap()

        try waitForTokenValue(screen.bidArea, contains: "completionOutcome=allPassRedeal", timeout: 6)
        try waitForTokenValue(screen.tableScene, contains: "bidAreaVisible=false", timeout: 4)
        try waitForTokenValue(screen.tableScene, contains: "dealer=south", timeout: 10)
        try waitForTokenValue(screen.bidArea, contains: "completionOutcome=none", timeout: 10)
        try assertTokenValue(screen.bidArea, contains: "status=inProgress")
        try assertTokenValue(screen.southSeatArea, contains: "dealerSeat=south")
        try assertTokenValue(screen.southSeatArea, contains: "dealerPillVisible=false")
        XCTAssertFalse(screen.postBiddingSummary.exists)
    }

    func testDealButtonIsDisabledAfterOpeningDeal() throws {
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        deal(on: screen)
        let firstSouthHand = screen.visibleCardLabels
        XCTAssertEqual(firstSouthHand.count, 13)

        XCTAssertTrue(screen.dealButton.exists)
        XCTAssertEqual(screen.dealButton.label, "Deal")
        XCTAssertFalse(screen.dealButton.isEnabled)
        screen.dealButton.tap()

        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
        XCTAssertTrue(screen.bidArea.exists)
        assertBidAreaShowsLegalValues(on: screen)
        XCTAssertFalse(screen.undealtDeckStack.exists)
        try assertTokenValue(screen.southSeatArea, contains: "dealerSeat=south")
        XCTAssertEqual(screen.dealerStationAreas.count, 1)
        XCTAssertEqual(screen.dealerStationAreas.first?.identifier, "tarneeb-seat-area-south")
        XCTAssertEqual(screen.visibleCardLabels, firstSouthHand)
        XCTAssertFalse(screen.oldDealCardsButton.exists)
        XCTAssertFalse(screen.oldNewDealButton.exists)
    }

    func testNewGameButtonResetsToOriginalLaunchStateAfterDeal() throws {
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        screen.newGameButton.tap()

        XCTAssertTrue(screen.cancelGameAlert.waitForExistence(timeout: 2))
        XCTAssertTrue(screen.keepPlayingButton.exists)
        XCTAssertTrue(screen.cancelGameButton.exists)
        screen.keepPlayingButton.tap()
        XCTAssertTrue(screen.gameScore.exists)
        XCTAssertFalse(screen.undealtDeckStack.exists)

        screen.newGameButton.tap()
        XCTAssertTrue(screen.cancelGameAlert.waitForExistence(timeout: 2))
        screen.cancelGameButton.tap()

        XCTAssertTrue(screen.undealtDeckStack.waitForExistence(timeout: 5))
        XCTAssertEqual(screen.deckStackCards.count, 52)
        XCTAssertEqual(screen.visibleCards.count, 0)
        XCTAssertEqual(screen.hiddenCardBacks.count, 0)
        XCTAssertFalse(screen.bidArea.exists)
        XCTAssertFalse(screen.bidTable.exists)
        XCTAssertFalse(screen.southBidSelector.exists)
        XCTAssertFalse(screen.southBidButton.exists)
        XCTAssertFalse(screen.dealCompleteMessage.exists)
        XCTAssertTrue(screen.dealButton.exists)
        XCTAssertTrue(screen.newGameButton.exists)
        XCTAssertEqual(screen.dealButton.label, "Deal")
        XCTAssertEqual(screen.newGameButton.label, "New Game")
        XCTAssertTrue(screen.dealButton.isEnabled)
        XCTAssertFalse(screen.newGameButton.isEnabled)
        XCTAssertFalse(screen.gameScore.exists)
        XCTAssertEqual(screen.dealerStationAreas.count, 1)
        XCTAssertEqual(screen.dealerStationAreas.first?.identifier, "tarneeb-seat-area-south")
        XCTAssertEqual(screen.dealerPills.count, 1)
        XCTAssertTrue(screen.southDealerPill.exists)
        try assertTokenValue(screen.southSeatArea, contains: "dealerPillVisible=true")

        assertTableTitleIsOnCardTable(on: screen)
        assertInitialDeckStackIsInDealerStation(on: screen)
        assertInitialStationsAreRoundedSquares(on: screen)
    }

    func testOpeningDealLeavesOnlyNewGameLive() throws {
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        screen.dealButton.tap()

        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 8))
        XCTAssertFalse(screen.dealButton.isEnabled)
        XCTAssertTrue(screen.newGameButton.isEnabled)
        XCTAssertTrue(screen.gameScore.exists)
        XCTAssertEqual(screen.visibleCards.count, 13)
        XCTAssertEqual(screen.hiddenCardBacks.count, 39)
        XCTAssertTrue(screen.bidArea.exists)
        assertBidAreaShowsLegalValues(on: screen)
    }

    func testPrimaryLayoutElementsRemainUsableAndNonOverlapping() throws {
        let app = launchApp()
        let screen = TarneebScreen(app: app)

        deal(on: screen)

        for element in screen.dealtUsabilityElements {
            assertElementIsUsableOnScreen(element, in: app)
        }

        assertNoSubstantialOverlap(screen.dealCompleteMessage, screen.dealButton)
        assertBidAreaAppearsUnderSouthStation(on: screen)
        assertCompletionAppearsAboveBottomDeal(on: screen)
        assertNoSubstantialOverlap(screen.northSeatArea, screen.cardTable)
        assertNoSubstantialOverlap(screen.southSeatArea, screen.cardTable)
        assertNoSubstantialOverlap(screen.westSeatArea, screen.eastSeatArea)

        for card in screen.visibleCards.allElementsBoundByIndex {
            assertFrame(card.frame, isInside: screen.southSeatArea.frame)
        }
        assertStationContentBelowLabel(screen.visibleCards.firstMatch, below: screen.southSeat)

        for hiddenCard in screen.westHiddenCardBacks.allElementsBoundByIndex {
            assertFrame(hiddenCard.frame, isInside: screen.westSeatArea.frame)
        }
        assertStationContentBelowLabel(screen.westHiddenCardBacks.firstMatch, below: screen.westSeat)

        for hiddenCard in screen.northHiddenCardBacks.allElementsBoundByIndex {
            assertFrame(hiddenCard.frame, isInside: screen.northSeatArea.frame)
        }
        assertStationContentBelowLabel(screen.northHiddenCardBacks.firstMatch, below: screen.northSeat)

        for hiddenCard in screen.eastHiddenCardBacks.allElementsBoundByIndex {
            assertFrame(hiddenCard.frame, isInside: screen.eastSeatArea.frame)
        }
        assertStationContentBelowLabel(screen.eastHiddenCardBacks.firstMatch, below: screen.eastSeat)
    }

    func testOldDealLabelsAndProhibitedGameplayControlsAreAbsent() throws {
        let app = launchApp()
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

    private func launchApp(
        initialDealer: String = "south",
        simulatedBids: String = "east:7,north:8,west:9"
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["TARNEEB_INITIAL_DEALER"] = initialDealer
        app.launchEnvironment["TARNEEB_SIMULATED_BIDS"] = simulatedBids
        app.launch()
        return app
    }

    private func deal(on screen: TarneebScreen) {
        XCTAssertTrue(screen.title.waitForExistence(timeout: 5))
        screen.dealButton.tap()
        XCTAssertTrue(screen.dealCompleteMessage.waitForExistence(timeout: 8))
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

    private func assertPlayAreaReservedAtTableCenter(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(screen.playArea.exists, file: file, line: line)
        XCTAssertTrue(screen.cardTable.frame.insetBy(dx: -4, dy: -4).contains(screen.playArea.frame), file: file, line: line)
        XCTAssertEqual(screen.playArea.frame.midX, screen.cardTable.frame.midX, accuracy: 4, file: file, line: line)
        XCTAssertEqual(screen.playArea.frame.midY, screen.cardTable.frame.midY, accuracy: 4, file: file, line: line)
        XCTAssertGreaterThan(screen.playArea.frame.width, screen.cardTable.frame.width * 0.45, file: file, line: line)
        XCTAssertLessThan(screen.playArea.frame.width, screen.cardTable.frame.width * 0.70, file: file, line: line)
        XCTAssertGreaterThan(screen.playArea.frame.height, screen.cardTable.frame.height * 0.32, file: file, line: line)
        XCTAssertLessThan(screen.playArea.frame.height, screen.cardTable.frame.height * 0.52, file: file, line: line)
        XCTAssertLessThan(screen.title.frame.maxY, screen.playArea.frame.minY, file: file, line: line)
    }

    private func assertInitialDeckStackIsInDealerStation(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let dealerStation = screen.dealerStationAreas.first
        XCTAssertNotNil(dealerStation, file: file, line: line)
        guard let dealerStation else {
            return
        }

        XCTAssertTrue(dealerStation.frame.insetBy(dx: -4, dy: -4).contains(screen.undealtDeckStack.frame), file: file, line: line)
        XCTAssertLessThan(
            abs(screen.undealtDeckStack.frame.midX - dealerStation.frame.midX),
            12,
            file: file,
            line: line
        )
        XCTAssertLessThan(
            abs(screen.undealtDeckStack.frame.midY - dealerStation.frame.midY),
            24,
            file: file,
            line: line
        )
        XCTAssertGreaterThan(abs(screen.undealtDeckStack.frame.midY - screen.cardTable.frame.midY), 20, file: file, line: line)
        XCTAssertTrue(screen.title.exists, file: file, line: line)
    }

    private func assertSeatLabelPinnedToTop(
        _ label: XCUIElement,
        in station: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let topOffset = label.frame.minY - station.frame.minY

        XCTAssertGreaterThanOrEqual(topOffset, 0, file: file, line: line)
        XCTAssertLessThanOrEqual(topOffset, 10, file: file, line: line)
    }

    private func assertStationContentBelowLabel(
        _ content: XCUIElement,
        below label: XCUIElement,
        minimumGap: CGFloat = 6,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(content.exists, file: file, line: line)
        XCTAssertTrue(label.exists, file: file, line: line)
        XCTAssertGreaterThanOrEqual(content.frame.minY, label.frame.maxY + minimumGap, file: file, line: line)
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

    private func assertBidAreaAppearsUnderSouthStation(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(screen.bidArea.frame.minY, screen.southSeatArea.frame.maxY - 2, file: file, line: line)
        XCTAssertEqual(Double(screen.bidArea.frame.midX), Double(screen.southSeatArea.frame.midX), accuracy: 12, file: file, line: line)
        XCTAssertLessThanOrEqual(screen.bidArea.frame.width, screen.southSeatArea.frame.width + 24, file: file, line: line)
    }

    private func assertBiddingDoesNotClaimTablePlayArea(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(screen.bidArea.exists, file: file, line: line)
        XCTAssertTrue(screen.playArea.exists, file: file, line: line)
        XCTAssertFalse(screen.bidArea.frame.intersects(screen.playArea.frame.insetBy(dx: -4, dy: -4)), file: file, line: line)
        XCTAssertGreaterThan(screen.bidArea.frame.minY, screen.playArea.frame.maxY, file: file, line: line)
    }

    private func assertContractBoxIsAnchoredOutsideUpperLeftTable(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(screen.postBiddingSummary.exists, file: file, line: line)
        XCTAssertTrue(screen.cardTable.exists, file: file, line: line)
        XCTAssertTrue(screen.playArea.exists, file: file, line: line)

        XCTAssertLessThan(screen.postBiddingSummary.frame.midX, screen.cardTable.frame.midX, file: file, line: line)
        XCTAssertLessThan(screen.postBiddingSummary.frame.midY, screen.cardTable.frame.midY, file: file, line: line)
        XCTAssertLessThan(screen.postBiddingSummary.frame.minX, screen.cardTable.frame.minX, file: file, line: line)
        XCTAssertLessThan(screen.postBiddingSummary.frame.minY, screen.cardTable.frame.minY, file: file, line: line)
        XCTAssertLessThan(screen.postBiddingSummary.frame.maxX, screen.cardTable.frame.midX, file: file, line: line)
        XCTAssertLessThan(screen.postBiddingSummary.frame.maxY, screen.cardTable.frame.midY, file: file, line: line)
        XCTAssertLessThan(screen.postBiddingSummary.frame.width, screen.cardTable.frame.width * 0.55, file: file, line: line)
        XCTAssertFalse(screen.postBiddingSummary.frame.intersects(screen.playArea.frame.insetBy(dx: -4, dy: -4)), file: file, line: line)
    }

    private func assertSouthBidButtonAppearsInlineWithBidChoices(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(screen.southBidButton.exists, file: file, line: line)
        XCTAssertTrue(screen.southBidSelector.exists, file: file, line: line)
        XCTAssertGreaterThanOrEqual(screen.southBidButton.frame.minX, screen.southBidSelector.frame.maxX - 2, file: file, line: line)
        XCTAssertEqual(screen.southBidButton.frame.midY, screen.southBidSelector.frame.midY, accuracy: 6, file: file, line: line)
        XCTAssertLessThanOrEqual(screen.southBidButton.frame.maxY, screen.bidArea.frame.maxY + 2, file: file, line: line)
    }

    private func assertPostBiddingSetButtonAppearsInlineWithSuitChoices(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(screen.postBiddingSouthSuitButton.exists, file: file, line: line)
        XCTAssertTrue(screen.postBiddingSouthSuitSelector.exists, file: file, line: line)
        XCTAssertGreaterThanOrEqual(screen.postBiddingSouthSuitButton.frame.minX, screen.postBiddingSouthSuitSelector.frame.maxX - 2, file: file, line: line)
        XCTAssertEqual(screen.postBiddingSouthSuitButton.frame.midY, screen.postBiddingSouthSuitSelector.frame.midY, accuracy: 6, file: file, line: line)
        XCTAssertLessThanOrEqual(screen.postBiddingSouthSuitButton.frame.maxY, screen.southTarneebSelection.frame.maxY + 2, file: file, line: line)
    }

    private func assertBidAreaShowsLegalValues(
        on screen: TarneebScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(screen.bidArea.exists, file: file, line: line)
        XCTAssertTrue(screen.bidTable.exists, file: file, line: line)
        for stationBid in screen.stationBids {
            XCTAssertTrue(stationBid.exists, file: file, line: line)
            do {
                try assertTokenValue(stationBid, contains: "value=", file: file, line: line)
            } catch {
                XCTFail("Station bid did not expose bid metadata: \(error)", file: file, line: line)
            }
        }

        guard let bidAreaValue = screen.bidArea.value as? String else {
            XCTFail("Bid area did not expose bid metadata", file: file, line: line)
            return
        }

        guard let allowedFragment = bidAreaValue
            .split(separator: ";")
            .first(where: { $0.hasPrefix("allowed=") }) else {
            XCTFail("Bid area metadata did not expose allowed values", file: file, line: line)
            return
        }

        let allowedValues = allowedFragment
            .dropFirst("allowed=".count)
            .split(separator: ",")
            .map(String.init)

        XCTAssertFalse(allowedValues.isEmpty, file: file, line: line)
        for allowedValue in allowedValues {
            XCTAssertTrue(Self.allowedBidLabels.contains(allowedValue), file: file, line: line)
        }

        guard let valuesFragment = bidAreaValue
            .split(separator: ";")
            .first(where: { $0.hasPrefix("values=") }) else {
            XCTFail("Bid area metadata did not expose values", file: file, line: line)
            return
        }

        let pairs = valuesFragment
            .dropFirst("values=".count)
            .split(separator: ",")
            .map(String.init)

        XCTAssertEqual(pairs.count, 4, file: file, line: line)

        for seat in ["south", "east", "north", "west"] {
            XCTAssertTrue(pairs.contains { $0.hasPrefix("\(seat):") }, file: file, line: line)
        }

        for pair in pairs {
            let components = pair.split(separator: ":")
            XCTAssertEqual(components.count, 2, file: file, line: line)
            if components.count == 2 {
                XCTAssertTrue(Self.visibleBidLabels.contains(String(components[1])), file: file, line: line)
            }
        }
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

    private func assertStationOutlineMatchesBiddingState(
        _ station: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let value = try XCTUnwrap(station.value as? String, file: file, line: line)
        if value.contains("activeTurn=true") || value.contains("bidMotionCueActive=true") {
            XCTAssertTrue(value.contains("outline=color.station.outline.active"), "\(value) does not contain active outline", file: file, line: line)
        } else {
            XCTAssertTrue(
                value.contains("outline=color.station.outline;") || value.contains("outline=color.station.outline.inactive"),
                "\(value) does not contain default or inactive outline",
                file: file,
                line: line
            )
        }
    }

    @discardableResult
    private func waitForTokenValue(
        _ element: XCUIElement,
        contains expectedValue: String,
        timeout: TimeInterval,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> String {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), file: file, line: line)

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let value = element.value as? String, value.contains(expectedValue) {
                return value
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }

        let value = try XCTUnwrap(element.value as? String, file: file, line: line)
        XCTFail("\(value) did not contain \(expectedValue)", file: file, line: line)
        return value
    }

    private func waitForAnyTokenValue(
        _ element: XCUIElement,
        containsAny expectedValues: [String],
        timeout: TimeInterval,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> String {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), file: file, line: line)

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let value = element.value as? String,
               expectedValues.contains(where: { value.contains($0) }) {
                return value
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }

        let value = try XCTUnwrap(element.value as? String, file: file, line: line)
        XCTFail("\(value) did not contain any of \(expectedValues)", file: file, line: line)
        return value
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

    private static let allowedBidLabels = ["Pass", "7", "8", "9", "10", "11", "12", "13"]
    private static let visibleBidLabels = ["--"] + allowedBidLabels

    private static let mvp007SmallestSupportedSimulator = "iPhone SE (3rd generation)"
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

    var playArea: XCUIElement {
        element(identifier: "tarneeb-play-area")
    }

    var southPlayAreaSlot: XCUIElement {
        element(identifier: "tarneeb-play-area-slot-south")
    }

    var westPlayAreaSlot: XCUIElement {
        element(identifier: "tarneeb-play-area-slot-west")
    }

    var northPlayAreaSlot: XCUIElement {
        element(identifier: "tarneeb-play-area-slot-north")
    }

    var eastPlayAreaSlot: XCUIElement {
        element(identifier: "tarneeb-play-area-slot-east")
    }

    var undealtDeckStack: XCUIElement {
        element(identifier: "tarneeb-undealt-deck-stack")
    }

    var deckStackCards: XCUIElementQuery {
        app.images.matching(identifier: "tarneeb-undealt-deck-stack-card")
    }

    var dealAnimationStack: XCUIElement {
        element(identifier: "tarneeb-deal-animation-stack")
    }

    var dealAnimationStackCards: XCUIElementQuery {
        app.images.matching(identifier: "tarneeb-deal-animation-stack-card")
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

    var gameScore: XCUIElement {
        element(identifier: "tarneeb-game-score")
    }

    var roundScoreMessage: XCUIElement {
        element(identifier: "tarneeb-round-score-message")
    }

    var gameWinnerMessage: XCUIElement {
        element(identifier: "tarneeb-game-winner-message")
    }

    var cancelGameAlert: XCUIElement {
        app.alerts["Cancel current game?"]
    }

    var keepPlayingButton: XCUIElement {
        cancelGameAlert.buttons["Keep Playing"]
    }

    var cancelGameButton: XCUIElement {
        cancelGameAlert.buttons["Cancel Game"]
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

    var dealerPills: XCUIElementQuery {
        app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "tarneeb-dealer-pill"))
    }

    var southDealerPill: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "tarneeb-dealer-pill-south").firstMatch
    }

    var bidArea: XCUIElement {
        element(identifier: "tarneeb-bid-area")
    }

    var bidLabel: XCUIElement {
        element(identifier: "tarneeb-bid-label")
    }

    var bidTable: XCUIElement {
        element(identifier: "tarneeb-bid-table")
    }

    var southStationBid: XCUIElement {
        element(identifier: "tarneeb-station-bid-south")
    }

    var eastStationBid: XCUIElement {
        element(identifier: "tarneeb-station-bid-east")
    }

    var northStationBid: XCUIElement {
        element(identifier: "tarneeb-station-bid-north")
    }

    var westStationBid: XCUIElement {
        element(identifier: "tarneeb-station-bid-west")
    }

    var stationBids: [XCUIElement] {
        [southStationBid, eastStationBid, northStationBid, westStationBid]
    }

    var southBidSelector: XCUIElement {
        element(identifier: "tarneeb-bid-selector-south")
    }

    var southTarneebSuitSelector: XCUIElement {
        element(identifier: "tarneeb-bid-suit-selector-south")
    }

    func southTarneebSuitOption(_ suit: String) -> XCUIElement {
        app.buttons.matching(identifier: "tarneeb-bid-suit-option-\(suit)").firstMatch
    }

    var southBidButton: XCUIElement {
        app.buttons.matching(identifier: "tarneeb-bid-button-south").firstMatch
    }

    var stationAreas: [XCUIElement] {
        [northSeatArea, westSeatArea, southSeatArea, eastSeatArea]
    }

    var dealerStationAreas: [XCUIElement] {
        stationAreas.filter { station in
            guard let seat = Self.seatRawValue(forStation: station),
                  let value = station.value as? String else {
                return false
            }

            return value.contains("dealerSeat=\(seat)")
        }
    }

    var nonDealerStationAreas: [XCUIElement] {
        stationAreas.filter { station in
            guard let seat = Self.seatRawValue(forStation: station),
                  let value = station.value as? String else {
                return false
            }

            return !value.contains("dealerSeat=\(seat)")
        }
    }

    private static func seatRawValue(forStation station: XCUIElement) -> String? {
        let prefix = "tarneeb-seat-area-"
        guard station.identifier.hasPrefix(prefix) else {
            return nil
        }

        return String(station.identifier.dropFirst(prefix.count))
    }

    var initialUsabilityElements: [XCUIElement] {
        [title, cardTable, undealtDeckStack, newGameButton, dealButton, northSeat, westSeat, southSeat, eastSeat]
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
            eastSeat,
            bidArea,
            bidTable,
            southStationBid,
            southBidButton
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

    var southHiddenHand: XCUIElement {
        element(identifier: "tarneeb-hidden-hand-south")
    }

    var southRevealHand: XCUIElement {
        element(identifier: "tarneeb-south-reveal-hand")
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

    var southHiddenCardBacks: XCUIElementQuery {
        app.images.matching(identifier: "tarneeb-hidden-card-back-south")
    }

    var dealCompleteMessage: XCUIElement {
        element(identifier: "tarneeb-deal-complete-message")
    }

    var biddingCompleteMessage: XCUIElement {
        app.staticTexts["Bidding complete"]
    }

    var postBiddingSummary: XCUIElement {
        element(identifier: "tarneeb-post-bidding-summary")
    }

    var southTarneebSelection: XCUIElement {
        element(identifier: "tarneeb-south-tarneeb-selection")
    }

    var postBiddingSouthSuitSelector: XCUIElement {
        element(identifier: "tarneeb-post-bidding-suit-selector-south")
    }

    var postBiddingSouthSuitButton: XCUIElement {
        app.buttons.matching(identifier: "tarneeb-post-bidding-suit-button-south").firstMatch
    }

    var prohibitedBiddingResolutionElements: [XCUIElement] {
        [
            app.buttons["Winning Bid"],
            app.buttons["Resolve Bid"],
            app.staticTexts["Winning Bid"],
            app.staticTexts["Resolve Bid"]
        ]
    }

    var prohibitedGameplayControls: [XCUIElement] {
        [
            app.buttons["Play Card"],
            app.buttons["Score"],
            app.buttons["Game Over"],
            app.segmentedControls["Trump"],
            app.segmentedControls["Tarneeb Suit"],
            app.staticTexts["Trick"]
        ]
    }

    var prohibitedOutOfScopeElements: [XCUIElement] {
        prohibitedBiddingResolutionElements + prohibitedGameplayControls + [
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
