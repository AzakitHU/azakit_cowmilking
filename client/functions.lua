---@param data table
function AddEntityMenuItem(data)
    if GetResourceState("ox_target") == "started" then
        exports.ox_target:addLocalEntity(data.entity, {
            label = data.desc,
            name = data.event,
            event = data.event,
            distance = 1.5
          })
    end
end

---@param data table
function RemoveEntityMenuItem(data)
    if GetResourceState("ox_target") == "started" then
        exports.ox_target:removeLocalEntity(data.entity, data.event)
    end
end