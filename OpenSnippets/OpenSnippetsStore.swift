import Foundation
import Combine

class SnippetStore: ObservableObject {
    @Published var snippets: [Snippet] = [] {
        didSet { save() }
    }

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory,
                                           in: .userDomainMask)[0]
        let appDir = dir.appendingPathComponent("Snippets", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir,
                                                 withIntermediateDirectories: true)
        self.fileURL = appDir.appendingPathComponent("snippets.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        snippets = (try? JSONDecoder().decode([Snippet].self, from: data)) ?? []
    }

    func save() {
        let data = try? JSONEncoder().encode(snippets)
        try? data?.write(to: fileURL)
    }
}

//
//  OpenSnippetsStore.swift
//  OpenSnippets
//
//  Created by Oliver Campbell on 08/01/2026.
//

