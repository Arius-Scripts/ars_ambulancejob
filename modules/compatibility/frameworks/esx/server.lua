local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

Framework = {}

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

function Framework.addItem(source, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    return xPlayer.addInventoryItem(item, amount)
end

function Framework.removeItem(source, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    return xPlayer.removeInventoryItem(item, amount)
end

ESX.RegisterUsableItem(Config.MedicBagItem, function(source, a, b)
    if not Framework.hasJob(source, Config.EmsJobs) then return end

    TriggerClientEvent("ars_ambulancejob:placeMedicalBag", source)
end)

CreateThread(function()
    for k, v in pairs(Config.EmsJobs) do
        TriggerEvent('esx_society:registerSociety', v, v, 'society_' .. v, 'society_' .. v, 'society_' .. v, { type = 'public' })
    end
end)
