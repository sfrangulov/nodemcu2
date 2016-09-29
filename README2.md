Список нод (имя/IP/MAC):
    ESP8266_8969997     192.168.221.36    5c:cf:7f:88:df:0d
    ESP8266_1794771     192.168.221.41    5c:cf:7f:1b:62:d3
    ESP8266_8777054     192.168.221.38    5c:cf:7f:85:ed:5e

MQTT команды для ноды:
    task/[ESP8266_XXXXXX]/
        restart - перезагрузка
        getindicators - получить список индикаторов
        setinterval - установить интервал для всех датчиков в секундах
        resetlast - сброс предыдущих показаний индикаторов
    task/[ESP8266_XXXXXX]/[SENSOR_ID]/
        interval - установить интервал для датчика
        auto_off - время автоматического отключения реле
        mode - change - отправлять данные только при изменении или allways - всегда по интервалу
    task/[ESP8266_XXXXXX]/[SENSOR_ID].[INDICATOR_ID] - установка значения, только для реле
    task/[ESP8266_XXXXXX]/[SENSOR_ID].[INDICATOR_ID]/disabled - отключение передачи данных по индикатору

Типы индикаторов:
    temperature
    humidity
    pressure
    state - состояние реле
    level - уровень в %

Wi-fi
    SSID: iot (точка скрыта, добавляется руками)
    password: Kitty12345

Порт:
ls /dev/cu.*

Поиск нод с мака:
dns-sd -B _telnet._tcp .

Прошивка:
python "../esptool/esptool.py" --port /dev/cu.wchusbserialfa1340 erase_flash
python "../esptool/esptool.py" --port /dev/cu.wchusbserialfa1340 --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 32m 0x0000 nodemcu-master-13-modules-2016-09-26-10-59-28-integer.bin 0x3FC000 esp_init_data_default.bin

Зашить все скрипты:
nodemcu-tool upload *.lua
nodemcu-tool upload *.json