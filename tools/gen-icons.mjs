#!/usr/bin/env node
// Phase 6 T3: traces the wireframe's stroked SVG icons into Roblox icon data (no npm deps).
//   node tools/gen-icons.mjs           # writes roblox/src/shared/CowHUD/IconData.luau
//   node tools/gen-icons.mjs --check   # exit code 1 if IconData.luau is stale
// Source: every <svg data-icon="name"> in index.html (24×24 viewBox, stroked, fill none). Paths (M L H V Z C S Q T A,
// absolute and relative), rect (incl. rx), circle, ellipse, line, polyline and polygon are flattened into polylines in
// SVG units. Icons.luau draws each segment as a round-capped Frame. A zero-length subpath (e.g. `h.01`) becomes a dot.
// Filled icons are out of scope (Frames cannot fill an arbitrary polygon) and fail the run.

import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const ROOT = resolve(import.meta.dirname, '..');
const HTML = resolve(ROOT, 'index.html');
const OUT = resolve(ROOT, 'roblox/src/shared/CowHUD/IconData.luau');
const SEGMENT = 1.5; // target curve segment length in SVG units (24 per icon): smooth at 24px, few Frames
const STRAIGHT = Math.cos((4 * Math.PI) / 180); // merge consecutive segments that turn by less than 4°

const attr = (tag, name) => tag.match(new RegExp(`\\s${name}="([^"]*)"`))?.[1];
const num = (tag, name, fallback = 0) => Number(attr(tag, name) ?? fallback);

// ---------- path flattening ----------
function cubic(p0, p1, p2, p3) {
    const len = Math.hypot(p1[0] - p0[0], p1[1] - p0[1]) + Math.hypot(p2[0] - p1[0], p2[1] - p1[1]) + Math.hypot(p3[0] - p2[0], p3[1] - p2[1]);
    const n = Math.max(2, Math.ceil(len / SEGMENT));
    const out = [];
    for (let i = 1; i <= n; i++) {
        const t = i / n, u = 1 - t;
        out.push([0, 1].map(k => u * u * u * p0[k] + 3 * u * u * t * p1[k] + 3 * u * t * t * p2[k] + t * t * t * p3[k]));
    }
    return out;
}
const quad = (p0, p1, p2) => cubic(p0, p0.map((v, k) => v + (2 / 3) * (p1[k] - v)), p2.map((v, k) => v + (2 / 3) * (p1[k] - v)), p2);

// SVG endpoint arc → centre parameterisation (SVG 1.1 implementation notes F.6.5).
function arc(p0, rx, ry, phiDeg, large, sweep, p1) {
    if (rx === 0 || ry === 0) return [p1];
    rx = Math.abs(rx); ry = Math.abs(ry);
    const phi = (phiDeg * Math.PI) / 180, cos = Math.cos(phi), sin = Math.sin(phi);
    const dx = (p0[0] - p1[0]) / 2, dy = (p0[1] - p1[1]) / 2;
    const x1 = cos * dx + sin * dy, y1 = -sin * dx + cos * dy;
    const lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry);
    if (lambda > 1) { rx *= Math.sqrt(lambda); ry *= Math.sqrt(lambda); }
    const num_ = rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1;
    const coef = (large === sweep ? -1 : 1) * Math.sqrt(Math.max(0, num_ / (rx * rx * y1 * y1 + ry * ry * x1 * x1)));
    const cx1 = (coef * rx * y1) / ry, cy1 = (-coef * ry * x1) / rx;
    const cx = cos * cx1 - sin * cy1 + (p0[0] + p1[0]) / 2, cy = sin * cx1 + cos * cy1 + (p0[1] + p1[1]) / 2;
    const angle = (ux, uy, vx, vy) => Math.atan2(ux * vy - uy * vx, ux * vx + uy * vy);
    const t0 = angle(1, 0, (x1 - cx1) / rx, (y1 - cy1) / ry);
    let dt = angle((x1 - cx1) / rx, (y1 - cy1) / ry, (-x1 - cx1) / rx, (-y1 - cy1) / ry);
    if (!sweep && dt > 0) dt -= 2 * Math.PI;
    if (sweep && dt < 0) dt += 2 * Math.PI;
    const n = Math.max(2, Math.ceil((Math.abs(dt) * Math.max(rx, ry)) / SEGMENT));
    const out = [];
    for (let i = 1; i <= n; i++) {
        const t = t0 + (dt * i) / n, ex = rx * Math.cos(t), ey = ry * Math.sin(t);
        out.push(i === n ? p1 : [cos * ex - sin * ey + cx, sin * ex + cos * ey + cy]);
    }
    return out;
}

