local module = {}

module.brokers = {}
module.online = {}

function module.is_online()
  local count = 0
  for _ in pairs(module.online) do
    if (_ ~= nil) then
      count = count + 1
    end
  end
  return count
end

local function connect()
      for key,value in pairs(module.brokers) do
        module.brokers[key]:connect(app.config.mqtt[key].host, app.config.mqtt[key].port, 0, 1, function(con)
            prn("============ MQTT  ==============")
            prn("  IP: ".. app.config.mqtt[key].host)
            prn("  Port: ".. app.config.mqtt[key].port)
            prn("  Client ID: ".. app.config.id)
            module.online[key] = 1
            module.brokers[key]:subscribe(app.config.mqtt[key].task_endpoint.."/#", 0)
        end)
     end
end

function module.publish_data(topic, payload)
  for key,value in pairs(module.brokers) do
    if (module.online[key] ~= nil) then
      prn("Publish "..app.config.mqtt[key].data_endpoint..topic.."="..payload)    
      module.brokers[key]:publish(app.config.mqtt[key].data_endpoint..topic, payload, 0, 0)
    end
  end
end

function module.publish_hello(payload)
  for key,value in pairs(module.brokers) do
    if (module.online[key] ~= nil) then
      prn("Publish "..app.config.mqtt[key].hello_endpoint.."="..payload)    
      module.brokers[key]:publish(app.config.mqtt[key].hello_endpoint, payload, 0, 0)
    end
  end
end

function module.publish_task_result(topic, payload)
  for key,value in pairs(module.brokers) do
    if (module.online[key] ~= nil) then
      prn("Publish "..topic.."/result="..payload)    
      module.brokers[key]:publish(topic.."/result", payload, 0, 0)
    end
  end
end

function module.start()
  for key,value in pairs(app.config.node.mqtt) do
    module.brokers[value] = mqtt.Client(app.config.id, 120)
    module.online[value] = nil
    module.brokers[value]:on("connect", function(client) module.online[value] = 1 end)
    module.brokers[value]:on("offline", function(client) module.online[value] = nil end)
    module.brokers[value]:on("message", function(client, topic, data)  
      if data == nil then
        data = "~~~"
      end
      prn("Task "..topic.."="..data)      
      app.new_message(topic, data)
    end)
  end
  connect()
end

return module  
