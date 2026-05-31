#!/bin/bash
cd ~/hsuApps/docker/redcap_dqa_standard_mnh
docker compose up --abort-on-container-exit
xdg-open cin_maternal/data/output
read -p "Press Enter to close..."
