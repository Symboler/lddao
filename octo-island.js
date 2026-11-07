/* Octo Island · Claw'd 五幕预览
   设计坐标系：1 单位 = 1 pt。紧凑态 126×37.33，展开态 372×132。 */

const T = {
  patrol: 3.0, expandEnd: 3.33, typingEnd: 7.2, lgtmEnd: 7.6,
  shatterEnd: 8.12, gameEnd: 15.6, resultEnd: 16.6,
  collapseEnd: 17.02, total: 18.2
};

const COL = {
  bg: '#0A0A0C', border: '#1F2024',
  orange: '#D97757', orangeDk: '#A95233', orangeLt: '#F0A081',
  cream: '#FFF3E6', ink: '#120A06',
  kw: '#C792EA', fn: '#82AAFF', str: '#C3E88D', cmt: '#5C6773', fg: '#D8DEE9',
  sky: '#5C94FC', brick: '#F5C542', brickDk: '#B4674E',
  grass: '#6ABE30', ground: '#8B5A2B', dark: '#101010'
};

/* ---------- 基础 ---------- */
function px(ctx, x, y, w, h, c) {
  ctx.fillStyle = c;
  ctx.fillRect(x, y, Math.max(w, 0.5), Math.max(h, 0.5));
}
function lerp(a, b, p) { return a + (b - a) * p; }
function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }
function easeOut(p) { return 1 - Math.pow(1 - p, 3); }
function easeInOut(p) { return p < 0.5 ? 2 * p * p : 1 - Math.pow(-2 * p + 2, 2) / 2; }
function spring(p) {
  if (p >= 1) return 1;
  return 1 - Math.pow(1 - p, 3) * Math.cos(p * 9);
}

/* ---------- 时间轴 → 岛尺寸（设计单位 pt） ---------- */
const COMPACT = { w: 126, h: 37.33, r: 18.66 };
const EXPANDED = { w: 372, h: 132, r: 24 };

function islandSize(t) {
  let p = 0;
  if (t < T.patrol) p = 0;
  else if (t < T.expandEnd) p = spring((t - T.patrol) / (T.expandEnd - T.patrol));
  else if (t < T.resultEnd) p = 1;
  else if (t < T.collapseEnd) p = 1 - easeInOut((t - T.resultEnd) / (T.collapseEnd - T.resultEnd));
  else p = 0;

  let w = lerp(COMPACT.w, EXPANDED.w, p);
  // 展开前 90ms 横向过冲（深吸一口气）
  const breathe = t >= T.patrol && t < T.patrol + 0.12
    ? 1 + 0.06 * Math.sin(((t - T.patrol) / 0.12) * Math.PI)
    : 1;
  w *= breathe;

  const h = lerp(COMPACT.h, EXPANDED.h, p);
  const r = lerp(COMPACT.r, EXPANDED.r, p);
  return { w, h, r, p };
}

/* ---------- Claw'd 像素螃蟹 ---------- */
function drawCrab(ctx, x, y, u, opt) {
  const o = opt || {};
  const face = o.face || 1;          // 1 右 / -1 左
  const bob = o.bob || 0;            // 上下浮动（单位）
  const blink = !!o.blink;
  const legPhase = o.legPhase || 0;
  const armUp = o.armUp || 0;        // 蟹钳抬起高度（单位）
  const s = u;
  const K = COL.ink, O = COL.orange, L = COL.orangeLt;

  // 4 条小短腿
  for (let i = 0; i < 4; i++) {
    const off = Math.sin(legPhase + i * 1.1) * 0.35;
    px(ctx, x + (4.2 + i * 2.1) * s + off * s, y + 9 * s, 0.9 * s, (1.9 + Math.abs(off) * 0.6) * s, K);
  }

  // 两只蟹钳（抬起时更高）
  const clawY = 2.2 - armUp;
  px(ctx, x - 0.4 * s, y + clawY * s + bob * s, 3.4 * s, 4.2 * s, K);
  px(ctx, x + 0.3 * s, y + (clawY + 0.5) * s + bob * s, 2.2 * s, 3.1 * s, O);
  px(ctx, x + 1.2 * s, y + (clawY + 1.6) * s + bob * s, 1.6 * s, 0.6 * s, K); // 钳口

  px(ctx, x + 13 * s, y + clawY * s + bob * s, 3.4 * s, 4.2 * s, K);
  px(ctx, x + 13.5 * s, y + (clawY + 0.5) * s + bob * s, 2.2 * s, 3.1 * s, O);
  px(ctx, x + 13.4 * s, y + (clawY + 1.6) * s + bob * s, 1.6 * s, 0.6 * s, K);

  // 身体
  px(ctx, x + 2.7 * s, y + (3.8 + bob) * s, 10.6 * s, 5.4 * s, K);
  px(ctx, x + 3.3 * s, y + (4.4 + bob) * s, 9.4 * s, 4.2 * s, O);
  // 高光
  px(ctx, x + 3.7 * s, y + (4.7 + bob) * s, 3.8 * s, 0.8 * s, L);

  // 眼睛
  px(ctx, x + 5.1 * s, y + (4.0 + bob) * s, 2.2 * s, 2.2 * s, COL.cream);
  px(ctx, x + 8.9 * s, y + (4.0 + bob) * s, 2.2 * s, 2.2 * s, COL.cream);
  if (blink) {
    px(ctx, x + 5.1 * s, y + (5.0 + bob) * s, 2.2 * s, 0.9 * s, K);
    px(ctx, x + 8.9 * s, y + (5.0 + bob) * s, 2.2 * s, 0.9 * s, K);
  } else {
    px(ctx, x + (5.6 + (face > 0 ? 0.5 : 0)) * s, y + (4.8 + bob) * s, 0.8 * s, 1.1 * s, K);
    px(ctx, x + (9.4 + (face > 0 ? 0.5 : 0)) * s, y + (4.8 + bob) * s, 0.8 * s, 1.1 * s, K);
  }
}

