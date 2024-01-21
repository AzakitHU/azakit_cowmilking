local spawnedcow = {}
local count = 0

---@param resourceName string
---@return string? count
local function deleteAll(resourceName)
    if GetCurrentResourceName() ~= resourceName then        
        return
    end

    for k, v in pairs(spawnedcow) do
        DeletePed(v)
        count = count + 1
    end

    return -- print(('Delete Milk Cow'):format(count))
end

---@param hash number
---@return number? hash
local function requestModel(hash)
    if not tonumber(hash) then
        return -- print(('That value: %s its not number/hash. ``'):format(hash))
    end

    if not IsModelValid(hash) then
        return -- print(('Attempted to load invalid model %s'):format(hash))
    end

    if HasModelLoaded(hash) then
        return hash
    end

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

---Spawn cow
local function spawncow()
    
    for i = 1, #Cow, 1 do
        local cow = Cow[i]

        requestModel(`a_c_cow`)

        local createdcow = CreatePed('cow', `a_c_cow`, cow.cowCoords.x, cow.cowCoords.y, cow.cowCoords.z, cow.cowCoords.w, false, false)

        FreezeEntityPosition(createdcow, cow.cowsettings.Freezecow)

        SetEntityInvincible(createdcow, cow.cowsettings.Invincible)
        SetPedDiesWhenInjured(createdcow, not cow.cowsettings.Invincible)
        SetPedCanPlayAmbientAnims(createdcow, cow.cowsettings.Invincible)
        SetPedCanRagdollFromPlayerImpact(createdcow, not cow.cowsettings.Invincible)

        SetBlockingOfNonTemporaryEvents(createdcow, cow.cowsettings.BlockingOfNonTemporaryEvents)

        SetEntityAsMissionEntity(createdcow, true, true)
        SetModelAsNoLongerNeeded(`a_c_cow`)

        
        TaskStartScenarioInPlace(createdcow, 'WORLD_COW_GRAZING', -1, true)

        spawnedcow[i] = createdcow
        exports.ox_target:addLocalEntity(createdcow, {
            label = _("start_milking"),
            name = 'milking',
            icon = 'fa-solid fa-eye',
            distance = 1.7,
           onSelect = function()
                         InteractMilking()
                    end
        })
    end
end

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
          --  lib.requestAnimDict('mini@repair', 10)
			TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 48, 0)
            if Check.EnableSkillCheck then
                local success = lib.skillCheck({'easy', 'easy', 'easy', 'easy'}, { 'w', 'a', 's', 'd' }) 
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
                Wait(1000 * Check.ProcessTime)
                lib.progressCircle({
                    duration = Duration,
                    label = _("process"),
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        car = true,
                    },
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_ped'
                    },})
                ExchangeRequest(index)
            end
            ClearPedTasks(ped)
            Interact = false  
end

RegisterNetEvent('azakit_cowmilking:bucketmilk')
AddEventHandler('azakit_cowmilking:bucketmilk', function()
    if FILLS then
  TriggerServerEvent('azakit_cowmilking:bucketmilk')
    else
        Wait(1000)
    end
end)

---@param resourceName string
---@return function? spawncow
local function spawncowOnStart(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    return spawncow()
end

AddEventHandler('playerSpawned', spawncow)
AddEventHandler('onResourceStart', spawncowOnStart)
AddEventHandler('onResourceStop', deleteAll)
