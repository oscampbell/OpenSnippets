import SwiftUI

struct PresetTheme: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let theme: AppTheme
}

struct PresetThemes {
    static let themes: [PresetTheme] = [
        PresetTheme(name: "Default", theme: AppTheme.defaultTheme),
        PresetTheme(name: "Cyberpunk", theme: AppTheme(
            primaryAccentColor: CodableColor(Color.yellow),
            secondaryAccentColor: CodableColor(Color.cyan),
            snippetListBackgroundColor: CodableColor(Color.black.opacity(0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.1, green: 0.1, blue: 0.12)),
            textColor: CodableColor(Color.yellow),
            buttonTextColor: CodableColor(Color.black),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Lambda", theme: AppTheme(
            primaryAccentColor: CodableColor(Color.orange),
            secondaryAccentColor: CodableColor(Color.white),
            snippetListBackgroundColor: CodableColor(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.1, green: 0.1, blue: 0.1)),
            textColor: CodableColor(Color.white),
            buttonTextColor: CodableColor(Color.black),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Ocean", theme: AppTheme(
            primaryAccentColor: CodableColor(Color.blue),
            secondaryAccentColor: CodableColor(Color.green),
            snippetListBackgroundColor: CodableColor(Color(red: 0.1, green: 0.2, blue: 0.3, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.05, green: 0.1, blue: 0.15)),
            textColor: CodableColor(Color.white),
            buttonTextColor: CodableColor(Color.white),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Forest", theme: AppTheme(
            primaryAccentColor: CodableColor(Color.green),
            secondaryAccentColor: CodableColor(Color.brown),
            snippetListBackgroundColor: CodableColor(Color(red: 0.1, green: 0.3, blue: 0.1, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.05, green: 0.15, blue: 0.05)),
            textColor: CodableColor(Color.white),
            buttonTextColor: CodableColor(Color.black),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Homebrew", theme: AppTheme(
            primaryAccentColor: CodableColor(Color.green),
            secondaryAccentColor: CodableColor(Color.white),
            snippetListBackgroundColor: CodableColor(Color.black.opacity(0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.05, green: 0.05, blue: 0.05)),
            textColor: CodableColor(Color.green),
            buttonTextColor: CodableColor(Color.black),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Solarized", theme: AppTheme(
            primaryAccentColor: CodableColor(Color(red: 0.149, green: 0.545, blue: 0.824)),
            secondaryAccentColor: CodableColor(Color(red: 0.824, green: 0.149, blue: 0.235)),
            snippetListBackgroundColor: CodableColor(Color(red: 0.004, green: 0.188, blue: 0.243, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.027, green: 0.235, blue: 0.294)),
            textColor: CodableColor(Color(red: 0.514, green: 0.58, blue: 0.584)),
            buttonTextColor: CodableColor(Color.white),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Dracula", theme: AppTheme(
            primaryAccentColor: CodableColor(Color(red: 0.98, green: 0.47, blue: 0.83)),
            secondaryAccentColor: CodableColor(Color(red: 0.31, green: 0.89, blue: 0.76)),
            snippetListBackgroundColor: CodableColor(Color(red: 0.16, green: 0.17, blue: 0.23, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.2, green: 0.21, blue: 0.27)),
            textColor: CodableColor(Color(red: 0.95, green: 0.95, blue: 0.96)),
            buttonTextColor: CodableColor(Color.black),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Nord", theme: AppTheme(
            primaryAccentColor: CodableColor(Color(red: 0.529, green: 0.808, blue: 0.922)),
            secondaryAccentColor: CodableColor(Color(red: 0.91, green: 0.56, blue: 0.61)),
            snippetListBackgroundColor: CodableColor(Color(red: 0.18, green: 0.2, blue: 0.25, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.23, green: 0.25, blue: 0.31)),
            textColor: CodableColor(Color(red: 0.91, green: 0.92, blue: 0.94)),
            buttonTextColor: CodableColor(Color.black),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Gruvbox", theme: AppTheme(
            primaryAccentColor: CodableColor(Color(red: 0.99, green: 0.5, blue: 0.04)),
            secondaryAccentColor: CodableColor(Color(red: 0.69, green: 0.73, blue: 0.03)),
            snippetListBackgroundColor: CodableColor(Color(red: 0.16, green: 0.16, blue: 0.16, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.2, green: 0.2, blue: 0.2)),
            textColor: CodableColor(Color(red: 0.92, green: 0.85, blue: 0.72)),
            buttonTextColor: CodableColor(Color.black),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Monokai", theme: AppTheme(
            primaryAccentColor: CodableColor(Color(red: 0.99, green: 0.54, blue: 0.0)),
            secondaryAccentColor: CodableColor(Color(red: 0.42, green: 0.8, blue: 0.0)),
            snippetListBackgroundColor: CodableColor(Color(red: 0.15, green: 0.16, blue: 0.13, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.19, green: 0.2, blue: 0.17)),
            textColor: CodableColor(Color(red: 0.93, green: 0.93, blue: 0.88)),
            buttonTextColor: CodableColor(Color.black),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Tokyo Night", theme: AppTheme(
            primaryAccentColor: CodableColor(Color(red: 0.47, green: 0.6, blue: 0.98)),
            secondaryAccentColor: CodableColor(Color(red: 0.6, green: 0.78, blue: 0.45)),
            snippetListBackgroundColor: CodableColor(Color(red: 0.1, green: 0.1, blue: 0.15, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.13, green: 0.13, blue: 0.19)),
            textColor: CodableColor(Color(red: 0.8, green: 0.8, blue: 0.9)),
            buttonTextColor: CodableColor(Color.white),
            fontFamily: "Monospaced",
            fontSize: 14.0
        )),
        PresetTheme(name: "Material", theme: AppTheme(
            primaryAccentColor: CodableColor(Color(red: 0.51, green: 0.6, blue: 1.0)),
            secondaryAccentColor: CodableColor(Color(red: 0.91, green: 0.49, blue: 0.57)),
            snippetListBackgroundColor: CodableColor(Color(red: 0.16, green: 0.2, blue: 0.25, opacity: 0.95)),
            snippetDetailBackgroundColor: CodableColor(Color(red: 0.2, green: 0.24, blue: 0.29)),
            textColor: CodableColor(Color(red: 0.94, green: 0.95, blue: 0.96)),
            buttonTextColor: CodableColor(Color.black),
            fontFamily: "Monospaced",
            fontSize: 14.0
        ))
    ]
}
