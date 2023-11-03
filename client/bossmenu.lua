for index, hospital in pairs(Config.Hospitals) do
    exports.ox_target:addBoxZone({
        coords = hospital.bossmenu.pos,
        size = vector3(2.0, 2.0, 2.0),
        drawSprite = true,
        groups = Config.EmsJobs,
        options = {
            {
                name = "open_boosmenu" .. index,
                icon = 'fa-solid fa-road',
                label = locale("bossmenu_label"),
                groups = Config.EmsJobs,
                onSelect = function(data)
                    if getPlayerJobGrade() >= hospital.bossmenu.min_grade then
                        openBossMenu(playerJob())
                    else
                        print("no access")
                    end
                end
            }
        }
    })
end
