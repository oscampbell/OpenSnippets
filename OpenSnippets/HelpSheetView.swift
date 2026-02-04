import SwiftUI
import AppKit // Added for NSFont/NSColor

struct HelpSheetView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @Binding var showingHelp: Bool

    var body: some View {
        ZStack {
            LinearGradient(colors: [themeSettings.currentTheme.snippetDetailBackgroundColor.color.opacity(0.8), themeSettings.currentTheme.snippetDetailBackgroundColor.color], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(themeSettings.currentTheme.primaryAccentColor.color)
                            .imageScale(.large)
                        Text("OpenSnippets Help")
                            .font(themedFont(style: .largeTitle)).bold()
                            .foregroundColor(themeSettings.currentTheme.textColor.color)
                        Spacer()
                        Button { showingHelp = false } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(themeSettings.currentTheme.textColor.color.opacity(0.9))
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 8)

                    VStack(alignment: .leading, spacing: 14) {
                        Group {
                            Text("Welcome to OpenSnippets!")
                                .font(themedFont(style: .title3)).bold()
                                .foregroundColor(themeSettings.currentTheme.textColor.color)
                            Text("Create, search, and copy your most-used text quickly. Use variables to auto-fill common values.")
                                .foregroundColor(themeSettings.currentTheme.textColor.color.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Divider().background(themeSettings.currentTheme.textColor.color.opacity(0.2))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Keyboard Shortcuts & Features")
                                .font(themedFont(style: .headline))
                                .foregroundColor(themeSettings.currentTheme.textColor.color)
                            
                            Group {
                                Label("Quick Open Palette: ⇧⌘P", systemImage: "command")
                                Label("Create a new snippet: ⌘N", systemImage: "plus.circle")
                                Label("Duplicate snippet: ⌘D", systemImage: "plus.square.on.square")
                                Label("Delete selected: ⌘⌫", systemImage: "trash")
                                Label("Copy snippet: ⌘C or double-click", systemImage: "doc.on.doc")
                                Label("Zoom In/Out: ⌘+ / ⌘- (Reset: ⌘0)", systemImage: "magnifyingglass.circle")
                            }
                            
                            Divider().background(themeSettings.currentTheme.textColor.color.opacity(0.2)).padding(.vertical, 4)
                            
                            Group {
                                Label("Favorites: Click the star to pin snippets to top", systemImage: "star.fill")
                                Label("Markdown: Toggle preview with the eye icon", systemImage: "eye")
                                Label("Tags: Add #tags via the input field", systemImage: "tag")
                                Label("Gist: Import from URL in the toolbar", systemImage: "icloud.and.arrow.down")
                                Label("Menu Bar: Access all snippets from system icon", systemImage: "hammer.fill")
                            }
                        }
                        .foregroundColor(themeSettings.currentTheme.textColor.color.opacity(0.9))
                        .font(themedFont(style: .body))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Variable expansion")
                                .font(themedFont(style: .headline))
                                .foregroundColor(themeSettings.currentTheme.textColor.color)
                            VStack(alignment: .leading, spacing: 3) {
                                Label("{{date}} → current date", systemImage: "circle.fill")
                                Label("{{time}} → current time", systemImage: "circle.fill")
                                Label("{{datetime}} → date + time", systemImage: "circle.fill")
                                Label("{{clipboard}} → current clipboard text", systemImage: "circle.fill")
                            }
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(themeSettings.currentTheme.textColor.color.opacity(0.6), themeSettings.currentTheme.textColor.color)
                            .font(themedFont(style: .body, design: .monospaced))
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
                                    .background(LinearGradient(colors: [themeSettings.currentTheme.primaryAccentColor.color, themeSettings.currentTheme.primaryAccentColor.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(themeSettings.currentTheme.textColor.color)
                                    .clipShape(Capsule())
                                    .shadow(color: themeSettings.currentTheme.primaryAccentColor.color.opacity(0.4), radius: 10, x: 0, y: 6)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 6)

                        // App Version
                        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                            .font(themedFont(style: .caption))
                            .foregroundColor(themeSettings.currentTheme.textColor.color.opacity(0.5))
                            .padding(.top, 10)
                    }
                    .padding(.vertical, 14).padding(.horizontal, 18)
                    .background(themeSettings.currentTheme.snippetDetailBackgroundColor.color.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(themeSettings.currentTheme.textColor.color.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .padding(30)
            }
            .scrollIndicators(.visible)
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    private func themedNSFont(style: Font.TextStyle, design: Font.Design = .default) -> NSFont {
        let size = themeSettings.currentTheme.fontSize
        let family = themeSettings.currentTheme.fontFamily

        switch family {
        case "Monospaced":
            return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case "Serif":
            return NSFont(name: "Times New Roman", size: size) ?? NSFont.systemFont(ofSize: size, weight: .regular)
        case "System":
            return NSFont.systemFont(ofSize: size)
        default:
            return NSFont.systemFont(ofSize: size)
        }
    }

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
}
