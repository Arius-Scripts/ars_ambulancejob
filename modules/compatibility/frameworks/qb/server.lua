QBCore = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil

if not QBCore then return end

Framework = {}
local useOxInventory = lib.load("config").useOxInventory
local ox_inventory = useOxInventory and exports.ox_inventory

function Framework.removeAccountMoney(target, account, amount)
    local xPlayer = QBCore.Functions.GetPlayer(target)
    if not xPlayer then return end

    xPlayer.Functions.RemoveMoney(account, amount)
end

function Framework.hasJob(target, jobs)
    local xPlayer = QBCore.Functions.GetPlayer(target)
    if not xPlayer then return end

    if type(jobs) == "table" then
        for index, jobName in pairs(jobs) do
            if xPlayer.PlayerData.job.name == jobName then return true end
        end
    else
        return xPlayer.PlayerData.job.name == jobs
    end

    return false
end

function Framework.playerJob(target)
    local xPlayer = QBCore.Functions.GetPlayer(target)
    if not xPlayer then return end

    return xPlayer.PlayerData.job.name
end

function Framework.updateStatus(data)
    local Player = QBCore.Functions.GetPlayer(data.target)

    Player.Functions.SetMetaData("isdead", data.status)

    if not player[data.target] then
        player[data.target] = {}
    end

    player[data.target].isDead = data.status

    if data.status == true then
        player[data.target].killedBy = data.killedBy
    end
end

function Framework.getPlayerName(target)
    local xPlayer = QBCore.Functions.GetPlayer(target)
    if not xPlayer then return end

    return xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
end

function Framework.getDeathStatus(target)
    local Player = QBCore.Functions.GetPlayer(target)
    if not Player then return end

    local data = {
        isDead = Player.PlayerData.metadata['isdead']
    }

    return data
end

function Framework.addItem(source, item, amount)
    if ox_inventory then
        return ox_inventory:AddItem(source, item, amount)
    end

    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return end
    if item == "money" or item == "cash" then
        return xPlayer.Functions.AddMoney("cash", amount)
    else
        return xPlayer.Functions.AddItem(item, amount)
    end
end

function Framework.removeItem(source, item, amount)
    if ox_inventory then
        return ox_inventory:RemoveItem(source, item, amount)
    end

    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return end

    if item == "money" then
        return xPlayer.Functions.RemoveMoney("cash", amount)
    end

    return xPlayer.Functions.RemoveItem(item, amount)
end

function Framework.wipeInventory(target, keep)
    if ox_inventory then
        return ox_inventory:ClearInventory(target, keep)
    end

    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return end
    exports["qb-inventory"]:ClearInventory(target, keep)
end

local medicBagItem = lib.load("config").medicBagItem
local emsJobs = lib.load("config").emsJobs
local tabletItem = lib.load("config").tabletItem

QBCore.Functions.CreateUseableItem(medicBagItem, function(source, item)
    if not Framework.hasJob(source, emsJobs) then return end

    TriggerClientEvent("ars_ambulancejob:placeMedicalBag", source)
end)
QBCore.Functions.CreateUseableItem(tabletItem, function(source, item)
    if not Framework.hasJob(source, emsJobs) then return end

    TriggerClientEvent("ars_ambulancejob:openDistressCalls", source)
end)
