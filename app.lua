local app = {}
app.iteration = 0
app.config = require("config")
app.mqtt = require("_mqtt")

--app._dht11 = require("_dht11")
--app._relay = require("_relay")
--app._soilhum = require("_soilhum")
--app._bmp085 = require("_bmp085")

function app.get_indicators()
    local msg = "{"
    for skey,svalue in pairs(app.config.node.sensors) do
        local i = app[app.config.node.sensors[skey].module].indicators
        if (svalue.type ~= nil) then
            i = app[app.config.node.sensors[skey].module].indicators[svalue.type]    
        end
        for ikey,ivalue in pairs(i) do
            if (msg ~= "{") then
                msg = msg..","    
            end
            msg = msg.."\""..skey.."."..ikey.."\":\""..ivalue.type.."\""
        end

    end
    return msg.."}"
end

function app.hello()
    
    app.mqtt.publish_hello(app.get_indicators())
end

function app.new_message(topic, data)
    local path = split(topic, "/")
    --
    if (path[table.getn(path)] == "result") then
        prn("Skip result message")
        return
    end
    --
    if (path[3] == "restart") then
        node.restart()
        return
    end    
    if (path[3] == "getindicators") then
        app.mqtt.publish_task_result(topic, app.get_indicators())
        return
    end   
    --
    if (path[3] == "resetlast") then
        for skey,svalue in pairs(app.config.node.sensors) do
            app.config.node.sensors[skey].last_res = {}
        end
        app.mqtt.publish_task_result(topic, "done")
        return
    end   
    --    
    id = split(path[3], ".")
    if (app.config.node.sensors[id[1]] == nil) then
         prn("Skip unknown task. Unknown sensor")
         app.mqtt.publish_task_result(topic, "error")
        return       
    end
    --
    local i = app[app.config.node.sensors[id[1]].module].indicators
    if (app.config.node.sensors[id[1]].type ~= nil) then
        i = app[app.config.node.sensors[id[1]].module].indicators[app.config.node.sensors[id[1]].type]
    end
    --
    if (id[2] == nil and path[4] ~= nil) then
        app.config.node.sensors[id[1]][path[4]] = data
        prn("Change config for sensor "..id[1])
        return
    end
    --
    if (id[2] ==nil or i[id[2]] == nil) then
        prn("Skip unknown task. Unknown indicator")
        app.mqtt.publish_task_result(topic, "error")
        return        
    end
    --
    if (path[4] == nil) then
        local res = {}
        res[id[2]] = data
        app[app.config.node.sensors[id[1]].module].set(id[1],app.config.node.sensors[id[1]], res)
        app.mqtt.publish_task_result(topic, "done")
        prn("Change value for indicator "..id[1].."."..id[2])
        return
    end
    --
    if (path[4] ~= nil) then
        if (path[4] == "disabled") then
            if (data == "true") then
                app.config.node.disabled[id[1].."."..id[2]] = "true"
            elseif (data == "false") then
                app.config.node.disabled[id[1].."."..id[2]] = nil
            end
        end
    end 
end

function app.start()
    tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
        if (app.mqtt.is_online() ~= 0) then
            tmr.stop(1)          
            prn("============ Ready ==============")
            for skey,svalue in pairs(app.config.node.sensors) do
                app[svalue.module] = require(svalue.module)
            end
            app.hello()
            app.init()
            tmr.alarm(1, 1000, tmr.ALARM_AUTO, app.timer)           
        end
    end)
end

function app.init()
    for skey,svalue in pairs(app.config.node.sensors) do
        app[app.config.node.sensors[skey].module].init(skey,svalue)  
        app.config.node.sensors[skey].last_res = {}   
    end
end

function app.timer()
    collectgarbage()
    local res = {}
    for skey,svalue in pairs(app.config.node.sensors) do
        if (app.iteration%app.config.node.sensors[skey].interval == 0) then
            res = app[app.config.node.sensors[skey].module].get(skey,svalue)
            local mode = "allways"
            if (app.config.node.sensors[skey].mode ~= nil) then
                mode = app.config.node.sensors[skey].mode
            end 
            for rkey,rvalue in pairs(res) do
                if (app.config.node.disabled[skey.."."..rkey] == nil) then
                    if (mode == "allways" or
                        (mode == "change" and
                            app.config.node.sensors[skey].last_res[rkey] ~= res[rkey])) then
                        app.mqtt.publish_data("/"..skey.."."..rkey, rvalue)
                    end
                end
            end
            if (mode == "change") then
                app.config.node.sensors[skey].last_res = deepcopy(res)
            end
        end
    end
    app.iteration = app.iteration + 1
end

return app
