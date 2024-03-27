for index, hospital in pairs(Config.Hospitals) do
    addBoxZone(hospital.bossmenu.pos, {
        {
            name = "open_bossmenu" .. index,
            icon = 'fa-solid fa-road',
            label = locale("bossmenu_label"),
            groups = Config.EmsJobs,
            fn = function(data)
                if getPlayerJobGrade() >= hospital.bossmenu.min_grade then
                    openBossMenu(playerJob())
                else
                    print(locale("bossmenu_denied"))
                end
            end
        }
    })
end
