#!/bin/bash

# alternative: use https://ducktoolkit.com/vidpid
clang++ -o vidpidswapper VID_PID_SWAPPER.cpp
chmod +x vidpidswapper
./vidpidswapper && mv vidpid.bin ./dist
