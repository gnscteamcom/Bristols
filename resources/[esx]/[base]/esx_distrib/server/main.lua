ESX               = nil
local ItemsLabels = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function()

	MySQL.Async.fetchAll(
		'SELECT * FROM items',
		{},
		function(result)

			for i=1, #result, 1 do
				ItemsLabels[result[i].name] = result[i].label
			end--

		end
	)

end)

ESX.RegisterServerCallback('esx_distributor:requestDBItems', function(source, cb)

	MySQL.Async.fetchAll(
		'SELECT * FROM distributor',
		{},
		function(result)

			local distributorItems  = {}

			for i=1, #result, 1 do

				if distributorItems[result[i].name] == nil then
					distributorItems[result[i].name] = {}
				end

				table.insert(distributorItems[result[i].name], {
					name  = result[i].item,
					price = result[i].price,
					label = ItemsLabels[result[i].item]
				})

			end

			cb(distributorItems)

		end
	)

end)

RegisterServerEvent('esx_distributor:buyItem')
AddEventHandler('esx_distributor:buyItem', function(itemName, price)

	local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.get('money') >= price then
        xPlayer.removeMoney(price)
		TriggerClientEvent('esx:showNotification', source, _U('bought') .. ItemsLabels[itemName])
		xPlayer.addInventoryItem(itemName, 1)
        cb(true)
      elseif xPlayer.get('bank') >= price then
        xPlayer.removeAccountMoney('bank', price)
		TriggerClientEvent('esx:showNotification', source, _U('bought') .. ItemsLabels[itemName].. ' avec votre carte bancaire')
		xPlayer.addInventoryItem(itemName, 1)
        cb(true)
      else
        cb(false)
      end

end)
