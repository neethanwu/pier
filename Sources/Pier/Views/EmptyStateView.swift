import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "circle.slash")
                .font(.system(size: 28, weight: .thin))
                .foregroundStyle(.tertiary)

            VStack(spacing: 4) {
                Text("No ports listening")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                Text("Start a dev server and Pier\nwill detect it automatically")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 24)
    }
}
