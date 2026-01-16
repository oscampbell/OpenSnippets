# OpenSnippets

A macOS application for storing and managing code snippets.

## Features

- **Snippet Management**: Create, edit, and delete code snippets.
- **Import/Export Functionality**: Easily export all your snippets to a single JSON file for backup or sharing. You can also import snippets from a previously exported JSON file. The JSON format is human-readable.
- **Syntax Highlighting**: Powered by [Highlightr](https://github.com/raspu/Highlightr), which is a Swift wrapper for [highlight.js](https://highlightjs.org/).
- **Customizable Themes**:
    - Choose from a list of preset themes.
    - Customize the theme to your liking with color pickers and font settings.
- **Dynamic Variable Expansion**: Use placeholders like `{{date}}`, `{{time}}`, `{{datetime}}`, and `{{clipboard}}` in your snippets.
- **Clipboard Integration**: Copy snippets to the clipboard and paste from the clipboard into your snippets.
- **Local Storage**: Snippets are saved locally to a JSON file.
- **Spell Checking**: The editor includes a spell checker.

## Getting Started

### Prerequisites

- macOS
- Xcode

### Installation

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/oscampbell/OpenSnippets.git
    ```

2.  **Open in Xcode**:
    ```bash
    cd OpenSnippets
    open OpenSnippets.xcodeproj
    ```

3.  **Build and Run**:
    In Xcode, select the "OpenSnippets" scheme and your Mac as the target, then press `Cmd + R` to build and run the application.
