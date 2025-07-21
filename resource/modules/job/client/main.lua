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
end

return Job
