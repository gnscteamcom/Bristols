local rob = false
local robbers = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function get3DDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
end

RegisterServerEvent('esx_holdupbank:braquagebank')
AddEventHandler('esx_holdupbank:braquagebank', function(result)
	local _source  = source
	local xPlayer  = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()
	local mess     = result
	--print(text)
	for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		TriggerClientEvent('esx_breakingnews:braquagebank', xPlayers[i],mess)
	end

end)

RegisterServerEvent('esx_holdupbank:toofar')
AddEventHandler('esx_holdupbank:toofar', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' and 'gouvernement' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at') .. Banks[robb].nameofbank)
			TriggerClientEvent('esx_holdupbank:killblip', xPlayers[i])
		end
	end
	if(robbers[source])then
		TriggerClientEvent('esx_holdupbank:toofarlocal', source)
		robbers[source] = nil
		TriggerClientEvent('esx:showNotification', source, _U('robbery_has_cancelled') .. Banks[robb].nameofbank)
		local xPlayer = ESX.GetPlayerFromId(source)
		TriggerEvent('esx:holdupmagbot2',xPlayer.name,Banks[robb].nameofbank)
	end
end)

RegisterServerEvent('esx_holdupbank:rob')
AddEventHandler('esx_holdupbank:rob', function(robb)

	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	if Banks[robb] then

		local bank = Banks[robb]

		if (os.time() - bank.lastrobbed) < 600 and bank.lastrobbed ~= 0 then

			TriggerClientEvent('esx:showNotification', source, _U('already_robbed') .. (1800 - (os.time() - bank.lastrobbed)) .. _U('seconds'))
			return
		end


		local cops = 0
		local copsoff = 0
		for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

 		  if xPlayer.job.name == 'police'then
				cops = cops + 1
			end

			if xPlayer.job.name == 'police' and xPlayer.job.grade >= 3 then
				copsoff = copsoff + 1
			end
		end


		if rob == false then

			if(cops >= Config.NumberOfCopsRequired)then
				if(copsoff >= Config.NumberOfffCopsRequired)then

						rob = true
						for i=1, #xPlayers, 1 do
							local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
							if xPlayer.job.name == 'police' then
									TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog') .. bank.nameofbank)
									TriggerClientEvent('esx_holdupbank:setblip', xPlayers[i], Banks[robb].position)
							end
						end

						local xPlayer = ESX.GetPlayerFromId(source)
						TriggerClientEvent('esx:showNotification', source, _U('started_to_rob') .. bank.nameofbank .. _U('do_not_move'))
						TriggerClientEvent('esx:showNotification', source, _U('alarm_triggered'))
						TriggerClientEvent('esx:showNotification', source, _U('hold_pos'))
						TriggerClientEvent('esx_holdupbank:currentlyrobbing', source, robb)
						TriggerEvent('esx:holdupmagbot',xPlayer.name,bank.nameofbank)
						
						Banks[robb].lastrobbed = os.time()
						robbers[source] = robb
						local savedSource = source
						SetTimeout(300000, function()

							if(robbers[savedSource])then

								rob = false
								TriggerClientEvent('esx_holdupbank:robberycomplete', savedSource, job)
								local xPlayer = ESX.GetPlayerFromId(source)
								TriggerEvent('esx:holdupmagbot3',xPlayer.name,bank.nameofbank,bank.reward)
								if(xPlayer)then

									xPlayer.addAccountMoney('black_money', bank.reward)
									local xPlayers = ESX.GetPlayers()
									for i=1, #xPlayers, 1 do
										local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
										if xPlayer.job.name == 'police' then
												TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_complete_at') .. bank.nameofbank)
												TriggerClientEvent('esx_holdupbank:killblip', xPlayers[i])
										end
									end
								end
							end
					end)
				else
					TriggerClientEvent('esx:showNotification', source, 'Il faut minimum '  .. Config.NumberOfffCopsRequired .. ' haut grader pour braquer la banque')
				end
			else
				TriggerClientEvent('esx:showNotification', source, _U('min_two_police') .. Config.NumberOfCopsRequired .. ' policiers pour braquer la banque')
			end
		else
			TriggerClientEvent('esx:showNotification', source, _U('robbery_already'))
		end
	end
end)