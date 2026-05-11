#!/usr/bin/env swift

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// ============================================================
// QRCodeApp - 应用图标生成器
// 用法: 在 macOS 上运行: swift Scripts/generate_app_icon.swift
// 输出: QRCodeApp/Resources/Assets.xcassets/AppIcon.appiconset/*.png
// ============================================================

// MARK: - App Icon 配置

/// 图标尺寸规格
struct IconSpec: CustomStringConvertible {
    let pointSize: CGFloat
    let scale: Int
    var pixelSize: Int { Int(pointSize * CGFloat(scale)) }
    var filename: String {
        let s = scale == 1 ? "" : "@\(scale)x"
        return "AppIcon\(Int(pointSize))x\(Int(pointSize))\(s).png"
    }
    var description: String { "\(filename) (\(pixelSize)×\(pixelSize)px)" }
}

let iconSpecs: [IconSpec] = [
    .init(pointSize: 20, scale: 2),
    .init(pointSize: 20, scale: 3),
    .init(pointSize: 29, scale: 2),
    .init(pointSize: 29, scale: 3),
    .init(pointSize: 40, scale: 2),
    .init(pointSize: 40, scale: 3),
    .init(pointSize: 60, scale: 2),
    .init(pointSize: 60, scale: 3),
    .init(pointSize: 1024, scale: 1),  // App Store
]

let outputDir = FileManager.default.currentDirectoryPath
    + "/QRCodeApp/Resources/Assets.xcassets/AppIcon.appiconset"

// MARK: - 绘制函数

