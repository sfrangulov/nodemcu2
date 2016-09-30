local module = {}

module.indicators = {
    humidity = {type="humidity", unit = "%", range_start = 0, range_end = 100}
}

function module.get(key, config)
  local res = {}
  res.humidity = 0
  gpio.write(config.pin, gpio.HIGH)
  tmr.delay(500)
  res.humidity = 100-100*adc.read(config.apin)/1024
  gpio.write(config.pin, gpio.LOW)
  return res
end

function module.init(key, config)
    gpio.mode(config.pin, gpio.OUTPUT)
    gpio.write(config.pin, gpio.LOW)
end

return module
