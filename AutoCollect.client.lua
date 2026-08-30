-- Clapped Hub - auto collect example
-- Place this LocalScript in your game's client-side script setup.

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/9ee279e/ClappedHub.lua")
local Library = assert(loadstring(source), "Could not compile ClappedHub.lua from GitHub")()

local UI = Library.new({
	Name = "CLAPPED HUB",
	Subtitle = "MONEY CONTROLS",
	Accent = Color3.fromRGB(78, 160, 255),
	ScriptType = "FREE",
})

local moneyTab = UI:Tab({
	Name = "Money",
	Icon = "$",
	Description = "Cash collection controls.",
})

local money = UI:Section({
	Tab = moneyTab,
	Name = "Collection",
	Description = "Collect money from every slot in bases 1-6.",
})

local remoteEvents = game:GetService("ReplicatedStorage")
	:WaitForChild("Network")
	:WaitForChild("RemoteEvents")

local requestCollectCash = remoteEvents:WaitForChild("RequestCollectCash")
local bases = workspace:WaitForChild("Bases")

local firstBase = 1
local lastBase = 6
local firstSlot = 1
local lastSlot = 20
local delayBetweenCollections = 0.1
local collecting = false
local collectionRun = 0

local function collectAllBases(run)
	while collecting and run == collectionRun do
		for baseNumber = firstBase, lastBase do
			local base = bases:FindFirstChild(tostring(baseNumber))
			local slots = base and base:FindFirstChild("Slots")

			if slots then
				for slotNumber = firstSlot, lastSlot do
					if not collecting or run ~= collectionRun then
						return
					end

					local slot = slots:FindFirstChild(tostring(slotNumber))
					local moneyPart = slot and slot:FindFirstChild("Money")
					if moneyPart then
						requestCollectCash:FireServer(moneyPart)
					end

					task.wait(delayBetweenCollections)
				end
			end
		end
	end
end

money:Toggle({
	Name = "Auto collect",
	Description = "Continuously collects slots 1-20 across bases 1-6.",
	Flag = "AutoCollect",
	Default = false,
	Callback = function(enabled)
		collecting = enabled
		collectionRun += 1

		if enabled then
			local run = collectionRun
			task.spawn(collectAllBases, run)
		end
	end,
})
