WarriorRotationArms = {}

local usable

function WarriorRotationArms.Solo_Arms(playerData)
	-- ARMS 31/10/0
	-- Taste for Blood
	-- Flagellation
	-- Precise Timing
	-- Frenzied Assault
	-- Enraged Regeneration
	-- Rampage
	-- Victory Rush

    usable, _ = IOService.SendIfUsable("Victory Rush", true)
	if(usable) then
		return true
	end

    return WarriorRotationArms.SingleTarget_Arms(playerData)
end

function WarriorRotationArms.SingleTarget_Arms(playerData)
	-- ARMS 31/10/0
	-- Taste for Blood
	-- Flagellation
	-- Precise Timing
	-- Frenzied Assault
	-- Enraged Regeneration
	-- Rampage
	-- Endless Rage

	local timeUntilDeath = IOService.TimeUntilDeath(playerData) or 1024
	local executePhase = playerData.target.health ~= 0 and ((playerData.target.health / playerData.target.healthMax) < 0.2)
	if(WarriorRotationGeneric.ActivateItems(playerData, timeUntilDeath, executePhase)) then
		return true
	end

	local enemiesCount = IOService.GetEnemiesWithinMeleeRange()

	if(WarriorRotationGeneric.IsOverpowerUsable(playerData)) then
		if(playerData.form ~= 1 and playerData.power > 25) then
			if(WarriorRotationGeneric.AttackWithMod(playerData, enemiesCount)) then
				return true
			end
		end

		usable, _ = IOService.SendIfOffCd("Overpower", true)
		if(usable) then
			return true
		end
	end

	if(not IOService.IsBleedImmune(playerData)) then
		usable, _ = IOService.SendIfDebuffNeeded(playerData, "Rend", true)
		if(usable) then
			return true
		end
	end

	local health, maxHealth = IOService.GetHealth()
	if((health / maxHealth) < 0.7) then
		usable, _ = IOService.SendIfUsable("Enraged Regeneration", true)
		if(usable) then
			return true
		end
	end

	--Byt till berserk om det inte är overpower/sweeping strike dags
	if(playerData.form ~= 3 and not WarriorRotationGeneric.ShouldSweepingStrike(enemiesCount) and not WarriorRotationGeneric.IsOverpowerUsable(playerData)) then
		if(playerData.power <= 25) then
			return IOService.SendIfUsableStance(playerData, "Berserker Stance", true)
		else
			return WarriorRotationArms.RageDump(playerData, 25, enemiesCount)
		end
	end

	if(not IOService.GetPlayerEffect(playerData, "Flagellation", true)) then
		usable, _ = IOService.SendIfUsable("Bloodrage", true)
		if(usable) then
			return true
		end

		usable, _ = IOService.SendIfOffCd("Berserker Rage", true)
		if(usable) then
			return true
		end
	end

	return WarriorRotationArms.RageDump(playerData, 50, enemiesCount)
end

function WarriorRotationArms.MultiTarget_Arms(playerData)
	-- ARMS 31/10/0
	-- Taste for Blood
	-- Flagellation
	-- Focused Rage
	-- Frenzied Assault
	-- Enraged Regeneration
	-- Rampage
	-- Endless Rage

	if(IOService.GetPlayerEffect(playerData, "Bladestorm", true)) then
		return IOService.SendNothing()
	end

	if(not IOService.GetPlayerEffect(playerData, "Flagellation", true)) then
		usable, _ = IOService.SendIfUsable("Bloodrage", true)
		if(usable) then
			return true
		end

		usable, _ = IOService.SendIfOffCd("Berserker Rage", true)
		if(usable) then
			return true
		end
	end

	usable, _ = IOService.SendIfUsable("Overpower", true)
	if(usable) then
		return true
	end

	if(WarriorRotationGeneric.EnsureBuffs(playerData)) then
		return true
	end

	local enemies = IOService.GetEnemiesWithinMeleeRange()
	if(enemies >= 1) then
		usable, _ = IOService.SendIfOffCd("Sweeping Strikes", true)
		if(usable) then
			return true
		end

		usable, _ = IOService.SendIfOffCd("Whirlwind", true)
		if(usable) then
			return true
		end

		if(not IsCurrentSpell("Cleave")) then
			usable, _ = IOService.SendIfUsable("Cleave", true)
			if(usable) then
				return true
			end
		end
	else
		if(not IsCurrentSpell("Heroic Strike")) then
			usable, _ = IOService.SendIfUsable("Heroic Strike", true)
			if(usable) then
				return true
			end
		end
	end

	return IOService.SendNothing()
