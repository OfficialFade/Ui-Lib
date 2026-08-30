-- Ocean UI Lib - buyer showcase launcher
-- Loads the full showcase without using a stale cached response.

local showcaseUrl = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/UltimateBuyerShowcase.client.lua"
local cacheKey = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
local source = game:HttpGet(showcaseUrl .. "?ocean_ui=" .. cacheKey)
local runShowcase = assert(loadstring(source), "Could not load Ocean UI Lib showcase")
runShowcase()

