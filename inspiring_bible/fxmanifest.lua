fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'inspiring_bible'
author 'OpenAI Codex'
description 'Beautiful Bible UI for QBCore with ox_inventory and ox_target support.'
version '1.0.0'

ui_page 'web/index.html'

shared_scripts {
    'config.lua',
    'shared/verses.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}
