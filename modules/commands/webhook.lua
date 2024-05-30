ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local discordWebhook = "" -- Put your Discord webhook here

RegisterServerEvent('ars_ambulancejob:discord:target')
AddEventHandler('ars_ambulancejob:discord:target', function(Command, playerId, targetId, radius)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local xTarget = ESX.GetPlayerFromId(targetId)
    local currentTime = os.date('%d-%m-%Y %H:%M:%S', os.time())
    local Staffname = xPlayer.getName()
    local Targetname = xTarget.getName()

    local message = "**Command:** " .. Command .. "\n **The admin that used the command:** " .. Staffname .. " **ID:** " .. playerId .. "\n **Player that was been revived:** " .. Targetname .. " **ID:** " .. targetId .. "\n **Time:** " .. currentTime
    local embeds = {
		{
			["title"] = "ars_ambulancejob ",
			["type"] = "rich",
			["color"] = 2490368,
			["description"] = message,
			["footer"] = {
				["text"] = "Arius-Scripts",
			},
            ["image"] = {
                ["url"] = "https://avatars.githubusercontent.com/u/70983185?v=4"
            },
		}
	}
	PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "ars_ambulancejob", embeds = embeds}), { ['Content-Type'] = 'application/json' })
end)

RegisterServerEvent('ars_ambulancejob:discord:radius')
AddEventHandler('ars_ambulancejob:discord:radius', function(Command, playerId, radius)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local Staffname = xPlayer.getName()
    local currentTime = os.date('%d-%m-%Y %H:%M:%S', os.time())

    local message = "**Command:** " .. Command .. "\n **The admin that used the command:** " .. Staffname .. " **ID:** " .. playerId .. "\n **Radius:** " .. radius .. "\n **Time:** " .. currentTime
    local embeds = {
		{
			["title"] = "ars_ambulancejob ",
			["type"] = "rich",
			["color"] = 2490368,
			["description"] = message,
			["footer"] = {
				["text"] = "Arius-Scripts",
			},
            ["image"] = {
                ["url"] = "https://avatars.githubusercontent.com/u/70983185?v=4"
            },
		}
	}
	PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "ars_ambulancejob", embeds = embeds}), { ['Content-Type'] = 'application/json' })
end)

RegisterServerEvent('ars_ambulancejob:discord:all')
AddEventHandler('ars_ambulancejob:discord:all', function(Command, playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local Staffname = xPlayer.getName()
    local currentTime = os.date('%d-%m-%Y %H:%M:%S', os.time())

    local message = "**Command:** " .. Command .. "\n **The admin that used the command:** " .. Staffname .. " **ID:** " .. playerId .. "\n **Time:** " .. currentTime
    local embeds = {
		{
			["title"] = "ars_ambulancejob ",
			["type"] = "rich",
			["color"] = 2490368,
			["description"] = message .. " om: " .. currentTime,
			["footer"] = {
				["text"] = "Arius-Scripts",
			},
            ["image"] = {
                ["url"] = "https://avatars.githubusercontent.com/u/70983185?v=4"
            },
		}
	}
	PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "ars_ambulancejob", embeds = embeds}), { ['Content-Type'] = 'application/json' })
end)
