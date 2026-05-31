#!/bin/bash
cat > ~/Desktop/RUN_CIN_PAEDS_STANDARD_DQA.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=CIN Standard Paeds DQA
Comment=Run DQA
Exec=/home/bob/hsuApps/docker/redcap_dqa_standard_paeds/run_dqa.sh
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Office;
EOF

chmod +x ~/Desktop/RUN_CIN_PAEDS_STANDARD_DQA.desktop