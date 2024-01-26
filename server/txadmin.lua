if not GetResourceState('monitor'):find('start') then return end

AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
    local target = eventData.id

    if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(target) ~= "number" then
        return
    end

    if target ~= -1 then
        local playerStateDead = Player(target).state.dead
        TriggerClientEvent('ars_ambulancejob:healPlayer', target, { revive = playerStateDead })
    elseif target == -1 then
        for _, playerId in ipairs(GetPlayers()) do
            local playerStateDead = Player(playerId).state.dead
            TriggerClientEvent('ars_ambulancejob:healPlayer', playerId, { revive = playerStateDead })
        end
    end
end)
