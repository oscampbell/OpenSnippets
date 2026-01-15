import Foundation

struct Snippet: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(title: String, content: String) {
        self.id = UUID()
        self.title = title
        self.content = content
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