/* ---------- 第一幕：紧凑态巡逻 ---------- */
function sceneCompact(ctx, t) {
  const W = COMPACT.w, H = COMPACT.h;
  const cycle = 2.56;
  const c = t % cycle;
  // 0–0.9 右移 / 0.9–1.18 停 / 1.18–2.28 左移 / 2.28–2.56 停
  let x, dir;
  if (c < 0.9) { x = lerp(4, 26, easeInOut(c / 0.9)); dir = 1; }
  else if (c < 1.18) { x = 26; dir = 1; }
  else if (c < 2.28) { x = lerp(26, 4, easeInOut((c - 1.18) / 1.1)); dir = -1; }
  else { x = 4; dir = -1; }

  const pause = (c >= 0.9 && c < 1.18) || c >= 2.28;
  const bob = Math.sin(t * 2 * Math.PI * 0.83) * 0.35;
  const blink = (Math.floor(t / 3.7) % 3 === 2) && (t % 3.7) < 0.14;
  const legPhase = t * 9;

  drawCrab(ctx, x, 7 + (pause ? 0.4 : 0), 1.55, {
    face: dir, bob, blink, legPhase,
    armUp: pause ? 0.8 : 0
  });

  // 右侧文案
  ctx.textBaseline = 'alphabetic';
  ctx.fillStyle = '#F5F5F7';
  ctx.font = '600 11px -apple-system,"PingFang SC",sans-serif';
  ctx.fillText('代码生成中', 56, 15);

  ctx.fillStyle = 'rgba(255,255,255,0.42)';
  ctx.font = '400 9px -apple-system,"PingFang SC",sans-serif';
  const sub = ['正在读项目…', '正在写第 1 版…', '改第 2 版…', '快好了…'][Math.min(3, Math.floor(t / 3.2))];
  ctx.fillText(sub, 56, 27);

  // 三个呼吸点
  for (let i = 0; i < 3; i++) {
    const a = 0.25 + 0.55 * (0.5 + 0.5 * Math.sin(t * 4 - i * 0.7));
    ctx.fillStyle = `rgba(217,119,87,${a})`;
    ctx.beginPath();
    ctx.arc(112 + i * 5, 24, 1.6, 0, Math.PI * 2);
    ctx.fill();
  }
}

/* ---------- 第二幕：代码打字机 ---------- */
const CODE = [
  'function jump() {',
  '  player.vy = -12;',
  '  sfx.play("boop");',
  '  // 这行别动，动了会炸',
  '}'
];

