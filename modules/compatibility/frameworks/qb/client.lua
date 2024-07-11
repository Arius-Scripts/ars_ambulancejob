local QBCore = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil

if not QBCore then return end

Framework = {}
local ox_inventory = Config.UseOxInventory and exports.ox_inventory


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    player.loaded = true
    Wait(3000)
    onPlayerLoaded()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    player.loaded = false
    player.isDead = false
end)

function Framework.toggleClothes(toggle, clothes)
    if toggle then
        utils.debug("Putting on clothes")

        local playerData = QBCore.Functions.GetPlayerData()
        local gender = playerData.charinfo.gender
        local playerPed = cache.ped
        local jobGrade = Framework.getPlayerJobGrade()

        utils.debug("Job Grade " .. jobGrade)

        if Config.ClothingScript and Config.ClothingScript ~= 'core' then
            local model = exports[Config.ClothingScript]:getPedModel(playerPed)

            if model == 'mp_m_freemode_01' then
                data = clothes.male[jobGrade] or clothes.male[1]
            elseif model == 'mp_f_freemode_01' then
                data = clothes.female[jobGrade] or clothes.female[1]
            end

            utils.debug("Using " .. Config.ClothingScript)

            exports[Config.ClothingScript]:setPedProps(playerPed, {
                {
                    component_id = 0,
                    texture = data['helmet_2'],
                    drawable = data['helmet_1']
                },
            })

            exports[Config.ClothingScript]:setPedComponents(playerPed, {
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
        elseif Config.ClothingScript == 'core' then
            utils.debug("Using " .. Config.ClothingScript)

            if gender == 0 then
                TriggerEvent('qb-clothing:client:loadOutfit', { outfitData = clothes.male[jobGrade] })
            else
                TriggerEvent('qb-clothing:client:loadOutfit', { outfitData = clothes.female[jobGrade] })
            end
        end
    else
        utils.debug("Putting civil clothes")

        TriggerServerEvent('qb-clothes:loadPlayerSkin')
    end
end

function Framework.getPlayerJobGrade()
    local playerData = QBCore.Functions.GetPlayerData()
    local jobGrade = playerData.job.grade

    return type(jobGrade) == "table" and jobGrade.level or jobGrade
end

function Framework.playerJob()
    local playerData = QBCore.Functions.GetPlayerData()

    return playerData.job.name
end

function Framework.hasJob(jobs)
    local playerData = QBCore.Functions.GetPlayerData()

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
    TriggerEvent("qb-bossmenu:client:OpenMenu")
end

function Framework.healStatus()
    local playerData = QBCore.Functions.GetPlayerData()

    TriggerServerEvent('consumables:server:addHunger', playerData.metadata.hunger + 100000)
    TriggerServerEvent('consumables:server:addThirst', playerData.metadata.hunger + 100000)
end

function Framework.hasItem(item, _quantity)
    local quantity = _quantity or 1
    if ox_inventory then
        return ox_inventory:Search('count', item) >= quantity
    end
    local playerData = QBCore.Functions.GetPlayerData()
    local playerInventory = playerData.items

    for _, v in pairs(playerInventory) do
        if v.name == item and v.amount >= quantity then return true end
    end

    return false
end

function Framework.playerSpawned()
end
