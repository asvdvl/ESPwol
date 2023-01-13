# WARNING
THIS PROJECT I CREATED FOR MYSELF ONLY, THIS SOFTWARE IS PROVIDED "AS IS".\
You can create an issue or a pull request, but I can't guarantee that I can handle it.\
P.S. The project planned to listen for packets to find the "magic packet" (true WoL), but given that esp is a low-power controller, I decided to refuse this, maybe in the future I will return to this issue. If you need to "click on a button" see the documentation below.
## ESPwol remote control pc
* show power led
* show hdd activity
* "press/hold" power button
* "press/hold" reset button

## using modulses
* `file gpio gpio_pulse net node tmr uart wifi`
* try to build youself firmware with this modules if default firmware craches.

## install
* turn your nodeMCU device into lua mode
* download and open this repo in `ESPlorer`
* edit your wifi credentials in `config.lua`
* use `ESPlorer` connect to your ESP
* load `index.html, init.lua, config.lua and srv.lua` into esp using the "Upload..." button located under the built-in code editor
* reset your esp and find her ip address in the console
* go to `http://<ESP-ADDR>` and enjoy!

## How to use 
* go to `http://<ESP-ADDR>` and enjoy!
* you will see 2 "LEDs" that show the power and activity of the hard drive on the real computer, they are updated in real time
* also you will see 2 "power" and "reset" buttons WHILE YOU PRESS 1 OF THESE BUTTONS REAL ESP WILL KEEP THIS "button" ON, this gives you the ability to make both "short" and long presses that you may need on different occasions

## Mini documentation
### files for ESP
* `config.lua` - CONFIG FILE, wifi credentials
* `index.html` - main web file with some css, js and...html, esp send him on `/` request
* `init.lua` - main load module, initialize wifi, dhcp client, load `srv.lua`
* `srv.lua` - web server module
### API
* `GET /status` - return json `{"power":true|false, "hdd":true|false}` where 
  * `power` - state of `D5` pin
  * `hdd` - state of `D6` pin
* `GET /set/[power|reset|all]/[on|off]` where
  * `button`
    * `power` - work with `D1` pin
    * `reset` - work with `D2` pin
  * `action`
    * `on` - set `HIGH` to `button` pin
    * `off` - set `LOW` to `button` pin
### API Linux examples
* `wget -qO - http://<IP-YOUR-ESP>/status` - get to output input status
* `wget -qO - http://<IP-YOUR-ESP>/set/power/on` - turn on power button and hold infinity
* `wget -qO- http://<IP-YOUR-ESP>/set/power/on ; sleep 0.5 ; wget -qO- http://<IP-YOUR-ESP>/set/power/off` - short press power button
* `wget -qO- http://<IP-YOUR-ESP>/set/reset/on ; sleep 0.5 ; wget -qO- http://<IP-YOUR-ESP>/set/reset/off` - short press reset button
* `wget -qO- http://<IP-YOUR-ESP>/set/all/on ; sleep 0.5 ; wget -qO- http://<IP-YOUR-ESP>/set/all/off` - short press power and reset button
* `wget -qO- http://<IP-YOUR-ESP>/set/power/on ; sleep 8 ; wget -qO- http://<IP-YOUR-ESP>/set/power/off` - long press power button(in many cases force shutdown pc)