const TYPING = (function () {
  const ev = [];
  let tm = 0;
  const pushCh = (ch, dt) => { ev.push({ t: tm, ch }); tm += dt; };
  const pushPause = (dt) => { tm += dt; };
  const pushDel = () => { ev.push({ t: tm, del: true }); tm += 0.05; };

  CODE.forEach((line, li) => {
    if (li === 3) pushPause(0.26);              // 遇到注释先停一下
    if (li === 1) {
      // 打错再删：先打 "  plal"，删掉 l，再补完
      const head = '  plal';
      for (const ch of head) pushCh(ch, (/([a-z])/i.test(ch) ? 0.04 : 0.025) + Math.random() * 0.006);
      pushPause(0.30);
      pushDel();
      pushPause(0.08);
      for (const ch of 'yer.vy = -12;') pushCh(ch, (/([a-z])/i.test(ch) ? 0.04 : 0.026) + Math.random() * 0.006);
    } else {
      for (const ch of line) pushCh(ch, (/([a-z])/i.test(ch) ? 0.040 : 0.026) + Math.random() * 0.006);
    }
    pushPause(0.10);
    pushCh('\n', 0.0);
    if (li === 2) pushPause(0.42);              // 思考停顿
  });

  // 每 3–5 行一次思考停顿已内嵌在 li===2 处
  const scale = (T.typingEnd - T.expandEnd) / tm;
  ev.forEach(e => e.t *= scale);
  return ev;
})();

function typedState(radius) {
  let text = '';
  let cursorT = -1;
  for (const e of TYPING) {
    if (e.t > radius) break;
    if (e.del) { text = text.slice(0, -1); cursorT = e.t; }
    else { text += e.ch; cursorT = e.t; }
  }
  return text;
}

function sceneEditor(ctx, t) {
  const W = EXPANDED.w, H = EXPANDED.h;
  px(ctx, 0, 0, W, H, COL.bg);
  ctx.strokeStyle = COL.border;
  ctx.lineWidth = 1;
  ctx.strokeRect(0.5, 0.5, W - 1, H - 1);

  // 顶部条
  const dots = ['#FF5F57', '#FEBC2E', '#28C840'];
  dots.forEach((c, i) => {
    ctx.fillStyle = c;
    ctx.globalAlpha = 0.75;
    ctx.beginPath();
    ctx.arc(13 + i * 11, 11, 3.2, 0, Math.PI * 2);
    ctx.fill();
    ctx.globalAlpha = 1;
  });
  ctx.fillStyle = 'rgba(255,255,255,0.75)';
  ctx.font = '600 10px ui-monospace,SFMono-Regular,Menlo,monospace';
  ctx.fillText('game.js', 52, 15);

  ctx.fillStyle = 'rgba(255,255,255,0.35)';
  ctx.font = '400 9px ui-monospace,SFMono-Regular,Menlo,monospace';
  ctx.textAlign = 'right';
  ctx.fillText('main ▸ 12ms', W - 12, 15);
  ctx.textAlign = 'left';

  px(ctx, 0, 22, W, 1, COL.border);

  // 代码
  const radius = clamp(t - T.expandEnd, 0, T.typingEnd - T.expandEnd);
  const text = typedState(radius);
  const lines = text.split('\n');
  const x0 = 14, y0 = 40, lh = 19.5, charW = 7.1;
  const mono = '500 12px ui-monospace,SFMono-Regular,Menlo,monospace';

  lines.forEach((line, i) => {
    let x = x0;
    const y = y0 + i * lh;
    // 行号
    ctx.fillStyle = 'rgba(255,255,255,0.18)';
    ctx.font = '400 9px ui-monospace,monospace';
    ctx.fillText(String(i + 1).padStart(2, '0'), x0 - 6, y);
    x += 10;

    ctx.font = mono;
    // 语法着色：粗略按前缀判断
    const trimmed = line.trimStart();
    let color = COL.fg;
    if (trimmed.startsWith('//')) color = COL.cmt;
    else if (trimmed.startsWith('function') || trimmed.startsWith('return')) color = COL.kw;
    else if (trimmed.startsWith('sfx') || trimmed.startsWith('player')) color = COL.fg;

    ctx.fillStyle = color;
    ctx.fillText(line, x, y);

    // 字符串高亮（简单处理）
    if (line.includes('"')) {
      const a = line.indexOf('"'), b = line.lastIndexOf('"');
      if (b > a) {
        const sx = x + ctx.measureText(line.slice(0, a)).width;
        ctx.fillStyle = COL.str;
        ctx.fillText(line.slice(a, b + 1), sx, y);
      }
    }
  });

  // 章鱼→螃蟹光标
  const lastLine = lines.length - 1;
  const lastText = lines[lastLine] || '';
  const cx = x0 + 10 + lastText.length * charW;
  const cy = y0 + lastLine * lh;
  const thinking = t > T.expandEnd + 2.4 && t < T.expandEnd + 2.8;
  drawCrab(ctx, cx - 1, cy - 6, 0.72, {
    face: 1,
    legPhase: thinking ? 0 : t * 22,
    blink: thinking,
    armUp: thinking ? 0 : 0.4
  });

  // 进度条
  const prog = clamp((t - T.expandEnd) / (T.typingEnd - T.expandEnd), 0, 1);
  px(ctx, 12, 118, W - 24, 3, '#1C1D21');
  px(ctx, 12, 118, (W - 24) * prog, 3, COL.orange);
  ctx.fillStyle = 'rgba(255,255,255,0.5)';
  ctx.font = '600 8px ui-monospace,monospace';
  ctx.fillText('生成中 ' + Math.round(prog * 100) + '%', 12, 114);
}

