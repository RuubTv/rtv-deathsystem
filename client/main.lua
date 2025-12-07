local IsMortuaryDead = false

local function OpenMortuaryUi(remainingSeconds)
    if Config.Nui and Config.Nui.Enabled then
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'openMortuaryUi',
            remainingSeconds = remainingSeconds or 0,
            showTimer = Config.Nui.ShowTimer,
            videoEnabled = Config.Nui.VideoEnabled,
        })
    end
end

local function CloseMortuaryUi()
    if Config.Nui and Config.Nui.Enabled then
        SendNUIMessage({
            action = 'closeMortuaryUi'
        })
    end
end


local function ApplyDeathVisual()
    if Config.Nui and Config.Nui.Enabled then
        DoScreenFadeOut(1500)
    else
        if Config.DeathVisual == 'black' or Config.DeathVisual == 'bag' then
            DoScreenFadeOut(1500)
        end
    end

    if Config.Visual and Config.Visual.DisableControls then
        CreateThread(function()
            while IsMortuaryDead do
                DisableAllControlActions(0)
                Wait(0)
            end
        end)
    end

end

local function ClearDeathVisual()
    if IsScreenFadedOut() then
        DoScreenFadeIn(1000)
    end
end

RegisterNetEvent('mortuary:client:NotifyError', function(msg)
    lib.notify({
        title = _L('error_title'),
        description = msg,
        type = 'error'
    })
end)

RegisterNetEvent('mortuary:client:NotifySuccess', function(msg)
    lib.notify({
        title = _L('success_title'),
        description = msg,
        type = 'success'
    })
end)


RegisterNetEvent('mortuary:client:NotifyNLR', function()
    CreateThread(function()
        Wait(1000)

        lib.alertDialog({
            header = _L('success_title'),
            content = _L('nlr_notice'),
            centered = true,
            cancel = false,
            labels = {
                confirm = 'OK'
            }
        })
    end)
end)

RegisterNetEvent('mortuary:client:StartDeathFlow', function(remainingSeconds, locations)
    IsMortuaryDead = true

    local ped = PlayerPedId()
    local loc = locations or Config.Locations

    FreezeEntityPosition(ped, true)

    lib.notify({
        title = _L('success_title'),
        description = _L('transfer_graveyard'),
        type = 'info'
    })

    Wait(3000)

    ApplyDeathVisual()

    Wait(1600)
    OpenMortuaryUi(remainingSeconds)

    SetEntityCoords(ped, loc.GraveyardCorpse.x, loc.GraveyardCorpse.y, loc.GraveyardCorpse.z - 1.0, false, false, false, true)
    SetEntityHeading(ped, loc.GraveyardCorpse.w)
end)

RegisterNetEvent('mortuary:client:ResumeDeathFlow', function(remainingSeconds)
    IsMortuaryDead = true

    local ped = PlayerPedId()
    local loc = Config.Locations

    SetEntityCoords(ped, loc.GraveyardCorpse.x, loc.GraveyardCorpse.y, loc.GraveyardCorpse.z - 1.0, false, false, false, true)
    SetEntityHeading(ped, loc.GraveyardCorpse.w)
    FreezeEntityPosition(ped, true)

    ApplyDeathVisual()
    Wait(1600)
    OpenMortuaryUi(remainingSeconds)

    lib.notify({
        title = _L('success_title'),
        description = _L('transfer_graveyard'),
        type = 'info'
    })
end)

RegisterNetEvent('mortuary:client:EndDeathFlow', function(wakeupLoc)
    local ped = PlayerPedId()
    local loc = wakeupLoc or Config.Locations.GraveyardCorpse

    IsMortuaryDead = false

    FreezeEntityPosition(ped, false)
    CloseMortuaryUi()
    ClearDeathVisual()

    SetEntityCoords(ped, loc.x, loc.y, loc.z, false, false, false, true)
    SetEntityHeading(ped, loc.w)
end)

RegisterNetEvent('mortuary:client:DebugForceRevive', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, 200)
    ClearPedTasksImmediately(ped)
end)
