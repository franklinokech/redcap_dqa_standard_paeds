#!/bin/bash
cd ~/hsuApps/docker/redcap_dqa_standard_neon
docker compose up --abort-on-container-exit
xdg-open cin_neon/data/output
read -p "Press Enter to close..."
