IOService = {}

function IOService.GetRuneOnSlot(slotname)
	local slotId = IOService.Constants.ValidRuneSlots[slotname]
	local rune = C_Engraving.GetRuneForEquipmentSlot(slotId)

	if (not rune) then
		return ""
	end

	return rune.name
end

function IOService.GetSpec()
	local maxPoint = 0
	local maxId = ""

	for i = 1, GetNumTalentTabs() do
		local id, _, pointsSpent = GetTalentTabInfo(i)

		if(pointsSpent > maxPoint) then
			maxPoint = pointsSpent
			maxId = id
		end
	end

	return maxId
end

function IOService.GetPlayerData()
	local playerData = {}

	--name, icon, count, debufftype, duration, expirationTime, unitCaster
	playerData.playerEffects = {}
	playerData.otherEffects = {}
	for i=1, 40 do
		local aura = { UnitAura("player", i, "") }
		if (not aura[1]) then
			break
		end

		if(aura[7] == "player") then
			playerData.playerEffects[aura[1]] = aura
		else
			playerData.otherEffects[aura[1]] = aura
		end
	end

	playerData.form = GetShapeshiftForm()
	playerData.power = UnitPower("player")

	playerData.target = {}
	playerData.target.id = UnitGUID("target")
	playerData.target.name = UnitName("target")
	playerData.target.health = UnitHealth("target")
	playerData.target.healthMax = UnitHealthMax("target")

	if(playerData.target.id) then
		playerData.target.isBoss = (UnitLevel("target") == -1)
		playerData.target.playerEffects = {}
		playerData.target.otherEffects = {}

		for i=1, 40 do
			local aura = { UnitAura("target", i, "HARMFUL") }
			if (not aura[1]) then
				break
			end

			if(aura[7] == "player") then
				playerData.target.playerEffects[aura[1]] = aura
			else
				playerData.target.otherEffects[aura[1]] = aura
			end
		end
	end

	return playerData
end

function IOService.GetGroupData()
	local  groupData = {}

	local targetList
	if(IsInRaid()) then
		targetList = IOService.Constants.RaidTargets
	elseif(IsInGroup())  then
		targetList = IOService.Constants.GroupTargets
	else
		return groupData
	end

	local playerMap = C_Map.GetBestMapForUnit("player")

	for _, target in ipairs(targetList) do
		if(not UnitExists(target)) then
			break
		end

		local targetMap = C_Map.GetBestMapForUnit(target)

		if(playerMap == targetMap) then
			local raider = {}

			raider["unit"] = target
			raider["health"] = UnitHealth(target)
			raider["maxHealth"] = UnitHealthMax(target)
			raider["position"] = C_Map.GetPlayerMapPosition(targetMap, target)

			table.insert(groupData, raider)
		end
	end

	return groupData
end

function IOService.GetGroupTargets()
	if(IsInRaid()) then
		return IOService.Constants.RaidTargets
	elseif(IsInGroup())  then
		return IOService.Constants.GroupTargets
	end

	return {[1] = "player"}
end

function IOService.GetItemCd(itemId)
	local _, duration, _ = C_Container.GetItemCooldown(itemId)
	return duration
end

function IOService.GetEnemiesWithinMeleeRange()
	local inRange = 0
	local unitID = 0

	for _, plate in pairs(C_NamePlate.GetNamePlates()) do
		unitID = plate.namePlateUnitToken
		if UnitCanAttack("player", unitID) and IsSpellInRange("Rend", unitID) == 1 then
			inRange = inRange + 1
		end
	end
	return inRange
end

function IOService.GetHealth()
	return UnitHealth("player"), UnitHealthMax("player")
end

function IOService.GetPlayerEffect(playerData, effect, byPlayer)
	if(not playerData.target.playerEffects) then
		return nil
	end

	local playerEffect = playerData.playerEffects[effect]

	if(byPlayer) then
		return playerEffect
	end

	if(not playerEffect) then
		return playerData.otherEffects[effect]
	end

	return playerEffect
end

