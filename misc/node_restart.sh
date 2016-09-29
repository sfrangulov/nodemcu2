#!/usr/bin/expect #Where the script should be run from.
#If it all goes pear shaped the script will timeout after 20 seconds.
set timeout 20
#First argument is assigned to the variable ip
set ip [lindex $argv 0]
#Second argument is assigned to the variable port
set port [lindex $argv 1]
spawn telnet $ip $port
expect "Escape character is '^]'."
sleep 1
send "node.restart()\r"
send "print(\"done\")\r"
expect "done"
sleep 1
close