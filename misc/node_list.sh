#!/usr/bin/expect #Where the script should be run from.
spawn telnet 192.168.221.1 23
expect "Escape character is '^]'."
expect "Login:"
send "admin\r"
expect "Password:"
send "admin\r"
expect "(config)>"
send "show ip arp\r"
expect "(config)>"
send "exit\r"
#close