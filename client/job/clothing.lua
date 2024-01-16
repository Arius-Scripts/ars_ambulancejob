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
    local ped = utils.createPed(data.model, data.pos)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    addLocalEntity(ped, {
        {
            label = locale('clothing_interact_label'),
            icon = 'fa-solid fa-road',
            groups = jobs,
            fn = function()
                openClothingMenu(data)
            end
        }
    })
end

-- © 𝐴𝑟𝑖𝑢𝑠 𝐷𝑒𝑣𝑒𝑙𝑜𝑝𝑚𝑒𝑛𝑡