/* ---------- 第四幕前置：LGTM 举牌 ---------- */
function sceneLGTM(ctx, t) {
  sceneEditor(ctx, t);
  const p = clamp((t - T.typingEnd) / (T.lgtmEnd - T.typingEnd), 0, 1);
  const jump = Math.sin(p * Math.PI) * 8;
  const cx = 300, cy = 96 - jump;
  drawCrab(ctx, cx - 6, cy - 8, 0.9, { face: 1, legPhase: t * 20, armUp: 1.2 });
  // 像素牌子
  px(ctx, cx + 6, cy - 18, 46, 16, COL.ink);
  px(ctx, cx + 7, cy - 17, 44, 14, COL.brick);
  ctx.fillStyle = '#1A1006';
  ctx.font = '700 9px ui-monospace,monospace';
  ctx.textAlign = 'center';
  ctx.fillText('LGTM', cx + 29, cy - 8);
  ctx.textAlign = 'left';
  // 进度冲满
  px(ctx, 12, 118, 348, 3, COL.orange);
}

/* ---------- 第三幕：像素化编译 ---------- */
let codeSnap = null;
function ensureSnap() {
  if (codeSnap) return;
  codeSnap = document.createElement('canvas');
  codeSnap.width = 372; codeSnap.height = 132;
  sceneEditor(codeSnap.getContext('2d'), T.typingEnd);
}

function sceneShatter(ctx, t) {
  ensureSnap();
  const gt = t - T.lgtmEnd;              // 0 .. 0.52
  const BW = 8, BH = 8;

  // 先铺游戏第一帧（420ms 后淡入）
  if (gt > 0.30) {
    const a = clamp((gt - 0.30) / 0.12, 0, 1);
    ctx.globalAlpha = a;
    sceneGameFrame(ctx, 0.4);
    ctx.globalAlpha = 1;
  }

  // Step1 压缩
  const p1 = clamp(gt / 0.31, 0, 1);
  if (gt < 0.34) {
    const sy = lerp(1, 0.055, easeOut(p1));
    ctx.save();
    ctx.translate(0, 66);
    ctx.scale(1, sy);
    ctx.translate(0, -66);
    ctx.globalAlpha = 1 - 0.35 * p1;
    ctx.drawImage(codeSnap, 0, 0, 372, 132);
    ctx.restore();
    ctx.globalAlpha = 1;
  }

  // Step2/3 裂解 + 坠落
  if (gt >= 0.15 && gt < 0.52) {
    const per = 0.006;
    for (let c = 0; c < 372 / BW; c++) {
      for (let r = 0; r < 6; r++) {
        const srcY = 22 + r * BH;
        if (srcY + BH > 118) continue;
        const appear = clamp((gt - 0.15 - c * per) / 0.05, 0, 1);
        if (appear <= 0) continue;
        const fallT = clamp((gt - 0.30 - c * 0.008) / 0.18, 0, 1);
        const jitter = (Math.random() - 0.5) * 1.2 * (1 - fallT);
        const dy = fallT * fallT * (120 + r * 6);
        ctx.globalAlpha = (1 - fallT) * appear;
        ctx.save();
        ctx.translate(jitter, dy);
        ctx.drawImage(codeSnap, c * BW, srcY, BW, BH, c * BW, srcY, BW, BH);
        ctx.restore();
      }
    }
    ctx.globalAlpha = 1;
    // 扫描线
    if (gt < 0.42) {
      const sy = (gt / 0.42) * 132;
      ctx.fillStyle = 'rgba(255,255,255,0.16)';
      ctx.fillRect(0, sy, 372, 1.2);
    }
  }
}

