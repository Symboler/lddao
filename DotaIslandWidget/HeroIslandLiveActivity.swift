import ActivityKit
import SwiftUI
import WidgetKit

@main
struct DotaIslandWidgetBundle: WidgetBundle {
    var body: some Widget {
        CodeGenIslandLiveActivity()
    }
}

struct CodeGenIslandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CodeGenIslandAttributes.self) { context in
            LockScreenCard(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedCode(context: context)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 2)
                }
            } compactLeading: {
                CompactLeading(context: context)
                    .frame(width: 46, height: 33)
            } compactTrailing: {
                CompactTrailing(context: context)
            } minimal: {
                MinimalBadge(context: context)
                    .frame(width: 22, height: 22)
            }
            .keylineTint(SceneCol.orange)
        }
    }
}

// MARK: - 紧凑态

struct CompactLeading: View {
    let context: ActivityViewContext<CodeGenIslandAttributes>

    var body: some View {
        TimelineView(.periodic(from: context.state.startDate, by: 0.25)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(context.state.startDate)
            Canvas { ctx, size in
                CodeGenScene.badge(&ctx, size: size, t: elapsed)
            }
        }
        .clipped()
        .allowsHitTesting(false)
    }
}

struct CompactTrailing: View {
    let context: ActivityViewContext<CodeGenIslandAttributes>

    var body: some View {
        TimelineView(.periodic(from: context.state.startDate, by: 0.25)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(context.state.startDate)
            VStack(alignment: .trailing, spacing: 1) {
                Text(context.state.status)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(SceneCol.orange.opacity(0.35 + 0.5 * (0.5 + 0.5 * sin(elapsed * 4 - Double(i) * 0.9))))
                            .frame(width: 2.5, height: 2.5)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct MinimalBadge: View {
    let context: ActivityViewContext<CodeGenIslandAttributes>

    var body: some View {
        TimelineView(.periodic(from: context.state.startDate, by: 0.5)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(context.state.startDate)
            Canvas { ctx, size in
                CodeGenScene.badge(&ctx, size: size, t: elapsed)
            }
        }
        .clipped()
        .allowsHitTesting(false)
    }
}

// MARK: - 展开态

struct ExpandedCode: View {
    let context: ActivityViewContext<CodeGenIslandAttributes>

    var body: some View {
        TimelineView(.periodic(from: context.state.startDate, by: 0.2)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(context.state.startDate)
            let t = elapsed.truncatingRemainder(dividingBy: CodeT.total)
            Canvas { ctx, size in
                CodeGenScene.expanded(&ctx, size: size, t: t)
            }
            .frame(height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .frame(height: 96)
    }
}

// MARK: - 锁屏卡片

struct LockScreenCard: View {
    let context: ActivityViewContext<CodeGenIslandAttributes>

    var body: some View {
        TimelineView(.periodic(from: context.state.startDate, by: 0.2)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(context.state.startDate)
            let t = elapsed.truncatingRemainder(dividingBy: CodeT.total)

            VStack(spacing: 0) {
                Canvas { ctx, size in
                    CodeGenScene.expanded(&ctx, size: size, t: t)
                }
                .frame(height: 118)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                HStack(spacing: 8) {
                    Text(context.state.status)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(SceneCol.orange)
                    Text(context.state.taskName)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer(minLength: 6)
                    Text("Claw'd")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
            }
            .frame(maxWidth: .infinity)
            .background(Color.black)
        }
    }
}
