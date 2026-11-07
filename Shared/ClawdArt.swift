import SwiftUI
import Foundation

/// Claw'd：16 × 12 单位的像素螃蟹。
enum Clawd {
    static let ink = Color(hex: "120A06")
    static let orange = Color(hex: "D97757")
    static let orangeLt = Color(hex: "F0A081")
    static let cream = Color(hex: "FFF3E6")

    /// x/y 为 16×12 网格左上角，u 为一个设计单位的边长。
    static func draw(_ ctx: inout GraphicsContext,
                     x: Double, y: Double, u s: Double,
                     face: Double = 1, bob: Double = 0, blink: Bool = false,
                     legPhase: Double = 0, armUp: Double = 0) {
        // 四条小短腿（正弦摆动）
        for i in 0..<4 {
            let off = sin(legPhase + Double(i) * 1.1) * 0.35
            PX.rect(&ctx,
                    x + (4.2 + Double(i) * 2.1) * s + off * s,
                    y + 9 * s,
                    0.9 * s,
                    (1.9 + abs(off) * 0.6) * s,
                    ink)
        }

        let clawY = 2.2 - armUp

        // 左蟹钳
        PX.rect(&ctx, x - 0.4 * s, y + clawY * s + bob * s, 3.4 * s, 4.2 * s, ink)
        PX.rect(&ctx, x + 0.3 * s, y + (clawY + 0.5) * s + bob * s, 2.2 * s, 3.1 * s, orange)
        PX.rect(&ctx, x + 1.2 * s, y + (clawY + 1.6) * s + bob * s, 1.6 * s, 0.6 * s, ink)

        // 右蟹钳
        PX.rect(&ctx, x + 13 * s, y + clawY * s + bob * s, 3.4 * s, 4.2 * s, ink)
        PX.rect(&ctx, x + 13.5 * s, y + (clawY + 0.5) * s + bob * s, 2.2 * s, 3.1 * s, orange)
        PX.rect(&ctx, x + 13.4 * s, y + (clawY + 1.6) * s + bob * s, 1.6 * s, 0.6 * s, ink)

        // 身体
        PX.rect(&ctx, x + 2.7 * s, y + (3.8 + bob) * s, 10.6 * s, 5.4 * s, ink)
        PX.rect(&ctx, x + 3.3 * s, y + (4.4 + bob) * s, 9.4 * s, 4.2 * s, orange)
        // 高光
        PX.rect(&ctx, x + 3.7 * s, y + (4.7 + bob) * s, 3.8 * s, 0.8 * s, orangeLt)

        // 眼睛
        PX.rect(&ctx, x + 5.1 * s, y + (4.0 + bob) * s, 2.2 * s, 2.2 * s, cream)
        PX.rect(&ctx, x + 8.9 * s, y + (4.0 + bob) * s, 2.2 * s, 2.2 * s, cream)
        if blink {
            PX.rect(&ctx, x + 5.1 * s, y + (5.0 + bob) * s, 2.2 * s, 0.9 * s, ink)
            PX.rect(&ctx, x + 8.9 * s, y + (5.0 + bob) * s, 2.2 * s, 0.9 * s, ink)
        } else {
            let shift: Double = face > 0 ? 0.5 : 0
            PX.rect(&ctx, x + (5.6 + shift) * s, y + (4.8 + bob) * s, 0.8 * s, 1.1 * s, ink)
            PX.rect(&ctx, x + (9.4 + shift) * s, y + (4.8 + bob) * s, 0.8 * s, 1.1 * s, ink)
        }
    }
}
