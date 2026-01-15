import SwiftUI

enum AppMode: String, CaseIterable, Identifiable {
    case window = "Window App"
    case menuBar = "Menu Bar App"

    var id: String { self.rawValue }
}

@main
struct SnippetsApp: App {
    @StateObject var themeSettings = ThemeSettings()
    @AppStorage("appMode") var appMode: AppMode = .window // Re-add AppMode and @AppStorage

    var body: some Scene {
        appScenes()
    }

    @SceneBuilder
    private func appScenes() -> some Scene {
        if appMode == .window {
            WindowGroup {
                ContentView()
                    .environmentObject(themeSettings)
            }
            .windowStyle(.titleBar)
        } else {
            MenuBarExtra("OpenSnippets", systemImage: "note.text") {
                Text("Menu Bar Placeholder")
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
    }
}

