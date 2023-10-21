player = {}
player.injuries = {}
local hospitals = {}


-- LocalPlayer.state:set("injuries", {}, true)


-- to remember

-- player.bleeding (to see if player is bleeding)
-- player.bleedingTime (to see from how much time he is bleeding)
-- player.lastBleedTime (to get the previuos bleeding time value before updating)


local function createZones()
    for index, hospital in pairs(Config.Hospitals) do
        local cfg = hospital

        if cfg.blip.enable then
            utils.createBlip(cfg.blip)
        end

        hospitals[#hospitals + 1] = lib.zones.box({
            name = 'ars_hospital:' .. index,
            coords = cfg.zone.pos,
            size = cfg.zone.size,
            rotation = 0.0,
            onEnter = function(self)

            end,
            onExit = function(self)

            end
        })
    end
end


CreateThread(createZones)
