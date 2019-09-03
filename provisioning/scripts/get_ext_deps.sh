#!/bin/bash
### https://github.com/hak5darren/USB-Rubber-Ducky
# Firmware
### !!!! This firmware is broken. It does not trigger the inject.bin. Us et heone from Firmware folder in ducky-flasher
# curl -q  https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Firmware/Images/c_duck_us.hex -o  c_duck_v2.hex

curl -q https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/ducky-flasher/Firmware/c_duck_v2.hex -o c_duck_v2.hex
curl -q  https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Firmware/Images/c_duck_osx.hex -o  c_duck_osx.hex
# Encoder
curl -q https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Encoder/encoder.jar  -o encoder.jar
# Layout you need
curl https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Encoder/resources/us.properties -o us.layout
# VID & PID SWAPPER
curl -q https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Firmware/Utils/VID_PID_SWAPPER/VID_PID_SWAPPER.cpp -o VID_PID_SWAPPER.cpp 
curl -q https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Firmware/Utils/VID_PID_SWAPPER/VIDPID.txt -o VIDPID.txt 


