import Foundation

struct CodeFormatter {
    
    static func format(_ code: String, language: String) -> String {
        switch language.lowercased() {
        case "json":
            return formatJSON(code)
        case "xml", "html":
            // Basic XML/HTML formatter could be complex; fallback to indent based on tags if possible, 
            // or just simple line separation. For now, let's try a simple XML parser if valid, or fallback.
            return formatXML(code)
        default:
            // Fallback to a basic brace-based indenter for C-style languages (Swift, JS, CSS, etc.)
            return formatBraces(code)
        }
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
