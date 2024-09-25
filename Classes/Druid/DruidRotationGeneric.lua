DruidRotationGeneric = {}

function DruidRotationGeneric.AssureTarget(playerData, target)
    local targetId = UnitGUID(target)
    if(targetId == playerData.target.id) then
        return false
    end

    IOService.SendTarget(target)
    return true
end

return DruidRotationGeneric