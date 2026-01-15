import SwiftUI

@main
struct SnippetsApp: App {
    @StateObject var themeSettings = ThemeSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeSettings)
        }
        .windowStyle(.titleBar)
    }
}

