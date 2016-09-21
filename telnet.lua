local module = {}

function module.start()
    telnet_srv = net.createServer(net.TCP, 180)
    telnet_srv:listen(23, function(socket)
        local fifo = {}
        local fifo_drained = true

        local function sender(c)
            if #fifo > 0 then
                c:send(table.remove(fifo, 1))
            else
                fifo_drained = true
            end
        end

        local function s_output(str)
            table.insert(fifo, str)
            if socket ~= nil and fifo_drained then
                fifo_drained = false
                sender(socket)
            end
        end

        node.output(s_output, 0)

        socket:on("receive", function(c, l)
            node.input(l)
        end)
        socket:on("disconnection", function(c)
            node.output(nil)
        end)
        socket:on("sent", sender)

        print("Welcome to NodeMCU world.")
    end)
end

function module.stop()
	if (telnet_srv ~= nil and telnet_srv["stop"] ~= nil) then
        telnet_srv.stop()
    end
end

return module
