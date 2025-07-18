--#--Fx Info--#--
fx_version 'cerulean'
use_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

--#--Resource Info--#--
version '1.0.5'
author 'Arius Scripts'
description 'Advanced ambulance job with intergrated death system'

shared_script { '@ox_lib/init.lua', "config.lua", }
ox_libs { 'locale' }

client_scripts {
    "resource/client.lua"
}


server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "resource/server.lua"
}

ui_page "web/index.html"


files {
    'locales/*.json',
    "data/*.lua",
    "resource/modules/**/*.lua",
    "resource/compatibility/frameworks/**/client.lua",
    "resource/compatibility/target/*.lua",
    "resource/compatibility/txadmin/server.lua",
    "resource/utils/client/utils.lua",
    "resource/utils/client/coords_debug.lua",

    "resource/modules/job/client/facilities/*.lua",

    "web/index.html",
    "web/js/*.js",
    "web/css/*.css",
}

dependencies {
    "oxmysql",
    "ox_lib"
}
