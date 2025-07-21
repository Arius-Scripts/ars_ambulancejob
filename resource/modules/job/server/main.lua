local distressCalls = {}
-- Table to store last distress call time per player
local playerDistressCooldowns = {}
local COOLDOWN_SECONDS = 300 -- 5 minutes

-- Callback to create a distress call, enforcing cooldown
lib.callback.register("ars_ambulancejob:cb:server:createDistressCall", function(source, data)
    local now = os.time()
    local last = playerDistressCooldowns[source] or 0
    if now - last < COOLDOWN_SECONDS then
        -- Still on cooldown, return remaining seconds
        return { success = false, remaining = COOLDOWN_SECONDS - (now - last) }
    end
    -- Store the distress call with all info
    distressCalls[#distressCalls + 1] = {
        player = source,
        time = now,
        data = data
    }
    playerDistressCooldowns[source] = now
    return { success = true }
end)

-- Optionally, add a function to get all distress calls (for admin or debug)
-- function getAllDistressCalls() return distressCalls end
