if GetResourceState('qb-target') ~= 'started' or GetResourceState('ox_target') == 'started' then return end

local qb_target = exports['qb-target']
Target = {}

local function convertJobs(groups)
    if not groups then return nil end
    local jobs = {}

    for _, job in pairs(groups) do
        jobs[job] = 0
    end

    return jobs
end

function Target.addLocalEntity(entity, _options)
    local options = {}

    for i = 1, #_options do
        local option = _options[i]
        local jobs = convertJobs(option.groups)

        options[#options + 1] = {
            label = option.label,
            icon = option.icon,
            job = jobs,
            action = option.fn
        }
    end

    qb_target:AddTargetEntity(entity, {
        options = options,
        distance = 3.0,
    })
end

function Target.addGlobalVehicle(_options)
    local options = {}

    for i = 1, #_options do
        local option = _options[i]
        local jobs = convertJobs(option.groups)

        options[#options + 1] = {
            label = option.label,
            icon = option.icon,
            job = jobs,
            canInteract = option.cn,
            action = option.fn
        }
    end
    qb_target:AddGlobalVehicle({
        options = options,
    })
end

function Target.addModel(models, _options)
    local options = {}

    for i = 1, #_options do
        local option = _options[i]
        local jobs = convertJobs(option.groups)

        options[#options + 1] = {
            label = option.label,
            icon = option.icon,
            job = jobs,
            canInteract = option.cn,
            action = option.fn
        }
    end
    qb_target:AddTargetModel(models, { options = options })
end

function Target.addBoxZone(coords, _options)
    local options = {}

    for i = 1, #_options do
        local option = _options[i]
        local jobs = convertJobs(option.groups)

        options[#options + 1] = {
            label = option.label,
            icon = option.icon,
            job = jobs,
            canInteract = option.cn,
            action = option.fn
        }
    end

    qb_target:AddBoxZone("name" .. coords, coords, 1.5, 1.6, {}, { options = options })
end

function Target.addGlobalPlayer(_options)
    local options = {}

    for i = 1, #_options do
        local option = _options[i]
        local jobs = convertJobs(option.groups)

        options[#options + 1] = {
            label = option.label,
            icon = option.icon,
            job = jobs,
            canInteract = option.cn,
            action = option.fn
        }
    end

    qb_target:AddGlobalPlayer({ options = options })
end
