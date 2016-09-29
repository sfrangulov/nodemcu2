local module = {}

local broker = {}
local online = false

function module.is_online()
  return online
end

local function connect()
    broker:connect(app.config.mqtt.host, app.config.mqtt.port, 0, 1, function(con)
      prn("============ MQTT  ==============")
      prn("  IP: ".. app.config.mqtt.host)
      prn("  Port: ".. app.config.mqtt.port)
      prn("  Client ID: ".. app.config.id)
      online = true
      broker:subscribe(app.config.mqtt.task_endpoint.."/#", 0)
    end)
end

function module.publish_data(topic, payload)
    prn("Publish "..app.config.mqtt.data_endpoint..topic.."="..payload)    
    broker:publish(app.config.mqtt.data_endpoint..topic, payload, 0, 0)
end

function module.publish_hello(payload)
    prn("Publish "..app.config.mqtt.hello_endpoint.."="..payload)    
    broker:publish(app.config.mqtt.hello_endpoint, payload, 0, 0)
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
