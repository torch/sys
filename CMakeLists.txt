cmake_minimum_required(VERSION 2.8)

string (REGEX REPLACE "(.*)lib/luarocks/rocks.*" "\\1" LUA_PREFIX "${CMAKE_INSTALL_PREFIX}" )

set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
include_directories (${PROJECT_SOURCE_DIR} ${LUA_PREFIX}/include)
link_directories (${LUA_PREFIX}/lib)
add_library (sys SHARED sys.c)
target_link_libraries (sys lua)

install_files(/lua sys.lua)
install_targets(/lib sys)

