# 🪦 l3th-graverob — Grave Robbery

A standalone-ish grave robbery job for FiveM. Players talk to an NPC, drive to a randomly selected gravestone marked on their GPS, dig it up with a shovel animation, and receive a randomized loot reward. Police can be alerted via dispatch while digging.

Works with **ox** or **qb** for target/progressbar/notify, and supports **ox_inventory / qb-inventory / ps-inventory** for rewards.

---

## ✨ Features

- NPC quest-giver that spawns only when a player is nearby (35m), and is cleaned up when they leave.
- Random grave location each job, marked with a radius blip + a target zone to interact with.
- Shovel prop + kneeling dig animation via `lib.progressBar`.
- Configurable time limit — the job auto-cancels if not completed in time.
- Weighted loot table with an optional bonus "special" reward roll.
- Optional police dispatch alert with a configurable chance.
- Multi-framework bridges for target, progressbar, notify, inventory, and dispatch.

---

## 📋 Requirements

| Dependency | Required | Notes |
|---|---|---|
| [ox_lib](https://github.com/overextended/ox_lib) | ✅ Yes | Callbacks, zones, progressbar, locale, requestModel. |
| **A target system** | ✅ Yes | `ox_target` **or** `qb-target` (set in config). |
| **An inventory** | ✅ Yes | `ox_inventory`, `qb-inventory`, **or** `ps-inventory` (auto-detected). |
| **A dispatch system** | ⚠️ Optional | `tk_dispatch`, `ps-dispatch`, `cd_dispatch`, or `fd-dispatch`. |

> ⚠️ The `fxmanifest.lua` uses `lua54 'yes'` — make sure `lua54` is enabled for the resource (it is, via the manifest) and your server supports it.

---

## 📦 Installation

1. **Place the resource** in your server's resources folder, keeping the name `l3th-graverob`:

   ```
   resources/[scripts]/[custom]/[l3th]/l3th-graverob
   ```

2. **Ensure it starts** in your `server.cfg`, *after* its dependencies:

   ```cfg
   ensure ox_lib
   ensure ox_target          # or qb-target
   ensure ox_inventory       # or qb-inventory / ps-inventory
   # ensure your dispatch resource here if used (e.g. tk_dispatch)

   ensure l3th-graverob
   ```

3. **Add the reward items** to your inventory. The default loot table (see below) references items like `lockpick`, `silver_coin`, `gold_coin`, `goldbar`, `ancient_egypt_artifact`, etc. Any item you list in `rewards` / `specialReward` **must exist in your inventory's item list**, or the `addItem` call will silently do nothing.

4. **Configure** the client and server configs (next section).

5. **Restart your server** (or `ensure l3th-graverob` / `refresh; ensure l3th-graverob`).

---

## ⚙️ Configuration

### Client — `configs/cl_config.lua`

```lua
return {
  debug = false,            -- Debug prints + visible zones (F8 / server console)
  interaction = 'ox',       -- 'ox' or 'qb' — used for target, progressbar, and notify
  dispatch = 'tk_dispatch', -- 'tk_dispatch', 'ps-dispatch', 'cd_dispatch', 'fd-dispatch', or 'custom'
  policeChance = 30,        -- % chance dispatch is alerted when a player starts digging

  npc = {                   -- Quest-giver NPC. Remove this block if you don't want an NPC.
    coords = vec4(-785.31, 34.78, 40.65, 217.91),
    model = 'a_f_y_epsilon_01',
  },
}
```

| Key | Description |
|---|---|
| `debug` | Enables debug prints and renders target/zone outlines. Leave `false` in production. |
| `interaction` | Which framework handles target/progressbar/notify. `'ox'` or `'qb'`. |
| `dispatch` | Which dispatch system to alert. Set to `'custom'` to disable / wire your own. |
| `policeChance` | Percent chance (0–100) the police get pinged when a dig starts. |
| `npc.coords` | `vec4` spawn position + heading of the quest NPC. |
| `npc.model` | Ped model for the quest NPC. |

### Server — `configs/sv_config.lua`

| Key | Description |
|---|---|
| `timeLimit` | Minutes a player has to complete the job before it auto-cancels. Default `10`. |
| `robLocations` | List of `vector3` gravestone coords. One is chosen at random per job. Add/remove freely. |
| `rewards` | Weighted loot table. **The `chance` values must add up to 100.** Use `item = nil` for a "found nothing" slot. |
| `specialRewardChance` | Percent chance (0–100) of also granting the `specialReward` on success. |
| `specialReward` | The bonus item (and optional `amount`) granted on a successful special roll. |

#### Loot table notes

- Each reward entry: `{ item = 'name', chance = N, amount = N }`.
- `chance` is a weight rolled against `math.random(1, 100)` cumulatively — **all entries' `chance` must total exactly 100**, or the high end of the table can become unreachable.
- An entry with `item = nil` represents getting nothing (the default config reserves `15%` for this).

---

## 🎮 How It Works (player flow)

1. Player approaches the NPC and selects **"Start grave robbery mission"**.
2. Server picks a random grave from `robLocations`, sets a time limit, and sends the player a GPS blip + radius.
3. Player drives to the grave and uses the **"Digging up the grave"** target option.
4. A ~25s dig animation plays (shovel prop). There's a `policeChance` of dispatch being alerted.
5. On completion, the server verifies the player is near the grave, then rolls the loot table and grants rewards.
6. If the player doesn't finish within `timeLimit` minutes, the job cancels automatically.

---

## 🧰 Debug Commands

Useful while configuring locations or tuning the animation:

| Command | Description |
|---|---|
| `gr` | Triggers `requestJob()` directly (skip walking to the NPC). |
| `granim` | Plays just the dig animation + shovel prop, with no job/NPC/zone required. |

> These are registered in `client/client.lua`. Remove or gate them behind `client.debug` before going to production if you don't want players using them.

---

## 🌍 Localization

Locale files live in `locales/` (`en.json`, `da.json`). Strings cover dispatch text, job status messages, errors, and NPC labels. Add your own `<lang>.json` and set the locale via ox_lib's standard `ox_lib` locale convar.

---

## 🛠️ Troubleshooting

- **No prop / no crouch in the dig animation** — ensure the animation dictionary `random@burial` loads; the prop is `prop_tool_shovel`. Offsets are tuned in `digProp` inside `client/client.lua`.
- **No rewards given** — the reward `item` must exist in your inventory's item list, and your inventory must be one of `ox_inventory` / `qb-inventory` / `ps-inventory`.
- **Loot feels off / top rewards never drop** — your `rewards` `chance` values don't add up to 100.
- **No dispatch alert** — confirm `dispatch` in the client config matches an installed/started dispatch resource, and that `policeChance` isn't `0`.
- **Nothing happens at the NPC** — confirm your `interaction` setting matches an installed target system (`ox_target` / `qb-target`).

---

## 📁 Structure

```
l3th-graverob/
├── client/client.lua        # NPC, zones, dig flow, debug commands
├── server/server.lua        # Job state, time limit, reward rolls
├── configs/
│   ├── cl_config.lua        # Client config
│   └── sv_config.lua        # Server config (locations, rewards, time limit)
├── bridge/
│   ├── dispatch/client.lua  # Dispatch system adapters
│   └── inventory/           # Inventory adapters (client/server)
├── utils/                   # Target / progressbar / notify wrappers
├── locales/                 # en.json, da.json
└── fxmanifest.lua
```

---

## 📄 Credits

- Author: **L3th**

> ℹ️ Note: this resource was adapted from a mailbox-robbery base, so a couple of manifest fields (`description`, `repository`) and some default dispatch strings still reference "mail box". Cosmetic only — update them if it bothers you.
