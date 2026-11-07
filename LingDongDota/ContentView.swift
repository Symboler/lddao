import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var start = Date()
    @State private var frozenT: Double? = nil
    @State private var activity: Activity<CodeGenIslandAttributes>?
    @State private var errorMessage: String?

    private var isRunning: Bool { activity != nil }

    private let acts: [(label: String, t: Double)] = [
        ("① 巡逻", 0),
        ("② 打字", 3.1),
        ("③ 像素化", 7.7),
        ("④ 跑酷", 8.2),
        ("⑤ 收起", 16.7)
    ]

    var body: some View {
        ZStack {
            backdrop
            ScrollView {
                VStack(spacing: 18) {
                    header
                    stage
                    controls
                    actionButton
                    hint
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - 背景

    private var backdrop: some View {
        ZStack {
            Color(hex: "08070A").ignoresSafeArea()
            RadialGradient(
                colors: [SceneCol.orange.opacity(0.22), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - 头部

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("OCTO ISLAND")
                .font(.system(size: 10, weight: .bold))
                .tracking(2.4)
                .foregroundStyle(SceneCol.orange)
            Text("灵动岛 · 代码生成动效")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text("Claw'd 巡逻 · 展开打字 · 像素化 · 跑酷 · 收起")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 真实尺寸舞台

    private var stage: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let t = currentT(timeline.date)
            let sz = CodeGenScene.liveSize(t)

            ZStack {
                RoundedRectangle(cornerRadius: CGFloat(sz.r), style: .continuous)
                    .fill(Color.black)
                    .frame(width: CGFloat(sz.w), height: CGFloat(sz.h))
                    .overlay(
                        RoundedRectangle(cornerRadius: CGFloat(sz.r), style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )

                islandContent(t: t)
                    .frame(width: CGFloat(sz.w), height: CGFloat(sz.h))
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(sz.r), style: .continuous))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 156)
        }
    }

    @ViewBuilder
    private func islandContent(t: Double) -> some View {
        if t < CodeT.patrol || t >= CodeT.collapseEnd {
            if t >= CodeT.collapseEnd {
                Canvas { ctx, size in
                    CodeGenScene.compactAfter(&ctx, size: size, t: t)
                }
            } else {
                Canvas { ctx, size in
                    CodeGenScene.compact(&ctx, size: size, t: t)
                }
            }
        } else {
            Canvas { ctx, size in
                CodeGenScene.expanded(&ctx, size: size, t: t)
            }
            .opacity(expandedAlpha(t))
            .scaleEffect(expandedScale(t))
        }
    }

    private func expandedAlpha(_ t: Double) -> Double {
        if t < CodeT.patrol + 0.35 {
            return clamp((t - (CodeT.patrol + 0.03)) / 0.2)
        }
        if t > CodeT.resultEnd {
            return clamp(1 - (t - CodeT.resultEnd) / (CodeT.collapseEnd - CodeT.resultEnd))
        }
        return 1
    }

    private func expandedScale(_ t: Double) -> Double {
        if t < CodeT.patrol + 0.35 {
            let a = clamp((t - (CodeT.patrol + 0.03)) / 0.2)
            return lerp(0.92, 1, a)
        }
        if t > CodeT.resultEnd {
            let q = clamp((t - CodeT.resultEnd) / (CodeT.collapseEnd - CodeT.resultEnd))
            return lerp(1, 0.6, q)
        }
        return 1
    }

    // MARK: - 控制

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    replay()
                } label: {
                    Label("重播", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    togglePlay()
                } label: {
                    Label(frozenT == nil ? "暂停" : "播放",
                          systemImage: frozenT == nil ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(SceneCol.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(SceneCol.orange.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 6) {
                ForEach(0..<acts.count, id: \.self) { index in
                    Button {
                        jump(to: acts[index].t)
                    } label: {
                        Text(acts[index].label)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 开关灵动岛

    private var actionButton: some View {
        Button {
            Task {
                if isRunning { await stop() } else { await start() }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isRunning ? "stop.fill" : "bolt.fill")
                Text(isRunning ? "结束灵动岛" : "开启灵动岛")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(isRunning ? .white : Color(hex: "150A05"))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: isRunning
                        ? [Color.white.opacity(0.12), Color.white.opacity(0.06)]
                        : [Color(hex: "F0A081"), SceneCol.orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var hint: some View {
        VStack(spacing: 6) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "FF7A70"))
                    .multilineTextAlignment(.center)
            }
            Text("上面是 iPhone 真实尺寸。真机灵动岛由系统渲染，刷新频率受限，动起来会比这里更卡一些；展开后点一下岛外即可收起。")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 2)
    }

    // MARK: - 时间

    private func currentT(_ date: Date) -> Double {
        let raw = frozenT ?? date.timeIntervalSince(start)
        return max(0, raw).truncatingRemainder(dividingBy: CodeT.total)
    }

    private func replay() {
        start = Date()
        frozenT = nil
    }

    private func togglePlay() {
        if let f = frozenT {
            start = Date().addingTimeInterval(-f)
            frozenT = nil
        } else {
            frozenT = currentT(Date())
        }
    }

    private func jump(to t: Double) {
        start = Date().addingTimeInterval(-t)
        frozenT = nil
    }

    // MARK: - Live Activity

    @MainActor
    private func start() async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            errorMessage = "系统未开启实时活动：设置 > 灵动岛Dota > 实时活动 > 允许"
            return
        }
        await stop()

        let attributes = CodeGenIslandAttributes(accentHex: "D97757")
        let state = CodeGenIslandAttributes.ContentState(
            startDate: Date(),
            taskName: "game.js",
            status: "代码生成中"
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
            errorMessage = nil
        } catch {
            activity = nil
            errorMessage = "开启失败：\(error.localizedDescription)"
        }
    }

    @MainActor
    private func stop() async {
        guard let current = activity else { return }
        activity = nil
        await current.end(nil, dismissalPolicy: .immediate)
    }
}

#Preview {
    ContentView()
}
