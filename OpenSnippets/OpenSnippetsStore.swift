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
        do {
            try FileManager.default.createDirectory(at: appDir,
                                                    withIntermediateDirectories: true)
        } catch {
            print("Error creating snippets directory: \(error.localizedDescription)")
        }
        self.fileURL = appDir.appendingPathComponent("snippets.json")
        load()
    }

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            snippets = try JSONDecoder().decode([Snippet].self, from: data)
        } catch {
            print("Error loading snippets: \(error.localizedDescription)")
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(snippets)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Error saving snippets: \(error.localizedDescription)")
        }
    }
}

//
//  OpenSnippetsStore.swift
//  OpenSnippets
//
//  Created by Oliver Campbell on 08/01/2026.
//

