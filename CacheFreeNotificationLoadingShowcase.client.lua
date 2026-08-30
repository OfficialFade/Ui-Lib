-- Ocean UI Lib by Fade - cache-free notification/loading showcase launcher

local HttpService = game:GetService("HttpService")
local cacheKey = HttpService:GenerateGUID(false):gsub("-", "")
local showcaseUrl = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/aae8c5d/NotificationLoadingShowcase.client.lua?cache_free=" .. cacheKey
local source = game:HttpGet(showcaseUrl)
assert(type(source) == "string" and #source > 0, "The notification showcase returned no source")
assert(loadstring(source), "The notification showcase could not be compiled")()
