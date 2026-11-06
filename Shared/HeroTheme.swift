import SwiftUI

extension Color {
    /// 解析 "RRGGBB" 形式的颜色字符串，解析失败时回退到白色。
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        guard cleaned.count == 6 else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
            return
        }
        self.init(
            .sRGB,
            red: Double((value & 0xFF0000) >> 16) / 255.0,
            green: Double((value & 0x00FF00) >> 8) / 255.0,
            blue: Double(value & 0x0000FF) / 255.0,
            opacity: 1
        )
    }
}

struct DotaHero: Identifiable, Hashable {
    let id: String
    let name: String
    let englishName: String
    let skillName: String
    let accentHex: String
    let glowHex: String

    var accent: Color { Color(hex: accentHex) }
    var glow: Color { Color(hex: glowHex) }

    /// 打包进 App / Widget 的本地素材（离线可用）
    var iconAsset: String { "hero_\(id)" }
    var artAsset: String { "hero_\(id)_art" }

    /// Dota 2 官方 CDN 在线素材（作为补充来源）
    var iconURL: URL? {
        URL(string: "https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/icons/\(id).png")
    }

    var artURL: URL? {
        URL(string: "https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/\(id).png")
    }
}

enum HeroCatalog {
    static let all: [DotaHero] = [
        DotaHero(
            id: "nevermore",
            name: "影魔",
            englishName: "Shadow Fiend",
            skillName: "魂之挽歌 · REQUIEM OF SOULS",
            accentHex: "E8663A",
            glowHex: "8A3BE0"
        ),
        DotaHero(
            id: "storm_spirit",
            name: "风暴之灵",
            englishName: "Storm Spirit",
            skillName: "球状闪电 · BALL LIGHTNING",
            accentHex: "4FC3F7",
            glowHex: "1E88E5"
        ),
        DotaHero(
            id: "axe",
            name: "斧王",
            englishName: "Axe",
            skillName: "狂战士怒吼 · BERSERKER'S CALL",
            accentHex: "E0432A",
            glowHex: "FF9E45"
        ),
        DotaHero(
            id: "invoker",
            name: "祈求者",
            englishName: "Invoker",
            skillName: "超震声波 · SUN STRIKE",
            accentHex: "F2C14E",
            glowHex: "7E57C2"
        )
    ]

    static func hero(id: String) -> DotaHero {
        all.first(where: { $0.id == id }) ?? all[0]
    }
}
