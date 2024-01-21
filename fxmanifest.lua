fx_version   'cerulean'
lua54        'yes'
game         'gta5'

name         'azakit_cowmilking'
version      '1.0.0'
author       'Azakit'
description  'Milking a cow'

client_scripts {
    'config.lua',
	"locales/*",
    'client/*'
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"locales/*",
	'config.lua',
    'server/*'
}

shared_scripts {
    '@ox_lib/init.lua',
	'@es_extended/imports.lua',
}
