import SwiftUI

@main
struct PierApp: App {
    @State private var monitor = ServerMonitor()

    var body: some Scene {
        MenuBarExtra {
            ServerListView(monitor: monitor)
                .frame(width: 320)
        } label: {
            Image(nsImage: Self.menuBarIcon(count: monitor.servers.count))
        }
        .menuBarExtraStyle(.window)
    }

    /// Draws the Count-in-Circle menu bar icon.
    /// Uses isTemplate with alpha knockout so macOS handles light/dark automatically.
    static func menuBarIcon(count: Int) -> NSImage {
        let diameter: CGFloat = 15
        let padding: CGFloat = 2
        let totalSize = diameter + padding * 2
        let size = NSSize(width: totalSize, height: totalSize)
        let isIdle = count == 0

        let image = NSImage(size: size, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

            let circleRect = NSRect(
                x: padding, y: padding,
                width: diameter, height: diameter
            )

            // Draw filled circle — lower alpha for idle state (.tertiaryLabel effect)
            let circleAlpha: CGFloat = isIdle ? 0.35 : 1.0
            ctx.setFillColor(CGColor(gray: 0, alpha: circleAlpha))
            ctx.fillEllipse(in: circleRect)

            // Text config
            let text: String
            let fontSize: CGFloat
            if isIdle {
                text = "\u{2013}" // en-dash
                fontSize = 10
            } else if count > 9 {
                text = "9+"
                fontSize = 9
            } else {
                text = "\(count)"
                fontSize = 10.5
            }

            let font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .bold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.black,
            ]
            let attrString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attrString.size()
            let textOrigin = NSPoint(
                x: circleRect.midX - textSize.width / 2,
                y: circleRect.midY - textSize.height / 2
            )

            // Punch out text using destinationOut — creates transparent knockout
            ctx.setBlendMode(.destinationOut)
            attrString.draw(at: textOrigin)
            ctx.setBlendMode(.normal)

            return true
        }
        image.isTemplate = true
        return image
    }
}

