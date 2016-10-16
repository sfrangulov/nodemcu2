table = require("table")
dofile("misc.lua")
_wifi = require("_wifi")
app = require("app")

app.config.json_config_load()

if (app.config.connection ~= nil) then
    _wifi.start(app.config.connection.wifissid,
                app.config.connection.wifipassword,
                app.mqtt.start)
    app.start()
else
    _wificfg = require("_wificfg")
    _wificfg.start()
end
