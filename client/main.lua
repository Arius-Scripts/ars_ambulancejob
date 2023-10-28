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


Citizen.CreateThread(function()
    for _, hospital in pairs(Config.Hospitals) do
        for name, pharmacy in pairs(hospital.pharmacy) do
            if pharmacy.blip.enable then
                utils.createBlip(pharmacy.blip)
            end

            lib.points.new({
                coords = pharmacy.pos,
                distance = 5,
                onEnter = function(self)
                    self.access = hasJob(Config.EmsJobs)
                end,
                nearby = function(self)
                    if self.access then
                        DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 200, 20, 20, 50, false, true, 2, false, nil, nil, false)

                        if self.currentDistance < 1 and IsControlJustReleased(0, 38) then
                            exports.ox_inventory:openInventory("shop", { type = name })
                        end
                    end
                end
            })
        end
    end
end)
