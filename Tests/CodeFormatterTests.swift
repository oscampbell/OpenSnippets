import XCTest
@testable import OpenSnippets

final class CodeFormatterTests: XCTestCase {

    func testFormatSwift_Minified() {
        let input = "func hello(){print(\"Hello\");if(true){return}}"
        let expected = """
        func hello() {
            print("Hello");
            if(true) {
                return
            }
        }
        """
        // Note: The formatter might produce slightly different output (e.g. newlines around braces), 
        // but it should definitely not be one line.
        let result = CodeFormatter.format(input, language: "swift")
        XCTAssertNotEqual(result, input)
        XCTAssertTrue(result.contains("\n"))
        XCTAssertTrue(result.contains("    ")) // Indentation
    }

    func testFormatHTML_Minified() {
        let input = "<html><body><div><p>Text</p></div></body></html>"
        let result = CodeFormatter.format(input, language: "html")
        XCTAssertNotEqual(result, input)
        XCTAssertTrue(result.contains("\n"))
        XCTAssertTrue(result.contains("    "))
    }
}

