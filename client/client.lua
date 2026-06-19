local client = require("configs.cl_config")
local utils = require("utils.cl_utils")
local dispatch = require("bridge.dispatch.client")

local ped = nil
local npcTarget = nil
local job = {
  active = false,
  blip = nil,
  targetZone = nil,
}

local digAnim = {
  dict = 'random@burial',
  clip = 'a_burial',
  flag = 1,
}

local digProp = {
  model = `prop_tool_shovel`,
  bone = 28422,
  pos = vec3(0.0, 0.0, 0.22),
  rot = vec3(0.0, 0.0, 0.0),
}

local function startDigging()
  if not job.active then return end

  if math.random(100) <= client.policeChance then
    dispatch.sendCall({
      title = locale('dispatch.title'),
      code = locale('dispatch.code'),
      priority = locale('dispatch.priority'),
      message = locale('dispatch.message'),
      coords = objCoords,
      showLocation = true,
      showDirection = false,
    })
  end

  local success = utils.progressBar({
    duration = 25000,
    label = locale('job.progress_label'),
    allowFalling = true,
    canCancel = true,
    disable = {
      move = true,
      car = true,
      combat = true,
    },
    anim = digAnim,
    prop = digProp,
  })

  if success then
    ClearPedTasks(cache.ped)

    TriggerServerEvent('l3th-graverob:server:completeJob')
  else
    ClearPedTasks(cache.ped)
    utils.notify({
      description = locale('job.failed'),
      type = 'error',
    })
  end
end

lib.callback.register('l3th-graverob:server:createJob', function(coords, misCoords, radius)
  job.active = true

  if job.blip then
    RemoveBlip(job.blip)
  end

  job.blip = AddBlipForRadius(coords.x, coords.y, coords.z, radius)

  SetBlipColour(job.blip, 27)
  SetBlipAlpha(job.blip, 128)

  if job.targetZone then
    utils.removeZone(job.targetZone)
  end

  job.targetZone = utils.addSphereTarget({
    coords = misCoords,
    radius = 1.5,
    debug = client.debug,
    options = {
      {
        icon = 'fa-solid fa-person-digging',
        label = locale('job.target_label'),
        onSelect = function()
          startDigging()
        end,
        canInteract = function()
          return job.active
        end
      }
    }
  })
  return true
end)

local function requestJob()
  if job.active then
    utils.notify({
      description = locale('error.already_active'),
      type = 'error',
    })
    return
  end

  local data = lib.callback.await('l3th-graverob:server:requestJob', false)
end

RegisterNetEvent('l3th-graverob:client:stopJob', function()
  job.active = false

  if job.blip then
    RemoveBlip(job.blip)
    job.blip = nil
  end

  if job.targetZone then
    utils.removeZone(job.targetZone)
    job.targetZone = nil
  end
end)

local function spawnPed()
  if ped and DoesEntityExist(ped) then return end

  local model = client.npc.model
  local coords = client.npc.coords

  lib.requestModel(model)
  while not HasModelLoaded(model) do
    Wait(0)
  end

  ped = CreatePed(4, model, coords.x, coords.y, coords.z - 1, coords.w, false, false)
  TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
  FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)

  Wait(250)

  npcTarget = utils.addEntityTarget(ped, {
    {
      icon = 'fa-solid fa-clipboard-list',
      label = locale('other.npc_start_label'),
      distance = 2.5,
      onSelect = function()
        requestJob()
      end,
      canInteract = function()
        return not job.active
      end
    }
  })

  SetModelAsNoLongerNeeded(model)
end

local function deletePed()
  if ped and DoesEntityExist(ped) then
    utils.removeEntityTarget(ped)
    DeleteEntity(ped)
    ped = nil
    npcTarget = nil
    if client.debug then print("[Debug] Grave Rob NPC deleted.") end
  end
end

local sphere = lib.zones.sphere({
  coords = client.npc.coords,
  radius = 35,
  debug = client.debug,
  onEnter = function()
    spawnPed()
  end,
  onExit = function()
    deletePed()
  end,
})

AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    deletePed()
    if job.blip then
      RemoveBlip(job.blip)
    end
    if job.targetZone then
      utils.removeZone(job.targetZone)
    end
    job.active = false
    job.blip = nil
    job.targetZone = nil
  end
end)