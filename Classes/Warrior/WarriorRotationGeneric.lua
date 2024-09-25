WarriorRotationGeneric = {}

WarriorRotationGeneric.diamondFlaskId = 20130
WarriorRotationGeneric.temperedHelmetId = 215161
WarriorRotationGeneric.goldwrapId = 215115

local usable

function WarriorRotationGeneric.ActivateItems(playerData, timeUntilDeath, executePhase)
	if(executePhase or timeUntilDeath < 60) then
		usable = IOService.SendIfItemUsable("Diamond Flask", WarriorRotationGeneric.diamondFlaskId)
		if(usable) then
			return true
		end
	end

	if(executePhase or timeUntilDeath < 30) then
		usable = IOService.SendIfItemUsable("Hyperconductive Goldwrap", WarriorRotationGeneric.goldwrapId)
		if(usable) then
			return true
		end
	end

	if(executePhase or timeUntilDeath < 10) then
		usable = IOService.SendIfItemUsable("Tempered Interference-Negating Helmet", WarriorRotationGeneric.temperedHelmetId)
		if(usable) then
			return true
		end
	end

	return false
end

function WarriorRotationGeneric.EnsureBuffs(playerData)
	usable, _ = IOService.SendIfAuraNeeded(playerData, "Battle Shout", true, 5, true)
	if(usable) then
		return true
	end

	if(not IOService.GetPlayerEffect(playerData, "Blood Pact", false)) then
		usable, _ = IOService.SendIfAuraNeeded(playerData, "Commanding Shout", true, 5, true)
		if(usable) then
			return true
		end
	end

	return false
end

function WarriorRotationGeneric.IsOverpowerUsable(playerData)
	if(IOService.GetPlayerEffect(playerData, "Taste for Blood", false)) then
		return true
	end

	if(playerData.target.id == WarriorRotation.lastDodgeId and time() - WarriorRotation.lastDodge < 4.5) then
		local _, duration, _, _ = GetSpellCooldown("Overpower")

		if ( duration ~= nil and duration > 1.5 ) then
			return false
		end

		return true
	end

	return false
end

function WarriorRotationGeneric.ShouldSweepingStrike(enemiesCount)
	if(enemiesCount <= 1) then
		return false
	end

	local _, duration, _, _ = GetSpellCooldown("Sweeping Strikes")

	if ( duration ~= nil and duration > 1.5 ) then
		return false
	end

	return true
end

function WarriorRotationGeneric.AttackWithMod(playerData, enemiesCount)
	if(enemiesCount > 1) then
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

	return false
end

return WarriorRotationGeneric