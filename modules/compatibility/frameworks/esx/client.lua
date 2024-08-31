local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

Framework = {}
local useOxInventory = lib.load("config").useOxInventory
local ox_inventory = useOxInventory and exports.ox_inventory

AddEventHandler('esx:onPlayerSpawn', function(playerData)
    Wait(1000)
    onPlayerLoaded()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
    player.isDead = false
end)

local clothingScript = lib.load("config").clothingScript
function Framework.toggleClothes(toggle, clothes)
    if toggle then
        utils.debug("Putting on clothes")

        local playerData = ESX.GetPlayerData()
        local playerPed = cache.ped
        local jobGrade = playerData.job.grade

        utils.debug("Job Grade " .. jobGrade)

        if clothingScript and clothingScript ~= 'core' then
            local model = exports[clothingScript]:getPedModel(playerPed)

            if model == 'mp_m_freemode_01' then
                data = clothes.male[jobGrade] or clothes.male[1]
            elseif model == 'mp_f_freemode_01' then
                data = clothes.female[jobGrade] or clothes.female[1]
            end
            local outfits = {}
            local selected = false

            for outfitName, outfit in pairs(data) do
                outfits[#outfits + 1] = {
                    title = outfitName,
                    icon = 'fa-solid fa-shirt',
                    onSelect = function()
                        data = outfit
                        selected = true
                    end,
                }
            end

            lib.registerContext({
                id = 'ars_ambulancejob:police_outfits',
                title = locale("police_outfits_title"),
                options = outfits
            })
            lib.showContext('ars_ambulancejob:police_outfits')

            while not selected do Wait(500) end
            utils.debug("Using " .. clothingScript)

            lib.progressBar({
                duration = 3000,
                label = locale("clothesmenu_job_use"),
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
            })

            exports[clothingScript]:setPedProps(playerPed, {
                {
                    component_id = 0,
                    texture = data['helmet_2'],
                    drawable = data['helmet_1']
                },
            })

            exports[clothingScript]:setPedComponents(playerPed, {
                {
                    component_id = 1,
                    texture = data['mask_2'],
                    drawable = data['mask_1']
                },
                {
                    component_id = 3,
                    texture = 0,
                    drawable = data['arms']
                },
                {
                    component_id = 8,
                    texture = data['tshirt_2'],
                    drawable = data['tshirt_1']
                },
                {
                    component_id = 11,
                    texture = data['torso_2'],
                    drawable = data['torso_1']
                },
                {
                    component_id = 9,
                    texture = data['bproof_2'],
                    drawable = data['bproof_1']
                },
                {
                    component_id = 10,
                    texture = data['decals_2'],
                    drawable = data['decals_1']
                },
                {
                    component_id = 7,
                    texture = data['chain_2'],
                    drawable = data['chain_1']
                },
                {
                    component_id = 4,
                    texture = data['pants_2'],
                    drawable = data['pants_1']
                },
                {
                    component_id = 6,
                    texture = data['shoes_2'],
                    drawable = data['shoes_1']
                },
                {
                    component_id = 5,
                    texture = data['bag_color'],
                    drawable = data['bag']
                },
            })
        elseif clothingScript == 'core' then
            utils.debug("Using " .. clothingScript)
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                local gender = skin.sex
                if gender == 0 then
                    data = clothes.male[jobGrade] or clothes.male[1]
                else
                    data = clothes.female[jobGrade] or clothes.female[1]
                end

                local outfits = {}
                local selected = false

                for outfitName, outfit in pairs(data) do
                    outfits[#outfits + 1] = {
                        title = outfitName,
                        icon = 'fa-solid fa-shirt',
                        onSelect = function()
                            data = outfit
                            selected = true
                        end,
                    }
                end

                lib.registerContext({
                    id = 'ars_ambulancejob:police_outfits',
                    title = locale("police_outfits_title"),
                    options = outfits
                })
                lib.showContext('ars_ambulancejob:police_outfits')

                while not selected do Wait(500) end

                lib.progressBar({
                    duration = 3000,
                    label = locale("clothesmenu_job_use"),
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
                })

                TriggerEvent('skinchanger:loadClothes', skin, data)
            end)
        end
    else
        utils.debug("Putting civil clothes")

        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
            TriggerEvent('skinchanger:loadSkin', skin)
            TriggerEvent('esx:restoreLoadout')
        end)
    end
end

function Framework.getPlayerJobGrade()
    local playerData = ESX.GetPlayerData()
    local jobGrade = playerData.job.grade

    return jobGrade
end

function Framework.playerJob()
    local playerData = ESX.GetPlayerData()

    return playerData.job.name
end

function Framework.hasJob(jobs)
    local playerData = ESX.GetPlayerData()

    if type(jobs) == "table" then
        for index, jobName in pairs(jobs) do
            if playerData.job.name == jobName then return true end
        end
    else
        return playerData.job.name == jobs
    end

    return false
end

function Framework.openBossMenu(job)
    TriggerEvent('esx_society:openBossMenu', job, function(data, menu) end, { wash = false })
end

function Framework.healStatus()
    TriggerEvent('esx_status:add', "hunger", 1000000)
    TriggerEvent('esx_status:add', "thirst", 1000000)
end

function Framework.playerSpawned()
    TriggerEvent('esx_basicneeds:resetStatus')
    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned')
end

function Framework.hasItem(item, _quantity)
    local quantity = _quantity or 1
    if ox_inventory then
        return ox_inventory:Search('count', item) >= quantity
    end

    local playerData = ESX.GetPlayerData()
    local playerInventory = playerData.inventory

    for _, v in pairs(playerInventory) do
        if v.name == item and v.count >= quantity then return true end
    end

    return false
end
