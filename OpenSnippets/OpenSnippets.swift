import Foundation

struct Snippet: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var content: String // This will eventually be derived from markdownContent or deprecated
    var markdownContent: String? // New property for rich text
    var language: String // New property for syntax highlighting language (e.g., "plaintext", "swift", "python")
    var createdAt: Date
    var updatedAt: Date

    init(title: String, content: String, language: String = "plaintext") { // Default to "plaintext"
        self.id = UUID()
        self.title = title
        self.content = content
        self.markdownContent = nil
        self.language = language // Initialize new property
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

//
//  OpenSnippets.swift
//  OpenSnippets
//
//  Created by Oliver Campbell on 08/01/2026.
//

