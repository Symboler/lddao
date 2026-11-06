import SwiftUI
import UIKit

/// 圆形英雄头像，用于灵动岛紧凑态与列表。
struct HeroToken: View {
    let hero: DotaHero
    var size: CGFloat

    var body: some View {
        Group {
            if let image = UIImage(named: hero.iconAsset) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                HeroSigil(hero: hero, compact: true)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(hero.accent.opacity(0.85), lineWidth: 0.8))
        .shadow(color: hero.accent.opacity(0.55), radius: size * 0.18)
    }
}

/// 无素材时使用的抽象英雄徽记。
struct HeroSigil: View {
    let hero: DotaHero
    var compact: Bool = false

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                RadialGradient(
                    colors: [hero.accent.opacity(0.9), hero.glow.opacity(0.45), Color(hex: "0B0611")],
                    center: .center,
                    startRadius: 0,
                    endRadius: max(side * 0.7, 1)
                )
                ForEach(0..<(compact ? 2 : 3), id: \.self) { index in
                    Circle()
                        .stroke(hero.accent.opacity(0.26), lineWidth: max(side * 0.02, 0.6))
                        .frame(
                            width: side * (0.42 + CGFloat(index) * 0.2),
                            height: side * (0.42 + CGFloat(index) * 0.2)
                        )
                        .rotation3DEffect(.degrees(64), axis: (x: 1, y: 0.25, z: 0))
                }
                Circle()
                    .fill(hero.accent.opacity(0.9))
                    .frame(width: side * 0.16, height: side * 0.16)
                    .blur(radius: max(side * 0.02, 0.4))
            }
        }
        .clipped()
    }
}

/// 技能充能条
struct RageBar: View {
    var progress: Double
    var accent: Color
    var height: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [accent.opacity(0.7), accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(proxy.size.width * CGFloat(min(max(progress, 0), 1)), 0))
            }
        }
        .frame(height: height)
    }
}