/* ---------- 第四幕：像素关卡 ---------- */
const G = { W: 128, H: 48, groundY: 40, sc: 2.12 };

function charState(gt) {
  let x = 10, y = 0;
  if (gt < 0.4) x = 10;
  else if (gt < 1.6) x = 10 + (gt - 0.4) / 1.2 * 10;
  else if (gt < 2.3) { const p = (gt - 1.6) / 0.7; x = 20 + p * 8; y = Math.sin(p * Math.PI) * 13; }
  else if (gt < 3.0) x = 28 + (gt - 2.3) / 0.7 * 6;
  else if (gt < 3.4) { const p = (gt - 3.0) / 0.4; x = 34 + p * 2; y = Math.sin(Math.min(p * 1.7, Math.PI)) * 6; }
  else if (gt < 4.2) x = 36 + (gt - 3.4) / 0.8 * 8;
  else if (gt < 5.6) { const p = (gt - 4.2) / 1.4; x = 44 + p * 16; y = Math.sin(p * Math.PI) * 15; }
  else if (gt < 6.6) x = 60 + (gt - 5.6) / 1.0 * 30;
  else if (gt < 7.0) { const p = (gt - 6.6) / 0.4; x = 90 + p * 14; y = Math.sin(p * Math.PI) * 11; }
  else { x = 104; }
  return { x, y };
}

function sceneGameFrame(ctx, gt) {
  // 供裂解重组用：静态第一帧
  const sc = G.sc, W = G.W, H = G.H;
  const ox = (372 - W * sc) / 2, oy = 24;
  ctx.save();
  ctx.translate(ox, oy);
  ctx.scale(sc, sc);
  px(ctx, 0, 0, W, H, COL.sky);
  px(ctx, 0, G.groundY, W, H - G.groundY, COL.ground);
  px(ctx, 0, G.groundY, W, 2, COL.grass);
  drawCrab(ctx, 10, G.groundY - 6, 0.5, { legPhase: 0 });
  ctx.restore();
}

function drawWorldBlock(ctx, x, y, label, dark) {
  const s = 8;
  px(ctx, x, y, s, s, COL.ink);
  px(ctx, x + 1, y + 1, s - 2, s - 2, dark ? '#B4674E' : COL.brick);
  px(ctx, x + 1, y + 1, s - 2, 1.5, dark ? '#D48A6E' : '#FFE08A');
  if (label) {
    ctx.fillStyle = COL.ink;
    ctx.font = '700 4.5px ui-monospace,monospace';
    ctx.textAlign = 'center';
    ctx.fillText(label, x + s / 2, y + s - 2.2);
    ctx.textAlign = 'left';
  }
}

