RotatorService = {}

RotatorService.abilities = {}
RotatorService.abilityCode = 1

function RotatorService.AddAbility(name, mainAbility, preAbilities, postAbilities, actionOverride)
	RotatorService.abilities[name] = {}

	RotatorService.abilities[name].name = name
	RotatorService.abilities[name].mainAbility = mainAbility
	RotatorService.abilities[name].preAbilities = preAbilities
	RotatorService.abilities[name].postAbilities = postAbilities
	RotatorService.abilities[name].actionOverride = actionOverride

	RotatorService.abilities[name].code = RotatorService.abilityCode
	-- 0 = none, 1 = shift, 2 = ctrl
	RotatorService.abilities[name].modKey = RotatorService.abilityCode % 3

	print("Adding " .. name .. " at " .. RotatorService.abilityCode )

	RotatorService.abilityCode = RotatorService.abilityCode + 1
end

return RotatorService