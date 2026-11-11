# Cozy Cow Game UI - Project Context & Artifacts

**Context & Project State for New Session:**

**Project:** Roblox "Cozy Cow" Game UI Wireframe (ScreenGui).
**Aesthetic:** Cute, cozy, bubbly, pixel-art inspired icons (Stardew Valley vibe), entirely monochromatic/grayscale (no colors or detailed images yet), utilizing thick borders (`border-[6px]` or `[8px]`) and heavy border radii (squircles).
**Current Progress:** We have successfully built V4 of the HTML/Tailwind CSS wireframe. The UI is fully responsive, utilizing a `ResizeObserver` to mimic Roblox's `UIScale` behavior across different aspect ratios (Desktop 16:9, Ultrawide 21:9, Mobile 19.5:9, Tablet 4:3). 

**Key UI Components & Rules:**
*   **Top-Left (Vitals):** Cow Profile (with Rebirth badge), Leaf-shaped Grazing Quest progress bar (with a white inner gap `p-1`), and Stamina/HP pill. 
*   **Top-Center (Town Bulletin):** Absolutely centered. Features a Sun icon, Day/Night timer, World Event progress, and Player Boost chip. Can toggle into a compact mini-pill.
*   **Top-Right (Economy & Settings):** Fused Calories pill with a thinner Upgrades tab tucked underneath. Trade button, and a Downward-Flared Cowbell shape for the Settings button.
*   **Left Sidebar:** Pixel Backpack shape for Inventory (with a top flap), and a standard squircle for the Closet. (Merges into a "Bag" in Compact Mode).
*   **Right Sidebar:** Herd button made of two interlocking/overlapping rounded squares. (Moves to Cow Profile in Compact Mode).
*   **Bottom Safe Zones:** The bottom-left and bottom-right corners must remain completely empty of interactive UI to allow for mobile thumbstick and jump/interact buttons.
*   **Bottom-Center:** Dashed "Area Actions (WIP)" placeholder.

## Latest HTML Artifact (V4)

