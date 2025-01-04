-- CLIENT
local spawnedcow = {}
local cowCoordsMap = {}

---@param resourceName string
---@return nil
local function deleteAll(resourceName)
    if GetCurrentResourceName() ~= resourceName then        
        return
    end

    for k, v in pairs(spawnedcow) do
        DeletePed(v)
    end
    spawnedcow = {}
    cowCoordsMap = {}
end

---@param hash number
---@return number? hash
local function requestModel(hash)
    if not tonumber(hash) then return end
    if not IsModelValid(hash) then return end
    if HasModelLoaded(hash) then return hash end

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(50)
    end
    return hash
end

---@param animDict string
---@return string? animDict
local function requestAnimDict(animDict)
    if type(animDict) ~= 'string' then
        return -- print(('Expected animDict to have type string (received %s)'):format(type(animDict)))
    end

    if not DoesAnimDictExist(animDict) then
        return -- print(('Attempted to load invalid animDict %s'):format(animDict))
    end

    if HasAnimDictLoaded(animDict) then 
        return animDict 
    end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(50)
    end

    return animDict
end

---@param coords vector3
---@return boolean
local function isCowAtCoords(coords)
    for _, cow in pairs(spawnedcow) do
        local cowCoords = GetEntityCoords(cow)
        if #(cowCoords - vector3(coords.x, coords.y, coords.z)) < 1.0 then
            return true
        end
    end
    return false
end

RegisterNetEvent('azakit_cowmilking:syncCows')
AddEventHandler('azakit_cowmilking:syncCows', function()
    for i, cowData in ipairs(Cow) do
        -- Check if the cow has already been created
        if not spawnedcow[i] and not isCowAtCoords(cowData.cowCoords) then
            requestModel(`a_c_cow`)

            -- Create cow at the coordinates specified in the config
            local createdcow = CreatePed('cow', `a_c_cow`, cowData.cowCoords.x, cowData.cowCoords.y, cowData.cowCoords.z, cowData.cowCoords.w, false, false)

            -- Apply the settings specified in the config
            local settings = cowData.cowsettings or {}
            FreezeEntityPosition(createdcow, settings.Freezecow or false)
            SetEntityInvincible(createdcow, settings.Invincible or false)
            SetBlockingOfNonTemporaryEvents(createdcow, settings.BlockingOfNonTemporaryEvents or false)
            SetPedDiesWhenInjured(createdcow, not (settings.Invincible or false))
            SetPedCanPlayAmbientAnims(createdcow, settings.Invincible or false)
            SetPedCanRagdollFromPlayerImpact(createdcow, not (settings.Invincible or false))

            -- Start the cow grazing animation
            TaskStartScenarioInPlace(createdcow, 'WORLD_COW_GRAZING', -1, true)

            -- Register the cow in the spawned list
            spawnedcow[i] = createdcow

            -- Add interaction using ox_target or qb-target
            if InteractionType == "ox_target" then
                exports.ox_target:addLocalEntity(createdcow, {
                    label = _("start_milking"),
                    name = 'milking',
                    icon = 'fa-solid fa-eye',
                    distance = 1.7,
                    onSelect = function()
                        InteractMilking()
                    end
                })
            elseif InteractionType == "qb-target" then
                exports['qb-target']:AddTargetEntity(createdcow, {
                    options = {
                        {
                            type = "client",
                            event = "azakit_cowmilking:InteractMilking",
                            icon = "fa-solid fa-eye",
                            label = _("start_milking"),
                        },
                    },
                    distance = 1.7
                })
            else
                print("^1ERROR: Unknown InteractionType! Only 'ox_target' or 'qb-target' are supported.^0")
            end
        else
            -- Print an error if the cow already exists at this location
            -- print(("Cow already exists at coordinates: %.2f, %.2f, %.2f"):format(cowData.cowCoords.x, cowData.cowCoords.y, cowData.cowCoords.z))
        end
    end
end)


-- Request cow states from the server when the player spawns
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('azakit_cowmilking:requestCows')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent('azakit_cowmilking:requestCows')
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, cow in pairs(spawnedcow) do
            DeleteEntity(cow)
        end
        spawnedcow = {}
    end
