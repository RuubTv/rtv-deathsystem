fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Doc Electroo'
description 'Mortuarium / NLR systeem for EMS'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua',
    'shared/locale.lua',
}

client_scripts {
    '@ox_target/export.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/video.mp4' -- zelf nog een mp4'tje toevoegen in de html-map
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}
