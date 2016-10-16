local module = {}

module.indicators = {
    temperature = {type="temperature", unit = "C", range_start = -55, range_end = 125} 
}

function module.get(key, config)
    local res = {}
    res.temperature = 0
    t = require("ds18b20")
    t.setup(config.pin)
    res.temperature = t.read()
    t = nil
    ds18b20 = nil
    package.loaded["ds18b20"]=nil
    return res
end

function module.init(key, config)
  if (config.pullup) then
    gpio.mode(config.pin, gpio.INPUT, gpio.PULLUP)
  end
end

return module