function parsePath(d) {
    const tokens = d.match(/[a-zA-Z]|-?(?:\d*\.\d+|\d+\.?)(?:e[-+]?\d+)?/g) ?? [];
    const polys = [];
    let i = 0, cmd = null, cur = [0, 0], start = [0, 0], poly = null, lastCtrl = null, lastCmd = null;
    const isCmd = t => /^[a-zA-Z]$/.test(t);
    const take = () => Number(tokens[i++]);
    // Arc flags may be packed without separators ("a1 1 0 000 1.4"): read them one digit at a time.
    const flag = () => {
        const t = tokens[i];
        if (t.length > 1 && /^[01]/.test(t)) { tokens[i] = t.slice(1); return Number(t[0]); }
        i++;
        return Number(t);
    };
    const point = rel => { const x = take(), y = take(); return rel ? [cur[0] + x, cur[1] + y] : [x, y]; };
    const lineTo = p => { poly.push(p); cur = p; };
    while (i < tokens.length) {
        if (isCmd(tokens[i])) cmd = tokens[i++];
        else if (cmd === null) throw new Error(`path data must start with a command: ${d}`);
        const rel = cmd === cmd.toLowerCase(), C = cmd.toUpperCase();
        if (C === 'M') {
            cur = point(rel); start = cur; poly = [cur]; polys.push(poly);
            cmd = rel ? 'l' : 'L'; // extra coordinate pairs after M are line-tos
            lastCtrl = null; lastCmd = 'M';
            continue;
        }
        if (!poly) { poly = [cur]; polys.push(poly); }
        let ctrl = null;
        if (C === 'Z') { lineTo(start); poly = null; cur = start; lastCmd = 'Z'; lastCtrl = null; continue; }
        if (C === 'L') lineTo(point(rel));
        else if (C === 'H') { const x = take(); lineTo([rel ? cur[0] + x : x, cur[1]]); }
        else if (C === 'V') { const y = take(); lineTo([cur[0], rel ? cur[1] + y : y]); }
        else if (C === 'C' || C === 'S') {
            const c1 = C === 'C' ? point(rel)
                : lastCtrl && 'CS'.includes(lastCmd) ? [2 * cur[0] - lastCtrl[0], 2 * cur[1] - lastCtrl[1]] : cur;
            const c2 = point(rel), p = point(rel);
            cubic(cur, c1, c2, p).forEach(lineTo);
            ctrl = c2;
        } else if (C === 'Q' || C === 'T') {
            const c1 = C === 'Q' ? point(rel)
                : lastCtrl && 'QT'.includes(lastCmd) ? [2 * cur[0] - lastCtrl[0], 2 * cur[1] - lastCtrl[1]] : cur;
            const p = point(rel);
            quad(cur, c1, p).forEach(lineTo);
            ctrl = c1;
        } else if (C === 'A') {
            const rx = take(), ry = take(), rot = take(), large = flag(), sweep = flag(), p = point(rel);
            arc(cur, rx, ry, rot, large, sweep, p).forEach(lineTo);
        } else throw new Error(`unsupported path command ${cmd} in: ${d}`);
        lastCtrl = ctrl; lastCmd = C;
    }
    return polys;
}

function ellipse(cx, cy, rx, ry) {
    const n = Math.max(8, Math.ceil((2 * Math.PI * Math.max(rx, ry)) / SEGMENT));
    return [Array.from({ length: n + 1 }, (_, i) => [cx + rx * Math.cos((2 * Math.PI * i) / n), cy + ry * Math.sin((2 * Math.PI * i) / n)])];
}

