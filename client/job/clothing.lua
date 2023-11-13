if not Config.ClothingScript then return end

local FreezeEntityPosition            = FreezeEntityPosition
local SetEntityInvincible             = SetEntityInvincible
local SetBlockingOfNonTemporaryEvents = SetBlockingOfNonTemporaryEvents

local function openClothingMenu(clothes)
    lib.registerContext({
        id = 'ems_clothing_menu',
        title = 'Clothing Menu',
        options = {
            {
                title = '🧥 Civil Clothes',
                description = 'Example button description',
                onSelect = function()
                    if lib.progressBar({
                            duration = 3000,
                            label = 'Putting on civil clothes',
                            useWhileDead = false,
                            allowCuffed = false,
                            canCancel = false,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                            },
                            anim = {
                                dict = 'clothingshirt',
                                clip = 'try_shirt_positive_d'
                            },
                        }) then
                        toggleClothes(false, clothes)
                    end
                end,
            },
            {
                title = '👮 Work Clothes',
                description = 'Example button description',
                onSelect = function()
                    if lib.progressBar({
                            duration = 3000,
                            label = 'Putting on works clothes',
                            useWhileDead = false,
                            allowCuffed = false,
                            canCancel = false,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                            },
                            anim = {
                                dict = 'clothingshirt',
                                clip = 'try_shirt_positive_d'
                            },
                        }) then
                        toggleClothes(true, clothes)
                    end
                end,
            },
        }
    })

    lib.showContext('ems_clothing_menu')
end

function initClothes(data, jobs)
    local ped = utils.createPed(data.model, data.pos[1], data.pos[2], data.pos[3], data.pos[4])

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'clothing' .. ped,
            label = locale('clothing_interact_label'),
            icon = 'fa-solid fa-road',
            groups = jobs,
            onSelect = function(entity)
                openClothingMenu(data)
            end
        }
    })
end

-- © 𝐴𝑟𝑖𝑢𝑠 𝐷𝑒𝑣𝑒𝑙𝑜𝑝𝑚𝑒𝑛𝑡
