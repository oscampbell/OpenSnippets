import Foundation

struct CodeFormatter {
    
    static func format(_ code: String, language: String) -> String {
        switch language.lowercased() {
        case "json":
            return formatJSON(code)
        case "xml", "html":
            return formatXML(code)
        case "python":
            // Python relies on indentation, so we cannot safely re-indent flattened code without a full parser.
            // We will perform safe cleanup: trim trailing whitespace and ensure consistent line endings.
            return formatPython(code)
        case "shell", "bash", "sh":
            return formatShell(code)
        default:
            // Fallback to a basic brace-based indenter for C-style languages (Swift, JS, CSS, etc.)
            return formatBraces(code)
        }
    }
    
    private static func formatPython(_ code: String) -> String {
        var formatted = ""
        let lines = code.components(separatedBy: .newlines)
        
        for line in lines {
            // Trim trailing whitespace only
            var processedLine = line
            while processedLine.hasSuffix(" ") {
                processedLine = String(processedLine.dropLast())
            }
            formatted += processedLine + "\n"
        }
        
        return formatted.trimmingCharacters(in: .newlines)
    }
    
    private static func formatShell(_ code: String) -> String {
        var formatted = ""
        var indentLevel = 0
        let indentStr = "    " // 4 spaces
        
        // Split by lines, trim whitespace
        let lines = code.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        for line in lines {
            var currentIndentChange = 0
            
            // Check for closing keywords at start of line
            if line.hasPrefix("fi") || line.hasPrefix("done") || line.hasPrefix("esac") || line.hasPrefix("}") || line.hasPrefix("]") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            // Check for middle-keywords that dedent then indent (elif, else)
            if line.hasPrefix("else") || line.hasPrefix("elif") {
                // Temporarily reduce indent for this line only
                let indentation = String(repeating: indentStr, count: max(0, indentLevel - 1))
                formatted += indentation + line + "\n"
            } else {
                let indentation = String(repeating: indentStr, count: indentLevel)
                formatted += indentation + line + "\n"
            }
            
            // Check for opening keywords
            // Basic heuristics for bash
            if line.hasSuffix(" then") || line == "then" ||
               line.hasSuffix(" do") || line == "do" ||
               line.hasSuffix("{") || line.hasSuffix("(") {
                currentIndentChange += 1
            }
            // Case statement structure is tricky, ignoring for simple heuristic or treating 'case' as indent
            if line.hasPrefix("case ") && line.hasSuffix(" in") {
                currentIndentChange += 1
            }
            
            indentLevel += currentIndentChange
        }
        
        return formatted.trimmingCharacters(in: .newlines)
    }
    
    private static func formatJSON(_ code: String) -> String {
        guard let data = code.data(using: .utf8) else { return code }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            return String(data: prettyData, encoding: .utf8) ?? code
        } catch {
            return code // Return original if invalid JSON
        }
    }
    
    // Very basic brace-based indenter
    private static func formatBraces(_ code: String) -> String {
        var formatted = ""
        var indentLevel = 0
        let indentStr = "    " // 4 spaces
        
        // Split by lines, trim whitespace
        let lines = code.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        for line in lines {
            // Decrease indent if line starts with } or ]
            if line.hasPrefix("}") || line.hasPrefix("]") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            let indentation = String(repeating: indentStr, count: indentLevel)
            formatted += indentation + line + "\n"
            
            // Increase indent if line ends with { or [
            if line.hasSuffix("{") || line.hasSuffix("[") {
                indentLevel += 1
            }
        }
        
        return formatted.trimmingCharacters(in: .newlines)
    }
    
    private static func formatXML(_ code: String) -> String {
        // A very naive XML/HTML indenter
        var formatted = ""
        var indentLevel = 0
        let indentStr = "    "
        
        // Regex to find tags
        // This is a simplistic approach and won't handle all edge cases (like script tags, etc.)
        let pattern = "(<[^>]+>|[^<]+)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return code }
        let nsString = code as NSString
        let results = regex.matches(in: code, range: NSRange(location: 0, length: nsString.length))
        
        for result in results {
            let token = nsString.substring(with: result.range).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !token.isEmpty else { continue }
            
            if token.hasPrefix("</") {
                // Closing tag
                indentLevel = max(0, indentLevel - 1)
            }
            
            let indentation = String(repeating: indentStr, count: indentLevel)
            formatted += indentation + token + "\n"
            
            if token.hasPrefix("<") && !token.hasPrefix("</") && !token.hasSuffix("/>") && !token.hasPrefix("<!") && !token.hasPrefix("<?") {
                // Opening tag (that isn't self-closing, comment, or doctype)
                // Also ignore void tags in HTML if we were being strict, but this is generic.
                indentLevel += 1
            }
        }
        
        return formatted.trimmingCharacters(in: .newlines)
    }
}
