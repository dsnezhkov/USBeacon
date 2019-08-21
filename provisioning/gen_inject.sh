#!/bin/bash

DSCRIPT="ducky_script_w10.txt"
#DSCRIPT="ducky_script_osx.txt"
INJECT="dist/inject.bin"

echo "!!!! Binarizing $DSCRIPT  -> $INJECT !!!!"
java -jar duckencoder.jar -i $DSCRIPT  -o $INJECT -l us.layout
