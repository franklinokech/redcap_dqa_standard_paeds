#!/bin/bash
cd ~/hsuApps/docker/redcap_dqa_standard_paeds
docker compose up --abort-on-container-exit
xdg-open cin_paeds/data/output
read -p "Press Enter to close..."
