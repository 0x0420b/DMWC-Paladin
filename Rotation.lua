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

local function regularCast(spell, Unit)
	if Spell[spell]:Cast(Unit) then
        return true
    end
end

function Paladin.Rotation()
	Locals()
-- Debug Settings
	if not Player.Combat and Setting("Debug") then
		if not prevs == nil then  
			prevs = nil
		end
		if not prev == nil then
			prev = nil
		end
	end	
	-- Debug Settings end
	
-- Targeting 
	if Player.Combat and not (Target and Target.ValidEnemy) and #Player:GetEnemies(5) >= 1 and Setting("AutoTarget") then
		TargetUnit(DMW.Attackable[1].unit)
	end 
	-- Targeting end

	if Target and Target.ValidEnemy and Target.Health > 1 then
		-- Auto Attack Start
		if not IsCurrentSpell(6603) and Target.Distance <= 5 then
			StartAttack(Target.Pointer)
		end
		-- Auto Attack end
	end 
	--Target.ValidEnemy end
end 
--Rotation end