local module = {}

module.indicators = {
    sound = {
      level = {type="level", unit = "%", range_start = 0, range_end = 100}
    },
    light = {
      level = {type="level", unit = "%", range_start = 0, range_end = 100}
    }   
}

function module.get(key, config)
  local res = {}
  res.level = 100-100*adc.read(config.apin)/1024
  return res
end

function module.init(key, config)
end

return module
