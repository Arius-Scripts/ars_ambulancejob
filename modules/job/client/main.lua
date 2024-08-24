local GetPlayerServerId            = GetPlayerServerId
local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
local PlayerPedId                  = PlayerPedId
local GetEntityHeading             = GetEntityHeading
local GetEntityForwardVector       = GetEntityForwardVector
local GetGameTimer                 = GetGameTimer
local GetEntityCoords              = GetEntityCoords
local GetStreetNameAtCoord         = GetStreetNameAtCoord
local GetStreetNameFromHashKey     = GetStreetNameFromHashKey
local TriggerServerEvent           = TriggerServerEvent
local CreateThread                 = CreateThread
local CreateObject                 = CreateObject
local AttachEntityToEntity         = AttachEntityToEntity
local SetNewWaypoint               = SetNewWaypoint
local ClearPedTasks                = ClearPedTasks
local DeleteEntity                 = DeleteEntity
local TaskPlayAnim                 = TaskPlayAnim
local PlaySound                    = PlaySound
local SetEntityVisible             = SetEntityVisible
local SetEntityInvincible          = SetEntityInvincible
local TriggerEvent                 = TriggerEvent
local SetCurrentPedWeapon          = SetCurrentPedWeapon

local weapons                      = lib.load("data.weapons")
local useOxInventory               = lib.load("config").useOxInventory
local consumeItemPerUse            = lib.load("config").consumeItemPerUse

local function checkPatient(target)
    local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(target))
    local data = lib.callback.await('ars_ambulancejob:getData', false, targetServerId)
    local isDead = data.status.isDead
    local status = isDead and locale("patient_not_conscious") or locale("patient_conscious")

    utils.debug(data)

    lib.progressBar({
        duration = 3000,
        label = locale("checking_patient"),
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
        },
    })

    local options = {
        {
            title = locale("status_patient") .. status,
            icon = 'heartbeat',
            iconColor = isDead and "#b5300b" or "#5b87b0",
            readOnly = true,
        },

        {
            title = locale("check_injuries"),
            description = locale("check_injuries_desc"),
            icon = 'user-injured',
            onSelect = function()
                local passData = {}
                passData.target = targetServerId
                passData.injuries = data.injuries

                checkInjuries(passData)
            end,
        }
    }

    if isDead then
        options[#options + 1] = {
            title = locale("revive_patient"),
            description = locale("revive_patient_desc"),
            icon = 'medkit',
            iconColor = "#5BC0DE",
            onSelect = function()
                local hasItem = Framework.hasItem("defibrillator")
                if not hasItem then return utils.showNotification(locale("not_enough_defibrillator")) end

                if useOxInventory then
                    local itemDurability = utils.getItem("defibrillator")?.metadata?.durability

                    if itemDurability then
                        if itemDurability < consumeItemPerUse then return utils.showNotification(locale("no_durability")) end
                    end
                end

                local playerPed = cache.ped or PlayerPedId()
                local playerHeading = GetEntityHeading(playerPed)
                local playerLocation = GetEntityForwardVector(playerPed)
                local playerCoords = GetEntityCoords(playerPed)


                local dataToSend = {}
                dataToSend.targetServerId = targetServerId
                dataToSend.injury = false
                dataToSend.heading = playerHeading
                dataToSend.location = playerLocation
                dataToSend.coords = playerCoords
                TriggerServerEvent("ars_ambulancejob:healPlayer", dataToSend)
            end,
        }

        options[#options + 1] = {
            title = weapons[data.killedBy] and weapons[data.killedBy][1] or locale("patient_not_found"),
            readOnly = true,
            icon = 'skull',
        }
    end

    lib.registerContext({
        id = 'ars_ambulancejob:check_patient',
        title = locale("check_patient_menu_title"),
        options = options
    })
    lib.showContext('ars_ambulancejob:check_patient')
end

local timeForNewCall = lib.load("config").waitTimeForNewCall
local sendDistressCall = lib.load("config").sendDistressCall
function createDistressCall()
    if player.distressCallTime then
        local currentTime = GetGameTimer()
        utils.debug(currentTime - player.distressCallTime, 60000 * timeForNewCall)
        if currentTime - player.distressCallTime < 60000 * timeForNewCall then
            return utils.showNotification(
                locale("distress_call_in_cooldown"))
        end
    end

    local input = lib.inputDialog(locale("distress_call_form_title"), {
        { type = 'input', label = locale("distress_call_form_label"), description = locale("distress_call_form_desc"), required = true },
    })
    if not input then return end

    local msg = input[1]


    sendDistressCall(msg)

    local data = {}
    local playerCoords = cache.coords or GetEntityCoords(cache.ped)

    local current, crossing = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)

    data.msg = msg
    data.gps = playerCoords
    data.location = GetStreetNameFromHashKey(current)

    TriggerServerEvent("ars_ambulancejob:createDistressCall", data)



    player.distressCallTime = GetGameTimer()
end

local helpCommandName = lib.load("config").helpCommand

exports("createDistressCall", createDistressCall)
RegisterCommand(helpCommandName, createDistressCall)

local emsJobs = lib.load("config").emsJobs

