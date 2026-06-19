local clConfig = require 'configs.cl_config'
local svConfig = require 'configs.sv_config'
local utils = require 'utils.sv_utils'
local inventory = require 'bridge.inventory.server'

local job = {
  active = false,
  misCoords = nil,
}

local function deleteJob(src)
  job.active = false
  job.misCoords = nil

  if src then
    TriggerClientEvent('l3th-graverob:client:stopJob', src)
  end
end

local function createRadiusCoords(coords, radius)
  if not coords or not radius or radius <= 0 then
    return coords
  end

  local angle = math.random() * (math.pi * 2)
  local distance = math.sqrt(math.random()) * radius
  local offsetX = math.cos(angle) * distance
  local offsetY = math.sin(angle) * distance
  local newCoords = vector3(coords.x + offsetX, coords.y + offsetY, coords.z)

  return newCoords
end

lib.callback.register('l3th-graverob:server:requestJob', function(source)
  local src = source
  if job.active then
    utils.notify({
      source = src,
      description = locale('error.already_active'),
      type = 'error',
    })
    return
  end

  job.active = true
  utils.notify({
    source = src,
    description = (locale('job.accepted')):format(svConfig.timeLimit),
    type = 'success',
  })

  -- Create a timeout for the job, if the player doesn't complete it within the time, it will be cancelled
  SetTimeout(svConfig.timeLimit * 60 * 1000, function() -- Time limit from config
    if job.active then
      job.active = false
      utils.notify({
        source = src,
        description = locale('job.cancelled'),
        type = 'error',
      })
      deleteJob(src)
    end
  end)

  local coords = svConfig.robLocations[math.random(1, #svConfig.robLocations)]
  job.misCoords = coords
  local radiusCoords = createRadiusCoords(coords, 10.0) -- Create radius coords with a radius of 10.0
  local radius = 50.0
  local blipCreated = lib.callback.await('l3th-graverob:server:createJob', src, radiusCoords, coords, radius)
end)

RegisterNetEvent('l3th-graverob:server:completeJob', function()
  local src = source

  if not job.active then

    utils.notify({
      source = src,
      description = locale('error.no_active_job'),
      type = 'error',
    })
    return
  end

  job.active = false

  local success = utils.isNearCoords(src, job.misCoords, 5.0)

  if not success then

    utils.notify({
      source = src,
      description = locale('error.not_near_location'),
      type = 'error',
    })
    return
  end

  local function getReward()
    local roll = math.random(1, 100)
    local cumulative = 0

    for _, reward in ipairs(svConfig.rewards or {}) do
      cumulative = cumulative + reward.chance
      if roll <= cumulative then

        return reward
      end
    end
  end

  local reward = getReward()
  if reward and reward.item then

    inventory.addItem(src, reward.item, reward.amount)
    if math.random(1, 100) < svConfig.specialRewardChance then
      local rareReward = svConfig.specialReward
      local rareAmount = rareReward.amount or 1

      inventory.addItem(src, rareReward.item, rareAmount)
      utils.notify({
        source = src,
        description = locale('job.completed_rare'),
        type = 'success',
      })
    else

      utils.notify({
        source = src,
        description = locale('job.completed'),
        type = 'success',
      })
    end
  else

    utils.notify({ source = src, description = locale('error.nothing_found'), type = 'info' })
  end

  deleteJob(src)
end)