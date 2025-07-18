local BONES            = require("data.body_parts")
local WEAPONS          = require("data.weapons")
local Injuries         = lib.class("injuries")

local bloodLvl         = 5000
local bleedingStartLvl = 50
local injuryTimestamps = {}
local bleedingTimer    = 0

local function applyBleedingEffects(ped, blood)
    if blood then
        ApplyPedBloodSpecific(ped, blood.component, blood.u, blood.v, 0.0, 1.0, -1, 0.0, "BasicSlash")
    end
end

local function createInjuryData(bone, weapon)
    local data = lib.table.deepclone(bone)
    data.cause = WEAPONS[weapon] and WEAPONS[weapon].cause or "N/A"
    data.shouldBleed = WEAPONS[weapon] and WEAPONS[weapon].bleeding or false
    data.value = (IsEntityDead(cache.ped) or data.cause == "shot") and 100 or 10
    data.description = bone.levels["default"]
    data.boneId = tostring(bone.id)
    if (data.value >= bleedingStartLvl) or data.shouldBleed then
        data.bleeding = true
        data.bleedingSeverity = math.floor(data.value / 10)
    end
    return data
end

local function updateInjuryValue(injury, bone, weapon)
    local newVal = math.min(injury.value + 10, 100)
    local shouldBleed = WEAPONS[weapon] and WEAPONS[weapon].bleeding or false

    if WEAPONS[weapon] and WEAPONS[weapon].cause == "shot" then newVal = 100 end
    injury.value = newVal
    injury.description = bone.levels[tostring(newVal)] or bone.levels["default"]

    if (newVal >= bleedingStartLvl) or shouldBleed then
        injury.bleedingSeverity = (injury.bleedingSeverity or 0) + 1
        if not injury.bleeding then
            injury.bleeding = true
            applyBleedingEffects(cache.ped, bone.blood)
        end
    end
end

function Injuries:set(injuries)
    if type(injuries) ~= "table" then return end
    self.injuries = {}

    for boneId, injury in pairs(injuries) do
        local data = lib.table.deepclone(injury)
        data.value = data.value or 10
        data.description = data.description or (data.levels and data.levels["default"]) or "Damaged"
        if data.value >= bleedingStartLvl then
            data.bleeding = true
            data.bleedingSeverity = math.floor(data.value / 10)
            applyBleedingEffects(cache.ped, data.blood)
        end
        self.injuries[boneId] = data
    end
end

function Injuries:update(target, weapon)
    local currentTime = GetGameTimer()
    local _, boneId = GetPedLastDamageBone(target)
    local bone = BONES[boneId]


    print(boneId, "bone id hit")

    if not bone or (injuryTimestamps[boneId] and (currentTime - injuryTimestamps[boneId] < 1000)) then return end

    self.injuries = self.injuries or {}

    if not self.injuries[bone.id] then
        self.injuries[bone.id] = createInjuryData(bone, weapon)
        applyBleedingEffects(target, bone.blood)
    else
        updateInjuryValue(self.injuries[bone.id], bone, weapon)
    end

    injuryTimestamps[boneId] = currentTime
    LocalPlayer.state:set("injuries", self.injuries, true)
end

function Injuries:get()
    return self.injuries
end

function Injuries:reset()
    self.injuries = nil
end

CreateThread(function()
    local previousCoords = GetEntityCoords(cache.ped)
    local walkTimer, runTimer = 0, 0

    while true do
        local newCoords = GetEntityCoords(cache.ped)
        local distanceMoved = #(previousCoords.xy - newCoords.xy)

        if distanceMoved >= 1 and not cache.vehicle then
            walkTimer += 1
            if walkTimer >= 3 then
                bleedingTimer += 1
                walkTimer = 0
            end
        end

        if distanceMoved >= 3 and not cache.vehicle then
            runTimer += 1
            if runTimer >= 3 then
                bleedingTimer += 5
                runTimer = 0
            end
        end

        previousCoords = newCoords
        Wait(1000)
    end
end)

function Injuries:bleedThread()
    CreateThread(function()
        while true do
            if self.injuries then
                for _, injury in pairs(self.injuries) do
                    if injury.bleeding and injury.bleedingSeverity then
                        bleedingTimer += 1
                        if bleedingTimer >= 30 then
                            ApplyDamageToPed(cache.ped, injury.bleedingSeverity * 8, false)
                            lib.notify({
                                title = 'Medical',
                                position = "top-center",
                                description = 'Your losing blood form your ' .. injury.label,
                                type = 'info'
                            })
                            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.02)
                            bloodLvl = bloodLvl - (100 * injury.bleedingSeverity)

                            if bloodLvl <= 3000 then
                                lib.notify({
                                    title = 'Medical',
                                    position = "top-center",
                                    description = "You have lost alot of blood got to a doctor",
                                    type = 'info'
                                })
                                DoScreenFadeOut(1000)
                                Wait(800)
                                DoScreenFadeIn(1000)
                            end
                            bleedingTimer = 0
                        end
                    end
                end
            end
            Wait(1000)
        end
    end)

    CreateThread(function()
        while true do
            local sleep = 1000
            if self.injuries then
                for _, injury in pairs(self.injuries) do
                    if injury.bleeding then
                        sleep = 0
                        local coords = GetPedBoneCoords(cache.ped, injury.boneId, 0.0, 0.0, 0.0)

                        Utils.drawText3D(coords, "Bleeding 🩸", 0.2, 0)
                    end
                end
            end
            Wait(sleep)
        end
    end)
end

Injuries:bleedThread()

RegisterCommand("inj", function()
    Injuries:update(cache.ped, -1553120962)
end)



return Injuries
