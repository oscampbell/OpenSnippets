import XCTest
@testable import OpenSnippets

final class SnippetUtilsTests: XCTestCase {

    func testExpandVariables_DateAndTime() {
        let template = "Start: {{date}} End: {{time}}"
        let result = SnippetUtils.expandVariables(in: template)

        XCTAssertFalse(result.contains("{{date}}"))
        XCTAssertFalse(result.contains("{{time}}"))
        // Further validation would require mocking Date or regex matching
    }

    func testExpandVariables_Clipboard() {
        // Prepare clipboard
        let pb = NSPasteboard.general
        pb.clearContents()
        let expectedContent = "TestContent_\(UUID().uuidString)"
        pb.setString(expectedContent, forType: .string)

        let template = "Paste: {{clipboard}}"
        let result = SnippetUtils.expandVariables(in: template)

        XCTAssertEqual(result, "Paste: \(expectedContent)")
    }
}
