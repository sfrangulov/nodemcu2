local module = {}

local restart = false

local function validateParam(p)
    prn(cjson.encode(p))
    local v = {"wifissid", "wifipassword", "mqtthost", "mqttport", "mqttlogin", "mqttpassword"}
    for i, val in ipairs(v) do
        if (p[val] == nil) then
            return false
        end
    end
    return true
end

function module.web()
    srv=net.createServer(net.TCP)
    srv:listen(80,function(conn)
        conn:on("receive", function(sck,req)
            local response = {}
            local _, _, method, path, vars = string.find(req, "([A-Z]+) (.+)?(.+) HTTP")
            if(method == nil)then
                _, _, method, path = string.find(req, "([A-Z]+) (.+) HTTP")
            end
            local _GET = {}
            if (vars ~= nil)then
                for k, v in string.gmatch(vars, "([%w%._]+)=([%w%._]+)&*") do
                    _GET[k] = v
                end
            end           
            if (vars ~= nil and path == '/') then
                if (validateParam(_GET)) then
                    response = {
                        'HTTP/1.1 200 OK\n\n',
                        '<!DOCTYPE html>\n',
                        '<html>\n',
                        '<head><meta  content="text/html; charset=utf-8">\n',
                        '<title>' .. app.config.id .. 'configuration</title></head>\n',
                        '<body><b>Configuration saved. Please, close this page</b>',
                        '</body></html>\n'
                    }
                    if file.open(node.chipid().."_connection.json", "w+") then
                        file.write(cjson.encode(_GET))
                        file.close()
                        restart = true
                    end               
                else
                    response = {
                        'HTTP/1.1 200 OK\n\n',
                        '<!DOCTYPE html>\n',
                        '<html>\n',
                        '<head><meta  content="text/html; charset=utf-8">\n',
                        '<title>' .. app.config.id .. ' configuration</title></head>\n',
                        '<body><b>Error in configuration</b><br><br>',
                        '<a href="http:\\\\'.. app.config.ap.ip.ip ..'\\">Back</a>\n',
                        '</body></html>\n'
                    }               
                end        
            end
            if (vars == nil and path == '/') then
                response = {
                    'HTTP/1.1 200 OK\n\n',
                    '<!DOCTYPE html>\n',
                    '<html>\n',
                    '<head><meta  content="text/html; charset=utf-8">\n',
                    '<title>' .. app.config.id .. ' configuration</title></head>\n',
                    '<form action="" method="GET">\n',
                    '<table border=0><td>Node ID: </td><td>' .. app.config.id .. '</td></tr>\n',
                    '<td>MAC Address: </td><td>' .. wifi.ap.getmac() .. '</td></tr>\n',
                    '<tr><td>WiFi SSID*: </td><td><input type="text" name="wifissid"></td></tr>\n',
                    '<tr><td>WiFi Password*: </td><td><input type="text" name="wifipassword"></td></tr>\n',
                    '<tr><td>MQTT Address*: </td><td><input type="text" name="mqtthost"></td></tr>\n',
                    '<tr><td>MQTT Port*: </td><td><input type="text" name="mqttport" value="1883"></td></tr>\n',        
                    '<tr><td>MQTT Login*: </td><td><input type="text" name="mqttlogin"></td></tr>\n',
                    '<tr><td>MQTT Password*: </td><td><input type="text" name="mqttpassword"</td></tr>\n',
                    '<tr><td><i>* - required field</i></td></tr>\n',
                    '</table><input type="submit" value="Save">\n',
                    '</form></body></html>\n'
                }
            end
            if (path ~= '/') then
                response = {'HTTP/1.1 404 NOT FOUND\n\n'}          
            end
            local function sender (sck)
                if #response > 0 then sck:send(table.remove(response, 1))
                else
                    sck:close()
                    if (restart == true) then
                        node.restart()
                    end
                end
            end
            sck:on("sent", sender)
            sender(sck)
        end)
    end)
end

function module.start()
    prn("============ WiFiC ==============")
    wifi.setmode(wifi.SOFTAP)
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
