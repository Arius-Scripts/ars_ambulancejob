-- Localize all dependencies and avoid polluting global scope
local Death = require("resource.modules.death.client")
local Injury = require("resource.modules.injuries.client")
local Job = require("resource.modules.job.client.main")

lib.load("resource.utils.client.utils")

Framework = lib.class("framework")

-- Event: Handle player damage and death logic
AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end
    local victim, victimDied, weapon = data[1], data[4], data[7]

    if not IsPedAPlayer(victim) or NetworkGetPlayerIndexFromPed(victim) ~= cache.playerId then return end
    local victimDiedAndPlayer = victimDied and (IsPedDeadOrDying(victim, true) or IsPedFatallyInjured(victim))
    if victimDiedAndPlayer then
        if Config.UseLaststand then
            if not LocalPlayer.state.deathState then
                LocalPlayer.state.deathState = "knocked"
            else
                LocalPlayer.state.deathState = "dead"
            end
        else
            LocalPlayer.state.deathState = "dead"
        end
        Death:init(weapon, LocalPlayer.state.deathState)
    end
    Injury:update(victim, weapon)
end)

-- Event: Sync injuries from state bag
AddStateBagChangeHandler("injuries", nil, function(bagName, key, injuries, reserved, replicated)
    local playerId = GetPlayerFromStateBagName(bagName)
    if playerId == 0 or replicated then return end
    local src = GetPlayerServerId(playerId)
    if src ~= cache.serverId or not injuries then return end
    Injury:set(injuries)
end)

-- Net Event: Heal player (revive or heal injuries)
RegisterNetEvent("ars_ambulancejob:client:healPlayer", function(data)
    if not data or type(data) ~= "table" then return end
    if data.revive then
        Death:stop()
        return
    end
    if data.injury then
        Injury:heal()
        return
    end
end)

-- Event: On resource start, sync injuries state
AddEventHandler("onResourceStart", function(resource)
    if cache.resource ~= resource then return end
    LocalPlayer.state:set("injuries", Framework:getInjuries(), true)
end)

-- Load framework and target compatibility modules dynamically
local path = ("resource.compatibility.frameworks.%s.client"):format(Config.Framework)
lib.load(path)
local target = ("resource.compatibility.target.%s"):format(Config.Target)
lib.load(target)

-- Optionally load debug utilities
if Config.Debug then
    lib.load("resource.utils.client.coords_debug")
end

-- Localize hospitals and garage modules
local Hospitals = require("data.hospitals")
local Garage = require("resource.modules.job.client.facilities.garage")

-- Create blips and hospital zones using ox_lib zones and blip helpers
for index, hospital in pairs(Hospitals) do
    local cfg = hospital
    if cfg.blip and cfg.blip.enable then
        Utils.createBlip(cfg.blip)
    end
    lib.zones.box({
        name = 'ars_ambulancejob_hospital:' .. index,
        coords = cfg.zone.pos,
        size = cfg.zone.size,
        debug = Config.Debug,
        onEnter = function(self)
            Garage:load(cfg.garage)
        end,
        onExit = function(self)
            Garage:unload()
        end
    })
end


RegisterNetEvent("ars_ambulancejob:client:createDistressCall", function(playerName)
    if not Framework:hasJob(Config.JobName) then return end

    lib.notify({
        title = locale("notification_new_call_title"),
        description = (locale("notification_new_call_desc")):format(playerName),
        position = 'bottom-right',
        duration = 8000,
        style = {
            backgroundColor = '#1C1C1C',
            color = '#C1C2C5',
            borderRadius = '8px',
            ['.description'] = {
                fontSize = '16px',
                color = '#B0B3B8'
            },
        },
        icon = 'fas fa-truck-medical',
        iconColor = '#FEBD69'
    })
    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset")
end)


RegisterNUICallback("callEms", function(data, cb)
    Job:createDistressCall(data.msg)
    cb(true)
end)

RegisterNUICallback("respawnPlayer", function(data, cb)
    Death:stop()
    cb(true)
end)


exports("createDistressCall", function(msg)
    Job:createDistressCall(msg)
end)

RegisterCommand("distresscalls", function()
    print(json.encode(Job:getDistressCalls(), { indent = true }))
end)

RegisterCommand("distressc", function()
    Job:createDistressCall("dsad")
end)


RegisterCommand("ds", function()
    Job:openDistressCalls()
end)
