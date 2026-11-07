import SwiftUI
import Foundation

// MARK: - 第四幕 · 像素跑酷 / 结算

extension CodeGenScene {
    static let gameW: Double = 128
    static let gameH: Double = 48
    static let groundY: Double = 40
    static let gameScale: Double = 2.12
    static let gameOX: Double = (372 - 128 * 2.12) / 2
    static let gameOY: Double = 24

    /// 关卡时间轴（gt 为进入第四幕后的秒数）
    static func charState(_ gt: Double) -> (x: Double, y: Double) {
        var x = 10.0
        var y = 0.0
        if gt < 0.4 {
            x = 10
        } else if gt < 1.6 {
            x = 10 + (gt - 0.4) / 1.2 * 10
        } else if gt < 2.3 {
            let p = (gt - 1.6) / 0.7
            x = 20 + p * 8
            y = sin(p * .pi) * 13
        } else if gt < 3.0 {
            x = 28 + (gt - 2.3) / 0.7 * 6
        } else if gt < 3.4 {
            let p = (gt - 3.0) / 0.4
            x = 34 + p * 2
            y = sin(min(p * 1.7, .pi)) * 6
        } else if gt < 4.2 {
            x = 36 + (gt - 3.4) / 0.8 * 8
        } else if gt < 5.6 {
            let p = (gt - 4.2) / 1.4
            x = 44 + p * 16
            y = sin(p * .pi) * 15
        } else if gt < 6.6 {
            x = 60 + (gt - 5.6) / 1.0 * 30
        } else if gt < 7.0 {
            let p = (gt - 6.6) / 0.4
            x = 90 + p * 14
            y = sin(p * .pi) * 11
        } else {
            x = 104
        }
        return (x, y)
    }

    /// 裂解转场时露出的第一帧
    static func gameFrame(_ ctx: inout GraphicsContext, gt: Double) {
        var inner = ctx
        inner.translateBy(x: CGFloat(gameOX), y: CGFloat(gameOY))
        inner.scaleBy(x: CGFloat(gameScale), y: CGFloat(gameScale))

        PX.rect(&inner, 0, 0, gameW, gameH, SceneCol.sky)
        PX.rect(&inner, 0, groundY, gameW, gameH - groundY, SceneCol.ground)
        PX.rect(&inner, 0, groundY, gameW, 2, SceneCol.grass)
        Clawd.draw(&inner, x: 10, y: groundY - 6, u: 0.5, legPhase: 0)
    }

    static func worldBlock(_ ctx: inout GraphicsContext, x: Double, y: Double,
                           label: String?, dark: Bool) {
        let s = 8.0
        PX.rect(&ctx, x, y, s, s, SceneCol.ink)
        PX.rect(&ctx, x + 1, y + 1, s - 2, s - 2, dark ? SceneCol.brickDk : SceneCol.brick)
        PX.rect(&ctx, x + 1, y + 1, s - 2, 1.5, dark ? Color(hex: "D48A6E") : Color(hex: "FFE08A"))
        if let label {
            PX.text(&ctx, label, x: x + s / 2, y: y + 1.6, size: 4.2, weight: .bold,
                    color: SceneCol.ink, mono: true, anchor: .top)
        }
    }

