lib.locale()

Config                         = {}

Config.Debug                   = false

Config.ClothingScript          = 'false' -- 'illenium-appearance', 'fivem-appearance' ,'core' or false -- to disable
Config.EmsJobs                 = { "ambulance" }
Config.RespawnTime             = 0                     -- in minutes
Config.UseInterDistressSystem  = true
Config.WaitTimeForNewCall      = 5                     -- minutes

Config.ReviveCommand           = "revive"
Config.ReviveAreaCommand       = "revivearea"
Config.HealCommand             = "heal"
Config.HealAreaCommand         = "healarea"
Config.ReviveAllCommand        = "reviveall"

Config.Webhook 				   = "https://discord.com/api/webhooks/"

Config.AdminGroup              = "group.admin"
Config.OwnerGroup              = "group.owner"              

Config.MedicBagProp            = "xm_prop_x17_bag_med_01a"
Config.MedicBagItem            = "medicalbag"

Config.HelpCommand             = "help"
Config.RemoveItemsOnRespawn    = true

Config.BaseInjuryReward        = 150 -- changes if the injury value is higher then 1
Config.ReviveReward            = 700

Config.ParamedicTreatmentPrice = 4000
Config.AllowAlways             = true        -- false if you want it to work only when there are only medics online

Config.AmbulanceStretchers     = 2           -- how many stretchers should an ambunalce have
Config.ConsumeItemPerUse       = 10          -- every time you use an item it gets used by 10%

Config.TimeToWaitForCommand    = 2           -- when player dies he needs to wait 2 minutes to do the ambulance command
Config.NpcReviveCommand        = "ambulance" -- this will work only when there are no medics online

Config.UsePedToDepositVehicle  = false       -- if false the vehicle will instantly despawns
Config.ExtraEffects            = true        -- false >> disables the screen shake and the black and white screen

Config.EmsVehicles             = {           -- vehicles that have access to the props (cones and ecc..)
	'ambulance',
	'ambulance2',
}

