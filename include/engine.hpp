#ifndef LONTRA_ENGINE_HPP
#define LONTRA_ENGINE_HPP

#include <string>
#include <random>
#include <chrono>
#include <vector>
#include "chess.hpp"

namespace lontra {

/**
 * @brief Main chess engine class
 * 
 * This class represents the Lontra chess engine, which initially plays
 * random legal moves. It's designed to be modular for future enhancements.
 */
class Engine {
public:
    /**
     * @brief Constructor
     */
    Engine();

    /**
     * @brief Sets up a position from FEN string
     * @param fen FEN string representation of the chess position
     * @param moves Additional moves to apply after the FEN position (optional)
     */
    void setPosition(const std::string& fen, const std::vector<std::string>& moves = {});
    
    /**
     * @brief Makes the engine search for the best move
     * @param depth The depth to search (not used in the random version)
     * @param movetime Maximum time to think in milliseconds (not used in the random version)
     * @return The best move in UCI format (e.g., "e2e4")
     */
    std::string search(int depth = 1, int movetime = 1000);
    
    /**
     * @brief Get the name of the engine
     * @return The engine name
     */
    std::string getName() const { return "Lontra"; }
    
    /**
     * @brief Get the version of the engine
     * @return The engine version
     */
    std::string getVersion() const { return "0.1"; }
    
    /**
     * @brief Get the author of the engine
     * @return The engine author
     */
    std::string getAuthor() const { return "Lontra Team"; }

private:
    // The chess board representation
    chess::Board board_;
    
    // Random number generator for move selection
    std::mt19937 rng_;
};

} // namespace lontra

#endif // LONTRA_ENGINE_HPP
