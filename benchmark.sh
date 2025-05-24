#!/bin/bash
# Automated benchmark script for Lontra chess engine
# This script runs tests against reference engines and updates the EVOLUTION.md file

# Configuration
LONTRA_PATH="./build/lontra"
STOCKFISH_PATH="/usr/games/stockfish"
NUM_GAMES=100
TIME_CONTROL="1+0"
VERSION=$(grep "getVersion" ./include/engine.hpp | awk -F'"' '{print $2}')
DATE=$(date +%Y-%m-%d)

echo "=== Lontra Chess Engine Benchmark Tool ==="
echo "Version: $VERSION"
echo "Date: $DATE"

# Check if engines exist
if [ ! -f "$LONTRA_PATH" ]; then
    echo "Error: Lontra engine not found at $LONTRA_PATH"
    exit 1
fi

if [ ! -f "$STOCKFISH_PATH" ]; then
    echo "Error: Stockfish engine not found at $STOCKFISH_PATH"
    exit 1
fi

# Create temporary results directory
RESULTS_DIR="benchmark_results"
mkdir -p "$RESULTS_DIR"

# Function to run a match and analyze results
run_match() {
    local opponent=$1
    local opponent_path=$2
    local skill_level=$3
    local games=$4
    local tc=$5
    local output_file="$RESULTS_DIR/${opponent}_results.pgn"
    
    echo "Running $games games against $opponent (Skill Level: $skill_level)..."
    
    cutechess-cli \
        -engine name=Lontra cmd="$LONTRA_PATH" \
        -engine name="$opponent" cmd="$opponent_path" option.Skill\ Level=$skill_level \
        -each proto=uci tc="$tc" \
        -rounds $games \
        -repeat \
        -recover \
        -concurrency 1 \
        -pgnout "$output_file" \
        -wait 10 | tee "$RESULTS_DIR/${opponent}_output.txt"
    
    # Extract score from output
    local score_line=$(grep "Score of Lontra vs" "$RESULTS_DIR/${opponent}_output.txt" | tail -1)
    
    if [ -z "$score_line" ]; then
        echo "Warning: No score found for match against $opponent"
        echo "$opponent|0|$games|0|0%" >> "$RESULTS_DIR/summary.txt"
        return
    fi
    
    # Parse the score line
    local wins=$(echo $score_line | awk '{print $6}')
    local losses=$(echo $score_line | awk '{print $8}')
    local draws=$(echo $score_line | awk '{print $10}')
    local total=$(echo $score_line | awk '{print $12}')
    
    # Ensure we have valid numbers
    if ! [[ "$wins" =~ ^[0-9]+$ ]]; then wins=0; fi
    if ! [[ "$losses" =~ ^[0-9]+$ ]]; then losses=0; fi
    if ! [[ "$draws" =~ ^[0-9]+$ ]]; then draws=0; fi
    if ! [[ "$total" =~ ^[0-9]+$ ]]; then total=$games; fi
    
    # Calculate win percentage
    local win_percentage=0
    if [ $total -gt 0 ]; then
        win_percentage=$(echo "scale=2; 100 * ($wins + $draws/2) / $total" | bc)
    fi
    
    echo "Result against $opponent: $wins-$losses-$draws ($win_percentage%)"
    echo "$opponent|$wins|$losses|$draws|$win_percentage%" >> "$RESULTS_DIR/summary.txt"
}

# Clear previous results
rm -f "$RESULTS_DIR/summary.txt"
echo "Opponent|Wins|Losses|Draws|Score%" > "$RESULTS_DIR/summary.txt"

# Run matches against different opponents
run_match "Stockfish_L0" "$STOCKFISH_PATH" 0 $NUM_GAMES $TIME_CONTROL
run_match "Stockfish_L1" "$STOCKFISH_PATH" 1 $NUM_GAMES $TIME_CONTROL
run_match "Stockfish_L2" "$STOCKFISH_PATH" 2 $NUM_GAMES $TIME_CONTROL

# Calculate approximate ELO based on results
# This is a very rough estimate based on the assumption that:
# - Stockfish Level 0 ≈ 1000 ELO
# - Stockfish Level 1 ≈ 1100 ELO
# - Stockfish Level 2 ≈ 1200 ELO
# 
# Using the formula: NewElo = OpponentElo + 400 * log10(Score / (1 - Score))

