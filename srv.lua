local head200NoReturns = "HTTP/1.0 200 OK\r\nServer: ESPLUA\r\nConnection: close\r\nAccess-Control-Allow-Origin: *\r\n"
local head200 = head200NoReturns.."\r\n"
local head400 = "HTTP/1.0 400 Bad Request\r\nAccess-Control-Allow-Origin: *\r\n\r\nBad request"
local head404 = "HTTP/1.0 404 Not Found\r\nContent-Type: text/html\r\n\r\nNot Found"

local function parseAction(sck, pin, text, notanswer)
    if text == "on" then
        if not notanswer then
            sck:send(head200)
        end
        gpio.write(pin, gpio.HIGH)
    elseif text == "off" then
        if not notanswer then
            sck:send(head200)
        end
        gpio.write(pin, gpio.LOW)
    else
        if not notanswer then
            sck:send(head404)
        end
    end
end

Srv = net.createServer(net.TCP)
Srv:listen(80,
    function(conn)
        conn:on("receive",
            function(sck, payload)
                gpio.write(4, gpio.LOW)
                local page = string.match(payload, "^GET ([%/%w]*).*HTTP")
                local pages = {}

                if not page then
                    gpio.write(4, gpio.HIGH)
                    sck:send(head400)
                    return
                end
                
                print("request "..page)
                print("subpages:")
                local i = 1
                for v in string.gmatch(page, '([^%/]+)') do
                    pages[i] = v
                    i = i + 1
                    print("\t"..v)
                end
                
                if pages[1] == nil then
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
                    
                    sck:send(head200..currFile.read(512))
                    sck:on("sent", sendBlock)
                elseif pages[1] == "status" then
                    if pages[2] == "sse" then
                        --TODO server-sent-events
                    else
                        sck:send(head200NoReturns.."Content-Type: application/json\r\n\r\n"..'{\"power\":'..tostring(gpio.read(5) == 0)..', \"hdd\":'..tostring(gpio.read(6) == 0)..'}')
                    end
                elseif pages[1] == "set" then
                    if pages[2] == "power" then
                        parseAction(sck, 1, pages[3])
                    elseif pages[2] == "reset" then
                        parseAction(sck, 2, pages[3])
                    elseif pages[2] == "all" then
                        parseAction(sck, 1, pages[3], true)
                        parseAction(sck, 2, pages[3])
                    else
                        sck:send(head400)
                    end
                else
                    print(payload)
                    sck:send(head404)
                end

                gpio.write(4, gpio.HIGH)
            end
        )
    conn:on("sent",
        function(sck)
            sck:close()
        end
    )
    end
)
