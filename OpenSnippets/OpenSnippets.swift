import Foundation

struct Snippet: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var content: String // This will eventually be derived from markdownContent or deprecated
    var markdownContent: String? // New property for rich text
    var language: String // New property for syntax highlighting language (e.g., "plaintext", "swift", "python")
    var isFavorite: Bool // New property for pinning/favoriting
    var tags: [String] // New property for organization
    var createdAt: Date
    var updatedAt: Date

    init(title: String, content: String, language: String = "plaintext") { // Default to "plaintext"
        self.id = UUID()
        self.title = title
        self.content = content
        self.markdownContent = nil
        self.language = language // Initialize new property
        self.isFavorite = false
        self.tags = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Codable Implementation for Backward Compatibility

    enum CodingKeys: String, CodingKey {
        case id, title, content, markdownContent, language, isFavorite, tags, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        markdownContent = try container.decodeIfPresent(String.self, forKey: .markdownContent)
        language = try container.decode(String.self, forKey: .language)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(markdownContent, forKey: .markdownContent)
        try container.encode(language, forKey: .language)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(tags, forKey: .tags)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}


//
//  OpenSnippets.swift
//  OpenSnippets
//
//  Created by Oliver Campbell on 08/01/2026.
//

