local GetEntityCoords         = GetEntityCoords
local GetEntityMaxHealth      = GetEntityMaxHealth
local SetEntityCoords         = SetEntityCoords
local SetEntityHeading        = SetEntityHeading
local SetEntityHealth         = SetEntityHealth
local TaskPlayAnim            = TaskPlayAnim
local Wait                    = Wait

local paramedicTreatmentPrice = lib.load("config").paramedicTreatmentPrice
local shouldRevive            = lib.load("config").shouldRevive

local function openParamedicMenu(ped, hospital)
    lib.registerContext({
        id = 'ars_ambulancejob:paramedic_menu',
        title = locale("paramedic_menu_title"),
        options = {
            {
                title = locale("get_treated_paramedic"),
                onSelect = function()
                    local hasMoney = Framework.hasItem("money", paramedicTreatmentPrice)
                    if not hasMoney then return utils.showNotification(locale("not_enough_money")) end


                    utils.addRemoveItem("remove", "money", paramedicTreatmentPrice)

                    local dict = lib.requestAnimDict("anim@gangops@morgue@table@")
                    local playerPed = cache.ped or PlayerPedId()
                    local previousCoords = cache.coords or GetEntityCoords(playerPed)
                    local bed = nil

                    utils.doScreenFadeOut(500, true)
                    Wait(1000)
                    utils.doScreenFadeIn(300)

                    for i = 1, #hospital.respawn do
                        local _bed = hospital.respawn[i]
                        local isBedOccupied = utils.isBedOccupied(_bed.bedPoint)
                        if not isBedOccupied then
                            bed = _bed
                            break
                        end
                    end

                    if not bed then bed = hospital.respawn[1] end

                    SetEntityCoords(playerPed, bed.bedPoint)
                    SetEntityHeading(playerPed, bed.bedPoint.w)
                    TaskPlayAnim(playerPed, dict, "body_search", 2.0, 2.0, -1, 1, 0, false, false, false)

                    SetEntityCoords(ped, bed.spawnPoint)
                    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", -1, true)

                    lib.progressBar({ duration = 15000, label = locale("getting_treated"), useWhileDead = false, canCancel = true, disable = { car = true, move = true }, })



                    SetEntityCoords(ped, hospital.paramedic.pos.xyz)
                    SetEntityHeading(ped, hospital.paramedic.pos.w)
                    if shouldRevive then
                        stopPlayerDeath()
                    else
                        utils.doScreenFadeOut(500, true)
                        Wait(1000)
                        utils.doScreenFadeIn(300)
                        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
                        player.injuries = {}
                    end


                    SetEntityCoords(playerPed, previousCoords)
                    utils.showNotification(locale("treated_by_paramedic"))
                    ClearPedTasks(ped)
                    ClearAreaOfObjects(hospital.paramedic.pos.xyz, 2.0, 0)
                end,
            }
        }
    })
    lib.showContext('ars_ambulancejob:paramedic_menu')
end

local function createAmbulance()
    local vehicleModel = "ambulance"
    lib.requestModel(vehicleModel)

    local playerPed = cache.ped or PlayerPedId()
    local playerCoords = cache.coords or GetEntityCoords(playerPed)

    local _, vector = GetNthClosestVehicleNode(playerCoords.x, playerCoords.y, playerCoords.z, math.random(50, 70), 0, 0, 0)
    local sX, sY, sZ = table.unpack(vector)

    ambulance = CreateVehicle(vehicleModel, sX, sY, sZ, 0, false, true)


    SetEntityAsMissionEntity(ambulance, true, true)
    SetVehicleEngineOn(ambulance, true, true, false)

    SetModelAsNoLongerNeeded(ambulance)

    SetVehicleSiren(ambulance, true)

    return ambulance
end

local function createAmbulanceDriver(vehicle)
    local pedModel = "s_m_m_paramedic_01"
    lib.requestModel(pedModel)

    local ped = CreatePedInsideVehicle(vehicle, 26, pedModel, -1, false, true)
    SetAmbientVoiceName(ped, "A_M_M_EASTSA_02_LATINO_FULL_01")
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityAsMissionEntity(ped, true, true)

    SetModelAsNoLongerNeeded(pedModel)
    return ped
end

local hospitals = lib.load("data.hospitals")
local allowAlwaysTreatment = lib.load("config").allowAlways

