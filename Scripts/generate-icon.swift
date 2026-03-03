#!/usr/bin/env swift
// Generates Pier.icns from the Count-in-Circle brand mark.
// Design system spec: "8" in white circle on dark gradient background.
// Usage: swift Scripts/generate-icon.swift

import AppKit
import Foundation

let sizes: [(Int, String)] = [
    (16,   "icon_16x16.png"),
    (32,   "icon_16x16@2x.png"),
    (32,   "icon_32x32.png"),
    (64,   "icon_32x32@2x.png"),
    (128,  "icon_128x128.png"),
    (256,  "icon_128x128@2x.png"),
    (256,  "icon_256x256.png"),
    (512,  "icon_256x256@2x.png"),
    (512,  "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

func drawIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    // Background: macOS rounded rect (22.5% corner radius per design system)
    let cornerRadius = s * 0.225
    let bgRect = NSRect(x: 0, y: 0, width: s, height: s)
    let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)

    // Gradient background: linear-gradient(145deg, #1C1C2E, #0E0E18)
    bgPath.addClip()
    let gradientColors = [
        CGColor(srgbRed: 0x1C/255, green: 0x1C/255, blue: 0x2E/255, alpha: 1),
        CGColor(srgbRed: 0x0E/255, green: 0x0E/255, blue: 0x18/255, alpha: 1),
    ] as CFArray
    if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: gradientColors, locations: [0, 1]) {
        // 145deg: top-left to bottom-right (roughly)
        let startPoint = CGPoint(x: s * 0.15, y: s * 0.85)
        let endPoint = CGPoint(x: s * 0.85, y: s * 0.15)
        ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
    }

    // White circle in center
    let circleDiameter = s * 0.56
    let circleRect = NSRect(
        x: (s - circleDiameter) / 2,
        y: (s - circleDiameter) / 2,
        width: circleDiameter,
        height: circleDiameter
    )
    ctx.setFillColor(CGColor(srgbRed: 0xF5/255, green: 0xF5/255, blue: 0xF7/255, alpha: 1))
    ctx.fillEllipse(in: circleRect)

    // Draw "8" — the canonical brand glyph
    let fontSize = circleDiameter * 0.55
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(red: 0x1C/255, green: 0x1C/255, blue: 0x2E/255, alpha: 1),
    ]
    let attrString = NSAttributedString(string: "8", attributes: attributes)
    let textSize = attrString.size()
    let textOrigin = NSPoint(
        x: circleRect.midX - textSize.width / 2,
        y: circleRect.midY - textSize.height / 2
    )
    attrString.draw(at: textOrigin)

    image.unlockFocus()
    return image
}

// Create iconset directory
let iconsetPath = "SupportFiles/AppIcon.iconset"
let fm = FileManager.default
try? fm.removeItem(atPath: iconsetPath)
try fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

for (size, filename) in sizes {
    let image = drawIcon(size: size)
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        print("Failed to generate \(filename)")
        continue
    }
    let path = "\(iconsetPath)/\(filename)"
    try pngData.write(to: URL(fileURLWithPath: path))
    print("Generated \(filename) (\(size)x\(size))")
}

// Convert to .icns
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetPath, "-o", "SupportFiles/AppIcon.icns"]
try process.run()
process.waitUntilExit()

if process.terminationStatus == 0 {
    print("Created SupportFiles/AppIcon.icns")
    try? fm.removeItem(atPath: iconsetPath)
} else {
    print("iconutil failed with status \(process.terminationStatus)")
}
