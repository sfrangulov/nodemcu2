local module = {}

module.id = "ESP8266_"..node.chipid()

module.node = require("config_"..node.chipid())

module.wifi = {
    ssid = "iot",
    password = "Kitty12345"
}

module.mqtt = {
    host = "192.168.100.68",
    port = 1883,
    data_endpoint = "data/"..module.id,
    task_endpoint = "task/"..module.id,
    hello_endpoint = "clients/"..module.id
}

module.data_error = -999999

function module.json_config_load()
    if (file.open(node.chipid().."_wifi.json")) then
        module.wifi = cjson.decode(file.read())
        file.close()
    end    
end

return module
