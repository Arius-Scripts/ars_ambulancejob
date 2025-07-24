GlobalState.distressCalls = GlobalState.distressCalls or {}
-- Table to store last distress call time per player
local playerDistressCooldowns = {}
local COOLDOWN_SECONDS = 1 * 60 -- 1 minutes

-- Callback to create a distress call, enforcing cooldown
lib.callback.register("ars_ambulancejob:cb:server:createDistressCall", function(source, data)
    local now = os.time()
    local last = playerDistressCooldowns[source] or 0
    local remaining = COOLDOWN_SECONDS - (now - last)
    if remaining > 0 then
        return false, remaining
    end
    playerDistressCooldowns[source] = now

    local playerName = Framework:getPlayerName(source)

    local calls = GlobalState.distressCalls or {}
    calls[#calls + 1] = {
        name = playerName,
        time = os.date("%Y-%m-%d %H:%M:%S", now),
        msg = data.msg,
        coords = data.coords,
        streetName = data.streetName
    }
    GlobalState.distressCalls = calls

    local players = GetPlayers()
    for i = 1, #players do
        local id = tonumber(players[i])

        if Framework:hasJob(id, Config.JobName) then
            TriggerClientEvent("ars_ambulancejob:client:createDistressCall", id, playerName)
        end
    end
    return true
end)

RegisterNetEvent("ars_ambulancejob:server:callCompleted", function(callIndex)
    if not callIndex then return end
    local calls = GlobalState.distressCalls or {}
    calls[callIndex] = nil
    GlobalState.distressCalls = calls
end)

----------------
--[ End Distresscalls ]--
----------------
