local module = {}

module.id = "ESP8266_"..node.chipid()

module.node = require("config_"..node.chipid())

module.wifi = {}

module.wifi.iot = {
    ssid = "iot",
    password = "Kitty12345"
}

module.mqtt = {}

module.mqtt.dev_int = {
    host = "192.168.100.68",
    port = 1883,
    --json = false,
    data_endpoint = "data/"..module.id,
    task_endpoint = "task/"..module.id,
    hello_endpoint = "clients/"..module.id
}

module.mqtt.dev_ext = {
    host = "s2e24d843.fastvps-server.com",
    port = 8081,
    --json = true,
    data_endpoint = "data/"..module.id,
    task_endpoint = "task/"..module.id,
    hello_endpoint = "clients/"..module.id
}

module.data_error = -999999

return module
