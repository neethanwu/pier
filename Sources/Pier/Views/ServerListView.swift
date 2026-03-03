import SwiftUI

struct ServerListView: View {
    @Bindable var monitor: ServerMonitor
    @Environment(\.colorScheme) private var colorScheme
    @State private var refreshAngle: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            header

            if monitor.servers.isEmpty {
                EmptyStateView()
            } else {
                serverList
            }

            footer
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 7) {
                // Count-in-circle mark (14x14pt per spec)
                CountCircle(count: monitor.servers.count, size: 14, colorScheme: colorScheme)

                Text("Pier")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.3)
            }

            Spacer()

            HStack(spacing: 2) {
                // Refresh button
                HeaderButton {
                    withAnimation(.linear(duration: 0.5)) {
                        refreshAngle += 360
                    }
                    Task { await monitor.refresh() }
                } label: {
                    RefreshIcon()
                        .frame(width: 13, height: 13)
                        .rotationEffect(.degrees(refreshAngle))
                }
                .keyboardShortcut("r", modifiers: .command)

                // Close button
                HeaderButton {
                    NSApplication.shared.terminate(nil)
                } label: {
                    CloseIcon()
                        .frame(width: 12, height: 12)
                }
                .keyboardShortcut("w", modifiers: .command)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
    }

    // MARK: - Server List

    private var serverList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(monitor.servers.enumerated()), id: \.element.id) { index, server in
                    if index > 0 {
                        Divider()
                            .opacity(0.04)
                            .padding(.horizontal, 14)
                    }
                    ServerRowView(
                        server: server,
                        onOpen: { monitor.openInBrowser(server: server) },
                        onKill: {
                            withAnimation(.spring(response: 0.35)) {
                                monitor.kill(server: server)
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .animation(.spring(response: 0.35), value: monitor.servers.count)
        }
        .frame(maxHeight: 380)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Text("\(monitor.servers.count) listening")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.system(size: 10))
            .foregroundStyle(
                colorScheme == .dark
                    ? Color(red: 0x98/255, green: 0x98/255, blue: 0x9D/255)
                    : Color(red: 0x86/255, green: 0x86/255, blue: 0x8B/255)
            )
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .overlay(alignment: .top) {
            Divider().opacity(0.04)
        }
    }
}

// MARK: - Count-in-Circle (shared between header and potentially elsewhere)

struct CountCircle: View {
    let count: Int
    let size: CGFloat
    let colorScheme: ColorScheme

    private var label: String {
        if count == 0 { return "\u{2013}" }
        if count > 9 { return "9+" }
        return "\(count)"
    }

    private var fontSize: CGFloat {
        let base = size * 0.6
        if count == 0 { return base * 0.85 }
        if count > 9 { return base * 0.75 }
        return base
    }

