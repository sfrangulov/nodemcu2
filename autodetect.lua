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
        sensor = {module = "_bmp085", sda = isda, scl = iscl}
        return cjson.encode(sensor)
    end
    return nil
end

function module.i2c_scanner()
    for scl=1,7 do
        for sda=1,7 do
            tmr.wdclr()
            if sda~=scl then
                i2c.setup(id,sda,scl,i2c.SLOW)
                for i=0,127 do
                        if find_dev(id, i)==true then
                            local sensor = i2c_detect("0x"..string.format("%02X",i), sda, scl)
                            if (sensor ~= nil) then
                                prn(sensor)
                            end
                        end
                end
            end
        end
    end
end

function module.start()
    prn("============ Autod ==============")
    module.i2c_scanner()    
end

return module
