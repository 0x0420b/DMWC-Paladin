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
	if Spell[spell]:Known() then
		if Spell[spell]:Cast(Unit) then
			return true
		end
	end
end

local function Buffing()
	--Apply Aura
	if Setting("Use Devotion Aura") and not Buff.DevotionAura:Exist() then
		regularCast("DevotionAura",Player)
	end
	if Setting("Use Retribution Aura") and not Buff.RetriAura:Exist() then
		regularCast("RetriAura",Player)
	end
	--Buff Self
	if Setting("Use Blessing of Might") then
		if not Buff.BlessingMight:Exist(Player) then
			if regularCast("BlessingMight", Player) then
				return true
			end
		end
	end
	if Setting("Use Blessing of Wisdom") then
		if not Buff.BlessingWissdom:Exist(Player) then
			if regularCast("BlessingWissdom", Player) then
				return true
			end
		end
	end
	--Buff Group Members
	if Setting ("Buff others") and not Player.Combat and Player.HP >= 20 then
		for _, Unit in ipairs(DMW.Units) do
			unitclass, unitclassid = select(2, UnitClass(Unit.Pointer))
			if Unit.Distance <= 10 and Unit.Player and Unit.Name~=Player.Name and Unit.LoS then
				if might[unitclass] and not Buff.BlessingMight:Exist(Unit) then
					if regularCast("BlessingMight",Unit) then
						return true
					end
				elseif wisdom[unitclass] and not Buff.BlessingWissdom:Exist(Unit)then
					if regularCast("BlessingWissdom",Unit) then
						return true
					end
				end
			end
		end
	end
end

local function Healing()
	-- HolyLight out of Combat
	if not Player.Combat and HP <= 75 then
		if regularCast("HolyLight", Player) then
			return true
		end
	end
	-- HolyLight in Combat
	if Player.Combat and HP <= 50 then
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
				if Setting("Use Seal Of Righteousness") and not Buff.SealOfRight:Exist(Player) then
					if regularCast("SealOfRight",Player) then
						return true
					end
				end
				--Seal of Command
				if Setting("Use Seal Of Command") and not Buff.SealOfRight:Exist(Player) then
					if regularCast("SealCommand",Player) then
						return true
					end
				end
				--Seal of Crusader
				if Setting("Use Seal Of Crusader") and not Buff.SealCrusader:Exist(Player) then
					if regularCast("SealCrusader",Player) then
						return true
					end
				end
				--Judgement
				if (Buff.SealOfRight:Exist(Player) or Buff.SealCrusader:Exist(Player) or Buff.SealCommand:Exist(Player)) and Spell.Judgement:CD() == 0 then
					if regularCast("Judgement", Target) then
						return true
					end
				end
			end 
		end
	end
end

local function Purify()
	if Setting("Use Purify") and Spell.Purify:IsReady() then
		for _, Unit in ipairs(Player:GetFriends(40)) do
			if Unit:Dispel(Spell.Purify) then
				if regularCast("Purify",Player) then 
					return true 
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
	if Purify() then
		return true
	end
	--Start Combat
	if Combat() then 
		return true
	end
end -- ROTATION