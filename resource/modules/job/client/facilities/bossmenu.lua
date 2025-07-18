local hospitals = lib.load("data.hospitals")
local emsJobs = lib.load("config").emsJobs
for index, hospital in pairs(hospitals) do
    Target.addBoxZone(hospital.bossmenu.pos, {
        {
            name = "open_bossmenu" .. index,
            icon = 'fa-solid fa-road',
            label = locale("bossmenu_label"),
            groups = emsJobs,
            fn = function(data)
                if Framework.getPlayerJobGrade() >= hospital.bossmenu.min_grade then
                    Framework.openBossMenu(Framework.playerJob())
                else
                    print(locale("bossmenu_denied"))
                end
            end
        }
    })
end
