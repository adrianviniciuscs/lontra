cmake_minimum_required(VERSION 3.10)
project(Lontra VERSION 0.1 LANGUAGES CXX)

# Set C++ standard to C++17 for compatibility
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add compiler warnings
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
elseif(MSVC)
    add_compile_options(/W4)
endif()

# Enable optimization for release builds
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()

# Add source files
set(SOURCES
    src/main.cpp
    src/engine.cpp
    src/uci.cpp
)

# Include directories
include_directories(include external)

# Create executable
add_executable(lontra ${SOURCES})

# Install target
install(TARGETS lontra DESTINATION bin)
