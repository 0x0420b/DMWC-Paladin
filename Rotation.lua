local DMW = DMW
local Paladin = DMW.Rotations.PALADIN
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Buff, Debuff, Spell, Stance, Target, Talent, Item, GCD, CDs, HUD

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
	HP = (Player.Health / Player.HealthMax) * 100
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Talent = Player.Talents
    Item = Player.Items
    Target = Player.Target or false
    HUD = DMW.Settings.profile.HUD
	CDs = Player:CDs()
end

local might = {
	["WARRIOR"] = true,
	["PALADIN"] = true,
	["HUNTER"] = true,
	["DRUID"] = true,
	["ROGUE"] = true
}
local wisdom = {
	["WARLOCK"] = true,
	["MAGE"] = true,
	["PRIEST"] = true
}

local function Debugsettings()
	-- Debug Settings
	if not Player.Combat and Setting("Debug") then
		if not prevs == nil then  
			prevs = nil
		end
		if not prev == nil then
			prev = nil
		end
	end	
end

local function regularCast(spell, Unit)
	if Spell[spell]:Cast(Unit) then
		return true
	end
end

local function Buffing()	
	--Apply Aura
	if Setting("Use Devotion Aura") and Spell.DevotionAura:Known() and not Buff.DevotionAura:Exist() then
		regularCast("DevotionAura",Player)
	end
	if Setting("Use Retribution Aura")and Spell.RetriAura:Known() and not Buff.RetriAura:Exist() then
		regularCast("RetriAura",Player)
	end
	if Setting("Use Sanctity Aura")and Spell.SanctityAura:Known() and not Buff.SanctityAura:Exist() then
		regularCast("SanctityAura",Player)
	end
	--Buff Self
	if Setting("Use Blessing of Might") and Spell.BlessingMight:Known() then
		if not Buff.BlessingMight:Exist(Player) then
			if Spell.BlessingofMightG:Known() and not Buff.BlessingofMightG:Exist() then
				if regularCast("BlessingofMightG", Player) then
					return true
				end
			else 
				if regularCast("BlessingMight", Player) then
					return true
				end
			end
		end
	end
	if Setting("Use Blessing of Wisdom") and Spell.BlessingWisdom:Known() then
		if not Buff.BlessingWisdom:Exist(Player) then
			if Spell.BlessingofWisdomG:Known() and Buff.BlessingofWisdomG:Exist() then
				if regularCast("BlessingofWisdomG", Player) then
					return true
				end
			else
				if regularCast("BlessingWisdom", Player) then
					return true
				end
			end
		end
	end
	if Setting("Use Blessing of Kings") then
		if not Buff.BlessingKings:Exist(Player) and Spell.BlessingKings:Known() then
			if Spell.BlessingofKingsG:Known() and Buff.BlessingofKingsG:Exist() then
				if regularCast("BlessingofKingsG", Player) then
					return true
				end
			else
				if regularCast("BlessingKings", Player) then
					return true
				end
			end
		end
	end
	--Buff Group Members
	if Setting ("Buff others") and not Player.Combat and Player.HP >= 20 then
		for _, Unit in pairs(DMW.Units) do
			unitclass, unitclassid = select(2, UnitClass(Unit.Pointer))
			if Unit.Distance <= 10 and Unit.Player and Unit.Name~=Player.Name and Unit.LoS then
				if Spell.BlessingofKingsG:Known() or Spell.BlessingKings:Known() then
					if Spell.BlessingofKingsG:Known() then
						if regularCast("BlessingofKingsG", Unit) then
							return true
						end
					else
						if regularCast("BlessingKings", Unit) then
							return true
						end
					end
				else
					if might[unitclass] and not Buff.BlessingMight:Exist(Unit) and Spell.BlessingMight:Known() then
						if Spell.BlessingofMightG:Known() then
							if regularCast("BlessingofMightG", Unit) then
								return true
							end
						else
							if regularCast("BlessingMight",Unit) then
								return true
							end
						end
					elseif wisdom[unitclass] and not Buff.BlessingWisdom:Exist(Unit) and Spell.BlessingWisdom:Known() then
						if Spell.BlessingofWisdomG:Known() then
							if regularCast("BlessingofWisdomG", Unit) then
								return true
							end
						else
							if regularCast("BlessingWisdom",Unit) then
								return true
							end
						end
					end
				end
			end
		end
	end
end

local function Healing()
	-- HolyLight out of Combat
	if not Player.Combat and HP <= 75 and Spell.HolyLight:Known() then
		if regularCast("HolyLight", Player) then
			return true
		end
	end
	-- HolyLight in Combat
	if Player.Combat and HP <= 50  and Spell.HolyLight:Known() then
		if regularCast("HolyLight") then
			return true
		end
	end
end

local function Targeting()
	-- Targeting 
	if Player.Combat and not (Target and Target.ValidEnemy) and #Player:GetEnemies(5) >= 1 and Setting("AutoTarget") then
		TargetUnit(DMW.Attackable[1].unit)
	end
end

local function StartAA()
	if Target and Target:IsEnemy() then
		if not IsCurrentSpell(6603) and Target.Distance <= 5 then
			StartAttack(Target.Pointer)
		end
	end
end

local function Combat ()
	if Target then
		if Target.ValidEnemy and Target.Health > 1 then
			------- COMBAT -------
			if Player.Combat and #Player:GetEnemies(5) >=1 and Target.Distance <= 10 then
				--Seal of Righteousness
				if Setting("Use Seal Of Righteousness") and not Buff.SealOfRight:Exist(Player) and Spell.SealOfRight:Known() then
					if regularCast("SealOfRight",Player) then
						return true
					end
				end
				--Seal of Command
				if Setting("Use Seal Of Command") and not Buff.SealCommand:Exist(Player) and Spell.SealCommand:Known() then
					if regularCast("SealCommand",Player) then
						return true
					end
				end
				--Seal of Crusader
				if Setting("Use Seal Of Crusader") and not Buff.SealCrusader:Exist(Player) and Spell.SealCrusader:Known() then
					if regularCast("SealCrusader",Player) then
						return true
					end
				end
				--Judgement
				if (Buff.SealOfRight:Exist(Player) or Buff.SealCrusader:Exist(Player) or Buff.SealCommand:Exist(Player)) and Spell.Judgement:CD() == 0 and Spell.Judgement:Known() then
					if regularCast("Judgement", Target) then
						return true
					end
				end
			end 
		end
	end
end

local function Dispel()
	if Setting("Use Dispel") then
		for _, Unit in ipairs(Player:GetFriends(40)) do
			if not Spell.Cleanse:Known() then
				if Unit:Dispel(Spell.Purify) then
					if regularCast("Purify", Unit) then 
						return true 
					end
				end
			else
				if Unit:Dispel(Spell.Cleanse) then
					if regularCast("Cleanse", Unit) then 
						return true 
					end
				end
			end
		end
	end
end

function Paladin.Rotation()
	Locals()
	--Check debug settings
	if Debugsettings() then
		return true
	end
	-- Check Buffs
	if Buffing() then
		return true
	end
	--Check targeting
	if Targeting() then
		return true
	end
	--Start AutoAttacking
	if StartAA() then
		return true
	end
	--Check for Self Healing
	if Healing() then
		return true
	end
	-- Dispel
	if Dispel() then
		return true
	end
	--Start Combat
	if Combat() then 
		return true
	end
end -- ROTATION