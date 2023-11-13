-- TODO change some data to use QBX.PlayerData
function removeAccountMoney(target, account, amount)
    local xPlayer = exports.qbx_core:GetPlayer(target)
    xPlayer.Functions.RemoveMoney(account, amount)
end

function hasJob(target, jobs)
    local xPlayer = exports.qbx_core:GetPlayer(target)

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
    local xPlayer = exports.qbx_core:GetPlayer(target)

    return xPlayer.PlayerData.job.name
end

function updateStatus(data)
    local Player = exports.qbx_core:GetPlayer(data.target)

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
    local xPlayer = exports.qbx_core:GetPlayer(target)

    return xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
end

function getDeathStatus(target)
    local Player = exports.qbx_core:GetPlayer(target)

    local data = {
        isDead = Player.PlayerData.metadata['isdead']
    }

    return data
end

exports.qbx_core:CreateUseableItem(Config.MedicBagItem, function(source, item)
    if not hasJob(source, Config.EmsJobs) then return end

    TriggerClientEvent("llrp_ambulancejob:placeMedicalBag", source)
end)
