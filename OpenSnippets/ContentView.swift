import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @StateObject private var store = SnippetStore()
    @State private var search = ""
    @State private var selectedIDs: Set<Snippet.ID> = []
    @State private var showingHelp = false
    @State private var showingDeleteConfirmation = false
    @State private var showingThemeSettings = false

    var isClipboardEmpty: Bool {
        NSPasteboard.general.string(forType: .string) == nil
    }

    // Filter snippets by search
    var filtered: [Snippet] {
        if search.isEmpty { return store.snippets }
        return store.snippets.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            $0.content.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        HSplitView {

            // MARK: - LEFT PANE (Snippet List)
            ZStack {
                themeSettings.currentTheme.snippetListBackgroundColor.color // dark background for left pane
                VStack {
                    TextField("Search", text: $search)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                        .tint(themeSettings.currentTheme.primaryAccentColor.color)
                        .padding()

                    List(filtered, selection: $selectedIDs) { snippet in
                        VStack(alignment: .leading) {
                            Text(snippet.title).bold()
                                .foregroundColor(themeSettings.currentTheme.textColor.color)
                            Text(snippet.content)
                                .lineLimit(1)
                                .foregroundColor(themeSettings.currentTheme.textColor.color.opacity(0.6))
                        }
                        // .contentShape(Rectangle()) // Removed to fix selection bug
                        .onTapGesture(count: 2) {
                            copy(snippet.content)
                        }
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                    .background(themeSettings.currentTheme.snippetListBackgroundColor.color)
                    .accentColor(themeSettings.currentTheme.primaryAccentColor.color) // selection highlight
                }
            }
            .frame(minWidth: 250)
            .layoutPriority(0)

            // MARK: - RIGHT PANE (Editor / Placeholder)
            ZStack {
                themeSettings.currentTheme.snippetDetailBackgroundColor.color // dark background for right pane
                Group {
                    if let firstSelectedID = selectedIDs.first, // Get the first selected ID
                       let index = store.snippets.firstIndex(where: { $0.id == firstSelectedID }) {

                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Title", text: $store.snippets[index].title)
                                .font(themedFont(style: .title2)) // Use themed font
                                .textFieldStyle(.plain)
                                .foregroundColor(themeSettings.currentTheme.textColor.color)
                                .tint(themeSettings.currentTheme.secondaryAccentColor.color)

                            Picker("Language", selection: $store.snippets[index].language) {
                                Text("Plain Text").tag("plaintext")
                                Text("Swift").tag("swift")
                                Text("Python").tag("python")
                                Text("JavaScript").tag("javascript")
                                Text("HTML").tag("html")
                                Text("CSS").tag("css")
                                Text("JSON").tag("json")
                                Text("Bash/Shell").tag("shell") // Added Bash/Shell
                                // Add more languages as needed
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(themeSettings.currentTheme.textColor.color)
                            .tint(themeSettings.currentTheme.secondaryAccentColor.color)
                            .padding(.horizontal, -4) // Adjust padding to align with TextField

                            SpellCheckingTextEditor(
                                text: $store.snippets[index].content,
                                language: $store.snippets[index].language, // Passed language binding
                                font: themedNSFont(style: .body, design: .monospaced),
                                foregroundColor: NSColor(themeSettings.currentTheme.textColor.color),
                                tintColor: NSColor(themeSettings.currentTheme.secondaryAccentColor.color)
                            )
                            .background(themeSettings.currentTheme.snippetDetailBackgroundColor.color.opacity(0.6))

                            HStack {
                                Button {
                                    copy(store.snippets[index].content)
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(LinearGradient(colors: [themeSettings.currentTheme.primaryAccentColor.color, themeSettings.currentTheme.primaryAccentColor.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                                        .clipShape(Capsule())
                                }
                                .keyboardShortcut("c", modifiers: [.command])
                                .buttonStyle(.plain)

                                Button {
                                    paste(into: &store.snippets[index].content)
                                } label: {
                                    Label("Paste", systemImage: "clipboard")
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(LinearGradient(colors: [themeSettings.currentTheme.secondaryAccentColor.color, themeSettings.currentTheme.secondaryAccentColor.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                                        .clipShape(Capsule())
                                }
                                .keyboardShortcut("v", modifiers: [.command])
                                .buttonStyle(.plain)
                                .disabled(isClipboardEmpty)

                                Spacer()

                                Text("Updated \(store.snippets[index].updatedAt.formatted())")
                                    .font(themedFont(style: .caption))
                                    .foregroundColor(themeSettings.currentTheme.textColor.color.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(8)

                    } else if selectedIDs.count > 1 { // Display a message for multiple selections
                        VStack {
                            Text("\(selectedIDs.count) snippets selected")
                                .foregroundColor(themeSettings.currentTheme.textColor.color.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else { // No selection
                        VStack {
                            Text("Select or create a snippet")
                                .foregroundColor(themeSettings.currentTheme.textColor.color.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(minWidth: 400)
            .layoutPriority(1)
        }
        .frame(minWidth: 700, minHeight: 400)
        .accentColor(themeSettings.currentTheme.primaryAccentColor.color) // global accent color
        .toolbar {
            ToolbarItemGroup {
                Button(action: newSnippet) {
                    Label("New", systemImage: "plus")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(LinearGradient(colors: [themeSettings.currentTheme.primaryAccentColor.color.opacity(0.8), themeSettings.currentTheme.primaryAccentColor.color], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                        .clipShape(Capsule())
                }
                .keyboardShortcut("n", modifiers: [.command])

                Button(action: { showingDeleteConfirmation = true }) {
                    Label("Delete", systemImage: "trash")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                                                                .background(LinearGradient(colors: [themeSettings.currentTheme.primaryAccentColor.color.opacity(0.8), themeSettings.currentTheme.primaryAccentColor.color], startPoint: .topLeading, endPoint: .bottomTrailing))                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                        .clipShape(Capsule())
                }
                .disabled(selectedIDs.isEmpty)
                .keyboardShortcut(.delete, modifiers: [.command])

                Button { showingHelp = true } label: {
                    Label("Help", systemImage: "questionmark.circle")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(LinearGradient(colors: [themeSettings.currentTheme.secondaryAccentColor.color.opacity(0.8), themeSettings.currentTheme.secondaryAccentColor.color], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                        .clipShape(Capsule())
                }

                Button { showingThemeSettings = true } label: { // Theme Settings Button
                    Label("Theme", systemImage: "paintbrush")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(LinearGradient(colors: [themeSettings.currentTheme.secondaryAccentColor.color.opacity(0.8), themeSettings.currentTheme.secondaryAccentColor.color], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                        .clipShape(Capsule())
                }
            }
        }
        .sheet(isPresented: $showingHelp) {
            HelpSheetView(showingHelp: $showingHelp)
        }
        .sheet(isPresented: $showingThemeSettings) { // Sheet for Theme Settings
            ThemeSettingsView()
        }
        .alert("Delete Snippet", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                performDeleteSnippet()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this snippet? This action cannot be undone.")
        }
    }

    // MARK: - Actions

    func newSnippet() {
        let snippet = Snippet(title: "New Snippet", content: "")
        store.snippets.insert(snippet, at: 0)
        selectedIDs = [snippet.id]
    }

    func performDeleteSnippet() {
        store.snippets.removeAll { selectedIDs.contains($0.id) }
        selectedIDs = []
    }

    func copy(_ text: String) {
        let expanded = expandVariables(in: text)

        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(expanded, forType: .string)
    }

    func paste(into text: inout String) {
        if let clipboardContent = NSPasteboard.general.string(forType: .string) {
            text.append(clipboardContent)
        }
    }

    // MARK: - Variable Expansion
    // Only for AppKit-based views.
    private func themedNSFont(style: Font.TextStyle, design: Font.Design = .default) -> NSFont {
        let size = themeSettings.currentTheme.fontSize
        let family = themeSettings.currentTheme.fontFamily

        switch family {
        case "Monospaced":
            return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case "Serif":
            return NSFont(name: "Times New Roman", size: size) ?? NSFont.systemFont(ofSize: size, weight: .regular)
        case "System":
            return NSFont.systemFont(ofSize: size) // Basic system font
        default:
            return NSFont.systemFont(ofSize: size) // Fallback
        }
    }

    // For SwiftUI views
    private func themedFont(style: Font.TextStyle, design: Font.Design = .default) -> Font {
        let size = themeSettings.currentTheme.fontSize
        let family = themeSettings.currentTheme.fontFamily

        switch family {
        case "Monospaced":
            return .system(size: size, weight: .regular, design: .monospaced)
        case "Serif":
            return .system(size: size, weight: .regular, design: .serif)
        case "System":
            return .system(size: size, weight: .regular, design: .default)
        default:
            return .system(size: size, weight: .regular, design: design)
        }
    }
    func expandVariables(in text: String) -> String {
        var result = text

        let now = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short

        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateStyle = .short
        dateTimeFormatter.timeStyle = .short

        result = result.replacingOccurrences(of: "{{date}}",
                                             with: dateFormatter.string(from: now))
        result = result.replacingOccurrences(of: "{{time}}",
                                             with: timeFormatter.string(from: now))
        result = result.replacingOccurrences(of: "{{datetime}}",
                                             with: dateTimeFormatter.string(from: now))

        if let clipboard = NSPasteboard.general.string(forType: .string) {
            result = result.replacingOccurrences(of: "{{clipboard}}",
                                                 with: clipboard)
        }

        return result
    }
}
