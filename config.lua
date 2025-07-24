Config = {}

Config.Debug = true

Config.Framework = "esx"
Config.Target = "ox_target" -- ox_target, qb-target
Config.JobName = "ambulance"
Config.EmsCommand = "911"

Config.UseLaststand = true

Config.MedicBagProp = "xm_prop_x17_bag_med_01a"
Config.MedicBagItem = "medicalbag"

Config.UseOxInventory = GetResourceState("ox_inventory") ~= "missing"

Config.Commands = {
    revive = { name = "revive", group = { "group.admin" } },
    reviveArea = { name = "revivearea", group = { "group.admin" } },
    heal = { name = "heal", group = { "group.admin" } },
    healArea = { name = "healarea", group = { "group.admin" } },
    reviveAll = { name = "reviveall", group = { "group.admin" } },
}

Config.Animations = {
    ["death_car"] = {
        dict = "veh@low@front_ps@idle_duck",
        clip = "sit"
    },
    ["death_normal"] = {
        dict = "dead",
        clip = "dead_a"
    },
    ["get_up"] = {
        dict = "get_up@directional@movement@from_knees@action",
        clip = "getup_r_0"
    }
}

function Config.sendDistressCall(msg)
    -- [--] -- Quasar

    -- TriggerServerEvent('qs-smartphone:server:sendJobAlert', {message = msg, location = GetEntityCoords(PlayerPedId())}, "ambulance")


    -- [--] -- GKS
    -- local myPos = GetEntityCoords(PlayerPedId())
    -- local GPS = 'GPS: ' .. myPos.x .. ', ' .. myPos.y

    -- ESX.TriggerServerCallback('gksphone:namenumber', function(Races)
    --   local name = Races[2].firstname .. ' ' .. Races[2].lastname

    --   TriggerServerEvent('gksphone:jbmessage', name, Races[1].phone_number, msg, '', GPS, "ambulance")
    -- end)
end

function Config.giveVehicleKeys(vehicle, plate)
    -- exaple usage
    -- exports['youscript']:name(vehicle, plate)
end

function Config.removeVehicleKeys(vehicle, plate)
    -- exaple usage
    -- exports['youscript']:name(vehicle, plate)
end
