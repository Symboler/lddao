import Foundation
import SwiftUI

/// 像素风对决演出：左侧影魔三连影压，右侧神灵武士掉血并阵亡。
/// 画面按 200 x 112 设计坐标绘制，自适应任意尺寸。
struct PixelDuelView: View {
    var startDate: Date
    var showsKillText: Bool = true

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            let t = elapsed.truncatingRemainder(dividingBy: PixelDuel.duration)
            ZStack {
                Canvas { context, size in
                    PixelDuel.render(&context, size: size, time: t)
                }
                if showsKillText, PixelDuel.isKillVisible(t) {
                    Text("KILL")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .tracking(4)
                        .foregroundStyle(Color(hex: "FFD65A"))
                        .shadow(color: Color(hex: "7A2418"), radius: 0, x: 2, y: 2)
                        .shadow(color: Color(hex: "FF8A3D").opacity(0.85), radius: 10)
                }
            }
        }
        .clipped()
        .allowsHitTesting(false)
    }
}

enum PixelDuel {
    static let duration: Double = 3.6
    static let designWidth: Double = 200
    static let designHeight: Double = 112
    static let nevX: Double = 46
    static let husX: Double = 148
    static let groundY: Double = 92

    struct Raze {
        let start: Double
        let hit: Double
        let targetY: Double
        let targetX: Double = 146
    }

    static let razes: [Raze] = [
        Raze(start: 0.42, hit: 0.86, targetY: 56),
        Raze(start: 1.08, hit: 1.52, targetY: 68),
        Raze(start: 1.74, hit: 2.18, targetY: 80)
    ]

    static func isKillVisible(_ t: Double) -> Bool {
        t > razes[2].hit + 0.06 && t < razes[2].hit + 1.15
    }

    // MARK: - 调色

    static let ink = Color(hex: "0B0611")
    static let ground = Color(hex: "14101C")
    static let groundLine = Color(hex: "3A2C48")
    static let shadowInk = Color(hex: "1A0E20")
    static let bodyInk = Color(hex: "241030")
    static let bodyLight = Color(hex: "321845")
    static let ember = Color(hex: "E8663A")
    static let emberLight = Color(hex: "FF8A4C")
    static let arcane = Color(hex: "8A3BE0")
    static let arcaneLight = Color(hex: "C77CFF")
    static let husBody = Color(hex: "C23A22")
    static let husLight = Color(hex: "E45A38")
    static let husDark = Color(hex: "8F1B12")
    static let husSkin = Color(hex: "E9A07A")
    static let steel = Color(hex: "B9C0C8")
    static let gold = Color(hex: "F2C14E")
    static let blood = Color(hex: "4A1410")

    // MARK: - 主渲染

    static func render(_ context: inout GraphicsContext, size: CGSize, time t: Double) {
        let scale = min(size.width / CGFloat(designWidth), size.height / CGFloat(designHeight))
        guard scale > 0 else { return }
        let offsetX = (size.width - CGFloat(designWidth) * scale) / 2
        let offsetY = (size.height - CGFloat(designHeight) * scale) / 2
        context.translateBy(x: offsetX, y: offsetY)
        context.scaleBy(x: scale, y: scale)

        drawBackground(&context)

        let charging = t < 0.42
        drawShadowFiend(&context, charging: charging)

        var hp: Double = 100
        var flash: Double = 0
        var recoil: Double = 0
        for raze in razes where t >= raze.hit {
            hp -= 34
            let age = t - raze.hit
            if age < 0.14 {
                flash = 0.85 - age / 0.14 * 0.85
                recoil = 2
            } else if age < 0.32 {
                recoil = 1
            }
        }
        hp = max(hp, 0)

        if hp > 0 {
            drawHuskar(&context, hp: hp, flash: flash, recoil: recoil)
        } else {
            let age = t - razes[2].hit
            if age < 0.12 {
                drawHuskar(&context, hp: 0, flash: 0.9, recoil: 3)
            }
            drawDeathDebris(&context, age: age)
        }

        // 三发影压
        let originX = nevX + 21
        let originY = groundY - 29
        for raze in razes {
            let progress = (t - raze.start) / (raze.hit - raze.start)
            drawBolt(&context, fromX: originX, fromY: originY,
                     toX: raze.targetX, toY: raze.targetY, progress: progress)
        }

        // 命中特效
        for raze in razes {
            let age = t - raze.hit
            if age >= 0, age <= 0.38 {
                drawImpact(&context, x: raze.targetX, y: raze.targetY, age: age)
            }
        }
    }

    // MARK: - 绘制工具

