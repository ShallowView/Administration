#!/bin/bash

rm -rf logConso

sudo apt install -y bc --no-install-suggests --no-install-recommends

sudo sh -c "echo \"0 * * * * root cd $(pwd) && bash consumTracker.sh\" > /etc/cron.d/conso"
