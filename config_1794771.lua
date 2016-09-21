local module = {
    wifi = "iot",
    mqtt = {"dev_int", "dev_ext"},
    sensors = {
        dht22_1 = {module = "_dht11", type="dht22", pin = 5, pullup = true, interval = 10}
        --,dht21_1 = {module = "_dht11", type="dht21", pin = 6, pullup = true, interval = 10}
        --,bmp085_1 = {module = "_bmp085", sda = 2, scl = 1, interval = 10}
        --,relay_1 = {module = "_relay", pin = 7, interval = 10, auto_off = 3}
        --,soilhum_1 = {module = "_soilhum", pin = 3, apin = 0, interval = 10}
        --,sound_1 = {module = "_aproc", type="sound", apin = 0, interval = 10}
        ,light_1 = {module = "_aproc", type="light", apin = 0, interval = 10}
    },
    disabled = {}
}

return module
