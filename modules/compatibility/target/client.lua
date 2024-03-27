if GetResourceState('ox_target') == 'started' then
    function addLocalEntity(entity, _options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                distance = 3,
                onSelect = option.fn
            }
        end
        exports.ox_target:addLocalEntity(entity, options)
    end

    function addGlobalVehicle(_options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                canInteract = option.cn,
                onSelect = option.fn
            }
        end

        exports.ox_target:addGlobalVehicle(options)
    end

    function addModel(models, _options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                canInteract = option.cn,
                onSelect = option.fn
            }
        end
        exports.ox_target:addModel(models, options)
    end

    function addBoxZone(coords, _options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                onSelect = option.fn
            }
        end

        exports.ox_target:addBoxZone({ coords = coords, options = options })
    end

    function addGlobalPlayer(_options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                canInteract = option.cn,
                onSelect = option.fn
            }
        end

        exports.ox_target:addGlobalPlayer(options)
    end
elseif GetResourceState('qb-target') == 'started' then
    local function convertJobs(groups)
        if not groups then return nil end
        local jobs = {}

        for _, job in pairs(groups) do
            jobs[job] = 0
        end

        return jobs
    end

    function addLocalEntity(entity, _options)
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

        exports['qb-target']:AddTargetEntity(entity, {
            options = options,
            distance = 3.0,
        })
    end

    function addGlobalVehicle(_options)
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
        exports['qb-target']:AddGlobalVehicle({
            options = options,
        })
    end

    function addModel(models, _options)
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
        exports['qb-target']:AddTargetModel(models, { options = options })
    end

    function addBoxZone(coords, _options)
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

        exports['qb-target']:AddBoxZone("name" .. coords, coords, 1.5, 1.6, {}, { options = options })
    end

    function addGlobalPlayer(_options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]
            local jobs = convertJobs(option.groups)

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                job = jobs,
                canInteract = option.cn,
                onSelect = option.fn
            }
        end

        exports['qb-target']:AddGlobalPlayer({ options = options })
    end
else
    Wait(3000)
    print("^6 NO TARGET WAS FOUND SCRIPT IS NOT GONNA WORK")
end
