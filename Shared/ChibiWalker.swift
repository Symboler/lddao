import SwiftUI

// MARK: - 武器类型

enum Weapon {
    case none, sword, axe, staff, orb
}

// MARK: - Q 版角色定义

struct ChibiCharacter: Identifiable, Hashable {
    let id: String
    let name: String
    let englishName: String
    let accentHex: String
    let glowHex: String

    // 调色板
    let skin: Color
    let hair: Color
    let outfit: Color
    let outfitDark: Color
    let accent: Color
    let eye: Color

    // 特征
    let hasHorns: Bool
    let hasMask: Bool
    let hasHat: Bool
    let weapon: Weapon
    let hairLong: Bool

    static func == (lhs: ChibiCharacter, rhs: ChibiCharacter) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - 角色目录

enum ChibiCatalog {
    static let all: [ChibiCharacter] = [shadowFiend, juggernaut, lina, crystalMaiden]

    static func chars(_ ids: [String]) -> [ChibiCharacter] {
        ids.compactMap { id in all.first { $0.id == id } }
    }

    static let shadowFiend = ChibiCharacter(
        id: "nevermore", name: "影魔", englishName: "SHADOW FIEND",
        accentHex: "E8663A", glowHex: "8A3BE0",
        skin: Color(hex: "2A1735"), hair: Color(hex: "E8663A"),
        outfit: Color(hex: "241030"), outfitDark: Color(hex: "150A1C"),
        accent: Color(hex: "8A3BE0"), eye: Color(hex: "FF8A4C"),
        hasHorns: true, hasMask: false, hasHat: false,
        weapon: .orb, hairLong: false
    )

    static let juggernaut = ChibiCharacter(
        id: "juggernaut", name: "剑圣", englishName: "JUGGERNAUT",
        accentHex: "F2C14E", glowHex: "E0432A",
        skin: Color(hex: "C9A87C"), hair: Color(hex: "F2C14E"),
        outfit: Color(hex: "B9C0C8"), outfitDark: Color(hex: "6A727C"),
        accent: Color(hex: "E0432A"), eye: Color(hex: "FFFFFF"),
        hasHorns: false, hasMask: true, hasHat: false,
        weapon: .sword, hairLong: false
    )

    static let lina = ChibiCharacter(
        id: "lina", name: "丽娜", englishName: "LINA",
        accentHex: "FF6B2B", glowHex: "FFD65A",
        skin: Color(hex: "F0C8A0"), hair: Color(hex: "E8663A"),
        outfit: Color(hex: "C23A22"), outfitDark: Color(hex: "8F1B12"),
        accent: Color(hex: "FFD65A"), eye: Color(hex: "2A0E08"),
        hasHorns: false, hasMask: false, hasHat: false,
        weapon: .orb, hairLong: true
    )

    static let crystalMaiden = ChibiCharacter(
        id: "crystal_maiden", name: "水晶室女", englishName: "CRYSTAL MAIDEN",
        accentHex: "7FC8FF", glowHex: "3A6FB0",
        skin: Color(hex: "F0D8C8"), hair: Color(hex: "A8D8FF"),
        outfit: Color(hex: "5A8FC7"), outfitDark: Color(hex: "2E5A8C"),
        accent: Color(hex: "C8E8FF"), eye: Color(hex: "1A3A5A"),
        hasHorns: false, hasMask: false, hasHat: true,
        weapon: .staff, hairLong: true
    )
}

// MARK: - 走秀引擎

enum ChibiWalker {
    static let walkFPS: Double = 8.0
    static let designWidth: Double = 200
    static let designHeight: Double = 80
    static let groundY: Double = 64
    static let spacing: Double = 38
    static let speed: Double = 18.0

