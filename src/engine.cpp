#include "engine.hpp"
#include <algorithm>
#include <iostream>
#include <vector>
#include <random>
#include <chrono>

namespace lontra {

Engine::Engine() 
    // Initialize with a time-based random seed
    : rng_(std::chrono::steady_clock::now().time_since_epoch().count()) {
    // Initialize with the standard starting position
    board_.setFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
}

void Engine::setPosition(const std::string& fen, const std::vector<std::string>& moves) {
    try {
        // Set the position from FEN
        board_.setFen(fen);
        
        // Apply additional moves if provided
        for (const auto& moveStr : moves) {
            chess::Move move = chess::uci::uciToMove(board_, moveStr);
            if (move != chess::Move::NULL_MOVE) {
                board_.makeMove(move);
            }
        }
    } catch (const std::exception& e) {
        std::cerr << "Error setting position: " << e.what() << std::endl;
        // Fallback to the starting position if there was an error
        board_.setFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    }
}

std::string Engine::search(int depth, int movetime) {
    // In this random move implementation, we ignore depth and movetime
    // These parameters are kept for future enhancements
    (void)depth;    // Silence unused parameter warning
    (void)movetime; // Silence unused parameter warning
    
    // Print some info about the search (useful for GUIs)
    std::cout << "info string Lontra is thinking..." << std::endl;
    
    // Generate all legal moves for the current position
    chess::Movelist movelist;
    chess::movegen::legalmoves(movelist, board_);
    
    // Output number of legal moves (useful info)
    std::cout << "info string Legal moves: " << movelist.size() << std::endl;
    
    // If no legal moves are available, return "(none)"
    if (movelist.size() == 0) {
        return "(none)";
    }
    
    // Pick a random move from the list of legal moves
    std::uniform_int_distribution<size_t> dist(0, movelist.size() - 1);
    chess::Move selectedMove = movelist[dist(rng_)];
    
    // Output the selected move in algebraic notation for information
    std::cout << "info string Selected move: " << chess::uci::moveToUci(selectedMove) << std::endl;
    
    // Convert the move to UCI format (e.g., "e2e4")
    return chess::uci::moveToUci(selectedMove);
}

} // namespace lontra
