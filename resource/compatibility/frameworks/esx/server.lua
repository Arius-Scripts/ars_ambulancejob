local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

function Framework:playerDied(target, bool)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return print("xPlayer not found " .. target) end

    xPlayer.setMeta("isDead", bool and 1 or 0)
end

function Framework:getInjuries(target)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return print("xPlayer not found " .. target) end

    return xPlayer.getMeta("injuries")
end

function Framework:setInjuries(target, injuries)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return print("xPlayer not found " .. target) end

    xPlayer.setMeta("injuries", json.encode(injuries))
end

function Framework:getPlayerName(target)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end

    return xPlayer.getName()
end

function Framework:hasJob(target, jobs)
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

ESX.RegisterUsableItem(Config.MedicBagItem, function(source, a, b)
    if not Framework.hasJob(source, Config.JobName) then return end

    TriggerClientEvent("ars_ambulancejob:client:placeMedicBag", source)
end)

AddEventHandler('esx:playerLogout', function(source)
    local injuries = Player(source).state.injuries
    Framework:setInjuries(source, injuries)
end)

AddEventHandler('esx:playerLoaded', function(source, xPlayer, isNew)
    local injuries = Framework:getInjuries(target)
    Player(source).state:set("injuries", json.decode(injuries), true)
end)
