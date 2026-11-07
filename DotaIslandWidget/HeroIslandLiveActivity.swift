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
            LockScreenParade(context: context)
                .activityBackgroundTint(Color(hex: "0A070F"))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedParade(context: context)
                }
            } compactLeading: {
                MarchingView(selectedIDs: context.state.selectedIDs,
                             startDate: context.state.walkStart, limit: 2)
                .frame(width: 40, height: 34)
            } compactTrailing: {
                VStack(spacing: 0) {
                    Text("\(context.state.selectedIDs.count)")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(hex: context.attributes.accentHex))
                        .contentTransition(.numericText())
                    Text("HEROES")
                        .font(.system(size: 7, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.45))
                }
            } minimal: {
                Text("\(context.state.selectedIDs.count)")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: context.attributes.accentHex))
            }
            .keylineTint(Color(hex: context.attributes.accentHex))
        }
    }
}

// MARK: - 灵动岛展开区

struct ExpandedParade: View {
    let context: ActivityViewContext<HeroIslandAttributes>

    var body: some View {
        VStack(spacing: 4) {
            ParadeView(selectedIDs: context.state.selectedIDs,
                       startDate: context.state.walkStart)
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 6) {
                Text("DOTA PARADE")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color(hex: context.attributes.accentHex))
                Text("\(context.state.selectedIDs.count) HEROES")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
                Spacer(minLength: 4)
                Text(context.state.headline)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 2)
        }
        .frame(height: 100)
        .padding(.bottom, 2)
    }
}

// MARK: - 锁屏卡片

struct LockScreenParade: View {
    let context: ActivityViewContext<HeroIslandAttributes>

    var body: some View {
        VStack(spacing: 0) {
            ParadeView(selectedIDs: context.state.selectedIDs,
                       startDate: context.state.walkStart)
                .frame(height: 90)
                .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                Text("DOTA PARADE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: context.attributes.accentHex))
                Text("\(context.state.selectedIDs.count) HEROES")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                Spacer(minLength: 6)
                Text(context.state.headline)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "0A070F"))
    }
}
