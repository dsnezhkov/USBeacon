#!/bin/bash


reflash(){
		  echo '[*] Making backup of stock firmware' 
		   sudo /usr/local/bin/dfu-programmer at32uc3b1256 dump > backup_orig_frm.bin
		  echo '[*] Erasing RD device'
		   sudo /usr/local/bin/dfu-programmer at32uc3b1256 erase
		  echo '[*] Flashing TwinDuck firmware'
		   sudo /usr/local/bin/dfu-programmer at32uc3b1256 flash --suppress-bootloader-mem c_duck_v2.1.hex
		  echo '[*] Making RD operational'
		   sudo /usr/local/bin/dfu-programmer at32uc3b1256 reset
		  echo '[*] All done'
}
pcopy(){
		  echo '[*] Copying payload to RD'
		  sleep 5
			## Your name of mounted disk may be different
		  #cp ./dist/* /Volumes/Untitled
		  cp ./dist/* /Volumes/NO\ NAME
		  echo '[*] Unmounting RD HW'
		  diskutil unmount /dev/disk3s1
}

if [[ "$#" -ne 1 ]]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 <reflash|pcopy>"
else
	case $1 in
		"reflash")
			echo "Reflashing..."
			reflash
			;;
		"pcopy")
			echo "Pcopy..."
			pcopy
			;;
		 *)
			echo "Invalid operation."
    		echo "Usage: $0 <reflash|pcopy>"
			;;
	esac	
fi
