player = {}
player.injuries = {}
local hospitals = {}


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
            clothes = Config.ClothingScript and cfg.clothes,
            rotation = 0.0,
            onEnter = function(self)
                initGarage(cfg.garage, Config.EmsJobs)

                if self.clothes then
                    initClothes(self.clothes, Config.EmsJobs)
                end
            end,
            onExit = function(self)
                for k, v in pairs(peds) do
                    if DoesEntityExist(v) then
                        DeletePed(v)
                    end
                end
            end
        })
    end
end


CreateThread(createZones)


CreateThread(function()
    for _, hospital in pairs(Config.Hospitals) do
        for name, pharmacy in pairs(hospital.pharmacy) do
            if pharmacy.blip.enable then
                utils.createBlip(pharmacy.blip)
            end

            lib.points.new({
                coords = pharmacy.pos,
                distance = 5,
                onEnter = function(self)
                    if pharmacy.job then
                        if hasJob(Config.EmsJobs) and getPlayerJobGrade() >= pharmacy.grade then
                            self.access = true
                        else
                            self.access = false
                        end
                    else
                        self.access = true
                    end
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
