#!/usr/bin/env swift
import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resourceDir = root.appendingPathComponent("Sources/QuotaCalendar/Resources", isDirectory: true)
let iconsetDir = resourceDir.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let fm = FileManager.default

let explicitSource = CommandLine.arguments.dropFirst().first.map { URL(fileURLWithPath: $0) }
let sourceURL = explicitSource ?? resourceDir.appendingPathComponent("AppIconSource.png")
let previewURL = resourceDir.appendingPathComponent("AppIcon.png")
let icnsURL = resourceDir.appendingPathComponent("AppIcon.icns")

guard fm.fileExists(atPath: sourceURL.path) else {
    throw NSError(
        domain: "AppIcon",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Missing icon source: \(sourceURL.path)"]
    )
}

func appendFourCharacterCode(_ code: String, to data: inout Data) {
    precondition(code.utf8.count == 4)
    data.append(contentsOf: code.utf8)
}

func appendBigEndianUInt32(_ value: UInt32, to data: inout Data) {
    var bigEndianValue = value.bigEndian
    withUnsafeBytes(of: &bigEndianValue) { data.append(contentsOf: $0) }
}

func writeICNS(from iconsetDir: URL, to url: URL) throws {
    let entries: [(type: String, file: String)] = [
        ("icp4", "icon_16x16.png"),
        ("ic11", "icon_16x16@2x.png"),
        ("icp5", "icon_32x32.png"),
        ("ic12", "icon_32x32@2x.png"),
        ("ic07", "icon_128x128.png"),
        ("ic13", "icon_128x128@2x.png"),
        ("ic08", "icon_256x256.png"),
        ("ic14", "icon_256x256@2x.png"),
        ("ic09", "icon_512x512.png"),
        ("ic10", "icon_512x512@2x.png")
    ]

    let chunks = try entries.map { entry in
        (entry.type, try Data(contentsOf: iconsetDir.appendingPathComponent(entry.file)))
    }
    let totalLength = chunks.reduce(8) { $0 + 8 + $1.1.count }

    var icns = Data()
    appendFourCharacterCode("icns", to: &icns)
    appendBigEndianUInt32(UInt32(totalLength), to: &icns)
    for (type, payload) in chunks {
        appendFourCharacterCode(type, to: &icns)
        appendBigEndianUInt32(UInt32(payload.count + 8), to: &icns)
        icns.append(payload)
    }
    try icns.write(to: url)
}

func resizedPNG(from image: NSImage, sourceURL: URL, size: Int, to url: URL) throws {
    if size == 1024 {
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
        try fm.copyItem(at: sourceURL, to: url)
        return
    }

    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "AppIcon", code: 2)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    NSColor.clear.setFill()
    NSBezierPath(rect: CGRect(x: 0, y: 0, width: size, height: size)).fill()
    image.draw(in: CGRect(x: 0, y: 0, width: size, height: size), from: .zero, operation: .sourceOver, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()

    guard let data = rep.representation(using: .png, properties: [.compressionFactor: 0.92]) else {
        throw NSError(domain: "AppIcon", code: 3)
    }
    try data.write(to: url)
}

for path in [iconsetDir.path, previewURL.path, icnsURL.path] where fm.fileExists(atPath: path) {
    try fm.removeItem(atPath: path)
}
try fm.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

guard let sourceImage = NSImage(contentsOf: sourceURL) else {
    throw NSError(
        domain: "AppIcon",
        code: 4,
        userInfo: [NSLocalizedDescriptionKey: "Cannot read icon source: \(sourceURL.path)"]
    )
}

let icons: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (name, size) in icons {
    try resizedPNG(from: sourceImage, sourceURL: sourceURL, size: size, to: iconsetDir.appendingPathComponent(name))
}
try fm.copyItem(at: sourceURL, to: previewURL)
try writeICNS(from: iconsetDir, to: icnsURL)

print("Generated AppIcon.png, AppIcon.iconset and AppIcon.icns from \(sourceURL.path)")
