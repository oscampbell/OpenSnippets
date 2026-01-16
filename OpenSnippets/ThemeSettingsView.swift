import SwiftUI

struct ThemedButtonStyle: ButtonStyle {
    @EnvironmentObject var themeSettings: ThemeSettings

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(LinearGradient(colors: [themeSettings.currentTheme.primaryAccentColor.color, themeSettings.currentTheme.primaryAccentColor.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .foregroundColor(themeSettings.currentTheme.buttonTextColor.color)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)
    }
}

struct PrimaryThemedButtonStyle: ButtonStyle {
    @EnvironmentObject var themeSettings: ThemeSettings

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(LinearGradient(colors: [themeSettings.currentTheme.primaryAccentColor.color, themeSettings.currentTheme.primaryAccentColor.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .foregroundColor(themeSettings.currentTheme.buttonTextColor.color)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)
    }
}

struct SecondaryThemedButtonStyle: ButtonStyle {
    @EnvironmentObject var themeSettings: ThemeSettings

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(LinearGradient(colors: [themeSettings.currentTheme.secondaryAccentColor.color, themeSettings.currentTheme.secondaryAccentColor.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .foregroundColor(themeSettings.currentTheme.buttonTextColor.color)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)
    }
}

struct ThemeSettingsView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @Environment(\.dismiss) var dismiss // For dismissing the sheet

    // Initialize @State variables with default placeholders
    @State private var selectedPrimaryAccentColor: Color = AppTheme.defaultTheme.primaryAccentColor.color
    @State private var selectedSecondaryAccentColor: Color = AppTheme.defaultTheme.secondaryAccentColor.color
    @State private var selectedSnippetListBackgroundColor: Color = AppTheme.defaultTheme.snippetListBackgroundColor.color
    @State private var selectedSnippetDetailBackgroundColor: Color = AppTheme.defaultTheme.snippetDetailBackgroundColor.color
    @State private var selectedTextColor: Color = AppTheme.defaultTheme.textColor.color
    @State private var selectedButtonTextColor: Color = AppTheme.defaultTheme.buttonTextColor.color
    @State private var selectedFontFamily: String = AppTheme.defaultTheme.fontFamily
    @State private var selectedFontSize: CGFloat = AppTheme.defaultTheme.fontSize

    @State private var selectedPresetTheme: PresetTheme? = PresetThemes.themes.first

    @State private var ignoreChanges = true // Flag to prevent initial onChange triggers

