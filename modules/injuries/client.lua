local TriggerServerEvent   = TriggerServerEvent
local GetPedLastDamageBone = GetPedLastDamageBone

local useOxInventory       = lib.load("config").useOxInventory
local consumeItemPerUse    = lib.load("config").consumeItemPerUse
local function checkInjuryCause(cause)
    local item = "bandage"

    if cause == "beaten" then
        item = "icepack"
    elseif cause == "stabbed" then
        item = "suturekit"
    elseif cause == "shot" then
        item = "tweezers"
    elseif cause == "fire" then
        item = "burncream"
    end


    utils.debug(item, cause)

    local hasItem = Framework.hasItem(item)
    if not hasItem then return utils.showNotification(locale("not_enough_" .. item)) end

    if useOxInventory then
        local itemDurability = utils.getItem(item)?.metadata?.durability

        if itemDurability then
            if itemDurability < consumeItemPerUse then
                utils.showNotification(locale("no_durability"))
                return false
            end
        end
    end

    utils.useItem(item, consumeItemPerUse)

    return true
end


function checkInjuries(data)
    local injuries = {}

    utils.debug(data.injuries)

    if not data.injuries or not next(data.injuries) then
        injuries[#injuries + 1] = {
            title = locale('no_injuries'),
        }
    else
        for _, v in pairs(data.injuries) do
            injuries[#injuries + 1] = {
                title = v.label,
                description = v.desc,

                arrow = true,
                onSelect = function()
                    lib.registerContext({
                        id = 'ars_ambulancejob:patient_injury',
                        title = v.label,
                        menu = "patient_injuries",
                        options = {
                            {
                                title = locale("injury_value"),
                                progress = v.value,
                                metadata = { v.value .. "%" },
                            },
                            {
                                title = locale("injury_cause"),
                                description = locale(v.cause),
                            },
                            {
                                title = locale("injury_treat"),
                                onSelect = function()
                                    if checkInjuryCause(v.cause) then
                                        if lib.progressBar({
                                                duration = 2000 * (v.value / 10),
                                                label = locale("treating_injury"),
                                                useWhileDead = false,
                                                canCancel = true,
                                                disable = {
                                                    car = true,
                                                    move = true
                                                },
                                                anim = {
                                                    scenario = "CODE_HUMAN_MEDIC_TEND_TO_DEAD"
                                                }

                                            })
                                        then
                                            local dataToSend = {}
                                            dataToSend.targetServerId = data.target
                                            dataToSend.injury = true
                                            dataToSend.bone = v.bone
                                            TriggerServerEvent("ars_ambulancejob:healPlayer", dataToSend)

                                            utils.addRemoveItem("add", "money", (100 * (v.value / 10)))

                                            utils.showNotification(locale("injury_treated"))
                                            utils.debug("Injury treated " .. dataToSend.bone)
                                        else
                                            utils.showNotification(locale("operation_canceled"))
                                        end
                                    end
                                end

                            }
                        }
                    })

                    lib.showContext("ars_ambulancejob:patient_injury")
                end
            }
        end
    end

    lib.registerContext({
        id = 'ars_ambulancejob:patient_injuries',
        title = locale("injury_menu_title"),
        menu = "check_patient",
        options = injuries
    })

    lib.showContext('ars_ambulancejob:patient_injuries')
end

function treatInjury(bone)
    if not player.injuries[bone] then return end -- secure check

    player.injuries[bone] = nil
    LocalPlayer.state:set("injuries", player.injuries, true)

    local playerHealth = GetEntityHealth(cache.ped)
    local playerMaxHealth = GetEntityMaxHealth(cache.ped)
    local newHealth = math.min(playerHealth + 10, playerMaxHealth)

    utils.debug("current", playerHealth)
    utils.debug("max", playerMaxHealth)
    utils.debug("new", newHealth, type(newHealth))

    SetEntityHealth(cache.ped, newHealth)
end

local bodyParts = lib.load("data.body_parts")
local weapons = lib.load("data.weapons")
function updateInjuries(victim, weapon)
    local found, lastDamagedBone = GetPedLastDamageBone(victim)

    local damagedBone = bodyParts[tostring(lastDamagedBone)]

    utils.debug("Damaged bone ", lastDamagedBone, damagedBone.label)

    if damagedBone then
        if not player.injuries[damagedBone.id] then
            player.injuries[damagedBone.id] = { bone = damagedBone.id, label = damagedBone.label, desc = damagedBone.levels["default"], value = player.isDead and 100 or 10, cause = weapons[weapon] and weapons[weapon][2] or "not found" }
        else
            local newVal = math.min(player.injuries[damagedBone.id].value + 10, 100)
            player.injuries[damagedBone.id].value = newVal
            player.injuries[damagedBone.id].desc = damagedBone.levels[tostring(newVal)] or damagedBone.levels["default"]
        end

        LocalPlayer.state:set("injuries", player.injuries, true)
    end
end
