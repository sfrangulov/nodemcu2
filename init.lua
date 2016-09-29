table = require("table")
dofile("misc.lua")
_wifi = require("_wifi")
app = require("app")

app.config.json_config_load()

_wifi.start(app.config.wifi.ssid,
            app.config.wifi.password,
            app.mqtt.start)
app.start()
