fx_version 'cerulean'
lua54 'yes'
game 'gta5'
use_experimental_fxv2_oal 'yes'
author 'L3th'
version 'v1.0.0'
repository 'https://github.com/L9th/l3th-graverob'
description 'Grave Robbery'

files {
    -- 'configs/*.lua',
    'locales/*.json',
    'utils/*.lua',
    'bridge/**/client.lua',
    'bridge/**/server.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
}

ox_libs {
	'math',
	'locale',
}

client_scripts {
	'client/*.lua',
    'configs/cl_config.lua',
}

server_scripts {
	'server/*.lua',
    'configs/sv_config.lua',
}