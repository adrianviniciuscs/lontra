#include "uci.hpp"
#include "engine.hpp"
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

namespace lontra {

UCI::UCI(Engine& engine) : engine_(engine) {}

void UCI::mainLoop() {
    std::string line;
    
    while (std::getline(std::cin, line)) {
        // Skip empty lines
        if (line.empty()) {
            continue;
        }
        
        // Tokenize the command
        std::vector<std::string> tokens = tokenize(line);
        
        if (tokens.empty()) {
            continue;
        }
        
        // Process commands
        const std::string& cmd = tokens[0];
        
        if (cmd == "uci") {
            handleUci();
        } else if (cmd == "isready") {
            handleIsReady();
        } else if (cmd == "position") {
            handlePosition(line);
        } else if (cmd == "go") {
            handleGo(line);
        } else if (cmd == "quit" || cmd == "exit") {
            handleQuit();
            break;
        } else if (cmd == "ucinewgame") {
            // Set up a new game with the starting position
            engine_.setPosition("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
        } else if (cmd == "stop") {
            // In our simple engine, this does nothing as search is instantaneous
            // But we acknowledge it for UCI compliance
        } else if (cmd == "setoption") {
            // We don't have options yet, but acknowledge for UCI compliance
        } else {
            // Unknown command - just ignore
            sendResponse("info string Unknown command: " + cmd);
        }
    }
}

void UCI::handleUci() {
    // Respond with engine information as per UCI protocol
    sendResponse("id name " + engine_.getName() + " " + engine_.getVersion());
    sendResponse("id author " + engine_.getAuthor());
    // We don't have options yet, but this is where we would put them
    // sendResponse("option name Example type check default false");
    sendResponse("uciok");
}

void UCI::handleIsReady() {
    // Always ready in this simple implementation
    sendResponse("readyok");
}

void UCI::handlePosition(const std::string& command) {
    std::istringstream iss(command);
    std::string token;
    
    // Skip "position" token
    iss >> token;
    
    // Check if the next token is "startpos" or "fen"
    std::string fen;
    std::vector<std::string> moves;
    
    iss >> token;
    
    if (token == "startpos") {
        // Use the starting position
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
        
        // Check if there are moves to apply
        if (iss >> token && token == "moves") {
            while (iss >> token) {
                moves.push_back(token);
            }
        }
    } else if (token == "fen") {
        // Read the FEN string (which can have spaces)
        std::string fenPart;
        int fenParts = 0;
        
        while (iss >> fenPart && fenParts < 6) {
            fen += fenPart + (fenParts < 5 ? " " : "");
            fenParts++;
        }
        
        // Check if there are moves to apply
        if (iss >> token && token == "moves") {
            while (iss >> token) {
                moves.push_back(token);
            }
        }
    }
    
    // Set the position in the engine
    if (!fen.empty()) {
        engine_.setPosition(fen, moves);
    }
}

void UCI::handleGo(const std::string& command) {
    std::istringstream iss(command);
    std::string token;
    
    // Skip "go" token
    iss >> token;
    
    // Default values
    int depth = 1;
    int movetime = 1000; // 1 second
    
    // Parse go parameters
    while (iss >> token) {
        if (token == "depth" && iss >> token) {
            depth = std::stoi(token);
        } else if (token == "movetime" && iss >> token) {
            movetime = std::stoi(token);
        }
        // Other parameters like wtime, btime, etc. are ignored for now
    }
    
    // Search for the best move
    std::string bestMove = engine_.search(depth, movetime);
    
    // Send the best move
    sendResponse("bestmove " + bestMove);
}

void UCI::handleQuit() {
    // Nothing specific to do
}

std::vector<std::string> UCI::tokenize(const std::string& command) {
    std::istringstream iss(command);
    std::vector<std::string> tokens;
    std::string token;
    
    while (iss >> token) {
        tokens.push_back(token);
    }
    
    return tokens;
}

void UCI::sendResponse(const std::string& response) {
    std::cout << response << std::endl;
}

} // namespace lontra