function sceneGame(ctx, t, label) {
  const gt = t - T.shatterEnd;
  const sc = G.sc, W = G.W, H = G.H;
  const ox = (372 - W * sc) / 2, oy = 24;
  const st = charState(gt);
  const cam = clamp(st.x - 40, 0, 60);
  const shake = (gt > 3.4 && gt < 3.82) || (gt > 2.95 && gt < 3.1) ? (Math.random() - 0.5) * 2 : 0;

  ctx.save();
  ctx.translate(ox + shake, oy + shake);
  ctx.scale(sc, sc);

  // 天空
  px(ctx, 0, 0, W, H, COL.sky);
  // 远景山（视差）
  const hillOff = -(cam * 0.35) % 64;
  for (let i = -1; i < 3; i++) {
    const hx = i * 64 + hillOff;
    px(ctx, hx + 8, G.groundY - 10, 26, 10, '#3F7FDB');
    px(ctx, hx + 4, G.groundY - 6, 34, 6, '#3F7FDB');
  }
  // 云
  const cloudOff = -(cam * 0.18) % 80;
  for (let i = 0; i < 3; i++) {
    const cx = i * 80 + cloudOff + 10;
    px(ctx, cx, 8, 14, 3, '#E8F4FF');
    px(ctx, cx + 3, 5, 8, 3, '#E8F4FF');
  }

  // 地面砖
  px(ctx, 0, G.groundY, W, H - G.groundY, COL.brown || '#8B5A2B');
  px(ctx, 0, G.groundY, W, 1.5, COL.grass);
  for (let bx = -8; bx < W + 8; bx += 8) {
    const wx = bx - (cam % 8);
    px(ctx, wx, G.groundY + 2, 7, 1, '#6E4521');
  }

  // 砖块（BUG / undefined）
  const blocks = [
    { x: 20, y: 28, label: 'BUG', dark: false, hit: gt > 1.95 && gt < 2.35 },
    { x: 44, y: 28, label: 'undef', dark: true, hit: gt > 3.4 && gt < 4.0 }
  ];
  blocks.forEach(b => {
    const bx = b.x - cam, by = b.y + (b.hit ? -2 : 0);
    if (bx > -10 && bx < W + 10) drawWorldBlock(ctx, bx, by, b.label, b.dark);
  });

  // 金币 PROD
  if (gt > 1.85 && gt < 3.2) {
    const p = clamp((gt - 1.85) / 0.5, 0, 1);
    const cy = 24 - p * 14;
    const cx = 24 - cam;
    px(ctx, cx, cy, 6, 6, COL.ink);
    px(ctx, cx + 1, cy + 1, 4, 4, COL.brick);
    ctx.fillStyle = '#1A1006';
    ctx.font = '700 3.4px ui-monospace,monospace';
    ctx.textAlign = 'center';
    ctx.fillText('PROD', cx + 3, cy + 4.6);
    ctx.textAlign = 'left';
  }

  // 小 bug 怪
  if (gt > 2.35 && gt < 3.5) {
    const p = clamp((gt - 2.35) / 1.15, 0, 1);
    const bx = lerp(52, 38, p) - cam;
    const by = G.groundY - 5;
    const squashed = gt > 3.0;
    if (squashed) {
      px(ctx, bx, by + 3, 7, 2, '#7A3B2A');
      px(ctx, bx - 1, by + 4, 9, 1.4, COL.ink);
    } else {
      px(ctx, bx, by, 6, 5, '#7A3B2A');
      px(ctx, bx + 1, by + 1, 1.5, 1.5, '#E0432A');
      px(ctx, bx + 4, by + 1, 1.5, 1.5, '#E0432A');
      px(ctx, bx - 1, by + 3, 1.5, 2, COL.ink);
      px(ctx, bx + 5.5, by + 3, 1.5, 2, COL.ink);
    }
  }

  // 旗杆（半旗）
  const fx = 104 - cam;
  if (fx < W + 6) {
    px(ctx, fx, G.groundY - 22, 1.5, 22, '#E8E8E8');
    const flagDown = gt > 6.9 ? 10 : 2;
    px(ctx, fx + 2, G.groundY - 22 + flagDown, 7, 5, '#E0432A');
  }

  // 主角：戴安全帽的 Claw'd
  const cx = st.x - cam;
  const cy = G.groundY - 7 - st.y;
  drawCrab(ctx, cx - 1, cy, 0.5, {
    legPhase: gt * 14,
    blink: false,
    armUp: st.y > 0 ? 0.8 : 0.2
  });
  // 安全帽
  px(ctx, cx - 1.5, cy - 2.5, 8, 2.5, COL.brick);
  px(ctx, cx - 2.5, cy - 0.6, 10, 1, '#D9A62E');

  // 撞 undefined 时的抖动云
  if (gt > 3.4 && gt < 3.9) {
    ctx.fillStyle = 'rgba(255,255,255,0.55)';
    ctx.font = '700 4px ui-monospace,monospace';
    ctx.fillText('!', cx + 2, cy - 4);
  }

  ctx.restore();

  // 顶栏 / 底部进度
  ctx.fillStyle = 'rgba(255,255,255,0.7)';
  ctx.font = '600 9px ui-monospace,monospace';
  ctx.fillText(label ? label : 'PREVIEW · game.js', 12, 16);
  ctx.fillStyle = 'rgba(255,255,255,0.35)';
  ctx.font = '400 8px ui-monospace,monospace';
  ctx.textAlign = 'right';
  ctx.fillText('60 fps', 360, 16);
  ctx.textAlign = 'left';

  const prog = clamp((gt - 0.4) / 7.1, 0, 1);
  px(ctx, 12, 118, 348, 3, '#1C1D21');
  px(ctx, 12, 118, 348 * prog, 3, COL.orange);
  ctx.fillStyle = 'rgba(255,255,255,0.5)';
  ctx.font = '600 8px ui-monospace,monospace';
  ctx.fillText(Math.round(prog * 100) + '%', 12, 114);

  // 上电扫描线
  if (gt < 0.4) {
    const p = gt / 0.4;
    ctx.fillStyle = 'rgba(0,0,0,' + (1 - p * 0.9) + ')';
    ctx.fillRect(0, 0, 372, 132);
    ctx.fillStyle = 'rgba(255,255,255,0.25)';
    ctx.fillRect(0, 24 + (1 - p) * (104 - 2), 372, p > 0.9 ? 104 : 2);
  }

  // 飘字
  const popups = [
    { t0: 2.0, txt: '+PROD', x: 24 - cam, y: 22 },
    { t0: 3.05, txt: '+1 XP', x: 34 - cam, y: 30 },
    { t0: 3.5, txt: 'undefined!', x: 44 - cam, y: 24 }
  ];
  popups.forEach(p => {
    const age = gt - p.t0;
    if (age > 0 && age < 1.1) {
      ctx.globalAlpha = 1 - age / 1.1;
      ctx.fillStyle = '#FFE08A';
      ctx.font = '700 9px ui-monospace,monospace';
      ctx.fillText(p.txt, ox + p.x * sc, oy + (p.y - age * 12) * sc);
      ctx.globalAlpha = 1;
    }
  });
}

