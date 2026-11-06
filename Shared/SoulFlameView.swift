import SwiftUI

/// 由时间轴驱动的魂火粒子特效，纯 Canvas 绘制，无外部素材依赖。
struct SoulFlameView: View {
    var accent: Color
    var glow: Color
    var intensity: Double
    var particleCount: Int
    var animated: Bool

    init(
        accent: Color,
        glow: Color,
        intensity: Double = 1.0,
        particleCount: Int = 14,
        animated: Bool = true
    ) {
        self.accent = accent
        self.glow = glow
        self.intensity = intensity
        self.particleCount = particleCount
        self.animated = animated
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !animated)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                draw(&context, size: size, time: time)
            }
        }
        .allowsHitTesting(false)
    }

    private func draw(_ context: inout GraphicsContext, size: CGSize, time: Double) {
        guard size.width > 1, size.height > 1 else { return }
        let w = size.width
        let h = size.height

        // 底部上升辉光
        let glowRect = CGRect(x: 0, y: h * 0.55, width: w, height: h * 0.45)
        context.fill(
            Path(glowRect),
            with: .linearGradient(
                Gradient(colors: [accent.opacity(0.30 * intensity), .clear]),
                startPoint: CGPoint(x: w / 2, y: glowRect.maxY),
                endPoint: CGPoint(x: w / 2, y: glowRect.minY)
            )
        )

        let count = max(particleCount, 6)
        for index in 0..<count {
            let seed = Double(index) / Double(count)
            let speed = 0.45 + Double((index * 53) % 29) / 45.0
            let progress = (time * speed + seed).truncatingRemainder(dividingBy: 1.0)

            // 上升过程中的左右摆动，越接近顶部摆动越小
            let sway = sin(time * 1.9 + Double(index) * 1.3) * 0.05 * (1.0 - progress)
            let x = w * CGFloat(0.08 + 0.84 * seed + sway)
            let y = h * 0.98 - h * CGFloat(0.82 * progress)
            let radius = w * CGFloat(0.028 + 0.052 * (1.0 - progress)) * CGFloat(intensity)
            let alpha = (1.0 - progress) * 0.9 * intensity

            let center = CGPoint(x: x, y: y)
            let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
            context.fill(
                Path(ellipseIn: rect),
                with: .radialGradient(
                    Gradient(colors: [accent.opacity(alpha), glow.opacity(alpha * 0.7), .clear]),
                    center: center,
                    startRadius: 0,
                    endRadius: radius
                )
            )
        }
    }
}
