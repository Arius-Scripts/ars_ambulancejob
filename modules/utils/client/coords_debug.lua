local debug = lib.load("config").debug
if not debug then return end
local hospitals = lib.load("data.hospitals")

for name, hospital in pairs(hospitals) do
    local zonePos = hospital.zone.pos
    local zoneSize = hospital.zone.size
    local inZone = false

    -- Paramedic
    inZone = utils.inHospitalZone(hospital.paramedic.pos, zonePos, zoneSize)
    if not inZone then
        utils.debug(("^6HOSPITAL %s"):format(string.upper(name)))
        utils.debug("^1Paramedic ^0 is not in the hospital zone change coordinates")
    end

    -- Bossmenu
    inZone = utils.inHospitalZone(hospital.bossmenu.pos, zonePos, zoneSize)
    if not inZone then
        utils.debug("^1Bossmenu ^0 is not in the hospital zone change coordinates")
    end

    -- Blip
    inZone = utils.inHospitalZone(hospital.blip.pos, zonePos, zoneSize)
    if not inZone then
        utils.debug("^1Blip ^0 is not in the hospital zone change coordinates")
    end

    -- Bed points
    for bedIndex = 1, #hospital.respawn do
        local bed = hospital.respawn[bedIndex]
        inZone = utils.inHospitalZone(bed.bedPoint, zonePos, zoneSize)
        if not inZone then
            utils.debug(("^1Bed N.%s ^0 is not in the hospital zone change coordinates"):format(bedIndex))
        end
    end

    -- Stashes
    for index, stash in pairs(hospital.stash) do
        inZone = utils.inHospitalZone(stash.pos, zonePos, zoneSize)
        if not inZone then
            utils.debug(("^1Stash ^4%s ^0 is not in the hospital zone change coordinates"):format(stash.label))
        end
    end

    -- Pharmacy
    for index, pharmacy in pairs(hospital.pharmacy) do
        inZone = utils.inHospitalZone(pharmacy.pos, zonePos, zoneSize)
        if not inZone then
            utils.debug(("^1Pharmacy ^4%s ^0 is not in the hospital zone change coordinates"):format(pharmacy.label))
        end
    end

    -- Garage
    for index, garage in pairs(hospital.garage) do
        inZone = utils.inHospitalZone(garage.pedPos.xyz, zonePos, zoneSize)
        if not inZone then
            utils.debug(("^1Garage ^4%s ^0 ped is not in the hospital zone change coordinates"):format(index))
        end
    end

    -- Clothes

    inZone = utils.inHospitalZone(hospital.clothes.pos.xyz, zonePos, zoneSize)
    if not inZone then
        utils.debug("^1Clothes ^0 ped is not in the hospital zone change coordinates")
    end
end
