#!/usr/bin/env node
// Phase 6 T4: checks every palette preset in tokens.json for contrast and colour-blind safety (no npm deps).
//   node tools/check-palette.mjs        # exit code 1 if any check fails
// For normal vision and for simulated protanopia, deuteranopia and tritanopia (Machado et al. 2009, severity 1.0):
//   - WCAG 2.2 contrast: Text ≥ 4.5:1 on Card, Screen and Fill; Accent ≥ 4.5:1 on Card; Border ≥ 3:1 on Card and Screen
//   - distinguishability: CIEDE2000 ΔE ≥ 10 between role pairs that carry meaning
//       Fill / Subtle    selected vs idle catalog cost chip, progress fills
//       Border / Card    button and card outlines
//       Accent / Fill    selected vs idle catalog slot outline
//       Danger / Text    destructive tool vs ordinary tools

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const tokens = JSON.parse(readFileSync(resolve(import.meta.dirname, '..', 'tokens.json'), 'utf8'));
const { order, presets } = tokens.palette;

const CONTRAST = [
    ['Text', 'Card', 4.5], ['Text', 'Screen', 4.5], ['Text', 'Fill', 4.5],
    ['Accent', 'Card', 4.5],
    ['Border', 'Card', 3], ['Border', 'Screen', 3],
];
const DISTINCT = [['Fill', 'Subtle'], ['Border', 'Card'], ['Accent', 'Fill'], ['Danger', 'Text']];
const MIN_DELTA_E = 10;

// Machado, Oliveira & Fernandes 2009, severity 1.0; applied to linear RGB.
const VISION = {
    normal: null,
    protanopia: [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]],
    deuteranopia: [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.011820, 0.042940, 0.968881]],
    tritanopia: [[1.255528, -0.076749, -0.178779], [-0.078411, 0.930809, 0.147602], [0.004733, 0.691367, 0.303900]],
};

const toLinear = c => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
const linearRgb = hex => [1, 3, 5].map(i => toLinear(parseInt(hex.slice(i, i + 2), 16) / 255));
const simulate = (rgb, m) => (m ? m.map(row => Math.min(1, Math.max(0, row[0] * rgb[0] + row[1] * rgb[1] + row[2] * rgb[2]))) : rgb);

const luminance = ([r, g, b]) => 0.2126 * r + 0.7152 * g + 0.0722 * b;
function contrast(a, b) {
    const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
    return (hi + 0.05) / (lo + 0.05);
}

function lab([r, g, b]) {
    // linear sRGB → XYZ (D65) → CIELAB
    const x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047;
    const y = 0.2126729 * r + 0.7151522 * g + 0.0721750 * b;
    const z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883;
    const f = t => (t > 216 / 24389 ? Math.cbrt(t) : (24389 / 27 * t + 16) / 116);
    return [116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z))];
}

// CIEDE2000 (Sharma, Wu & Dalal 2005), kL = kC = kH = 1.
function deltaE2000([L1, a1, b1], [L2, a2, b2]) {
    const rad = Math.PI / 180;
    const C1 = Math.hypot(a1, b1), C2 = Math.hypot(a2, b2), Cbar = (C1 + C2) / 2;
    const G = 0.5 * (1 - Math.sqrt(Cbar ** 7 / (Cbar ** 7 + 25 ** 7)));
    const a1p = (1 + G) * a1, a2p = (1 + G) * a2;
    const C1p = Math.hypot(a1p, b1), C2p = Math.hypot(a2p, b2);
    const hue = (b, a) => (a === 0 && b === 0 ? 0 : (Math.atan2(b, a) / rad + 360) % 360);
    const h1p = hue(b1, a1p), h2p = hue(b2, a2p);
    const dLp = L2 - L1, dCp = C2p - C1p;
    let dhp = 0;
    if (C1p * C2p !== 0) dhp = Math.abs(h2p - h1p) <= 180 ? h2p - h1p : h2p - h1p > 180 ? h2p - h1p - 360 : h2p - h1p + 360;
    const dHp = 2 * Math.sqrt(C1p * C2p) * Math.sin((dhp / 2) * rad);
    const Lbp = (L1 + L2) / 2, Cbp = (C1p + C2p) / 2;
    let hbp = h1p + h2p;
    if (C1p * C2p !== 0) hbp = Math.abs(h1p - h2p) <= 180 ? (h1p + h2p) / 2 : h1p + h2p < 360 ? (h1p + h2p + 360) / 2 : (h1p + h2p - 360) / 2;
    const T = 1 - 0.17 * Math.cos((hbp - 30) * rad) + 0.24 * Math.cos(2 * hbp * rad) + 0.32 * Math.cos((3 * hbp + 6) * rad) - 0.2 * Math.cos((4 * hbp - 63) * rad);
    const dTheta = 30 * Math.exp(-(((hbp - 275) / 25) ** 2));
    const RC = 2 * Math.sqrt(Cbp ** 7 / (Cbp ** 7 + 25 ** 7));
    const SL = 1 + (0.015 * (Lbp - 50) ** 2) / Math.sqrt(20 + (Lbp - 50) ** 2);
    const SC = 1 + 0.045 * Cbp, SH = 1 + 0.015 * Cbp * T;
    const RT = -Math.sin(2 * dTheta * rad) * RC;
    return Math.sqrt((dLp / SL) ** 2 + (dCp / SC) ** 2 + (dHp / SH) ** 2 + RT * (dCp / SC) * (dHp / SH));
}

let failures = 0;
for (const name of order) {
    const preset = presets[name];
    const lines = [];
    for (const [vision, matrix] of Object.entries(VISION)) {
        const color = role => simulate(linearRgb(preset[role]), matrix);
        const results = [
            ...CONTRAST.map(([fg, bg, min]) => {
                const ratio = contrast(color(fg), color(bg));
                return { ok: ratio >= min, text: `${fg}/${bg} ${ratio.toFixed(2)}:1 (min ${min})` };
            }),
            ...DISTINCT.map(([a, b]) => {
                const dE = deltaE2000(lab(color(a)), lab(color(b)));
                return { ok: dE >= MIN_DELTA_E, text: `${a}/${b} ΔE ${dE.toFixed(1)} (min ${MIN_DELTA_E})` };
            }),
        ];
        const failed = results.filter(r => !r.ok);
        failures += failed.length;
        lines.push(`  ${failed.length ? 'FAIL' : 'PASS'}  ${vision.padEnd(13)}${failed.map(r => r.text).join('; ')}`);
    }
    console.log(`${name}\n${lines.join('\n')}`);
}
console.log(failures ? `${failures} check(s) failed` : 'all palette checks passed');
process.exit(failures ? 1 : 0);
