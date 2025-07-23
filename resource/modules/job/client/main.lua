local Job = lib.class("job")


function Job:createDistressCall(msg)
    if not msg or type(msg) ~= "string" then return end

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

return Job
