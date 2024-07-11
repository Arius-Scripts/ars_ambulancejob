local DrawMarker            = DrawMarker
local IsControlJustReleased = IsControlJustReleased
local CreateThread          = CreateThread
local useOxInventory        = lib.load("config").useOxInventory
local ox_inventory          = useOxInventory and exports.ox_inventory
local hospitals             = lib.load("data.hospitals")
local emsJobs               = lib.load("config").emsJobs

local function createShops()
    for _, hospital in pairs(hospitals) do
        for name, pharmacy in pairs(hospital.pharmacy) do
            if pharmacy.blip.enable then
                utils.createBlip(pharmacy.blip)
            end

            lib.points.new({
                coords = pharmacy.pos,
                distance = 3,
                onEnter = function(self)
                    if pharmacy.job then
                        if Framework.hasJob(emsJobs) and Framework.getPlayerJobGrade() >= pharmacy.grade then
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
                            if ox_inventory then
                                return ox_inventory:openInventory("shop", { type = name })
                            end


                            local items = {}

                            for i = 1, #pharmacy.items do
                                local item = pharmacy.items[i]
                                items[#items + 1] = {
                                    title = item.label,
                                    description = "Price: " .. item.price,
                                    icon = item.icon,
                                    onSelect = function()
                                        local amount = lib.inputDialog(locale("pharmacy_buying_quantity_title"), {
                                            { type = 'number', label = locale("pharmacy_buying_quantity"), icon = 'hashtag' },
                                        })
                                        if not amount then return end

                                        local quantity = amount[1]
                                        local totalPrice = item.price * quantity

                                        local hasMoney = Framework.hasItem("money", totalPrice)
                                        if not hasMoney then return utils.showNotification(locale("not_enough_money")) end

                                        utils.addRemoveItem("remove", "money", totalPrice)
                                        utils.addRemoveItem("add", item.name, quantity)
                                    end,
                                }
                            end



                            lib.registerContext({
                                id = name,
                                title = pharmacy.label,
                                options = items
                            })
                            lib.showContext(name)
                        end
                    end
                end
            })
        end
    end
end
CreateThread(createShops)
