fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'Rexshack Gaming : Stable'

dependencies {
	'qbr-core'
}

shared_scripts {
	'@qbr-core/shared/locale.lua',
    'locale/en.lua',
	'config.lua'
}
client_scripts {
    'horse_comp.lua',
    'client/main.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
	'html/*',
	'html/css/*',
	'html/fonts/*',
	'html/img/*'
}

lua54 'yes'