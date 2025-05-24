#include "engine.hpp"
#include "uci.hpp"
#include <iostream>

/**
 * @brief Entry point for the Lontra chess engine
 * 
 * This file initializes the engine and starts the UCI protocol handler.
 */
int main() {
    // Disable output buffering for real-time UCI communication
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    
    try {
        // Initialize the engine
        lontra::Engine engine;
        
        // Initialize the UCI handler with the engine
        lontra::UCI uci(engine);
        
        // Start the main UCI loop
        uci.mainLoop();
    } catch (const std::exception& e) {
        std::cerr << "Fatal error: " << e.what() << std::endl;
        return 1;
    } catch (...) {
        std::cerr << "Unknown fatal error" << std::endl;
        return 1;
    }
    
    return 0;
}
