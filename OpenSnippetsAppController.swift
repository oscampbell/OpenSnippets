import SwiftUI
import AppKit
import Combine

class OpenSnippetsAppController: NSObject, NSApplicationDelegate, ObservableObject {

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    @Published var showingPopover = false
    @StateObject var store = SnippetStore() // Initialize SnippetStore here

    // This closure will be set by the App struct to allow opening windows
    var openMainWindowClosure: (() -> Void)?

    override init() {
        super.init()
        setupMenuBar()
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "hammer.fill", accessibilityDescription: nil) // More visible placeholder icon
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 600) // Initial size, can be adjusted
        popover.behavior = .transient // Dismisses automatically when clicking outside
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: MenuBarView()
                                                                .environmentObject(ThemeSettings()) // Provide theme settings
                                                                .environmentObject(store) // Provide the shared snippet store
                                                                .environmentObject(self)) // Provide the app delegate itself
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if showingPopover {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            showingPopover = true
        }
    }

    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        showingPopover = false
    }
    
    // Function to show/open the main application window
    func showMainWindow() {
        if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "mainWindow" }) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true) // Bring the app to the front
        } else {
            // No window found, so post a notification to open a new one via the App struct
            NotificationCenter.default.post(name: .openMainWindow, object: nil)
        }
        closePopover(nil) // Always close the popover when opening the main window
    }

    // NSApplicationDelegate method (optional for menu bar apps, but good for lifecycle management)
    func applicationDidFinishLaunching(_ notification: Notification) {
        // This is where you would typically perform setup tasks when the app launches
        // For menu bar apps, the NSStatusItem setup handles the primary launch behavior.
    }
}

extension OpenSnippetsAppController: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        showingPopover = false
    }
}
