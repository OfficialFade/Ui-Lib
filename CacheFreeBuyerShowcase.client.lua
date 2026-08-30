-- Cache-free buyer showcase loader
-- Fetches the latest published showcase with a unique cache-busting query.

local showcaseUrl = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/UltimateBuyerShowcase.client.lua"
local cacheBust = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
local source = game:HttpGet(showcaseUrl .. "?v=" .. cacheBust)
local runShowcase = assert(loadstring(source), "Could not load the buyer showcase")
runShowcase()

