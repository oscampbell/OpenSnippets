import SwiftUI
import AppKit

struct CommandPaletteView: View {
    @EnvironmentObject var store: SnippetStore
    @Binding var isPresented: Bool
    
    @State private var query = ""
    @State private var selectedIndex = 0
    
    var filteredSnippets: [Snippet] {
        if query.isEmpty {
            return store.snippets.sorted { $0.updatedAt > $1.updatedAt }
        }
        return store.snippets.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(query) })
        }.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Type to search snippets...", text: $query)
                    .textFieldStyle(.plain)
                    .font(.title3)
                    .onSubmit {
                        selectAndClose()
                    }
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(filteredSnippets.enumerated()), id: \.element.id) { index, snippet in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(snippet.title)
                                    .font(.headline)
                                    .foregroundColor(index == selectedIndex ? .white : .primary)
                                HStack {
                                    Text(snippet.language)
                                        .font(.caption)
                                        .foregroundColor(index == selectedIndex ? .white.opacity(0.8) : .secondary)
                                    if !snippet.tags.isEmpty {
                                        Text(snippet.tags.map{ "#\($0)" }.joined(separator: " "))
                                            .font(.caption)
                                            .foregroundColor(index == selectedIndex ? .white.opacity(0.8) : .secondary)
                                    }
                                }
                            }
                            Spacer()
                            if index == selectedIndex {
                                Image(systemName: "return")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(index == selectedIndex ? Color.accentColor : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedIndex = index
                            selectAndClose()
                        }
                        .onHover { hovering in
                            if hovering {
                                selectedIndex = index
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .background(Material.ultraThin)
        .cornerRadius(12)
        .shadow(radius: 20)
        .padding(40)
        .onAppear {
            selectedIndex = 0
        }
        .onChange(of: query) { _, _ in
            selectedIndex = 0
        }
    }
    
    func selectAndClose() {
        if filteredSnippets.indices.contains(selectedIndex) {
            let snippet = filteredSnippets[selectedIndex]
            let expanded = SnippetUtils.expandVariables(in: snippet.content)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(expanded, forType: .string)
            // Ideally we also navigate to it or just close
            isPresented = false
        }
    }
}
