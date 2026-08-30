-- Final buyer showcase launcher
-- Always fetches the latest published showcase and bypasses stale cache entries.

local showcaseUrl = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/UltimateBuyerShowcase.client.lua"
local cacheKey = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
local source = game:HttpGet(showcaseUrl .. "?cache=" .. cacheKey)
local runShowcase = assert(loadstring(source), "Could not load the latest buyer showcase")
runShowcase()

