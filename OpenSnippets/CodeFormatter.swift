import Foundation

struct CodeFormatter {
    
    static func format(_ code: String, language: String) -> String {
        switch language.lowercased() {
        case "json":
            return formatJSON(code)
        case "xml", "html":
            return formatXML(code)
        case "python":
            return formatPython(code)
        case "shell", "bash", "sh":
            return formatShell(code)
        default:
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
            return code
        }
    }
    
    private static func formatPython(_ code: String) -> String {
        var formatted = ""
        let lines = code.components(separatedBy: .newlines)
        
        for line in lines {
            // Trim trailing whitespace
            var processedLine = line
            while processedLine.hasSuffix(" ") {
                processedLine = String(processedLine.dropLast())
            }
            formatted += processedLine + "\n"
        }
        
        return formatted.trimmingCharacters(in: .newlines)
    }
    
    // MARK: - C-Style Formatter (Swift, JS, CSS)
    
    private static func formatBraces(_ code: String) -> String {
        // Step 1: "Explode" the code (add newlines) safely
        let exploded = explodeCStyle(code)
        
        // Step 2: Indent
        var formatted = ""
        var indentLevel = 0
        let indentStr = "    "
        
        let lines = exploded.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        for line in lines {
            if line.hasPrefix("}") || line.hasPrefix("]") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            let indentation = String(repeating: indentStr, count: indentLevel)
            formatted += indentation + line + "\n"
            
            if line.hasSuffix("{") || line.hasSuffix("[") {
                indentLevel += 1
            }
        }
        
        return formatted.trimmingCharacters(in: .newlines)
    }
    
    // Tokenizer-based exploder to safely insert newlines
    private static func explodeCStyle(_ code: String) -> String {
        var result = ""
        var inString = false
        var stringChar: Character? = nil
        var escaped = false
        
        for char in code {
            if inString {
                result.append(char)
                if escaped {
                    escaped = false
                } else if char == "\\" {
                    escaped = true
                } else if char == stringChar {
                    inString = false
                    stringChar = nil
                }
            } else {
                if char == "\"" || char == "'" {
                    inString = true
                    stringChar = char
                    result.append(char)
                } else if char == "{" {
                    result.append(" {\n")
                } else if char == "}" {
                    result.append("\n}\n")
                } else if char == ";" {
                    result.append(";\n")
                } else {
                    result.append(char)
                }
            }
        }
        return result
    }
    
    // MARK: - HTML/XML Formatter
    
    private static func formatXML(_ code: String) -> String {
        // Simple XML/HTML exploder
        // Adds newline before < and after >
        let exploded = code.replacingOccurrences(of: ">", with: ">\n")
                           .replacingOccurrences(of: "<", with: "\n<")
        
        var formatted = ""
        var indentLevel = 0
        let indentStr = "    "
        
        let lines = exploded.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        for line in lines {
            if line.hasPrefix("</") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            let indentation = String(repeating: indentStr, count: indentLevel)
            formatted += indentation + line + "\n"
            
            if line.hasPrefix("<") && !line.hasPrefix("</") && !line.hasSuffix("/>") && !line.hasPrefix("<!") && !line.hasPrefix("<?") {
                // Check if it's not a void tag (HTML specific, imprecise but better than nothing)
                let voidTags = ["<area", "<base", "<br", "<col", "<embed", "<hr", "<img", "<input", "<link", "<meta", "<param", "<source", "<track", "<wbr"]
                let isVoid = voidTags.contains { line.hasPrefix($0) }
                
                if !isVoid {
                    indentLevel += 1
                }
            }
        }
        
        return formatted.trimmingCharacters(in: .newlines)
    }
    
    // MARK: - Shell Formatter
    
    private static func formatShell(_ code: String) -> String {
        // Simple split on common separators
        // Add newlines around key structural elements to ensure they are on their own lines or start lines
        let exploded = code.replacingOccurrences(of: ";", with: ";\n")
                           .replacingOccurrences(of: "&&", with: " &&\n")
                           .replacingOccurrences(of: "||", with: " ||\n")
                           .replacingOccurrences(of: "{", with: " {\n")
                           .replacingOccurrences(of: "}", with: "\n}\n")
                           .replacingOccurrences(of: " then", with: "\nthen\n") // Ensure 'then' breaks line
                           .replacingOccurrences(of: "; then", with: ";\nthen\n") // explicit common case
                           .replacingOccurrences(of: " do", with: "\ndo\n") // Ensure 'do' breaks line
                           .replacingOccurrences(of: "; do", with: ";\ndo\n")
        
        var formatted = ""
        var indentLevel = 0
        let indentStr = "    "
        
        let lines = exploded.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        for line in lines {
            var currentIndentChange = 0
            
            // Closing keywords
            if line.hasPrefix("fi") || line.hasPrefix("done") || line.hasPrefix("esac") || line.hasPrefix("}") || line.hasPrefix("]") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            // Middle keywords
            if line.hasPrefix("else") || line.hasPrefix("elif") {
                let indentation = String(repeating: indentStr, count: max(0, indentLevel - 1))
                formatted += indentation + line + "\n"
            } else {
                let indentation = String(repeating: indentStr, count: indentLevel)
                formatted += indentation + line + "\n"
            }
            
            // Opening keywords
            if line.hasPrefix("then") || line.hasSuffix(" then") ||
               line.hasPrefix("do") || line.hasSuffix(" do") ||
               line.hasSuffix("{") || line.hasSuffix("(") {
                currentIndentChange += 1
            }
            if line.hasPrefix("case ") && line.hasSuffix(" in") {
                currentIndentChange += 1
            }
            
            indentLevel += currentIndentChange
        }
        
        return formatted.trimmingCharacters(in: .newlines)
    }
}
