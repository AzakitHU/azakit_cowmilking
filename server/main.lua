RegisterServerCallback("azakit_cowmilking:exchangeProcess", function(source, cb, index)
    local xPlayer = ESX.GetPlayerFromId(source)
    local src = source
    local item = xPlayer.getInventoryItem(BUCKET)
    if item.count >= 1 then
        xPlayer.removeInventoryItem(BUCKET, 1)
        xPlayer.addInventoryItem(BUCKETMILK, 1) 
        cb(true)
        local message = "**Steam:** " .. GetPlayerName(src) .. "\n**Identifier:** " .. xPlayer.identifier .. "\n**ID:** " .. src .. "\n**Log:** Successful milking a cow!"
        discordLog(message, Webhook)  
    else
        cb(false)
    end
end)

ESX.RegisterUsableItem(BUCKETMILK, function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    TriggerClientEvent('azakit_cowmilking:bucketmilk', src)
end)

RegisterNetEvent('azakit_cowmilking:bucketmilk')
AddEventHandler('azakit_cowmilking:bucketmilk', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local object = xPlayer.getInventoryItem(BOTTLE).count
    local object2 = xPlayer.getInventoryItem(BUCKETMILK).count
    if object >= BOTTLE_AMOUNT and object2 >= 1 then
     xPlayer.removeInventoryItem(BUCKETMILK, 1)
     xPlayer.removeInventoryItem(BOTTLE, BOTTLE_AMOUNT)   
     xPlayer.addInventoryItem(HOMEMILK, BOTTLE_AMOUNT)   
     xPlayer.addInventoryItem(BUCKET, 1)
     TriggerClientEvent('ox_lib:notify', source, { type = 'success', title = 'You pour the milk into the plastic bottles.', position = 'top' })  
    else
	    TriggerClientEvent('ox_lib:notify', source, { type = 'error', title = 'You need more plastic bottles!', position = 'top' })
    end
end)

function discordLog(message, webhook)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = 'AzakitBOT', embeds = {{["description"] = "".. message .."",["footer"] = {["text"] = "Azakit Development - https://discord.com/invite/DmsF6DbCJ9",["icon_url"] = "https://cdn.discordapp.com/attachments/1150477954430816456/1192512440215277688/azakitdevelopmentlogoavatar.png?ex=65a958c1&is=6596e3c1&hm=fc6638bef39209397047b55d8afbec6e8a5d4ca932d8b49aec74cb342e2910dc&",},}}, avatar_url = "https://cdn.discordapp.com/attachments/1150477954430816456/1192512440215277688/azakitdevelopmentlogoavatar.png?ex=65a958c1&is=6596e3c1&hm=fc6638bef39209397047b55d8afbec6e8a5d4ca932d8b49aec74cb342e2910dc&"}), { ['Content-Type'] = 'application/json' })
end
