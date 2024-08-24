local useInternalClothing = lib.load("config").clothingScript
if not useInternalClothing then return end

local FreezeEntityPosition            = FreezeEntityPosition
local SetEntityInvincible             = SetEntityInvincible
local SetBlockingOfNonTemporaryEvents = SetBlockingOfNonTemporaryEvents

local function openClothingMenu(clothes)
    lib.registerContext({
        id = 'ars_ambulancejob:ems_clothing_menu',
        title = locale("clothesmenu_label"),
        options = {
            {
                title = locale('clothesmenu_civilian_label'),
                description = locale('clothesmenu_civilian_description'),
                icon = "fa-solid fa-shirt",
                onSelect = function()
                    if lib.progressBar({
                            duration = 3000,
                            label = locale("clothesmenu_civilian_use"),
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
                        Framework.toggleClothes(false, clothes)
                    end
                end,
            },
            {
                title = locale('clothesmenu_job_label'),
                description = locale('clothesmenu_job_description'),
                icon = "fa-solid fa-user-doctor",
                onSelect = function()
                    Framework.toggleClothes(true, clothes)
                end,
            },
        }
    })

    lib.showContext('ars_ambulancejob:ems_clothing_menu')
end

function initClothes(data, jobs)
    local ped = utils.createPed(data.model, data.pos)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    Target.addLocalEntity(ped, {
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
