import SwiftUI
import Foundation

// MARK: - 时间轴

enum CodeT {
    static let patrol: Double = 3.0
    static let expandEnd: Double = 3.33
    static let typingEnd: Double = 7.2
    static let lgtmEnd: Double = 7.6
    static let shatterEnd: Double = 8.12
    static let gameEnd: Double = 15.6
    static let resultEnd: Double = 16.6
    static let collapseEnd: Double = 17.02
    static let total: Double = 18.2
}

enum SceneCol {
    static let bg = Color(hex: "0A0A0C")
    static let border = Color(hex: "1F2024")
    static let orange = Color(hex: "D97757")
    static let cream = Color(hex: "FFF3E6")
    static let ink = Color(hex: "120A06")
    static let kw = Color(hex: "C792EA")
    static let str = Color(hex: "C3E88D")
    static let cmt = Color(hex: "5C6773")
    static let fg = Color(hex: "D8DEE9")
    static let sky = Color(hex: "5C94FC")
    static let brick = Color(hex: "F5C542")
    static let brickDk = Color(hex: "B4674E")
    static let grass = Color(hex: "6ABE30")
    static let ground = Color(hex: "8B5A2B")
    static let red = Color(hex: "E0432A")
}

// MARK: - 缓动

func clamp(_ v: Double, _ a: Double = 0, _ b: Double = 1) -> Double {
    max(a, min(b, v))
}

func lerp(_ a: Double, _ b: Double, _ p: Double) -> Double {
    a + (b - a) * p
}

func easeOut(_ p: Double) -> Double {
    1 - pow(1 - p, 3)
}

func easeInOut(_ p: Double) -> Double {
    p < 0.5 ? 2 * p * p : 1 - pow(-2 * p + 2, 2) / 2
}

func springEase(_ p: Double) -> Double {
    if p >= 1 { return 1 }
    return 1 - pow(1 - p, 3) * cos(p * 9)
}

// MARK: - 场景

enum CodeGenScene {
    static let compactSize = CGSize(width: 126, height: 37.33)
    static let expandedSize = CGSize(width: 372, height: 132)

    // MARK: 岛尺寸（App 内真实尺寸动画）

    static func liveSize(_ t: Double) -> (w: Double, h: Double, r: Double, p: Double) {
        var p = 0.0
        if t < CodeT.patrol { p = 0 }
        else if t < CodeT.expandEnd { p = springEase((t - CodeT.patrol) / (CodeT.expandEnd - CodeT.patrol)) }
        else if t < CodeT.resultEnd { p = 1 }
        else if t < CodeT.collapseEnd { p = 1 - easeInOut((t - CodeT.resultEnd) / (CodeT.collapseEnd - CodeT.resultEnd)) }
        else { p = 0 }

        var w = lerp(Double(compactSize.width), Double(expandedSize.width), p)
        if t >= CodeT.patrol && t < CodeT.patrol + 0.12 {
            w *= 1 + 0.06 * sin(((t - CodeT.patrol) / 0.12) * .pi)
        }
        let h = lerp(Double(compactSize.height), Double(expandedSize.height), p)
        let r = lerp(18.66, 24, p)
        return (w, h, r, p)
    }

    // MARK: 第一幕 · 紧凑态巡逻

