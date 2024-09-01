local adminGroups = lib.load("config").adminGroup
local reviveCommand = lib.load("config").reviveCommand

lib.addCommand(reviveCommand, {
    help = locale("revive_player"),
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
            optional = true,
        },
    },
    restricted = adminGroups
}, function(source, args, raw)
    if not args.target then args.target = source end

    local data = {}
    data.revive = true

    local StaffID = source
    local TargetID = args.target

    TriggerClientEvent('ars_ambulancejob:healPlayer', args.target, data)
    Citizen.Wait(10)
    TriggerEvent('ars_ambulancejob:discord:target', "revive", StaffID, TargetID)

    if source > 0 then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("revived_player")):format(args.target))
    else
        print("^4ars_ambulancejob > ^0", (locale("revived_player")):format(args.target))
    end
end)

local reviveAreaCommand = lib.load("config").reviveAreaCommand
lib.addCommand(reviveAreaCommand, {
    help = locale("revive_area"),
    params = {
        {
            name = 'radius',
            type = 'number',
            help = 'to revive players in radius',
            optional = false,
        },
    },
    restricted = adminGroups
}, function(source, args, raw)
    if source <= 0 then return print("^4ars_ambulancejob > ^0", "You cant run this command from console") end

    local players = GetPlayers()

    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    local StaffID = source
    local radius = args.radius

    for i = 1, #players do
        local player = players[i]
        local ped    = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local dist   = #(playerCoords - coords)

        if dist <= args.radius then
            TriggerClientEvent('ars_ambulancejob:healPlayer', player, { revive = true })
            Citizen.Wait(10)
            TriggerEvent('ars_ambulancejob:discord:radius', "revivearea", StaffID, radius)
        end
    end
    TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("revived_area")):format(args.radius))
end)

local healCommand = lib.load("config").healCommand
lib.addCommand(healCommand, {
    help = locale("heal_player"),
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
            optional = true,
        },
    },
    restricted = adminGroups
}, function(source, args, raw)
    if not args.target then args.target = source end

    local StaffID = source
    local TargetID = args.target

    local data = {}
    data.heal = true
    TriggerClientEvent('ars_ambulancejob:healPlayer', args.target, data)
    Citizen.Wait(10)
    TriggerEvent("ars_ambulancejob:discord:target", Config.HealCommand, source, TargetID)

    if source > 0 then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("healed_player")):format(args.target))
    else
        print("^4ars_ambulancejob > ^0", (locale("healed_player")):format(args.target))
    end
end)

local healAreaCommand = lib.load("config").healAreaCommand
lib.addCommand(healAreaCommand, {
    help = locale("heal_area"),
    params = {
        {
            name = 'radius',
            type = 'number',
            help = 'to revive players in radius',
            optional = false,
        },
    },
    restricted = adminGroups
}, function(source, args, raw)
    if source <= 0 then return print("^4ars_ambulancejob > ^0", "You cant run this command from console") end

    local players = GetPlayers()

    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    local StaffID = source
    local radius = args.radius

    for i = 1, #players do
        local player = players[i]
        local ped    = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local dist   = #(coords - playerCoords)
        if dist <= args.radius then
            TriggerClientEvent('ars_ambulancejob:healPlayer', player, { heal = true })
            Citizen.Wait(10)
            TriggerEvent('ars_ambulancejob:discord:radius', "healarea", StaffID, radius)
        end
    end
    TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("healed_area")):format(args.radius))
end)

local reviveAllCommand = lib.load("config").reviveAllCommand
lib.addCommand(reviveAllCommand, {
    help = locale("revive_all"),
    restricted = adminGroups
}, function(source, args, raw)
    local players = GetPlayers()

    local StaffID = source

    for i = 1, #players do
        local player = players[i]
        TriggerClientEvent('ars_ambulancejob:healPlayer', player, { revive = true })
    end

    if source > 0 then
        TriggerClientEvent("ars_ambulancejob:showNotification", source, locale("revived_all"))
        Citizen.Wait(10)
        TriggerEvent("ars_ambulancejob:discord:all", Config.ReviveAllCommand, source)
    else
        print("^4ars_ambulancejob > ^0", locale("revived_all"))
    end
end)
