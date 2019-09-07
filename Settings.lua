local DMW = DMW
DMW.Rotations.PALADIN = {}
local Paladin = DMW.Rotations.PALADIN
local UI = DMW.UI

function Paladin.Settings()
	UI.AddHeader("General")
	UI.AddToggle("AutoTarget", "Auto Targets mobs while in Combat", false)
	UI.AddToggle("Debug","Adds Debug prints to Chat", false)
end
