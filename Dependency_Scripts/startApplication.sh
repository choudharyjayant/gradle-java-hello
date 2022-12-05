#!/bin/bash
cd /home/ubuntu/order/target/
nohup java -jar order-service.jar  > /dev/null 2>&1 &
