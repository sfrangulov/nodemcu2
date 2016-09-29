local module = {}

module.id = "ESP8266_"..node.chipid()

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

module.sensors = {}

module.location = ""

module.data_error = -999999

function module.json_config_load()
    prn("============ Confi ==============")
    if (file.open(node.chipid().."_wifi.json")) then
        module.wifi = cjson.decode(file.read())
        file.close()
        prn("  WiFi config loaded")
    end
    if (file.open(node.chipid().."_mqtt.json")) then
        module.mqtt = cjson.decode(file.read())
        module.mqtt.data_endpoint = module.mqtt.data_endpoint..module.id
        module.mqtt.task_endpoint = module.mqtt.task_endpoint..module.id
        module.mqtt.hello_endpoint = module.mqtt.hello_endpoint..module.id
        file.close()
        prn("  MQTT config loaded")
    end
    if (file.open(node.chipid().."_sensors.json")) then
        module.sensors = cjson.decode(file.read())
        file.close()
        prn("  Sensors config loaded")
    end           
end

return module
