local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end



AddEventHandler('esx:onPlayerSpawn', function(playerData)
    Wait(1000)
end)

AddEventHandler('esx:onPlayerLogout', function()
    -- Framework:setInjuries()
end)


function Framework:getInjuries()
    local playerData = ESX.GetPlayerData()
    return json.decode(playerData?.metadata?.injuries) or {}
end

function Framework:hasJob(jobs)
    local playerData = ESX.GetPlayerData()

    if type(jobs) == "table" then
        for index, jobName in pairs(jobs) do
            if playerData.job.name == jobName then return true end
        end
    else
        return playerData.job.name == jobs
    end

    return false
end

function Framework:getPlayerJobGrade()
    local playerData = ESX.GetPlayerData()
    local jobGrade = playerData.job.grade

    return jobGrade
end

function Framework:playerJob()
    local playerData = ESX.GetPlayerData()

    return playerData.job.name
end
