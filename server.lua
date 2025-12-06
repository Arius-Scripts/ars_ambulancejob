player               = {}
medicalBags          = medicalBags or {}
local pendingRewards = {}
distressCalls        = {}
local config         = lib.load("config")
local emsJobs        = config.emsJobs
local reviveReward   = config.reviveReward or 0
local medicBagItem   = config.medicBagItem
local paramedicPrice = config.paramedicTreatmentPrice or 0
local useOxInventory = config.useOxInventory
local hospitals      = lib.load("data.hospitals")
local ox_inventory   = useOxInventory and exports.ox_inventory

local pharmacies = {}
for _, hospital in pairs(hospitals) do
    if hospital.pharmacy then
        for id, pharmacy in pairs(hospital.pharmacy) do
            pharmacies[id] = pharmacy
        end
    end
end

local function getPharmacyItem(pharmacyId, itemName)
    local pharmacy = pharmacies[pharmacyId]
    if not pharmacy or not pharmacy.items then return end

    for _, item in ipairs(pharmacy.items) do
        if item.name == itemName then
            return item, pharmacy
        end
    end
end

local function ensureRewardCache(source)
    if not pendingRewards[source] then
        pendingRewards[source] = {
            revives = {},
            injuries = {}
        }
    end

    return pendingRewards[source]
end

local function cleanupRewardCache(source)
    local rewards = pendingRewards[source]
    if not rewards then return end

    local hasRevives = rewards.revives and next(rewards.revives)
    local hasInjuries = rewards.injuries and next(rewards.injuries)

    if not hasRevives and not hasInjuries then
        pendingRewards[source] = nil
    end
end

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

    local targetServerId = tonumber(data.targetServerId)

    if data.injury then
        local targetPlayer = Player(targetServerId)
        if not targetPlayer then return end

        local injuries = targetPlayer.state.injuries or {}
        local injury = injuries[data.bone]
        if not injury then return end

        local reward = math.floor(100 * ((injury.value or 0) / 10))
        if reward > 0 then
            local rewards = ensureRewardCache(source)
            rewards.injuries[targetServerId] = rewards.injuries[targetServerId] or {}
            rewards.injuries[targetServerId][data.bone] = reward
        end

        TriggerClientEvent('ars_ambulancejob:healPlayer', targetServerId, data)
    else
        data.anim = "medic"
        TriggerClientEvent("ars_ambulancejob:playHealAnim", source, data)
        data.anim = "dead"
        TriggerClientEvent("ars_ambulancejob:playHealAnim", targetServerId, data)

        if reviveReward and reviveReward > 0 then
            local rewards = ensureRewardCache(source)
            rewards.revives[targetServerId] = reviveReward
        end
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

RegisterNetEvent("ars_ambulancejob:useItem", function(data)
    if not Framework.hasJob(source, emsJobs) then return end

    if ox_inventory then
        local item = ox_inventory:GetSlotWithItem(source, data.item)
        local slot = item.slot

        return ox_inventory:SetDurability(source, slot, item.metadata?.durability and (item.metadata?.durability - data.value) or (100 - data.value))
    end

    Framework.removeItem(data.item)
end)
local removeItemsOnRespawn = config.removeItemsOnRespawn
local keepItemsOnRespawn = config.keepItemsOnRespawn
RegisterNetEvent("ars_ambulancejob:removeInventory", function()
    local source = source
    if player[source].isDead and removeItemsOnRespawn then
        Framework.wipeInventory(source, keepItemsOnRespawn)
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

lib.callback.register('ars_ambulancejob:purchaseItem', function(source, pharmacyId, itemName, quantity)
    quantity = tonumber(quantity)
    if not quantity or quantity < 1 then return { success = false, reason = 'invalid_quantity' } end

    local item, pharmacy = getPharmacyItem(pharmacyId, itemName)
    if not item then return { success = false, reason = 'invalid_item' } end

    if pharmacy.job and not Framework.hasJob(source, emsJobs) then
        return { success = false, reason = 'no_access' }
    end

    if pharmacy.job and pharmacy.grade then
        local jobGrade = Framework.getPlayerJobGrade and Framework.getPlayerJobGrade(source) or 0
        if jobGrade < pharmacy.grade then
            return { success = false, reason = 'no_access' }
        end
    end

    local totalPrice = math.floor(item.price * quantity)
    if totalPrice < 1 then return { success = false, reason = 'invalid_price' } end

    if not Framework.hasItem(source, 'money', totalPrice) then
        return { success = false, reason = 'not_enough_money' }
    end

    Framework.removeItem(source, 'money', totalPrice)
    Framework.addItem(source, item.name, quantity)

    return { success = true }
end)

lib.callback.register('ars_ambulancejob:payParamedicTreatment', function(source)
    if paramedicPrice <= 0 then return true end

    if not Framework.hasItem(source, 'money', paramedicPrice) then
        return false
    end

    Framework.removeItem(source, 'money', paramedicPrice)
    return true
end)

RegisterNetEvent("ars_ambulancejob:claimReward", function(payload)
    local source = source
    if not Framework.hasJob(source, emsJobs) then return end
    if type(payload) ~= "table" then return end

    local rewards = pendingRewards[source]
    if not rewards then return end

    if payload.type == "revive" then
        local target = tonumber(payload.target)
        if not target then return end

        local reward = rewards.revives[target]
        if not reward then return end

        rewards.revives[target] = nil
        Framework.addItem(source, "money", reward)

    elseif payload.type == "injury" then
        local target = tonumber(payload.target)
        local bone = payload.bone
        if not target or not bone then return end

        local patientRewards = rewards.injuries[target]
        if not patientRewards then return end

        local reward = patientRewards[bone]
        if not reward then return end

        patientRewards[bone] = nil
        if not next(patientRewards) then
            rewards.injuries[target] = nil
        end

        Framework.addItem(source, "money", reward)
    end

    cleanupRewardCache(source)
end)

RegisterNetEvent("ars_ambulancejob:returnMedicalBag", function()
    local source = source
    if not Framework.hasJob(source, emsJobs) then return end

    local deployed = medicalBags[source]
    if not deployed or deployed < 1 then return end

    deployed -= 1
    if deployed <= 0 then
        medicalBags[source] = nil
    else
        medicalBags[source] = deployed
    end

    Framework.addItem(source, medicBagItem, 1)
end)

AddEventHandler('playerDropped', function()
    local source = source
    pendingRewards[source] = nil
    medicalBags[source] = nil
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
