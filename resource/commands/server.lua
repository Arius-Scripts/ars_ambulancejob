local Commands = Config.Commands

-- Cooldown table: stores last command usage time per player per command
local PlayerCommandCooldowns = {}
-- Distress calls table: stores all distress calls with info
local DistressCalls = {}

-- Helper: Check and update cooldown for a player/command
local function checkAndSetCooldown(playerId, command, cooldownSeconds)
    local now = os.time()
    PlayerCommandCooldowns[playerId] = PlayerCommandCooldowns[playerId] or {}
    local last = PlayerCommandCooldowns[playerId][command] or 0
    if now - last < cooldownSeconds then
        return false, cooldownSeconds - (now - last)
    end
    PlayerCommandCooldowns[playerId][command] = now
    return true
end

-- Helper: Add a distress call
local function addDistressCall(playerId, info)
    table.insert(DistressCalls, {
        playerId = playerId,
        time = os.time(),
        info = info
    })
end

-- Example usage for distress call (call this from wherever a distress is triggered):
-- addDistressCall(source, { location = GetEntityCoords(GetPlayerPed(source)), message = 'Help needed!' })

-- Wrap command logic with cooldown check
lib.addCommand(Commands.revive.name, {
    help = locale("revive_player"),
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
            optional = true,
        },
    },
    restricted = Commands.revive.group
}, function(source, args, raw)
    -- Cooldown: 5 minutes (300 seconds) per player
    local ok, remaining = checkAndSetCooldown(source, 'revive', 300)
    if not ok then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("cooldown_active"):format(math.ceil(remaining / 60))))
        return
    end
    if not args.target then args.target = source end
    local data = {}
    data.revive = true
    TriggerClientEvent('ars_ambulancejob:client:healPlayer', args.target, data)
    if source > 0 then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("revived_player")):format(args.target))
    else
        print("^4ars_ambulancejob > ^0", (locale("revived_player")):format(args.target))
    end
end)

-- Repeat similar cooldown logic for other commands as needed
-- Example for reviveArea
lib.addCommand(Commands.reviveArea.name, {
    help = locale("revive_area"),
    params = {
        {
            name = 'radius',
            type = 'number',
            help = 'to revive players in radius',
            optional = false,
        },
    },
    restricted = Commands.reviveArea.group
}, function(source, args, raw)
    if source <= 0 then return print("^4ars_ambulancejob > ^0", "You cant run this command from console") end
    local ok, remaining = checkAndSetCooldown(source, 'reviveArea', 300)
    if not ok then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("cooldown_active"):format(math.ceil(remaining / 60))))
        return
    end
    local players = GetPlayers()
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    for i = 1, #players do
        local player = players[i]
        local ped    = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local dist   = #(playerCoords - coords)
        if dist <= args.radius then
            TriggerClientEvent('ars_ambulancejob:client:healPlayer', player, { revive = true })
        end
    end
    TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("revived_area")):format(args.radius))
end)

-- Add cooldown to heal command
lib.addCommand(Commands.heal.name, {
    help = locale("heal_player"),
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
            optional = true,
        },
    },
    restricted = Commands.heal.group
}, function(source, args, raw)
    local ok, remaining = checkAndSetCooldown(source, 'heal', 300)
    if not ok then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("cooldown_active"):format(math.ceil(remaining / 60))))
        return
    end
    if not args.target then args.target = source end
    local data = {}
    data.heal = true
    TriggerClientEvent('ars_ambulancejob:client:healPlayer', args.target, data)
    if source > 0 then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("healed_player")):format(args.target))
    else
        print("^4ars_ambulancejob > ^0", (locale("healed_player")):format(args.target))
    end
end)

-- Add cooldown to healArea command
lib.addCommand(Commands.healArea.name, {
    help = locale("heal_area"),
    params = {
        {
            name = 'radius',
            type = 'number',
            help = 'to revive players in radius',
            optional = false,
        },
    },
    restricted = Commands.healArea.group
}, function(source, args, raw)
    if source <= 0 then return print("^4ars_ambulancejob > ^0", "You cant run this command from console") end
    local ok, remaining = checkAndSetCooldown(source, 'healArea', 300)
    if not ok then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("cooldown_active"):format(math.ceil(remaining / 60))))
        return
    end
    local players = GetPlayers()
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    for i = 1, #players do
        local player = players[i]
        local ped    = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local dist   = #(coords - playerCoords)
        if dist <= args.radius then
            TriggerClientEvent('ars_ambulancejob:client:healPlayer', player, { heal = true })
        end
    end
    TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("healed_area")):format(args.radius))
end)

-- Add cooldown to reviveAll command
lib.addCommand(Commands.reviveAll.name, {
    help = locale("revive_all"),
    restricted = Commands.reviveAll.group
}, function(source, args, raw)
    local ok, remaining = checkAndSetCooldown(source, 'reviveAll', 300)
    if not ok then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("cooldown_active"):format(math.ceil(remaining / 60))))
        return
    end
    local players = GetPlayers()
    for i = 1, #players do
        local player = players[i]
        TriggerClientEvent('ars_ambulancejob:client:healPlayer', player, { revive = true })
    end
    if source > 0 then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, locale("revived_all"))
    else
        print("^4ars_ambulancejob > ^0", locale("revived_all"))
    end
end)

-- NOTE: You must add a new locale string for "cooldown_active" in your locales, e.g.:
-- "cooldown_active": "You must wait %s more minutes before using this command again."
