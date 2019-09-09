local DMW = DMW
DMW.Rotations.PALADIN = {}
local Paladin = DMW.Rotations.PALADIN
local UI = DMW.UI

function Paladin.Settings()
	UI.AddHeader("General")
	UI.AddToggle("AutoTarget", "Auto Targets mobs while in Combat", false)
	UI.AddToggle("Debug","Adds Debug prints to Chat", false)
	UI.AddHeader("Buffs")
	UI.AddToggle("Use Blessing of Might", nil, false)
	UI.AddToggle("Use Blessing of Wisdom", nil, false)
	UI.AddToggle("Buff others", nil, false)
	UI.AddHeader("Seals")
	UI.AddToggle("Use Seal Of Righteousness", nil, false)
	UI.AddToggle("Use Seal Of Command", nil, false)
	UI.AddToggle("Use Seal Of Crusader", nil, false)
	UI.AddHeader("Auras")
	UI.AddToggle("Use Devotion Aura", nil, false)	
	UI.AddToggle("Use Retribution Aura", nil, false)
	UI.AddHeader("Dispel")
	UI.AddToggle("Use Purify", nil, false)
	UI.AddToggle("Use Cleanse *not implemented yet*", nil, false)
end