cmake_minimum_required(VERSION 2.8)


IF(${CMAKE_PROJECT_NAME} STREQUAL "Torch")
  SET(TORCH_LIBRARIES TH luaT)
  SET(TORCH_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

  SET(INSTALL_PREFIX /${Torch_INSTALL_LUA_PATH_SUBDIR})
  SET(CINSTALL_PREFIX /${Torch_INSTALL_LUA_CPATH_SUBDIR})

  SET(LIBS ${TORCH_LIBRARIES})
ELSE(${CMAKE_PROJECT_NAME} STREQUAL "Torch")
  string (REGEX REPLACE "(.*)lib/luarocks/rocks.*" "\\1" LUA_PREFIX "${CMAKE_INSTALL_PREFIX}" )
  SET(INSTALL_PREFIX /lua)
  SET(CINSTALL_PREFIX /lib)
  SET(LIBS lua)
ENDIF(${CMAKE_PROJECT_NAME} STREQUAL "Torch")

set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
include_directories (${PROJECT_SOURCE_DIR} ${LUA_PREFIX}/include)
link_directories (${LUA_PREFIX}/lib)
add_library (sys SHARED sys.c)
target_link_libraries(sys ${LIBS})

install_files(${INSTALL_PREFIX} sys.lua)
install_targets(${CINSTALL_PREFIX} sys)

