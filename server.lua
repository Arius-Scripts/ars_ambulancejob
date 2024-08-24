player               = {}
distressCalls        = {}
local emsJobs        = lib.load("config").emsJobs
local useOxInventory = lib.load("config").useOxInventory
local ox_inventory   = useOxInventory and exports.ox_inventory

RegisterNetEvent("ars_ambulancejob:updateDeathStatus", function(death)
    local source = source
    local data = {}
    data.target = source
    data.status = death.isDead
    data.killedBy = death?.weapon or false

    Framework.updateStatus(data)
end)

RegisterNetEvent("ars_ambulancejob:revivePlayer", function(data)
    local source = source
    if not Framework.hasJob(source, emsJobs) or not source or source < 1 then return end

    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(data.targetServerId)

    if data.targetServerId < 1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
        print(source .. ' probile modder')
    else
        local dataToSend = {}
        dataToSend.revive = true

        TriggerClientEvent('ars_ambulancejob:healPlayer', tonumber(data.targetServerId), dataToSend)
    end
end)

RegisterNetEvent("ars_ambulancejob:healPlayer", function(data)
    local source = source
    if not Framework.hasJob(source, emsJobs) or not source or source < 1 then return end


    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(data.targetServerId)

    if data.targetServerId < 1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
        return print(source .. ' probile modder')
    end


    if data.injury then
        TriggerClientEvent('ars_ambulancejob:healPlayer', tonumber(data.targetServerId), data)
    else
        data.anim = "medic"
        TriggerClientEvent("ars_ambulancejob:playHealAnim", source, data)
        data.anim = "dead"
        TriggerClientEvent("ars_ambulancejob:playHealAnim", data.targetServerId, data)
    end
end)

RegisterNetEvent("ars_ambulancejob:createDistressCall", function(data)
    local source = source
    if not source or source < 1 then return end

    local playerName = Framework.getPlayerName(source)

    distressCalls[#distressCalls + 1] = {
        msg = data.msg,
        gps = data.gps,
        location = data.location,
        name = playerName
    }

    local players = GetPlayers()

    for i = 1, #players do
        local id = tonumber(players[i])

        if Framework.hasJob(id, emsJobs) then
            TriggerClientEvent("ars_ambulancejob:createDistressCall", id, playerName)
        end
    end
end)

RegisterNetEvent("ars_ambulancejob:callCompleted", function(call)
    for i = #distressCalls, 1, -1 do
        if distressCalls[i].gps == call.gps and distressCalls[i].msg == call.msg then
            table.remove(distressCalls, i)
            break
        end
    end
end)

RegisterNetEvent("ars_ambulancejob:removAddItem", function(data)
    local source = source

    local method = data.toggle and Framework.removeItem or Framework.addItem

    method(source, data.item, data.quantity)
end)

RegisterNetEvent("ars_ambulancejob:useItem", function(data)
    if not Framework.hasJob(source, emsJobs) then return end

    if ox_inventory then
        local item = ox_inventory:GetSlotWithItem(source, data.item)
        local slot = item.slot

        return ox_inventory:SetDurability(source, slot, item.metadata?.durability and (item.metadata?.durability - data.value) or (100 - data.value))
    end

    Framework.removeItem(data.item)
end)
local removeItemsOnRespawn = lib.load("config").removeItemsOnRespawn
RegisterNetEvent("ars_ambulancejob:removeInventory", function()
    local source = source
    if player[source].isDead and removeItemsOnRespawn then
        Framework.wipeInventory(source, lib.load("config").keepItemsOnRespawn)
    end
end)

RegisterNetEvent("ars_ambulancejob:putOnStretcher", function(data)
    if not player[data.target].isDead then return end
    TriggerClientEvent("ars_ambulancejob:putOnStretcher", data.target, data.toggle)
end)

RegisterNetEvent("ars_ambulancejob:togglePatientFromVehicle", function(data)
    if not player[data.target].isDead then return end

    TriggerClientEvent("ars_ambulancejob:togglePatientFromVehicle", data.target, data.vehicle)
end)

lib.callback.register('ars_ambulancejob:getDeathStatus', function(source, target)
    return player[target] and player[target] or Framework.getDeathStatus(target or source)
end)

lib.callback.register('ars_ambulancejob:getData', function(source, target)
    local data = {}
    data.injuries = Player(target).state.injuries or false
    data.status = Framework.getDeathStatus(target or source) or Player(target).state.dead
    data.killedBy = player[target]?.killedBy or false

    return data
end)

lib.callback.register('ars_ambulancejob:getDistressCalls', function(source)
    return distressCalls
end)

lib.callback.register('ars_ambulancejob:openMedicalBag', function(playerId)
    local source = playerId
    local playerIdentifier = GetPlayerIdentifierByType(source, "license"):gsub("license:", "")

    ox_inventory:RegisterStash("medicalBag_" .. playerIdentifier, "Medical Bag", 10, 50 * 1000)

    return "medicalBag_" .. playerIdentifier
end)


lib.callback.register('ars_ambulancejob:getMedicsOniline', function(source)
    local count = 0
    local players = GetPlayers()

    for i = 1, #players do
        local id = tonumber(players[i])

        if Framework.hasJob(id, emsJobs) then
            count += 1
        end
    end
    return count
end)

if ox_inventory then
    lib.callback.register('ars_ambulancejob:getItem', function(source, name)
        local item = ox_inventory:GetSlotWithItem(source, name)

        return item
    end)

    local medicBagItem = lib.load("config").medicBagItem
    ox_inventory:registerHook('swapItems', function(payload)
        if string.find(payload.toInventory, "medicalBag_") then
            if payload.fromSlot.name == medicBagItem then return false end
        end
    end, {})

    AddEventHandler('onServerResourceStart', function(resourceName)
        if resourceName == GetCurrentResourceName() then
            local hospitals = lib.load("data.hospitals")

            for index, hospital in pairs(hospitals) do
                local cfg = hospital

                for id, stash in pairs(cfg.stash) do
                    ox_inventory:RegisterStash(id, stash.label, stash.slots, stash.weight * 1000, stash.shared and true or nil)
                end

                for id, pharmacy in pairs(cfg.pharmacy) do
                    ox_inventory:RegisterShop(id, {
                        name = pharmacy.label,
                        inventory = pharmacy.items,
                    })
                end
            end
        end
    end)
end



lib.versionCheck('Arius-Development/ars_ambulancejob')
