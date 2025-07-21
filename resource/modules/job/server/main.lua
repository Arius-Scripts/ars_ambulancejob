local distressCalls = {}
-- Table to store last distress call time per player
local playerDistressCooldowns = {}
local COOLDOWN_SECONDS = 300 -- 5 minutes

-- Callback to create a distress call, enforcing cooldown
lib.callback.register("ars_ambulancejob:cb:server:createDistressCall", function(source, data)
    local now = os.time()
    local last = playerDistressCooldowns[source] or 0
    if now - last < COOLDOWN_SECONDS then
        return false, COOLDOWN_SECONDS - (now - last)
    end

    distressCalls[#distressCalls + 1] = {
        player = source,
        time = now,
        data = data
    }
    playerDistressCooldowns[source] = now


    local players = GetPlayers()
    local playerName = Framework:getPlayerName(source)

    for i = 1, #players do
        local id = tonumber(players[i])

        if Framework:hasJob(id, Config.JobName) then
            TriggerClientEvent("ars_ambulancejob:client:createDistressCall", id, playerName)
        end
    end
    return true
end)

function getAllDistressCalls() return distressCalls end
