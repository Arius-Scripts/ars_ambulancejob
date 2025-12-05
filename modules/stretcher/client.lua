local AttachEntityToEntity            = AttachEntityToEntity
local ClearPedTasks                   = ClearPedTasks
local CreateObject                    = CreateObject
local CreateThread                    = CreateThread
local DetachEntity                    = DetachEntity
local Entity                          = Entity
local FreezeEntityPosition            = FreezeEntityPosition
local GetClosestObjectOfType          = GetClosestObjectOfType
local GetEntityAttachedTo             = GetEntityAttachedTo
local GetEntityModel                  = GetEntityModel
local GetEntityCoords                 = GetEntityCoords
local GetPlayerServerId               = GetPlayerServerId
local GetVehicleClassFromName         = GetVehicleClassFromName
local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
local IsControlJustPressed            = IsControlJustPressed
local IsEntityAttachedToEntity        = IsEntityAttachedToEntity
local IsEntityPlayingAnim             = IsEntityPlayingAnim
local IsVehicleSeatFree               = IsVehicleSeatFree
local NetworkGetEntityFromNetworkId   = NetworkGetEntityFromNetworkId
local NetworkGetPlayerIndexFromPed    = NetworkGetPlayerIndexFromPed
local PlayerPedId                     = PlayerPedId
local SetEntityAsMissionEntity        = SetEntityAsMissionEntity
local TaskPlayAnim                    = TaskPlayAnim
local TaskWarpPedIntoVehicle          = TaskWarpPedIntoVehicle
local Wait                            = Wait


local usingStretcher = false
local currentStretcher = nil
local patientOnStretcher = nil
local emsJobs = lib.load("config").emsJobs
local emsVehicles = lib.load("config").emsVehicles

local function isEmsVehicle(vehicle)
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)

    for model, value in pairs(emsVehicles) do
        if value then
            if joaat(model) == vehicleModel or GetVehicleClassFromName(model) == vehicleClass then return true end
        end
    end

    return false
end

local function useStretcher(stretcher)
    usingStretcher = true
    currentStretcher = stretcher

    local playerPed = cache.ped or PlayerPedId()
    local dict = lib.requestAnimDict("anim@heists@box_carry@")

    AttachEntityToEntity(stretcher, playerPed, GetPedBoneIndex(playerPed, 28422), -0.1681134, -1.0495786, -0.516176, 12.740244, 4.5091583, -8.204815, true, true, false, true, 1, true)
    SetEntityAsMissionEntity(stretcher)


    lib.showTextUI(locale("control_drop_stretcher"), {
        position = "top-center",
        icon = 'bed',
        style = {
            borderRadius = '8px',
            backgroundColor = '#48BB78',
            color = 'white',
            padding = '10px',
            boxShadow = '0 2px 4px rgba(0, 0, 0, 0.2)'
        }
    })

    CreateThread(function()
        while IsEntityAttachedToEntity(stretcher, playerPed) do
            if IsControlJustPressed(0, 47) then
                DetachEntity(stretcher, true, true)
                ClearPedTasks(playerPed)
                PlaceObjectOnGroundProperly(stretcher)
                FreezeEntityPosition(stretcher, true)
                usingStretcher = false
                lib.hideTextUI()
            end
            Wait(1)
        end
    end)

    while IsEntityAttachedToEntity(stretcher, playerPed) do
        if not IsEntityPlayingAnim(playerPed, dict, 'idle', 3) then
            TaskPlayAnim(playerPed, dict, 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
        end

        Wait(1000)
    end
end

function toggleStretcher(toggle)
    local playerPed = cache.ped or PlayerPedId()
    local playerCoords = cache.coords or GetEntityCoords(playerPed)
    if toggle then
        local stretcherModel = lib.requestModel("prop_ld_binbag_01")

        local stretcher = CreateObject(stretcherModel, playerCoords.x, playerCoords.y, playerCoords.z, true, false, false)
        currentStretcher = stretcher

        useStretcher(stretcher)
    else
        ClearPedTasks(playerPed)
        DeleteEntity(currentStretcher)

        usingStretcher = false
        lib.hideTextUI()
    end
end

function putOnStretcher(toggle, target)
    local data = {}
    data.toggle = toggle
    data.target = GetPlayerServerId(NetworkGetPlayerIndexFromPed(target))
    TriggerServerEvent("ars_ambulancejob:putOnStretcher", data)
    patientOnStretcher = toggle and target or nil
end

RegisterNetEvent("ars_ambulancejob:togglePatientFromVehicle", function(veh)
    local playerPed = cache.ped or PlayerPedId()
    local vehicle = NetworkGetEntityFromNetworkId(veh)
    local currentVehicle = cache.vehicle
    local seatToGo = nil

    DetachEntity(playerPed)

    utils.debug(currentVehicle)

    if not currentVehicle then
        local seats = GetVehicleMaxNumberOfPassengers(vehicle)
        for i = 0, seats - 1 do
            if IsVehicleSeatFree(vehicle, i) then
                seatToGo = i
                break
            end
        end

        if seatToGo then
            TaskWarpPedIntoVehicle(playerPed, vehicle, seatToGo)
        end
    else
        TaskLeaveVehicle(playerPed, currentVehicle, 16)
    end
end)

RegisterNetEvent("ars_ambulancejob:putOnStretcher", function(toggle)
    local playerPed = cache.ped or PlayerPedId()
    local playerCoords = cache.coords or GetEntityCoords(playerPed)

    if toggle then
        local closestStretcher = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 5.5, `prop_ld_binbag_01`, false)
        AttachEntityToEntity(playerPed, closestStretcher, 0, 0, 0.0, 1.0, 195.0, 0.0, 180.0, 0.0, false, false, false, false, 2)
    else
        DetachEntity(playerPed)
        ClearPedTasks(playerPed)
    end
end)
local ambulanceStretchers = lib.load("config").ambulanceStretchers

