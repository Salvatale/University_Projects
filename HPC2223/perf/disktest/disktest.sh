#!/bin/bash

tempfile=tempfile-$(hostname -s)
count=2048

stop() { rm -f $tempfile; }

trap "stop" 2

echo 'Write to file:'
dd if=/dev/zero of=$tempfile bs=1M count=$count conv=fdatasync,notrunc

sleep 5
echo

echo 'Read from file:'
dd if=$tempfile of=/dev/null bs=1M count=$count

#stop

