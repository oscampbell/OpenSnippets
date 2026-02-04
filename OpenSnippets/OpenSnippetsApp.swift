import SwiftUI
import AppKit // Required for NSApplication and NSWindow

@main
struct SnippetsApp: App {
    @NSApplicationDelegateAdaptor(OpenSnippetsAppController.self) var appDelegate
    @StateObject var themeSettings = ThemeSettings()

    var body: some Scene {
        // The main window of the application
        WindowGroup("OpenSnippets Main Window", id: "mainWindow") {
            ContentView()
                .environmentObject(themeSettings)
                .environmentObject(appDelegate.store) // Pass the store from the app delegate
                .environmentObject(appDelegate) // Inject the app delegate itself as an EnvironmentObject
                .onReceive(NotificationCenter.default.publisher(for: .openMainWindow)) { _ in
                    // When the notification is received, try to open the main window
                    openWindow(id: "mainWindow")
                    // If the window was already open, this will bring it to the front
                    // We also need to manually activate the app
                    NSApp.activate(ignoringOtherApps: true)
                }
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(after: .sidebar) {
                Divider()
                Button("Zoom In") {
                    themeSettings.increaseFontSize()
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("Zoom Out") {
                    themeSettings.decreaseFontSize()
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("Actual Size") {
                    themeSettings.resetFontSize()
                }
                .keyboardShortcut("0", modifiers: .command)
            }
            SidebarCommands() // Standard sidebar commands
        }

        // A settings scene that doesn't display any content but is needed for some app setup
        Settings {
            EmptyView()
        }
    }

    @Environment(\.openWindow) private var openWindow
}