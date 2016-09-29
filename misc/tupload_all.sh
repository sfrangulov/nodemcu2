#!/bin/sh
for i in *.lua; do ./tupload.sh $1 $2 $i $i; done
./node_restart.sh $1 $2