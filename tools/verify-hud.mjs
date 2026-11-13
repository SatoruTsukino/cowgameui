#!/usr/bin/env node
// Phase 5 T7: checks the index.html HUD preview across the device matrix with headless Chrome (no npm deps).
//   node tools/verify-hud.mjs            # exit code 1 if any check fails
// It first checks that every data-rbx path names Roblox instances (checkRbxMap). Then for every preset × page it asserts:
//   - no two HUD groups overlap (the safe-zone outlines count: they stand in for the native touch controls)
//   - every visible text renders ≥ 11pt on the simulated device (≥ 12pt for text-xs / text-sm labels)
// Roblox runs the same rules live; see roblox/README.md "Verifying" for the Studio check.

import { spawn } from 'node:child_process';
import { mkdtempSync, readdirSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const CHROME = process.env.CHROME ?? '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const PAGE = pathToFileURL(resolve(import.meta.dirname, '..', 'index.html')).href;
const PRESETS = ['aspect-video', 'aspect-21-9', 'aspect-4-3', 'aspect-19-5-9'];
const PAGES = ['pasture', 'building'];

// Phase 6 T2: every `data-rbx="A/B/C"` path segment in index.html must name a Roblox instance, i.e. appear as a
// string literal in the CowHUD Luau sources (static `Name = "…"` or data-driven names such as `action = "Moo"`).
// Static check, no Chrome needed. Luau `Name = "…"` literals no data-rbx path uses are listed for information only:
// structural frames (Border, Fill, Track, …) have no HTML element of their own.
function checkRbxMap() {
    const root = resolve(import.meta.dirname, '..');
    const luauDir = join(root, 'roblox/src/shared/CowHUD');
    const sources = readdirSync(luauDir, { recursive: true }).filter(f => f.endsWith('.luau'))
        .map(f => readFileSync(join(luauDir, f), 'utf8'));
    const literals = new Set(sources.flatMap(s => [...s.matchAll(/"([A-Za-z][A-Za-z0-9]*)"/g)].map(m => m[1])));
    const html = readFileSync(join(root, 'index.html'), 'utf8');
    const paths = [...html.matchAll(/data-rbx="([^"]+)"/g)].map(m => m[1]);
    const missing = paths.filter(p => p.split('/').some(seg => !literals.has(seg)));
    const used = new Set(paths.flatMap(p => p.split('/')));
    const names = new Set(sources.flatMap(s => [...s.matchAll(/Name = "([A-Za-z0-9]+)"/g)].map(m => m[1])));
    const unmapped = [...names].filter(n => !used.has(n)).sort();
    console.log(`${missing.length ? 'FAIL' : 'PASS'}  data-rbx map: ${paths.length} paths`
        + (missing.length ? `\n      no Luau instance named: ${missing.join('; ')}` : '')
        + `\n      info, Luau names without an HTML element: ${unmapped.join(' ')}`);
    return missing.length === 0;
}

// Runs inside the page. Returns { overlaps: [...], smallText: [...] }.
function audit() {
    const page = document.querySelector('#pagePasture:not(.hidden), #pageBuilding:not(.hidden)');
    const visible = el => el.offsetParent !== null && getComputedStyle(el).visibility !== 'hidden';
    const groups = [
        ...[...page.children].filter(el => getComputedStyle(el).position === 'absolute' && visible(el)),
        ...['safeZoneLeft', 'safeZoneRight'].map(id => document.getElementById(id)).filter(el => el && visible(el)),
    ].filter(el => !el.hasAttribute('data-verify-skip')).filter(el => !el.classList.contains('pointer-events-none') || el.id.startsWith('safeZone') || el.querySelector('.pointer-events-auto, button'));
    const name = el => el.id || el.className.split(' ').slice(0, 3).join('.');
    // Decorative layers (placement boundary, CoreGui mock) are excluded by the pointer-events filter above.
    const rects = groups.map(el => [name(el), el.getBoundingClientRect()]);
    const overlaps = [];
    for (let i = 0; i < rects.length; i++) {
        for (let j = i + 1; j < rects.length; j++) {
            const [a, ra] = rects[i], [b, rb] = rects[j];
            const w = Math.min(ra.right, rb.right) - Math.max(ra.left, rb.left);
            const h = Math.min(ra.bottom, rb.bottom) - Math.max(ra.top, rb.top);
            if (w > 1 && h > 1) overlaps.push(`${a} × ${b}`);
        }
    }
    const smallText = [];
    for (const el of page.parentElement.querySelectorAll('*')) {
        if (el.closest('[data-verify-skip]')) continue; // world-space / CoreGui mock-ups, not HUD text
        if (!visible(el) || ![...el.childNodes].some(n => n.nodeType === 3 && n.textContent.trim())) continue;
        const label = el.classList.contains('text-xs') || el.classList.contains('text-sm');
        const pt = parseFloat(getComputedStyle(el).fontSize) * hudScale; // virtual px × device HUD scale
        if (pt < (label ? 12 : 11) - 0.05) smallText.push(`${el.textContent.trim().slice(0, 24)} (${pt.toFixed(1)}pt)`);
    }
    return { overlaps, smallText };
}

async function cdp(port) {
    for (let i = 0; i < 50; i++) {
        try {
            const list = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
            const target = list.find(t => t.type === 'page');
            if (target) return target.webSocketDebuggerUrl;
        } catch {}
        await new Promise(r => setTimeout(r, 200));
    }
    throw new Error('Chrome did not start');
}

const profile = mkdtempSync(join(tmpdir(), 'verify-hud-'));
const port = 9300 + Math.floor(Math.random() * 500);
const chrome = spawn(CHROME, ['--headless=new', '--disable-gpu', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--window-size=1400,1000', 'about:blank'], { stdio: 'ignore' });

let failed = !checkRbxMap();
try {
    const ws = new WebSocket(await cdp(port));
    await new Promise(r => ws.addEventListener('open', r, { once: true }));
    let id = 0;
    const pending = new Map();
    ws.addEventListener('message', e => {
        const msg = JSON.parse(e.data);
        if (pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id); }
    });
    const send = (method, params = {}) => new Promise(r => { const n = ++id; pending.set(n, r); ws.send(JSON.stringify({ id: n, method, params })); });
    const evaluate = async expr => (await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true })).result.result.value;

    for (const preset of PRESETS) {
        for (const pageName of PAGES) {
            await send('Page.navigate', { url: `${PAGE}?aspect=${preset}&page=${pageName}&safezones=1` });
            await new Promise(r => setTimeout(r, 1500)); // Tailwind CDN + the aspect transition settle
            const { overlaps, smallText } = await evaluate(`(${audit})()`);
            const ok = overlaps.length === 0 && smallText.length === 0;
            failed ||= !ok;
            console.log(`${ok ? 'PASS' : 'FAIL'}  ${preset.padEnd(14)} ${pageName.padEnd(9)}`
                + (overlaps.length ? `\n      overlaps: ${overlaps.join('; ')}` : '')
                + (smallText.length ? `\n      small text: ${smallText.join('; ')}` : ''));
        }
    }
    ws.close();
} finally {
    chrome.kill();
    await new Promise(r => chrome.once('exit', r));
    rmSync(profile, { recursive: true, force: true, maxRetries: 5, retryDelay: 200 });
}
process.exit(failed ? 1 : 0);
