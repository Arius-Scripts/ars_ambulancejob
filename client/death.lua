function stopPlayerDeath()
    player.isDead = false
    player.injuries = {}

    local playerPed = cache.ped or PlayerPedId()

    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
        Wait(50)
    end

    local coords = cache.coords or GetEntityCoords(playerPed)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.w, false, false)

    local deathStatus = { isDead = false }
    TriggerServerEvent('ars_ambulancejob:updateDeathStatus', deathStatus)

    playerPed = PlayerPedId()

    if cache.vehicle then
        SetPedIntoVehicle(cache.ped, cache.vehicle, cache.seat)
    end

    ClearPedBloodDamage(playerPed)
    SetEntityInvincible(playerPed, false)
    SetEveryoneIgnorePlayer(cache.playerId, false)
    ClearPedTasks(playerPed)
    AnimpostfxStopAll()

    DoScreenFadeIn(700)
    TaskPlayAnim(playerPed, Config.DeathAnimations["revive"].dict, Config.DeathAnimations["revive"].clip, 8.0, -8.0, -1, 0, 0, 0, 0, 0)

    -- LocalPlayer.state:set("injuries", {}, true)
    LocalPlayer.state:set("dead", false, true)
    player.distressCallTime = nil
end

RegisterNetEvent("ars_ambulancejob:healPlayer", function(data)
    if data.revive then
        stopPlayerDeath()
    elseif data.injury then
        treatInjury(data.bone)
    end
end)


local function respawnPlayer()
    lib.requestAnimDict("anim@gangops@morgue@table@")

    local playerPed = cache.ped or PlayerPedId()
    local hospital = utils.getClosestHospital()

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(1) end

    SetEntityCoords(cache.ped, hospital.respawn.bedPoint)
    SetEntityHeading(cache.ped, hospital.respawn.bedPoint.w)
    TaskPlayAnim(playerPed, "anim@gangops@morgue@table@", "body_search", 2.0, 2.0, -1, 1, 0, false, false, false)
    FreezeEntityPosition(playerPed, true)

    Wait(1000)
    DoScreenFadeIn(300)

    Wait(5000)

    stopPlayerDeath()
    ClearPedTasks(playerPed)
    FreezeEntityPosition(playerPed, false)
    SetEntityCoords(cache.ped, hospital.respawn.spawnPoint)
end

local function initPlayerDeath()
    if player.isDead then return end

    player.isDead = true

    for _, anim in pairs(Config.DeathAnimations) do
        lib.requestAnimDict(anim.dict)
    end

    ShakeGameplayCam('DEATH_FAIL_IN_EFFECT_SHAKE', 1.0)
    AnimpostfxPlay('DeathFailOut', 0, true)

    Wait(4000)

    DoScreenFadeOut(200)
    Wait(800)
    DoScreenFadeIn(400)

    local playerPed = cache.ped or PlayerPedId()

    CreateThread(function()
        while player.isDead do
            DisableFirstPersonCamThisFrame()
            Wait(0)
        end
    end)

    local coords = cache.coords or GetEntityCoords(playerPed)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(playerPed), false, false)
    playerPed = PlayerPedId()

    if cache.vehicle then
        SetPedIntoVehicle(cache.ped, cache.vehicle, cache.seat)
    end

    SetEntityInvincible(cache.ped, true)
    SetEntityHealth(cache.ped, 100)
    SetEveryoneIgnorePlayer(cache.playerId, true)

    local time = 60000 * Config.RespawnTime
    local deathTime = GetGameTimer()

    CreateThread(function()
        while player.isDead do
            local sleep = 1500

            if not player.gettingRevived then
                sleep = 0
                local anim = cache.vehicle and Config.DeathAnimations["car"] or Config.DeathAnimations["normal"]

                if not IsEntityPlayingAnim(playerPed, anim.dict, anim.clip, 3) then
                    TaskPlayAnim(playerPed, anim.dict, anim.clip, 50.0, 8.0, -1, 1, 1.0, false, false, false)
                end

                local elapsedSeconds = math.floor((GetGameTimer() - deathTime) / 1000)

                utils.drawTextFrame({
                    x = 0.5,
                    y = 0.9,
                    msg = "Press ~r~E~s~ to call medics"
                })

                if IsControlJustPressed(0, 38) then
                    createDistressCall()
                end

                if GetGameTimer() - deathTime >= time then
                    EnableControlAction(0, 47, true)

                    utils.drawTextFrame({
                        x = 0.5,
                        y = 0.86,
                        msg = "Press ~r~G~s~ to respawn"
                    })

                    if IsControlJustPressed(0, 47) then
                        local confermation = lib.alertDialog({
                            header = 'Top G',
                            content = 'Are you sure you want to respawn!',
                            centered = true,
                            cancel = true
                        })

                        if confermation == "confirm" then
                            respawnPlayer()
                        end
                    end
                else
                    utils.drawTextFrame({
                        x = 0.5,
                        y = 0.86,
                        msg = ("Respawn available in ~b~ %s seconds~s~"):format(math.floor((time / 1000) - elapsedSeconds))
                    })
                end
            end

            Wait(sleep)
        end
    end)
end

function onPlayerLoaded()
    local data = lib.callback.await('ars_ambulancejob:getDeathStatus', false)
    player.isDead = data.isDead and data.isDead or false

    if player.isDead then
        initPlayerDeath()
    end
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end

    local victim, victimDied, weapon = data[1], data[4], data[7]
    utils.debug(weapon)


    if not IsPedAPlayer(victim) then return end

    local playerPed = cache.playerId or PlayerId()

    if NetworkGetPlayerIndexFromPed(victim) ~= playerPed then return end

    local victimDiedAndPlayer = victimDied and NetworkGetPlayerIndexFromPed(victim) == playerPed and (IsPedDeadOrDying(victim, true) or IsPedFatallyInjured(victim))

    if victimDiedAndPlayer then
        local deathData = {}

        deathData.isDead = true
        deathData.weapon = weapon

        TriggerServerEvent('ars_ambulancejob:updateDeathStatus', deathData)
        LocalPlayer.state:set("dead", true, true)
        initPlayerDeath()
    end

    updateInjuries(victim, weapon)

    utils.debug(LocalPlayer.state.injuries)
end)
