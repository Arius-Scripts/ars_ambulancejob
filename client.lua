local DoesEntityExist = DoesEntityExist
local DeletePed       = DeletePed
local CreateThread    = CreateThread

player                = {}
player.injuries       = {}
local hospitals       = {}

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
            debug = Config.Debug,
            rotation = 0.0,
            onEnter = function(self)
                initGarage(cfg.garage, Config.EmsJobs)

                if self.clothes then
                    initClothes(self.clothes, Config.EmsJobs)
                end

                initParamedic()
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

-- © 𝐴𝑟𝑖𝑢𝑠 𝐷𝑒𝑣𝑒𝑙𝑜𝑝𝑚𝑒𝑛𝑡
