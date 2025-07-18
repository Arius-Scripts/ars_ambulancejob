local Injuries = require "resource.modules.injuries.client"
local Death = lib.class("death")


if Config.UseLaststand then
    local anims = {
        standby = { "random@dealgonewrong", "idle_a" },
        forward = { "move_injured_ground", "sidel_loop" },
        backward = { "move_injured_ground", "back_loop" },
    }

    lib.requestAnimDict(anims.forward[1])
    lib.requestAnimDict(anims.standby[1])

    function Death:knocked(weapon)
        local playerPed = cache.ped
        local coords = GetEntityCoords(playerPed)

        Death:disableKeybinds(false)

        ClearPedTasks(playerPed)
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed) / 2)
        SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, false, false, false)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(playerPed), false, false)

        TaskPlayAnim(playerPed, anims.standby[1], anims.standby[2], 8.0, -8.0, -1, 0, 0, 0, 0, 0)

        local allowedControls = { 245, 1, 2, 6, 5, 33, 32, 175, 174, 18 }
        CreateThread(function()
            while self.deathState == "knocked" do
                DisableAllControlActions(0)
                DisableAllControlActions(1)
                DisableAllControlActions(28)

                for _, control in ipairs(allowedControls) do
                    EnableControlAction(0, control, true)
                end

                local camRot = GetGameplayCamRot(2)
                SetEntityHeading(playerPed, camRot.z)

                if not self.moving then
                    if not IsEntityPlayingAnim(playerPed, anims.standby[1], anims.standby[2], 3) then
                        TaskPlayAnim(playerPed, anims.standby[1], anims.standby[2], 2.0, -8.0, -1, 0, 0, 0, 0, 0)
                    end
                end
                Wait(0)
            end

            StopAnimTask(playerPed, anims.backward[1], "back_loop", 1.0)
            StopAnimTask(playerPed, anims.forward[1], "sidel_loop", 1.0)
        end)

        local progress = lib.progressCircle({
            position = "bottom",
            duration = 5000,
            label = "Bleeding out",
        })

        if progress then Death:init(weapon, "dead") end
    end

    function Death:createMovementKeybind(name, description, defaultKey, animDict, animName)
        local keybind = lib.addKeybind({
            name = name,
            description = description,
            defaultKey = defaultKey,
            onPressed = function(keybindSelf)
                if not self.deathState or self.deathState ~= "knocked" then return end
                self.moving = true
                if not IsEntityPlayingAnim(cache.ped, animDict, animName, 3) then
                    TaskPlayAnim(cache.ped, animDict, animName, 1.0, -8.0, -1, 1, 0, 0, 0, 0)
                end
            end,
            onReleased = function(keybindSelf)
                if not self.deathState or self.deathState ~= "knocked" then return end
                self.moving = false
                StopAnimTask(cache.ped, animDict, animName, 1.0)
            end
        })

        if not self.keybinds then self.keybinds = {} end
        self.keybinds[#self.keybinds + 1] = keybind
    end

    Death:createMovementKeybind('ars_ambulancejob:keybind:move_forward', 'Press W to move forward', 'W', anims.forward[1], anims.forward[2])
    Death:createMovementKeybind('ars_ambulancejob:keybind:move_backwards', 'Press S to move backwards', 'S', anims.backward[1], anims.backward[2])

    function Death:disableKeybinds(state)
        if self.keybinds then
            for i = 1, #self.keybinds do
                local keybind = self.keybinds[i]
                keybind:disable(state)
            end
        end
    end
end
function Death:init(weapon, state)
    if self.deathState and self.deathState == state then return end
    self.deathState = state
    if lib.progressActive() then lib.cancelProgress() end

    if state == "knocked" then
        return Death:knocked(weapon)
    end
    -- if (IsEntityDead(cache.ped) or IsPedDeadOrDying(cache.ped, true) or IsPedFatallyInjured(cache.ped)) then return end

    SetEntityHealth(cache.ped, 0)
    Death:disableKeybinds(true)

    Wait(1000)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "deathScreen",
        data = true
    })

    local data = {
        weapon = weapon,
    }
    TriggerServerEvent("ars_ambulancejob:server:playerDied", data)
end

function Death:stop()
    local playerPed = cache.ped
    if not IsEntityDead(playerPed) then return end

    SendNUIMessage({
        action = "deathScreen",
        data = false
    })
    SetNuiFocus(false, false)


    local coords = GetEntityCoords(playerPed)

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.w, false, false)
    ClearPedBloodDamage(playerPed)
    SetEntityInvincible(playerPed, false)
    SetEveryoneIgnorePlayer(cache.playerId, false)
    ClearPedTasks(playerPed)
    AnimpostfxStopAll()

    TaskPlayAnim(playerPed, Config.Animations["get_up"].dict, Config.Animations["get_up"].clip, 8.0, -8.0, -1, 0, 0, 0, 0, 0)

    Wait(100) -- wait for anim to play
    while IsEntityPlayingAnim(playerPed, Config.Animations["get_up"].dict, Config.Animations["get_up"].clip, 3) do Wait(100) end

    Injuries:reset()
    LocalPlayer.state.deathState = nil
    self.deathState = nil
    Death:disableKeybinds(true)
end

RegisterCommand("r", function(source, args, rawCommand)
    Death:stop()
end)

return Death
