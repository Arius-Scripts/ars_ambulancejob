local function openParamedicMenu()
    lib.registerContext({
        id = 'paramedic_menu_ambulance_job',
        title = locale("paramedic_menu_title"),
        options = {
            {
                title = locale("get_treated_paramedic"),
                onSelect = function()
                    local money = exports.ox_inventory:Search("count", "money")

                    if money >= Config.ParamedicTreatmentPrice then
                        utils.addRemoveItem("remove", "money", Config.ParamedicTreatmentPrice)

                        local dict = lib.requestAnimDict("anim@gangops@morgue@table@")
                        local playerPed = cache.ped or PlayerPedId()
                        local previousCoords = cache.coords or GetEntityCoords(playerPed)
                        local nearHospital = utils.getClosestHospital()

                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do Wait(1) end

                        Wait(1000)
                        DoScreenFadeIn(300)

                        SetEntityCoords(playerPed, nearHospital.respawn.bedPoint)
                        SetEntityHeading(playerPed, nearHospital.respawn.bedPoint.w)
                        TaskPlayAnim(playerPed, dict, "body_search", 2.0, 2.0, -1, 1, 0, false, false, false)

                        print(nearHospital.respawn.spawnPoint)

                        SetEntityCoords(ped, nearHospital.respawn.spawnPoint)
                        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", -1, true)

                        lib.progressBar({ duration = 15000, label = locale("getting_treated"), useWhileDead = false, canCancel = true, disable = { car = true, move = true }, })

                        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
                        player.injuries = {}

                        SetEntityCoords(ped, hospital.paramedic.pos.xyz)
                        SetEntityHeading(ped, hospital.paramedic.pos.w)

                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do Wait(1) end

                        SetEntityCoords(playerPed, previousCoords)

                        Wait(1000)
                        DoScreenFadeIn(300)

                        utils.showNotification("treated_by_paramedic")
                        ClearPedTasks(ped)
                        ClearAreaOfObjects(hospital.paramedic.pos.xyz, 2.0, 0)
                    else
                        utils.showNotification("not_enough_money")
                    end
                end,
            }
        }
    })
    lib.showContext('paramedic_menu_ambulance_job')
end

function initParamedic()
    for index, hospital in pairs(Config.Hospitals) do
        local ped = utils.createPed(hospital.paramedic.model, hospital.paramedic.pos)

        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'paramedicGuyAmbulanceJob' .. ped,
                label = locale('paramedic_interact_label'),
                icon = 'fa-solid fa-ambulance',
                distance = 3,
                onSelect = function(data)
                    openParamedicMenu()
                end,
            }
        })
    end
end
