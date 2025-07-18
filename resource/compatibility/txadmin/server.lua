if not GetResourceState('monitor'):find('start') then return end

AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
    local target = eventData.id

    if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(target) ~= "number" then
        return
    end

    if target ~= -1 then
        TriggerClientEvent('ars_ambulancejob:client:healPlayer', target, { revive = true })
    elseif target == -1 then
        for _, playerId in ipairs(GetPlayers()) do
            TriggerClientEvent('ars_ambulancejob:client:healPlayer', playerId, { revive = true })
        end
    end
end)
