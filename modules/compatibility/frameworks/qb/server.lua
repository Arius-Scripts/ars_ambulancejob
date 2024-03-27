QBCore = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil

if not QBCore then return end

function removeAccountMoney(target, account, amount)
    local xPlayer = QBCore.Functions.GetPlayer(target)
    xPlayer.Functions.RemoveMoney(account, amount)
end

function hasJob(target, jobs)
    local xPlayer = QBCore.Functions.GetPlayer(target)

    if type(jobs) == "table" then
        for index, jobName in pairs(jobs) do
            if xPlayer.PlayerData.job.name == jobName then return true end
        end
    else
        return xPlayer.PlayerData.job.name == jobs
    end

    return false
end

function playerJob(target)
    local xPlayer = QBCore.Functions.GetPlayer(target)

    return xPlayer.PlayerData.job.name
end

function updateStatus(data)
    local Player = QBCore.Functions.GetPlayer(data.target)

    Player.Functions.SetMetaData("isdead", data.status)

    if not player[source] then
        player[source] = {}
    end

    player[source].isDead = data.status

    if data.status == true then
        player[source].killedBy = data.killedBy
    end
end

function getPlayerName(target)
    local xPlayer = QBCore.Functions.GetPlayer(target)

    return xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
end

function getDeathStatus(target)
    local Player = QBCore.Functions.GetPlayer(target)

    local data = {
        isDead = Player.PlayerData.metadata['isdead']
    }

    return data
end

QBCore.Functions.CreateUseableItem(Config.MedicBagItem, function(source, item)
    if not hasJob(source, Config.EmsJobs) then return end

    TriggerClientEvent("ars_ambulancejob:placeMedicalBag", source)
end)