    static func compact(_ ctx: inout GraphicsContext, size: CGSize, t: Double) {
        PX.fit(&ctx, size: size, design: compactSize)
        let cycle = 2.56
        let c = t.truncatingRemainder(dividingBy: cycle)

        var x = 4.0
        var dir = 1.0
        if c < 0.9 {
            x = lerp(4, 26, easeInOut(c / 0.9))
            dir = 1
        } else if c < 1.18 {
            x = 26
            dir = 1
        } else if c < 2.28 {
            x = lerp(26, 4, easeInOut((c - 1.18) / 1.1))
            dir = -1
        } else {
            x = 4
            dir = -1
        }

        let pause = (c >= 0.9 && c < 1.18) || c >= 2.28
        let bob = sin(t * 2 * .pi * 0.83) * 0.35
        let blinkCycle = t.truncatingRemainder(dividingBy: 3.7)
        let blink = (Int(t / 3.7) % 3 == 2) && blinkCycle < 0.14

        Clawd.draw(&ctx, x: x, y: 7 + (pause ? 0.4 : 0), u: 1.55,
                   face: dir, bob: bob, blink: blink, legPhase: t * 9,
                   armUp: pause ? 0.8 : 0)

        PX.text(&ctx, "代码生成中", x: 56, y: 5, size: 11, weight: .semibold,
                color: Color(hex: "F5F5F7"))
        let subs = ["在写第 1 版…", "正在读项目…", "改第 2 版…", "快好了…"]
        let idx = min(3, Int(t / 3.2))
        PX.text(&ctx, subs[idx], x: 56, y: 20, size: 9, weight: .regular,
                color: Color.white.opacity(0.42))

        for i in 0..<3 {
            let a = 0.25 + 0.55 * (0.5 + 0.5 * sin(t * 4 - Double(i) * 0.7))
            PX.circle(&ctx, 112 + Double(i) * 5, 24, 1.6, SceneCol.orange.opacity(a))
        }
    }

    /// 紧凑态左侧小徽标（灵动岛 compactLeading，约 44×34 pt）
    static func badge(_ ctx: inout GraphicsContext, size: CGSize, t: Double) {
        PX.fit(&ctx, size: size, design: CGSize(width: 40, height: 34))
        let cycle = 2.56
        let c = t.truncatingRemainder(dividingBy: cycle)
        var x = 6.0
        var dir = 1.0
        if c < 0.9 { x = lerp(2, 10, easeInOut(c / 0.9)); dir = 1 }
        else if c < 1.18 { x = 10; dir = 1 }
        else if c < 2.28 { x = lerp(10, 2, easeInOut((c - 1.18) / 1.1)); dir = -1 }
        else { x = 2; dir = -1 }

        let blink = (Int(t / 3.7) % 3 == 2) && t.truncatingRemainder(dividingBy: 3.7) < 0.14
        Clawd.draw(&ctx, x: x, y: 7.5, u: 1.55,
                   face: dir, bob: sin(t * 2 * .pi * 0.83) * 0.35,
                   blink: blink, legPhase: t * 9, armUp: 0)
    }

    // MARK: 收起后的余味

    static func compactAfter(_ ctx: inout GraphicsContext, size: CGSize, t: Double) {
        compact(&ctx, size: size, t: t)
        PX.rect(&ctx, 48, 8, 72, 22, SceneCol.bg)
        PX.text(&ctx, "Claw'd 完成了", x: 52, y: 5, size: 11, weight: .semibold,
                color: Color(hex: "F5F5F7"))
        PX.text(&ctx, "1 个任务", x: 52, y: 20, size: 9, weight: .regular,
                color: Color.white.opacity(0.42))
    }

    // MARK: 第二幕 · 打字机

    static let codeLines = [
        "function jump() {",
        "  player.vy = -12;",
        "  sfx.play(\"boop\");",
        "  // 这行别动，动了会炸",
        "}"
    ]

    static let typedEvents: [(t: Double, ch: String)] = {
        var ev: [(Double, String)] = []
        var tm = 0.0
        func push(_ ch: String, _ dt: Double) {
            ev.append((tm, ch))
            tm += dt
        }
        func pause(_ dt: Double) { tm += dt }

        for (li, line) in codeLines.enumerated() {
            if li == 3 { pause(0.26) }
            if li == 1 {
                // 打错再删：先打 "  plal"，退格，再补完 "yer.vy = -12;"
                for ch in "  plal" {
                    push(String(ch), (ch.isLetter ? 0.040 : 0.026))
                }
                pause(0.30)
                ev.append((tm, "\u{8}"))
                tm += 0.05
                pause(0.08)
                for ch in "yer.vy = -12;" {
                    push(String(ch), (ch.isLetter ? 0.040 : 0.026))
                }
            } else {
                for ch in line {
                    push(String(ch), (ch.isLetter ? 0.040 : 0.026))
                }
            }
            pause(0.10)
            push("\n", 0.0)
            if li == 2 { pause(0.42) }
        }

        let scale = (CodeT.typingEnd - CodeT.expandEnd) / tm
        return ev.map { (t: $0.0 * scale, ch: $0.1) }
    }()

