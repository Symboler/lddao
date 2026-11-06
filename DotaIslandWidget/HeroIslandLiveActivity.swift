import ActivityKit
import SwiftUI
import WidgetKit

@main
struct DotaIslandWidgetBundle: WidgetBundle {
    var body: some Widget {
        HeroIslandLiveActivity()
    }
}

struct HeroIslandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HeroIslandAttributes.self) { context in
            LockScreenHeroCard(context: context)
                .activityBackgroundTint(Color(hex: "0A070F"))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            let hero = HeroCatalog.hero(id: context.attributes.heroID)
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        HeroToken(hero: hero, size: 26)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(hero.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                            Text(hero.englishName.uppercased())
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(context.state.soulCount)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(hero.accent)
                            .contentTransition(.numericText())
                        Text("SOULS")
                            .font(.system(size: 8, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedHeroStage(context: context, hero: hero)
                }
            } compactLeading: {
                HeroToken(hero: hero, size: 19)
            } compactTrailing: {
                Text("\(context.state.soulCount)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(hero.accent)
                    .contentTransition(.numericText())
                    .frame(width: 24)
            } minimal: {
                HeroToken(hero: hero, size: 17)
            }
            .keylineTint(hero.accent)
        }
    }
}

// MARK: - 灵动岛展开区

struct ExpandedHeroStage: View {
    let context: ActivityViewContext<HeroIslandAttributes>
    let hero: DotaHero

    var body: some View {
        ZStack(alignment: .bottom) {
            HeroArtworkView(hero: hero)
                .frame(maxWidth: .infinity)
                .frame(height: 82)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.4),
                            .init(color: .black, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            SoulFlameView(
                accent: hero.accent,
                glow: hero.glow,
                intensity: 1.0,
                particleCount: 10
            )
            .frame(height: 84)
            .opacity(0.9)

            VStack(spacing: 5) {
                HStack(spacing: 6) {
                    Text(context.state.headline)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(hero.accent)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text("\(Int(context.state.rage * 100))%")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                }
                RageBar(progress: context.state.rage, accent: hero.accent, height: 3)
            }
            .padding(.horizontal, 2)
        }
        .frame(height: 88)
        .padding(.bottom, 2)
    }
}

// MARK: - 锁屏卡片

struct LockScreenHeroCard: View {
    let context: ActivityViewContext<HeroIslandAttributes>

    var body: some View {
        let hero = HeroCatalog.hero(id: context.attributes.heroID)
        ZStack(alignment: .leading) {
            HeroArtworkView(hero: hero)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .frame(height: 134)
                .mask(
                    LinearGradient(
                        colors: [.clear, .black, .black],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            SoulFlameView(accent: hero.accent, glow: hero.glow, intensity: 0.85, particleCount: 12)
                .frame(height: 134)
                .opacity(0.85)

            VStack(alignment: .leading, spacing: 3) {
                Text(hero.englishName.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(hero.accent)
                Text(hero.name)
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(.white)
                Text(context.attributes.skillName)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1)

                HStack(spacing: 5) {
                    Text("\(context.state.soulCount)")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(hero.accent)
                        .contentTransition(.numericText())
                    Text("SOULS")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .padding(.top, 4)

                RageBar(progress: context.state.rage, accent: hero.accent, height: 3)
                    .frame(width: 104)
            }
            .padding(.leading, 16)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 134)
        .background(Color(hex: "0A070F"))
    }
}
