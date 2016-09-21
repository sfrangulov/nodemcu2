dofile("misc.lua")
table = require("table")
_wifi = require("_wifi")
app = require("app")

_wifi.start(app.config.wifi[app.config.node.wifi].ssid,
            app.config.wifi[app.config.node.wifi].password,
            app.mqtt.start)
app.start()
