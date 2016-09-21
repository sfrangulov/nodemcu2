local module = {}

module.indicators = {
  dht11 = {
    temperature = {type="temperature", unit = "C", range_start = 0, range_end = 50},
    humidity = {type="humidity", unit = "C", range_start = 20, range_end = 90}
  },
  dht21 = {
    temperature = {type="temperature", unit = "C", range_start = -40, range_end = 80},
    humidity = {type="humidity", unit = "C", range_start = 0, range_end = 100}
  },
  dht22 = {
    temperature = {type="temperature", unit = "C", range_start = -40, range_end = 80},
    humidity = {type="humidity", unit = "C", range_start = 0, range_end = 100}
  }    
}

function module.get(key, config)
  res = {}
  res.temperature = 0
  res.humidity = 0
  dht=require("dht")
  if (config.type == "dht11") then
    status,temp,humi,temp_decimial,humi_decimial = dht.read11(config.pin)
  else
    status,temp,humi,temp_decimial,humi_decimial = dht.read(config.pin)  
  end
  if( status == dht.OK ) then
    res.temperature = temp.."."..(math.abs(temp_decimial)/100)
    res.humidity = humi.."."..(math.abs(humi_decimial)/100)
    if(temp == 0 and temp_decimial<0) then
      res.temperature = "-"..res.temperature
    end
  elseif( status == dht.ERROR_CHECKSUM ) then
    res.temperature = app.config.data_error
    res.humidity = app.config.data_error
  elseif( status == dht.ERROR_TIMEOUT ) then
    res.temperature = app.config.data_error
    res.humidity = app.config.data_error
  end
  dht=nil
  package.loaded["dht"]=nil
  return res
end

function module.init(key, config)
  if (config.pullup) then
    gpio.mode(config.pin, gpio.INPUT, gpio.PULLUP)
  end
end

return module
