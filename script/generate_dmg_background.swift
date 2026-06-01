#!/usr/bin/env swift
import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resourceDir = root.appendingPathComponent("Sources/QuotaCalendar/Resources", isDirectory: true)
let baseURL = resourceDir.appendingPathComponent("DmgBackgroundBase.png")
let outputURL = resourceDir.appendingPathComponent("DmgBackground.png")

let width = 720
let height = 420

func roundedRect(_ rect: CGRect, _ radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawText(_ text: String, at point: CGPoint, size: CGFloat, weight: NSFont.Weight, color: NSColor, alignment: NSTextAlignment = .center, width: CGFloat = 360) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: paragraph
    ]
    NSString(string: text).draw(in: CGRect(x: point.x - width / 2, y: point.y, width: width, height: size * 1.5), withAttributes: attrs)
}

func strokePath(_ path: NSBezierPath, color: NSColor, width: CGFloat) {
    color.setStroke()
    path.lineWidth = width
    path.stroke()
}

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: width,
    pixelsHigh: height,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fatalError("Unable to create bitmap")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSGraphicsContext.current?.imageInterpolation = .high

let canvas = CGRect(x: 0, y: 0, width: width, height: height)
NSColor(calibratedRed: 0.10, green: 0.12, blue: 0.13, alpha: 1).setFill()
NSBezierPath(rect: canvas).fill()

if let base = NSImage(contentsOf: baseURL) {
    let srcRatio = base.size.width / base.size.height
    let dstRatio = CGFloat(width) / CGFloat(height)
    var srcRect = CGRect(origin: .zero, size: base.size)
    if srcRatio > dstRatio {
        let cropWidth = base.size.height * dstRatio
        srcRect.origin.x = (base.size.width - cropWidth) / 2
        srcRect.size.width = cropWidth
    } else {
        let cropHeight = base.size.width / dstRatio
        srcRect.origin.y = (base.size.height - cropHeight) / 2
        srcRect.size.height = cropHeight
    }
    base.draw(in: canvas, from: srcRect, operation: .sourceOver, fraction: 1)
}

let overlay = NSGradient(colors: [
    NSColor(calibratedWhite: 0.03, alpha: 0.28),
    NSColor(calibratedWhite: 0.02, alpha: 0.06),
    NSColor(calibratedWhite: 0.03, alpha: 0.32)
])
overlay?.draw(in: NSBezierPath(rect: canvas), angle: 0)

let titleColor = NSColor(calibratedWhite: 0.96, alpha: 0.96)
let mutedColor = NSColor(calibratedWhite: 0.80, alpha: 0.70)
let accentColor = NSColor(calibratedRed: 0.42, green: 0.95, blue: 0.55, alpha: 0.95)

drawText("Codex Quota Calendar", at: CGPoint(x: 360, y: 334), size: 24, weight: .semibold, color: titleColor)
drawText("Drag to Applications to install", at: CGPoint(x: 360, y: 304), size: 14, weight: .medium, color: mutedColor)

let leftHalo = roundedRect(CGRect(x: 96, y: 106, width: 168, height: 168), 84)
NSColor(calibratedWhite: 1, alpha: 0.055).setFill()
leftHalo.fill()

let rightHalo = roundedRect(CGRect(x: 456, y: 106, width: 168, height: 168), 84)
NSColor(calibratedRed: 0.44, green: 1.0, blue: 0.58, alpha: 0.07).setFill()
rightHalo.fill()

let arrow = NSBezierPath()
arrow.move(to: CGPoint(x: 282, y: 190))
arrow.curve(to: CGPoint(x: 436, y: 190), controlPoint1: CGPoint(x: 326, y: 162), controlPoint2: CGPoint(x: 392, y: 162))
arrow.lineCapStyle = .round
strokePath(arrow, color: accentColor, width: 5)

let arrowHead = NSBezierPath()
arrowHead.move(to: CGPoint(x: 434, y: 190))
arrowHead.line(to: CGPoint(x: 414, y: 206))
arrowHead.move(to: CGPoint(x: 434, y: 190))
arrowHead.line(to: CGPoint(x: 414, y: 174))
arrowHead.lineCapStyle = .round
arrowHead.lineJoinStyle = .round
strokePath(arrowHead, color: accentColor, width: 5)

drawText("App", at: CGPoint(x: 180, y: 72), size: 13, weight: .medium, color: mutedColor)
drawText("Applications", at: CGPoint(x: 540, y: 72), size: 13, weight: .medium, color: mutedColor)

let footer = "Local-only quota rhythm for Codex"
drawText(footer, at: CGPoint(x: 360, y: 32), size: 12, weight: .regular, color: NSColor(calibratedWhite: 0.82, alpha: 0.48))

NSGraphicsContext.restoreGraphicsState()

guard let data = rep.representation(using: .png, properties: [.compressionFactor: 0.92]) else {
    fatalError("Unable to encode PNG")
}
try data.write(to: outputURL)
print("Generated \(outputURL.path)")
