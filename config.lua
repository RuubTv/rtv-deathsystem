Config = {}


Config.Locale = 'nl' -- 'en' or 'nl'

-- your revive export
Config.RevivePlayer = function(src)
    -- Example: qbx_medical
TriggerClientEvent('qbx_medical:client:playerRevived', src)
            -- OSP Ambulance
    --TriggerEvent('osp_ambulance:revive', src) -- OSP 
end

Config.Locations = {
    GraveyardCorpse = vec4(278.48, -1338.6, 24.34, 74.88),
    GraveyardWakeups = {
        vec4(-1684.75, -291.45, 50.89, 140.82),
        vec4(-329.47, 6153.76, 31.31, 49.52),
        vec4(-324.26, 2818.15, 58.45, 53.5),
        vec4(1839.9, 3672.24, 33.28, 214.22),
        vec4(-243.41, 6324.7, 31.43, 313.75),
        vec4(344.45, -1398.17, 31.51, 52.23),
        vec4(1150.78, -1530.27, 34.39, 327.78), -- add more if needed
        vec4(-1857.4, -347.56, 48.84, 143.47),
    }
}


Config.Time = {
    Min = 1,   -- in minutes
    Max = 20,   -- in minutes
}

Config.AllowedJobs = {
    ['ambulance'] = {
        minGrade = 1, -- Min grade to use the command
    }
}


Config.DeathVisual = 'bag' -- DONT TOUCH

Config.Visual = {
    MuteWorld = true,        -- No sounds set to false if you want to let the player hear sounds around him
    DisableControls = true,
}

Config.Inventory = {
    WipeOnNLR = true,
    Blacklist = {
        'id_card',
        'driver_license',
        -- add more items if needed
    }
}

Config.Nui = {
    Enabled = true,      -- set to false if you dont want to use the NUI and have a blackscreen
    ShowTimer = true,    -- timer text
    VideoEnabled = true, -- Video On/Off
}
