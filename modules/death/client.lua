local NetworkResurrectLocalPlayer  = NetworkResurrectLocalPlayer
local ShakeGameplayCam             = ShakeGameplayCam
local AnimpostfxPlay               = AnimpostfxPlay
local CreateThread                 = CreateThread
local Wait                         = Wait
local SetEntityCoords              = SetEntityCoords
local TaskPlayAnim                 = TaskPlayAnim
local FreezeEntityPosition         = FreezeEntityPosition
local ClearPedTasks                = ClearPedTasks
local SetEntityHealth              = SetEntityHealth
local SetEntityInvincible          = SetEntityInvincible
local SetEveryoneIgnorePlayer      = SetEveryoneIgnorePlayer
local GetGameTimer                 = GetGameTimer
local IsControlJustPressed         = IsControlJustPressed
local TriggerServerEvent           = TriggerServerEvent
local AddEventHandler              = AddEventHandler
local SetEntityHeading             = SetEntityHeading
local PlayerPedId                  = PlayerPedId
local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
local IsPedAPlayer                 = IsPedAPlayer
local IsPedDeadOrDying             = IsPedDeadOrDying
local IsPedFatallyInjured          = IsPedFatallyInjured

local animations                   = lib.load("config").animations
function stopPlayerDeath()
    player.isDead = false
    -- player.injuries = {}

    local playerPed = cache.ped or PlayerPedId()

    utils.doScreenFadeOut(800, true)


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

    utils.doScreenFadeIn(700)
    TaskPlayAnim(playerPed, animations["get_up"].dict, animations["get_up"].clip, 8.0, -8.0, -1, 0, 0, 0, 0, 0)

    -- LocalPlayer.state:set("injuries", {}, true)
    LocalPlayer.state:set("dead", false, true)
    player.distressCallTime = nil

    Framework.playerSpawned()
    healPlayer()
end

function healPlayer()
    local playerPed = cache.ped or PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)

    SetEntityHealth(playerPed, maxHealth)
    Framework.healStatus()
end

RegisterNetEvent("ars_ambulancejob:healPlayer", function(data)
    if data.revive then
        stopPlayerDeath()
    elseif data.injury then
        treatInjury(data.bone)
    elseif data.heal then
        healPlayer()
    end
end)

local removeItemsOnRespawn = lib.load("config").removeItemsOnRespawn
local function respawnPlayer()
    local playerPed = cache.ped or PlayerPedId()

    if removeItemsOnRespawn then
        TriggerServerEvent("ars_ambulancejob:removeInventory")
    end

    lib.requestAnimDict("anim@gangops@morgue@table@")
    lib.requestAnimDict("switch@franklin@bed")

    local hospital = utils.getClosestHospital()
    local bed = nil

    utils.doScreenFadeOut(800, true)

    for i = 1, #hospital.respawn do
        local _bed = hospital.respawn[i]
        local isBedOccupied = utils.isBedOccupied(_bed.bedPoint)
        if not isBedOccupied then
            bed = _bed
            break
        end
    end

    if not bed then bed = hospital.respawn[1] end

    player.respawning = true

    SetEntityCoords(playerPed, bed.bedPoint)
    SetEntityHeading(playerPed, bed.bedPoint.w)
    TaskPlayAnim(playerPed, "anim@gangops@morgue@table@", "body_search", 2.0, 2.0, -1, 1, 0, false, false, false)
    FreezeEntityPosition(playerPed, true)


    utils.doScreenFadeIn(300)
    Wait(5000)
    SetEntityCoords(playerPed, vector3(bed.bedPoint.x, bed.bedPoint.y, bed.bedPoint.z) + vector3(0.0, 0.0, -1.0))
    FreezeEntityPosition(playerPed, false)
    SetEntityHeading(cache.ped, bed.bedPoint.w + 90.0)
    TaskPlayAnim(playerPed, "switch@franklin@bed", "sleep_getup_rubeyes", 1.0, 1.0, -1, 8, -1, 0, 0, 0)

    Wait(5000)

    stopPlayerDeath()
    ClearPedTasks(playerPed)
    SetEntityCoords(playerPed, bed.spawnPoint)
    player.respawning = false
end

local useExtraEffects = lib.load("config").extraEffects
local respawnTime = lib.load("config").respawnTime
local function initPlayerDeath(logged_dead)
    if player.isDead then return end

    player.isDead = true
    startCommandTimer()

    for _, anim in pairs(animations) do
        lib.requestAnimDict(anim.dict)
    end

    if logged_dead then goto logged_dead end

    if useExtraEffects then
        ShakeGameplayCam('DEATH_FAIL_IN_EFFECT_SHAKE', 1.0)
        AnimpostfxPlay('DeathFailOut', 0, true)

        Wait(4000)

        utils.doScreenFadeOut(200, true)
        Wait(800)
        utils.doScreenFadeIn(400)
    end
    if not player.isDead then return end

    ::logged_dead::
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

    local time = 60000 * respawnTime
    local deathTime = GetGameTimer()

    CreateThread(function()
        while player.isDead do
            local sleep = 500

            if not player.gettingRevived and not player.respawning then
                sleep = 0
                local anim = cache.vehicle and animations["death_car"] or animations["death_normal"]

                if not IsEntityPlayingAnim(playerPed, anim.dict, anim.clip, 3) then
                    TaskPlayAnim(playerPed, anim.dict, anim.clip, 50.0, 8.0, -1, 1, 1.0, false, false, false)
                end

                local elapsedSeconds = math.floor((GetGameTimer() - deathTime) / 1000)

                utils.drawTextFrame({
                    x = 0.5,
                    y = 0.9,
                    msg = locale("death_screen_call_medic")
                })

                if IsControlJustPressed(0, 38) then
                    createDistressCall()
                end

                if GetGameTimer() - deathTime >= time then
                    EnableControlAction(0, 47, true)

                    utils.drawTextFrame({
                        x = 0.5,
                        y = 0.86,
                        msg = locale("death_screen_respawn")
                    })

                    if IsControlJustPressed(0, 47) then
                        local confirmation = lib.alertDialog({
                            header = locale("death_screen_confirm_respawn_header"),
                            content = locale("death_screen_confirm_respawn_content"),
                            centered = true,
                            cancel = true
                        })

                        if confirmation == "confirm" then
                            respawnPlayer()
                        end
                    end
                else
                    utils.drawTextFrame({
                        x = 0.5,
                        y = 0.86,
                        msg = (locale("death_screen_respawn_timer")):format(math.floor((time / 1000) - elapsedSeconds))
                    })
                end
            end

            Wait(sleep)
        end
    end)
end

function onPlayerLoaded()
    exports.spawnmanager:setAutoSpawn(false) -- for qbcore

    local data = lib.callback.await('ars_ambulancejob:getDeathStatus', false)

    if data?.isDead then
        initPlayerDeath(true)
        utils.showNotification("logged_dead")
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


exports("isDead", function()
    return player.isDead
end)
