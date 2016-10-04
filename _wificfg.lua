local module = {}

local wait_form = false

local pwf = {}
local pmq = {}

local attempt = 10

local node_restart = false

local mqtt_online = false

local function http_response(conn, msg, r)
    local buf = ""
    prn(msg)   
    buf = 'HTTP/1.1 200 OK\n\n'
    buf = buf .. '<!DOCTYPE html>\n'
    buf = buf .. '<html>\n'
    buf = buf .. '<head><meta  content="text/buf; charset=utf-8">\n'
    buf = buf .. '<title>' .. app.config.id .. '</title></head>\n'
    buf = buf .. '<body><h1>' .. msg .. '</h1>\n'
    buf = buf .. '</body></html>\n'
    if (r == true) then
        node_restart = true
    end
    conn:send(buf)
end

local function wait_ip(conn)
  if (attempt >= 0) then
    if wifi.sta.getip()== nil then
        attempt = attempt - 1
    else
        tmr.stop(0)
        prn("============ WiFi  ==============")    
        prn("  MAC: " .. wifi.ap.getmac())
        prn("  SSID: "..pwf.ssid)    
        prn("  IP: "..wifi.sta.getip())
        attempt = 10
        local broker = {}
        broker = mqtt.Client(app.config.id, 120)
        tmr.alarm(0, 2000, tmr.ALARM_AUTO, function()
            if (mqtt_online) then
                tmr.stop(0)
                http_response(conn, "Configuration saved", true)
            end
            if (attempt >= 0) then
                attempt = attempt - 1
            else
                tmr.stop(0)
                http_response(conn, "ERROR! Unable to connect to MQTT broker", true)
            end
        end)
        broker:connect(pmq.host, pmq.port, 0, 1, function(con)
            prn("============ MQTT  ==============")
            prn("  IP: ".. pmq.host)
            prn("  Port: ".. app.config.mqtt.port)
            prn("  Client ID: ".. pmq.port)
            mqtt_online = true      
        end)
    end
  else
    http_response(conn, "ERROR! Unable to connect Wi-Fi", true)
  end
end

function module.web()
    
    require("http").createServer(80, function(req, res)
        -- analyse method and url
        print("+R", req.method, req.url, node.heap())
        -- setup handler of headers, if any
        req.onheader = function(self, name, value)
            -- print("+H", name, value)
            -- E.g. look for "content-type" header,
            --   setup body parser to particular format
            -- if name == "content-type" then
            --   if value == "application/json" then
            --     req.ondata = function(self, chunk) ... end
            --   elseif value == "application/x-www-form-urlencoded" then
            --     req.ondata = function(self, chunk) ... end
            --   end
            -- end
        end
        -- setup handler of body, if any
        req.ondata = function(self, chunk)
            print("+B", chunk and #chunk, node.heap())
            -- request ended?
            if not chunk then
            -- reply
            --res:finish("")
            res:send(nil, 200)
            res:send_header("Connection", "close")
            res:send("Hello, world!")
            res:finish()
            end
        end
        -- or just do something not waiting till body (if any) comes
        --res:finish("Hello, world!")
        --res:finish("Salut, monde!")
    end)
    
    
    --[=====[ local srv = net.createServer(net.TCP)
    srv:listen(80,function(conn)
    conn:on("receive",function(conn,request)
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
        if (method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
        end
        local buf = ""
        if (method == "GET" and path == "/") then
            buf = 'HTTP/1.1 200 OK\n\n'
            buf = buf .. '<!DOCTYPE html>\n'
            buf = buf .. '<html>\n'
            buf = buf .. '<head><meta  content="text/buf; charset=utf-8">\n'
            buf = buf .. '<title>' .. app.config.id .. '</title></head>\n'
            buf = buf .. '<body><h1>' .. app.config.id .. ' configuration</h1>\n'
            buf = buf .. '<form action="" method="POST">\n'
            buf = buf .. '<table border=0><tr><td>WiFi SSID: </td><td><input type="text" name="wssid"></td></tr>\n'
            buf = buf .. '<tr><td>WiFi Password: </td><td><input type="text" name="wpass"></td></tr>\n'
            buf = buf .. '<tr><td>MQTT Address: </td><td><input type="text" name="mhost"></td></tr>\n'
            buf = buf .. '<tr><td>MQTT Port: </td><td><input type="text" name="mport" value="1883"></td></tr>\n'        
            buf = buf .. '<tr><td>MQTT Login: </td><td><input type="text" name="mlogin"></td></tr>\n'
            buf = buf .. '<tr><td>MQTT Password: </td><td><input type="text" name="mpass"</td></tr>\n'
            buf = buf .. '</table><input type="submit" value="Save">\n'
            buf = buf .. '</form></body></html>\n'
            conn:send(buf)
            return
        end

        if (method == "POST" and path == "/") then
            wait_form = true
            return
        end
        if (wait_form) then
            wait_form = false
            local param = split(request, "&")
            local c = 0
            for i in pairs(param) do
                pa = split(param[i], "=")
                if (pa[1] == "wssid") then
                    pwf.ssid = pa[2]
                    c = c + 1
                elseif (pa[1] == "wpass") then
                    pwf.password = pa[2]
                    c = c + 1
                elseif (pa[1] == "mhost") then
                    pmq.host = pa[2]
                    c = c + 1
                elseif (pa[1] == "mport") then
                    pmq.port = pa[2]
                    c = c + 1
                elseif (pa[1] == "mlogin") then
                    pmq.login = pa[2]
                    c = c + 1
                elseif (pa[1] == "mpass") then
                    pmq.password = pa[2] 
                    c = c + 1                                             
                end
            end
            if (c == 6) then
                wifi.sta.config(pwf.ssid, pwf.password) 
                wifi.sta.connect()
                tmr.alarm(0, 2000, tmr.ALARM_AUTO, function() wait_ip(conn) end)
                return            
            end
        end
        conn:send('HTTP/1.1 404 NOT FOUND\n\n')
    end)
    conn:on("sent", function(conn)
        conn:close()
        if (node_restart == true) then
            node.restart()
        end         
    end)
end)
--]=====]
end

function module.start()
    prn("============ WiFiC ==============")
    wifi.setmode(wifi.STATIONAP)
    wifi.setphymode(wifi.PHYMODE_N)
    wifi.ap.config(app.config.ap)
    wifi.ap.setip(app.config.ap.ip)
    wifi.ap.dhcp.config(app.config.ap.dhcp)
    wifi.ap.dhcp.start()
    prn("  MAC: " .. wifi.ap.getmac())
    prn("  SSID: "..app.config.ap.ssid)    
    prn("  IP: "..app.config.ap.ip.ip)
    prn("  Web: http://"..app.config.ap.ip.ip.."/")
    module.web()
end

return module
