-- Ocean UI Lib by Fade - cache-free complete showcase launcher
-- Generates a unique URL every run, then loads the full product example.

local HttpService = game:GetService("HttpService")
local cacheKey = HttpService:GenerateGUID(false):gsub("-", "")
local showcaseUrl = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/acb10ac/ProductShowcase.client.lua?cache_free=" .. cacheKey
local response = game:HttpGet(showcaseUrl)
assert(type(response) == "string" and #response > 0, "The product showcase returned no source")
local runShowcase = assert(loadstring(response), "The product showcase could not be compiled")
runShowcase()
