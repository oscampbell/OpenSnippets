import SwiftUI
import AppKit // Import AppKit for NSPasteboard

struct MenuBarView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var store: SnippetStore // Access the shared SnippetStore
    @EnvironmentObject var appDelegate: OpenSnippetsAppController // Access the app delegate
    
    @State private var search = ""
    @State private var hoveredSnippet: Snippet? // State to manage hovered snippet for popover

    var filteredSnippets: [Snippet] {
        if search.isEmpty {
            return store.snippets
        } else {
            return store.snippets.filter {
                $0.title.localizedCaseInsensitiveContains(search) ||
                $0.content.localizedCaseInsensitiveContains(search)
            }
        }
    }

    var body: some View {
        VStack {
            TextField("Search", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding([.horizontal, .top])

            Text("Snippets will appear here")
                .foregroundColor(.gray)
                .padding()

            Button("Open Main Window") {
                appDelegate.showMainWindow() // Call the showMainWindow function
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .frame(width: 400, height: 600) // Fixed size for the popover
    }

    @Environment(\.openWindow) private var openWindow

    func copy(_ text: String) {
        let expanded = SnippetUtils.expandVariables(in: text) // Use the shared utility
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(expanded, forType: .string)
    }
}
