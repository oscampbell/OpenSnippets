import XCTest
@testable import OpenSnippets

final class ThemeSettingsTests: XCTestCase {

    func testFontSizeConstraints() {
        let settings = ThemeSettings()
        
        // Reset to default
        settings.resetFontSize()
        XCTAssertEqual(settings.currentTheme.fontSize, 14.0)
        
        // Increase
        settings.increaseFontSize()
        XCTAssertEqual(settings.currentTheme.fontSize, 15.0)
        
        // Test Max Limit (36.0)
        settings.currentTheme.fontSize = 35.0
        settings.increaseFontSize()
        XCTAssertEqual(settings.currentTheme.fontSize, 36.0)
        settings.increaseFontSize()
        XCTAssertEqual(settings.currentTheme.fontSize, 36.0, "Should be capped at 36.0")
        
        // Test Min Limit (8.0)
        settings.currentTheme.fontSize = 9.0
        settings.decreaseFontSize()
        XCTAssertEqual(settings.currentTheme.fontSize, 8.0)
        settings.decreaseFontSize()
        XCTAssertEqual(settings.currentTheme.fontSize, 8.0, "Should be capped at 8.0")
    }
}
