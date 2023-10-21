lib.locale()

Config = {}

Config.Debug = true

Config.ClothingScript = 'illenium-appearance' -- 'illenium-appearance', 'fivem-appearance' ,'core' or false -- to disable
Config.ReviveCommand = "revive"
Config.EmsJobs = { "ambulance", "ems" }
Config.RespawnTime = 5 -- in minutes
Config.UseInterDistressSystem = true
Config.WaitTimeForNewCall = 5 -- minutes

Config.LimpAnim = "move_m@injured"
Config.StartLimp = 4

Config.DeathAnimations = {
	["car"] = {
		dict = "veh@low@front_ps@idle_duck",
		clip = "sit"
	},
	["normal"] = {
		dict = "dead",
		clip = "dead_a"
	},
	["revive"] = {
		dict = "get_up@directional@movement@from_knees@action",
		clip = "getup_r_0"
	}
}


Config.Hospitals = {
	["phillbox"] = {
		zone = {
			pos = vec3(299.0, -585.28, 43.28),
			size = vec3(96.0, 79.0, 65.0),
		},
		blip = {
			enable = true,
			name = 'Phillbox Hospital',
			type = 61,
			scale = 0.8,
			color = 2,
			pos = vector3(299.0, -585.28, 43.28),
		},
		respawn = {
			bedPoint = vector4(-450.5561, -323.2419, 34.6836, 91.5347),
			spawnPoint = vector4(-450.9195, -321.9326, 34.9059, 349.6794)
		},
		pharmacy = {
			["ems_shop_1"] = {
				job = false,
				label = "Pharmacy",
				grade = 0, -- works only if job true
				pos = vector3(-484.7923, -342.2781, 34.3617),
				items = {
					{ name = 'bandage', price = 18000, },
				}
			}
		}
	},
}

Config.BleedingWeapons = {
	[`WEAPON_PISTOL`],
	[`WEAPON_PISTOL_MK2`]
}


Config.BodyParts = {
	["0"] = { id = "hip", label = "Damaged Hipbone", levels = { ["default"] = "Damaged" } },          -- hip bone,
	["10706"] = { id = "rclavicle", label = "Right Clavicle", levels = { ["default"] = "Damaged" } }, --right clavicle
	["64729"] = { id = "lclavicle", label = "Left Clavicle", levels = { ["default"] = "Damaged" } }, --right clavicle
	["14201"] = { id = "lfoot", label = "Left Foot", levels = { ["default"] = "Damaged" } },          -- left foot
	["18905"] = { id = "lhand", label = "Left Hand", levels = { ["default"] = "Damaged" } },          -- left hand
	["24816"] = { id = "lbdy", label = "Lower chest", levels = { ["default"] = "Damaged" } },         -- lower chest
	["24817"] = { id = "ubdy", label = "Upper Chest", levels = { ["default"] = "Damaged" } },         -- Upper chest
	["24818"] = { id = "shoulder", label = "Shoulder", levels = { ["default"] = "Damaged" } },        -- shoulder
	["28252"] = { id = "rforearm", label = "Right Forearm", levels = { ["default"] = "Damaged" } },   -- right forearm
	["36864"] = { id = "rleg", label = "Right leg", levels = { ["default"] = "Damaged" } },           -- right lef
	["39317"] = { id = "neck", label = "Neck", levels = { ["default"] = "Damaged" } },                -- neck
	["40269"] = { id = "ruparm", label = "Right Upper Arm", levels = { ["default"] = "Damaged" } },   -- right upper arm
	["45509"] = { id = "luparm", label = "Left Upper Arm", levels = { ["default"] = "Damaged" } },    -- left upper arm
	["51826"] = { id = "rthigh", label = "Right Thigh", levels = { ["default"] = "Damaged" } },       -- right thigh
	["52301"] = { id = "rfoot", label = "Right Foot", levels = { ["default"] = "Damaged" } },         -- right foot
	["57005"] = { id = "rhand", label = "Right Hand", levels = { ["default"] = "Damaged" } },         -- right hand
	["57597"] = { id = "5lumbar", label = "5th Lumbar vertabra", levels = { ["default"] = "Damaged" } }, --waist
	["58271"] = { id = "lthigh", label = "Left Thigh", levels = { ["default"] = "Damaged" } },        -- left thigh
	["61163"] = { id = "lforearm", label = "Left forearm", levels = { ["default"] = "Damaged" } },    -- left forearm
	["63931"] = { id = "lleg", label = "Left Leg", levels = { ["default"] = "Damaged" } },            -- left leg
	["31086"] = { id = "head", label = "Head", levels = { ["default"] = "Damaged" } },                -- head
}

function Config.SendDistressCall(msg)
--[--] -- Quasar

	-- TriggerServerEvent('qs-smartphone:server:sendJobAlert', {message = msg, location = GetEntityCoords(PlayerPedId())}, "ambulance")


--[--] -- GKS
    -- local myPos = GetEntityCoords(PlayerPedId())
    -- local GPS = 'GPS: ' .. myPos.x .. ', ' .. myPos.y

    -- ESX.TriggerServerCallback('gksphone:namenumber', function(Races)
    --     local name = Races[2].firstname .. ' ' .. Races[2].lastname

    --     TriggerServerEvent('gksphone:jbmessage', name, Races[1].phone_number, msg, '', GPS, "ambulance")
    -- end)

end
