lib.addCommand(Config.ReviveCommand, {
    help = locale("revive_player"),
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
            optional = true,
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    if not args.target then args.target = source end

    local data = {}
    data.revive = true

    TriggerClientEvent('ars_ambulancejob:healPlayer', args.target, data)
    TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("revived_player")):format(args.target))
end)


lib.addCommand(Config.ReviveAreaCommand, {
    help = locale("revive_area"),
    params = {
        {
            name = 'radius',
            type = 'number',
            help = 'to revive players in radius',
            optional = false,
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local players = GetPlayers()

    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    for i = 1, #players do
        local player = players[i]
        local ped    = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local dist   = #(playerCoords - coords)

        if dist <= args.radius then
            TriggerClientEvent('ars_ambulancejob:healPlayer', player, { revive = true })
        end
    end
    TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("revived_area")):format(args.radius))
end)


lib.addCommand(Config.HealCommand, {
    help = locale("heal_player"),
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
            optional = true,
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    if not args.target then args.target = source end

    local data = {}
    data.heal = true
    TriggerClientEvent('ars_ambulancejob:healPlayer', args.target, data)
    TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("healed_player")):format(args.target))
end)

lib.addCommand(Config.HealAreaCommand, {
    help = locale("heal_area"),
    params = {
        {
            name = 'radius',
            type = 'number',
            help = 'to revive players in radius',
            optional = false,
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local players = GetPlayers()

    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    for i = 1, #players do
        local player = players[i]
        local ped    = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local dist   = #(coords - playerCoords)
        if dist <= args.radius then
            TriggerClientEvent('ars_ambulancejob:healPlayer', player, { heal = true })
        end
    end
    TriggerClientEvent("ars_ambulancejob:showNotification", source, (locale("healed_area")):format(args.radius))
end)

lib.addCommand(Config.ReviveAllCommand, {
    help = locale("revive_all"),
    restricted = 'group.admin'
}, function(source, args, raw)
    local players = GetPlayers()

    for i = 1, #players do
        local player = players[i]
        TriggerClientEvent('ars_ambulancejob:healPlayer', player, { heal = true })
    end

    TriggerClientEvent("ars_ambulancejob:showNotification", source, locale("revived_all"))
end)
