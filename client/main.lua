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
