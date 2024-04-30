message(STATUS "Include Catch2")
cpmaddpackage("gh:catchorg/Catch2#b5373dadca40b7edc8570cf9470b9b1cb1934d40"
)# v3.5.4

list(APPEND CMAKE_MODULE_PATH ${Catch2_SOURCE_DIR}/extras)

add_executable(Catch_tests_run test.cpp)

target_link_libraries(Catch_tests_run
                      PRIVATE jolt_raylib_hello_world_compiler_flags)
target_link_libraries(Catch_tests_run PRIVATE Catch2::Catch2WithMain)
target_include_directories(Catch_tests_run PUBLIC "${PROJECT_SOURCE_DIR}/src")

include(Catch)
catch_discover_tests(Catch_tests_run)
