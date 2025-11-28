import AppKit
import Foundation

func createCalendarIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    let ctx = NSGraphicsContext.current!.cgContext
    
    // Scale factors
    let padding = size * 0.1
    let cornerRadius = size * 0.15
    
    // Calendar background
    let rect = NSRect(x: padding, y: padding, width: size - 2 * padding, height: size - 2 * padding * 1.3)
    let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    // White background
    NSColor.white.setFill()
    path.fill()
    
    // Border
    NSColor(white: 0.27, alpha: 1.0).setStroke()
    path.lineWidth = max(2, size * 0.02)
    path.stroke()
    
    // Header bar (red)
    let headerHeight = size * 0.25
    let headerRect = NSRect(x: padding, y: size - padding - headerHeight, width: size - 2 * padding, height: headerHeight)
    let headerPath = NSBezierPath(roundedRect: headerRect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    // Clip to only show top rounded corners
    let clipRect = NSRect(x: padding, y: size - padding - headerHeight, width: size - 2 * padding, height: headerHeight)
    NSBezierPath(rect: clipRect).setClip()
    
    NSColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1.0).setFill()
    headerPath.fill()
    
    // Reset clip
    ctx.resetClip()
    
    // Draw binding rings
    let ringY = size - padding - headerHeight - padding * 0.3
    let ringRadius = size * 0.05
    let ring1X = size * 0.3
    let ring2X = size * 0.7
    
    NSColor(white: 0.27, alpha: 1.0).setFill()
    for ringX in [ring1X, ring2X] {
        let ringRect = NSRect(x: ringX - ringRadius, y: ringY - ringRadius, width: ringRadius * 2, height: ringRadius * 2)
        NSBezierPath(ovalIn: ringRect).fill()
    }
    
    // Draw date number
    let dateText = "28"
    let fontSize = size * 0.35
    let font = NSFont.systemFont(ofSize: fontSize, weight: .semibold)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(white: 0.2, alpha: 1.0)
    ]
    
    let textSize = dateText.size(withAttributes: attributes)
    let textY = (size - padding - headerHeight) / 2 - textSize.height / 2
    let textX = (size - textSize.width) / 2
    
    dateText.draw(at: NSPoint(x: textX, y: textY), withAttributes: attributes)
    
    image.unlockFocus()
    return image
}

// Generate icons
let sizes: [(Int, Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

let outputDir = "/Users/richard/dev/source/mine/mcal/MenuBarCalendar/Assets.xcassets/AppIcon.appiconset"

for (baseSize, scale) in sizes {
    let actualSize = CGFloat(baseSize * scale / 2)
    let icon = createCalendarIcon(size: actualSize)
    
    if let tiffData = icon.tiffRepresentation,
       let bitmapImage = NSBitmapImageRep(data: tiffData),
       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
        
        let filename: String
        if scale == 1 {
            filename = "\(outputDir)/icon_\(baseSize)x\(baseSize).png"
        } else {
            filename = "\(outputDir)/icon_\(baseSize)x\(baseSize)@\(scale)x.png"
        }
        
        try? pngData.write(to: URL(fileURLWithPath: filename))
        print("Generated: \(filename)")
    }
}

print("All icons generated successfully!")
