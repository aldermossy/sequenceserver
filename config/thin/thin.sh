#!/bin/bash

cd /home/app/webapp
export HOME=/root

chmod 755 /etc/service/thin/supervise
chown app /etc/service/thin/supervise/ok /etc/service/thin/supervise/control /etc/service/thin/supervise/status


exec chpst -u app:app thin -R ./config.ru start -p 4567 >>/var/log/thin.log 2>&1