Config.DeathAnimations         = {
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
	["pillbox"] = {
		paramedic = {
			model = "s_m_m_scientist_01",
			pos = vector4(-436.1755, -325.7487, 33.910762, 171.40728),
		},
		bossmenu = {
			pos = vector3(-455.3441, 320.0995, 34.910755),
			min_grade = 5
		},
		zone = {
			pos = vector3(-436.4369, -340.4771, 34.910762),
			size = vec3(150.0, 200.0, 150.0),
		},
		blip = {
			enable = true,
			name = 'Hospital',
			type = 61,
			scale = 1.0,
			color = 2,
			pos = vector3(-436.4369, -340.4771, 34.910762),
		},
		respawn = {
			{
				bedPoint = vector4(-445.7848, -307.135, 35.837501, 34.940803),
				spawnPoint = vector4(-444.5588, -304.94, 34.910758, 103.79467)
			},
			-- {
			-- 	bedPoint = vector4(346.96, -590.64, 44.12, 338.0),
			-- 	spawnPoint = vector4(348.84, -583.36, 42.32, 68.24)
			-- },

		},
		stash = {
			['ems_stash_1'] = {
				slots = 100,
				weight = 450, -- kg
				min_grade = 0,
				label = 'Locker',
				shared = false, -- false if you want to make everyone has a personal stash
				pos = vector3(-435.8961, -320.2668, 34.910758)
			}
		},
		pharmacy = {
			["ems_shop_1"] = {
				job = true,
				label = "Pharmacy",
				grade = 0, -- works only if job true
				pos = vector3(-430.8908, -320.9941, 34.910751),
				blip = {
					enable = false,
					name = 'Pharmacy',
					type = 61,
					scale = 0.7,
					color = 2,
					pos = vector3(-430.8908, -320.9941, 34.910751),
				},
				items = {
					{ name = 'medicalbag',    price = 10 },
					{ name = 'bandage',       price = 10 },
					{ name = 'defibrillator', price = 10 },
					{ name = 'tweezers',      price = 10 },
					{ name = 'burncream',     price = 10 },
					{ name = 'suturekit',     price = 10 },
					{ name = 'icepack',       price = 10 },
				}
			},
			["ems_shop_2"] = {
				job = false,
				label = "Pharmacy",
				grade = 0, -- works only if job true
				pos = vector3(22.644552, -1107.116, 29.796998),
				blip = {
					enable = true,
					name = 'Pharmacy',
					type = 61,
					scale = 0.7,
					color = 2,
					pos = vector3(22.644552, -1107.116, 29.796998),
				},
				items = {
					{ name = 'bandage', price = 10 },
				}
			},
		},
		garage = {
			['ems_garage_1'] = {
				pedPos = vector4(-452.3661, -351.736, 33.501834, 15.006129),
				model = 's_m_m_chemsec_01',
				spawn = vector4(-454.2525, -339.5548, 34.363494, 352.72827),
				deposit = vector3(-492.2372, -336.2443, 34.372535),
				driverSpawnCoords = vector3(-458.4902, -338.0246, 34.500801),

				vehicles = {
					{
						label = 'Ambulance Audi 3',
						spawn_code = 'ambuaudi3',
						min_grade = 1,
						modifications = {} -- es. {color1 = {255, 12, 25}}
					},
				}
			}
		},
		clothes = {
			enable = false,
			pos = vector4(300.7454, -597.4542, 42.2918, 298.0781),
			model = 'a_f_m_bevhills_01',
			male = {
				[1] = {
					['mask_1']    = 0,
					['mask_2']    = 0,
					['arms']      = 0,
					['tshirt_1']  = 15,
					['tshirt_2']  = 0,
					['torso_1']   = 86,
					['torso_2']   = 0,
					['bproof_1']  = 0,
					['bproof_2']  = 0,
					['decals_1']  = 0,
					['decals_2']  = 0,
					['chain_1']   = 0,
					['chain_2']   = 0,
					['pants_1']   = 10,
					['pants_2']   = 2,
					['shoes_1']   = 56,
					['shoes_2']   = 0,
					['helmet_1']  = 34,
					['helmet_2']  = 0,
					['glasses_1'] = 34,
					['glasses_2'] = 1,
				},
				[2] = {
					['mask_1']    = 0,
					['mask_2']    = 0,
					['arms']      = 0,
					['tshirt_1']  = 15,
					['tshirt_2']  = 0,
					['torso_1']   = 86,
					['torso_2']   = 0,
					['bproof_1']  = 0,
					['bproof_2']  = 0,
					['decals_1']  = 0,
					['decals_2']  = 0,
					['chain_1']   = 0,
					['chain_2']   = 0,
					['pants_1']   = 10,
					['pants_2']   = 2,
					['shoes_1']   = 56,
					['shoes_2']   = 0,
					['helmet_1']  = 34,
					['helmet_2']  = 0,
					['glasses_1'] = 34,
					['glasses_2'] = 1,
				},
			},
			female = {
				[1] = {
					['mask_1']    = 0,
					['mask_2']    = 0,
					['arms']      = 0,
					['tshirt_1']  = 15,
					['tshirt_2']  = 0,
					['torso_1']   = 86,
					['torso_2']   = 0,
					['bproof_1']  = 0,
					['bproof_2']  = 0,
					['decals_1']  = 0,
					['decals_2']  = 0,
					['chain_1']   = 0,
					['chain_2']   = 0,
					['pants_1']   = 10,
					['pants_2']   = 2,
					['shoes_1']   = 56,
					['shoes_2']   = 0,
					['helmet_1']  = 34,
					['helmet_2']  = 0,
					['glasses_1'] = 34,
					['glasses_2'] = 1,
				},
			},
		},
	},
}