    static func px(_ context: inout GraphicsContext, _ x: Double, _ y: Double,
                   _ w: Double, _ h: Double, _ color: Color) {
        let rect = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(w), height: CGFloat(h))
        context.fill(Path(rect), with: .color(color))
    }

    // MARK: - 背景

    static func drawBackground(_ context: inout GraphicsContext) {
        px(&context, 0, 0, designWidth, designHeight, ink)
        px(&context, 0, 40, designWidth, 30, Color(hex: "130A1C"))
        let hills: [(Double, Double, Double, Double)] = [
            (10, 74, 30, 12), (40, 68, 34, 18), (78, 72, 26, 14),
            (120, 66, 36, 20), (160, 73, 30, 13), (186, 70, 16, 16)
        ]
        for hill in hills {
            px(&context, hill.0, hill.1, hill.2, hill.3, Color(hex: "170D22"))
        }
        px(&context, 0, groundY - 2, designWidth, designHeight - groundY + 2, ground)
        px(&context, 0, groundY - 2, designWidth, 1, groundLine)

        let stones: [(Double, Double)] = [
            (18, 96), (34, 102), (62, 98), (88, 104), (112, 97),
            (170, 101), (188, 96), (72, 88), (130, 90)
        ]
        for stone in stones {
            px(&context, stone.0, stone.1, 3, 2, Color(hex: "241833"))
        }
        px(&context, husX - 14, groundY - 1, 26, 1, blood)
        px(&context, 8, 58, 5, 34, Color(hex: "1E1529"))
        px(&context, 7, 56, 7, 3, Color(hex: "2A2038"))
        px(&context, 186, 54, 3, 38, Color(hex: "1E1529"))
        px(&context, 180, 58, 6, 2, Color(hex: "1E1529"))
        px(&context, 189, 62, 7, 2, Color(hex: "1E1529"))
    }

    // MARK: - 影魔

    static func drawShadowFiend(_ context: inout GraphicsContext, charging: Bool) {
        let x = nevX
        let bob: Double = charging ? -1 : 0
        let y = groundY + bob

        px(&context, x - 14, groundY - 1, 28, 2, Color.black)

        px(&context, x - 9, y - 12, 6, 12, shadowInk)
        px(&context, x + 3, y - 12, 6, 12, shadowInk)
        px(&context, x - 11, y - 2, 8, 2, Color(hex: "120818"))
        px(&context, x + 3, y - 2, 9, 2, Color(hex: "120818"))

        px(&context, x - 10, y - 32, 20, 21, bodyInk)
        px(&context, x - 10, y - 32, 20, 2, bodyLight)
        px(&context, x - 6, y - 27, 12, 2, ember)
        px(&context, x - 4, y - 24, 8, 2, Color(hex: "B84A2A"))
        px(&context, x - 7, y - 21, 14, 1, arcane)
        px(&context, x - 10, y - 13, 20, 2, Color(hex: "150A1C"))

        px(&context, x - 7, y - 45, 14, 13, shadowInk)
        px(&context, x - 7, y - 45, 14, 2, Color(hex: "2A1735"))
        px(&context, x - 9, y - 52, 3, 7, ember)
        px(&context, x - 10, y - 54, 2, 3, emberLight)
        px(&context, x + 6, y - 52, 3, 7, ember)
        px(&context, x + 8, y - 54, 2, 3, emberLight)
        px(&context, x - 5, y - 41, 3, 2, emberLight)
        px(&context, x + 2, y - 41, 3, 2, emberLight)
        px(&context, x - 2, y - 36, 4, 1, ember)

        px(&context, x + 8, y - 29, 11, 4, Color(hex: "2A1836"))
        px(&context, x + 8, y - 29, 3, 4, bodyLight)

        let palmX = x + 19
        let palmY = y - 31
        px(&context, palmX, palmY, 5, 7, shadowInk)
        if charging {
            px(&context, palmX + 2, palmY + 1, 5, 5, arcane)
            px(&context, palmX + 3, palmY + 2, 3, 3, arcaneLight)
            px(&context, palmX + 4, palmY + 3, 1, 1, .white)
            px(&context, palmX - 2, palmY - 2, 11, 11, arcane.opacity(0.25))
        }
    }

    // MARK: - 神灵武士

    static func drawHuskar(_ context: inout GraphicsContext, hp: Double, flash: Double, recoil: Double) {
        guard hp > 0 else { return }
        let x = husX - recoil
        let y = groundY

        px(&context, x - 13, groundY - 1, 26, 2, Color.black)

        px(&context, x - 6, y - 11, 5, 11, Color(hex: "7A2418"))
        px(&context, x + 2, y - 11, 5, 11, Color(hex: "7A2418"))
        px(&context, x - 8, y - 2, 7, 2, Color(hex: "5A1A10"))
        px(&context, x + 2, y - 2, 8, 2, Color(hex: "5A1A10"))

        px(&context, x - 8, y - 30, 16, 20, husBody)
        px(&context, x - 8, y - 30, 16, 2, husLight)
        px(&context, x - 8, y - 13, 16, 2, gold)
        px(&context, x - 4, y - 25, 8, 2, husDark)

        px(&context, x - 5, y - 40, 10, 10, husSkin)
        px(&context, x - 6, y - 41, 12, 3, husDark)
        px(&context, x - 6, y - 38, 2, 4, husDark)
        px(&context, x - 3, y - 36, 2, 1, Color(hex: "2A0E08"))
        px(&context, x + 1, y - 36, 2, 1, Color(hex: "2A0E08"))

        // 双斧
        for offset in [-13.0, 11.0] {
            px(&context, x + offset, y - 26, 2, 10, Color(hex: "6B4A2A"))
            px(&context, x + offset - 3, y - 30, 8, 4, steel)
            px(&context, x + offset - 4, y - 28, 2, 5, Color(hex: "8A909A"))
        }

        if flash > 0 {
            px(&context, x - 9, y - 42, 18, 32, Color.white.opacity(min(flash, 0.85)))
        }

        // 血条
        let barWidth: Double = 44
        let barX = husX - barWidth / 2 - recoil
        let barY = y - 52
        px(&context, barX - 1, barY - 1, barWidth + 2, 7, Color(hex: "0A070F"))
        px(&context, barX, barY, barWidth, 5, Color(hex: "3A1010"))
        let filled = barWidth * max(hp, 0) / 100
        px(&context, barX, barY, filled, 5, Color(hex: "E0432A"))
        px(&context, barX, barY, filled, 1, Color(hex: "FF7A50"))
    }

    // MARK: - 影压弹道

    static func drawBolt(_ context: inout GraphicsContext, fromX: Double, fromY: Double,
                         toX: Double, toY: Double, progress: Double) {
        guard progress >= 0, progress <= 1 else { return }
        let x = fromX + (toX - fromX) * progress
        let y = fromY + (toY - fromY) * progress

        // 拖尾
        for index in 1...7 {
            let p = max(progress - Double(index) * 0.055, 0)
            let tailX = fromX + (toX - fromX) * p
            let tailY = fromY + (toY - fromY) * p
            let size = max(1, 5 - Double(index))
            let alpha = 0.75 - Double(index) * 0.1
            px(&context, tailX - size / 2, tailY - size / 2, size, size, arcane.opacity(alpha))
            px(&context, tailX - size / 2 + 1, tailY - size / 2 + 1,
               size - 2, size - 2, ember.opacity(alpha * 0.7))
        }

        // 弹体
        px(&context, x - 5, y - 5, 10, 10, Color(hex: "0E0518"))
        px(&context, x - 4, y - 4, 8, 8, arcane)
        px(&context, x - 3, y - 3, 6, 6, arcaneLight)
        px(&context, x - 2, y - 2, 4, 4, ember)
        px(&context, x - 1, y - 1, 2, 2, .white)

        // 外圈像素环
        for index in 0..<12 {
            let angle = Double(index) / 12 * Double.pi * 2
            px(&context, x + cos(angle) * 9 - 1, y + sin(angle) * 9 - 1, 2, 2,
               index % 2 == 0 ? arcane : ember)
        }
    }

    // MARK: - 命中

    static func drawImpact(_ context: inout GraphicsContext, x: Double, y: Double, age: Double) {
        guard age >= 0, age <= 0.38 else { return }
        let p = age / 0.38
        let radius = 4 + p * 16

        for index in 0..<18 {
            let angle = Double(index) / 18 * Double.pi * 2
            px(&context, x + cos(angle) * radius - 1.5, y + sin(angle) * radius - 1.5, 3, 3,
               index % 3 == 0 ? Color(hex: "FFD65A") : ember)
        }
        if p < 0.45 {
            px(&context, x - 6, y - 6, 12, 12, Color.white.opacity(0.9))
        }
        for index in 0..<8 {
            let angle = Double(index) / 8 * Double.pi * 2 + 0.4
            let distance = 3 + p * 20
            px(&context, x + cos(angle) * distance, y + sin(angle) * distance, 2, 2, husBody)
        }
    }

    // MARK: - 阵亡碎块

    private static let debris: [(angle: Double, speed: Double, color: Color)] = [
        (-2.6, 26, husBody), (-2.1, 20, husDark), (-1.7, 30, husSkin),
        (-1.2, 22, steel), (-0.8, 28, husBody), (-0.4, 18, gold),
        (0.1, 24, husDark), (0.5, 20, husBody), (0.9, 26, husSkin),
        (1.3, 22, Color(hex: "7A2418")), (1.8, 18, steel), (2.4, 24, husDark)
    ]

    static func drawDeathDebris(_ context: inout GraphicsContext, age: Double) {
        guard age > 0 else { return }
        let t = min(age, 1.4)
        for (index, piece) in debris.enumerated() {
            let velocityX = cos(piece.angle) * piece.speed
            let velocityY = sin(piece.angle) * piece.speed - 22
            let x = husX + velocityX * t
            let y = groundY - 20 + velocityY * t + 34 * t * t
            let size = index % 3 == 0 ? 3.0 : 2.0
            if y < groundY + 2 {
                px(&context, x, y, size, size, piece.color)
            }
        }
        if t > 0.6 {
            px(&context, husX - 16, groundY, 32, 2, blood)
        }
    }
}
