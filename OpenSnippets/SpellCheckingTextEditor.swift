import SwiftUI
import AppKit

struct SpellCheckingTextEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont?
    var foregroundColor: NSColor?
    var tintColor: NSColor?
    var isEditable: Bool = true

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.isContinuousSpellCheckingEnabled = true
        textView.usesAutomaticDataDetection = false
        textView.usesAutomaticQuoteSubstitution = false
        textView.usesAutomaticDashSubstitution = false
        textView.usesAutomaticTextReplacement = false
        textView.textContainerInset = NSSize(width: 5, height: 5) // Add some padding

        if let font = font {
            textView.font = font
        }
        if let foregroundColor = foregroundColor {
            textView.textColor = foregroundColor
        }
        textView.isEditable = isEditable
        textView.allowsUndo = true

        // Set tint color (selection and insertion point)
        if let tintColor = tintColor {
            textView.insertionPointColor = tintColor
        }

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
        }
        if textView.font != font {
            textView.font = font
        }
        if textView.textColor != foregroundColor {
            textView.textColor = foregroundColor
        }
        if textView.insertionPointColor != tintColor {
            textView.insertionPointColor = tintColor
        }
        textView.isEditable = isEditable
        // Ensure continuous spell checking remains enabled
        if !textView.isContinuousSpellCheckingEnabled {
            textView.isContinuousSpellCheckingEnabled = true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SpellCheckingTextEditor

        init(_ parent: SpellCheckingTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}