local function vehicleInteractions()
    local options = {
        {
            name = 'ars_ambulancejob_take_stretcher',
            icon = 'fa-solid fa-car-side',
            label = locale('take_stretcher'),
            groups = emsJobs,
            cn = function(entity, distance, coords, name)
                return isEmsVehicle(entity) and not usingStretcher and not player.isDead
            end,
            fn = function(data)
                local vehicle = type(data) == "number" and data or data.entity
                if not Entity(vehicle).state.stretcher then Entity(vehicle).state.stretcher = ambulanceStretchers end
                if Entity(vehicle).state.stretcher < 1 then return utils.showNotification(locale("no_stretcher_found")) end

                toggleStretcher(true)

                Entity(vehicle).state.stretcher -= 1
            end
        },
        {
            name = 'ars_ambulancejob_put_stretcher',
            icon = 'fa-solid fa-car-side',
            label = locale('put_stretcher'),
            groups = emsJobs,
            cn = function(entity, distance, coords, name)
                return isEmsVehicle(entity) and usingStretcher and not patientOnStretcher and not player.isDead
            end,
            fn = function(data)
                local vehicle = type(data) == "number" and data or data.entity
                if Entity(vehicle).state.stretcher >= ambulanceStretchers then return utils.showNotification(locale("stretcher_limit_reached")) end

                Entity(vehicle).state.stretcher += 1

                toggleStretcher(false)
            end
        },
        {
            name = 'ars_ambulancejob_put_patient_in_vehicle',
            icon = 'fa-solid fa-car-side',
            label = locale('put_patient_in_vehicle'),
            groups = emsJobs,
            cn = function(entity, distance, coords, name)
                return isEmsVehicle(entity) and usingStretcher and patientOnStretcher and not player.isDead
            end,
            fn = function(data)
                local dataToSend = {}
                dataToSend.vehicle = NetworkGetNetworkIdFromEntity(data.entity)
                dataToSend.target = GetPlayerServerId(NetworkGetPlayerIndexFromPed(patientOnStretcher))
                TriggerServerEvent('ars_ambulancejob:togglePatientFromVehicle', dataToSend)

                Entity(data.entity).state.patient = patientOnStretcher
                patientOnStretcher = nil
            end
        },
        {
            name = 'ars_ambulancejob_take_patient_from_vehicle',
            icon = 'fa-solid fa-car-side',
            label = locale('take_patient_from_vehicle'),
            groups = emsJobs,
            cn = function(entity, distance, coords, name)
                return isEmsVehicle(entity) and Entity(entity).state?.patient and not player.isDead
            end,
            fn = function(data)
                local dataToSend = {}
                dataToSend.target = GetPlayerServerId(NetworkGetPlayerIndexFromPed(Entity(data.entity).state?.patient))
                TriggerServerEvent('ars_ambulancejob:togglePatientFromVehicle', dataToSend)

                Wait(150)
                putOnStretcher(true, Entity(data.entity).state?.patient)

                Entity(data.entity).state.patient = nil
            end
        },

    }

    Target.addGlobalVehicle(options)
end

local function stretcherInteraction()
    Target.addModel({ `prop_ld_binbag_01` }, {
        {
            name = 'ars_ambulancejob_stretcher_model',
            label = locale('take_stretcher'),
            icon = 'fa-solid fa-bed',
            groups = emsJobs,
            distance = 3,
            cn = function()
                return not usingStretcher and not player.isDead
            end,
            fn = function(data)
                useStretcher(type(data) == "number" and data or data.entity)
            end,
        },
        {
            name = 'ars_ambulancejob_remove_from_stretcher',
            icon = 'fa-solid fa-car-side',
            label = locale('remove_from_stretcher'),
            groups = emsJobs,
            cn = function(entity, distance, coords, name)
                local playerId, playerPed, playerCoords = lib.getClosestPlayer(GetEntityCoords(entity), 2.0, false)
                return GetEntityAttachedTo(playerPed) == entity and not player.isDead
            end,
            fn = function(data)
                local playerId, playerPed, playerCoords = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.0, false)
                if GetEntityAttachedTo(playerPed) == data.entity then
                    putOnStretcher(false, playerPed)
                end
            end
        },
    })
end

vehicleInteractions()
stretcherInteraction()
