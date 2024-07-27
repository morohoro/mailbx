fx_version 'cerulean'
games {'gta5'}

author 'SNL'
description 'Mailbox'
version '1.0.0'

client_script 'client.lua'
server_script {
    'locales/en.lua',
    'config.lua',
	'server.lua'
}

files({
    'html/ui.html',
    'html/script.js',
    'html/bg.png'
})

ui_page 'html/ui.html'

dependency 'qb-core'