Config.BodyParts = {

	-- ["0"] = { id = "hip", label = "Damaged Hipbone", levels = { ["default"] = "Damaged", ["10"] = "Damaged x2", ["20"] = "Damaged x3", ["30"] = "Damaged x3", ["40"] = "Damaged x3", ["50"] = "Damaged x3" } },
	["0"] = { id = "hip", label = "Damaged Hipbone", levels = { ["default"] = "Damaged", ["10"] = "Damaged x2", ["20"] = "Damaged x3", ["30"] = "Damaged x3", ["40"] = "Damaged x3" } }, -- hip bone,
	["10706"] = { id = "rclavicle", label = "Right Clavicle", levels = { ["default"] = "Damaged" } },                                                                                 --right clavicle
	["64729"] = { id = "lclavicle", label = "Left Clavicle", levels = { ["default"] = "Damaged" } },                                                                                  --right clavicle
	["14201"] = { id = "lfoot", label = "Left Foot", levels = { ["default"] = "Damaged" } },                                                                                          -- left foot
	["18905"] = { id = "lhand", label = "Left Hand", levels = { ["default"] = "Damaged" } },                                                                                          -- left hand
	["24816"] = { id = "lbdy", label = "Lower chest", levels = { ["default"] = "Damaged" } },                                                                                         -- lower chest
	["24817"] = { id = "ubdy", label = "Upper Chest", levels = { ["default"] = "Damaged" } },                                                                                         -- Upper chest
	["24818"] = { id = "shoulder", label = "Shoulder", levels = { ["default"] = "Damaged" } },                                                                                        -- shoulder
	["28252"] = { id = "rforearm", label = "Right Forearm", levels = { ["default"] = "Damaged" } },                                                                                   -- right forearm
	["36864"] = { id = "rleg", label = "Right leg", levels = { ["default"] = "Damaged" } },                                                                                           -- right lef
	["39317"] = { id = "neck", label = "Neck", levels = { ["default"] = "Damaged" } },                                                                                                -- neck
	["40269"] = { id = "ruparm", label = "Right Upper Arm", levels = { ["default"] = "Damaged" } },                                                                                   -- right upper arm
	["45509"] = { id = "luparm", label = "Left Upper Arm", levels = { ["default"] = "Damaged" } },                                                                                    -- left upper arm
	["51826"] = { id = "rthigh", label = "Right Thigh", levels = { ["default"] = "Damaged" } },                                                                                       -- right thigh
	["52301"] = { id = "rfoot", label = "Right Foot", levels = { ["default"] = "Damaged" } },                                                                                         -- right foot
	["57005"] = { id = "rhand", label = "Right Hand", levels = { ["default"] = "Damaged" } },                                                                                         -- right hand
	["57597"] = { id = "5lumbar", label = "5th Lumbar vertabra", levels = { ["default"] = "Damaged" } },                                                                              --waist
	["58271"] = { id = "lthigh", label = "Left Thigh", levels = { ["default"] = "Damaged" } },                                                                                        -- left thigh
	["61163"] = { id = "lforearm", label = "Left forearm", levels = { ["default"] = "Damaged" } },                                                                                    -- left forearm
	["63931"] = { id = "lleg", label = "Left Leg", levels = { ["default"] = "Damaged" } },                                                                                            -- left leg
	["31086"] = { id = "head", label = "Head", levels = { ["default"] = "Damaged" } },                                                                                                -- head
}

function Config.SendDistressCall(msg)
	--[--] -- Quasar

	--TriggerServerEvent('qs-smartphone:server:sendJobAlert', {message = msg, location = GetEntityCoords(PlayerPedId())}, "ambulance")


	--[--] -- GKS
	-- local myPos = GetEntityCoords(PlayerPedId())
	-- local GPS = 'GPS: ' .. myPos.x .. ', ' .. myPos.y

	-- ESX.TriggerServerCallback('gksphone:namenumber', function(Races)
	--     local name = Races[2].firstname .. ' ' .. Races[2].lastname

	--     TriggerServerEvent('gksphone:jbmessage', name, Races[1].phone_number, msg, '', GPS, "ambulance")
	-- end)
end
