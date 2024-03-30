include(cmake/CPM.cmake)

## Jolt Config

# When turning this option on, the library will be compiled using doubles for
# positions. This allows for much bigger worlds.
set(DOUBLE_PRECISION OFF)

# When turning this option on, the library will be compiled with debug symbols
set(GENERATE_DEBUG_SYMBOLS ON)

# When turning this option on, the library will be compiled in such a way to
# attempt to keep the simulation deterministic across platforms
set(CROSS_PLATFORM_DETERMINISTIC OFF)

# When turning this option on, the library will be compiled with interprocedural
# optimizations enabled, also known as link-time optimizations or link-time code
# generation. Note that if you turn this on you need to use
# SET_INTERPROCEDURAL_OPTIMIZATION() or set(CMAKE_INTERPROCEDURAL_OPTIMIZATION
# ON) to enable LTO specificly for your own project as well. If you don't do
# this you may get an error: /usr/bin/ld: libJolt.a: error adding symbols: file
# format not recognized set(INTERPROCEDURAL_OPTIMIZATION ON)
set(INTERPROCEDURAL_OPTIMIZATION ON)

# When turning this on, in Debug and Release mode, the library will emit extra
# code to ensure that the 4th component of a 3-vector is kept the same as the
# 3rd component and will enable floating point exceptions during simulation to
# detect divisions by zero. Note that this currently only works using MSVC.
# Clang turns Float2 into a SIMD vector sometimes causing floating point
# exceptions (the option is ignored).
set(FLOATING_POINT_EXCEPTIONS_ENABLED OFF)

# Number of bits to use in ObjectLayer. Can be 16 or 32.
set(OBJECT_LAYER_BITS 16)

# Select X86 processor features to use, by default the library compiles with
# AVX2, if everything is off it will be SSE2 compatible.
set(USE_SSE4_1 ON)
set(USE_SSE4_2 ON)
set(USE_AVX ON)
set(USE_AVX2 ON)
set(USE_AVX512 OFF)
set(USE_LZCNT ON)
set(USE_TZCNT ON)
set(USE_F16C ON)
set(USE_FMADD ON)

# Requires C++ 17
#set(CMAKE_CXX_STANDARD 17)
#set(CMAKE_CXX_STANDARD_REQUIRED ON)
#set(CMAKE_CXX_EXTENSIONS OFF)

function(jolt_raylib_hello_world_setup_dependencies)
  message(STATUS "Include Dear ImGui")
  FetchContent_Declare(
    ImGui
    GIT_REPOSITORY https://github.com/ocornut/imgui
    GIT_TAG 277ae93c41314ba5f4c7444f37c4319cdf07e8cf) # v1.90.4
  FetchContent_MakeAvailable(ImGui)
  FetchContent_GetProperties(ImGui SOURCE_DIR IMGUI_DIR)

  add_library(
    imgui STATIC
    ${imgui_SOURCE_DIR}/imgui.cpp ${imgui_SOURCE_DIR}/imgui_draw.cpp
    ${imgui_SOURCE_DIR}/imgui_widgets.cpp ${imgui_SOURCE_DIR}/imgui_tables.cpp)
  target_include_directories(imgui INTERFACE ${imgui_SOURCE_DIR})

  message(STATUS "Include Jolt")
  FetchContent_Declare(
    JoltPhysics
    GIT_REPOSITORY "https://github.com/jrouwe/JoltPhysics"
    GIT_TAG "v4.0.2"
    SOURCE_SUBDIR "Build")
  FetchContent_MakeAvailable(JoltPhysics)

  include(cmake/CPM.cmake)

  message(STATUS "Include dbg-macro")
  cpmaddpackage("gh:sharkdp/dbg-macro#fb9976f410f8b29105818b20278cd0be0e853fe8"
  )# v0.5.1

  message(STATUS "Include fmtlib")
  cpmaddpackage("gh:fmtlib/fmt#e69e5f977d458f2650bb346dadf2ad30c5320281") # 10.x

  message(STATUS "Include raylib")
  cpmaddpackage("gh:raysan5/raylib#ae50bfa2cc569c0f8d5bc4315d39db64005b1b0"
  )# v5.0

  message(STATUS "Include spdlog")
  cpmaddpackage("gh:gabime/spdlog#7c02e204c92545f869e2f04edaab1f19fe8b19fd"
  )# v1.13.0

  message(STATUS "Include rlImGui")
  FetchContent_Declare(
    rlImGui
    GIT_REPOSITORY https://github.com/raylib-extras/rlImGui
    GIT_TAG d765c1ef3d37cf939f88aaa272a59a2713d654c9)
  FetchContent_MakeAvailable(rlImGui)
  FetchContent_GetProperties(rlImGui SOURCE_DIR RLIMGUI_DIR)
  add_library(rlimgui STATIC ${rlimgui_SOURCE_DIR}/rlImGui.cpp)
  #add_library(rlimgui INTERFACE)
  #target_sources(rlimgui PRIVATE ${rlimgui_SOURCE_DIR}/rlImGui.cpp)
  target_link_libraries(rlimgui PUBLIC imgui raylib)
  #target_link_libraries(rlimgui INTERFACE imgui raylib)
#  if(APPLE)
#    target_link_libraries(rlimgui PUBLIC "-framework IOKit")
#    target_link_libraries(rlimgui PUBLIC "-framework Cocoa")
#    target_link_libraries(rlimgui PUBLIC "-framework OpenGL")
#  endif()
  target_include_directories(rlimgui INTERFACE ${rlimgui_SOURCE_DIR})
endfunction()
