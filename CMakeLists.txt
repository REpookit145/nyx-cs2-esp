cmake_minimum_required(VERSION 3.20)
project(cs2_esp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(IMGUI_DIR "${CMAKE_SOURCE_DIR}/third_party/imgui")

if(NOT EXISTS "${IMGUI_DIR}/imgui.cpp")
    message(FATAL_ERROR "imgui not found. Run build.bat (it clones it) or place imgui in third_party/imgui.")
endif()

add_library(cs2_esp SHARED
    src/dllmain.cpp
    src/hooks.cpp
    src/esp.cpp
    src/menu.cpp
    src/offsets.cpp

    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/backends/imgui_impl_dx11.cpp
    ${IMGUI_DIR}/backends/imgui_impl_win32.cpp
)

target_include_directories(cs2_esp PRIVATE
    src
    ${IMGUI_DIR}
    ${IMGUI_DIR}/backends
)

target_link_libraries(cs2_esp PRIVATE d3d11 dxgi dwmapi imm32 winmm)
target_compile_definitions(cs2_esp PRIVATE UNICODE _UNICODE)

if(MSVC)
    target_compile_options(cs2_esp PRIVATE /utf-8 /W3)
    set_target_properties(cs2_esp PROPERTIES OUTPUT_NAME "cs2_esp")
endif()

# minimal injector (console exe)
add_executable(injector tools/injector.cpp)
if(MSVC)
    target_compile_options(injector PRIVATE /utf-8 /W3)
    set_target_properties(injector PROPERTIES OUTPUT_NAME "injector")
endif()
