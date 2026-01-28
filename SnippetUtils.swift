import Foundation
import AppKit

struct SnippetUtils {
    static func expandVariables(in text: String) -> String {
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

        /*
        if let clipboard = NSPasteboard.general.string(forType: .string) {
            result = result.replacingOccurrences(of: "{{clipboard}}",
                                                 with: clipboard)
        }
        */

        return result
    }
}
