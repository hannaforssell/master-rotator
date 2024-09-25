DruidRotation = {}

function DruidRotation.InitModes()
    DruidRotation.Modes = {}

    local spec = IOService:GetSpec()

    print("Using rotations for ".. spec)
    if(spec == "Balance") then
	elseif(spec == "Feral Combat") then
		DruidRotation.Modes["Solo"] = DruidRotationFeral.Solo_Feral
		DruidRotation.Modes["Group"] = DruidRotationFeral.Group_Feral
    elseif(spec == "Restoration") then
        DruidRotation.Modes["Healing"] = DruidRotationResto.Healing_Resto
        DruidRotation.Modes["Pvp"] = DruidRotationResto.Pvp_Resto
    else
        error("Unkown spec " .. spec)
    end

    return DruidRotation.Modes
end

function DruidRotation.GetAbilities()
    return {
        [1] = {name = "Mangle(Cat)"},
        [2] = {name = "Shred"},
        [3] = {name = "Rake"},
        [4] = {name = "Rip"},
        [5] = {name = "Tiger's Fury",},
        [6] = {name = "Ferocious Bite"},
        [7] = {name = "Berserk"},
        [8] = {name = "Faerie Fire (Feral)"},
        [9] = {name = "Savage Roar"},
        [10] = {name = "Innervate"},
        [11] = {name = "Powershift", mainAbility = "!cat form"},
        [12] = {name = "Ravage"},
        [13] = {name = "Ritualist's Hammer"},
        [14] = {name = "Mangle(Bear)"},
        [15] = {name = "Bash"},
        [16] = {name = "Regrowth"},
        [17] = {name = "Healing Touch"},
        [18] = {name = "Nourish"},
        [19] = {name = "Remove Curse"},
        [20] = {name = "Cure Poison"},
        [21] = {name = "Insect Swarm"},
        [22] = {name = "Faerie Fire"},
        [23] = {name = "Rejuvenation(Rank 1)"},
        [24] = {name = "Swiftmend"},
        [25] = {name = "Wild Growth"},
        [26] = {name = "Lifebloom"},
        [27] = {name = "Wrath"},
        [28] = {name = "Bear", mainAbility = "!dire bear form"},
        [29] = {name = "Demoralizing Roar"},
        [30] = {name = "Enrage"},
        [31] = {name = "Maul"},
        [32] = {name = "Frenzied Regeneration"}
    }
end

function DruidRotation.Rotation(mode, playerData)
    local rotateFunc = DruidRotation.Modes[mode]
    if(rotateFunc) then
        return rotateFunc(playerData)
    end
    error("No rotation function found for " .. mode)
end

return DruidRotation