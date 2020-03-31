local rob = false
local robbers = {}
PlayersCrafting    = {}
local CopsConnected  = 0
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function get3DDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
end

RegisterServerEvent('ddx_vangelico_robbery:toofar')
AddEventHandler('ddx_vangelico_robbery:toofar', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
			TriggerClientEvent('ddx_vangelico_robbery:BraquageAnnule', xPlayers[i])
			TriggerClientEvent('ddx_vangelico_robbery:killblip', xPlayers[i])
		end
	end
	if(robbers[source])then
		TriggerClientEvent('ddx_vangelico_robbery:toofarlocal', source)
		robbers[source] = nil
		TriggerClientEvent('ddx_vangelico_robbery:BraquageAnnule')
	end
end)

RegisterServerEvent('ddx_vangelico_robbery:endrob')
AddEventHandler('ddx_vangelico_robbery:endrob', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('end'))
			TriggerClientEvent('ddx_vangelico_robbery:killblip', xPlayers[i])
			TriggerClientEvent('ddx_vangelico_robbery:BraquageFinit', xPlayers[i])
		end
	end
	if(robbers[source])then
		TriggerClientEvent('ddx_vangelico_robbery:robberycomplete', source)
		robbers[source] = nil
		TriggerClientEvent('esx:showNotification', source, _U('robbery_has_ended') .. Stores[robb].nameofstore)
	end
end)

RegisterServerEvent('ddx_vangelico_robbery:rob')
AddEventHandler('ddx_vangelico_robbery:rob', function(robb)

	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	if Stores[robb] then

		local store = Stores[robb]

		if (os.time() - store.lastrobbed) < 600 and store.lastrobbed ~= 0 then

            TriggerClientEvent('ddx_vangelico_robbery:togliblip', source)
			TriggerClientEvent('esx:showNotification', source, _U('already_robbed') .. (1800 - (os.time() - store.lastrobbed)) .. _U('seconds'))
			return
		end


		local cops = 0
		for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
				cops = cops + 1
			end
		end


		if rob == false then

			if(cops >= Config.RequiredCopsRob)then

				rob = true
				for i=1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
					if xPlayer.job.name == 'police' then
							--TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog') .. store.nameofstore)
							TriggerClientEvent('ddx_vangelico_robbery:setblip', xPlayers[i], Stores[robb].position)
					end
				end

				TriggerClientEvent('esx:showNotification', source, _U('started_to_rob') .. store.nameofstore .. _U('do_not_move'))
				--TriggerClientEvent('esx:showNotification', source, _U('alarm_triggered'))
				--TriggerClientEvent('esx:showNotification', source, _U('hold_pos'))
			    TriggerClientEvent('ddx_vangelico_robbery:currentlyrobbing', source, robb)
                CancelEvent()
				Stores[robb].lastrobbed = os.time()
			else
				TriggerClientEvent('ddx_vangelico_robbery:togliblip', source)
				TriggerClientEvent('esx:showNotification', source, _U('min_two_police'))
			end
		else
			TriggerClientEvent('ddx_vangelico_robbery:togliblip', source)
			TriggerClientEvent('esx:showNotification', source, _U('robbery_already'))
		end
	end
end)

RegisterServerEvent('ddx_vangelico_robbery:gioielli1')
AddEventHandler('ddx_vangelico_robbery:gioielli1', function()

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.addInventoryItem('jewels', 1)
end)

function CountCops()

	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1000, CountCops)
end

CountCops()

local function Craft(source)

	SetTimeout(4000, function()

		if PlayersCrafting[source] == true and CopsConnected >= Config.RequiredCopsSell then

			local xPlayer  = ESX.GetPlayerFromId(source)
			local JewelsQuantity = xPlayer.getInventoryItem('jewels').count

			if JewelsQuantity < 20 then 
				TriggerClientEvent('ddx_vangelico_robbery:VenteBijouxRefuser', source)
			else   
				TriggerClientEvent('ddx_vangelico_robbery:VenteBijoux', source)
				xPlayer.removeInventoryItem('jewels', 20)
				Citizen.Wait(4000)
				xPlayer.addMoney(36000)			
				Craft(source)
			end
		else
		TriggerClientEvent('esx:showNotification', source, _U('copsforsell'))
		end
	end)
end

RegisterServerEvent('lester:vendita')
AddEventHandler('lester:vendita', function()
	local _source = source
	PlayersCrafting[_source] = true
	--TriggerClientEvent('esx:showNotification', _source, 'Tu donne t\'es bijoux au revendeur ...')
	Craft(_source)
end)

RegisterServerEvent('lester:nvendita')
AddEventHandler('lester:nvendita', function()
	local _source = source
	PlayersCrafting[_source] = false
end)
