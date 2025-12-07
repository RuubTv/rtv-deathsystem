local QBCore = exports['qb-core']:GetCoreObject()
local ActiveDeaths = {}

local function GetJobGrade(job)
    if not job then return 0 end
    if type(job.grade) == 'table' and job.grade.level then
        return job.grade.level
    end
    return job.grade or 0
end

local function IsAllowedToDeclare(player)
    if not player then return false end
    local job = player.PlayerData.job
    if not job or not job.name then return false end

    local jobConfig = Config.AllowedJobs[job.name]
    if not jobConfig then return false end

    local grade = GetJobGrade(job)
    return grade >= (jobConfig.minGrade or 0)
end

local function AddDeath(citizenid, expiresAt)
    ActiveDeaths[citizenid] = {
        citizenid = citizenid,
        expiresAt = expiresAt
    }

    MySQL.insert('INSERT INTO mortuary_deaths (citizenid, expires_at) VALUES (?, ?)', {
        citizenid,
        expiresAt
    })
end

local function RemoveDeath(citizenid)
    ActiveDeaths[citizenid] = nil
    MySQL.update('DELETE FROM mortuary_deaths WHERE citizenid = ?', { citizenid })
end

local function WipeInventoryWithBlacklist(src)
    if not Config.Inventory.WipeOnNLR then return end

    local blacklist = {}
    for _, itemName in ipairs(Config.Inventory.Blacklist or {}) do
        blacklist[itemName] = true
    end

    local items = exports.ox_inventory:GetInventoryItems(src)
    if not items then return end

    for slot, item in pairs(items) do
        if item and item.name and not blacklist[item.name] then
            exports.ox_inventory:RemoveItem(src, item.name, item.count, item.metadata, slot)
        end
    end
end

local function GetRandomWakeupLocation()
    local wakeups = Config.Locations.GraveyardWakeups

    if type(wakeups) ~= 'table' or #wakeups == 0 then
        return Config.Locations.GraveyardCorpse
    end

    local idx = math.random(1, #wakeups)
    return wakeups[idx]
end

local function FinishDeath(citizenid)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if not Player then
        RemoveDeath(citizenid)
        return
    end

    local src = Player.PlayerData.source
    print(('[mortuary] FinishDeath for %s (src: %s)'):format(citizenid, src))

    WipeInventoryWithBlacklist(src)

    local ok, err = pcall(function()
        Config.RevivePlayer(src)
    end)

    if not ok then
        print(('[mortuary] ERROR in Config.RevivePlayer for %s: %s'):format(citizenid, err))
    else
        print(('[mortuary] RevivePlayer executed for %s'):format(citizenid))
    end


    local wakeupLoc = GetRandomWakeupLocation()
    TriggerClientEvent('mortuary:client:EndDeathFlow', src, wakeupLoc)

    RemoveDeath(citizenid)

    TriggerClientEvent('mortuary:client:NotifyNLR', src)
end

CreateThread(function()
    while true do
        local now = os.time()
        for citizenid, data in pairs(ActiveDeaths) do
            if data.expiresAt <= now then
                FinishDeath(citizenid)
            end
        end
        Wait(5000)
    end
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end

    MySQL.query('SELECT * FROM mortuary_deaths', {}, function(rows)
        if not rows or #rows == 0 then return end
        for _, row in ipairs(rows) do
            ActiveDeaths[row.citizenid] = {
                citizenid = row.citizenid,
                expiresAt = row.expires_at
            }
        end
    end)
end)

RegisterNetEvent('QBCore:Server:PlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT * FROM mortuary_deaths WHERE citizenid = ? LIMIT 1', { citizenid }, function(rows)
        local row = rows and rows[1]
        if not row then return end

        ActiveDeaths[citizenid] = {
            citizenid = citizenid,
            expiresAt = row.expires_at
        }

        local now = os.time()
        if row.expires_at <= now then
            FinishDeath(citizenid)
        else
            local remaining = row.expires_at - now
            if remaining < 0 then remaining = 0 end
            TriggerClientEvent('mortuary:client:ResumeDeathFlow', src, remaining)
        end
    end)
end)

local function HandleDeclareDead(medicSrc, targetId, minutes)
    local Medic = QBCore.Functions.GetPlayer(medicSrc)
    if not Medic then return end

    if not IsAllowedToDeclare(Medic) then
        TriggerClientEvent('mortuary:client:NotifyError', medicSrc, _L('declare_no_permission'))
        return
    end

    local Target = QBCore.Functions.GetPlayer(tonumber(targetId) or 0)
    if not Target then
        TriggerClientEvent('mortuary:client:NotifyError', medicSrc, _L('declare_invalid_target'))
        return
    end

    local citizenid = Target.PlayerData.citizenid

    minutes = tonumber(minutes) or Config.Time.Min
    if minutes < Config.Time.Min or minutes > Config.Time.Max then
        TriggerClientEvent('mortuary:client:NotifyError', medicSrc,
            _L('declare_settime_error', Config.Time.Min, Config.Time.Max))
        return
    end

    local expiresAt = os.time() + (minutes * 60)
    local remainingSeconds = minutes * 60

    AddDeath(citizenid, expiresAt)

    TriggerClientEvent('mortuary:client:NotifySuccess', medicSrc, _L('declare_success_medic'))
    TriggerClientEvent('mortuary:client:NotifySuccess', Target.PlayerData.source, _L('declare_success_patient'))
    TriggerClientEvent('mortuary:client:StartDeathFlow', Target.PlayerData.source, remainingSeconds, Config.Locations)
end

RegisterNetEvent('mortuary:server:DeclareDead', function(targetId, minutes)
    local src = source
    HandleDeclareDead(src, targetId, minutes)
end)

QBCore.Commands.Add('mortuary', 'Stuur een speler naar het kerkhof (ambulance only)', {
    { name = 'id', help = 'Speler ID' },
    { name = 'time', help = 'Tijd in minuten (tussen ' .. Config.Time.Min .. ' en ' .. Config.Time.Max .. ')' }
}, false, function(source, args)
    local src = source
    local targetId = args[1]
    local minutes = args[2]

    if not targetId then
        TriggerClientEvent('mortuary:client:NotifyError', src, 'Gebruik: /mortuary [id] [tijd]')
        return
    end

    HandleDeclareDead(src, targetId, minutes)
end, 'user') 
