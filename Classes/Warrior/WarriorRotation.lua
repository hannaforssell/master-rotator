WarriorRotation = {}

WarriorRotation.lastDodge = 0
WarriorRotation.lastDodgeId = nil
WarriorRotation.subscribedEvents = {
    ["SPELL_MISSED"] = true,
    ["SWING_MISSED"] = true,
    ["SPELL_DAMAGE"] = true
}

function WarriorRotation.InitModes()
    WarriorRotation.Modes = {}

    local spec = IOService:GetSpec()

    print("Using rotations for ".. spec)
    if(spec == "Arms") then
        WarriorRotation.Modes["Solo"] = WarriorRotationArms.Solo_Arms
		WarriorRotation.Modes["Single"] = WarriorRotationArms.SingleTarget_Arms
        WarriorRotation.Modes["Multi"] = WarriorRotationArms.MultiTarget_Arms
        WarriorRotation.Modes["Pvp"] = WarriorRotationArms.Pvp_Arms
	elseif(spec == "Fury") then
		WarriorRotation.Modes["Single"] = WarriorRotationSnB.SingleTarget_SnB
    elseif(spec == "Protection") then
    else
        error("Unkown spec " .. spec)
    end

    local warriorFrame = CreateFrame("Frame")
	warriorFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	warriorFrame:SetScript("OnEvent", function(self, event)
		local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, swingMissType, spellName, _, spellMissType, critical = CombatLogGetCurrentEventInfo()

		if(sourceGUID ~= MasterRotator.playerGuid or not WarriorRotation.subscribedEvents[subevent]) then
			return
		end

		if(spellName == "Overpower") then
			WarriorRotation.lastDodge = 0
			WarriorRotation.lastDodgeId = nil
			return;
		end

		if(subevent == "SPELL_MISSED" and spellMissType == "DODGE" or subevent == "SWING_MISSED" and swingMissType == "DODGE") then
			WarriorRotation.lastDodge = timestamp
			WarriorRotation.lastDodgeId = destGUID
		end
	end)

    return WarriorRotation.Modes
end

function WarriorRotation.GetAbilities()
    local gladiatorStance = IOService.GetRuneOnSlot("Feet") == "Gladiator Stance";
    local furiousThunder = IOService.GetRuneOnSlot("Legs") == "Furious Thunder";

	local battleStance = {"Battle Stance"}
    local thunderClapBattleStance = {"Battle Stance"}
	local defensiveStance = {"Defensive Stance"}
	local berserkerStance = {"Berserker Stance"}

	if(gladiatorStance) then
		battleStance = nil
		defensiveStance = nil
		berserkerStance = nil
        thunderClapBattleStance = nil
	end
    if(furiousThunder) then
        thunderClapBattleStance = nil
    end

    return {
        [1] = {name = "Bloodrage"},
        [2] = {name = "Overpower", preAbilities = battleStance},
        [3] = {name = "Victory Rush"},
        [4] = {name = "Heroic Strike"},
        [5] = {name = "Battle Shout",},
        [6] = {name = "Rend"},
        [7] = {name = "Cleave"},
        [8] = {name = "Revenge"},
        [9] = {name = "Sunder Armor"},
        [10] = {name = "Thunder Clap", preAbilities = thunderClapBattleStance},
        [11] = {name = "Demoralizing Shout"},
        [12] = {name = "Execute"},
        [13] = {name = "Quick Strike"},
        [14] = {name = "Raging Blow"},
        [15] = {name = "Hamstring"},
        [16] = {name = "Battle Stance"},
        [17] = {name = "Defensive Stance"},
        [18] = {name = "Berserker Stance"},
        [19] = {name = "War Stomp"},
        [20] = {name = "Disarm",  preAbilities = defensiveStance},
        [21] = {name = "Sweeping Strikes", preAbilities = battleStance},
        [22] = {name = "Commanding Shout"},
        [23] = {name = "Slam"},
        [24] = {name = "Pummel", preAbilities = berserkerStance},
        [25] = {name = "Berserker Rage", preAbilities = berserkerStance},
        [26] = {name = "Whirlwind", preAbilities = berserkerStance},
        [27] = {name = "Bloodthirst"},
        [28] = {name = "Enraged Regeneration"},
        [29] = {name = "Mortal Strike"},
        [30] = {name = "Death Wish"},
        [31] = {name = "Gladiator Stance"},
        [32] = {name = "Diamond Flask"},
        [33] = {name = "Hyperconductive Goldwrap"},
        [34] = {name = "Tempered Interference-Negating Helmet"}
    }
end

function WarriorRotation.Rotation(mode, playerData)
    local rotateFunc = WarriorRotation.Modes[mode]
    if(rotateFunc) then
        return rotateFunc(playerData)
    end
    error("No rotation function found for " .. mode)
end

return WarriorRotation