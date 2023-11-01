function takeStretcher()
    local stretcherModel = lib.requestModel("prop_ld_binbag_01")

    local playerPed = cache.ped or PlayerPedId()
    local playerCoords = cache.coords or GetEntityCoords(playerPed)
    local stretcher = CreateObject(stretcherModel, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
    AttachEntityToEntity(stretcher, playerPed, GetPedBoneIndex(playerPed, 28422), -0.1681134, -1.0495786, -0.426176, 12.740244, 4.5091583, -8.204815, true, true, false, true, 1, true)

    while IsEntityAttachedToEntity(stretcher, playerPed) do
        Wait(0)
        if not IsEntityPlayingAnim(playerPed, 'anim@heists@box_carry@', 'idle', 3) then
            TaskPlayAnim(playerPed, 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
        end
        if IsControlJustPressed(0, 38) then
            DetachEntity(stretcher, true, true)
            ClearPedTasks(playerPed)
            SetEntityCoords(stretcher, GetEntityCoords(stretcher) + vector3(0.0, 0.0, -0.1))
            exports.ox_target:addLocalEntity(stretcher, {
                {
                    name = 'paramedicGuyAmbulanceJob' .. ped,
                    label = locale('paramedic_interact_label'),
                    icon = 'fa-solid fa-ambulance',
                    distance = 3,
                    onSelect = function(data)
                        print("dsa")
                    end,
                }
            })
        end
    end
end

local function isEmsVehicle(vehicle)
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)

    for index, model in pairs(Config.EmsVehicles) do
        if joaat(model) == vehicleModel or GetVehicleClassFromName(model) == vehicleClass then return true end
    end

    return false
end

local function vehicleInteractions()
    local options = {
        {
            name = 'ars_ambulancejob_stretcher',
            icon = 'fa-solid fa-car-side',
            label = locale('take_stretcher'),
            groups = Config.EmsJobs,
            canInteract = function(entity, distance, coords, name)
                return isEmsVehicle(entity)
            end,
            onSelect = function(data)
                takeStretcher()
            end
        }
    }

    exports.ox_target:addGlobalVehicle(options)
end

vehicleInteractions()

-- © 𝐴𝑟𝑖𝑢𝑠 𝐷𝑒𝑣𝑒𝑙𝑜𝑝𝑚𝑒𝑛𝑡