    var body: some View {
        TabView {
            // Preset Themes Tab
            Form {
                Section("Preset Theme") {
                    Picker("Select a Theme", selection: $selectedPresetTheme) {
                        ForEach(PresetThemes.themes, id: \.self) { presetTheme in
                            Text(presetTheme.name).tag(presetTheme as PresetTheme?)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedPresetTheme) { oldPreset, newPreset in
                        if let preset = newPreset {
                            applyPreset(preset)
                        }
                    }
                }
            }
            .tabItem {
                Label("Presets", systemImage: "swatchpalette")
            }

            // Custom Theme Tab
            Form {
                Section("Colors") {
                    ColorPicker("Primary Accent Color", selection: $selectedPrimaryAccentColor)
                    ColorPicker("Secondary Accent Color", selection: $selectedSecondaryAccentColor)
                    ColorPicker("Snippet List Background", selection: $selectedSnippetListBackgroundColor)
                    ColorPicker("Snippet Detail Background", selection: $selectedSnippetDetailBackgroundColor)
                    ColorPicker("Text Color", selection: $selectedTextColor)
                    ColorPicker("Button Text Color", selection: $selectedButtonTextColor)
                }

                Section("Font") {
                    Picker("Font Family", selection: $selectedFontFamily) {
                        Text("System").tag("System")
                        Text("Monospaced").tag("Monospaced")
                        Text("Serif").tag("Serif")
                        // Add more font options as desired
                    }
                    .pickerStyle(.menu)

                    Slider(value: $selectedFontSize, in: 10...20, step: 1) {
                        Text("Font Size")
                    } minimumValueLabel: {
                        Text("10")
                    } maximumValueLabel: {
                        Text("20")
                    }
                    Text("Current size: \(selectedFontSize, format: .number)")
                }

                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .buttonStyle(ThemedButtonStyle())
                .padding(.top)
            }
            .tabItem {
                Label("Custom", systemImage: "slider.horizontal.3")
            }
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 500, minHeight: 400)
        .navigationTitle("Theme Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(ThemedButtonStyle())
            }
        }
        .onAppear {
            // Set @State variables from themeSettings.currentTheme only once on appear
            selectedPrimaryAccentColor = themeSettings.currentTheme.primaryAccentColor.color
            selectedSecondaryAccentColor = themeSettings.currentTheme.secondaryAccentColor.color
            selectedSnippetListBackgroundColor = themeSettings.currentTheme.snippetListBackgroundColor.color
            selectedSnippetDetailBackgroundColor = themeSettings.currentTheme.snippetDetailBackgroundColor.color
            selectedTextColor = themeSettings.currentTheme.textColor.color
            selectedButtonTextColor = themeSettings.currentTheme.buttonTextColor.color
            selectedFontFamily = themeSettings.currentTheme.fontFamily
            selectedFontSize = themeSettings.currentTheme.fontSize
            ignoreChanges = false // Allow changes to trigger updateTheme() after initialization
        }
        // Robust onChange observers
        .onChange(of: selectedPrimaryAccentColor) { oldValue, newValue in if !ignoreChanges && oldValue != newValue { updateTheme() } }
        .onChange(of: selectedSecondaryAccentColor) { oldValue, newValue in if !ignoreChanges && oldValue != newValue { updateTheme() } }
        .onChange(of: selectedSnippetListBackgroundColor) { oldValue, newValue in if !ignoreChanges && oldValue != newValue { updateTheme() } }
        .onChange(of: selectedSnippetDetailBackgroundColor) { oldValue, newValue in if !ignoreChanges && oldValue != newValue { updateTheme() } }
        .onChange(of: selectedTextColor) { oldValue, newValue in if !ignoreChanges && oldValue != newValue { updateTheme() } }
        .onChange(of: selectedButtonTextColor) { oldValue, newValue in if !ignoreChanges && oldValue != newValue { updateTheme() } }
        .onChange(of: selectedFontFamily) { oldValue, newValue in if !ignoreChanges && oldValue != newValue { updateTheme() } }
        .onChange(of: selectedFontSize) { oldValue, newValue in if !ignoreChanges && oldValue != newValue { updateTheme() } }
    }

    private func updateTheme() {
        themeSettings.currentTheme = AppTheme(
            primaryAccentColor: CodableColor(selectedPrimaryAccentColor),
            secondaryAccentColor: CodableColor(selectedSecondaryAccentColor),
            snippetListBackgroundColor: CodableColor(selectedSnippetListBackgroundColor),
            snippetDetailBackgroundColor: CodableColor(selectedSnippetDetailBackgroundColor),
            textColor: CodableColor(selectedTextColor),
            buttonTextColor: CodableColor(selectedButtonTextColor),
            fontFamily: selectedFontFamily,
            fontSize: selectedFontSize
        )
    }

    private func resetToDefaults() {
        themeSettings.currentTheme = AppTheme.defaultTheme
        selectedPrimaryAccentColor = themeSettings.currentTheme.primaryAccentColor.color
        selectedSecondaryAccentColor = themeSettings.currentTheme.secondaryAccentColor.color
        selectedSnippetListBackgroundColor = themeSettings.currentTheme.snippetListBackgroundColor.color
        selectedSnippetDetailBackgroundColor = themeSettings.currentTheme.snippetDetailBackgroundColor.color
        selectedTextColor = themeSettings.currentTheme.textColor.color
        selectedButtonTextColor = themeSettings.currentTheme.buttonTextColor.color
        selectedFontFamily = themeSettings.currentTheme.fontFamily
        selectedFontSize = themeSettings.currentTheme.fontSize
    }

    private func applyPreset(_ preset: PresetTheme) {
        themeSettings.currentTheme = preset.theme
        selectedPrimaryAccentColor = preset.theme.primaryAccentColor.color
        selectedSecondaryAccentColor = preset.theme.secondaryAccentColor.color
        selectedSnippetListBackgroundColor = preset.theme.snippetListBackgroundColor.color
        selectedSnippetDetailBackgroundColor = preset.theme.snippetDetailBackgroundColor.color
        selectedTextColor = preset.theme.textColor.color
        selectedButtonTextColor = preset.theme.buttonTextColor.color
        selectedFontFamily = preset.theme.fontFamily
        selectedFontSize = preset.theme.fontSize
    }
}