function initParamedic()
    for index, hospital in pairs(hospitals) do
        local ped = utils.createPed(hospital.paramedic.model, hospital.paramedic.pos)

        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        Target.addLocalEntity(ped, {
            {
                label = locale('paramedic_interact_label'),
                icon = 'fa-solid fa-ambulance',
                groups = false,
                fn = function()
                    if not allowAlwaysTreatment then
                        local medicsOnline = lib.callback.await('ars_ambulancejob:getMedicsOniline', false)
                        if medicsOnline <= 0 then
                            openParamedicMenu(ped, hospital)
                        else
                            utils.showNotification(locale("medics_online"))
                        end
                    else
                        openParamedicMenu(ped, hospital)
                    end
                end
            }
        })
    end
end

local function offlineRevive()
    if not player.isDead then return end
    local medicsOnline = lib.callback.await('ars_ambulancejob:getMedicsOniline', false)
    if medicsOnline > 0 then return utils.showNotification(locale("medics_online")) end
    if player.timePassedForCommand > 0 then return utils.showNotification(locale("wait_time"):format(player.timePassedForCommand)) end

    utils.showNotification(locale("medic_coming"))

    local tpToPed = false
    local dict = lib.requestAnimDict("mini@cpr@char_a@cpr_str")
    local playerPed = cache.ped or PlayerPedId()
    local playerCoords = cache.coords or GetEntityCoords(playerPed)
    local startTime = GetGameTimer()

    local ambulance = createAmbulance()
    local ambulanceDriver = createAmbulanceDriver(ambulance)
    while not DoesEntityExist(ambulanceDriver) do Wait(1) end

    TaskVehicleDriveToCoord(ambulanceDriver, ambulance, playerCoords.x, playerCoords.y, playerCoords.z, 40.0, 0, GetEntityModel(ambulance), 2146958335, 10.0)
    SetPedKeepTask(ambulanceDriver, true)

    while true do
        local driverCoords = GetEntityCoords(ambulanceDriver)
        playerCoords = GetEntityCoords(playerPed)
        local dist = #(driverCoords - playerCoords)


        utils.debug(GetGameTimer() - startTime)
        if (GetGameTimer() - startTime) > 35000 then
            break
        end

        utils.debug(dist)

        if dist < 30 then
            break
        end
        Wait(1)
    end

    TaskLeaveVehicle(ambulanceDriver, ambulance, 64)
    TaskGoToCoordAnyMeans(ambulanceDriver, playerCoords.x, playerCoords.y, playerCoords.z, 10.0, 0, 0, 786603)

    startTime = GetGameTimer()

    while true do
        local driverCoords = GetEntityCoords(ambulanceDriver)
        playerCoords = GetEntityCoords(playerPed)
        local dist = #(driverCoords - playerCoords)

        utils.debug(dist)
        utils.debug(GetGameTimer() - startTime)

        if (GetGameTimer() - startTime) > 5000 then
            tpToPed = true
            break
        end

        if dist < 2 then
            break
        end
        Wait(1)
    end
    if tpToPed then
        SetEntityCoords(ambulanceDriver, cache.coords)
        TaskGoToCoordAnyMeans(ambulanceDriver, playerCoords.x, playerCoords.y, playerCoords.z, 10.0, 0, 0, 786603)
        Wait(1000)
    end

    Wait(1000)

    TaskPlayAnim(ambulanceDriver, dict, "cpr_pumpchest", 1.0, 1.0, -1, 9, 1.0, false, false, false)

    Wait(1000 * 15)

    stopPlayerDeath()
    DeleteEntity(ambulance)
    DeleteEntity(ambulanceDriver)
end

local timeToWaitForCommand = lib.load("config").timeToWaitForCommand * 60000
function startCommandTimer()
    CreateThread(function()
        local deathTime = GetGameTimer()

        while player.isDead do
            local currentTime = GetGameTimer()
            local timePassed = currentTime - deathTime
            player.timePassedForCommand = math.ceil((timeToWaitForCommand - timePassed) / 1000)
            utils.debug(player.timePassedForCommand)

            Wait(1000)
        end
    end)
end

local npcReviveCommand = lib.load("config").npcReviveCommand
RegisterCommand(npcReviveCommand, offlineRevive)
