DruidRotationResto = {}

local usable

DruidRotationFeral.powershiftManaCost = 585 + 53
DruidRotationFeral.ritualistId = 221446

function DruidRotationResto.Healing_Resto(playerData)
    -- O -- Regrowth/Healing Touch/Nourish(spec if already has my HOT) as emergency for dying players
    -- O -- Remove curse/Cure poison if any dangerous ones
    -- X -- Keep Insect swarm/Faerie Fire on boss
    -- O -- To raid heal - Rejuvenation(Rank 1) + Swiftmend on me, then Efflorescence (15 sec) (heals around swiftmend target)
    -- O -- 2 or more group members are injured -> Wild growth
    -- O -- Single target healing -> Lifebloom -> Nourish (if further healing required)
    -- O -- Incoming damage low? Wrath for regen Mana & proc instant Healing Touch

    -- local map = C_Map.GetBestMapForUnit("player")
    -- local position = C_Map.GetPlayerMapPosition(map, "raid1")
    -- print(position:GetXY()) -- 0.54766619205475, 0.54863452911377

    -- local groupData = IOService.GetGroupData()
    -- --DebugHelper.PrintDump(groupData)

    -- if (not IOService.GetTargetEffect(playerData, "Insect Swarm", false)) then
    --     usable, _ = IOService.SendIfDebuffNeeded(playerData, "Insect Swarm", true, 1, true)
    --     if (usable) then
    --         return true
    --     end
    -- end

    -- if (not IOService.GetTargetEffect(playerData, "Faerie Fire", false)) then
    --     usable, _ = IOService.SendIfDebuffNeeded(playerData, "Faerie Fire", true, 1, true)
    --     if (usable) then
    --         return true
    --     end
    -- end

    -- usable, _ = IOService.SendIfUsable("Wrath", true)
    -- if(usable) then
    --   return true
    -- else
    -- end

    return IOService.SendNothing()
end

function DruidRotationResto.Pvp_Resto(playerData)
    if(playerData.form ~= 1) then
        return IOService.SendIfUsableDruidForm(playerData, "Bear", true)
    end

    if(playerData.power < 80) then
        usable, _ = IOService.SendIfUsable("Enrage", true)
		if(usable) then
			return true
		end
    end

    local health, maxHealth = IOService.GetHealth()
	if((health / maxHealth) < 0.7 and playerData.power > 10) then
		usable, _ = IOService.SendIfUsable("Frenzied Regeneration", true)
		if(usable) then
			return true
		end
	end

    usable, _ = IOService.SendIfUsable("Bash", true)
    if(usable) then
        return true
    end

    usable, _ = IOService.SendIfDebuffNeeded(playerData, "Demoralizing Roar", true)
	if(usable) then
		return true
	end

    if(not IOService.GetPlayerEffect(playerData, "Frenzied Regeneration", false) or playerData.power > 50) then
        usable, _ = IOService.SendIfUsable("Maul", true)
        if(usable) then
            return true
        end
    end

    return IOService.SendNothing()
end

return DruidRotationResto
