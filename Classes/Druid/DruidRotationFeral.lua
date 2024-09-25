DruidRotationFeral = {}

local usable

DruidRotationFeral.powershiftManaCost = 585 + 53
DruidRotationFeral.ritualistId = 221446

function DruidRotationFeral.Solo_Feral(playerData)
    if(DruidRotationFeral.GenericDamage(playerData)) then
        return true
      end

      usable, _ = IOService.SendIfUsable("Mangle(Cat)", true)
      if(usable) then
        return true
      end

      return IOService.SendNothing()
end

function DruidRotationFeral.Group_Feral(playerData)
    if(playerData.form ~= 3) then
        return IOService.SendAbility("Powershift")
    end

    if (DruidRotationFeral.GenericDamage(playerData)) then
        return true
    end

    local mana = UnitPower("player", 0)
    if (playerData.power <= 10 and mana > DruidRotationFeral.powershiftManaCost) then
        if (mana > DruidRotationFeral.powershiftManaCost * 2) then
            usable, _ = IOService.SendAbility("Powershift")
            if (usable) then
                return true
            end
        else
            usable, _ = IOService.SendIfUsable("Innervate", true)
            if (usable) then
                return true
            end
        end
    end

    usable, _ = IOService.SendIfUsable("Shred", true)
    if (usable) then
        return true
    end

    return IOService.SendNothing()
end

function DruidRotationFeral.GenericDamage(playerData)
    local comboPoints = IOService.GetComboPoints()

    if (IOService.GetPlayerEffect(playerData, "Prowl", true)) then
        usable, _ = IOService.SendIfUsable("Ravage", true)
        if (usable) then
            return true
        end
    end

    if (not IOService.GetTargetEffect(playerData, "Faerie Fire", false)) then
        usable, _ = IOService.SendIfDebuffNeeded(playerData, "Faerie Fire (Feral)", true, 1, true)
        if (usable) then
            return true
        end
    end

    local savageRoar = IOService.GetPlayerEffect(playerData, "Savage Roar", true)
    if (not savageRoar or savageRoar[6] - GetTime() < 1.5) then
        if (comboPoints >= 2) then
            IOService.SendIfUsable("Savage Roar", true)
            return true
        else
            IOService.SendIfUsable("Mangle(Cat)", true)
            return true
        end
    end

    if (comboPoints == 5) then
        local timeUntilDeath = IOService.TimeUntilDeath(playerData) or 1024

        if ((not savageRoar or savageRoar[6] - GetTime() < 7) and timeUntilDeath > 7) then
            IOService.SendIfUsable("Savage Roar", true)
            return true
        end

        local rip = IOService.GetPlayerEffect(playerData, "Rip", true)
        if ((not rip or rip[6] < 1.5) and timeUntilDeath > 8) then
            usable, _ = IOService.SendIfUsable("Rip", true)
            if (usable) then
                return true
            end
        end

        usable, _ = IOService.SendIfUsable("Ferocious Bite", true)
        if (usable) then
            return true
        end
    end

    if (playerData.power < 20) then
        usable, _ = IOService.SendIfUsable("Tiger's Fury", true)
        if (usable) then
            return true
        end
    end

    if (IOService.GetPlayerEffect(playerData, "Tiger's Fury", true)) then
        usable, _ = IOService.SendIfUsable("Berserk", true)
        if (usable) then
            return true
        end

        usable = IOService.SendIfItemUsable("Ritualist's Hammer", DruidRotationFeral.ritualistId)
        if (usable) then
            return true
        end
    end

    usable, _ = IOService.SendIfDebuffNeeded(playerData, "Rake", true, 3, false)
    if (usable) then
        return true
    end
end

return DruidRotationFeral
