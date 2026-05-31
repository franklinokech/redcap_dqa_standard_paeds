#!/bin/bash
cat > ~/Desktop/RUN_CIN_NEON_STANDARD_DQA.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=CIN Standard Neonatal DQA
Comment=Run DQA
Exec=/home/bob/hsuApps/docker/redcap_dqa_standard_neon/run_dqa.sh
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Office;
EOF

chmod +x ~/Desktop/RUN_CIN_NEON_STANDARD_DQA.desktop