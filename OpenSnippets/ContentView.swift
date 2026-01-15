import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var store = SnippetStore()
    @State private var search = ""
    @State private var selectedID: Snippet.ID?
    @State private var showingHelp = false

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
                Color.black.opacity(0.95) // dark background for left pane
                VStack {
                    TextField("Search", text: $search)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.white)
                        .tint(.cyan)
                        .padding()

                    List(filtered, selection: $selectedID) { snippet in
                        VStack(alignment: .leading) {
                            Text(snippet.title).bold()
                                .foregroundColor(.white)
                            Text(snippet.content)
                                .lineLimit(1)
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) {
                            copy(snippet.content)
                        }
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                    .background(Color.black.opacity(0.95))
                    .accentColor(.cyan) // selection highlight
                }
            }
            .frame(minWidth: 250)
            .layoutPriority(0)

            // MARK: - RIGHT PANE (Editor / Placeholder)
            ZStack {
                Color(red: 0.10, green: 0.10, blue: 0.12) // dark background for right pane
                Group {
                    if let id = selectedID,
                       let index = store.snippets.firstIndex(where: { $0.id == id }) {

                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Title", text: $store.snippets[index].title)
                                .font(.title2)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .tint(.mint)

                            TextEditor(text: $store.snippets[index].content)
                                .font(.system(.body, design: .monospaced))
                                .scrollContentBackground(.hidden)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .tint(.mint)

                            HStack {
                                Button {
                                    copy(store.snippets[index].content)
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .foregroundColor(.black)
                                        .clipShape(Capsule())
                                }
                                .keyboardShortcut("c", modifiers: [.command])
                                .buttonStyle(.plain)

                                Spacer()

                                Text("Updated \(store.snippets[index].updatedAt.formatted())")
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(8)

                    } else {
                        VStack {
                            Text("Select or create a snippet")
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(minWidth: 400)
            .layoutPriority(1)
        }
        .frame(minWidth: 700, minHeight: 400)
        .accentColor(.mint) // global accent color
        .toolbar {
            ToolbarItemGroup {
                Button(action: newSnippet) {
                    Label("New", systemImage: "plus")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
                .keyboardShortcut("n", modifiers: [.command])

                Button(action: deleteSnippet) {
                    Label("Delete", systemImage: "trash")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(selectedID == nil)
                .keyboardShortcut(.delete, modifiers: [.command])

                Button { showingHelp = true } label: {
                    Label("Help", systemImage: "questionmark.circle")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .sheet(isPresented: $showingHelp) {
            HelpSheetView(showingHelp: $showingHelp)
        }
    }

    // MARK: - Actions

    func newSnippet() {
        let snippet = Snippet(title: "New Snippet", content: "")
        store.snippets.insert(snippet, at: 0)
        selectedID = snippet.id
    }

    func deleteSnippet() {
        guard let id = selectedID else { return }
        store.snippets.removeAll { $0.id == id }
        selectedID = nil
    }

    func copy(_ text: String) {
        let expanded = expandVariables(in: text)

        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(expanded, forType: .string)
    }

    // MARK: - Variable Expansion
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

private struct HelpSheetView: View {
    @Binding var showingHelp: Bool
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.08, green: 0.08, blue: 0.10), Color(red: 0.06, green: 0.06, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.yellow)
                            .imageScale(.large)
                        Text("OpenSnippets Help")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        Spacer()
                        Button { showingHelp = false } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white.opacity(0.9))
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 8)

                    VStack(alignment: .leading, spacing: 14) {
                        Group {
                            Text("Welcome to OpenSnippets!")
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            Text("Create, search, and copy your most-used text quickly. Use variables to auto-fill common values.")
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Divider().background(Color.white.opacity(0.2))

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Create a new snippet: ⌘N", systemImage: "plus.circle")
                            Label("Delete selected snippet: ⌘⌫", systemImage: "trash")
                            Label("Copy snippet: ⌘C or double-click", systemImage: "doc.on.doc")
                            Label("Search snippets: type in the search box", systemImage: "magnifyingglass")
                        }
                        .foregroundColor(.white.opacity(0.9))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Variable expansion")
                                .font(.headline)
                                .foregroundColor(.white)
                            VStack(alignment: .leading, spacing: 3) {
                                Label("{{date}} → current date", systemImage: "circle.fill")
                                Label("{{time}} → current time", systemImage: "circle.fill")
                                Label("{{datetime}} → date + time", systemImage: "circle.fill")
                                Label("{{clipboard}} → current clipboard text", systemImage: "circle.fill")
                            }
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white.opacity(0.6), Color.white)
                            .font(.system(.body, design: .monospaced))
                        }
                        .padding(.top, 6)

                        HStack {
                            Spacer()
                            Button {
                                showingHelp = false
                            } label: {
                                Text("Got it")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(.black)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.cyan.opacity(0.4), radius: 10, x: 0, y: 6)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 6)
                    }
                    .padding(.vertical, 14).padding(.horizontal, 18)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .scrollBounceBehavior(.basedOnSize)
                .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                .frame(minWidth: 660, idealWidth: 800, maxWidth: .infinity, minHeight: 450, idealHeight: 500, maxHeight: .infinity)
            }
            .scrollIndicators(.automatic)
        }
        .presentationSizing(.fitted)
    }
}

