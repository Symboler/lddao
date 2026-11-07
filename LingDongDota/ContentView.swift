import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var selectedIDs: [String] = ChibiCatalog.all.map { $0.id }
    @State private var activity: Activity<HeroIslandAttributes>?
    @State private var walkStart: Date = Date()
    @State private var errorMessage: String?

    private var isRunning: Bool { activity != nil }
    private var selectedChars: [ChibiCharacter] { ChibiCatalog.chars(selectedIDs) }
    private var accent: Color {
        Color(hex: selectedChars.first?.accentHex ?? "E8663A")
    }
    private var glow: Color {
        Color(hex: selectedChars.first?.glowHex ?? "8A3BE0")
    }

    var body: some View {
        ZStack {
            backdrop
            ScrollView {
                VStack(spacing: 18) {
                    header
                    stage
                    characterPicker
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
                colors: [accent.opacity(0.32), glow.opacity(0.12), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 460
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - 头部

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LIVE ACTIVITY · DYNAMIC ISLAND")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(accent)
            Text("灵动岛 · DOTA 走秀")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text("Q 版像素英雄排队走过灵动岛，可自由选择出场角色")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 走秀预览舞台

    private var stage: some View {
        VStack(spacing: 0) {
            ParadeView(selectedIDs: selectedIDs, startDate: walkStart)
                .frame(height: 160)

            HStack(spacing: 8) {
                Text("DOTA PARADE")
                    .foregroundStyle(accent)
                Text("\(selectedIDs.count) HEROES")
                    .foregroundStyle(.white.opacity(0.45))
                Spacer()
                Text("点击重播")
                    .foregroundStyle(.white.opacity(0.3))
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
                .stroke(accent.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: glow.opacity(0.25), radius: 18, y: 8)
        .onTapGesture { walkStart = Date() }
    }

    // MARK: - 角色选择

    private var characterPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("选择出场角色")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Button {
                    if selectedIDs.count == ChibiCatalog.all.count {
                        selectedIDs = []
                    } else {
                        selectedIDs = ChibiCatalog.all.map { $0.id }
                    }
                } label: {
                    Text(selectedIDs.count == ChibiCatalog.all.count ? "全不选" : "全选")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(accent)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ChibiCatalog.all) { char in
                        let selected = selectedIDs.contains(char.id)
                        Button {
                            toggle(char)
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selected
                                              ? Color(hex: char.accentHex).opacity(0.18)
                                              : Color.white.opacity(0.04))
                                    ParadePreviewIcon(char: char)
                                        .frame(width: 44, height: 44)
                                }
                                .frame(width: 56, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selected
                                                ? Color(hex: char.accentHex)
                                                : Color.white.opacity(0.1),
                                                lineWidth: selected ? 2 : 1)
                                )

                                Text(char.name)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(selected ? .white : .white.opacity(0.45))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func toggle(_ char: ChibiCharacter) {
        if let index = selectedIDs.firstIndex(of: char.id) {
            selectedIDs.remove(at: index)
        } else {
            selectedIDs.append(char.id)
        }
        walkStart = Date()
    }

    // MARK: - 按钮

    private var actionButton: some View {
        Button {
            Task {
                if isRunning { await stop() } else { await start() }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isRunning ? "stop.fill" : "figure.walk")
                Text(isRunning ? "结束灵动岛走秀" : "开启灵动岛走秀")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(isRunning ? .white : Color(hex: "0A070F"))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: isRunning
                        ? [Color.white.opacity(0.12), Color.white.opacity(0.06)]
                        : [accent, glow.opacity(0.85)],
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
        .disabled(selectedIDs.isEmpty)
        .opacity(selectedIDs.isEmpty ? 0.4 : 1)
    }

    private var hint: some View {
        VStack(spacing: 6) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "FF7A70"))
                    .multilineTextAlignment(.center)
            }
            Text("开启后回到桌面：紧凑态角色原地踏步，长按展开观看完整横向走秀。")
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
        guard !selectedIDs.isEmpty else {
            errorMessage = "请至少选择一个角色"
            return
        }
        await stop()

        walkStart = Date()
        let first = selectedChars.first!
        let attributes = HeroIslandAttributes(
            accentHex: first.accentHex,
            glowHex: first.glowHex
        )
        let state = HeroIslandAttributes.ContentState(
            selectedIDs: selectedIDs,
            walkStart: walkStart,
            headline: "\(selectedIDs.count) HEROES MARCHING"
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

/// 角色卡片上的小预览（单角色静止）。
struct ParadePreviewIcon: View {
    let char: ChibiCharacter

    var body: some View {
        Canvas { context, size in
            var c = context
            Pixel.fit(&c, size: size, designWidth: 40, designHeight: 40)
            ChibiWalker.drawChar(&c, char: char, x: 20, groundY: 34, frame: 0)
        }
    }
}

#Preview {
    ContentView()
}