    var body: some View {
        Canvas { ctx, canvasSize in
            let d = min(canvasSize.width, canvasSize.height)
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            // Circle fill
            let circleRect = CGRect(x: center.x - d/2, y: center.y - d/2, width: d, height: d)
            let circlePath = Path(ellipseIn: circleRect)

            if count == 0 {
                // Idle: dimmed circle
                let idleColor: Color = colorScheme == .dark
                    ? Color(red: 0x63/255, green: 0x63/255, blue: 0x66/255) // #636366
                    : Color(red: 0xAE/255, green: 0xAE/255, blue: 0xB2/255) // #AEAEB2
                ctx.fill(circlePath, with: .color(idleColor))
            } else {
                // Active: high-contrast fill
                let fillColor: Color = colorScheme == .dark
                    ? Color(red: 0xF5/255, green: 0xF5/255, blue: 0xF7/255) // #F5F5F7
                    : Color(red: 0x1D/255, green: 0x1D/255, blue: 0x1F/255) // #1D1D1F
                ctx.fill(circlePath, with: .color(fillColor))
            }

            // Text inside circle
            let textColor: Color
            if count == 0 {
                textColor = colorScheme == .dark
                    ? Color(red: 0x2C/255, green: 0x2C/255, blue: 0x2E/255) // #2C2C2E
                    : Color(red: 0xF5/255, green: 0xF5/255, blue: 0xF7/255) // #F5F5F7
            } else {
                textColor = colorScheme == .dark
                    ? Color(red: 0x1C/255, green: 0x1C/255, blue: 0x1E/255) // #1C1C1E
                    : Color(red: 0xF5/255, green: 0xF5/255, blue: 0xF7/255) // #F5F5F7
            }

            let font = Font.system(size: fontSize, weight: .bold).monospacedDigit()
            var text = Text(label).font(font).foregroundColor(textColor)
            text = text.foregroundColor(textColor)
            ctx.draw(text, at: center)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Refresh Icon (two counter-rotating arcs with arrow tips per design system)

struct RefreshIcon: View {
    @Environment(\.colorScheme) private var colorScheme

    private var iconColor: Color {
        colorScheme == .dark
            ? Color(red: 0x98/255, green: 0x98/255, blue: 0x9D/255) // #98989D
            : Color(red: 0x86/255, green: 0x86/255, blue: 0x8B/255) // #86868B
    }

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / 16, size.height / 16)
            context.scaleBy(x: scale, y: scale)

            let shading = GraphicsContext.Shading.color(iconColor)
            let stroke = StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)

            // Top arc: from left (180°) clockwise through top to upper-right (316°)
            context.stroke(
                Path { p in
                    p.addArc(center: CGPoint(x: 8, y: 8), radius: 6,
                             startAngle: .degrees(180), endAngle: .degrees(316),
                             clockwise: false)
                },
                with: shading, style: stroke
            )

            // Bottom arc: from right (0°) clockwise through bottom to lower-left (136°)
            context.stroke(
                Path { p in
                    p.addArc(center: CGPoint(x: 8, y: 8), radius: 6,
                             startAngle: .degrees(0), endAngle: .degrees(136),
                             clockwise: false)
                },
                with: shading, style: stroke
            )

            // Top-right arrow tip
            context.stroke(
                Path { p in
                    p.move(to: CGPoint(x: 12, y: 2))
                    p.addLine(to: CGPoint(x: 13, y: 4))
                    p.addLine(to: CGPoint(x: 11, y: 4.5))
                },
                with: shading, style: stroke
            )

            // Bottom-left arrow tip
            context.stroke(
                Path { p in
                    p.move(to: CGPoint(x: 4, y: 14))
                    p.addLine(to: CGPoint(x: 3, y: 12))
                    p.addLine(to: CGPoint(x: 5, y: 11.5))
                },
                with: shading, style: stroke
            )
        }
    }
}

// MARK: - Close Icon (X mark per design system)

struct CloseIcon: View {
    @Environment(\.colorScheme) private var colorScheme

    private var iconColor: Color {
        colorScheme == .dark
            ? Color(red: 0x98/255, green: 0x98/255, blue: 0x9D/255) // #98989D
            : Color(red: 0x86/255, green: 0x86/255, blue: 0x8B/255) // #86868B
    }

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / 16, size.height / 16)
            context.scaleBy(x: scale, y: scale)

            let shading = GraphicsContext.Shading.color(iconColor)
            let stroke = StrokeStyle(lineWidth: 1.8, lineCap: .round)

            context.stroke(
                Path { p in
                    p.move(to: CGPoint(x: 4, y: 4))
                    p.addLine(to: CGPoint(x: 12, y: 12))
                },
                with: shading, style: stroke
            )
            context.stroke(
                Path { p in
                    p.move(to: CGPoint(x: 12, y: 4))
                    p.addLine(to: CGPoint(x: 4, y: 12))
                },
                with: shading, style: stroke
            )
        }
    }
}

// MARK: - Header Button (26x26pt hit area, 6pt corner radius per spec)

struct HeaderButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: Label
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme

    // Design system: light rgba(0,0,0,0.05), dark rgba(255,255,255,0.06)
    private var hoverOpacity: Double {
        colorScheme == .dark ? 0.06 : 0.05
    }

    var body: some View {
        Button(action: action) {
            label
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 26)
                .background(
                    isHovering ? Color.primary.opacity(hoverOpacity) : .clear,
                    in: RoundedRectangle(cornerRadius: 6)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
    }
}
