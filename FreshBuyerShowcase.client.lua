-- Fresh buyer showcase loader
-- Fetches the newest full showcase from GitHub with cache-busting enabled.

local showcaseUrl = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/6956a87/UltimateBuyerShowcase.client.lua"
local cacheBust = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
local source = game:HttpGet(showcaseUrl .. "?v=" .. cacheBust)
local runShowcase = assert(loadstring(source), "Could not load the latest buyer showcase")
runShowcase()