**File Path:** `index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cozy Cow Game UI Wireframe V4 - Aspect Ratios</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Nunito:wght@700;800;900&display=swap');

        body {
            font-family: 'Nunito', sans-serif;
            background-color: #e5e7eb;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            padding: 1.5rem;
            overflow-x: hidden;
        }

        .game-screen {
            background-image: radial-gradient(#d1d5db 2px, transparent 2px);
            background-size: 32px 32px;
            background-position: center;
            background-color: #f3f4f6;
            box-shadow: 0 24px 48px -12px rgba(0, 0, 0, 0.15);
            max-width: 90vw;
            max-height: 75vh;
            margin: 0 auto;
        }

        .ui-element {
            user-select: none;
            -webkit-user-select: none;
        }

        .hud-spring {
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        /* Specialized Shapes */
        .shape-leaf {
            border-radius: 2rem 2rem 0.5rem 0.5rem;
            border-top-left-radius: 2.5rem;
            border-bottom-right-radius: 2.5rem;
            border-top-right-radius: 0.5rem;
            border-bottom-left-radius: 0.5rem;
        }

        .shape-cowbell {
            border-radius: 35% 35% 15% 15% / 50% 50% 20% 20%;
        }

        .aspect-21-9 { aspect-ratio: 21 / 9; }
        .aspect-4-3 { aspect-ratio: 4 / 3; }
        .aspect-19-5-9 { aspect-ratio: 19.5 / 9; }
    </style>
</head>
<body class="gap-6 w-full">

    <!-- ================= CONTROLS ================= -->
    <div class="flex flex-wrap items-center justify-between gap-4 w-full max-w-[1280px] px-6 py-4 bg-white rounded-[2rem] border-[6px] border-gray-400 shadow-sm z-50">
        <div class="flex items-center gap-3">
            <span class="w-4 h-4 rounded-full bg-gray-500 animate-pulse"></span>
            <span class="text-gray-500 font-black text-sm tracking-widest uppercase">ScreenGui Controls</span>
        </div>
        <div class="flex flex-wrap items-center gap-3">
            <select id="aspectRatioSelect" onchange="changeAspectRatio(this)" class="px-4 py-2 rounded-full border-[4px] border-gray-400 bg-white text-gray-600 font-black text-xs tracking-wider uppercase outline-none cursor-pointer hover:bg-gray-50">
                <option value="aspect-video">Desktop (16:9)</option>
                <option value="aspect-21-9">Ultrawide (21:9)</option>
                <option value="aspect-19-5-9">Mobile (19.5:9)</option>
                <option value="aspect-4-3">Tablet (4:3)</option>
            </select>
            <div class="w-px h-6 bg-gray-300 mx-1"></div>
            <button id="btnCompact" onclick="toggleCompactMode()" class="px-5 py-2.5 rounded-full border-[4px] border-gray-400 bg-gray-100 text-gray-600 font-black text-xs tracking-wider uppercase hover:bg-gray-200 transition-colors">
                Compact Mode: OFF
            </button>
            <button id="btnBulletin" onclick="toggleBulletin()" class="px-5 py-2.5 rounded-full border-[4px] border-gray-600 bg-gray-600 text-white font-black text-xs tracking-wider uppercase hover:opacity-90 transition-opacity">
                World Bulletin: ON
            </button>
            <button id="btnSafeZones" onclick="toggleSafeZones()" class="px-5 py-2.5 rounded-full border-[4px] border-gray-400 bg-gray-100 text-gray-600 font-black text-xs tracking-wider uppercase hover:bg-gray-200 transition-colors">
                Mobile Safe Zones: OFF
            </button>
        </div>
    </div>

    <!-- ================= GAME PREVIEW ================= -->
    <div class="game-screen w-[1280px] aspect-video relative rounded-[3rem] border-[8px] border-gray-500 overflow-hidden transition-all duration-500">
        
        <!-- GAME UI SCALER WRAPPER -->
        <div id="ui-container" class="absolute pointer-events-none origin-top-left">
            
            <!-- TOP HUD ROW -->
            <div class="absolute top-6 left-6 right-6 flex justify-between items-start z-20 pointer-events-none">
                
                <!-- 1. TOP-LEFT: Vitals & Quests -->
                <div class="flex items-start gap-4 pointer-events-auto shrink-0">
                    <!-- Cow Profile -->
                    <div class="relative w-28 h-28 rounded-[2rem] border-[6px] border-gray-400 bg-white flex flex-col items-center justify-center shadow-md ui-element hover:scale-105 transition-transform cursor-pointer shrink-0">
                        <span class="text-gray-500 font-black text-lg tracking-widest">COW</span>
                        
                        <div id="profileHerdBadge" class="hidden absolute -top-3 -right-3 px-3 py-1 bg-gray-600 text-white rounded-full border-[4px] border-white shadow-sm">
                            <span class="font-black text-[10px] tracking-widest uppercase">+ HERD</span>
                        </div>

                        <div class="absolute -bottom-3.5 left-1/2 -translate-x-1/2 px-3 py-1 bg-gray-400 rounded-xl border-[4px] border-white flex items-center shadow-sm whitespace-nowrap">
                            <span class="text-white font-black text-[10px] tracking-wider uppercase">Rebirth 2</span>
                        </div>
                    </div>

                    <!-- Inline Vitals -->
                    <div class="flex flex-col gap-3 w-64 pt-1 ui-element">
                        <div class="flex flex-col gap-1">
                            <span class="px-1 text-gray-500 font-black text-[10px] tracking-widest uppercase truncate">Grazing: Clover Meadow</span>
                            <div class="w-full h-10 shape-leaf border-[6px] border-gray-400 bg-white p-1 flex items-center shadow-sm relative overflow-hidden">
                                <div class="h-full w-[68%] bg-gray-300 rounded-l-full rounded-r-sm"></div>
                                <div class="absolute inset-0 flex items-center px-3 pointer-events-none">
                                    <span class="text-gray-600 font-black text-xs tracking-wider">68%</span>
                                </div>
                            </div>
                        </div>

                        <div class="w-full rounded-full border-[6px] border-gray-500 bg-white p-1 shadow-sm relative h-10" title="Outer Border = Stamina">
                            <div class="h-full w-[85%] bg-gray-300 rounded-full flex items-center px-2">
                                <span class="text-gray-600 font-black text-[10px] tracking-wider uppercase">HP 100</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 3. TOP-RIGHT: Economy & Menus -->
                <div class="flex items-start gap-4 pointer-events-auto shrink-0">
                    <div class="flex flex-col items-center">
                        <div class="h-14 px-5 rounded-[1.5rem] border-[6px] border-gray-400 bg-white flex items-center justify-center shadow-sm relative z-10 ui-element hover:scale-105 transition-transform cursor-pointer">
                            <span class="text-gray-500 font-black tracking-widest text-xs uppercase">Calories: 1,500</span>
                        </div>
                        <div id="upgradesPill" class="h-8 px-4 -mt-2 rounded-b-xl border-[4px] border-gray-400 border-t-0 bg-gray-200 flex items-end pb-1 shadow-sm hover:bg-gray-300 cursor-pointer transition-colors">
                            <span class="text-gray-500 font-black text-[9px] tracking-widest uppercase">Upgrades ⬆</span>
                        </div>
                    </div>

                    <div id="topRightStandard" class="flex items-start gap-3 pt-1">
                        <div class="w-14 h-14 rounded-2xl border-[6px] border-gray-400 bg-white flex items-center justify-center shadow-sm ui-element hover:scale-110 cursor-pointer">
                            <span class="text-gray-500 font-black text-[9px] tracking-wider uppercase">Trade</span>
                        </div>
                        <div class="w-14 h-14 shape-cowbell border-[6px] border-gray-400 bg-white flex items-center justify-center shadow-sm ui-element hover:scale-110 cursor-pointer relative" title="Settings">
                            <span class="text-gray-500 font-black text-[9px] tracking-widest uppercase mt-2">SET</span>
                            <div class="absolute -top-2 w-4 h-3 border-[4px] border-gray-400 rounded-t-full bg-transparent"></div>
                        </div>
                    </div>

                    <div id="topRightCompact" class="hidden w-14 h-14 rounded-2xl border-[6px] border-gray-400 bg-white flex flex-col items-center justify-center shadow-sm ui-element hover:scale-110 cursor-pointer pt-1" title="More">
                        <span class="text-gray-600 font-black text-sm tracking-widest leading-none">•••</span>
                    </div>
                </div>
            </div>

            <!-- 2. TOP-CENTER: Town Bulletin -->
            <div id="townBulletinWrapper" class="absolute top-6 left-1/2 -translate-x-1/2 flex flex-col items-center pointer-events-auto ui-element hud-spring z-20">
                <div id="bulletinFull" class="flex flex-col items-center">
                    <div class="flex items-center gap-3 px-4 py-2.5 rounded-[2rem] border-[6px] border-gray-400 bg-white shadow-lg">
                        <div class="flex items-center gap-2 pr-3 border-r-4 border-gray-200">
                            <div class="w-8 h-8 rounded-full border-4 border-gray-400 bg-gray-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-gray-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="12" cy="12" r="4"></circle>
                                    <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"></path>
                                </svg>
                            </div>
                            <div class="flex flex-col">
                                <span class="text-[9px] font-black text-gray-400 tracking-widest uppercase leading-none">Cycle</span>
                                <span class="text-xs font-black text-gray-600 tracking-wider uppercase mt-0.5">DAY • 02:45</span>
                            </div>
                        </div>

                        <div class="flex flex-col gap-1 min-w-[155px]">
                            <div class="flex items-center justify-between px-1">
                                <span class="text-[9px] font-black text-gray-400 tracking-widest uppercase">World Event</span>
                                <span class="text-[10px] font-black text-gray-500 tracking-wider">4m 12s</span>
                            </div>
                            <div class="w-full h-6 rounded-full border-4 border-gray-300 bg-gray-100 p-0.5 relative overflow-hidden flex items-center">
                                <div class="h-full w-[55%] bg-gray-300 rounded-full"></div>
                                <span class="absolute inset-0 flex items-center justify-center text-[10px] font-black text-gray-600 tracking-wider uppercase">
                                    Clover Bloom
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="-mt-1.5 px-4 py-1 rounded-b-2xl rounded-t-lg border-4 border-gray-500 bg-gray-100 shadow-md flex items-center gap-2">
                        <span class="w-2 h-2 rounded-full bg-gray-500"></span>
                        <span class="text-[10px] font-black text-gray-600 tracking-widest uppercase">2x Calories • 01:30</span>
                    </div>
                </div>

                <div id="bulletinCompact" class="hidden relative items-center gap-2.5 px-4 py-2.5 rounded-full border-[6px] border-gray-400 bg-white shadow-lg cursor-pointer hover:scale-105 transition-transform">
                    <div class="w-7 h-7 rounded-full border-4 border-gray-400 bg-gray-100 flex items-center justify-center">
                        <svg class="w-3.5 h-3.5 text-gray-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="4"></circle>
                            <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"></path>
                        </svg>
                    </div>
                    <span class="text-xs font-black text-gray-600 tracking-wider uppercase">02:45</span>
                    <span class="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-gray-500 border-4 border-white shadow-sm"></span>
                </div>
            </div>

            <!-- ================= SIDEBARS ================= -->
            <div class="absolute left-6 top-48 flex flex-col gap-4 pointer-events-auto z-10">
                <div id="leftSidebarStandard" class="flex flex-col gap-4">
                    <div class="w-16 h-[4.5rem] rounded-xl border-[6px] border-gray-400 bg-white relative shadow-sm ui-element hover:scale-110 cursor-pointer flex flex-col items-center justify-end pb-1.5" title="Inventory">
                        <div class="absolute top-0 left-1/2 -translate-x-1/2 w-8 h-4 border-b-[4px] border-l-[4px] border-r-[4px] border-gray-400 rounded-b-md bg-gray-100"></div>
                        <span class="text-gray-500 font-black text-[9px] tracking-widest uppercase">INV</span>
                    </div>
                    <div class="w-16 h-16 rounded-2xl border-[6px] border-gray-400 bg-white flex items-center justify-center shadow-sm ui-element hover:scale-110 cursor-pointer">
                        <span class="text-gray-500 font-black text-[9px] tracking-wider uppercase">Closet</span>
                    </div>
                </div>

                <div id="leftSidebarCompact" class="hidden w-16 h-[4.5rem] rounded-xl border-[6px] border-gray-400 bg-white shadow-sm ui-element hover:scale-110 cursor-pointer flex flex-col items-center justify-end pb-1.5 relative" title="Bag (Inv + Closet)">
                    <div class="absolute top-0 left-1/2 -translate-x-1/2 w-8 h-4 border-b-[4px] border-l-[4px] border-r-[4px] border-gray-400 rounded-b-md bg-gray-100"></div>
                    <span class="text-gray-500 font-black text-[9px] tracking-wider uppercase">BAG</span>
                </div>
            </div>

            <div id="rightSidebarHerd" class="absolute right-6 top-32 flex flex-col items-end pointer-events-auto z-10 hud-spring">
                <div class="relative w-16 h-16 ui-element hover:scale-110 cursor-pointer">
                    <div class="absolute top-0 right-0 w-12 h-12 rounded-[0.8rem] border-[6px] border-gray-400 bg-gray-200"></div>
                    <div class="absolute bottom-0 left-0 w-12 h-12 rounded-[0.8rem] border-[6px] border-gray-400 bg-white flex items-center justify-center shadow-sm">
                        <span class="text-gray-500 font-black text-[9px] tracking-widest uppercase">Herd</span>
                    </div>
                </div>
            </div>

            <!-- ================= BOTTOM SAFE ZONES ================= -->
            <div id="safeZoneLeft" class="hidden absolute bottom-6 left-6 w-48 h-48 rounded-full border-[4px] border-dashed border-gray-400 bg-gray-300/30 flex flex-col items-center justify-center pointer-events-none">
                <span class="text-gray-500 font-black text-[10px] tracking-widest uppercase">Thumbstick</span>
            </div>
            <div id="safeZoneRight" class="hidden absolute bottom-6 right-6 w-56 h-48 rounded-[2.5rem] border-[4px] border-dashed border-gray-400 bg-gray-300/30 flex flex-col items-center justify-center pointer-events-none">
                <span class="text-gray-500 font-black text-[10px] tracking-widest uppercase">Jump / Interact</span>
            </div>

            <!-- ================= BOTTOM-CENTER AREA ACTIONS ================= -->
            <div class="absolute bottom-6 left-1/2 -translate-x-1/2 pointer-events-auto w-1/3 max-w-sm z-10">
                <div class="flex flex-col items-center justify-center py-3 px-5 rounded-3xl border-[6px] border-dashed border-gray-400 bg-white/80 backdrop-blur-sm shadow-sm ui-element hover:scale-105 cursor-pointer">
                    <span class="text-gray-500 font-black text-sm tracking-widest uppercase">Area Actions (WIP)</span>
                </div>
            </div>

        </div>
    </div>

    <script>
        let isCompact = false;
        let isBulletinVisible = true;
        let areSafeZonesVisible = false;

        function setButtonState(btn, label, active) {
            btn.textContent = `${label}: ${active ? 'ON' : 'OFF'}`;
            if (active) {
                btn.className = "px-5 py-2.5 rounded-full border-[4px] border-gray-600 bg-gray-600 text-white font-black text-xs tracking-wider uppercase hover:opacity-90 transition-opacity";
            } else {
                btn.className = "px-5 py-2.5 rounded-full border-[4px] border-gray-400 bg-gray-100 text-gray-600 font-black text-xs tracking-wider uppercase hover:bg-gray-200 transition-colors";
            }
        }

        function toggleCompactMode() {
            isCompact = !isCompact;
            setButtonState(document.getElementById('btnCompact'), 'Compact Mode', isCompact);

            document.getElementById('profileHerdBadge').classList.toggle('hidden', !isCompact);
            document.getElementById('leftSidebarStandard').classList.toggle('hidden', isCompact);
            document.getElementById('leftSidebarCompact').classList.toggle('hidden', !isCompact);
            document.getElementById('leftSidebarCompact').classList.toggle('flex', isCompact);

            const rightHerd = document.getElementById('rightSidebarHerd');
            if (isCompact) {
                rightHerd.classList.add('opacity-0', 'scale-75', 'pointer-events-none');
            } else {
                rightHerd.classList.remove('opacity-0', 'scale-75', 'pointer-events-none');
            }

            document.getElementById('topRightStandard').classList.toggle('hidden', isCompact);
            document.getElementById('topRightCompact').classList.toggle('hidden', !isCompact);
            document.getElementById('topRightCompact').classList.toggle('flex', isCompact);
            
            const upgradesPill = document.getElementById('upgradesPill');
            if (isCompact) {
                upgradesPill.classList.add('hidden');
            } else {
                upgradesPill.classList.remove('hidden');
            }

            document.getElementById('bulletinFull').classList.toggle('hidden', isCompact);
            document.getElementById('bulletinCompact').classList.toggle('hidden', !isCompact);
            document.getElementById('bulletinCompact').classList.toggle('flex', isCompact);
        }

        function toggleBulletin() {
            isBulletinVisible = !isBulletinVisible;
            setButtonState(document.getElementById('btnBulletin'), 'World Bulletin', isBulletinVisible);
            const bulletin = document.getElementById('townBulletinWrapper');
            if (isBulletinVisible) {
                bulletin.classList.remove('opacity-0', 'scale-90', 'pointer-events-none');
            } else {
                bulletin.classList.add('opacity-0', 'scale-90', 'pointer-events-none');
            }
        }

        function toggleSafeZones() {
            areSafeZonesVisible = !areSafeZonesVisible;
            setButtonState(document.getElementById('btnSafeZones'), 'Mobile Safe Zones', areSafeZonesVisible);
            document.getElementById('safeZoneLeft').classList.toggle('hidden', !areSafeZonesVisible);
            document.getElementById('safeZoneRight').classList.toggle('hidden', !areSafeZonesVisible);
        }

        function changeAspectRatio(selectElement) {
            const screen = document.querySelector('.game-screen');
            screen.classList.remove('aspect-video', 'aspect-21-9', 'aspect-4-3', 'aspect-19-5-9');
            screen.classList.add(selectElement.value);
            resizeUI();
        }

        function resizeUI() {
            const screen = document.querySelector('.game-screen');
            const ui = document.getElementById('ui-container');
            if (!screen || !ui) return;
            
            const rect = screen.getBoundingClientRect();
            if (rect.width === 0 || rect.height === 0) return;

            const virtualHeight = 720;
            const currentAspectRatio = rect.width / rect.height;
            const virtualWidth = virtualHeight * currentAspectRatio;
            
            ui.style.width = `${virtualWidth}px`;
            ui.style.height = `${virtualHeight}px`;
            
            const scale = rect.height / virtualHeight;
            ui.style.transform = `scale(${scale})`;
            ui.style.left = `0px`;
            ui.style.top = `0px`;
        }

        const resizeObserver = new ResizeObserver(() => { resizeUI(); });

        document.addEventListener('DOMContentLoaded', () => {
            const screen = document.querySelector('.game-screen');
            resizeObserver.observe(screen);
            resizeUI();
        });
    </script>
</body>
</html>
```