/* ---------- 第七幕：结算 ---------- */
function sceneResult(ctx, t) {
  const p = clamp((t - T.gameEnd) / 0.9, 0, 1);
  sceneGameFrame(ctx, 7.5);
  ctx.fillStyle = 'rgba(6,6,10,' + (0.55 + p * 0.3) + ')';
  ctx.fillRect(0, 0, 372, 132);

  const txt1 = 'COMPILE OK';
  const txt2 = 'LOCAL ONLY';
  const n1 = Math.floor(clamp(p * 2, 0, 1) * txt1.length);
  const n2 = Math.floor(clamp(p * 2 - 1, 0, 1) * txt2.length);

  ctx.textAlign = 'center';
  ctx.fillStyle = COL.brick;
  ctx.font = '800 22px ui-monospace,monospace';
  ctx.fillText(txt1.slice(0, n1), 186, 66);
  ctx.fillStyle = COL.orange;
  ctx.font = '800 18px ui-monospace,monospace';
  ctx.fillText(txt2.slice(0, n2), 186, 92);
  ctx.textAlign = 'left';

  ctx.fillStyle = 'rgba(255,255,255,0.42)';
  ctx.font = '400 9px -apple-system,"PingFang SC",sans-serif';
  ctx.textAlign = 'center';
  if (p > 0.7) ctx.fillText('Deploy 成功 · 其实只是本地能跑', 186, 112);
  ctx.textAlign = 'left';
}

/* ---------- 展开态总调度 ---------- */
function drawExpanded(ctx, t) {
  if (t < T.typingEnd) sceneEditor(ctx, t);
  else if (t < T.lgtmEnd) sceneLGTM(ctx, t);
  else if (t < T.shatterEnd) sceneShatter(ctx, t);
  else if (t < T.gameEnd) sceneGame(ctx, t);
  else sceneResult(ctx, t);
}

/* ---------- 收起态（余味） ---------- */
function sceneCompactAfter(ctx, t) {
  sceneCompact(ctx, t);
  // 覆盖右侧文案
  ctx.fillStyle = 'rgba(0,0,0,1)';
  if (t > T.collapseEnd && t < T.collapseEnd + 3) {
    ctx.fillStyle = '#0A0A0C';
    ctx.fillRect(48, 8, 72, 22);
    ctx.fillStyle = '#F5F5F7';
    ctx.font = '600 11px -apple-system,"PingFang SC",sans-serif';
    ctx.fillText('Claw\'d 完成了', 52, 15);
    ctx.fillStyle = 'rgba(255,255,255,0.42)';
    ctx.font = '400 9px -apple-system,"PingFang SC",sans-serif';
    ctx.fillText('1 个任务', 52, 27);
  }
}

/* ---------- 画布 / 主循环 ---------- */
const islandEl = document.getElementById('island');
const islandCanvas = document.getElementById('islandCanvas');
const zoomEl = document.getElementById('zoomIsland');
const zoomCanvas = document.getElementById('zoomCanvas');
const BASE_PX_PER_MM = 3.7795;
let pxPerMm = BASE_PX_PER_MM;
let t = 0, playing = true, last = performance.now();

function ptPx() { return pxPerMm * 0.16566; }

function sizeCanvas(canvas, w, h) {
  const dpr = window.devicePixelRatio || 1;
  canvas.style.width = w + 'px';
  canvas.style.height = h + 'px';
  const bw = Math.max(1, Math.round(w * dpr));
  const bh = Math.max(1, Math.round(h * dpr));
  if (canvas.width !== bw || canvas.height !== bh) {
    canvas.width = bw; canvas.height = bh;
  }
  return { w, h, dpr };
}