function openDistressCalls()
    if not Framework.hasJob(emsJobs) then return end

    local playerPed = cache.ped or PlayerPedId()
    local playerCoords = cache.coords or GetEntityCoords(playerPed)

    local distressCalls = lib.callback.await('ars_ambulancejob:getDistressCalls', false)

    local calls = {}

    local dict = lib.requestAnimDict("amb@world_human_tourist_map@male@base")
    local model = lib.requestModel("prop_cs_tablet")

    TaskPlayAnim(playerPed, dict, "base", 2.0, 2.0, -1, 51, 0, false, false, false)

    local tablet = CreateObject(model, playerCoords.x, playerCoords.y, playerCoords.z + 0.2, true, true, true)
    AttachEntityToEntity(tablet, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true, false, true, 1, true)

    for i = 1, #distressCalls do
        local call = distressCalls[i]

        utils.debug(call)

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
                    menu    = "openDistressCalls",
                    options = {
                        {
                            title       = call.msg,
                            icon        = "fa-info-circle",
                            iconColor   = "#0077FF",
                            readOnly    = true,
                            description = locale("tablet_call_desc")
                        },
                        {
                            title       = call.location,
                            icon        = "fa-map-marker",
                            iconColor   = "#00CC00",
                            readOnly    = true,
                            description = locale("tablet_call_location")
                        },
                        {
                            title       = locale("tablet_call_waypoint_title"),
                            icon        = "fa-map-pin",
                            iconColor   = "#FFA500",
                            arrow       = true,
                            description = locale("tablet_call_waypoint_desc"),

                            onSelect    = function()
                                SetNewWaypoint(call.gps.x, call.gps.y)
                                utils.showNotification(locale("tablet_call_waypoint_notification"))
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
                                TriggerServerEvent("ars_ambulancejob:callCompleted", call)
                                utils.showNotification(locale("tablet_call_resolved_notification"))
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

RegisterNetEvent("ars_ambulancejob:openDistressCalls", openDistressCalls)
exports("openDistressCalls", openDistressCalls)


Target.addGlobalPlayer({
    {
        name = 'check_suspect',
        icon = 'fas fa-magnifying-glass',
        label = locale('check_patient'),
        groups = emsJobs,
        distance = 3,
        fn = function(data)
            checkPatient(type(data) == "number" and data or data.entity)
        end
    },
    {
        name = 'put_on_stretcher',
        icon = 'fas fa-magnifying-glass',
        label = locale('put_on_stretcher'),
        groups = emsJobs,
        distance = 3,
        cn = function(entity, distance, coords, name, bone)
            local _coords = GetEntityCoords(entity)
            local closestStretcher = GetClosestObjectOfType(_coords.x, _coords.y, _coords.z, 5.5, `prop_ld_binbag_01`, false)

            return closestStretcher ~= 0 and not player.isDead
        end,
        fn = function(data)
            putOnStretcher(true, type(data) == "number" and data or data.entity)
        end
    },
})

local animations = lib.load("config").animations
local reviveReward = lib.load("config").reviveReward
RegisterNetEvent("ars_ambulancejob:playHealAnim", function(data)
    local playerPed = cache.ped or PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if data.anim == "medic" then
        utils.showNotification(locale("action_revive_notification"))

        CreateThread(function()
            lib.progressBar({
                duration = 14900 + (900 * 15) + 1000,
                label = locale("reviving_patient"),
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = true,
                    move = true,
                },
            })
        end)

        lib.requestAnimDict("mini@cpr@char_a@cpr_def")
        lib.requestAnimDict("mini@cpr@char_a@cpr_str")

        TaskPlayAnim(playerPed, 'mini@cpr@char_a@cpr_def', 'cpr_intro', 8.0, 8.0, -1, 0, 0, false, false, false)

        Wait(14900)

        for i = 1, 15 do
            Wait(900)
            TaskPlayAnim(playerPed, 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest', 8.0, 8.0, -1, 0, 0, false, false, false)
        end

        Wait(1000)

        TaskPlayAnim(playerPed, animations["get_up"].dict, animations["get_up"].clip, 10.0, -10.0, -1, 0, 0, 0, 0, 0)


        utils.useItem("defibrillator", consumeItemPerUse)
        utils.addRemoveItem("add", "money", reviveReward)
    elseif data.anim == "dead" then
        utils.showNotification(locale("action_revived_notification"))

        player.gettingRevived = true

        lib.requestAnimDict('mini@cpr@char_b@cpr_str')
        lib.requestAnimDict('mini@cpr@char_b@cpr_def')

        SetEntityVisible(playerPed, false)
        Wait(250)
        SetEntityVisible(playerPed, true)

        SetEntityInvincible(playerPed, false)
        TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
        SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)

        local x, y, z = table.unpack(data.coords + data.location)

        SetEntityCoords(playerPed, x, y, z - 0.50)
        SetEntityHeading(playerPed, data.heading - 270.0)

        TaskPlayAnim(playerPed, 'mini@cpr@char_b@cpr_def', 'cpr_intro', 8.0, 8.0, -1, 0, 0, false, false, false)

        Wait(14900)

        TaskPlayAnim(playerPed, 'mini@cpr@char_b@cpr_str', 'cpr_pumpchest', 8.0, 8.0, -1, 0, 0, false, false, false)

        for i = 1, 15 do
            Wait(900)
            TaskPlayAnim(playerPed, 'mini@cpr@char_b@cpr_str', 'cpr_pumpchest', 8.0, 8.0, -1, 0, 0, false, false, false)
        end

        Wait(800)

        player.gettingRevived = false
        stopPlayerDeath()
    end
end)


RegisterNetEvent("ars_ambulancejob:createDistressCall", function(name)
    if not Framework.hasJob(emsJobs) then return end

    lib.notify({
        title = locale("notification_new_call_title"),
        description = (locale("notification_new_call_desc")):format(name),
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
