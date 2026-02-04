import SwiftUI

struct SnippetCardView: View {
    let snippet: Snippet
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Window Header
            HStack(spacing: 8) {
                Circle().fill(Color.red).frame(width: 12, height: 12)
                Circle().fill(Color.yellow).frame(width: 12, height: 12)
                Circle().fill(Color.green).frame(width: 12, height: 12)
                Spacer()
                Text(snippet.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor.color.opacity(0.5))
            }
            .padding(.bottom, 8)
            
            // Content
            Text(snippet.content)
                .font(.system(size: theme.fontSize, weight: .regular, design: .monospaced))
                .foregroundColor(theme.textColor.color)
                .lineSpacing(4)
        }
        .padding(32)
        .background(theme.snippetDetailBackgroundColor.color)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(40)
        .background(
            LinearGradient(
                colors: [theme.primaryAccentColor.color, theme.secondaryAccentColor.color],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
