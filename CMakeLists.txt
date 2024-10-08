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
    "$<${msvc_cxx}:$<BUILD_INTERFACE:-W4;Zc;-__cplusplus;-Gm-;-MP;-nologo;-diagnostics:classic;-FC;-fp:except-;-Zc:inline;-GR->>"
)


if (MSVC)
	# 64 bit architecture
	set(CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE "x64")

	# Set runtime library
	if (USE_STATIC_MSVC_RUNTIME_LIBRARY)
		set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
	else()
		set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
	endif()

	# Set general compiler flags
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:__cplusplus /Gm- /Wall /WX /MP /nologo /diagnostics:classic /FC /fp:except- /Zc:inline")

	# Optionally generate debug symbols
	if (GENERATE_DEBUG_SYMBOLS)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zi")
	endif()

	# Remove any existing compiler flag that enables RTTI
    #string(REPLACE "/GR" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})

	# Set compiler flag for disabling RTTI
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /GR-")

	if ("${CMAKE_VS_PLATFORM_NAME}" STREQUAL "ARM")
		# On ARM the exception handling flag is missing which causes warnings
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc")
	endif()

	# Set compiler flags for various configurations
	# set(CMAKE_CXX_FLAGS_DEBUG "/GS /Od /Ob0 /RTC1")
	# set(CMAKE_CXX_FLAGS_RELEASE "/GS- /Gy /O2 /Oi /Ot")
	# set(CMAKE_CXX_FLAGS_DISTRIBUTION "/GS- /Gy /O2 /Oi /Ot")

	# Set linker flags
	# if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
	# 	if (CROSS_PLATFORM_DETERMINISTIC)
	# 		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fp:precise")
	# 	else()
	# 		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fp:fast") # Clang doesn't use fast math because it cannot be turned off inside a single compilation unit
	# 	endif()
	# elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
	# 	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /showFilenames")
	# 	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Qunused-arguments") # Clang emits warnings about unused arguments such as /MP and /GL
	# endif()
else()
	# Set general compiler flags
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror")

	# Optionally generate debug symbols
    #if (GENERATE_DEBUG_SYMBOLS)
    #		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
    #endif()

	if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
		# Also disable -Wstringop-overflow or it will generate false positives that can't be disabled from code when link-time optimizations are enabled
		# Also turn off automatic fused multiply add contractions, there doesn't seem to be a way to do this selectively through the macro JPH_PRECISE_MATH_OFF
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-stringop-overflow -ffp-contract=off")
	else()
		# Do not use -ffast-math since it cannot be turned off in a single compilation unit under clang, see Core.h
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffp-model=precise")

		# On clang 14 and later we can turn off float contraction through a pragma, older versions and deterministic versions need it off always, see Core.h
		if (CMAKE_CXX_COMPILER_VERSION LESS 14 OR CROSS_PLATFORM_DETERMINISTIC)
			set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffp-contract=off")
		endif()
	endif()

	# Set compiler flags for various configurations
	set(CMAKE_CXX_FLAGS_DEBUG "")
	set(CMAKE_CXX_FLAGS_RELEASE "-O3")
	set(CMAKE_CXX_FLAGS_DISTRIBUTION "-O3")

	# Set linker flags
	if (NOT ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows"))
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pthread")
	endif()
endif()


# Set linker flags
set(CMAKE_EXE_LINKER_FLAGS_DISTRIBUTION "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")

# Enable link time optimization in Release and Distribution mode if requested and available
SET_INTERPROCEDURAL_OPTIMIZATION()

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
