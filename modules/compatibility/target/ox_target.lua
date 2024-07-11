if GetResourceState('ox_target') ~= 'started' then return end

local ox_target = exports.ox_target
Target = {}

function Target.addLocalEntity(entity, _options)
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
    ox_target:addLocalEntity(entity, options)
end

function Target.addGlobalVehicle(_options)
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

    ox_target:addGlobalVehicle(options)
end

function Target.addModel(models, _options)
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
    ox_target:addModel(models, options)
end

function Target.addBoxZone(coords, _options)
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

    ox_target:addBoxZone({ coords = coords, options = options })
end

function Target.addGlobalPlayer(_options)
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

    ox_target:addGlobalPlayer(options)
end
