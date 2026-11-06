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
                    ExpandedHeroStage(context: context)
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

    var body: some View {
        VStack(spacing: 4) {
            PixelDuelView(startDate: context.state.battleStart)
                .frame(height: 96)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 6) {
                Text("SHADOW FIEND")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color(hex: "E8663A"))
                Text("×3 影压")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
                Spacer(minLength: 4)
                Text("\(context.state.soulCount)")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "E8663A"))
                    .contentTransition(.numericText())
                RageBar(progress: context.state.rage, accent: Color(hex: "E8663A"), height: 2)
                    .frame(width: 48)
            }
            .padding(.horizontal, 2)
        }
        .frame(height: 112)
        .padding(.bottom, 2)
    }
}

// MARK: - 锁屏卡片

struct LockScreenHeroCard: View {
    let context: ActivityViewContext<HeroIslandAttributes>

    var body: some View {
        VStack(spacing: 0) {
            PixelDuelView(startDate: context.state.battleStart)
                .frame(height: 112)
                .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                Text("SHADOW FIEND")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: "E8663A"))
                Text("三连影压")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                Spacer(minLength: 6)
                Text("\(context.state.soulCount) SOULS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.55))
                    .contentTransition(.numericText())
                Text("\(Int(context.state.rage * 100))%")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "E8663A"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "0A070F"))
    }
}
