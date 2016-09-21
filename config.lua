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
    data_endpoint = "data/"..module.id,
    task_endpoint = "task/"..module.id,
    hello_endpoint = "clients/"..module.id
}

module.mqtt.dev_ext = {
    host = "iot.eclipse.org",
    port = 1883,
    data_endpoint = "trs/data/"..module.id,
    task_endpoint = "trs/task/"..module.id,
    hello_endpoint = "trs/clients/"..module.id
}

module.data_error = -999999

return module
