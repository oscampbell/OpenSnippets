import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @Environment(\.dismiss) var dismiss // For dismissing the sheet

    // Initialize @State variables with default placeholders
    @State private var selectedPrimaryAccentColor: Color = AppTheme.defaultTheme.primaryAccentColor.color
    @State private var selectedSecondaryAccentColor: Color = AppTheme.defaultTheme.secondaryAccentColor.color
    @State private var selectedSnippetListBackgroundColor: Color = AppTheme.defaultTheme.snippetListBackgroundColor.color
    @State private var selectedSnippetDetailBackgroundColor: Color = AppTheme.defaultTheme.snippetDetailBackgroundColor.color
    @State private var selectedTextColor: Color = AppTheme.defaultTheme.textColor.color
    @State private var selectedFontFamily: String = AppTheme.defaultTheme.fontFamily
    @State private var selectedFontSize: CGFloat = AppTheme.defaultTheme.fontSize

    @State private var ignoreChanges = true // Flag to prevent initial onChange triggers

    var body: some View {
        Form {
            Section("Colors") {
                ColorPicker("Primary Accent Color", selection: $selectedPrimaryAccentColor)
                ColorPicker("Secondary Accent Color", selection: $selectedSecondaryAccentColor)
                ColorPicker("Snippet List Background", selection: $selectedSnippetListBackgroundColor)
                ColorPicker("Snippet Detail Background", selection: $selectedSnippetDetailBackgroundColor)
                ColorPicker("Text Color", selection: $selectedTextColor)
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
            .buttonStyle(.borderedProminent)
            .padding(.top)

            Spacer()
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 500, minHeight: 400)
        .navigationTitle("Theme Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            // Set @State variables from themeSettings.currentTheme only once on appear
            selectedPrimaryAccentColor = themeSettings.currentTheme.primaryAccentColor.color
            selectedSecondaryAccentColor = themeSettings.currentTheme.secondaryAccentColor.color
            selectedSnippetListBackgroundColor = themeSettings.currentTheme.snippetListBackgroundColor.color
            selectedSnippetDetailBackgroundColor = themeSettings.currentTheme.snippetDetailBackgroundColor.color
            selectedTextColor = themeSettings.currentTheme.textColor.color
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
        selectedFontFamily = themeSettings.currentTheme.fontFamily
        selectedFontSize = themeSettings.currentTheme.fontSize
    }
}
