--#--
--Fx info--
--#--
fx_version 'cerulean'
use_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
version '1.0.0'

--#--
--Manifest--
--#--

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

client_scripts {
	"client/modules/deathCause.lua",
	"client/modules/utils.lua",

	"client/main.lua",

	"client/bridge/esx.lua",
	"client/bridge/qb.lua",

	"client/injuries.lua",
	"client/death.lua",
	"client/job.lua",
	"client/garage.lua",
	"client/medical_bag.lua",
	"client/clothing.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/main.lua",
	"server/bridge/esx.lua",
	"server/bridge/qb.lua",
}

files {
	'locales/*.json',
}
