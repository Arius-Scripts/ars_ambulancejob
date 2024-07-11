--#--
--Fx info--
--#--
fx_version 'cerulean'
use_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
version '1.0.3'
author 'Arius Scripts'
description 'Advanced ambulance job with intergrated death system'


--#--
--Manifest--
--#--

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

client_scripts {
	"data/weapons.lua",
	"modules/utils/client/utils.lua",

	"client.lua",

	"modules/compatibility/frameworks/**/client.lua",
	"modules/compatibility/target/*.lua",

	"modules/injuries/client.lua",
	"modules/death/client.lua",
	"modules/stretcher/client.lua",
	"modules/paramedic/client.lua",

	"modules/job/client/main.lua",
	"modules/job/client/garage.lua",
	"modules/job/client/medical_bag.lua",
	"modules/job/client/stashes.lua",
	"modules/job/client/shops.lua",
	"modules/job/client/clothing.lua",
	"modules/job/client/bossmenu.lua",

	"modules/utils/client/coords_debug.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"modules/compatibility/frameworks/**/server.lua",
	"server.lua",
	"modules/commands/server.lua",
	"modules/compatibility/txadmin/server.lua",
}

files {
	'locales/*.json',
}
