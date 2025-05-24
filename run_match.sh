#!/bin/bash
# Script to run a match between Lontra and Stockfish using cutechess-cli

# Path to the engines
LONTRA_PATH="/home/adrian/projetos/lontra/build/lontra"
STOCKFISH_PATH="/usr/games/stockfish"

# Make sure the engines exist
if [ ! -f "$LONTRA_PATH" ]; then
    echo "Error: Lontra engine not found at $LONTRA_PATH"
    exit 1
fi

if [ ! -f "$STOCKFISH_PATH" ]; then
    echo "Error: Stockfish engine not found at $STOCKFISH_PATH"
    exit 1
fi

# Number of games to play
NUM_GAMES=100

# Time control (1 second per move)
TIME_CONTROL="1+0"

# Run the match using cutechess-cli
cutechess-cli \
  -engine name=Lontra cmd="$LONTRA_PATH" \
  -engine name=Stockfish cmd="$STOCKFISH_PATH" option.Skill\ Level=0 \
  -each proto=uci tc="$TIME_CONTROL" \
  -rounds $NUM_GAMES \
  -repeat \
  -recover \
  -concurrency 1 \
  -pgnout results.pgn \
  -wait 10

echo "Match complete! Results are in results.pgn"
