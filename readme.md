## ESPwol remote control pc
* show power led
* show hdd activity
* "press/hold" power button
* "press/hold" reset button

# using modulses
* `file gpio gpio_pulse net node tmr uart wifi`
* try to build youself firmware with this modules if default firmware craches.

## install
* turn your nodeMCU device into lua mode
* download and open this repo in `ESPlorer`
* edit your wifi credentials in `init.lua`
* use `ESPlorer` to load `index.html, init.lua and srv.lua` into esp using the "Load..." button located under the built-in code editor
* reset your esp and find her ip address in the console
* go to `http://<ESP-ADDR>` and enjoy!