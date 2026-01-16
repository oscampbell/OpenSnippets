import SwiftUI
import AppKit

struct SpellCheckingTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var language: String
    var font: NSFont?
    var foregroundColor: NSColor?
    var tintColor: NSColor?
    var isEditable: Bool = true

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        context.coordinator.textView = textView

        textView.delegate = context.coordinator
        textView.isRichText = true // Must be true for attributed strings
        textView.isContinuousSpellCheckingEnabled = true
        textView.textContainerInset = NSSize(width: 5, height: 5) // Add some padding

        if let font = font {
            textView.font = font
        }
        // Set default text color, which will be overridden by highlighting
        if let foregroundColor = foregroundColor {
            textView.textColor = foregroundColor
        }
        textView.isEditable = isEditable
        textView.allowsUndo = true

        // Set tint color (selection and insertion point)
        if let tintColor = tintColor {
            textView.insertionPointColor = tintColor
        }
        
        // Set the initial text and apply highlighting
        textView.string = text
        context.coordinator.parent = self // Ensure parent is set for initial highlighting
        applySyntaxHighlighting(to: textView, language: language)

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        
        // Update text if different, then re-apply highlighting
        if textView.string != text {
            let selectedRange = textView.selectedRange // Preserve selection
            textView.string = text
            textView.setSelectedRange(selectedRange)
        }

        if textView.font != font {
            textView.font = font
        }
        // No need to update textColor here, as it's handled by applySyntaxHighlighting

        if textView.insertionPointColor != tintColor {
            textView.insertionPointColor = tintColor ?? .white
        }
        textView.isEditable = isEditable
        
        // Re-apply highlighting on updates
        applySyntaxHighlighting(to: textView, language: language)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SpellCheckingTextEditor
        var textView: NSTextView?

        init(_ parent: SpellCheckingTextEditor) {
            self.parent = parent
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(paste), name: .pasteInTextView, object: nil)
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            // Re-apply highlighting on text changes
            parent.applySyntaxHighlighting(to: textView, language: parent.language)
        }

        @objc func paste() {
            guard let textView = textView else { return }
            if let clipboardContent = NSPasteboard.general.string(forType: .string) {
                textView.insertText(clipboardContent, replacementRange: textView.selectedRange())
                parent.text = textView.string // Explicitly update the binding after paste
            }
        }
    }
    
    // MARK: - Syntax Highlighting Logic
    private func applySyntaxHighlighting(to textView: NSTextView, language: String) {
        guard let textStorage = textView.textStorage else { return }

        // Remove existing highlighting by resetting to default font and color
        let wholeRange = NSRange(location: 0, length: textStorage.length)
        let defaultColor = self.foregroundColor ?? .labelColor
        let defaultFont = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)

        textStorage.beginEditing()
        textStorage.setAttributes([.foregroundColor: defaultColor, .font: defaultFont], range: wholeRange)
        
        let boldFont = NSFont.boldSystemFont(ofSize: self.font?.pointSize ?? NSFont.systemFontSize)
        
        switch language.lowercased() {
        case "swift":
            let keywords = ["func", "var", "let", "struct", "class", "import", "return", "if", "else", "for", "in", "while", "guard", "switch", "case", "break", "continue", "fallthrough", "default", "public", "private", "internal", "fileprivate", "open", "static"]
            for keyword in keywords {
                highlightMatches(for: keyword, in: textStorage, color: .systemOrange, font: boldFont)
            }
            highlightMatches(for: "//.*", in: textStorage, color: .systemGray, font: self.font, isRegex: true) // Single-line comments
            highlightMatches(for: "/\\*.*?\\*/", in: textStorage, color: .systemGray, font: self.font, isRegex: true) // Multi-line comments
            highlightMatches(for: "\".*?\"", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Strings
            highlightMatches(for: "'.*?'", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Characters (if Swift had them like this)
        case "python":
            let keywords = ["import", "from", "def", "class", "if", "else", "elif", "for", "in", "while", "return", "break", "continue", "try", "except", "finally", "with", "as", "pass", "lambda", "yield", "and", "or", "not", "is", "None", "True", "False"]
            for keyword in keywords {
                highlightMatches(for: keyword, in: textStorage, color: .systemTeal, font: boldFont)
            }
            highlightMatches(for: "#.*", in: textStorage, color: .systemGray, font: self.font, isRegex: true) // Comments
            highlightMatches(for: "\".*?\"", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Double-quoted strings
            highlightMatches(for: "'.*?'", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Single-quoted strings
        case "javascript":
            let keywords = ["function", "var", "let", "const", "if", "else", "for", "in", "of", "while", "return", "break", "continue", "switch", "case", "default", "try", "catch", "finally", "import", "export", "class", "extends", "super", "this", "new", "true", "false", "null", "undefined", "async", "await"]
            for keyword in keywords {
                highlightMatches(for: keyword, in: textStorage, color: .systemPurple, font: boldFont)
            }
            highlightMatches(for: "//.*", in: textStorage, color: .systemGray, font: self.font, isRegex: true) // Single-line comments
            highlightMatches(for: "/\\*.*?\\*/", in: textStorage, color: .systemGray, font: self.font, isRegex: true) // Multi-line comments
            highlightMatches(for: "\".*?\"", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Double-quoted strings
            highlightMatches(for: "'.*?'", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Single-quoted strings
            highlightMatches(for: "`.*?`", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Template literals
        case "html":
            highlightMatches(for: "<[/]?[a-zA-Z][^>]*>", in: textStorage, color: .systemBlue, font: boldFont, isRegex: true) // Tags
            highlightMatches(for: "&[^;]+;", in: textStorage, color: .systemGreen, font: self.font, isRegex: true) // Entities
            highlightMatches(for: "\".*?\"", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Attribute values
            highlightMatches(for: "'.*?'", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Attribute values
            highlightMatches(for: "<!--.*?-->", in: textStorage, color: .systemGray, font: self.font, isRegex: true) // Comments
        case "css":
            highlightMatches(for: "@[a-z]+", in: textStorage, color: .systemCyan, font: boldFont, isRegex: true) // @rules
            highlightMatches(for: "[a-zA-Z-]+:", in: textStorage, color: .systemBlue, font: boldFont, isRegex: true) // Properties
            highlightMatches(for: "\".*?\"", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // String values
            highlightMatches(for: "'.*?'", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // String values
            highlightMatches(for: "#[0-9a-fA-F]{3,8}\\b", in: textStorage, color: .systemBrown, font: self.font, isRegex: true) // Hex colors
            highlightMatches(for: "/\\*.*?\\*/", in: textStorage, color: .systemGray, font: self.font, isRegex: true) // Comments
        case "json":
            highlightMatches(for: "\".*?\"\\s*:", in: textStorage, color: .systemMint, font: boldFont, isRegex: true) // Keys
            highlightMatches(for: "\".*?\"", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // String values
            highlightMatches(for: "\\b(true|false|null)\\b", in: textStorage, color: .systemPurple, font: boldFont, isRegex: true) // Booleans and null
            highlightMatches(for: "\\b-?\\d+(\\.\\d+)?([eE][+-]?\\d+)?\\b", in: textStorage, color: .systemTeal, font: self.font, isRegex: true) // Numbers
        case "shell":
            let keywords = ["if", "then", "else", "fi", "for", "in", "do", "done", "while", "until", "export", "local", "function", "return", "echo", "pwd", "ls", "cd", "grep", "awk", "sed", "cut", "cat"]
            for keyword in keywords {
                highlightMatches(for: "\\b\(keyword)\\b", in: textStorage, color: .systemPink, font: boldFont, isRegex: true)
            }
            highlightMatches(for: "#.*", in: textStorage, color: .systemGray, font: self.font, isRegex: true) // Comments
            highlightMatches(for: "\".*?\"", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Double-quoted strings
            highlightMatches(for: "'.*?'", in: textStorage, color: .systemRed, font: self.font, isRegex: true) // Single-quoted strings
        default:
            // Default to plain text color (already set above)
            break
        }
        
        textStorage.endEditing()
    }

    private func highlightMatches(for pattern: String, in textStorage: NSTextStorage, color: NSColor, font: NSFont?, isRegex: Bool = false) {
        do {
            let regex: NSRegularExpression
            if isRegex {
                regex = try NSRegularExpression(pattern: pattern, options: [])
            } else {
                // Ensure whole word matching for non-regex patterns
                regex = try NSRegularExpression(pattern: "\\b" + NSRegularExpression.escapedPattern(for: pattern) + "\\b", options: [])
            }

            let matches = regex.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
            for match in matches {
                textStorage.addAttribute(.foregroundColor, value: color, range: match.range)
                if let f = font {
                    textStorage.addAttribute(.font, value: f, range: match.range)
                }
            }
        } catch {
            print("Regex error for pattern '\(pattern)': \(error)")
        }
    }
}
