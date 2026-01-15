# OpenSnippets

A macOS application designed for developers and users to store, organize, and manage their frequently used code snippets or text blocks efficiently.

## Features

-   **Snippet Management**: Create, edit, and delete code snippets with customizable titles and content.
-   **Intuitive Two-Pane Interface**: A clean and user-friendly interface featuring a list of all snippets on the left pane and a dedicated editor for the selected snippet on the right.
-   **Quick Search Functionality**: Easily locate any snippet by searching through its title or content using the integrated search bar.
-   **Syntax Highlighting**: Supports syntax highlighting for a variety of programming languages, including Plain Text, Swift, Python, JavaScript, HTML, CSS, JSON, and Bash/Shell. This functionality is powered by an integrated version of Highlightr (a wrapper around the popular highlight.js library).
-   **Extensive Customizable Themes**: Personalize the application's appearance to match your preferences. Users can adjust primary and secondary accent colors, text color, background colors for both the snippet list and detail panes, font size, and choose between "Monospaced," "Serif," or "System" font families.
-   **Dynamic Variable Expansion**: Enhance productivity with automatic replacement of placeholders like `{{date}}`, `{{time}}`, `{{datetime}}`, and `{{clipboard}}` with their current values when snippet content is copied.
-   **Seamless Clipboard Integration**: Effortlessly copy snippet content to the system clipboard or paste content from the clipboard directly into your snippets.
-   **Automatic Persistence**: All your snippets are automatically saved to a local JSON file in your application support directory, ensuring data integrity and retention across sessions.
-   **Built-in Spell Checking**: The snippet editor includes spell-checking capabilities to help maintain accuracy in your text.
-   **In-App Help**: Access a dedicated help sheet for guidance on using the application's features.

## Known Issues

-   **Basic Syntax Highlighting**: While functional, the current `Highlightr` implementation is a custom integration and may not offer the most up-to-date language definitions or advanced highlighting features found in the latest official releases of `highlight.js`.
-   **Limited Default Themes**: The application currently provides extensive customization options but does not include a selection of pre-defined themes. Users must manually configure colors to create their desired aesthetic.

## Future Development

-   **Enhanced Syntax Highlighting**: Plan to upgrade to the latest official `Highlightr` library or explore other robust syntax highlighting solutions to ensure broader language support, improved accuracy, and better performance.
-   **Pre-built Theme Library**: Introduce a diverse collection of attractive, pre-configured themes that users can select with a single click, providing a quicker way to personalize the application.
-   **Snippet Tagging and Categorization**: Implement a comprehensive system for tagging, categorizing, and filtering snippets, allowing for more granular organization and easier retrieval of specific code blocks.
-   **Cloud Synchronization**: Explore and integrate options for syncing snippets across multiple macOS devices (e.g., via iCloud or a custom backend service).
-   **Import/Export Functionality**: Develop features to allow users to import and export snippets in various common formats (e.g., JSON, plain text, markdown).
-   **Basic Version Control for Snippets**: Introduce functionality to track changes to individual snippets, offering a history and the ability to revert to previous versions.

## Getting Started

### Prerequisites

-   macOS (latest stable version recommended)
-   Xcode (latest stable version recommended)

### Installation

1.  **Clone the Repository**:
    ```bash
    git clone [repository_url]
    ```
    (Replace `[repository_url]` with the actual URL of this repository.)

2.  **Open in Xcode**:
    Navigate to the cloned directory and open the project:
    ```bash
    open OpenSnippets.xcodeproj
    ```

3.  **Build and Run**:
    In Xcode, select your desired target (e.g., "My Mac") from the scheme dropdown and click the "Run" button (▶︎) or press `Cmd + R` to build and launch the application.
