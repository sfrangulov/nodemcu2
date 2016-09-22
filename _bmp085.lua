local module = {}

module.indicators = {
    temperature = {type="temperature", unit = "C", range_start = 0, range_end = 65},
    pressure = {type="pressure", unit = "mm Hg", range_start = 0, range_end = 0}
}

function module.get(key, config)
  res = {}
  res.temperature = 0
  res.pressure = 0
  bmp085=require("bmp085")
  bmp085.init(config.sda, config.scl)
  local t = bmp085.temperature()
  local p = bmp085.pressure()
  res.temperature = (t / 10).."."..(t % 10)
  res.pressure = (p * 75 / 10000).."."..((p * 75 % 10000) / 100)
  bmp085=nil
  package.loaded["bmp085"]=nil
  return res
end

function module.init(key, config)

end

return module