end)

RegisterNetEvent('azakit_cowmilking:InteractMilking', function()
    InteractMilking()
end)

function ExchangeRequest(index)
    TriggerServerCallback("azakit_cowmilking:exchangeProcess", function(result)
        if result then
            lib.notify({
                position = 'top',
                title = _("reward"),
                type = 'success'
            })
        else
            lib.notify({
                position = 'top',
                title = _("noitem"),
                type = 'error'
            })
        end
    end, index)
end

function InteractMilking(index)
    if Interact then return end
    Interact = true
    local ped = PlayerPedId()
    RequestAnimDict('mini@repair')
    while not HasAnimDictLoaded('mini@repair') do
        Wait(500)
    end
        
    --  lib.requestAnimDict('mini@repair', 10)
    TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 48, 0)
    if Check.EnableSkillCheck then
        local success = lib.skillCheck(SkillCheckDifficulty, SkillCheckKeys) 
        if success then 
            ExchangeRequest(index)
        else
            lib.notify({
                position = 'top',
                title = _("failed"),
                type = 'error'
            })
        end
    else
        lib.progressCircle({
            duration = 1000 * Check.ProcessTime,
            label = _("process"),
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true },
            anim = { dict = 'mini@repair', clip = 'fixing_a_ped' }
        })
        ExchangeRequest(index)
    end
    ClearPedTasks(ped)
    Interact = false  
end

-- exports("useItem", ...) call
exports("useItem", function(data, slot)
    local itemName = data.name
    local hasBucketMilk = false
    local hasEnoughBottles = false

    if FrameworkType == "ESX" then
        local playerInventory = ESX.GetPlayerData().inventory
        for _, item in ipairs(playerInventory) do
            if item.name == BUCKETMILK then
                hasBucketMilk = item.count >= 1
            elseif item.name == BOTTLE then
                hasEnoughBottles = item.count >= BOTTLE_AMOUNT
            end
        end
    elseif FrameworkType == "QBCore" then
        local player = QBCore.Functions.GetPlayerData()
        hasBucketMilk = GetItemCount(player.items, BUCKETMILK) >= 1
        hasEnoughBottles = GetItemCount(player.items, BOTTLE) >= BOTTLE_AMOUNT
    end

    print("Debug: hasBucketMilk =", hasBucketMilk, "hasEnoughBottles =", hasEnoughBottles) -- Debug log

    if hasBucketMilk and hasEnoughBottles then
        -- Trigger the milking event only if the player has enough items
        TriggerEvent('azakit_cowmilking:bucketmilk', itemName)
    else
        -- Notify the player they don't have the necessary items
        lib.notify({
            type = 'error',
            title = _("need_more"),
            position = 'top'
        })
    end
end)

-- Function to get item count from inventory for QBCore
function GetItemCount(items, itemName)
    for _, item in pairs(items) do
        if item.name == itemName then
            return item.amount
        end
    end
    return 0
end


RegisterNetEvent('azakit_cowmilking:bucketmilk')
AddEventHandler('azakit_cowmilking:bucketmilk', function()
    if FILLS then
        -- Show the progress circle and start the animation
        local ped = PlayerPedId()
        
        -- Request the animation dictionary before playing the animation
        RequestAnimDict('mini@repair')
        while not HasAnimDictLoaded('mini@repair') do
            Wait(100)
        end

        -- Play the animation while milking
        TaskPlayAnim(ped, 'mini@repair', 'fixing_a_ped', 8.0, -8.0, -1, 48, 0)

        -- Show the progress circle for the specified time
        lib.progressCircle({
            duration = 1000 * Check.ProcessTime,
            label = _("process_bottle"),
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true },
            anim = { dict = 'mini@repair', clip = 'fixing_a_ped' }
        })

        -- Trigger the server event to process the bucket milk action
        TriggerServerEvent('azakit_cowmilking:bucketmilk')

        -- Clear the animation once it's done
        ClearPedTasks(ped)
    else
        Wait(1000)
    end
end)
