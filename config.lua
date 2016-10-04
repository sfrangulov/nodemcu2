local module = {}

module.id = "ESP8266_"..node.chipid()

--module.wifi = {
--    ssid = "iot",
--    password = "Kitty12345"
--}

module.ap= {
    ssid=module.id,
    pwd="Kitty12345",
    auth=AUTH_WPA_WPA2_PSK,
    channel = 6,
    hidden = 0,
    max=4,
    beacon=100
}

module.ap.ip = {
    ip="192.168.222.1",
    netmask="255.255.255.0",
    gateway="192.168.222.1"
}

module.ap.dhcp = {
    start="192.168.222.2"
}

module.mqtt = {
    host = "192.168.100.68",
    port = 1883,
    data_endpoint = "data/"..module.id,
    task_endpoint = "task/"..module.id,
    hello_endpoint = "clients/"..module.id
}

module.interval = 10

module.sensors = {}

module.sensors_detected = {}

module.location = ""

module.data_error = -999999

function module.json_config_load()
    prn("============ Confi ==============")
    if (file.open(node.chipid().."_wifi.json")) then
        module.wifi = cjson.decode(file.read())
        file.close()
        prn("  WiFi config loaded")
    else
        prn("  No WiFi config")
        return
    end
    if (file.open(node.chipid().."_mqtt.json")) then
        module.mqtt = cjson.decode(file.read())
        module.mqtt.data_endpoint = module.mqtt.data_endpoint..module.id
        module.mqtt.task_endpoint = module.mqtt.task_endpoint..module.id
        module.mqtt.hello_endpoint = module.mqtt.hello_endpoint..module.id
        file.close()
        prn("  MQTT config loaded")
    else
        prn("  No MQTT config")
    end
    if (file.open(node.chipid().."_sensors.json")) then
        module.sensors = cjson.decode(file.read())
        file.close()
        prn("  Sensors config loaded")
    else
        prn("  No sensor config")
        tmr.alarm(6, 5000, tmr.ALARM_SINGLE, function()
            autodetect = require("autodetect")
            autodetect.start() 
            autodetect=nil
            package.loaded["autodetect"]=nil  
        end)
    end           
end

return module
