import ActivityKit
import Foundation

/// 灵动岛 Live Activity 数据模型，App 与 Widget 共用。
struct CodeGenIslandAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// 动画时间原点，Widget 端据此自行推进
        var startDate: Date
        /// 文件名
        var taskName: String
        /// 紧凑态文案
        var status: String
    }

    /// 强调色
    var accentHex: String
}
