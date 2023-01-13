local head200NoReturns = "HTTP/1.0 200 OK\r\nServer: ESPLUA\r\nAccess-Control-Allow-Origin: *\r\n"
local head200 = head200NoReturns.."\r\n"
local head400 = "HTTP/1.0 400 Bad Request\r\nAccess-Control-Allow-Origin: *\r\n\r\nBad request"
local head404 = "HTTP/1.0 404 Not Found\r\nContent-Type: text/html\r\n\r\nNot Found"

local sseCallbacksI = 1
local sseCallbacks = {}

local function sseCallback(level, when, eventcount)
    gpio.write(4, gpio.LOW)
    for _,v in pairs(sseCallbacks) do
        v()
    end
    gpio.write(4, gpio.HIGH)
end

local function addSseCallback(callback)
    sseCallbacks[sseCallbacksI] = callback
    print('add event '..sseCallbacksI)
    sseCallbacksI = sseCallbacksI + 1
    return sseCallbacksI
end

local function removeSseCallback(id)
    print('remove event '..id..'\ntotal: '..#sseCallbacks)
    table.remove(sseCallbacks, id)
end

gpio.trig(5, "both", sseCallback)
gpio.trig(6, "both", sseCallback)

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
                local i = 1
                for v in string.gmatch(page, '([^%/]+)') do
                    pages[i] = v
                    i = i + 1
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
                        local callbackID = 0
                        local function sendData()
                            if sck:getpeer() then
                                sck:send('data: {\"power\":'..tostring(gpio.read(5) == 0)..', \"hdd\":'..tostring(gpio.read(6) == 0)..'}\n\n')
                            else
                                print('not connected')
                                removeSseCallback(callbackID)
                            end
                        end
                        local tmer = tmr.create()
                        tmer:register(1000, tmr.ALARM_AUTO, sendData)
                        callbackID = addSseCallback(sendData)

                        sck:send(head200NoReturns.."Content-Type: text/event-stream\r\nCache-Control: no-cache\r\nConnection: keep-alive\r\n\r\n")
                        sck:on("disconnection",
                            function()
                                removeSseCallback(callbackID)
                                tmer:unregister()
                            end)
                        sck:on("sent", function() end)
                        tmer:start()
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
