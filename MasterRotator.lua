MasterRotator = LibStub("AceAddon-3.0"):NewAddon("MasterRotator", "AceConsole-3.0", "AceEvent-3.0")

function MasterRotator:OnInitialize()
end

function MasterRotator:OnEnable()
    MasterRotatorGui.CreateBaseFrame()

    MasterRotator.AssignBasicInfo()
    MasterRotator.AssignClassRotation()

    MasterRotator.CreateModeButtons()
    MasterRotator.AddAbilities()

    MasterRotatorGui.CreateOutputBar()
    MasterRotatorGui.CreateBaseFrame()

    MasterRotator.AddHookScript()
end

function MasterRotator:OnDisable()
    -- Called when the addon is disabled
end

function MasterRotator.AssignBasicInfo()
    MasterRotator.playerGuid = UnitGUID("player")
    local _, englishClass, _, englishRace = GetPlayerInfoByGUID(MasterRotator.playerGuid)
    MasterRotator.class = englishClass
    MasterRotator.race = englishRace
end

function MasterRotator.AssignClassRotation()
    if(MasterRotator.class == "WARRIOR") then
        MasterRotator.ClassRotation = WarriorRotation
    end
    if(MasterRotator.class == "DRUID") then
        MasterRotator.ClassRotation = DruidRotation
    end

    if(not MasterRotator.ClassRotation) then
        error("Unsupported class!")
    end
end

function MasterRotator.CreateModeButtons()
    MasterRotatorGui.CreateExportFrame(MasterRotatorMacro.Export)

    local first = true
    local modes = MasterRotator.ClassRotation.InitModes()
	for mode, _ in pairs(modes) do
        if(first) then
            MasterRotator.rotationMode = mode
            first = false
        end
        MasterRotatorGui.CreateModeButton(mode, mode)
    end

    if(first) then
        error("MasterRotator.ClassRotation.InitModes return empty table")
    end
end

function MasterRotator.AddAbilities()
    MasterRotator.abilities = {}

    for abilityCode, ability in pairs(MasterRotator.ClassRotation.GetAbilities()) do
        MasterRotator.AddAbility(abilityCode, ability.name, ability.mainAbility, ability.preAbilities, ability.postAbilities, ability.actionOverride)
    end
end

function MasterRotator.AddAbility(abilityCode, name, mainAbility, preAbilities, postAbilities, actionOverride)
	MasterRotator.abilities[name] = {}

	MasterRotator.abilities[name].name = name

    if(mainAbility) then
        MasterRotator.abilities[name].mainAbility = mainAbility
    else
        MasterRotator.abilities[name].mainAbility = name
    end

	MasterRotator.abilities[name].preAbilities = preAbilities
	MasterRotator.abilities[name].postAbilities = postAbilities
	MasterRotator.abilities[name].actionOverride = actionOverride

	MasterRotator.abilities[name].code = abilityCode
	-- 0 = none, 1 = shift, 2 = ctrl
	MasterRotator.abilities[name].modKey = abilityCode % 3

	print("Adding " .. name .. " at " .. abilityCode )
    DebugHelper.PrintDump(MasterRotator.abilities[name])
end

MasterRotator.timeElapsed = 0
function OnUpdate(self, elapsed)
    MasterRotator.timeElapsed = MasterRotator.timeElapsed + elapsed
    if MasterRotator.timeElapsed > 5 then
        if(MasterRotator.timeElapsed > 0.1) then
            print("Slow callback problem, time: " .. MasterRotator.timeElapsed )
        end

        MasterRotator.timeElapsed = 0

        local nClock = GetTime()
        local playerData = IOService.GetPlayerData()
        MasterRotator.ClassRotation.Rotation(MasterRotator.rotationMode, playerData)
        local diff = GetTime() - nClock
        if(diff > 0) then
            print("Rotation exec time: " .. diff)
        end
    end
end

MasterRotator.timeElapsed = 0
function MasterRotator.AddHookScript()
    MasterRotatorGui.baseFrame:HookScript("OnUpdate", function(self, elapsed)
        MasterRotator.timeElapsed = MasterRotator.timeElapsed + elapsed
        if MasterRotator.timeElapsed > 0.02 then
            if(MasterRotator.timeElapsed > 0.1) then
                print("Slow callback problem, time: " .. MasterRotator.timeElapsed )
            end

            MasterRotator.timeElapsed = 0

            local nClock = GetTime()
            local playerData = IOService.GetPlayerData()
            MasterRotator.ClassRotation.Rotation(MasterRotator.rotationMode, playerData)
            local diff = GetTime() - nClock
            if(diff > 0) then
                print("Rotation exec time: " .. diff)
            end
        end
    end)
end
