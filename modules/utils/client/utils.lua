local CreatePed = CreatePed
local SetEntityInvincible = SetEntityInvincible
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local CreateVehicle = CreateVehicle
local SetVehicleNeedsToBeHotwired = SetVehicleNeedsToBeHotwired
local NetworkFadeInEntity = NetworkFadeInEntity
local AddBlipForCoord = AddBlipForCoord
local SetBlipSprite = SetBlipSprite
local SetBlipDisplay = SetBlipDisplay
local SetBlipScale = SetBlipScale
local SetBlipColour = SetBlipColour
local SetBlipAsShortRange = SetBlipAsShortRange
local BeginTextCommandSetBlipName = BeginTextCommandSetBlipName
local AddTextComponentString = AddTextComponentString
local EndTextCommandSetBlipName = EndTextCommandSetBlipName
local GetEntityCoords = GetEntityCoords
local PlayerPedId = PlayerPedId
local TriggerServerEvent = TriggerServerEvent
local DoScreenFadeOut = DoScreenFadeOut
local DoScreenFadeIn = DoScreenFadeIn
local IsScreenFadedOut = IsScreenFadedOut
local IsScreenFadedIn = IsScreenFadedIn

utils = {}
peds = {}

function utils.showNotification(msg, type)
    lib.notify({
        title = 'Ars Ambulancejob',
        description = msg,
        type = type and type or 'info'
    })
end

local debug = lib.load("config").debug

function utils.debug(...)
    if debug then
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

    for k, v in pairs(lib.load("data.hospitals")) do
        local hospitalCoords = v.zone.pos
        local dist = #(playerCoords - hospitalCoords)

        if dist < minDist then
            minDist = dist
            closestHospital = v
        end
    end

    return closestHospital
end

function utils.addRemoveItem(type, item, quantity)
    local data = {}
    data.toggle = type == "remove"
    data.item = item
    data.quantity = quantity

    utils.debug(type, item, quantity)
    utils.debug(data)

    TriggerServerEvent("ars_ambulancejob:removAddItem", data)
end

function utils.useItem(item, value)
    local data = {}
    data.item = item
    data.value = value
    TriggerServerEvent("ars_ambulancejob:useItem", data)
end

function utils.getItem(name)
    local item = lib.callback.await('ars_ambulancejob:getItem', false, name)

    return item
end

function utils.isBedOccupied(coords)
    local playerId, playerPed, playerCoords = lib.getClosestPlayer(coords.xyz, 1.5, true)
    if not playerPed then return false end
    if IsEntityPlayingAnim(playerPed, "anim@gangops@morgue@table@", "body_search", 3) or IsEntityPlayingAnim(playerPed, "switch@franklin@bed", "sleep_getup_rubeyes", 3) then return true end

    return false
end

function utils.inHospitalZone(playerPos, boxPos, boxSize)
    local xInside = playerPos.x >= boxPos.x - boxSize.x / 2 and playerPos.x <= boxPos.x + boxSize.x / 2
    local yInside = playerPos.y >= boxPos.y - boxSize.y / 2 and playerPos.y <= boxPos.y + boxSize.y / 2
    local zInside = playerPos.z >= boxPos.z - boxSize.z / 2 and playerPos.z <= boxPos.z + boxSize.z / 2

    return xInside and yInside and zInside
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

function utils.doScreenFadeOut(duration, wait)
    DoScreenFadeOut(duration or 800)

    if not wait then return end
    while not IsScreenFadedOut() do
        Wait(50)
    end
end

function utils.doScreenFadeIn(duration, wait)
    DoScreenFadeIn(duration or 800)

    if not wait then return end
    while not IsScreenFadedIn() do
        Wait(50)
    end
end

RegisterNetEvent('ars_ambulancejob:showNotification', utils.showNotification)
