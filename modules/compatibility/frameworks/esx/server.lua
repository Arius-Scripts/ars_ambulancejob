local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

function removeAccountMoney(target, account, amount)
    local xPlayer = ESX.GetPlayerFromId(target)
    xPlayer.removeAccountMoney(account, amount)
end

function hasJob(target, jobs)
    local xPlayer = ESX.GetPlayerFromId(target)

    if type(jobs) == "table" then
        for index, jobName in pairs(jobs) do
            if xPlayer.job.name == jobName then return true end
        end
    else
        return xPlayer.job.name == jobs
    end

    return false
end

function playerJob(target)
    local xPlayer = ESX.GetPlayerFromId(target)

    return xPlayer.job.name
end

function updateStatus(data)
    local xPlayer = ESX.GetPlayerFromId(data.target)

    MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', { data.status, xPlayer.identifier })

    if not player[source] then
        player[source] = {}
    end

    player[source].isDead = data.status

    if data.status == true then
        player[source].killedBy = data.killedBy
    end
end

function getPlayerName(target)
    local xPlayer = ESX.GetPlayerFromId(target)

    return xPlayer.getName()
end

function getDeathStatus(target)
    local xPlayer = ESX.GetPlayerFromId(target)

    local isDead = MySQL.scalar.await('SELECT `is_dead` FROM `users` WHERE `identifier` = ? LIMIT 1', {
        xPlayer.identifier
    })

    local data = {
        isDead = isDead
    }

    return data
end

ESX.RegisterUsableItem(Config.MedicBagItem, function(source)
    if not hasJob(source, Config.EmsJobs) then return end

    TriggerClientEvent("ars_ambulancejob:placeMedicalBag", source)
end)

CreateThread(function()
    for k, v in pairs(Config.EmsJobs) do
        TriggerEvent('esx_society:registerSociety', v, v, 'society_' .. v, 'society_' .. v, 'society_' .. v, { type = 'public' })
    end
end)
