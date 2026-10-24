import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let width = 720
let height = 320
let frameCount = 40
let outputURL = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent()
    .appendingPathComponent("qa-hero.gif")

let colorSpace = CGColorSpaceCreateDeviceRGB()
let blue = CGColor(red: 0.24, green: 0.55, blue: 1, alpha: 1)
let cyan = CGColor(red: 0.13, green: 0.86, blue: 0.91, alpha: 1)
let muted = CGColor(red: 0.49, green: 0.58, blue: 0.7, alpha: 1)

func drawText(_ text: String, x: CGFloat, y: CGFloat, size: CGFloat, color: CGColor, centered: Bool = false, context: CGContext) {
    let font = CTFontCreateWithName("Menlo" as CFString, size, nil)
    let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
    let textX = centered ? x - CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil)) / 2 : x
    context.textPosition = CGPoint(x: textX, y: y)
    CTLineDraw(line, context)
}

let nodes: [(String, String, CGFloat, CGFloat, CGColor)] = [
    ("API", "REST / JSON", 82, 122, blue),
    ("TEST", "Playwright", 235, 72, cyan),
    ("BUG", "Jira Track", 415, 125, blue),
    ("ASSERT", "Strict Equal", 604, 88, blue),
    ("QA", "Automation", 496, 170, cyan),
    ("CI/CD", "GitHub Actions", 180, 166, blue),
]

let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.gif.identifier as CFString, frameCount, nil)!
CGImageDestinationSetProperties(destination, [
    kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0],
] as CFDictionary)

for frame in 0..<frameCount {
    let bitmap = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    let time = CGFloat(frame) / CGFloat(frameCount) * 2 * .pi

    bitmap.setFillColor(CGColor(red: 0.025, green: 0.04, blue: 0.075, alpha: 1))
    bitmap.fill(CGRect(x: 0, y: 0, width: width, height: height))

    bitmap.setStrokeColor(CGColor(red: 0.15, green: 0.25, blue: 0.38, alpha: 0.25))
    bitmap.setLineWidth(0.5)
    for x in stride(from: 0, through: width, by: 32) {
        bitmap.move(to: CGPoint(x: x, y: 0))
        bitmap.addLine(to: CGPoint(x: x, y: height))
    }
    for y in stride(from: 0, through: height, by: 32) {
        bitmap.move(to: CGPoint(x: 0, y: y))
        bitmap.addLine(to: CGPoint(x: width, y: y))
    }
    bitmap.strokePath()

    let particles: [(CGFloat, CGFloat)] = (0..<34).map { index in
        let seed = CGFloat(index)
        let x = (seed * 97 + 25 + sin(time + seed) * 17).truncatingRemainder(dividingBy: CGFloat(width - 20)) + 10
        let y = (seed * 53 + 31 + cos(time * 0.8 + seed * 1.7) * 15).truncatingRemainder(dividingBy: CGFloat(height - 20)) + 10
        return (x, y)
    }

    for first in particles.indices {
        for second in particles.indices where second > first {
            let dx = particles[first].0 - particles[second].0
            let dy = particles[first].1 - particles[second].1
            let distance = hypot(dx, dy)
            if distance < 112 {
                bitmap.setStrokeColor(CGColor(red: 0.22, green: 0.48, blue: 0.9, alpha: 0.4 * (1 - distance / 112)))
                bitmap.setLineWidth(0.8)
                bitmap.move(to: CGPoint(x: particles[first].0, y: particles[first].1))
                bitmap.addLine(to: CGPoint(x: particles[second].0, y: particles[second].1))
                bitmap.strokePath()
            }
        }
    }

    for (index, particle) in particles.enumerated() {
        bitmap.setFillColor(index.isMultiple(of: 4) ? cyan : blue)
        bitmap.fillEllipse(in: CGRect(x: particle.0 - 1.8, y: particle.1 - 1.8, width: 3.6, height: 3.6))
    }

    drawText("MD. TANVIR AHAMED", x: CGFloat(width) / 2, y: 276, size: 21, color: .white, centered: true, context: bitmap)
    drawText("JUNIOR SQA ENGINEER  /  MANUAL  ·  API  ·  AUTOMATION", x: CGFloat(width) / 2, y: 253, size: 10, color: muted, centered: true, context: bitmap)

    for (index, node) in nodes.enumerated() {
        let drift = sin(time + CGFloat(index) * 0.8) * 5
        let center = CGPoint(x: node.2, y: node.3 + drift)
        bitmap.setFillColor(CGColor(red: 0.04, green: 0.08, blue: 0.14, alpha: 0.94))
        bitmap.fillEllipse(in: CGRect(x: center.x - 39, y: center.y - 39, width: 78, height: 78))
        bitmap.setStrokeColor(CGColor(red: 0.24, green: 0.55, blue: 1, alpha: 0.65))
        bitmap.setLineWidth(1)
        bitmap.strokeEllipse(in: CGRect(x: center.x - 39, y: center.y - 39, width: 78, height: 78))
        drawText(node.0, x: center.x, y: center.y + 2, size: 11, color: node.4, centered: true, context: bitmap)
        drawText(node.1, x: center.x, y: center.y - 13, size: 7, color: muted, centered: true, context: bitmap)
    }

    drawText("34 / 34 TESTS PASSED", x: 26, y: 22, size: 9, color: CGColor(red: 0.25, green: 0.88, blue: 0.58, alpha: 1), context: bitmap)

    let image = bitmap.makeImage()!
    CGImageDestinationAddImage(destination, image, [
        kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 0.08],
    ] as CFDictionary)
}

guard CGImageDestinationFinalize(destination) else {
    fatalError("Could not write the animated hero GIF")
}

print("Generated \(outputURL.path)")