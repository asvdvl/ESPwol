local function parseAction(text)
    if text == "on" then
        return gpio.HIGH
    elseif text == "off" then
        return gpio.LOW
    else
        return 'err'
    end
end

activityPulse = gpio.pulse.build( {{[4] = gpio.LOW, delay=50000},{[4] = gpio.HIGH, delay=0}})

Srv = net.createServer(net.TCP)
Srv:listen(80,
    function(conn)
        conn:on("receive",
            function(sck, payload)
                activityPulse:stop(function() end)
                activityPulse:start(function() end)
                local page = string.match(payload, "^GET (\/%w*).*HTTP")
                print("request "..page)

                if page == "/" then
                    local currFile = file.open("index.html", "r")
                    local function sendBlock(localSocket)
                        local chunck = currFile.read(512)
                        if chunck then
                            sck:send(chunck)
                        else
                            localSocket:close()
                            chunck = nil
                            file.close()
                        end
                    end
                    
                    sck:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"..currFile.read(512))
                    sck:on("sent", sendBlock)
                elseif page == "/status" then
                    sck:send("HTTP/1.0 200 OK\r\nAccess-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"..'{\"power\":'..tostring(gpio.read(5) == 0)..', \"hdd\":'..tostring(gpio.read(6) == 0)..'}')
                elseif page == "/set" then
                    local button, action = string.match(payload, "^GET .*\?button=(.*)\&action=(.*) HTTP")
                    local head200 = "HTTP/1.0 200 OK\r\nAccess-Control-Allow-Origin: *\r\n"
                    local head400 = "HTTP/1.0 400 OK\r\nAccess-Control-Allow-Origin: *\r\n"
                    
                    if not button or not action then
                        sck:send(head400)
                        return
                    end
                    print("button "..button)
                    print("action "..action)
                    
                    if button == "power" then
                        local result = parseAction(action)
                        if result == 'err' then
                            sck:send(head400)
                        else
                            gpio.write(1, result)
                            sck:send(head200)
                        end
                    elseif button == "reset" then
                        local result = parseAction(action)
                        if result == 'err' then
                            sck:send(head400)
                        else
                            gpio.write(2, result)
                            sck:send(head200)
                        end
                    else
                        sck:send(head400)
                    end
                else
                    print(payload)
                    sck:send("HTTP/1.0 404 OK\r\nContent-Type: text/html\r\n")
                end
            end
        )
    conn:on("sent",
        function(sck)
            sck:close()
        end
    )
    end
)
