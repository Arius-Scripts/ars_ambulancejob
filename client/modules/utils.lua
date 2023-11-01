utils = {}
peds = {}

function utils.showNotification(msg, type)
    lib.notify({
        title = 'Ars Ambulancejob',
        description = msg,
        type = type and type or 'info'
    })
end

function utils.debug(...)
    if Config.Debug then
        local args = { ... }

        for i = 1, #args do
            local arg = args[i]
            args[i] = type(arg) == 'table' and json.encode(arg, { sort_keys = true, indent = true }) or tostring(arg)
        end

        print('^6[DEBUG] ^7', table.concat(args, '\t'))
    end
end

function utils.createPed(name, ...)
    local model = lib.requestModel(name)

    if not model then return end

    local ped = CreatePed(0, model, ...)

    SetEntityInvincible(ped, true)
    SetModelAsNoLongerNeeded(model)

    table.insert(peds, ped)

    return ped
end

function utils.createVehicle(name, ...)
    local model = lib.requestModel(name)

    if not model then return end

    local vehicle = CreateVehicle(model, ...)

    SetVehicleNeedsToBeHotwired(vehicle, false)
    NetworkFadeInEntity(vehicle, true)
    SetModelAsNoLongerNeeded(model)

    return vehicle
end

function utils.createBlip(data)
    local blip = AddBlipForCoord(data.pos)
    SetBlipSprite(blip, data.type)
    SetBlipDisplay(blip, 6)
    SetBlipScale(blip, data.scale)
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.name)
    EndTextCommandSetBlipName(blip)

    return blip
end

function utils.getClosestHospital()
    local closestHospital = nil
    local playerPed = cache.ped or PlayerPedId()
    local playerCoords = cache.coords or GetEntityCoords(playerPed)
    local minDist = 999999

    for k, v in pairs(Config.Hospitals) do
        local hospitalCoords = v.zone.pos
        local dist = #(playerCoords - hospitalCoords)

        if dist < minDist then
            minDist = dist
            closestHospital = v
        end
    end

    return closestHospital
end

function utils.drawTextFrame(data)
    SetTextFont(4)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)

    SetTextEntry('STRING')
    AddTextComponentString(data.msg)
    DrawText(data.x, data.y)
end

RegisterNetEvent('ars_ambulancejob:showNotification', utils.showNotification)
