cmake_minimum_required(VERSION 3.10)

# set the project name
project(app)

set(CMAKE_CXX_STANDARD 17)

# add the executable
add_executable(app main.cpp glad.c stb.cpp)

# Set where the ImGui files are stored
set(IMGUI_PATH  ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
    
# Compile as static library 
file(GLOB IMGUI_SOURCES ${IMGUI_PATH}/*.cpp) 

find_package(OpenGL REQUIRED)
target_link_libraries(app PRIVATE ${OPENGL_gl_LIBRARY})

find_package(glfw3 REQUIRED)
target_link_libraries(app PRIVATE glfw)

find_package(Lua51 REQUIRED)
target_link_libraries(app PRIVATE ${LUA_LIBRARIES})

add_library(imgui STATIC ${IMGUI_SOURCES})


target_include_directories(app PUBLIC
                           "${PROJECT_BINARY_DIR}"
                           "${PROJECT_BINARY_DIR}/include"
                           "${PROJECT_SOURCE_DIR}/imgui"
                           "${LUA_INCLUDE_DIR}"
                           )

target_link_libraries(app PUBLIC imgui)
target_link_libraries(app PUBLIC lua5.1)


