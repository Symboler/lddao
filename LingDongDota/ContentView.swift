import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var selectedHero: DotaHero = HeroCatalog.all[0]
    @State private var activity: Activity<HeroIslandAttributes>?
    @State private var souls: Int = 0
    @State private var rage: Double = 0.35
    @State private var ticker: Task<Void, Never>?
    @State private var errorMessage: String?
    @State private var battleStart: Date = Date()

    private var isRunning: Bool { activity != nil }

    var body: some View {
        ZStack {
            backdrop
            ScrollView {
                VStack(spacing: 18) {
                    header
                    stage
                    statsRow
                    actionButton
                    hint
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - 背景

    private var backdrop: some View {
        ZStack {
            Color(hex: "06040A").ignoresSafeArea()
            RadialGradient(
                colors: [selectedHero.accent.opacity(0.32), selectedHero.glow.opacity(0.12), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 460
            )
            .ignoresSafeArea()
            SoulFlameView(
                accent: selectedHero.accent,
                glow: selectedHero.glow,
                intensity: 0.45,
                particleCount: 18
            )
            .opacity(0.45)
            .ignoresSafeArea()
        }
    }

    // MARK: - 头部

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LIVE ACTIVITY · DYNAMIC ISLAND")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(selectedHero.accent)
            Text("灵动岛 · DOTA 英雄")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text("影魔在左侧三连影压，神灵武士在右侧被击杀")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 主预览舞台

    private var stage: some View {
        VStack(spacing: 0) {
            PixelDuelView(startDate: battleStart)
                .frame(height: 200)

            HStack(spacing: 8) {
                Text("SHADOW FIEND")
                    .foregroundStyle(Color(hex: "E8663A"))
                Text("三连影压")
                    .foregroundStyle(.white.opacity(0.45))
                Spacer()
                Text("HUSKAR")
                    .foregroundStyle(Color(hex: "E0432A"))
            }
            .font(.system(size: 10, weight: .bold))
            .tracking(1.2)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color(hex: "0E0A16"))
        }
        .background(Color(hex: "0B0611"))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color(hex: "E8663A").opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color(hex: "8A3BE0").opacity(0.25), radius: 18, y: 8)
        .onTapGesture { battleStart = Date() }
    }

    // MARK: - 数据区

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(title: "SOULS 魂能", value: "\(souls)", accent: selectedHero.accent)
            statCard(title: "技能充能", value: "\(Int(rage * 100))%", accent: selectedHero.accent)
        }
    }

    private func statCard(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.45))
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }

    // MARK: - 按钮

    private var actionButton: some View {
        Button {
            Task {
                if isRunning {
                    await stop()
                } else {
                    await start()
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isRunning ? "stop.fill" : "bolt.fill")
                Text(isRunning ? "结束灵动岛动效" : "开启灵动岛动效")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(isRunning ? .white : Color(hex: "0A070F"))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: isRunning
                        ? [Color.white.opacity(0.12), Color.white.opacity(0.06)]
                        : [selectedHero.accent, selectedHero.glow.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(isRunning ? 0.1 : 0.25), lineWidth: 1)
            )
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
            Text("开启后回到桌面：紧凑态显示影魔头像，长按展开即可观看三连影压击杀神灵武士的像素动画。")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 2)
    }

    // MARK: - Live Activity 控制

    @MainActor
    private func start() async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            errorMessage = "系统未开启实时活动：设置 > 灵动岛Dota > 实时活动 > 允许"
            return
        }
        await stop()

        let hero = selectedHero
        let attributes = HeroIslandAttributes(
            heroID: hero.id,
            heroName: hero.name,
            heroEnglishName: hero.englishName,
            skillName: hero.skillName,
            accentHex: hero.accentHex,
            glowHex: hero.glowHex
        )
        souls = 0
        rage = 0.35
        battleStart = Date()
        let state = HeroIslandAttributes.ContentState(
            soulCount: souls,
            rage: rage,
            headline: hero.skillName,
            battleStart: battleStart
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
            errorMessage = nil
            startTicker()
        } catch {
            activity = nil
            errorMessage = "开启失败：\(error.localizedDescription)"
        }
    }

    @MainActor
    private func stop() async {
        ticker?.cancel()
        ticker = nil
        guard let current = activity else { return }
        activity = nil
        await current.end(nil, dismissalPolicy: .immediate)
    }

    @MainActor
    private func startTicker() {
        ticker?.cancel()
        ticker = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(700))
                guard !Task.isCancelled else { return }
                souls = min(souls + Int.random(in: 1...3), 99)
                rage = min(rage + 0.06, 1.0)
                if rage >= 1.0 { rage = 0.05 }
                await pushState()
            }
        }
    }

    @MainActor
    private func pushState() async {
        guard let current = activity else { return }
        let state = HeroIslandAttributes.ContentState(
            soulCount: souls,
            rage: rage,
            headline: selectedHero.skillName,
            battleStart: battleStart
        )
        await current.update(ActivityContent(state: state, staleDate: nil))
    }
}

#Preview {
    ContentView()
}
