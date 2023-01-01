print('start exec srv.lua')

Srv = net.createServer(net.TCP)
Srv:listen(80,
    function(conn)
        conn:on("receive",
            function(sck, payload)
                local page = string.match(payload, "^GET (.*) HTTP")
                print("request "..page)
                
                if page == "/" then
                    file.open("index.html")
                    sck:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"..file.read())
                    
                    local chunck = file.read()
                    while chunck do
                        sck:send(chunck)
                        chunck = file.read()
                    end
                    
                    file.close()
                elseif page == "/status" then
                    sck:send("HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\n\r\n")
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

print('srv.lua fin')
