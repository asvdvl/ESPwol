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
    end
)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, 
    function(T)
        print("\n\tSTA - GOT IP".."\n\tIP: "..T.IP.."\n\tnetmask: "..T.netmask.."\n\tgateway: "..T.gateway)
    end
)

dofile('srv.lua')

print('init.lua fin')
