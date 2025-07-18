RegisterNetEvent("ars_ambulancejob:server:playerDied", function(data)
    local source = source
    Player(source).state:set("isDead", true)

    Framework:playerDied(source, true)
end)
