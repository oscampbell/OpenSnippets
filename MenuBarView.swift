import SwiftUI
import AppKit // Import AppKit for NSPasteboard

struct MenuBarView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var store: SnippetStore // Access the shared SnippetStore
    @EnvironmentObject var appDelegate: OpenSnippetsAppController // Access the app delegate
    
    @State private var search = ""
    @State private var copiedID: UUID? // Track which snippet was copied for feedback

    var filteredSnippets: [Snippet] {
        let snippetsToFilter: [Snippet]
        if search.isEmpty {
            snippetsToFilter = store.snippets
        } else {
            snippetsToFilter = store.snippets.filter {
                $0.title.localizedCaseInsensitiveContains(search) ||
                $0.content.localizedCaseInsensitiveContains(search)
            }
        }
        // Sort: Favorites first, then by date
        return snippetsToFilter.sorted {
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite && !$1.isFavorite
            }
            return $0.updatedAt > $1.updatedAt
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header / Search
            VStack {
                TextField("Search snippets...", text: $search)
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }
            .background(Color(nsColor: .windowBackgroundColor))

            // Snippet List
            List(filteredSnippets) { snippet in
                HStack {
                    iconForLanguage(snippet.language)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading) {
                        Text(snippet.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(snippet.content)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if snippet.id == copiedID {
                        Text("Copied!")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.green)
                            .transition(.opacity)
                    } else if snippet.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle()) // Make the whole row clickable
                .onTapGesture {
                    copyAndClose(snippet)
                }
            }
            .listStyle(.plain)

            Divider()

            // Footer
            HStack {
                Spacer()
                Button("Open Main Window") {
                    appDelegate.showMainWindow()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                Spacer()
            }
            .padding(12)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 350, height: 500)
    }

    func copyAndClose(_ snippet: Snippet) {
        let expanded = SnippetUtils.expandVariables(in: snippet.content)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(expanded, forType: .string)
        
        withAnimation {
            copiedID = snippet.id
        }
        
        // Delay closing to show feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            copiedID = nil
            appDelegate.closePopover(nil)
        }
    }
    
    private func iconForLanguage(_ language: String) -> Image {
        switch language {
        case "swift": return Image(systemName: "swift")
        case "python": return Image(systemName: "curlybraces.square.fill")
        case "javascript": return Image(systemName: "curlybraces")
        case "html": return Image(systemName: "chevron.left.slash.chevron.right")
        case "css": return Image(systemName: "curlybraces.square")
        case "json": return Image(systemName: "doc.json")
        case "shell": return Image(systemName: "terminal")
        case "plaintext": return Image(systemName: "doc.plaintext")
        default: return Image(systemName: "doc.text")
        }
    }
}
