import SwiftUI

struct ServerRowView: View {
    let server: DevServer
    let onOpen: () -> Void
    let onKill: () -> Void

    @State private var isHovering = false
    @State private var isPulsing = false
    @State private var isKilling = false
    @Environment(\.colorScheme) private var colorScheme

    // Design system status colors
    private var statusGreen: Color {
        colorScheme == .dark
            ? Color(red: 0x30/255, green: 0xD1/255, blue: 0x58/255) // #30D158
            : Color(red: 0x2D/255, green: 0xB8/255, blue: 0x4D/255) // #2DB84D — muted from #34C759
    }

    // Breathing pulse floor — lighter in light mode so green stays visible on #F5F5F5
    private var pulseMinOpacity: Double {
        colorScheme == .dark ? 0.3 : 0.5
    }

    var body: some View {
        HStack(spacing: 10) {
            // Port column (68pt fixed)
            HStack(spacing: 6) {
                Circle()
                    .fill(statusGreen)
                    .frame(width: 6, height: 6)
                    .opacity(isPulsing ? pulseMinOpacity : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
                    .onAppear { isPulsing = true }

                Text(":\(String(server.port))")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .tracking(-0.3)
            }
            .frame(width: 68, alignment: .leading)

            // Info column (flexible)
            VStack(alignment: .leading, spacing: 1) {
                Text(server.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.tail)

                if let branch = server.gitBranch {
                    HStack(spacing: 3) {
                        BranchIcon()
                            .frame(width: 10, height: 10)

                        Text(branch)
                            .font(.system(size: 10, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right column: uptime or actions
            // ZStack keeps both views in the hierarchy so hover tracking isn't broken
            ZStack {
                Text(TimeFormatter.format(server.uptime))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .opacity(isHovering ? 0 : 1)

                HStack(spacing: 3) {
                    KillButton {
                        isKilling = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onKill()
                        }
                    }
                    OpenButton(action: onOpen)
                }
                .opacity(isHovering ? 1 : 0)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(isHovering ? Color.primary.opacity(0.02) : .clear)
        .opacity(isKilling ? 0.3 : 1.0)
        .scaleEffect(isKilling ? 0.98 : 1.0)
        .contentShape(Rectangle())
        .animation(.easeOut(duration: 0.15), value: isHovering)
        .animation(.easeOut(duration: 0.2), value: isKilling)
        .onHover { hovering in
            isHovering = hovering
        }
    }

    func triggerKill() {
        isKilling = true
    }
}

// MARK: - Git Branch Icon (SF Symbol — reliable at small sizes)

struct BranchIcon: View {
    var body: some View {
        Image(systemName: "arrow.triangle.branch")
            .font(.system(size: 9, weight: .medium))
    }
}

// MARK: - Action Buttons per Design System

struct KillButton: View {
    let action: () -> Void
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme

    private var fgColor: Color {
        if isHovering {
            return colorScheme == .dark
                ? Color(red: 0xFF/255, green: 0x45/255, blue: 0x3A/255) // #FF453A
                : Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255) // #FF3B30
        }
        return colorScheme == .dark
            ? Color(red: 0x98/255, green: 0x98/255, blue: 0x9D/255) // #98989D
            : Color(red: 0x86/255, green: 0x86/255, blue: 0x8B/255) // #86868B
    }

    private var bgColor: Color {
        if isHovering {
            return colorScheme == .dark
                ? Color(red: 1, green: 69/255, blue: 58/255).opacity(0.1)
                : Color(red: 1, green: 59/255, blue: 48/255).opacity(0.06)
        }
        return .clear
    }

    var body: some View {
        Button(action: action) {
            Text("Kill")
                .font(.system(size: 11))
                .foregroundStyle(fgColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(bgColor, in: RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
    }
}

struct OpenButton: View {
    let action: () -> Void
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme

    private var bgOpacity: Double {
        if isHovering {
            return colorScheme == .dark ? 0.14 : 0.1
        }
        return colorScheme == .dark ? 0.1 : 0.06
    }

    var body: some View {
        Button(action: action) {
            Text("Open")
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Color.primary.opacity(bgOpacity),
                    in: RoundedRectangle(cornerRadius: 5)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
    }
}
