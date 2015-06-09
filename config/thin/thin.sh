#!/bin/bash

cd /home/app/webapp
export HOME=/root
exec chpst -u app:app thin -R ./config.ru start -p 4567 >>/var/log/thin.log 2>&1
