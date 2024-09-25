MasterRotatorMacro = {}
MasterRotatorMacro.Constants = {}

MasterRotatorMacro.preMacroText = "/startattack\n"

function MasterRotatorMacro.Export()
	MasterRotatorMacro.AddPersonalMacros()
	MasterRotatorMacro.AddTargetingMacros()
	MasterRotatorMacro.GetKeybindings()
end

function MasterRotatorMacro.AddPersonalMacros()
	for i = 1, 100 do
		DeleteMacro("ZZRotate-" .. i)
	end

	local sortedAbilities = {}
	for _, ability in pairs(MasterRotator.abilities) do
		sortedAbilities[ability.code] = ability
	end

	local macroText = MasterRotatorMacro.preMacroText
	local macroTexts = {}
	local	modText = ""
	for i, ability in ipairs(sortedAbilities) do
		if(i % 3 == 1 and i ~= 1) then
			table.insert(macroTexts, macroText)
			macroText = MasterRotatorMacro.preMacroText
		end

		if(ability.modKey == 0) then
			modText = "[nomod]"
		elseif(ability.modKey == 1) then
			modText = "[mod:shift]"
		elseif(ability.modKey == 2) then
			modText = "[mod:ctrl]"
		end

		if(ability.preAbilities ~= nil) then
			for _, v in ipairs(ability.preAbilities) do
				macroText = macroText .. "\n/cast " .. modText .. " " .. v
			end
		end

		local actionText = "/cast"
		if(ability.actionOverride) then
			actionText = ability.actionOverride
		end

		macroText = macroText .. "\n" .. actionText .. " " .. modText .. " " .. ability.mainAbility

		if(ability.postAbilities ~= nil) then
			for _, v in ipairs(ability.postAbilities) do
				macroText = macroText .. "\n/cast " .. modText .. " " .. v
			end
		end
	end

	if(macroText ~= "") then
		table.insert(macroTexts, macroText)
	end

	for i, macroText in ipairs(macroTexts) do
		CreateMacro("ZZRotate-" .. i, "INV_MISC_QUESTIONMARK", macroText, 1);
		print(SetBindingMacro("F" .. i, "ZZRotate-" .. i))
	end
end

function MasterRotatorMacro.AddTargetingMacros()
	for i = 1, 100 do
		DeleteMacro("ZZTarget-" .. i)
	end

	local macroText = ""
	local groupTargets = IOService.Constants.TargetCodes
	for i = 1, #groupTargets do
		if(i % 4 == 0) then
			macroText = macroText .. "\n/tar [nomod] " .. groupTargets[i]
		elseif(i % 4 == 1) then
			macroText = macroText .. "\n/tar [mod:shift] " .. groupTargets[i]
		elseif(i % 4 == 2) then
			macroText = macroText .. "\n/tar [mod:ctrl] " .. groupTargets[i]
		elseif(i % 4 == 3) then
			macroText = macroText .. "\n/tar [mod:alt] " .. groupTargets[i]
		end

		if((i ~= 1 and i % 4 == 0) or i == #groupTargets) then
			local macroNumber = ceil(i / 4)
			print(macroNumber)
			CreateMacro("ZZTarget-" .. macroNumber, "INV_MISC_QUESTIONMARK", macroText, false);
			print(SetBindingMacro("NUMPAD" .. (macroNumber - 1), "ZZTarget-" .. macroNumber))
			macroText = ""
		end
	end
end

function MasterRotatorMacro.GetKeybindings()
	local sortedAbilities = {}
	for _, ability in pairs(MasterRotator.abilities) do
		sortedAbilities[ability.code] = ability
	end

	local translations = {}

	local mod = ""
	for i, ability in pairs(sortedAbilities) do
		if(ability.modKey == 0) then
			mod = nil
		elseif(ability.modKey == 1) then
			mod = "LShiftKey" --Shift
		elseif(ability.modKey == 2) then
			mod = "LControlKey" --Ctrl
		end

		local key = "F" .. (floor((i - 1) / 3) + 1)

		translations[ability.code] = {}
		translations[ability.code].Id = ability.code
		translations[ability.code].Key = key
		translations[ability.code].Mod = mod
		translations[ability.code].Name = ability.name
	end

	MasterRotatorGui:DisplayText(JSON:encode(translations))
end

return MasterRotatorMacro
