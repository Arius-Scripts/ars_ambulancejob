-- Refactored: Improved local scoping, require/lib.load usage, nil-safety, ox_lib conventions, and code organization.
-- Comments added to explain changes and fixes.

-- Localize all dependencies and avoid polluting global scope
local Death = require("resource.modules.death.client")
local Injury = require("resource.modules.injuries.client")
lib.load("resource.utils.client.utils")

local Framework = lib.class("framework")

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
