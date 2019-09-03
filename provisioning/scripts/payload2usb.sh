#!/bin/bash


reflash(){

          #DFUPROGRAMMER="/usr/local/bin/dfu-programmer"
          DFUPROGRAMMER="./dfu-programmer"
          #FIRMWARE="USB_v2.1.hex"
          #FIRMWARE="c_duck_us.hex"
          #FIRMWARE="c_duck_osx.hex"
          #FIRMWARE="c_duck_v2.1.hex"
          FIRMWARE="c_duck_v2.hex"

		  echo '[*] Making backup of stock firmware' 
		   sudo $DFUPROGRAMMER at32uc3b1256 dump > backup_orig_frm.bin
		  echo '[*] Erasing RD device'
           sleep 1 
		   sudo $DFUPROGRAMMER at32uc3b1256 erase
		  echo "[*] Flashing ( ${FIRMWARE} )  firmware"
           sleep 1
		   sudo $DFUPROGRAMMER at32uc3b1256 flash --suppress-bootloader-mem $FIRMWARE
           sleep 1
		  echo '[*] Making RD operational'
		   sudo $DFUPROGRAMMER at32uc3b1256 reset
		  echo '[*] All done'
}
pcopy(){
		  echo '[*] Copying payload to RD'
		  sleep 3
		  ## Your volume name and/or disk path may be different. Check and adjust
          # rename:  diskutil rename  /Volumes/NO\ NAME\ 1/ PINGID
		  cp -R ./dist/* /Volumes/PINGID
		  echo '[*] Unmounting RD HW'
		  sudo diskutil unmount /dev/disk3s1
}

if [[ "$#" -ne 1 ]]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 <reflash|pcopy>"
    echo "        1. reflash - remount SD-CARD in DFU mode to flash firmware and script" 
    echo "        2. pcopy - remount SD-CARD in Data mode to copy payload"
else
	case $1 in
		"reflash")
			echo "Reflashing..."
			reflash
			;;
		"pcopy")
			echo "Copyng payload..."
			pcopy
			;;
		 *)
			echo "Invalid operation."
    		echo "Valid options: <reflash|pcopy>"
			;;
	esac	
fi