function IOService.GetTargetEffect(playerData, effect, byPlayer)
	if(not playerData.target.playerEffects) then
		return nil
	end

	local playerEffect = playerData.target.playerEffects[effect]

	if(byPlayer) then
		return playerEffect
	end

	if(not playerEffect) then
		return playerData.target.otherEffects[effect]
	end

	return playerEffect
end

function IOService.GetComboPoints()
	return GetComboPoints("player", "target")
end

function IOService.IsBleedImmune(playerData)
	if(not IOService.Constants.BleedImmuneTypes[UnitCreatureType("target")]) then
		return false
	end

	if(IOService.Constants.CanBleedMobs[playerData.target.name]) then
		return false
	end

	return true
end

function IOService.SendIfUsable(ability, ignoreNoMana)
	local _, duration, _, _ = GetSpellCooldown(ability)

	if ( duration ~= nil and duration > 1.5 ) then
		return false, false
	end

	local usable, noMana = IsUsableSpell(ability)
	if (usable or (ignoreNoMana and noMana)) then
		IOService.SendAbility(ability)
	end

	return usable or (ignoreNoMana and noMana), noMana
end

function IOService.SendIfUsableStance(playerData, ability, ignoreNoMana)
	if(playerData.form == IOService.Constants.Stances[ability]) then
		return false, false
	end

	local start, duration, enabled, modRate = GetSpellCooldown(ability)
	if ( start ~= 0 ) then
		return false, false
	end

	local usable, noMana = IsUsableSpell(ability)
	if (usable or (ignoreNoMana and noMana)) then
		IOService.SendAbility(ability)
	end

	return usable, noMana
end

function IOService.SendIfUsableDruidForm(playerData, ability, ignoreNoMana)
	if(playerData.form == IOService.Constants.Forms[ability]) then
		return false, false
	end

	IOService.SendAbility(ability)

	return true, false
end

function IOService.SendIfAuraNeeded(playerData, ability, ignoreNoMana, overlapTime, byAnySource)
	local effect = IOService.GetPlayerEffect(playerData, ability, not byAnySource)

	if(not effect or (overlapTime and effect[6] ~= 0 and effect[6] - GetTime() < overlapTime)) then
		return IOService.SendIfUsable(ability, ignoreNoMana)
	end

	return false, false
end

function IOService.SendIfDebuffNeeded(playerData, ability, ignoreNoMana, overlapTime, byAnySource)
	local effect = IOService.GetTargetEffect(playerData, ability, not byAnySource)

	if(not effect or (overlapTime and effect[6] ~= 0 and effect[6] - GetTime() < overlapTime)) then
		return IOService.SendIfUsable(ability, ignoreNoMana)
	end

	return false, false
end

function IOService.SendIfOffCd(ability, ignoreNoMana)
	local _, duration, _, _ = GetSpellCooldown(ability)

	if (duration ~= nil and duration > 1.5 ) then
		return false, false
	end

	IOService.SendAbility(ability)
	return true, false
end

function IOService.SendAbility(abilityName)
	local ability = MasterRotator.abilities[abilityName]

	MasterRotatorGui.output:SetColorTexture(100 / 255, 0, ability.code / 255)
	return true, true
end

function IOService.SendIfItemUsable(ability, itemId)
	local duration = IOService.GetItemCd(itemId)
	if (duration ~= 0) then
		return false
	end

	IOService.SendAbility(ability)

	return true
end

function IOService.SendTarget(target)
	local targetCode = IOService.Constants.TargetCodes[target]

	if(not targetCode) then
		error("Can't find targetCode for " .. target)
	end

	MasterRotatorGui.output:SetColorTexture(100 / 255, 1 / 255, targetCode / 255)
	return true
end

function IOService.SendNothing()
	MasterRotatorGui.output:SetColorTexture(100 / 255, 0, 0)
	return false
end

function IOService.TimeUntilDeath(playerData)
	local combat = Details:GetCurrentCombat()
	local target = combat:GetActor(DETAILS_ATTRIBUTE_DAMAGE, playerData.target.name)

	if(not target) then
		return nil
	end

	local damageTaken = target.damage_taken
	local combatTime = combat:GetCombatTime()

	if(combatTime < 3) then
		return nil
	end

	local effectiveDPS = damageTaken / combatTime

	return playerData.target.health / effectiveDPS
end

return IOService