calculate_elo() {
    local opponent=$1
    local base_elo=$2
    
    # Get win percentage 
    local score_line=$(grep "^$opponent" "$RESULTS_DIR/summary.txt")
    
    if [ -z "$score_line" ]; then
        echo "No data found for $opponent"
        echo "$opponent|$base_elo|0%|$(($base_elo - 400))" >> "$RESULTS_DIR/elo.txt"
        return
    fi
    
    local wins=$(echo $score_line | cut -d'|' -f2)
    local losses=$(echo $score_line | cut -d'|' -f3)
    local draws=$(echo $score_line | cut -d'|' -f4)
    
    # Calculate score
    local total_games=$(($wins + $losses + $draws))
    
    if [ "$total_games" -eq 0 ]; then
        echo "No games played against $opponent"
        echo "$opponent|$base_elo|0%|$(($base_elo - 400))" >> "$RESULTS_DIR/elo.txt"
        return
    fi
    
    local win_percentage=$(echo "scale=4; 100 * ($wins + $draws/2) / $total_games" | bc)
    
    # For random moves against strong engines, just estimate directly
    if [ "$win_percentage" = "0" ]; then
        local elo=$(($base_elo - 400))
        echo "$opponent|$base_elo|0%|$elo" >> "$RESULTS_DIR/elo.txt"
        return
    fi
    
    # Convert percentage to decimal
    local score=$(echo "scale=4; $win_percentage/100" | bc)
    
    # Avoid division by zero or negative logarithm
    if (( $(echo "$score < 0.001" | bc -l) )); then
        score="0.001"
    elif (( $(echo "$score > 0.999" | bc -l) )); then
        score="0.999"
    fi
    
    # Calculate ELO difference
    local elo_diff=$(echo "scale=0; 400 * l($score/(1-$score))/l(10)" | bc -l 2>/dev/null || echo "-400")
    
    # Calculate final ELO
    local elo=$(echo "$base_elo + $elo_diff" | bc)
    
    echo "$opponent|$base_elo|$win_percentage%|$elo" >> "$RESULTS_DIR/elo.txt"
}

# Clear previous ELO results
echo "Opponent|Base ELO|Score%|Estimated Lontra ELO" > "$RESULTS_DIR/elo.txt"

calculate_elo "Stockfish_L0" 1000
calculate_elo "Stockfish_L1" 1100
calculate_elo "Stockfish_L2" 1200

# Calculate average estimated ELO
AVG_ELO=$(awk -F'|' 'NR>1 {sum+=$4; count++} END {print int(sum/count)}' "$RESULTS_DIR/elo.txt")

echo "Estimated Lontra ELO: ~$AVG_ELO"

# Update the EVOLUTION.md file
update_evolution_file() {
    local version="$VERSION"
    local date="$DATE"
    local elo="$AVG_ELO"
    local features="UCI Protocol, Random Moves"
    
    # Check if the version already exists in the file
    if grep -q "| $version " EVOLUTION.md; then
        echo "Version $version already exists in EVOLUTION.md, not updating"
        return
    fi
    
    # Backup the file
    cp EVOLUTION.md EVOLUTION.md.bak
    
    # Insert the new version after the header line
    awk -v ver="$version" -v dt="$date" -v el="$elo" -v feat="$features" '
    /\| Version \| Date / {
        print $0;
        print "| " ver " | " dt " | " feat " | ~" el " (estimated) | Benchmark updated |";
        next;
    }
    { print $0 }
    ' EVOLUTION.md.bak > EVOLUTION.md
    
    # Add the detailed benchmark results
    cat >> EVOLUTION.md <<EOF

### Performance Results

#### v$version ($date)
$(awk -F'|' 'NR>1 {print "- **vs " $1 "**: " $2 "-" $3 "-" $4 " (" $5 " score)"}' "$RESULTS_DIR/summary.txt")
- **Estimated ELO**: ~$AVG_ELO

EOF
    
    echo "Updated EVOLUTION.md with benchmark results for version $version"
}

# Update the evolution file
update_evolution_file

# Update README.md with the current ELO score
update_readme() {
    # Look for ELO line in README.md
    if grep -q "Current ELO:" README.md; then
        # Update existing ELO information
        sed -i "s/Current ELO:.*$/Current ELO: ~$AVG_ELO/" README.md
        echo "Updated README.md with current ELO estimate"
    else
        # Add ELO information before the ## Usage section
        awk -v elo="$AVG_ELO" '
        /^## Uso/ || /^## Usage/ {
            print "Current ELO: ~" elo "\n";
            print $0;
            next;
        }
        { print $0 }
        ' README.md > README.md.new
        mv README.md.new README.md
        echo "Added ELO information to README.md"
    fi
}

# Update the README file
update_readme

echo "Benchmark completed! Results are in the $RESULTS_DIR directory"
echo "EVOLUTION.md has been updated with the latest benchmark results"
