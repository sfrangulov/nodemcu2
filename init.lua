table = require("table")
dofile("misc.lua")
_wifi = require("_wifi")
_wificfg = require("_wificfg")
app = require("app")

app.config.json_config_load()

if (app.config.wifi ~= nil) then
    _wifi.start(app.config.wifi.ssid,
                app.config.wifi.password,
                app.mqtt.start)
    app.start()
else
    _wificfg.start()
end
