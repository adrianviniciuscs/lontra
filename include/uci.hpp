#ifndef LONTRA_UCI_HPP
#define LONTRA_UCI_HPP

#include <string>
#include <vector>
#include <functional>
#include "chess.hpp"

namespace lontra {

// Forward declarations
class Engine;

/**
 * @brief Class responsible for handling UCI protocol communication
 * 
 * This class processes UCI commands from stdin and sends responses to stdout
 * according to the UCI protocol specifications.
 */
class UCI {
public:
    /**
     * @brief Constructor for UCI handler
     * @param engine Reference to the chess engine
     */
    explicit UCI(Engine& engine);

    /**
     * @brief Main loop to handle UCI commands
     * 
     * Listens for commands from stdin and calls appropriate handlers
     */
    void mainLoop();

private:
    // Reference to the chess engine
    Engine& engine_;

    // UCI command handlers
    void handleUci();
    void handleIsReady();
    void handlePosition(const std::string& command);
    void handleGo(const std::string& command);
    void handleQuit();
    
    // Helper methods
    std::vector<std::string> tokenize(const std::string& command);
    void sendResponse(const std::string& response);
};

} // namespace lontra

#endif // LONTRA_UCI_HPP
