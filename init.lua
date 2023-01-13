---@diagnostic disable: undefined-global
wifi.setmode(wifi.STATION)

dofile('config.lua')
wifi.sta.config(Station_cfg)
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,
    function(T)
        print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\tChannel: "..T.channel)
        WaitWifiConnect:update(2, { loop=3 })
    end
)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,
    function(T)
        print("\n\tSTA - GOT IP".."\n\tIP: "..T.IP.."\n\tnetmask: "..T.netmask.."\n\tgateway: "..T.gateway)
        WaitWifiConnect:update(4, { loop=5 })
    end
)

gpio.mode(1, gpio.OUTPUT)
gpio.mode(2, gpio.OUTPUT)
gpio.mode(5, gpio.INPUT, gpio.PULLUP)
gpio.mode(6, gpio.INPUT, gpio.PULLUP)
gpio.mode(4, gpio.OUTPUT)

WaitWifiConnect = gpio.pulse.build( {
    {[4] = gpio.LOW, delay=500000},
    {[4] = gpio.HIGH, delay=500000, loop = 1, count=100000, min=490000, max=510000},
    {[4] = gpio.LOW, delay=200000},
    {[4] = gpio.HIGH, delay=200000, loop = 3, count=100000, min=19000, max=210000},
    {[4] = gpio.LOW, delay=20000, count=100000, min=19000, max=21000},
    {[4] = gpio.HIGH, delay=9000000, loop = 5, count=10000000, min=8900000, max=9100000}
})

WaitWifiConnect:start(function() end)

dofile('srv.lua')
