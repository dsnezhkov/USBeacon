#!/bin/bash
### https://github.com/hak5darren/USB-Rubber-Ducky
# Firmware
curl -q  https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Firmware/Images/c_duck_v2.1.hex -o  c_duck_v2.1.hex
# Encoder
curl -q https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Encoder/encoder.jar -o encoder.jar
# Layout you need
curl https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Encoder/resources/us.properties -o us.layout
# VID & PID SWAPPER
curl -q https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Firmware/Utils/VID_PID_SWAPPER/VID_PID_SWAPPER.cpp -o VID_PID_SWAPPER.cpp 
curl -q https://raw.githubusercontent.com/hak5darren/USB-Rubber-Ducky/master/Firmware/Utils/VID_PID_SWAPPER/VIDPID.txt -o VIDPID.txt 


