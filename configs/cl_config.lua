return {
  debug = false, -- Enable debug messages in the server console and F8 console
  interaction = 'ox', -- 'ox', 'qb' or 'custom' (This is for Target, Progressbar and notify)
  -- minigame = 'tgg', -- 'sk-minigames', 'ox', 'glitch-minigames' or 'custom'
  dispatch = 'tk_dispatch', -- tk_dispatch', 'ps-dispatch', 'cd_dispatch', 'fd-dispatch' or 'custom'

  policeChance = 30, -- Chance in percent that the police will be alerted when a player starts robbing a gravestone
  
  npc = { -- Location where the NPC will be spawned, if you don't want an NPC, just remove the coords and model
    coords = vec4(-785.31, 34.78, 40.65, 217.91),
    model = 'a_f_y_epsilon_01'
  },
}
