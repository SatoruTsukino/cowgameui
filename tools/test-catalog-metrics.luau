--!strict
-- Phase 5 T11: checks the catalog deck sizes across the device matrix with plain luau (no Roblox needed).
--   luau tools/test-catalog-metrics.luau     # exits with an error if any check fails
-- Per device it mirrors the HUD scale (Scaler: viewport height / 720, clamped to the touch or desktop floor) and
-- the legibility floor (Util.textSize), then asserts:
--   - the deck plus its bottom margin fits CatalogMetrics.Budget of the canvas height, unless even the Compact
--     deck can't (reported as OVER)
--   - desktop and tablet keep the Full deck, phones get Compact
--   - every label box is at least as tall as its rendered text (one line per line of label)

local CatalogMetrics = require("../roblox/src/shared/CowHUD/CatalogMetrics")
local Tokens = require("../roblox/src/shared/CowHUD/Tokens")

local REFERENCE, MIN_SCALE, TOUCH_MIN_SCALE = Tokens.scale.ReferenceHeight, Tokens.scale.MinScale, Tokens.scale.TouchMinScale

local function textSize(base: number, scale: number): number
	local floor = if base >= 12 then 12 else 11
	return math.max(base, math.ceil(floor / scale))
end

type Device = { name: string, w: number, h: number, touch: boolean, expect: string }
local DEVICES: { Device } = {
	{ name = "1080p desktop", w = 1920, h = 1080, touch = false, expect = "full" },
	{ name = "1440p desktop", w = 2560, h = 1440, touch = false, expect = "full" },
	{ name = "ultrawide 3440x1440", w = 3440, h = 1440, touch = false, expect = "full" },
	{ name = "iPad 1180x820", w = 1180, h = 820, touch = true, expect = "full" },
	{ name = "iPad mini 1133x744", w = 1133, h = 744, touch = true, expect = "full" },
	{ name = "4:3 tablet 1024x768", w = 1024, h = 768, touch = true, expect = "full" },
	{ name = "iPhone 14 844x390", w = 844, h = 390, touch = true, expect = "compact" },
	{ name = "iPhone SE 667x375", w = 667, h = 375, touch = true, expect = "compact" },
	{ name = "short window 1280x420", w = 1280, h = 420, touch = false, expect = "compact" },
}

local failures = 0
print(string.format("%-24s %5s %4s %-8s %-10s %s", "device", "scale", "vH", "deck", "height", "share"))
for _, d in DEVICES do
	local scale = math.clamp(d.h / REFERENCE, if d.touch then TOUCH_MIN_SCALE else MIN_SCALE, 4)
	local vH = d.h / scale
	local tabText, slotText = textSize(10, scale), textSize(9, scale)
	local m = CatalogMetrics.choose(vH, tabText, slotText)
	local used = m.height + m.bottom
	local share = used / vH
	local density = if m.compact then "compact" else "full"
	local problems = {}
	if density ~= d.expect then
		table.insert(problems, "expected " .. d.expect)
	end
	if share > CatalogMetrics.Budget + 1e-9 then
		table.insert(problems, "OVER budget")
	end
	local line = math.ceil(slotText * 1.2)
	if m.slotName < line * (if m.compact then 1 else 2) then
		table.insert(problems, "slot name box too short")
	end
	if m.tabLines < math.ceil(tabText * 1.2) * (if m.compact then 1 else 2) then
		table.insert(problems, "tab label box too short")
	end
	-- The inactive tab's label area (above the tray, below its 4px border) must hold the label block.
	if m.tabInactive - (CatalogMetrics.TrayBorder + 5) - 4 < m.tabLines then
		table.insert(problems, "inactive tab label clipped")
	end
	if m.chip < line then
		table.insert(problems, "cost chip too short")
	end
	failures += #problems
	print(string.format("%-24s %5.2f %4d %-8s %3d/%-6d %3d%%  %s", d.name, scale, vH, density, used, vH,
		math.round(100 * share), if #problems > 0 then "FAIL " .. table.concat(problems, ", ") else "PASS"))
end

assert(failures == 0, failures .. " check(s) failed")
