
package = "sys"
version = "1.0-1"

source = {
   url = "sys-1.0-1.tgz"
}

description = {
   summary = "Provides a set of standard unixy tools",
   detailed = [[
         This package provides a set of standard unix
         tools, from file operators, to system clocks
         and so on.
   ]],
   homepage = "",
   license = "MIT/X11" -- or whatever you like
}

dependencies = {
   "lua >= 5.1"
   -- If you depend on other rocks, add them here
}

build = {
   type = "cmake",

   cmake = [[
         cmake_minimum_required(VERSION 2.8)

         string (REGEX REPLACE "(.*)lib/luarocks/rocks.*" "\\1" LUA_PREFIX "${CMAKE_INSTALL_PREFIX}" )

         set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
         include_directories (${PROJECT_SOURCE_DIR} ${LUA_PREFIX}/include)
         link_directories (${LUA_PREFIX}/lib)
         add_library (sys SHARED sys.c)
         target_link_libraries (sys lua)

         install_files(/lua sys.lua)
         install_targets(/lib sys)
   ]],

   variables = {
      CMAKE_INSTALL_PREFIX = "$(PREFIX)"
   }
}
