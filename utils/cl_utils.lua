local client = require 'configs.cl_config'
local utils = {}

utils.notify = function(data)
  if client.interaction == 'ox' then
    lib.notify({
      title = data.title or '',
      description = data.description or '',
      type = data.type or 'info',
      position = data.position or 'bottom',
      duration = data.duration or 3000,
    })
  elseif client.interaction == 'qb' then
    TriggerEvent('QBCore:Notify', data.description or '', data.type or 'primary', data.duration or 3000)
  end
end

utils.progressBar = function(data)
  local success

  if client.interaction == 'ox' then
    success = lib.progressBar({
      duration = data.duration,
      position = 'bottom',
      label = data.label,
      useWhileDead = false,
      allowRagdoll = data.allowRagdoll or false,
      allowCuffed = data.allowCuffed or false,
      allowFalling = data.allowFalling or false,
      allowSwimming = data.allowSwimming or false,
      canCancel = data.canCancel ~= false,
      disable = data.disable,
      anim = data.anim,
      prop = data.prop,
    })

  elseif client.interaction == 'qb' then
    local QBCore = exports['qb-core']:GetCoreObject()

    QBCore.Functions.Progressbar(
      data.label,
      data.label,
      data.duration,
      false,
      data.canCancel ~= false,
      {
        disableMovement = data.disable and data.disable.move or false,
        disableCarMovement = data.disable and data.disable.car or false,
      },
      data.anim and {
        animDict = data.anim.dict,
        anim = data.anim.clip,
      } or {},
      {},
      {},
      function()
        success = true
        if data.onSuccess then data.onSuccess() end
      end,
      function()
        success = false
        if data.onCancel then data.onCancel() end
      end
    )

    return
  end

  if success then
    if data.onSuccess then data.onSuccess() end
    return true
  else
    if data.onCancel then data.onCancel() end
    return false
  end
end


utils.getTargetOptions = function(options)
  local targetOptions = {}

  if type(options) ~= 'table' then
    return targetOptions
  end

  if client.interaction == 'ox' then
    for i = 1, #options do
      targetOptions[i] = {
        icon = options[i].icon,
        items = type(options[i].items) == 'table' and options[i].items or { options[i].items },
        label = options[i].label,
        onSelect = options[i].onSelect,
        canInteract = options[i].canInteract,
        distance = options[i].distance or 2.0,
      }
    end

  elseif client.interaction == 'qb' then
    for i = 1, #options do
      targetOptions[i] = {
        icon = options[i].icon,
        item = options[i].items,
        label = options[i].label,
        action = function(entity, distance, data)
          options[i].onSelect({
            entity = entity,
            distance = distance,
            data = data
          })
        end,
        canInteract = options[i].canInteract,
        distance = options[i].distance or 2.0,
      }
    end
  end

  return targetOptions
end

utils.addSphereTarget = function(data)
  if client.interaction == 'ox' then
    return exports.ox_target:addSphereZone({
      coords = data.coords,
      radius = data.radius or 1.0,
      debug = data.debug or false,
      options = utils.getTargetOptions(data.options)
    })

  elseif client.interaction == 'qb' then
    local name = data.name or ('l3th-graverob:%s:%s:%s'):format(data.coords.x, data.coords.y, data.coords.z)

    return exports['qb-target']:AddCircleZone(name, data.coords, data.radius or 1.0, {
      name = name,
      debugPoly = data.debug or false,
      useZ = true,
    }, {
      options = utils.getTargetOptions(data.options),
      distance = data.distance or client.maxDistance or 2.5,
    })
  end
end

utils.addEntityTarget = function(entity, options)
  if client.interaction == 'ox' then
    return exports.ox_target:addLocalEntity(entity, utils.getTargetOptions(options))

  elseif client.interaction == 'qb' then
    return exports['qb-target']:AddTargetEntity(entity, {
      options = utils.getTargetOptions(options),
      distance = client.maxDistance or 2.5,
    })
  end
end

utils.removeEntityTarget = function(entity)
  if not entity then
    return
  end

  if client.interaction == 'ox' then
    exports.ox_target:removeLocalEntity(entity)
  elseif client.interaction == 'qb' then
    exports['qb-target']:RemoveTargetEntity(entity)
  end
end

utils.removeZone = function(zone)
  if not zone then
    return
  end

  if client.interaction == 'ox' then
    exports.ox_target:removeZone(zone)
  elseif client.interaction == 'qb' then
    exports['qb-target']:RemoveZone(zone)
  end
end

return utils