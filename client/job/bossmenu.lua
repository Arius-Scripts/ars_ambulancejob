for index, hospital in pairs(Config.Hospitals) do
    addBoxZone(hospital.bossmenu.pos, {
        {
            name = "open_boosmenu" .. index,
            icon = 'fa-solid fa-road',
            label = locale("bossmenu_label"),
            groups = Config.EmsJobs,
            fn = function(data)
                if getPlayerJobGrade() >= hospital.bossmenu.min_grade then
                    openBossMenu(playerJob())
                else
                    print("no access")
                end
            end
        }
    })
end
