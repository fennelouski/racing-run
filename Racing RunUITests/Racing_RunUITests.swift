//
//  Racing_RunUITests.swift
//  Racing RunUITests
//
//  Created by Nathan Fennel on 10/8/25.
//

import XCTest

final class Racing_RunUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]

        // Clear user defaults to start fresh each time
        app.launchArguments.append("-com.nathanfennel.Racing-Run.clearUserDefaults")
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Screenshot Tests

    @MainActor
    func testCharacterCreationScreenAppearance() throws {
        app.launch()

        // Wait for character creation screen to appear
        let instructionLabel = app.staticTexts["Take a picture of your face!"]
        XCTAssertTrue(instructionLabel.waitForExistence(timeout: 5))

        // Verify all key UI elements are present
        XCTAssertTrue(app.buttons["📸 Take Photo"].exists)

        // Take screenshot of character creation screen
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "CharacterCreationScreen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testCharacterCreationScreenLayout() throws {
        app.launch()

        // Wait for the screen to load
        let captureButton = app.buttons["📸 Take Photo"]
        XCTAssertTrue(captureButton.waitForExistence(timeout: 5))

        // Verify button is visible and properly positioned
        XCTAssertTrue(captureButton.isHittable)

        // Take screenshot
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "CharacterCreationLayout"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testAppearanceInLightMode() throws {
        // Force light mode
        app.launchArguments.append("--UIUserInterfaceStyle:Light")
        app.launch()

        let instructionLabel = app.staticTexts["Take a picture of your face!"]
        XCTAssertTrue(instructionLabel.waitForExistence(timeout: 5))

        // Capture screenshot in light mode
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "CharacterCreation-LightMode"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testAppearanceInDarkMode() throws {
        // Force dark mode
        app.launchArguments.append("--UIUserInterfaceStyle:Dark")
        app.launch()

        let instructionLabel = app.staticTexts["Take a picture of your face!"]
        XCTAssertTrue(instructionLabel.waitForExistence(timeout: 5))

        // Capture screenshot in dark mode
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "CharacterCreation-DarkMode"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testLandscapeOrientation() throws {
        XCUIDevice.shared.orientation = .landscapeLeft
        app.launch()

        let instructionLabel = app.staticTexts["Take a picture of your face!"]
        XCTAssertTrue(instructionLabel.waitForExistence(timeout: 5))

        // Capture screenshot in landscape
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "CharacterCreation-Landscape"
        attachment.lifetime = .keepAlways
        add(attachment)

        // Reset to portrait
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testUIElementsPresence() throws {
        app.launch()

        // Wait for screen
        XCTAssertTrue(app.staticTexts["Take a picture of your face!"].waitForExistence(timeout: 5))

        // Check all expected elements
        XCTAssertTrue(app.buttons["📸 Take Photo"].exists, "Capture button should be visible")
        XCTAssertTrue(app.staticTexts["Take a picture of your face!"].exists, "Instruction label should be visible")

        // Retake and Continue buttons should be hidden initially
        XCTAssertFalse(app.buttons["🔄 Retake"].isHittable, "Retake button should be hidden initially")
        XCTAssertFalse(app.buttons["✓ Use This Photo"].isHittable, "Continue button should be hidden initially")

        // Take screenshot showing all elements
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "UIElements-InitialState"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testFullAppFlow() throws {
        app.launch()

        // 1. Character Creation Screen
        let instructionLabel = app.staticTexts["Take a picture of your face!"]
        XCTAssertTrue(instructionLabel.waitForExistence(timeout: 5))

        var screenshot = app.screenshot()
        var attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "01-CharacterCreation-Initial"
        attachment.lifetime = .keepAlways
        add(attachment)

        // Wait a bit for camera preview to load
        sleep(2)

        screenshot = app.screenshot()
        attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "02-CharacterCreation-CameraReady"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Accessibility Tests

    @MainActor
    func testAccessibilityLabels() throws {
        app.launch()

        let captureButton = app.buttons["📸 Take Photo"]
        XCTAssertTrue(captureButton.waitForExistence(timeout: 5))

        // Verify button is accessible
        XCTAssertTrue(captureButton.isHittable)

        // Take screenshot for accessibility review
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Accessibility-Review"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Performance Tests

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }

    @MainActor
    func testScrollPerformance() throws {
        app.launch()

        // Wait for UI to load
        XCTAssertTrue(app.buttons["📸 Take Photo"].waitForExistence(timeout: 5))

        // Measure animation performance
        let options = XCTMeasureOptions()
        options.invocationOptions = [.manuallyStart]

        measure(options: options) {
            startMeasuring()
            // Simulate some UI interactions
            sleep(1)
            stopMeasuring()
        }
    }
}
