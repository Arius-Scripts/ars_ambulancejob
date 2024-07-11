local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

Framework = {}
local useOxInventory = lib.load("config").useOxInventory
local ox_inventory = useOxInventory and exports.ox_inventory

function Framework.removeAccountMoney(target, account, amount)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end

    xPlayer.removeAccountMoney(account, amount)
end

function Framework.hasJob(target, jobs)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end
    if type(jobs) == "table" then
        for index, jobName in pairs(jobs) do
            if xPlayer.job.name == jobName then return true end
        end
    else
        return xPlayer.job.name == jobs
    end

    return false
end

function Framework.playerJob(target)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end

    return xPlayer.job.name
end

function Framework.updateStatus(data)
    local xPlayer = ESX.GetPlayerFromId(data.target)

    MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', { data.status, xPlayer.identifier })

    if not player[data.target] then
        player[data.target] = {}
    end

    player[data.target].isDead = data.status

    if data.status == true then
        player[data.target].killedBy = data.killedBy
    end
end

function Framework.getPlayerName(target)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end

    return xPlayer.getName()
end

function Framework.getDeathStatus(target)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end

    local isDead = MySQL.scalar.await('SELECT `is_dead` FROM `users` WHERE `identifier` = ? LIMIT 1', {
        xPlayer.identifier
    })

    local data = {
        isDead = isDead
    }

    return data
end

function Framework.addItem(target, item, amount)
    if ox_inventory then
        return ox_inventory:AddItem(target, item, amount)
    end

    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end
    return xPlayer.addInventoryItem(item, amount)
end

function Framework.removeItem(target, item, amount)
    if ox_inventory then
        return ox_inventory:RemoveItem(target, item, amount)
    end

    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end
    return xPlayer.removeInventoryItem(item, amount)
end

function Framework.wipeInventory(target, keep)
    if ox_inventory then
        return ox_inventory:ClearInventory(target, keep)
    end

    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end

    for _, item in pairs(xPlayer.inventory) do
        local found = false
        for index, keepItem in pairs(keep) do
            if string.lower(item.name) == string.lower(keepItem) then
                found = true
                break
            end
        end
        if item.count > 0 and not found then
            xPlayer.setInventoryItem(item.name, 0)
        end
    end
end

local medicBagItem = lib.load("config").medicBagItem
local emsJobs = lib.load("config").emsJobs
local tabletItem = lib.load("config").tabletItem

ESX.RegisterUsableItem(medicBagItem, function(source, a, b)
    if not Framework.hasJob(source, emsJobs) then return end

    TriggerClientEvent("ars_ambulancejob:placeMedicalBag", source)
end)

ESX.RegisterUsableItem(tabletItem, function(source, a, b)
    if not Framework.hasJob(source, emsJobs) then return end

    TriggerClientEvent("ars_ambulancejob:openDistressCalls", source)
end)


if GetResourceState('esx_society'):find('start') then
    CreateThread(function()
        for k, v in pairs(emsJobs) do
            TriggerEvent('esx_society:registerSociety', v, v, 'society_' .. v, 'society_' .. v, 'society_' .. v, { type = 'public' })
        end
    end)
else
    print("^6[Warning] > ^7 esx_society ^6needs to be started")
end
