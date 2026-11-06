import ActivityKit
import Foundation

/// 灵动岛 Live Activity 的数据模型，App 与 Widget 共用。
struct HeroIslandAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// 已收集的魂能数量
        var soulCount: Int
        /// 技能充能进度 0...1
        var rage: Double
        /// 灵动岛展开区上方的状态文案
        var headline: String
        /// 像素对决动画的时间原点，Widget 端据此自行推进动画
        var battleStart: Date
    }

    var heroID: String
    var heroName: String
    var heroEnglishName: String
    var skillName: String
    var accentHex: String
    var glowHex: String
}