/// 绘制 QR 码风格应用图标
/// 设计说明：
/// - 深蓝→蓝渐变圆角背景，象征科技感
/// - 白色 QR 码定位图案 + 数据模块
/// - 右下角扫描框装饰，体现"扫码"功能
func drawAppIcon(pixelSize: Int) -> CGImage? {
    let cs = CGFloat(pixelSize)
    let rect = CGRect(x: 0, y: 0, width: cs, height: cs)

    guard let ctx = CGContext(
        data: nil,
        width: pixelSize, height: pixelSize,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
    ) else { return nil }

    ctx.setShouldAntialias(true)
    ctx.setAllowsAntialiasing(true)
    ctx.interpolationQuality = .high

    // ----- 1. 渐变背景 -----
    let topColor = CGColor(red: 0.02, green: 0.44, blue: 0.96, alpha: 1.0)   // #0570f5
    let botColor = CGColor(red: 0.08, green: 0.22, blue: 0.70, alpha: 1.0)   // #1438b3
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [topColor, botColor] as CFArray,
        locations: [0.0, 1.0]
    )

    // 圆角裁剪
    let cornerRadius = cs * 0.22
    let clipPath = CGPath(roundedRect: rect,
                          cornerWidth: cornerRadius,
                          cornerHeight: cornerRadius,
                          transform: nil)
    ctx.addPath(clipPath)
    ctx.clip()

    if let g = gradient {
        ctx.drawLinearGradient(g,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: cs, y: cs),
            options: [])
    }

    let white = CGColor(red: 1, green: 1, blue: 1, alpha: 0.95)

    // ----- 2. QR 码定位图案 -----
    let qrSize = cs * 0.58
    let qx = (cs - qrSize) / 2
    let qy = (cs - qrSize) / 2
    let m = qrSize / 15  // 模块尺寸

    func positionPattern(atX: Int, atY: Int) {
        let ox = qx + CGFloat(atX) * m
        let oy = qy + CGFloat(atY) * m
        // 外框 7x7
        ctx.setFillColor(white)
        ctx.fill(CGRect(x: ox, y: oy, width: m * 7, height: m * 7))
        // 挖空 5x5 内白
        ctx.setBlendMode(.clear)
        ctx.fill(CGRect(x: ox + m, y: oy + m, width: m * 5, height: m * 5))
        ctx.setBlendMode(.normal)
        // 内黑 3x3
        ctx.setFillColor(white)
        ctx.fill(CGRect(x: ox + m * 2, y: oy + m * 2, width: m * 3, height: m * 3))
    }

    positionPattern(atX: 0, atY: 0)
    positionPattern(atX: 8, atY: 0)
    positionPattern(atX: 0, atY: 8)

    // ----- 3. QR 码数据模块（视觉填充） -----
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.85))
    // 用固定种子产生类似二维码的视觉图案
    let pattern: [[Bool]] = (0..<15).map { r in
        (0..<15).map { c in
            let v = (r * 17 + c * 31 + 7) % 19
            return v > 7  // ~50% 填充率
        }
    }

    for r in 0..<15 {
        for c in 0..<15 {
            // 跳过定位图案区域 + 格式校正区
            if (r < 7 && c < 7) || (r < 7 && c > 7) || (r > 7 && c < 7) { continue }
            // 跳过时序图案（第6行/列）
            if r == 6 || c == 6 { continue }
            guard pattern[r][c] else { continue }

            let x = qx + CGFloat(c) * m
            let y = qy + CGFloat(r) * m
            ctx.fill(CGRect(x: x, y: y, width: m, height: m))
        }
    }

    // 时序图案（虚线）
    ctx.setFillColor(white)
    for i in 0..<8 {
        if i % 2 == 0 {
            // 水平时序（第6行）
            let x = qx + CGFloat(7 + i) * m
            let y = qy + 6 * m
            ctx.fill(CGRect(x: x, y: y, width: m, height: m))
            // 垂直时序（第6列）
            let x2 = qx + 6 * m
            let y2 = qy + CGFloat(7 + i) * m
            ctx.fill(CGRect(x: x2, y: y2, width: m, height: m))
        }
    }

    // ----- 4. 右下角扫描取景框装饰 -----
    let scanBoxSize = cs * 0.22
    let scanMargin = cs * 0.10
    let sx = cs - scanBoxSize - scanMargin
    let sy = cs - scanBoxSize - scanMargin

    // 半透明框
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.50))
    ctx.setLineWidth(1.5)
    ctx.stroke(CGRect(x: sx, y: sy, width: scanBoxSize, height: scanBoxSize))

    // 四角白色 L 形角标
    let cornerLen = scanBoxSize * 0.28
    let lineW: CGFloat = max(2.5, cs * 0.004)
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.85))
    ctx.setLineWidth(lineW)
    ctx.setLineCap(.round)

    let pts: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (sx, sy + cornerLen, sx, sy, sx + cornerLen, sy),                    // 左上
        (sx + scanBoxSize - cornerLen, sy, sx + scanBoxSize, sy, sx + scanBoxSize, sy + cornerLen), // 右上
        (sx, sy + scanBoxSize - cornerLen, sx, sy + scanBoxSize, sx + cornerLen, sy + scanBoxSize), // 左下
        (sx + scanBoxSize - cornerLen, sy + scanBoxSize, sx + scanBoxSize, sy + scanBoxSize, sx + scanBoxSize, sy + scanBoxSize - cornerLen), // 右下
    ]
    for (x1, y1, x2, y2, x3, y3) in pts {
        ctx.move(to: CGPoint(x: x1, y: y1))
        ctx.addLine(to: CGPoint(x: x2, y: y2))
        ctx.addLine(to: CGPoint(x: x3, y: y3))
        ctx.strokePath()
    }

    return ctx.makeImage()
}

// MARK: - 保存 PNG

func savePNG(_ image: CGImage, to path: String) -> Bool {
    let url = URL(fileURLWithPath: path)
    guard let dest = CGImageDestinationCreateWithURL(
        url as CFURL,
        UTType.png.identifier as CFString,
        1, nil
    ) else { return false }
    CGImageDestinationAddImage(dest, image, nil)
    return CGImageDestinationFinalize(dest)
}

// MARK: - 主流程

func main() {
    let fm = FileManager.default
    try? fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

    print("🎨 QRCodeApp 图标生成器\n")
    print("📂 输出: \(outputDir)\n")

    var success = 0
    var failure = 0

    for spec in iconSpecs {
        guard let cgImage = drawAppIcon(pixelSize: spec.pixelSize) else {
            print("  ❌ 绘制失败: \(spec)")
            failure += 1
            continue
        }
        let filePath = "\(outputDir)/\(spec.filename)"
        if savePNG(cgImage, to: filePath) {
            print("  ✅ \(spec)")
            success += 1
        } else {
            print("  ❌ 写入失败: \(spec)")
            failure += 1
        }
    }

    print("\n📊 结果: \(success) 成功, \(failure) 失败")
    if success > 0 {
        print("\n💡 提示: 在 Xcode 中打开 Assets.xcassets，就能看到新图标了")
    }
}

main()