    /// 展开态：横向走秀。
    static func parade(_ ctx: inout GraphicsContext, size: CGSize,
                       chars: [ChibiCharacter], elapsed: Double) {
        Pixel.fit(&ctx, size: size, designWidth: designWidth, designHeight: designHeight)
        // 背景
        Pixel.px(&ctx, 0, 0, designWidth, designHeight, Color(hex: "0B0611"))
        Pixel.px(&ctx, 0, groundY, designWidth, designHeight - groundY, Color(hex: "14101C"))
        Pixel.px(&ctx, 0, groundY, designWidth, 1, Color(hex: "3A2C48"))

        guard !chars.isEmpty else { return }
        let count = chars.count
        let span = spacing * Double(count)
        let frame = Int((elapsed * walkFPS).truncatingRemainder(dividingBy: 4))

        for i in 0..<count * 2 {
            let char = chars[i % count]
            var x = (elapsed * speed + Double(i) * spacing).truncatingRemainder(dividingBy: span)
            if x < 0 { x += span }
            x -= 50
            if x > -30 && x < designWidth + 30 {
                drawChar(&ctx, char: char, x: x, groundY: groundY, frame: frame)
            }
        }
    }

    /// 紧凑态：原地踏步。draws up to `limit` characters at fixed x positions.
    static func march(_ ctx: inout GraphicsContext, size: CGSize,
                      chars: [ChibiCharacter], elapsed: Double, limit: Int = 2) {
        Pixel.fit(&ctx, size: size, designWidth: 40, designHeight: 40)
        Pixel.px(&ctx, 0, 0, 40, 40, Color.clear)
        let frame = Int((elapsed * walkFPS).truncatingRemainder(dividingBy: 4))
        let shown = Array(chars.prefix(limit))
        let baseX: Double = 20
        let charSpacing: Double = 18
        let offset = -Double(shown.count - 1) * charSpacing / 2
        for (i, char) in shown.enumerated() {
            drawChar(&ctx, char: char, x: baseX + offset + Double(i) * charSpacing,
                     groundY: 34, frame: frame)
        }
    }

    // MARK: 单角色绘制（脚在 (x, groundY)，面朝右）

