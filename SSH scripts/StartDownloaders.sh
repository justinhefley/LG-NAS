#!/bin/bash
ssh root@192.168.1.15 "/root/startall.sh start < /dev/null >> /tmp/mediacenter.log 2>&1 &"
exit