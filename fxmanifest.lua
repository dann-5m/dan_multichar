fx_version "cerulean"

lua54 'yes'

games {
  "gta5",
  "rdr3"
}

ui_page 'web/build/index.html'

client_script {
  "shared/*",
  "client/**/*"
}
server_script {
  "shared/*",
  "server/**/*"
}

files {
  'web/build/index.html',
  'web/build/**/*'
}
