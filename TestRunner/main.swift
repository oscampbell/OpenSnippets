import Foundation

print("Running manual tests for CodeFormatter...")

let swiftInput = "func hello(){print(\"Hello\");if(true){return}}"
let swiftFormatted = CodeFormatter.format(swiftInput, language: "swift")
print("\n--- Swift Input ---")
print(swiftInput)
print("--- Swift Output ---")
print(swiftFormatted)

if swiftFormatted.contains("\n") && swiftFormatted.contains("    print") {
    print("PASS: Swift format added newlines and indentation.")
} else {
    print("FAIL: Swift format did not add newlines or indentation.")
    exit(1)
}

let htmlInput = "<html><body><div><p>Text</p></div></body></html>"
let htmlFormatted = CodeFormatter.format(htmlInput, language: "html")
print("\n--- HTML Input ---")
print(htmlInput)
print("--- HTML Output ---")
print(htmlFormatted)

if htmlFormatted.contains("\n") && htmlFormatted.contains("    <p>") {
    print("PASS: HTML format added newlines and indentation.")
} else {
    print("FAIL: HTML format did not add newlines or indentation.")
    exit(1)
}

let shellInput = "if [ -f file ]; then echo 'found'; fi"
let shellFormatted = CodeFormatter.format(shellInput, language: "shell")
print("\n--- Shell Input ---")
print(shellInput)
print("--- Shell Output ---")
print(shellFormatted)

if shellFormatted.contains("\n") && shellFormatted.contains("    echo") {
    print("PASS: Shell format added newlines and indentation.")
} else {
    print("FAIL: Shell format did not add newlines or indentation.")
    exit(1)
}

print("\nAll tests passed!")
