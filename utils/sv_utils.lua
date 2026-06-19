local utils = {}
local client = require 'configs.cl_config'

utils.isNearCoords = function(playerId, coords, nearDis)
    if not playerId or not coords or not nearDis then
        return false
    end

    local ped = GetPlayerPed(playerId)
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        return false
    end

    local entityCoords = GetEntityCoords(ped)
    local distance = #(entityCoords - coords)
    return distance < nearDis
end

utils.notify = function(data)
    if client.interaction == 'ox' then
        TriggerClientEvent('ox_lib:notify', data.source, data)
    elseif client.interaction == 'qb' then
        TriggerClientEvent('QBCore:Notify', data.source, data.description, data.type or 'success', data.length or 5000)
    end
end

return utils