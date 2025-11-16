# Racing Run - Testing Guide

## Screenshot Tests

We've implemented comprehensive UI screenshot tests to ensure the app looks great and functions correctly across different scenarios.

### Test Coverage

The screenshot tests cover:

1. **Initial Screen Appearance**
   - Character creation screen layout
   - Button visibility and positioning
   - Label text and formatting

2. **Appearance Modes**
   - Light mode rendering
   - Dark mode rendering
   - High contrast compatibility

3. **Orientation Support**
   - Portrait orientation
   - Landscape orientation
   - Adaptive layout verification

4. **UI Element Presence**
   - All buttons are present
   - Labels display correctly
   - Hidden elements stay hidden until needed

5. **Accessibility**
   - Button accessibility labels
   - VoiceOver compatibility
   - Touch target sizes

6. **Performance**
   - Launch performance metrics
   - Animation smoothness
   - Response time measurements

### Running Screenshot Tests

To run the screenshot tests:

```bash
# Run all UI tests
xcodebuild test -scheme "Racing Run" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' -only-testing:Racing\ RunUITests

# Run a specific test
xcodebuild test -scheme "Racing Run" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' -only-testing:Racing\ RunUITests/Racing_RunUITests/testCharacterCreationScreenAppearance
```

Or use Xcode:
1. Open the project in Xcode
2. Press `Cmd+U` to run all tests
3. Or click the diamond icon next to individual tests in `Racing_RunUITests.swift`

### Viewing Screenshots

After tests run, screenshots are automatically attached to the test results:

1. Open the **Test Navigator** (Cmd+6)
2. Click on a test that completed
3. Click on the **Attachments** section
4. View the captured screenshots

Screenshots are saved with descriptive names:
- `CharacterCreationScreen` - Initial screen
- `CharacterCreation-LightMode` - Light appearance
- `CharacterCreation-DarkMode` - Dark appearance
- `CharacterCreation-Landscape` - Landscape orientation
- `UIElements-InitialState` - All UI elements
- `01-CharacterCreation-Initial` - App flow step 1
- `02-CharacterCreation-CameraReady` - App flow step 2

### Test Details

#### Screenshot Tests

- `testCharacterCreationScreenAppearance()` - Captures the initial character creation screen
- `testCharacterCreationScreenLayout()` - Verifies proper layout and positioning
- `testAppearanceInLightMode()` - Tests light mode rendering
- `testAppearanceInDarkMode()` - Tests dark mode rendering
- `testLandscapeOrientation()` - Tests landscape layout
- `testUIElementsPresence()` - Verifies all UI elements are present
- `testFullAppFlow()` - Captures screenshots of the complete flow

#### Accessibility Tests

- `testAccessibilityLabels()` - Verifies accessibility compliance

#### Performance Tests

- `testLaunchPerformance()` - Measures app launch time
- `testScrollPerformance()` - Measures UI interaction performance

### Continuous Integration

These tests can be integrated into your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Run UI Tests
  run: |
    xcodebuild test \
      -scheme "Racing Run" \
      -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1' \
      -only-testing:Racing\ RunUITests \
      -resultBundlePath TestResults.xcresult

- name: Upload Screenshots
  uses: actions/upload-artifact@v3
  with:
    name: screenshots
    path: TestResults.xcresult
```

### Troubleshooting

**Tests fail on simulator launch:**
- Make sure the specified simulator is installed
- Try resetting the simulator: `xcrun simctl erase all`

**Camera permissions not granted:**
- The tests use launch arguments to clear user defaults
- Camera UI may show permission dialogs in tests

**Screenshots not captured:**
- Ensure `attachment.lifetime = .keepAlways` is set
- Check Xcode test results for attachments

### Best Practices

1. **Run tests before commits** - Catch UI regressions early
2. **Review screenshots** - Manually inspect captured screenshots
3. **Test on multiple devices** - Run tests on different simulator sizes
4. **Update baselines** - When intentionally changing UI, update expected results

### Future Enhancements

Planned test improvements:
- Snapshot testing with baseline comparisons
- Automated visual regression testing
- Testing with actual character photos
- Testing game scene rendering
- Testing leaderboard screens
- Testing authentication flows

---

## Build Status

✅ **Build succeeds** with only deprecation warnings for iOS 26.0 APIs
✅ **Screenshot tests configured** and ready to run
✅ **No errors** in the codebase

### Fixed Issues

During setup, we fixed:
1. Info.plist conflict - Removed standalone plist file, added camera permissions to project settings
2. SKSpriteNode mask property - Updated to use SKCropNode for circular face mask
3. CGRect initialization typo - Fixed parameter labels in face extraction

All issues resolved and the project now builds successfully!
