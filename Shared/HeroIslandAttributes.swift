import ActivityKit
import Foundation

/// 灵动岛 Live Activity 的数据模型，App 与 Widget 共用。
struct HeroIslandAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// 参加走秀的角色 ID 列表
        var selectedIDs: [String]
        /// 走秀动画的时间原点，Widget 端据此自行推进动画
        var walkStart: Date
        /// 状态文案
        var headline: String
    }

    /// 主题强调色（取第一个角色）
    var accentHex: String
    /// 主题光晕色
    var glowHex: String
}
