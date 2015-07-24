#include <lua.h>
#include <lauxlib.h>

#ifdef _WIN32

#define WINDOWS_LEAN_AND_MEAN
#include <windows.h>
#include <stdint.h>

static int l_clock(lua_State *L) {
    static const uint64_t EPOCH = 116444736000000000ULL;
    SYSTEMTIME  systemtime;
    FILETIME filetime;
    uint64_t time;
    GetSystemTime(&systemtime);
    GetSystemTimeAsFileTime(&filetime);
    time = (((uint64_t)filetime.dwHighDateTime) << 32) + ((uint64_t)filetime.dwLowDateTime);
    double precise_time = (time - EPOCH) / 10000000.0;
    lua_pushnumber(L, precise_time);
    return 1;
}

static int l_usleep(lua_State *L) {
  int time = 1;
  if (lua_isnumber(L, 1)) time = lua_tonumber(L, 1);
  Sleep(time / 1000);
  return 1;
}

#else

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <sys/time.h>
#include <unistd.h>
#include <time.h>

static int l_clock(lua_State *L) {
  struct timeval tv;
  struct timezone tz;
  struct tm *tm;
  gettimeofday(&tv, &tz);
  tm=localtime(&tv.tv_sec);
  double precise_time = tv.tv_sec + tv.tv_usec / 1e6;
  lua_pushnumber(L,precise_time);
  return 1;
}

static int l_usleep(lua_State *L) {
  int time = 1;
  if (lua_isnumber(L, 1)) time = lua_tonumber(L, 1);
  usleep(time);
  return 1;
}

#endif

static const struct luaL_Reg routines [] = {
  {"clock", l_clock},
  {"usleep", l_usleep},
  {NULL, NULL}
};

#if defined(_WIN32)
    #define SYS_DLLEXPORT __declspec(dllexport) __cdecl
#else
    #define SYS_DLLEXPORT 
#endif
int SYS_DLLEXPORT luaopen_libsys(lua_State *L)
{
  lua_newtable(L);
#if LUA_VERSION_NUM == 501
  luaL_register(L, NULL, routines);
#else
  luaL_setfuncs(L, routines, 0);
#endif
  return 1;
}
