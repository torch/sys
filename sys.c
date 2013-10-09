
#include <lua.h>
#include <lauxlib.h>

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
  double precise_time = tm->tm_hour*3600 + tm->tm_min*60 + tm->tm_sec + tv.tv_usec / 1000000.0;
  lua_pushnumber(L,precise_time);
  return 1;
}

static int l_usleep(lua_State *L) {
  int time = 1;
  if (lua_isnumber(L, 1)) time = lua_tonumber(L, 1);
  usleep(time);
  return 1;
}

static const struct luaL_reg routines [] = {
  {"clock", l_clock},
  {"usleep", l_usleep},
  {NULL, NULL}
};

int luaopen_libsys(lua_State *L)
{
  luaL_openlib(L, "libsys", routines, 0);
  return 1;
}
