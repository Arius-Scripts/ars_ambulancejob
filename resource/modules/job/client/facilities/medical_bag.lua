local TaskStartScenarioInPlace         = TaskStartScenarioInPlace
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local TaskPlayAnim                     = TaskPlayAnim
local Wait                             = Wait
local CreateObjectNoOffset             = CreateObjectNoOffset
local PlaceObjectOnGroundProperly      = PlaceObjectOnGroundProperly
local DeleteEntity                     = DeleteEntity
local ClearPedTasks                    = ClearPedTasks
local RegisterNetEvent                 = RegisterNetEvent

local medicBagProp                     = lib.load("config").medicBagProp
local useOxInventory                   = lib.load("config").useOxInventory

local function openMedicalBag()
    local playerPed = cache.ped or PlayerPedId()

    TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD")

    lib.callback('ars_ambulancejob:openMedicalBag', false, function(stash)
        exports.ox_inventory:openInventory("stash", stash)
    end)
end

local function placeMedicalBag()
    lib.requestAnimDict("pickup_object")
    lib.requestModel(medicBagProp)

    local playerPed = cache.ped or PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)

    TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, 8.0, 1000, 50, 0, false, false, false)

    Wait(900)

    medicBag = CreateObjectNoOffset(medicBagProp, coords.x, coords.y, coords.z, true, false)
    PlaceObjectOnGroundProperly(medicBag)

    utils.addRemoveItem("remove", "medicalbag", 1)

    Target.addLocalEntity(medicBag, {
        {
            label = locale('open_medical_bag'),
            icon = 'fa-solid fa-suitcase',
            groups = false,
            fn = function()
                if not useOxInventory then
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

local emsJobs = lib.load("config").emsJobs

RegisterNetEvent("ars_ambulancejob:placeMedicalBag", function()
    if not Framework.hasJob(emsJobs) then return end

    placeMedicalBag()
end)
