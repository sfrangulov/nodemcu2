local module = {}

local telent = require("telnet")

local _ssid = ""
local _password = ""

local function _cb()
end

local function wait_ip()  
  if wifi.sta.getip()== nil then
  else
    tmr.stop(0)
    prn("============ WiFi  ==============")    
    prn("  MAC: " .. wifi.ap.getmac())
    prn("  SSID: ".._ssid)    
    prn("  IP: "..wifi.sta.getip())
    --prn("  Web: http://"..wifi.sta.getip().."/")
    --_wificfg.web()
    prn("  Telnet port: 23")
    telent.start()
    _cb()
  end
end

local function connect()  
    wifi.sta.config(_ssid, _password)
    wifi.sta.connect()
    wifi.sta.autoconnect(1)
    tmr.alarm(0, 2000, tmr.ALARM_AUTO, wait_ip)
end

function module.start(ssid, password, cb)
  _ssid = ssid
  _password = password
  _cb = cb
  wifi.setmode(wifi.STATION)
  wifi.setphymode(wifi.PHYMODE_N)
  wifi.sta.getap(connect)    
end

return module  
