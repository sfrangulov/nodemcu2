local module = {
    wifi = "iot",
    mqtt = {"dev_int", "dev_ext"},
    sensors = {
        dht11_1 = {module = "_dht11", type="dht11", pin = 1, interval = 10}
        ,relay_1 = {module = "_relay", pin = 2, interval = 10, auto_off = 3}
        ,soilhum_1 = {module = "_soilhum", pin = 3, apin = 0, interval = 600}
    },
    disabled = {}
}

return module
