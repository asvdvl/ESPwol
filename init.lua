---@diagnostic disable: undefined-global
print('start exec init.lua')

wifi.setmode(wifi.STATION)
Station_cfg={}
Station_cfg.ssid = "xxx"
Station_cfg.pwd = "xxx"
Station_cfg.save = false
wifi.sta.config(Station_cfg)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, 
    function(T)
        print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\tChannel: "..T.channel)
        waitWifiConnect:update(2, { loop=3 })
    end
)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,
    function(T)
        print("\n\tSTA - GOT IP".."\n\tIP: "..T.IP.."\n\tnetmask: "..T.netmask.."\n\tgateway: "..T.gateway)
        waitWifiConnect:stop(4, function() end)
        waitWifiConnect = nil
    end
)

gpio.mode(1, gpio.OUTPUT)
gpio.mode(2, gpio.OUTPUT)
gpio.mode(5, gpio.INPUT)
gpio.mode(6, gpio.INPUT)
gpio.mode(4, gpio.OUTPUT)

waitWifiConnect = gpio.pulse.build( {
    {[4] = gpio.LOW, delay=500000},
    {[4] = gpio.HIGH, delay=500000, loop = 1, count=100000, min=490000, max=510000},
    {[4] = gpio.LOW, delay=200000},
    {[4] = gpio.HIGH, delay=200000, loop = 3, count=100000, min=190000, max=210000}
})

waitWifiConnect:start(function() end)

dofile('srv.lua')
print('init.lua fin')