local module = {}

module.id = "ESP8266_"..node.chipid()

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

module.interval = 10

module.sensors = {}

module.sensors_detected = {}

module.location = ""

module.data_error = -999999

function module.json_config_load()
    prn("============ Confi ==============")
    if (file.open(node.chipid().."_connection.json")) then
        module.connection = cjson.decode(file.read())
        module.connection.mqttdataendpoint = "data/"..module.id
        module.connection.mqtttaskendpoint = "task/"..module.id
        module.connection.mqtthelloendpoint ="clients/"..module.id
        file.close()
        prn("  Connection config loaded")
    else
        prn("  No connection config")
        return
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
