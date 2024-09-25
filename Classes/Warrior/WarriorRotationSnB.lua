WarriorRotationSnB = {}

local usable

function WarriorRotationSnB.SingleTarget_SnB(playerData)
	-- 13/28/0
	-- Shield Mastery
	-- Flagellation
	-- Focused Rage
	-- Consumed By Rage
	-- Gladiator Stance
	-- Rampage
	-- Devastate	

	usable, _ = IOService.SendIfUsableStance(playerData, "Gladiator Stance", true)
	if(usable) then
		return true
	end

	if(playerData.target.isBoss) then
		local timeUntilDeath = IOService.TimeUntilDeath(playerData) or 1024
		local executePhase = playerData.target.health ~= 0 and ((playerData.target.health / playerData.target.healthMax) < 0.2)

		if(WarriorRotationGeneric.ActivateItems(playerData, timeUntilDeath, executePhase)) then
			return true
		end

		if(executePhase or timeUntilDeath < 30) then
			usable, _ = IOService.SendIfUsable("Death Wish", true)
			if(usable) then
				return true
			end
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

	if(WarriorRotationGeneric.EnsureBuffs(playerData)) then
		return true
	end

	usable, _ = IOService.SendIfUsable("Execute", true)
	if(usable) then
		return true
	end

	usable, _ = IOService.SendIfUsable("Overpower", true)
	if(usable) then
		return true
	end

	if(playerData.power >= 80) then
		usable, _ = IOService.SendIfUsable("Whirlwind", true)
		if(usable) then
			return true
		end

		local enemiesCount = IOService.GetEnemiesWithinMeleeRange()
		if(WarriorRotationGeneric.AttackWithMod(playerData, enemiesCount)) then
			return true
		end
	end

	usable, _ = IOService.SendIfUsable("Sunder Armor", true)
	if(usable) then
		return true
	end

	return IOService.SendNothing()
end

return WarriorRotationSnB