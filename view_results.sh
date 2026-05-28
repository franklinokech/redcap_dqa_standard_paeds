#!/bin/bash
# =============================================================================
# View DQA Results - Open results folder and show summary
# =============================================================================

cd ~/Desktop/redcap_dqa

echo ""
echo "════════════════════════════════════════════════════════════"
echo "              DQA RESULTS VIEWER"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check if results exist
if [ -d "cin_maternal/data/output" ]; then
    result_files=$(ls -1 cin_maternal/data/output/dqa_*.csv 2>/dev/null)
    
    if [ -n "$result_files" ]; then
        echo "📊 Latest results:"
        echo ""
        ls -la cin_maternal/data/output/dqa_*.csv 2>/dev/null | while read line; do
            file=$(echo "$line" | awk '{print $9}')
            size=$(echo "$line" | awk '{print $5}')
            date=$(echo "$line" | awk '{print $6, $7, $8}')
            echo "  📄 $(basename "$file") - $size bytes - $date"
        done
        
        echo ""
        echo "Opening results folder..."
        xdg-open cin_maternal/data/output
    else
        echo "⚠ No results found. Run DQA first."
    fi
else
    echo "⚠ Results folder not found."
fi

echo ""
read -p "Press Enter to close..."
