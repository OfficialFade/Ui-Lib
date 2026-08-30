-- Ocean UI Lib by Fade - exact-commit single notification showcase launcher
local HttpService = game:GetService("HttpService")
local cacheKey = HttpService:GenerateGUID(false):gsub("-", "")
local url = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/SingleNotificationShowcase.client.lua?cache_free=" .. cacheKey
local source = game:HttpGet(url)
assert(type(source) == "string" and #source > 0, "The showcase returned no source")
assert(loadstring(source), "The showcase could not be compiled")()
