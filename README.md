# Mortuary NLR

Small add-on to your ambulance/death system.  
EMS can **fully remove a player from a situation** using `/mortuary`.  
The player gets a **full-screen NUI with a countdown** (optional video), stays “out of the world” for the configured time, then is **revived and inventory wiped** at the graveyard.  
After waking up, the **New Life Rule (NLR)** applies.

## Features
- `/mortuary [id] [time]` (EMS-only via config job/grade)
- No mortuary location used
- Fade → NUI overlay
- Min/max timer via config
- DB persistence by `citizenid` (crash/relog + restart safe)
- Automatic DB cleanup after completion
- Inventory wipe with blacklist option
- Configurable revive function (default OSP, easy to switch to other revive functions)
- Random graveyard wake-up spots to prevent stacking/camping
- Locales: `nl` + `en`

## Dependencies
- `qb-core` (or Qbox with QBCore bridge)
- `ox_lib`
- `ox_inventory`
- `oxmysql`

## Install
1. Place the resource in `resources/`
2. Add to `server.cfg`:
