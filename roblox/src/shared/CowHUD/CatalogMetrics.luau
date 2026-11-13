--[[
	Catalog deck sizes (phase 5 T11). Pure arithmetic with no Roblox APIs, so `tools/test-catalog-metrics.luau`
	runs it with plain `luau`.

	The deck (tabs + tray, plus its bottom margin) may use at most `Budget` of the virtual canvas height. The
	Full deck (wireframe: two-line tabs, portrait slots) is used when it fits; otherwise the Compact deck
	(one-line tabs that scroll, landscape slots with a one-line name). Sizes grow with the text, which the
	legibility floor raises on small HUD scales (Util.textSize), so labels always fit their boxes.

	Full on desktop/iPad (text at wireframe size): tabs 47 tall, slots 96×112, deck 216 of 720 (30%).
	Full on phones (text 15): tabs 57, slots 120×128, deck 242 of 520 (47%); Compact there: 168 (32%).
	index.html mirrors this with `.deck-compact` (fitCatalogDeck).
]]

-- Roblox requires by instance; plain `luau` (no `script` global) requires by path.
local Tokens = if script then require(script.Parent.Tokens) else require("./Tokens")

local CatalogMetrics = {}

CatalogMetrics.Budget = Tokens.deck.Budget -- share of the virtual canvas height
CatalogMetrics.TrayBorder = Tokens.deck.TrayBorder -- border-[5px]; the active tab reaches this far into the tray (-mb-[5px])

local LINE_HEIGHT = 1.2 -- Nunito line box, matches the .deck-compact `line-height: 1.2`

local function line(size: number): number
	return math.ceil(size * LINE_HEIGHT)
end

export type Metrics = {
	compact: boolean,
	tabLines: number, -- label block height
	tabActive: number, -- border-t 5 + py + lines
	tabInactive: number, -- border-t 4 + pt 1 + lines + pb 11 (bottom 10 hidden behind the tray)
	slotWidth: number, -- Full: fixed; Compact: minimum (each slot fits its name)
	slotHeight: number,
	slotName: number,
	slotGap: number,
	slotPad: { x: number, y: number }, -- inside the 4px slot border
	chip: number, -- cost chip height
	icon: { w: number, h: number, glyph: number },
	trayPadY: number,
	trayHeight: number,
	bottom: number, -- margin under the deck
	height: number, -- tabs + tray, without `bottom`
}

-- tabText / slotText: the rendered text sizes (virtual px) of the 10px tab labels and 9px slot labels.
function CatalogMetrics.deck(compact: boolean, tabText: number, slotText: number): Metrics
	local slotLine = line(slotText)
	local tabLines = if compact then line(tabText) else math.max(26, 2 * line(tabText))
	local slotName = if compact then slotLine else math.max(22, 2 * slotLine)
	local chip = math.max(18, slotLine + (if compact then 4 else 2))
	local icon = if compact then { w = 40, h = 32, glyph = 20 } else { w = 48, h = 40, glyph = 24 }
	local slotGap = if compact then 4 else 6
	local slotPad = if compact then { x = 10, y = 6 } else { x = 6, y = 6 }
	local slotHeight = 2 * 4 + 2 * slotPad.y + slotName + slotGap + icon.h + slotGap + chip
	local trayPadY = if compact then 8 else 14 -- py-3.5
	local m = {
		compact = compact,
		tabLines = tabLines,
		tabActive = 5 + 2 * (if compact then 6 else 8) + tabLines,
		tabInactive = 16 + tabLines,
		-- w-24, widened as the floor raises the text (120 at the phones' 15px)
		slotWidth = if compact then 112 else math.max(96, 96 + 4 * (slotText - 9)),
		slotHeight = if compact then slotHeight else math.max(112, slotHeight), -- h-28
		slotName = slotName,
		slotGap = slotGap,
		slotPad = slotPad,
		chip = chip,
		icon = icon,
		trayPadY = trayPadY,
		bottom = if compact then 12 else 24, -- bottom-6
	}
	m.trayHeight = m.slotHeight + 2 * trayPadY + 2 * CatalogMetrics.TrayBorder
	m.height = m.tabActive - CatalogMetrics.TrayBorder + m.trayHeight
	return m
end

-- The deck for a canvas `virtualHeight` px tall: Full when it fits the budget, Compact otherwise.
function CatalogMetrics.choose(virtualHeight: number, tabText: number, slotText: number): Metrics
	local full = CatalogMetrics.deck(false, tabText, slotText)
	if full.height + full.bottom <= CatalogMetrics.Budget * virtualHeight then
		return full
	end
	return CatalogMetrics.deck(true, tabText, slotText)
end

return CatalogMetrics
