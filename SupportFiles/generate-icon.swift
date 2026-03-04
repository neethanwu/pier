#!/usr/bin/env swift
// Generates AppIcon.icns per Pier design system v1:
// - Background: linear-gradient(145deg, #1C1C2E → #0E0E18)
// - Circle: #F5F5F7
// - Number "8": #1C1C2E, SF Pro Bold
// - Corner radius: 22.5% (macOS icon grid)

import AppKit

func generateIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    // Rounded rect clip (22.5% corner radius per macOS icon grid)
    let cornerRadius = s * 0.225
    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(path)
    ctx.clip()

    // Background gradient: 145° (bottom-left to upper-right area)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let startColor = CGColor(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x2E/255.0, alpha: 1.0) // #1C1C2E
    let endColor = CGColor(red: 0x0E/255.0, green: 0x0E/255.0, blue: 0x18/255.0, alpha: 1.0)   // #0E0E18
    let gradient = CGGradient(colorsSpace: colorSpace, colors: [startColor, endColor] as CFArray, locations: [0.0, 1.0])!
    // 145° angle: start top-left, end bottom-right (slightly angled)
    let startPoint = CGPoint(x: s * 0.1, y: s * 0.9)
    let endPoint = CGPoint(x: s * 0.9, y: s * 0.1)
    ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

    // White circle
    let circleSize = s * 0.6
    let circleRect = CGRect(x: (s - circleSize) / 2, y: (s - circleSize) / 2, width: circleSize, height: circleSize)
    ctx.setFillColor(CGColor(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF7/255.0, alpha: 1.0)) // #F5F5F7
    ctx.fillEllipse(in: circleRect)

    // Number "8" — SF Pro Bold
    let fontSize = s * 0.38
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x2E/255.0, alpha: 1.0), // #1C1C2E
    ]
    let text = NSAttributedString(string: "8", attributes: attributes)
    let textSize = text.size()
    let textOrigin = NSPoint(
        x: (s - textSize.width) / 2,
        y: (s - textSize.height) / 2
    )
    text.draw(at: textOrigin)

    image.unlockFocus()
    return image
}

// Generate all required sizes for .icns
let sizes = [16, 32, 64, 128, 256, 512, 1024]
let iconsetPath = "SupportFiles/AppIcon.iconset"
let fm = FileManager.default

// Create iconset directory
try? fm.removeItem(atPath: iconsetPath)
try fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

for size in sizes {
    let image = generateIcon(size: size)
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed to generate \(size)px icon")
        continue
    }

    // Standard resolution
    if size <= 512 {
        let filename = "icon_\(size)x\(size).png"
        try png.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(filename)"))
    }

    // @2x resolution (half the name)
    let halfSize = size / 2
    if halfSize >= 16 && size != 16 {
        let filename2x = "icon_\(halfSize)x\(halfSize)@2x.png"
        try png.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(filename2x)"))
    }
}

// Convert to .icns
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetPath, "-o", "SupportFiles/AppIcon.icns"]
try process.run()
process.waitUntilExit()

// Clean up iconset
try? fm.removeItem(atPath: iconsetPath)

if process.terminationStatus == 0 {
    print("Generated SupportFiles/AppIcon.icns")
} else {
    print("iconutil failed with status \(process.terminationStatus)")
}