    static func typedText(_ radius: Double) -> String {
        var text = ""
        for e in typedEvents {
            if e.t > radius { break }
            if e.ch == "\u{8}" {
                if !text.isEmpty { text.removeLast() }
            } else {
                text.append(e.ch)
            }
        }
        return text
    }

    static func editor(_ ctx: inout GraphicsContext, t: Double) {
        let W = Double(expandedSize.width), H = Double(expandedSize.height)
        PX.rect(&ctx, 0, 0, W, H, SceneCol.bg)
        ctx.stroke(Path(CGRect(x: 0.5, y: 0.5,
                                width: CGFloat(W - 1),
                                height: CGFloat(H - 1))),
                   with: .color(SceneCol.border), lineWidth: 1)

        // 顶部条
        let dots = [Color(hex: "FF5F57"), Color(hex: "FEBC2E"), Color(hex: "28C840")]
        for (i, c) in dots.enumerated() {
            PX.circle(&ctx, 13 + Double(i) * 11, 11, 3.2, c.opacity(0.75))
        }
        PX.text(&ctx, "game.js", x: 52, y: 5, size: 10, weight: .semibold,
                color: Color.white.opacity(0.75), mono: true)
        PX.text(&ctx, "main ▸ 12ms", x: W - 12, y: 5, size: 9, weight: .regular,
                color: Color.white.opacity(0.35), mono: true, anchor: .topTrailing)
        PX.rect(&ctx, 0, 22, W, 1, SceneCol.border)

        // 代码
        let radius = clamp(t - CodeT.expandEnd, 0, CodeT.typingEnd - CodeT.expandEnd)
        let text = typedText(radius)
        let lines = text.components(separatedBy: "\n")
        let x0 = 14.0, y0 = 30.0, lh = 19.5, charW = 7.2

        for (i, line) in lines.enumerated() {
            if i > 4 { break }
            let y = y0 + Double(i) * lh
            PX.text(&ctx, String(format: "%02d", i + 1), x: x0 - 6, y: y + 1.5,
                    size: 9, weight: .regular, color: Color.white.opacity(0.18), mono: true)

            let trimmed = line.trimmingCharacters(in: .whitespaces)
            var color = SceneCol.fg
            if trimmed.hasPrefix("//") {
                color = SceneCol.cmt
            } else if trimmed.hasPrefix("function") {
                color = SceneCol.kw
            }

            let tx = x0 + 10
            if !line.isEmpty {
                PX.text(&ctx, line, x: tx, y: y, size: 12, weight: .medium,
                        color: color, mono: true)
            }

            if let a = line.firstIndex(of: "\""), let b = line.lastIndex(of: "\""), a != b {
                let pre = line[line.startIndex..<a]
                let quoted = String(line[a...b])
                PX.text(&ctx, quoted, x: tx + Double(pre.count) * charW, y: y,
                        size: 12, weight: .medium, color: SceneCol.str, mono: true)
            }
        }

        // Claw'd 光标
        let lastLine = lines.count - 1
        let lastText = lastLine >= 0 ? lines[lastLine] : ""
        let cx = x0 + 10 + Double(lastText.count) * charW
        let cy = y0 + Double(max(lastLine, 0)) * lh
        let thinking = t > CodeT.expandEnd + 2.4 && t < CodeT.expandEnd + 2.8
        Clawd.draw(&ctx, x: cx - 1, y: cy - 3, u: 0.72,
                   face: 1, legPhase: thinking ? 0 : t * 22,
                   blink: thinking, armUp: thinking ? 0 : 0.4)

        // 进度条
        let prog = clamp((t - CodeT.expandEnd) / (CodeT.typingEnd - CodeT.expandEnd))
        PX.rect(&ctx, 12, 118, W - 24, 3, Color(hex: "1C1D21"))
        PX.rect(&ctx, 12, 118, (W - 24) * prog, 3, SceneCol.orange)
        PX.text(&ctx, "生成中 \(Int(prog * 100))%", x: 12, y: 106, size: 8,
                weight: .semibold, color: Color.white.opacity(0.5), mono: true)
    }

