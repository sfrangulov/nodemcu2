local module = {}

module.indicators = {
    state = {type="state", unit = "", range_start = 0, range_end = 1}
}

function module.get(key, config)
  res = {}
  res.state = gpio.read(config.pin)
  return res
end

function module.set(key, config, value)
  for rkey,rvalue in pairs(value) do
    gpio.write(config.pin, rvalue)
    app.config.node.sensors[key].interval_tmp = app.config.node.sensors[key].interval
    app.config.node.sensors[key].interval = 1
    if (rvalue == "1" and config.auto_off ~= nil) then
      tmr.alarm(6, config.auto_off * 1000, tmr.ALARM_SINGLE, function()
        gpio.write(config.pin, gpio.LOW)
        app.config.node.sensors[key].interval = app.config.node.sensors[key].interval_tmp  
      end)
    end
  end
end

function module.init(key, config)
    gpio.mode(config.pin, gpio.INPUT)
    gpio.write(config.pin, gpio.LOW)
end

return module