    static func game(_ ctx: inout GraphicsContext, t: Double) {
        let gt = t - CodeT.shatterEnd
        let sc = gameScale, W = gameW, H = gameH
        let st = charState(gt)
        let cam = clamp(st.x - 40, 0, 60)
        let shake: Double = ((gt > 3.4 && gt < 3.82) || (gt > 2.95 && gt < 3.1))
            ? sin(gt * 90) * 1.0 : 0

        var inner = ctx
        inner.translateBy(x: CGFloat(gameOX + shake), y: CGFloat(gameOY + shake))
        inner.scaleBy(x: CGFloat(sc), y: CGFloat(sc))

        // 天空
        PX.rect(&inner, 0, 0, W, H, SceneCol.sky)

        // 视差远山
        let hillOff = -(cam * 0.35).truncatingRemainder(dividingBy: 64)
        for i in -1..<3 {
            let hx = Double(i) * 64 + hillOff
            PX.rect(&inner, hx + 8, groundY - 10, 26, 10, Color(hex: "3F7FDB"))
            PX.rect(&inner, hx + 4, groundY - 6, 34, 6, Color(hex: "3F7FDB"))
        }

        // 云
        let cloudOff = -(cam * 0.18).truncatingRemainder(dividingBy: 80)
        for i in 0..<3 {
            let cx = Double(i) * 80 + cloudOff + 10
            PX.rect(&inner, cx, 8, 14, 3, Color(hex: "E8F4FF"))
            PX.rect(&inner, cx + 3, 5, 8, 3, Color(hex: "E8F4FF"))
        }

        // 地面
        PX.rect(&inner, 0, groundY, W, H - groundY, SceneCol.ground)
        PX.rect(&inner, 0, groundY, W, 1.5, SceneCol.grass)
        var bx = -8.0
        while bx < W + 8 {
            let wx = bx - cam.truncatingRemainder(dividingBy: 8)
            PX.rect(&inner, wx, groundY + 2, 7, 1, Color(hex: "6E4521"))
            bx += 8
        }

        // BUG / undefined 砖块
        let blocks: [(x: Double, y: Double, label: String, dark: Bool, hit: Bool)] = [
            (20, 28, "BUG", false, gt > 1.95 && gt < 2.35),
            (44, 28, "undef", true, gt > 3.4 && gt < 4.0)
        ]
        for b in blocks {
            let dx = b.x - cam
            if dx > -10 && dx < W + 10 {
                worldBlock(&inner, x: dx, y: b.y + (b.hit ? -2 : 0), label: b.label, dark: b.dark)
            }
        }

        // PROD 金币
        if gt > 1.85 && gt < 3.2 {
            let p = clamp((gt - 1.85) / 0.5)
            let cy = 24 - p * 14
            let cx = 24 - cam
            PX.rect(&inner, cx, cy, 6, 6, SceneCol.ink)
            PX.rect(&inner, cx + 1, cy + 1, 4, 4, SceneCol.brick)
            PX.text(&inner, "PROD", x: cx + 3, y: cy + 1.2, size: 3.4, weight: .bold,
                    color: Color(hex: "1A1006"), mono: true, anchor: .top)
        }

        // 小 bug 怪
        if gt > 2.35 && gt < 3.5 {
            let p = clamp((gt - 2.35) / 1.15)
            let dx = lerp(52, 38, p) - cam
            let by = groundY - 5
            if gt > 3.0 {
                PX.rect(&inner, dx, by + 3, 7, 2, Color(hex: "7A3B2A"))
                PX.rect(&inner, dx - 1, by + 4, 9, 1.4, SceneCol.ink)
            } else {
                PX.rect(&inner, dx, by, 6, 5, Color(hex: "7A3B2A"))
                PX.rect(&inner, dx + 1, by + 1, 1.5, 1.5, SceneCol.red)
                PX.rect(&inner, dx + 4, by + 1, 1.5, 1.5, SceneCol.red)
                PX.rect(&inner, dx - 1, by + 3, 1.5, 2, SceneCol.ink)
                PX.rect(&inner, dx + 5.5, by + 3, 1.5, 2, SceneCol.ink)
            }
        }

        // 半旗
        let fx = 104 - cam
        if fx < W + 6 {
            PX.rect(&inner, fx, groundY - 22, 1.5, 22, Color(hex: "E8E8E8"))
            let flagDown: Double = gt > 6.9 ? 10 : 2
            PX.rect(&inner, fx + 2, groundY - 22 + flagDown, 7, 5, SceneCol.red)
        }

        // 主角
        let cx = st.x - cam
        let cy = groundY - 7 - st.y
        Clawd.draw(&inner, x: cx - 1, y: cy, u: 0.5,
                   legPhase: gt * 14, blink: false,
                   armUp: st.y > 0 ? 0.8 : 0.2)
        // 安全帽
        PX.rect(&inner, cx - 1.5, cy - 2.5, 8, 2.5, SceneCol.brick)
        PX.rect(&inner, cx - 2.5, cy - 0.6, 10, 1, Color(hex: "D9A62E"))

        if gt > 3.4 && gt < 3.9 {
            PX.text(&inner, "!", x: cx + 2, y: cy - 6, size: 4, weight: .bold,
                    color: .white.opacity(0.7), mono: true, anchor: .top)
        }

        // 顶栏 / 进度
        PX.text(&ctx, "PREVIEW · game.js", x: 12, y: 8, size: 9, weight: .semibold,
                color: Color.white.opacity(0.7), mono: true)
        PX.text(&ctx, "60 fps", x: 360, y: 9, size: 8, weight: .regular,
                color: Color.white.opacity(0.35), mono: true, anchor: .topTrailing)

        let prog = clamp((gt - 0.4) / 7.1)
        PX.rect(&ctx, 12, 118, 348, 3, Color(hex: "1C1D21"))
        PX.rect(&ctx, 12, 118, 348 * prog, 3, SceneCol.orange)
        PX.text(&ctx, "\(Int(prog * 100))%", x: 12, y: 106, size: 8,
                weight: .semibold, color: Color.white.opacity(0.5), mono: true)

        // 上电扫描线
        if gt < 0.4 {
            let p = gt / 0.4
            PX.rect(&ctx, 0, 0, 372, 132, Color.black.opacity(1 - p * 0.9))
            PX.rect(&ctx, 0, 24 + (1 - p) * 102, 372, 2, Color.white.opacity(0.25))
        }

        // 飘字
        let popups: [(t0: Double, txt: String, x: Double, y: Double)] = [
            (2.0, "+PROD", 24, 22),
            (3.05, "+1 XP", 34, 30),
            (3.5, "undefined!", 44, 24)
        ]
        for p in popups {
            let age = gt - p.t0
            if age > 0 && age < 1.1 {
                var inner2 = ctx
                inner2.opacity = 1 - age / 1.1
                PX.text(&inner2, p.txt,
                        x: gameOX + (p.x - cam) * sc,
                        y: gameOY + (p.y - age * 12) * sc,
                        size: 9, weight: .bold, color: Color(hex: "FFE08A"), mono: true)
            }
        }
    }

    // MARK: 结算

    static func result(_ ctx: inout GraphicsContext, t: Double) {
        let p = clamp((t - CodeT.gameEnd) / 0.9)

        var base = ctx
        game(&base, t: CodeT.gameEnd - 0.02)

        PX.rect(&ctx, 0, 0, 372, 132, Color(hex: "06060A").opacity(0.55 + p * 0.3))

        let n1 = Int(clamp(p * 2) * Double("COMPILE OK".count))
        let n2 = Int(clamp(p * 2 - 1) * Double("LOCAL ONLY".count))
        PX.text(&ctx, String("COMPILE OK".prefix(n1)), x: 186, y: 42,
                size: 22, weight: .heavy, color: SceneCol.brick, mono: true, anchor: .top)
        PX.text(&ctx, String("LOCAL ONLY".prefix(n2)), x: 186, y: 72,
                size: 18, weight: .heavy, color: SceneCol.orange, mono: true, anchor: .top)

        if p > 0.7 {
            PX.text(&ctx, "Deploy 成功 · 其实只是本地能跑", x: 186, y: 104,
                    size: 9, weight: .regular, color: Color.white.opacity(0.42), anchor: .top)
        }
    }
}
