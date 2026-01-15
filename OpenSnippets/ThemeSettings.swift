import SwiftUI
import Combine

// MARK: - Theme Struct
struct AppTheme: Codable, Equatable, Hashable {
    var primaryAccentColor: CodableColor
    var secondaryAccentColor: CodableColor
    var snippetListBackgroundColor: CodableColor
    var snippetDetailBackgroundColor: CodableColor
    var textColor: CodableColor
    var fontFamily: String
    var fontSize: CGFloat

    static let defaultTheme = AppTheme(
        primaryAccentColor: CodableColor(Color.cyan),
        secondaryAccentColor: CodableColor(Color.mint),
        snippetListBackgroundColor: CodableColor(Color.black.opacity(0.95)),
        snippetDetailBackgroundColor: CodableColor(Color(red: 0.10, green: 0.10, blue: 0.12)),
        textColor: CodableColor(Color.white),
        fontFamily: "Monospaced", // Default monospaced font
        fontSize: 14.0
    )
}

// MARK: - CodableColor (Helper for encoding/decoding Color)
struct CodableColor: Codable, Equatable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(_ color: Color) {
        if let components = NSColor(color).cgColor.components {
            if components.count >= 3 {
                self.red = Double(components[0])
                self.green = Double(components[1])
                self.blue = Double(components[2])
            } else { // Handle grayscale
                self.red = Double(components[0])
                self.green = Double(components[0])
                self.blue = Double(components[0])
            }
            self.alpha = Double(NSColor(color).alphaComponent)
        } else {
            // Fallback for unexpected color components
            self.red = 0
            self.green = 0
            self.blue = 0
            self.alpha = 1
        }
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - ThemeSettings Class
class ThemeSettings: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            if let encoded = try? JSONEncoder().encode(currentTheme) {
                UserDefaults.standard.set(encoded, forKey: "appTheme")
            }
        }
    }

    init() {
        if let savedThemeData = UserDefaults.standard.data(forKey: "appTheme"),
           let decodedTheme = try? JSONDecoder().decode(AppTheme.self, from: savedThemeData) {
            self.currentTheme = decodedTheme
        } else {
            self.currentTheme = AppTheme.defaultTheme
        }
    }
}
