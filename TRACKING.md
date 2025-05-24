# Tracking Lontra Chess Engine Evolution

This document explains how to track and document the evolution of the Lontra chess engine's performance over time.

## Automated Benchmarking System

The project includes an automated benchmarking system that helps track the engine's performance as it evolves.

### Files

1. **EVOLUTION.md** - Contains the version history and performance metrics
2. **benchmark.sh** - Script to run engine tests and update performance metrics
3. **results.pgn** - Generated PGN file containing detailed game records

### Running Benchmarks

To run a benchmark and update the evolution tracking documents:

```bash
./benchmark.sh
```

This will:
1. Run multiple matches against reference engines with different skill levels
2. Calculate an estimated ELO rating for your engine
3. Update the EVOLUTION.md file with the results
4. Update the README.md with the current ELO rating

### Benchmark Configuration

You can modify the following parameters in `benchmark.sh`:

- `NUM_GAMES` - Number of games to play against each opponent (default: 100)
- `TIME_CONTROL` - Time control setting for games (default: 1+0)

### How ELO is Calculated

The ELO estimation is based on performance against engines with known approximate strengths:
- Stockfish Level 0 ≈ 1000 ELO
- Stockfish Level 1 ≈ 1100 ELO
- Stockfish Level 2 ≈ 1200 ELO

The formula used is: `NewElo = OpponentElo + 400 * log10(Score / (1 - Score))`

Note: This is a rough approximation for tracking relative progress over time.

## Manual Updates

You can also manually update the EVOLUTION.md file when you make significant changes to the engine:

1. Add a new entry to the version history table
2. Document key features added
3. Update performance metrics based on benchmark results
4. Add detailed notes about the changes

## Visualization

For a visual representation of the engine's progress over time, consider plotting the ELO ratings from EVOLUTION.md. You can use tools like:

- Gnuplot
- Python with matplotlib
- Excel/Google Sheets

Example command to generate a simple plot:
```bash
grep -o "Estimated ELO: ~[0-9]*" EVOLUTION.md | cut -d'~' -f2 > elo_history.txt
gnuplot -e "set terminal png; set output 'elo_progress.png'; plot 'elo_history.txt' with linespoints title 'Lontra ELO Progress'"
```

## Best Practices

1. Run benchmarks after each significant change
2. Use consistent settings for fair comparisons
3. Document not just the ELO, but also key features and improvements
4. Keep test games in the results directory for later analysis
