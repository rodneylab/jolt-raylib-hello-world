cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

project(
  JoltRaylibHelloWorld
  VERSION 0.0.1
  DESCRIPTION
    "Jolt Physics raylib: trying Jolt C++ game development physics library with raylib in a 3D hello world bouncing sphere example."
  LANGUAGES C CXX)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_EXPORT_COMPILE_COMMANDS True)
add_library(jolt_raylib_hello_world_compiler_flags INTERFACE)
target_compile_features(jolt_raylib_hello_world_compiler_flags
                        INTERFACE cxx_std_17)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

include(Dependencies.cmake)
jolt_raylib_hello_world_setup_dependencies()

set(gcc_like_cxx "$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>")
set(msvc_cxx "$<COMPILE_LANG_AND_ID:CXX,MSVC>")
target_compile_options(
  jolt_raylib_hello_world_compiler_flags
  INTERFACE
    "$<${gcc_like_cxx}:$<BUILD_INTERFACE:-pedantic-errors;-Werror;-Wall;-Weffc++;-Wextra;-Wconversion;-Wsign-conversion>>"
    "$<${msvc_cxx}:$<BUILD_INTERFACE:-W4>>")

include(cmake/StaticAnalysers.cmake)
enable_clang_tidy()

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${PROJECT_SOURCE_DIR}/cmake")
option(RUN_TESTS "Enable tests" ON)
include(coverage)
add_coverage_target("Catch_tests/*")

# The configurations we support
set(CMAKE_CONFIGURATION_TYPES "Debug;Release;Distribution")

# Set linker flags
set(CMAKE_EXE_LINKER_FLAGS_DISTRIBUTION "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")

# Enable link time optimization in Release and Distribution mode if requested
# and available
set_interprocedural_optimization()

# Compile the HelloWorld application
add_executable(JoltRaylibHelloWorld src/main.cpp src/game/game.cpp
                                    src/physics.cpp)
target_include_directories(JoltRaylibHelloWorld
                           PRIVATE ${JoltPhysics_SOURCE_DIR}/..)
target_include_directories(JoltRaylibHelloWorld
                           PUBLIC "${PROJECT_SOURCE_DIR}/src")
target_link_libraries(
  JoltRaylibHelloWorld
  PRIVATE Jolt
          fmt
          imgui
          raylib
          rlimgui
          spdlog::spdlog_header_only
          jolt_raylib_hello_world_compiler_flags)
target_compile_definitions(JoltRaylibHelloWorld PRIVATE SPDLOG_FMT_EXTERNAL)
target_compile_definitions(
  JoltRaylibHelloWorld PUBLIC ASSETS_PATH="${CMAKE_CURRENT_SOURCE_DIR}/assets/")

# Make this project the startup project
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT "JoltRaylibHelloWorld")

option(RUN_UNIT_TESTS "Run Catch2 unit tests" ON)
if(RUN_UNIT_TESTS)
  enable_testing()
  add_subdirectory(Catch_tests)
endif()
