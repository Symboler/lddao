import SwiftUI
import Foundation

extension Color {
    /// 解析 "RRGGBB" 形式的颜色字符串，解析失败时回退到白色。
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        guard cleaned.count == 6 else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
            return
        }
        self.init(
            .sRGB,
            red: Double((value & 0xFF0000) >> 16) / 255.0,
            green: Double((value & 0x00FF00) >> 8) / 255.0,
            blue: Double(value & 0x0000FF) / 255.0,
            opacity: 1
        )
    }
}

/// 像素画布工具：设计坐标系（1 单位 = 1 pt），整数矩形 + 等宽文字。
enum PX {
    /// 按比例居中铺满可用区域，返回缩放比。
    @discardableResult
    static func fit(_ ctx: inout GraphicsContext, size: CGSize, design: CGSize) -> Double {
        let sw = Double(size.width), sh = Double(size.height)
        let s = min(sw / Double(design.width), sh / Double(design.height))
        let ox = (sw - Double(design.width) * s) / 2
        let oy = (sh - Double(design.height) * s) / 2
        ctx.translateBy(x: CGFloat(ox), y: CGFloat(oy))
        ctx.scaleBy(x: CGFloat(s), y: CGFloat(s))
        return s
    }

    static func rect(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double,
                     _ w: Double, _ h: Double, _ color: Color) {
        let r = CGRect(x: CGFloat(x), y: CGFloat(y),
                       width: CGFloat(max(w, 0.4)), height: CGFloat(max(h, 0.4)))
        ctx.fill(Path(r), with: .color(color))
    }

    static func circle(_ ctx: inout GraphicsContext, _ cx: Double, _ cy: Double,
                       _ r: Double, _ color: Color) {
        let box = CGRect(x: CGFloat(cx - r), y: CGFloat(cy - r),
                         width: CGFloat(r * 2), height: CGFloat(r * 2))
        ctx.fill(Path(ellipseIn: box), with: .color(color))
    }

    /// 文字绘制。y 为文字顶部（top-leading / top / top-trailing 锚点）。
    static func text(_ ctx: inout GraphicsContext, _ str: String,
                     x: Double, y: Double, size: Double,
                     weight: Font.Weight = .semibold,
                     color: Color = .white,
                     mono: Bool = false,
                     anchor: UnitPoint = .topLeading) {
        let font: Font = mono
            ? .system(size: CGFloat(size), weight: weight, design: .monospaced)
            : .system(size: CGFloat(size), weight: weight)
        ctx.draw(Text(str).font(font).foregroundColor(color),
                 at: CGPoint(x: CGFloat(x), y: CGFloat(y)), anchor: anchor)
    }
}