function shape(tag) {
    const name = tag.match(/^<(\w+)/)[1];
    if (name === 'path') return parsePath(attr(tag, 'd'));
    if (name === 'circle') return ellipse(num(tag, 'cx'), num(tag, 'cy'), num(tag, 'r'), num(tag, 'r'));
    if (name === 'ellipse') return ellipse(num(tag, 'cx'), num(tag, 'cy'), num(tag, 'rx'), num(tag, 'ry'));
    if (name === 'line') return [[[num(tag, 'x1'), num(tag, 'y1')], [num(tag, 'x2'), num(tag, 'y2')]]];
    if (name === 'polyline' || name === 'polygon') {
        const v = attr(tag, 'points').trim().split(/[\s,]+/).map(Number);
        const pts = Array.from({ length: v.length / 2 }, (_, i) => [v[2 * i], v[2 * i + 1]]);
        if (name === 'polygon') pts.push(pts[0]);
        return [pts];
    }
    if (name === 'rect') {
        const x = num(tag, 'x'), y = num(tag, 'y'), w = num(tag, 'width'), h = num(tag, 'height');
        const r = Math.min(num(tag, 'rx', attr(tag, 'ry') ?? 0), w / 2, h / 2);
        if (!r) return [[[x, y], [x + w, y], [x + w, y + h], [x, y + h], [x, y]]];
        return parsePath(`M${x + r} ${y}H${x + w - r}A${r} ${r} 0 0 1 ${x + w} ${y + r}V${y + h - r}A${r} ${r} 0 0 1 ${x + w - r} ${y + h}`
            + `H${x + r}A${r} ${r} 0 0 1 ${x} ${y + h - r}V${y + r}A${r} ${r} 0 0 1 ${x + r} ${y}Z`);
    }
    throw new Error(`unsupported SVG element <${name}>`);
}

// Drops repeated points and merges nearly straight runs, so each polyline uses as few Frames as it needs.
function simplify(pts) {
    const out = [];
    for (const p of pts) {
        const last = out.at(-1);
        if (last && Math.hypot(p[0] - last[0], p[1] - last[1]) < 1e-3) continue;
        if (out.length >= 2) {
            const a = out.at(-2), ux = last[0] - a[0], uy = last[1] - a[1], vx = p[0] - last[0], vy = p[1] - last[1];
            if ((ux * vx + uy * vy) / (Math.hypot(ux, uy) * Math.hypot(vx, vy)) > STRAIGHT) out.pop();
        }
        out.push(p);
    }
    return out.length ? out : [pts[0]];
}

// ---------- extract ----------
const html = readFileSync(HTML, 'utf8');
const icons = {};
for (const m of html.matchAll(/<svg\b([^>]*)>([\s\S]*?)<\/svg>/g)) {
    const name = attr(m[1], 'data-icon');
    if (!name) continue;
    if (attr(m[1], 'viewBox') !== '0 0 24 24') throw new Error(`${name}: viewBox must be 0 0 24 24`);
    const filled = (tag) => { const fill = attr(tag, 'fill'); return fill && fill !== 'none'; };
    const cls = attr(m[1], 'class') ?? '';
    if (/\bfill-(?!none\b)/.test(cls) || filled(m[1]) || [...m[2].matchAll(/<\w+[^>]*>/g)].some(t => filled(t[0]))) {
        throw new Error(`${name}: filled icons are not supported (Frames cannot fill a polygon)`);
    }
    const polys = [...m[2].matchAll(/<(path|circle|ellipse|line|polyline|polygon|rect)\b[^>]*>/g)].flatMap(t => shape(t[0])).map(simplify);
    if (icons[name] && JSON.stringify(icons[name]) !== JSON.stringify(polys)) throw new Error(`${name}: two different SVGs share this data-icon`);
    icons[name] = polys;
}

// ---------- emit ----------
const r = v => Number(v.toFixed(2));
const names = Object.keys(icons).sort();
let segments = 0;
const body = names.map(name => {
    const polys = icons[name].map(pts => { segments += Math.max(1, pts.length - 1); return `{ ${pts.flatMap(p => p.map(r)).join(', ')} }`; });
    return `\t${name} = {\n${polys.map(p => `\t\t${p},`).join('\n')}\n\t},`;
}).join('\n');
const out = `-- Icon outlines (generated by tools/gen-icons.mjs from the <svg data-icon> elements in index.html; do not edit).
-- Each icon is a list of polylines { x1, y1, x2, y2, ... } in 24×24 SVG units; a single point is a dot.

return table.freeze({
${body}
})
`;

const check = process.argv.includes('--check');
let current = null;
try { current = readFileSync(OUT, 'utf8'); } catch {}
const summary = `${names.length} icons, ${segments} segments`;
if (current === out) console.log(`icons up to date (${summary})`);
else if (check) { console.error('STALE roblox/src/shared/CowHUD/IconData.luau: run node tools/gen-icons.mjs'); process.exit(1); }
else { writeFileSync(OUT, out); console.log(`wrote roblox/src/shared/CowHUD/IconData.luau (${summary})`); }
