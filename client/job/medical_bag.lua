local TaskStartScenarioInPlace         = TaskStartScenarioInPlace
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local TaskPlayAnim                     = TaskPlayAnim
local Wait                             = Wait
local CreateObjectNoOffset             = CreateObjectNoOffset
local PlaceObjectOnGroundProperly      = PlaceObjectOnGroundProperly
local DeleteEntity                     = DeleteEntity
local ClearPedTasks                    = ClearPedTasks
local RegisterNetEvent                 = RegisterNetEvent

local function openMedicalBag()
    local playerPed = cache.ped or PlayerPedId()

    TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD")

    lib.callback('ars_ambulancejob:openMedicalBag', false, function(stash)
        exports.ox_inventory:openInventory("stash", stash)
    end)
end

local function placeMedicalBag()
    lib.requestAnimDict("pickup_object")
    lib.requestModel(Config.MedicBagProp)

    local playerPed = cache.ped or PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)

    TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, 8.0, 1000, 50, 0, false, false, false)

    Wait(900)

    medicBag = CreateObjectNoOffset(Config.MedicBagProp, coords.x, coords.y, coords.z, true, false)
    PlaceObjectOnGroundProperly(medicBag)

    utils.addRemoveItem("remove", "medicalbag", 1)

    addLocalEntity(medicBag, {
        {
            label = locale('open_medical_bag'),
            icon = 'fa-solid fa-suitcase',
            groups = false,
            fn = function()
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

RegisterNetEvent("ars_ambulancejob:placeMedicalBag", function()
    if not hasJob(Config.EmsJobs) then return end

    placeMedicalBag()
end)

-- © 𝐴𝑟𝑖𝑢𝑠 𝐷𝑒𝑣𝑒𝑙𝑜𝑝𝑚𝑒𝑛𝑡
