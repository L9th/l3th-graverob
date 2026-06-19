local inventory = {}
local QBCore = nil

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

inventory.addItem = function(source, item, count, metadata)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(source, item, count, metadata or nil)
    elseif GetResourceState('qb-inventory') == 'started' then
        return exports['qb-inventory']:AddItem(source, item, count)
    elseif GetResourceState('ps-inventory') == 'started' then
        return exports['ps-inventory']:AddItem(source, item, count)
    end
end

inventory.hasItem = function(source, item, count)
    count = count or 1

    if GetResourceState('ox_inventory') == 'started' then
        return (exports.ox_inventory:Search(source, 'count', item) or 0) >= count
    elseif GetResourceState('qb-inventory') == 'started' then
        return exports['qb-inventory']:HasItem(source, item, count)
    elseif GetResourceState('ps-inventory') == 'started' then
        return exports['ps-inventory']:HasItem(source, item, count)
    end

    return false
end

return inventory