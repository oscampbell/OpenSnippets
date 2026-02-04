import XCTest
@testable import OpenSnippets

final class SnippetModelTests: XCTestCase {

    func testSnippetDecodingWithMissingIsFavorite() throws {
        // JSON representing a snippet from a previous version (missing "isFavorite")
        let json = """
        {
            "id": "A1B2C3D4-E5F6-7890-1234-567890ABCDEF",
            "title": "Old Snippet",
            "content": "print('Hello')",
            "language": "python",
            "createdAt": 728820000.0,
            "updatedAt": 728820000.0
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970 // Assuming standard Double for Date if not ISO8601
        // Note: The app uses default encoding for Date which is float (timeIntervalSinceReferenceDate) by default for JSONEncoder?
        // Let's check how default JSONEncoder/Decoder handles dates. By default it is deferredToDate (Double).
        
        let snippet = try decoder.decode(Snippet.self, from: json)
        
        XCTAssertEqual(snippet.title, "Old Snippet")
        XCTAssertFalse(snippet.isFavorite, "isFavorite should default to false if missing")
    }
    
    func testSnippetEncodingAndDecoding() throws {
        var snippet = Snippet(title: "New Snippet", content: "let x = 1", language: "swift")
        snippet.isFavorite = true
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(snippet)
        
        let decoder = JSONDecoder()
        let decodedSnippet = try decoder.decode(Snippet.self, from: data)
        
        XCTAssertEqual(decodedSnippet.id, snippet.id)
        XCTAssertTrue(decodedSnippet.isFavorite)
        XCTAssertEqual(decodedSnippet.title, snippet.title)
    }
}
