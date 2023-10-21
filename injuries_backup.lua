function loadInjuries()
    print(LocalPlayer.state.injuries)
    for k, v in pairs(LocalPlayer.state.injuries) do
        print(k, v)
    end
end

function treatInjury(bone)
    if not player.injuries[bone] then return end -- secure check

    local playerPed = cache.ped or PlayerPedId()

    local currentHealth = GetEntityHealth(playerPed)
    local healthToAdd = player.injuries[bone].value / 2
    local newHealth = math.min(currentHealth + healthToAdd, 100)

    player.bleedingLvl -= player.injuries[bone].value  / 10

    player.injuries[bone] = nil
    LocalPlayer.state:set("injuries", player.injuries, true)

    if player.bleedingLvl <= 5 then
        toggleLimpWalk(false)
    end

    SetEntityHealth(playerPed, newHealth)
end

function toggleLimpWalk(toggle)
    local playerPed = cache.ped or PlayerPedId()
    if toggle then
        player.limping = true
        lib.requestAnimSet(Config.LimpAnim)

        SetPedMovementClipset(playerPed, Config.LimpAnim, true)
    else
        player.limping = false
        ResetPedMovementClipset(playerPed)
        ResetPedWeaponMovementClipset(playerPed)
        ResetPedStrafeClipset(playerPed)
    end
end

function initBleeding()
    if not player.bleedingTime then
        player.bleedingTime = 1
    end

    while player.bleeding do
        if player.bleedingLvl > 0 then
            if player.bleedingLvl ~= player.currBleedingLvl then
                player.currBleedingLvl = player.bleedingLvl
                -- utils.showNotification(locale("your_bleeding_lvl") .. player.bleedingLvl)
            end
        end

        player.lastBleedTime = player.bleedingTime
        player.bleedingTime += 1

        if player.bleedingTime - player.lastBleedTime >= 5 then
            print("s")
            player.bleedingLvl += 1
            player.lastBleedTime = player.bleedingTime
        end

        -- utils.showNotification(locale("your_losing_blood"))
        if player.bleedingLvl >= 50 then
            if not player.limping then
                toggleLimpWalk(true)
            end
        end

        Wait(1000)
    end
end

function updateInjuries(victim, weapon)
    local found, lastDamaagedBone = GetPedLastDamageBone(victim)

    utils.debug("Damaged bone ", lastDamaagedBone)

    local damagedBone = Config.BodyParts[tostring(lastDamaagedBone)]

    utils.debug(damagedBone.label)

    if damagedBone then
        if not player.injuries[damagedBone.id] then
            player.injuries[damagedBone.id] = { bone = damagedBone.id, label = damagedBone.label, desc = damagedBone.levels["default"], value = 10 }
        else
            local newVal = math.min(player.injuries[damagedBone.id].value + 10, 100)
            player.injuries[damagedBone.id].value = newVal
            player.injuries[damagedBone.id].desc = damagedBone.levels[tostring(newVal)] or damagedBone.levels["default"]
        end

        LocalPlayer.state:set("injuries", player.injuries, true)

        if Config.BleedingWeapons[weapon] then
            player.currBleedingLvl = player.bleedingLvl or 0
            player.bleedingLvl = (player.bleedingLvl or 0) += 1

            if not player.bleeding then
                player.bleeding = true
                initBleeding()
            end
        end
    end
end

-- AddStateBagChangeHandler('injuries', ('player:%s'):format(cache.serverId), function(_, _, injuries)
--     local limp

--     if player.injuries["lleg"] or player.injuries["rleg"] then
--         local lleg = player.injuries["lleg"]
--         local rleg = player.injuries["rleg"]

--         limp = lleg and lleg.value >= Config.StartLimp or rleg and rleg.value >= Config.StartLimp

--         if limp and not player.limping then
--             toggleLimpWalk(true)
--         end
--     end

--     if not limp and player.limping then
--         toggleLimpWalk(false)
--     end
-- end)
