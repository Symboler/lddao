import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var selectedHero: DotaHero = HeroCatalog.all[0]
    @State private var activity: Activity<HeroIslandAttributes>?
    @State private var souls: Int = 0
    @State private var rage: Double = 0.35
    @State private var ticker: Task<Void, Never>?
    @State private var errorMessage: String?

    private var isRunning: Bool { activity != nil }

    var body: some View {
        ZStack {
            backdrop
            ScrollView {
                VStack(spacing: 18) {
                    header
                    heroPicker
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
            Text("选择英雄后开启实时活动，回到桌面即可在灵动岛看到英雄动效")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 英雄选择

    private var heroPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(HeroCatalog.all) { hero in
                    heroChip(hero)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func heroChip(_ hero: DotaHero) -> some View {
        let isSelected = hero.id == selectedHero.id
        return Button {
            guard selectedHero.id != hero.id else { return }
            selectedHero = hero
            if isRunning {
                Task { await start() }
            }
        } label: {
            VStack(spacing: 6) {
                HeroToken(hero: hero, size: 46)
                    .opacity(isSelected ? 1 : 0.55)
                Text(hero.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
            }
            .frame(width: 68, height: 76)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? hero.accent.opacity(0.18) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? hero.accent.opacity(0.85) : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 主预览舞台

    private var stage: some View {
        ZStack(alignment: .bottomLeading) {
            HeroArtworkView(hero: selectedHero)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.55),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            LinearGradient(
                colors: [.clear, Color(hex: "06040A").opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )

            SoulFlameView(accent: selectedHero.accent, glow: selectedHero.glow, intensity: 1.0, particleCount: 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(selectedHero.englishName.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(selectedHero.accent)
                Text(selectedHero.name)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text(selectedHero.skillName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(16)
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(selectedHero.accent.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: selectedHero.accent.opacity(0.25), radius: 18, y: 8)
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
            Text("开启后请回到桌面或锁屏查看：紧凑态显示英雄头像与魂能，长按展开可查看技能特效与充能进度。")
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
        let state = HeroIslandAttributes.ContentState(
            soulCount: souls,
            rage: rage,
            headline: hero.skillName
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
            headline: selectedHero.skillName
        )
        await current.update(ActivityContent(state: state, staleDate: nil))
    }
}

#Preview {
    ContentView()
}
