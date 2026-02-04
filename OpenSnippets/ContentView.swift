import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @StateObject private var store = SnippetStore()
    @State private var search = ""
    @State private var selectedIDs: Set<Snippet.ID> = []
    @State private var showingHelp = false
    @State private var showingDeleteConfirmation = false
    @State private var showingThemeSettings = false
    @State private var editingSnippetContent: String = ""
    @State private var showingCopyFeedback = false // Feedback state
    @State private var isPreviewMode = false // Preview toggle state
    @State private var showingCommandPalette = false // Command Palette state
    @State private var showingGistImport = false // Gist Import state
    @State private var gistURL = ""
    @Environment(\.undoManager) var undoManager

    var isClipboardEmpty: Bool {
        NSPasteboard.general.string(forType: .string) == nil
    }

    // Filter snippets by search and sort by favorites
    var filtered: [Snippet] {
        let snippetsToFilter: [Snippet]
        if search.isEmpty {
            snippetsToFilter = store.snippets
        } else {
            snippetsToFilter = store.snippets.filter {
                $0.title.localizedCaseInsensitiveContains(search) ||
                $0.content.localizedCaseInsensitiveContains(search)
            }
        }
        
        return snippetsToFilter.sorted {
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite && !$1.isFavorite
            }
            return $0.updatedAt > $1.updatedAt // Secondary sort by date
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

                    List(selection: $selectedIDs) {
                        ForEach(filtered) { snippet in
                            HStack {
                                iconForLanguage(snippet.language)
                                    .foregroundColor(themeSettings.currentTheme.secondaryAccentColor.color)
                                VStack(alignment: .leading) {
                                    Text(snippet.title).bold()
                                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                                    Text(snippet.content)
                                        .lineLimit(1)
                                        .foregroundColor(themeSettings.currentTheme.textColor.color.opacity(0.6))
                                    
                                    if !snippet.tags.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(snippet.tags, id: \.self) { tag in
                                                    Text("#\(tag)")
                                                        .font(.caption2)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(themeSettings.currentTheme.secondaryAccentColor.color.opacity(0.2))
                                                        .foregroundColor(themeSettings.currentTheme.secondaryAccentColor.color)
                                                        .cornerRadius(4)
                                                }
                                            }
                                        }
                                        .frame(height: 20)
                                    }
                                }
                                Spacer()
                                if snippet.isFavorite {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }
                            }
                            .onTapGesture(count: 2) {
                                copy(snippet.content)
                            }
                            .tag(snippet.id)
                            .contextMenu {
                                Button {
                                    selectedIDs = [snippet.id]
                                    duplicateSnippet()
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                
                                Divider()
                                
                                Button(role: .destructive) {
                                    selectedIDs = [snippet.id]
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Divider()
                                
                                Button {
                                    exportAsImage(snippet: snippet)
                                } label: {
                                    Label("Share as Image", systemImage: "photo")
                                }
                            }
                        }
                        // Note: onMove logic needs adjustment if we are sorting.
                        // Standard list reordering conflicts with auto-sorting.
                        // We will disable manual reordering when sorting logic is active or handle it carefully.
                        // For now, let's keep it but be aware it might jump back.
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                    .background(themeSettings.currentTheme.snippetListBackgroundColor.color)
                    .accentColor(themeSettings.currentTheme.primaryAccentColor.color) // selection highlight
                    .onChange(of: selectedIDs) { oldSelection, newSelection in
                        if let newID = newSelection.first,
                           let index = store.snippets.firstIndex(where: { $0.id == newID }) {
                            editingSnippetContent = store.snippets[index].content
                        }
                    }
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
                            HStack {
                                TextField("Title", text: $store.snippets[index].title)
                                    .font(themedFont(style: .title2)) // Use themed font
                                    .textFieldStyle(.plain)
                                    .foregroundColor(themeSettings.currentTheme.textColor.color)
                                    .tint(themeSettings.currentTheme.secondaryAccentColor.color)
                                
                                Spacer()
                                
                                Button {
                                    toggleFavorite(for: store.snippets[index])
                                } label: {
                                    Image(systemName: store.snippets[index].isFavorite ? "star.fill" : "star")
                                        .foregroundColor(store.snippets[index].isFavorite ? .yellow : themeSettings.currentTheme.textColor.color.opacity(0.5))
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                                .help("Toggle Favorite")
                                
                                Button {
                                    withAnimation {
                                        isPreviewMode.toggle()
                                    }
                                } label: {
                                    Image(systemName: isPreviewMode ? "eye.slash" : "eye")
                                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                                .help(isPreviewMode ? "Edit Mode" : "Preview Markdown")
                                
                                Button {
                                    let originalContent = editingSnippetContent
                                    
                                    // Register Undo
                                    undoManager?.registerUndo(withTarget: store) { _ in
                                        if let undoIndex = store.snippets.firstIndex(where: { $0.id == firstSelectedID }) {
                                            store.snippets[undoIndex].content = originalContent
                                            // We also need to update the local editing state if we are currently editing this snippet
                                            if selectedIDs.contains(firstSelectedID) {
                                                editingSnippetContent = originalContent
                                            }
                                        }
                                    }
                                    
                                    editingSnippetContent = CodeFormatter.format(editingSnippetContent, language: store.snippets[index].language)
                                    // Trigger update to store
                                    store.snippets[index].content = editingSnippetContent
                                } label: {
                                    Image(systemName: "wand.and.stars")
                                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                                .help("Format Code")
                            }

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

                            // Tags Input
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(themeSettings.currentTheme.secondaryAccentColor.color)
                                TextField("Tags (comma separated)", text: Binding(
                                    get: {
                                        store.snippets[index].tags.joined(separator: ", ")
                                    },
                                    set: { newValue in
                                        store.snippets[index].tags = newValue
                                            .split(separator: ",")
                                            .map { $0.trimmingCharacters(in: .whitespaces) }
                                            .filter { !$0.isEmpty }
                                    }
                                ))
                                .textFieldStyle(.plain)
                                .foregroundColor(themeSettings.currentTheme.textColor.color)
                            }
                            .padding(.vertical, 4)

                            if isPreviewMode {
                                ScrollView {
                                    Text(LocalizedStringKey(editingSnippetContent))
                                        .font(themedFont(style: .body))
                                        .foregroundColor(themeSettings.currentTheme.textColor.color)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }
                                .background(themeSettings.currentTheme.snippetDetailBackgroundColor.color.opacity(0.6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(themeSettings.currentTheme.secondaryAccentColor.color, lineWidth: 1)
                                )
                            } else {
                                SpellCheckingTextEditor(
                                    text: $editingSnippetContent,
                                    language: $store.snippets[index].language, // Passed language binding
                                    font: themedNSFont(style: .body, design: .monospaced),
                                    foregroundColor: NSColor(themeSettings.currentTheme.textColor.color),
                                    tintColor: NSColor(themeSettings.currentTheme.secondaryAccentColor.color)
                                )
                                .onChange(of: editingSnippetContent) { oldValue, newValue in
                                    store.snippets[index].content = newValue
                                }
                                .background(themeSettings.currentTheme.snippetDetailBackgroundColor.color.opacity(0.6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(themeSettings.currentTheme.secondaryAccentColor.color, lineWidth: 1)
                                )
                            }

                            HStack {
                                Button {
                                    copy(store.snippets[index].content)
                                } label: {
                                    HStack {
                                        Image(systemName: showingCopyFeedback ? "checkmark" : "doc.on.doc")
                                        Text(showingCopyFeedback ? "Copied!" : "Copy")
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(LinearGradient(colors: [themeSettings.currentTheme.primaryAccentColor.color, themeSettings.currentTheme.primaryAccentColor.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(themeSettings.currentTheme.buttonTextColor.color)
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain) // Apply plain style
                                .keyboardShortcut("c", modifiers: [.command])

                                Button {
                                    paste()
                                } label: {
                                    Label("Paste", systemImage: "clipboard")
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(LinearGradient(colors: [themeSettings.currentTheme.secondaryAccentColor.color, themeSettings.currentTheme.secondaryAccentColor.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .foregroundColor(themeSettings.currentTheme.buttonTextColor.color)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain) // Apply plain style
                                .keyboardShortcut("v", modifiers: [.command])
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
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: newSnippet) {
                    Label("New", systemImage: "plus")
                }
                .buttonStyle(PrimaryThemedButtonStyle())
                .keyboardShortcut("n", modifiers: [.command])

                Button(action: duplicateSnippet) {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                .buttonStyle(SecondaryThemedButtonStyle())
                .disabled(selectedIDs.count != 1)
                .keyboardShortcut("d", modifiers: [.command])

                Button(action: { showingDeleteConfirmation = true }) {
                    Label("Delete", systemImage: "trash")
                }
                .buttonStyle(SecondaryThemedButtonStyle())
                .disabled(selectedIDs.isEmpty)
                .keyboardShortcut(.delete, modifiers: [.command])
            }

            ToolbarItemGroup(placement: .secondaryAction) {
                Button(action: importSnippets) {
                    Label("Import JSON", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(SecondaryThemedButtonStyle())
                
                Button(action: { showingGistImport = true }) {
                    Label("Import Gist", systemImage: "icloud.and.arrow.down")
                }
                .buttonStyle(SecondaryThemedButtonStyle())

                Button(action: exportSnippets) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(SecondaryThemedButtonStyle())

                Button { showingThemeSettings = true } label: { // Theme Settings Button
                    Label("Theme", systemImage: "paintbrush")
                }
                .buttonStyle(PrimaryThemedButtonStyle())

                Button { showingHelp = true } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
                .buttonStyle(SecondaryThemedButtonStyle())
                
                Button { showingCommandPalette.toggle() } label: {
                    Label("Quick Open", systemImage: "command")
                }
                .buttonStyle(SecondaryThemedButtonStyle())
                .keyboardShortcut("p", modifiers: [.command, .shift])
            }
        }
        .sheet(isPresented: $showingHelp) {
            HelpSheetView(showingHelp: $showingHelp)
        }
        .sheet(isPresented: $showingThemeSettings) { // Sheet for Theme Settings
            ThemeSettingsView()
        }
        .overlay {
            if showingCommandPalette {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingCommandPalette = false
                    }
                
                CommandPaletteView(isPresented: $showingCommandPalette)
                    .environmentObject(store)
                    .frame(width: 500)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .alert("Import from GitHub Gist", isPresented: $showingGistImport) {
            TextField("Gist URL", text: $gistURL)
            Button("Import") {
                importGist(from: gistURL)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the full URL of a public GitHub Gist.")
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

    func exportSnippets() {
        print("Export snippets button clicked")
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "OpenSnippets.json"

        if savePanel.runModal() == .OK {
            print("File selected")
            if let url = savePanel.url {
                print("URL: \(url)")
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let data = try encoder.encode(store.snippets)
                    try data.write(to: url)
                    print("Snippets exported successfully")
                } catch {
                    print("Error exporting snippets: \(error.localizedDescription)")
                }
            }
        }
    }

    func importSnippets() {
        print("Import snippets button clicked")
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false

        if openPanel.runModal() == .OK {
            print("File selected")
            if let url = openPanel.url {
                print("URL: \(url)")
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let snippets = try decoder.decode([Snippet].self, from: data)
                    print("Decoded \(snippets.count) snippets")

                    for snippet in snippets {
                        if !store.snippets.contains(where: { $0.id == snippet.id }) {
                            store.snippets.append(snippet)
                            print("Imported snippet: \(snippet.title)")
                        } else {
                            print("Skipped duplicate snippet: \(snippet.title)")
                        }
                    }
                } catch {
                    print("Error importing snippets: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func importGist(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let lastPathComponent = url.lastPathComponent
        let gistID = lastPathComponent // simplistic extraction
        
        guard !gistID.isEmpty else { return }
        
        let apiURL = URL(string: "https://api.github.com/gists/\(gistID)")!
        
        URLSession.shared.dataTask(with: apiURL) { data, response, error in
            if let data = data {
                do {
                    // Quick and dirty JSON parsing for Gist structure
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let files = json["files"] as? [String: Any] {
                        
                        DispatchQueue.main.async {
                            for (filename, fileData) in files {
                                if let fileInfo = fileData as? [String: Any],
                                   let content = fileInfo["content"] as? String {
                                    
                                    let language = (fileInfo["language"] as? String)?.lowercased() ?? "plaintext"
                                    let snippet = Snippet(title: filename, content: content, language: language)
                                    store.snippets.insert(snippet, at: 0)
                                }
                            }
                        }
                    }
                } catch {
                    print("Error parsing Gist: \(error)")
                }
            }
        }.resume()
    }

    func exportAsImage(snippet: Snippet) {
        let cardView = SnippetCardView(snippet: snippet, theme: themeSettings.currentTheme)
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 2.0 // High res
        
        if let nsImage = renderer.nsImage {
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.png]
            savePanel.nameFieldStringValue = "\(snippet.title).png"
            
            if savePanel.runModal() == .OK, let url = savePanel.url {
                if let tiffData = nsImage.tiffRepresentation,
                   let bitmapImage = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                    try? pngData.write(to: url)
                }
            }
        }
    }

    func newSnippet() {
        let snippet = Snippet(title: "New Snippet", content: "")
        store.snippets.insert(snippet, at: 0)
        selectedIDs = [snippet.id]
    }

    func duplicateSnippet() {
        guard let id = selectedIDs.first,
              let index = store.snippets.firstIndex(where: { $0.id == id }) else { return }
        
        let original = store.snippets[index]
        var copy = Snippet(title: "\(original.title) Copy", content: original.content, language: original.language)
        copy.markdownContent = original.markdownContent
        copy.isFavorite = original.isFavorite
        
        store.snippets.insert(copy, at: index + 1)
        selectedIDs = [copy.id]
    }
    
    func toggleFavorite(for snippet: Snippet) {
        if let index = store.snippets.firstIndex(where: { $0.id == snippet.id }) {
            store.snippets[index].isFavorite.toggle()
        }
    }

    func performDeleteSnippet() {
        store.snippets.removeAll { selectedIDs.contains($0.id) }
        selectedIDs = []
    }

    func copy(_ text: String) {
        let expanded = SnippetUtils.expandVariables(in: text)

        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(expanded, forType: .string)
        
        // Show feedback
        withAnimation {
            showingCopyFeedback = true
        }
        
        // Hide feedback after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingCopyFeedback = false
            }
        }
    }

    func paste() {
        NotificationCenter.default.post(name: .pasteInTextView, object: nil)
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

    private func iconForLanguage(_ language: String) -> Image {
        switch language {
        case "swift":
            return Image(systemName: "swift")
        case "python":
            return Image(systemName: "curlybraces.square.fill") // Using filled curly braces for distinction
        case "javascript":
            return Image(systemName: "curlybraces") // Good representation for JS
        case "html":
            return Image(systemName: "chevron.left.slash.chevron.right") // Represents tags
        case "css":
            return Image(systemName: "curlybraces.square") // Unfilled version of curly braces
        case "json":
            return Image(systemName: "doc.json") // Specific SF Symbol for JSON
        case "shell":
            return Image(systemName: "terminal") // Specific SF Symbol for terminal/shell
        case "plaintext":
            return Image(systemName: "doc.plaintext") // Specific SF Symbol for plain text
        default:
            return Image(systemName: "doc.text") // Generic document icon
        }
    }
}

