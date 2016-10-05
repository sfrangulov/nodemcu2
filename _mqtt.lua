local module = {}

local broker = {}
local online = false

function module.is_online()
  return online
end

local function connect()
    broker:connect(app.config.connection.mqtthost, app.config.connection.mqttport, 0, 1, function(con)
      prn("============ MQTT  ==============")
      prn("  IP: ".. app.config.connection.mqtthost)
      prn("  Port: ".. app.config.connection.mqttport)
      prn("  Client ID: ".. app.config.id)
      online = true
      broker:subscribe(app.config.connection.mqtttaskendpoint.."/#", 0)
    end)
end

function module.publish_data(topic, payload)
    prn("Publish "..app.config.connection.mqttdataendpoint..topic.."="..payload)    
    broker:publish(app.config.connection.mqttdataendpoint..topic, payload, 0, 0)
end

function module.publish_hello(payload)
    prn("Publish "..app.config.connection.mqtthelloendpoint.."="..payload)    
    broker:publish(app.config.connection.mqtthelloendpoint, payload, 0, 0)
end

function module.publish_task_result(topic, payload)
    prn("Publish "..topic.."/result="..payload)    
    broker:publish(topic.."/result", payload, 0, 0)
end

function module.start()
    broker = mqtt.Client(app.config.id, 120)
    broker:on("offline", function(client) online = false end)
    broker:on("message", function(client, topic, data)  
      if data == nil then
        data = "~~~"
      end
      prn("Task "..topic.."="..data)      
      app.new_message(topic, data)
    end)
    connect()
end

return module  
