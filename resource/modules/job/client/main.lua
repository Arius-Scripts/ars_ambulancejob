local Job = lib.class("job")

function Job:createDistressCall(msg)
    if not msg or type(msg) ~= "string" then return end

    Config.sendDistressCall(msg)

    local data = {}
    local playerCoords = GetEntityCoords(cache.ped)
    local current, crossing = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)

    data.msg = msg
    data.coords = playerCoords
    data.streetName = GetStreetNameFromHashKey(current)

    local success = lib.callback.await("ars_ambulancejob:cb:server:createDistressCall", false, data)
    if not success then return Utils.showNotification(locale("distresscall_cooldown")) end

    Utils.showNotification(locale("distresscall_success"))
end

function Job:getDistressCalls()
    return GlobalState.distressCalls
end

function Job:openDistressCalls()
    local playerPed = cache.ped
    local playerCoords = GetEntityCoords(playerPed)

    local distressCalls = Job:getDistressCalls()

    local calls = {}

    local dict = lib.requestAnimDict("amb@world_human_tourist_map@male@base")
    local model = lib.requestModel("prop_cs_tablet")

    TaskPlayAnim(playerPed, dict, "base", 2.0, 2.0, -1, 51, 0, false, false, false)

    local tablet = CreateObject(model, playerCoords.x, playerCoords.y, playerCoords.z + 0.2, true, true, true)
    AttachEntityToEntity(tablet, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true, false, true, 1, true)

    for i = 1, #distressCalls do
        local call = distressCalls[i]

        Utils.debug(call)

        calls[#calls + 1] = {
            title       = call.name,
            description = call.msg,
            icon        = "fa-truck-medical",
            iconColor   = "#FEBD69",
            arrow       = true,
            onSelect    = function()
                lib.registerContext({
                    id      = "ars_ambulancejob:openCall",
                    title   = call.name,
                    menu    = "ars_ambulancejob:openDistressCalls",
                    options = {
                        {
                            title       = call.msg,
                            icon        = "fa-info-circle",
                            iconColor   = "#0077FF",
                            readOnly    = true,
                            description = locale("tablet_call_desc")
                        },
                        {
                            title       = call.time,
                            icon        = "fa-clock",
                            iconColor   = "FF7F8489",
                            readOnly    = true,
                            description = locale("tablet_call_time")
                        },
                        {
                            title       = call.streetName,
                            icon        = "fa-map-pin",
                            iconColor   = "#FFA500",
                            arrow       = true,
                            description = locale("tablet_call_waypoint_desc"),

                            onSelect    = function()
                                SetNewWaypoint(call.coords.x, call.coords.y)
                                Utils.showNotification(locale("tablet_call_waypoint_notification"))
                                ClearPedTasks(playerPed)
                                DeleteEntity(tablet)
                            end
                        },
                        {
                            title       = locale("tablet_call_resolved_title"),
                            icon        = "fa-check",
                            iconColor   = "#32CD32",
                            arrow       = true,
                            description = locale("tablet_call_resolved_desc"),
                            onSelect    = function()
                                TriggerServerEvent("ars_ambulancejob:server:callCompleted", i)
                                Utils.showNotification(locale("tablet_call_resolved_notification"))
                                ClearPedTasks(playerPed)
                                DeleteEntity(tablet)
                            end
                        },
                    }
                })
                lib.showContext("ars_ambulancejob:openCall")
            end
        }
    end

    lib.registerContext({
        id      = 'ars_ambulancejob:openDistressCalls',
        title   = "Calls",
        onExit  = function()
            ClearPedTasks(playerPed)
            DeleteEntity(tablet)
        end,
        options = calls
    })
    lib.showContext('ars_ambulancejob:openDistressCalls')
end

RegisterNetEvent("ars_ambulancejob:client:createDistressCall", function(playerName)
    if not Framework:hasJob(Config.JobName) then return end

    lib.notify({
        title = locale("notification_new_call_title"),
        description = (locale("notification_new_call_desc")):format(playerName),
        position = 'bottom-right',
        duration = 8000,
        style = {
            backgroundColor = '#1C1C1C',
            color = '#C1C2C5',
            borderRadius = '8px',
            ['.description'] = {
                fontSize = '16px',
                color = '#B0B3B8'
            },
        },
        icon = 'fas fa-truck-medical',
        iconColor = '#FEBD69'
    })
    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset")
end)


RegisterNUICallback("sendDistressCall", function(data, cb)
    Job:createDistressCall(data.msg)
    cb(true)
end)

exports("createDistressCall", function(msg)
    Job:createDistressCall(msg)
end)

RegisterCommand(Config.EmsCommand, function(source, args, rawCommand)
    local input = lib.inputDialog(locale("distress_call_form_title"), {
        { type = 'input', label = locale("distress_call_form_label"), description = locale("distress_call_form_desc"), required = true },
    })
    if not input then return end

    local msg = input[1]

    Job:createDistressCall(msg)
end)

----------------
--[ End Distresscalls ]--
----------------

local function openMedicalBag()
    local playerPed = cache.ped

    TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD")

    if not Config.UseOxInventory then
        return false
    end

    lib.callback('ars_ambulancejob:openMedicalBag', false, function(stash)
        exports.ox_inventory:openInventory("stash", stash)
    end)
end

function Job:placeMedicBag()
    lib.requestAnimDict("pickup_object")
    lib.requestModel(Config.MedicBagProp)

    local playerPed = cache.ped or PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)

    TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, 8.0, 1000, 50, 0, false, false, false)

    Wait(900)

    local medicBag = CreateObjectNoOffset(Config.MedicBagProp, coords.x, coords.y, coords.z, true, false)
    PlaceObjectOnGroundProperly(medicBag)

    -- utils.addRemoveItem("remove", "medicalbag", 1)

    Target.addLocalEntity(medicBag, {
        {
            label = locale('open_medical_bag'),
            icon = 'fa-solid fa-suitcase',
            groups = false,
            fn = function()
                -- TODO
                if not Config.UseOxInventory then
                    return print("ONLY AVAILABLE FOR OX INVENTORY FOR NOW")
                end

                openMedicalBag()
            end
        },
        {
            label = locale('pickup_medical_bag'),
            icon = 'fa-solid fa-xmark',
            groups = false,
            fn = function(data)
                TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, 8.0, 1000, 50, 0, false, false, false)

                Wait(900)
                DeleteEntity(type(data) == "number" and data or data.entity)
                ClearPedTasks(playerPed)

                utils.addRemoveItem("add", "medicalbag", 1)
            end
        },
    })
end

RegisterNetEvent("ars_ambulancejob:client:placeMedicBag", function()
    if not Framework.hasJob(Cofnig.JobName) then return end

    Job:placeMedicBag()
end)

RegisterCommand("mdi", function(source, args, rawCommand)
    Job:placeMedicBag()
end)


----------------
--[ End Medic Bag ]--
----------------
---
local Hospitals = require("data.hospitals")

for index, hospital in pairs(Hospitals) do
    Target.addBoxZone(hospital.bossmenu.pos, {
        {
            name = "open_bossmenu" .. index,
            icon = 'fa-solid fa-road',
            label = locale("bossmenu_label"),
            groups = Config.JobName,
            fn = function(data)
                if Framework.getPlayerJobGrade() >= hospital.bossmenu.min_grade then
                    Framework.openBossMenu(Framework.playerJob())
                else
                    print(locale("bossmenu_denied"))
                end
            end
        }
    })
end

----------------
--[ End Boss Menu ]--
----------------