function drawScene(canvas, t) {
  const sz = islandSize(t);
  const dpr = window.devicePixelRatio || 1;
  const cw = canvas.width / dpr, ch = canvas.height / dpr;
  const compact = t < T.patrol || t >= T.collapseEnd;
  const dw = compact ? COMPACT.w : EXPANDED.w;
  const dh = compact ? COMPACT.h : EXPANDED.h;
  const fit = Math.min(cw / dw, ch / dh);
  const ox = (cw - dw * fit) / 2;
  const oy = (ch - dh * fit) / 2;
  const ctx = canvas.getContext('2d');

  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.setTransform(fit * dpr, 0, 0, fit * dpr, ox * dpr, oy * dpr);
  ctx.imageSmoothingEnabled = false;

  if (compact) {
    if (t >= T.collapseEnd) sceneCompactAfter(ctx, t); else sceneCompact(ctx, t);
    return;
  }

  let alpha = 1, sc = 1;
  if (t < T.patrol + 0.35) {
    alpha = clamp((t - (T.patrol + 0.03)) / 0.2, 0, 1);
    sc = lerp(0.92, 1, alpha);
  }
  if (t > T.resultEnd) {
    const q = (t - T.resultEnd) / (T.collapseEnd - T.resultEnd);
    alpha = 1 - q;
    sc = lerp(1, 0.6, q);
  }
  ctx.globalAlpha = alpha;
  ctx.save();
  ctx.translate(dw / 2, dh / 2);
  ctx.scale(sc, sc);
  ctx.translate(-dw / 2, -dh / 2);
  drawExpanded(ctx, t);
  ctx.restore();
  ctx.globalAlpha = 1;
}

function layout() {
  const sz = islandSize(t);
  const k = ptPx();
  const w = Math.max(20, sz.w * k), h = Math.max(6, sz.h * k);
  sizeCanvas(islandCanvas, w, h);
  islandEl.style.borderRadius = (sz.r * k) + 'px';

  const zw = 340;
  const zh = zw * (sz.h / sz.w);
  sizeCanvas(zoomCanvas, zw, zh);
  zoomEl.style.borderRadius = (sz.r * (zw / sz.w)) + 'px';
}

const fillEl = document.getElementById('fill');
const tNowEl = document.getElementById('tNow');
const actsEl = document.getElementById('acts');

function frame(now) {
  const dt = Math.min(0.05, (now - last) / 1000);
  last = now;
  if (playing) {
    t += dt;
    if (t >= T.total) t = 0;
  }
  layout();
  drawScene(islandCanvas, t);
  drawScene(zoomCanvas, t);

  const p = clamp(t / 17.0, 0, 1);
  fillEl.style.width = (p * 100) + '%';
  tNowEl.textContent = t.toFixed(2) + 's';

  const marks = [0, T.patrol, T.lgtmEnd, T.shatterEnd, T.resultEnd];
  let cur = 0;
  for (let i = 0; i < marks.length; i++) if (t >= marks[i]) cur = i;
  Array.from(actsEl.children).forEach((el, i) => el.classList.toggle('cur', i === cur));

  requestAnimationFrame(frame);
}

/* ---------- 交互 ---------- */
const btnPlay = document.getElementById('btnPlay');
btnPlay.onclick = () => {
  playing = !playing;
  btnPlay.textContent = playing ? '暂停' : '播放';
  btnPlay.classList.toggle('on', playing);
};
document.getElementById('btnReplay').onclick = () => { t = 0; playing = true; btnPlay.textContent = '暂停'; btnPlay.classList.add('on'); };

Array.from(actsEl.children).forEach(el => {
  el.onclick = () => { t = parseFloat(el.dataset.t); };
});

const calib = document.getElementById('calib');
const calibVal = document.getElementById('calibVal');
function applyCalib() {
  pxPerMm = BASE_PX_PER_MM * (parseFloat(calib.value) / 100);
  document.documentElement.style.setProperty('--mm', pxPerMm + 'px');
  calibVal.textContent = '1 mm = ' + pxPerMm.toFixed(2) + ' px ｜ 灵动岛宽 ' + (20.9 * pxPerMm).toFixed(0) + ' px';
  layout();
}
calib.addEventListener('input', applyCalib);
document.getElementById('btnCalib').onclick = () => { calib.value = 100; applyCalib(); };

applyCalib();
requestAnimationFrame(frame);