    // MARK: 第四幕前置 · LGTM 举牌

    static func lgtm(_ ctx: inout GraphicsContext, t: Double) {
        editor(&ctx, t: t)
        let p = clamp((t - CodeT.typingEnd) / (CodeT.lgtmEnd - CodeT.typingEnd))
        let jump = sin(p * .pi) * 8
        let cx = 300.0, cy = 96.0 - jump
        Clawd.draw(&ctx, x: cx - 6, y: cy - 8, u: 0.9,
                   face: 1, legPhase: t * 20, armUp: 1.2)

        PX.rect(&ctx, cx + 6, cy - 18, 46, 16, SceneCol.ink)
        PX.rect(&ctx, cx + 7, cy - 17, 44, 14, SceneCol.brick)
        PX.text(&ctx, "LGTM", x: cx + 29, y: cy - 14, size: 9, weight: .bold,
                color: Color(hex: "1A1006"), mono: true, anchor: .top)

        PX.rect(&ctx, 12, 118, 348, 3, SceneCol.orange)
    }

    // MARK: 第三幕 · 像素化编译

    static func shatter(_ ctx: inout GraphicsContext, t: Double) {
        let gt = t - CodeT.lgtmEnd

        if gt > 0.30 {
            let a = clamp((gt - 0.30) / 0.12)
            var inner = ctx
            inner.opacity = a
            gameFrame(&inner, gt: 0.4)
        }

        let p1 = clamp(gt / 0.31)
        if gt < 0.34 {
            var inner = ctx
            inner.translateBy(x: 0, y: 66)
            inner.scaleBy(x: 1, y: CGFloat(lerp(1, 0.055, easeOut(p1))))
            inner.translateBy(x: 0, y: -66)
            inner.opacity = 1 - 0.35 * p1
            editor(&inner, t: CodeT.typingEnd)
        }

        if gt >= 0.15 && gt < 0.52 {
            let bw = 8.0, bh = 8.0
            for c in 0..<47 {
                for r in 0..<6 {
                    let srcY = 22.0 + Double(r) * bh
                    if srcY + bh > 118 { continue }
                    let appear = clamp((gt - 0.15 - Double(c) * 0.006) / 0.05)
                    if appear <= 0 { continue }
                    let fallT = clamp((gt - 0.30 - Double(c) * 0.008) / 0.18)
                    let v = sin(Double(c) * 12.9898 + Double(r) * 78.233) * 43758.5453
                    let pick = v - floor(v)
                    let color: Color = pick < 0.72 ? SceneCol.bg
                        : (pick < 0.82 ? SceneCol.fg : (pick < 0.90 ? SceneCol.kw : SceneCol.str))

                    var inner = ctx
                    inner.translateBy(x: 0, y: CGFloat(fallT * fallT * (120 + Double(r) * 6)))
                    inner.opacity = (1 - fallT) * appear
                    PX.rect(&inner, Double(c) * bw + 0.4, srcY + 0.4, bw - 0.8, bh - 0.8, color)
                }
            }

            if gt < 0.42 {
                let sy = (gt / 0.42) * 132
                PX.rect(&ctx, 0, sy, 372, 1.2, Color.white.opacity(0.16))
            }
        }
    }

    // MARK: 分发

    static func expanded(_ ctx: inout GraphicsContext, size: CGSize, t: Double) {
        PX.fit(&ctx, size: size, design: expandedSize)
        if t < CodeT.typingEnd {
            editor(&ctx, t: t)
        } else if t < CodeT.lgtmEnd {
            lgtm(&ctx, t: t)
        } else if t < CodeT.shatterEnd {
            shatter(&ctx, t: t)
        } else if t < CodeT.gameEnd {
            game(&ctx, t: t)
        } else {
            result(&ctx, t: t)
        }
    }
}