end

function WarriorRotationArms.Pvp_Arms(playerData)
	if(playerData.form ~= 1) then
		return IOService.SendIfUsableStance(playerData, "Battle Stance", true)
	end

	usable, _ = IOService.SendIfUsable("Bloodrage", true)
	if(usable) then
		return true
	end

	local health, maxHealth = IOService.GetHealth()
	if((health / maxHealth) < 0.7) then
		usable, _ = IOService.SendIfUsable("Enraged Regeneration", true)
		if(usable) then
			return true
		end
	end

	local _, englishClass, _ = UnitClass("unit");
	if(englishClass == "PRIEST") then
		usable, _ = IOService.SendIfUsable("Berserker Rage", true)
		if(usable) then
			return true
		end
	end

	if(WarriorRotationGeneric.IsOverpowerUsable(playerData)) then
		if(playerData.form ~= 1 and playerData.power > 25) then
			if(WarriorRotationGeneric.AttackWithMod(playerData, 1)) then
				return true
			end
		end

		usable, _ = IOService.SendIfOffCd("Overpower", true)
		if(usable) then
			return true
		end
	end

	usable, _ = IOService.SendIfUsable("Execute", true)
	if(usable) then
		return true
	end

	if(WarriorRotationGeneric.EnsureBuffs(playerData)) then
		return true
	end

	usable, _ = IOService.SendIfDebuffNeeded(playerData, "Rend", true)
	if(usable) then
		return true
	end

	usable, _ = IOService.SendIfUsable("Slam", true)
	if(usable) then
		return true
	end

	if(playerData.power > 50 and not IsCurrentSpell("Heroic Strike")) then
		usable, _ = IOService.SendIfUsable("Heroic Strike", true)
		if(usable) then
			return true
		end
	end

	usable, _ = IOService.SendIfUsable("Mortal Strike", true)
	if(usable) then
		return true
	end

	return IOService.SendNothing()
end

function WarriorRotationArms.RageDump(playerData, limit, enemiesCount)
	usable, _ = IOService.SendIfUsable("Execute", true)
	if(usable) then
		return true
	end

	if(WarriorRotationGeneric.EnsureBuffs(playerData)) then
		return true
	end

	if(enemiesCount > 1) then
		if(playerData.form == 1 or playerData.power < 25) then
			usable, _ = IOService.SendIfUsable("Sweeping Strikes", true)
			if(usable) then
				return true
			end
		end

		if(playerData.form == 3) then
			usable, _ = IOService.SendIfUsable("Whirlwind", true)
			if(usable) then
				return true
			end
		end
	end

	usable, _ = IOService.SendIfUsable("Slam", true)
	if(usable) then
		return true
	end

	usable, _ = IOService.SendIfUsable("Mortal Strike", true)
	if(usable) then
		return true
	end

	if(playerData.form == 3 or  playerData.power <= 25) then
		usable, _ = IOService.SendIfUsable("Whirlwind", true)
		if(usable) then
			return true
		end
	end

	if(playerData.power > limit) then
		if(WarriorRotationGeneric.AttackWithMod(playerData, enemiesCount)) then
			return true
		end
	end

	if(IOService.GetPlayerEffect(playerData, "Wild Strikes", false)) then
		usable, _ = IOService.SendIfUsable("Hamstring", true)
		if(usable) then
			return true
		end
	end

	return IOService.SendNothing()
end

return WarriorRotationArms