function treatInjury(bone)
    if not player.injuries[bone] then return end -- secure check

    local playerPed = cache.ped or PlayerPedId()

    local currentHealth = GetEntityHealth(playerPed)
    local healthToAdd = player.injuries[bone].value / 2
    local newHealth = math.min(currentHealth + healthToAdd, 100)

    player.bleedingLvl -= player.injuries[bone].value / 10

    player.injuries[bone] = nil
    LocalPlayer.state:set("injuries", player.injuries, true)

    if player.bleedingLvl <= 5 then
        toggleLimpWalk(false)
    end

    SetEntityHealth(playerPed, newHealth)
end

function updateInjuries(victim, weapon)
    local found, lastDamaagedBone = GetPedLastDamageBone(victim)

    local damagedBone = Config.BodyParts[tostring(lastDamaagedBone)]

    utils.debug("Damaged bone ", lastDamaagedBone, damagedBone.label)

    if damagedBone then
        if not player.injuries[damagedBone.id] then
            player.injuries[damagedBone.id] = { bone = damagedBone.id, label = damagedBone.label, desc = damagedBone.levels["default"], value = 10, cause = WEAPONS[weapon][2] }
        else
            local newVal = math.min(player.injuries[damagedBone.id].value + 10, 100)
            player.injuries[damagedBone.id].value = newVal
            player.injuries[damagedBone.id].desc = damagedBone.levels[tostring(newVal)] or damagedBone.levels["default"]
        end

        LocalPlayer.state:set("injuries", player.injuries, true)
    end
end
