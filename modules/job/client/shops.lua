local DrawMarker            = DrawMarker
local IsControlJustReleased = IsControlJustReleased
local CreateThread          = CreateThread

local function createShops()
    for _, hospital in pairs(Config.Hospitals) do
        for name, pharmacy in pairs(hospital.pharmacy) do
            if pharmacy.blip.enable then
                utils.createBlip(pharmacy.blip)
            end

            lib.points.new({
                coords = pharmacy.pos,
                distance = 3,
                onEnter = function(self)
                    if pharmacy.job then
                        if hasJob(Config.EmsJobs) and getPlayerJobGrade() >= pharmacy.grade then
                            self.access = true
                            lib.showTextUI(locale('control_to_open_shop'))
                        else
                            self.access = false
                        end
                    else
                        self.access = true
                        lib.showTextUI(locale('control_to_open_shop'))
                    end
                end,
                onExit = function()
                    lib.hideTextUI()
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
end
CreateThread(createShops)

-- © 𝐴𝑟𝑖𝑢𝑠 𝐷𝑒𝑣𝑒𝑙𝑜𝑝𝑚𝑒𝑛𝑡