    static func drawChar(_ ctx: inout GraphicsContext, char: ChibiCharacter,
                         x: Double, groundY: Double, frame: Int) {
        // 步态参数
        let isForwardStep = frame == 0 || frame == 2
        let bodyBob: Double = isForwardStep ? 1 : 0
        let leftLegDX: Double = frame == 0 ? -1 : (frame == 2 ? 1 : 0)
        let rightLegDX: Double = frame == 0 ? 1 : (frame == 2 ? -1 : 0)
        let leftArmDX: Double = frame == 0 ? 1 : (frame == 2 ? -1 : 0)
        let rightArmDX: Double = frame == 0 ? -1 : (frame == 2 ? 1 : 0)

        let by = groundY + bodyBob  // body/head baseline

        // 影子
        Pixel.px(&ctx, x - 5, groundY, 10, 1, Color.black.opacity(0.35))

        // 腿（固定在地面）
        Pixel.px(&ctx, x - 3 + leftLegDX, groundY - 4, 2, 4, char.outfitDark)
        Pixel.px(&ctx, x + 1 + rightLegDX, groundY - 4, 2, 4, char.outfitDark)
        // 鞋
        Pixel.px(&ctx, x - 4 + leftLegDX, groundY - 1, 3, 1, Color(hex: "120818"))
        Pixel.px(&ctx, x + 1 + rightLegDX, groundY - 1, 3, 1, Color(hex: "120818"))

        // 身体
        Pixel.px(&ctx, x - 4, by - 9, 8, 5, char.outfit)
        Pixel.px(&ctx, x - 4, by - 9, 8, 1, char.outfitDark.opacity(0.5))
        // 腰带
        Pixel.px(&ctx, x - 4, by - 5, 8, 1, char.outfitDark)

        // 手臂
        Pixel.px(&ctx, x - 5 + leftArmDX, by - 8, 2, 4, char.outfit)
        Pixel.px(&ctx, x + 3 + rightArmDX, by - 8, 2, 4, char.outfit)
        // 手
        Pixel.px(&ctx, x - 5 + leftArmDX, by - 5, 2, 1, char.skin)
        Pixel.px(&ctx, x + 3 + rightArmDX, by - 5, 2, 1, char.skin)

        // 头
        let headX = x - 3
        let headY = by - 16
        Pixel.px(&ctx, headX, headY, 7, 7, char.skin)
        Pixel.px(&ctx, headX, headY, 7, 1, char.skin.opacity(0.7))

        // 眼睛
        Pixel.px(&ctx, headX + 1, headY + 3, 1, 1, char.eye)
        Pixel.px(&ctx, headX + 4, headY + 3, 1, 1, char.eye)

        // 头发 / 帽饰
        if char.hasHorns {
            Pixel.px(&ctx, headX, headY - 3, 2, 3, char.hair)
            Pixel.px(&ctx, headX + 5, headY - 3, 2, 3, char.hair)
            Pixel.px(&ctx, headX - 1, headY - 1, 1, 2, char.hair.opacity(0.7))
            Pixel.px(&ctx, headX + 7, headY - 1, 1, 2, char.hair.opacity(0.7))
        } else if char.hasMask {
            Pixel.px(&ctx, headX - 1, headY, 9, 4, char.hair)
            Pixel.px(&ctx, headX + 1, headY + 2, 1, 1, char.eye)
            Pixel.px(&ctx, headX + 5, headY + 2, 1, 1, char.eye)
        } else if char.hasHat {
            Pixel.px(&ctx, headX, headY - 3, 7, 3, char.outfit)
            Pixel.px(&ctx, headX - 1, headY - 1, 9, 1, char.outfitDark)
            Pixel.px(&ctx, headX + 2, headY - 5, 3, 2, char.accent)
        } else {
            // 普通头发
            Pixel.px(&ctx, headX, headY - 1, 7, 2, char.hair)
            Pixel.px(&ctx, headX - 1, headY, 1, 3, char.hair)
            Pixel.px(&ctx, headX + 7, headY, 1, 3, char.hair)
            if char.hairLong {
                Pixel.px(&ctx, x - 5, by - 9, 1, 5, char.hair)
                Pixel.px(&ctx, x + 4, by - 9, 1, 5, char.hair)
            }
        }

        // 武器（右手）
        let handX = x + 3 + rightArmDX
        let handY = by - 6
        switch char.weapon {
        case .sword:
            Pixel.px(&ctx, handX + 2, handY - 4, 1, 5, Color(hex: "D8DCE0"))
            Pixel.px(&ctx, handX + 1, handY, 3, 1, char.accent)
        case .axe:
            Pixel.px(&ctx, handX + 2, handY - 4, 1, 5, Color(hex: "6B4A2A"))
            Pixel.px(&ctx, handX + 3, handY - 5, 3, 3, Color(hex: "B9C0C8"))
        case .staff:
            Pixel.px(&ctx, handX + 2, handY - 6, 1, 7, Color(hex: "6B4A2A"))
            Pixel.px(&ctx, handX + 1, handY - 7, 3, 2, char.accent)
            Pixel.px(&ctx, handX + 2, handY - 7, 1, 1, .white)
        case .orb:
            Pixel.px(&ctx, handX + 2, handY - 3, 3, 3, char.accent)
            Pixel.px(&ctx, handX + 3, handY - 2, 1, 1, .white)
        case .none:
            break
        }
    }
}

// MARK: - SwiftUI 视图

/// 展开态 / 锁屏：横向走秀。
struct ParadeView: View {
    let selectedIDs: [String]
    let startDate: Date

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 10.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            Canvas { context, size in
                ChibiWalker.parade(&context, size: size,
                                   chars: ChibiCatalog.chars(selectedIDs), elapsed: elapsed)
            }
        }
        .clipped()
        .allowsHitTesting(false)
    }
}

/// 紧凑态：原地踏步。
struct MarchingView: View {
    let selectedIDs: [String]
    let startDate: Date
    var limit: Int = 2

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 10.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            Canvas { context, size in
                ChibiWalker.march(&context, size: size,
                                  chars: ChibiCatalog.chars(selectedIDs),
                                  elapsed: elapsed, limit: limit)
            }
        }
        .clipped()
        .allowsHitTesting(false)
    }
}
