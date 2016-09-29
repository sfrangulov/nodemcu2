#!/bin/sh
port="$(ls /dev/cu.wchusbserial*)"
echo "Detected on port $port"
python "$HOME/Downloads/esptool/esptool.py" --port $port erase_flash
sleep 5
python "$HOME/Downloads/esptool/esptool.py" --port $port --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 32m 0x0000 firmware/nodemcu.bin 0x3FC000 firmware/esp_init_data_default.bin