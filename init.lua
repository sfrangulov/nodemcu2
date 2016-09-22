table = require("table")
dofile("misc.lua")
_wifi = require("_wifi")
app = require("app")

_wifi.start(app.config.wifi[app.config.node.wifi].ssid,
            app.config.wifi[app.config.node.wifi].password,
            app.mqtt.start)
app.start()
