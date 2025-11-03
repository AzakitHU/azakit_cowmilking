local Framework = {}
local Cows = {}
local ESX, QBCore = nil, nil

if FrameworkType == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
elseif FrameworkType == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
end

if FrameworkType == "ESX" then
    Framework.GetPlayer = function(source)
       -- print("Using ESX Framework.")
        return ESX.GetPlayerFromId(source)
    end
    Framework.AddItem = function(source, item, amount)
        ESX.GetPlayerFromId(source).addInventoryItem(item, amount)
    end
    Framework.RemoveItem = function(source, item, amount)
        ESX.GetPlayerFromId(source).removeInventoryItem(item, amount)
    end
    Framework.GetItemCount = function(source, item)
        return ESX.GetPlayerFromId(source).getInventoryItem(item).count
    end
elseif FrameworkType == "QBCore" then
   -- print("Using QBCore Framework.")
    Framework.GetPlayer = function(source)
        return QBCore.Functions.GetPlayer(source)
    end
    Framework.AddItem = function(source, item, amount)
        QBCore.Functions.GetPlayer(source).Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add')
    end
    Framework.RemoveItem = function(source, item, amount)
        QBCore.Functions.GetPlayer(source).Functions.RemoveItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove')
    end
    Framework.GetItemCount = function(source, item)
        local player = QBCore.Functions.GetPlayer(source)
        local itemData = player.Functions.GetItemByName(item)
        return itemData and itemData.amount or 0
    end
end

if FrameworkType == "ESX" and not ESX then
    print("^1ERROR: Failed to initialize ESX. Make sure it is correctly installed and configured.^0")
elseif FrameworkType == "QBCore" and not QBCore then
    print("^1ERROR: Failed to initialize QBCore. Make sure it is correctly installed and configured.^0")
end


RegisterServerCallback("azakit_cowmilking:exchangeProcess", function(source, cb, index)
    local player = Framework.GetPlayer(source)
    local src = source
    if not player then
        print("^1ERROR: Failed to retrieve player object. Check Framework configuration.^0")
        cb(false)
        return
    end

    if Framework.GetItemCount(source, BUCKET) >= 1 then
        Framework.RemoveItem(source, BUCKET, 1)
        Framework.AddItem(source, BUCKETMILK, 1)
        cb(true)
        local message = "**Steam:** " .. GetPlayerName(src) .. "\n**Identifier:** " .. player.identifier .. "\n**ID:** " .. src .. "\n**Log:** Successful milking a cow!"
        discordLog(message, Webhook)
    else
        cb(false)
    end
end)

if FrameworkType == "ESX" then
    ESX.RegisterUsableItem(BUCKETMILK, function(source)
        local player = ESX.GetPlayerFromId(source)
        
        -- Check if the player has enough bottles before triggering the client event
        if player.getInventoryItem(BOTTLE).count >= BOTTLE_AMOUNT then
            TriggerClientEvent('azakit_cowmilking:bucketmilk', source)  -- Trigger the client-side event
        else
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                title = _("need_more"),
                position = 'top'
            })
        end
    end)
elseif FrameworkType == "QBCore" then
    QBCore.Functions.CreateUseableItem(BUCKETMILK, function(source)
        local player = QBCore.Functions.GetPlayer(source)
        
        -- Check if the player has enough bottles before triggering the client event
        if player.Functions.GetItemByName(BOTTLE) and player.Functions.GetItemByName(BOTTLE).amount >= BOTTLE_AMOUNT then
            TriggerClientEvent('azakit_cowmilking:bucketmilk', source)  -- Trigger the client-side event
        else
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                title = _("need_more"),
                position = 'top'
            })
        end
    end)
end


-- Initialize cows
for i, cow in ipairs(Cow) do
    Cows[i] = {
        coords = cow.cowCoords,
        spawned = false -- Indicates whether the cow has already spawned
    }
end

RegisterNetEvent('azakit_cowmilking:requestCows')
AddEventHandler('azakit_cowmilking:requestCows', function()
    local src = source
    TriggerClientEvent('azakit_cowmilking:syncCows', src, Cows)
end)

RegisterNetEvent('azakit_cowmilking:markCowSpawned')
AddEventHandler('azakit_cowmilking:markCowSpawned', function(index)
    if Cows[index] then
        Cows[index].spawned = true
    end
end)

RegisterNetEvent('azakit_cowmilking:checkItems')
AddEventHandler('azakit_cowmilking:checkItems', function(itemName)
    local src = source
    local player = Framework.GetPlayer(src)

    if not player then
        print("^1ERROR: Failed to retrieve player object.^0")
        return
    end

    local bucketMilkCount, bottleCount = 0, 0

    if FrameworkType == "ESX" then
        bucketMilkCount = Framework.GetItemCount(src, BUCKETMILK)
        bottleCount = Framework.GetItemCount(src, BOTTLE)
    elseif FrameworkType == "QBCore" then
        bucketMilkCount = Framework.GetItemCount(src, BUCKETMILK)
        bottleCount = Framework.GetItemCount(src, BOTTLE)
    end

    if bucketMilkCount >= 1 and bottleCount >= BOTTLE_AMOUNT then
        TriggerClientEvent('azakit_cowmilking:bucketmilk', src, itemName)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = _("need_more"),
            position = 'top'
        })
    end
end)

RegisterNetEvent('azakit_cowmilking:bucketmilk')
AddEventHandler('azakit_cowmilking:bucketmilk', function()
    local player = Framework.GetPlayer(source)
    if not player then
        print("^1ERROR: Failed to retrieve player object. Check Framework configuration.^0")
        return
    end

    if Framework.GetItemCount(source, BOTTLE) >= BOTTLE_AMOUNT and
       Framework.GetItemCount(source, BUCKETMILK) >= 1 then
        Framework.RemoveItem(source, BUCKETMILK, 1)
        Framework.RemoveItem(source, BOTTLE, BOTTLE_AMOUNT)
        Framework.AddItem(source, HOMEMILK, BOTTLE_AMOUNT)
        Framework.AddItem(source, BUCKET, 1)

        TriggerClientEvent('ox_lib:notify', source, { 
            type = 'success', 
            title = _("poured_milk"),
            position = 'top' 
        })
    else
        TriggerClientEvent('ox_lib:notify', source, { 
            type = 'error', 
            title = _("need_more"),
            position = 'top' 
        })
    end
end)

function discordLog(message, webhook)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = 'AzakitBOT', embeds = {{["description"] = "".. message .."",["footer"] = {["text"] = "Azakit Development - https://discord.com/invite/DmsF6DbCJ9",["icon_url"] = "https://cdn.discordapp.com/attachments/1150477954430816456/1192512440215277688/azakitdevelopmentlogoavatar.png?ex=65a958c1&is=6596e3c1&hm=fc6638bef39209397047b55d8afbec6e8a5d4ca932d8b49aec74cb342e2910dc&",},}}, avatar_url = "https://cdn.discordapp.com/attachments/1150477954430816456/1192512440215277688/azakitdevelopmentlogoavatar.png?ex=65a958c1&is=6596e3c1&hm=fc6638bef39209397047b55d8afbec6e8a5d4ca932d8b49aec74cb342e2910dc&"}), { ['Content-Type'] = 'application/json' })
end
