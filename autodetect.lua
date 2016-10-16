local module = {}

local id = 0
local i2c_pin= {5,4,0,2,14,12,13}

local function find_dev(i2c_id, dev_addr)
     i2c.start(i2c_id)
     c=i2c.address(i2c_id, dev_addr ,i2c.TRANSMITTER)
     i2c.stop(i2c_id)
     return c
end

local function i2c_detect(iaddr, isda, iscl)
    local sensor = {}
    if (iaddr == "0x77") then
        sensor = {module = "_bmp085", sda = isda, scl = iscl, interval = app.config.interval}
        return sensor
    end
    return nil
end

function i2c_scanner()
    for scl=1,7 do
        for sda=1,7 do
            tmr.wdclr()
            if sda~=scl then
                i2c.setup(id,sda,scl,i2c.SLOW)
                for i=0,127 do
                        if find_dev(id, i)==true then
                            local sensor = i2c_detect("0x"..string.format("%02X",i), sda, scl)
                            if (sensor ~= nil) then
                                app.config.sensors_detected["ad_"..sensor.module.."_"..sensor.sda.."_"..sensor.scl] = deepcopy(sensor)
                            end
                        end
                end
            end
        end
    end
end

function dht_scanner()
  --dht=require("dht")
  for pin=1,8 do
    status,temp,humi,temp_decimial,humi_decimial = dht.read(pin)
    dht_type = "dht22"
    if( status ~= dht.OK ) then
        status,temp,humi,temp_decimial,humi_decimial = dht.read11(pin)
        dht_type = "dht11"    
    end
    if( status == dht.OK ) then
        app.config.sensors_detected["ad__dht11_"..pin] = {module="_dht11", pin = pin, type = dht_type, interval = app.config.interval}
    end  
  end
  --dht=nil
  --package.loaded["dht"]=nil
end

function module.start()
    prn("============ Autod ==============")
    i2c_scanner()
    dht_scanner()
    app.config.sensors = app.config.sensors_detected
    prn(cjson.encode(app.config.sensors))
    prn("  Done")
end

return module
