
#include <lua.h>
#include <lauxlib.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <sys/time.h>
# include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>
#define NAMLEN(dirent) strlen((dirent)->d_name)

#define SBINCREMENT 256

typedef struct {
  char *buffer;
  int maxlen;
  int len;
} SB;

static void 
sbinit(SB *sb)
{
  sb->buffer = (char*)malloc(SBINCREMENT);
  sb->maxlen = SBINCREMENT;
  sb->len = 0;
}

static char *
sbfree(SB *sb)
{
  if (sb->buffer)
    free(sb->buffer);
  sb->buffer = 0;
  return 0;
}

static void
sbgrow(SB *sb, int n)
{
  if (sb->buffer && sb->len + n > sb->maxlen)
    {
      int nlen = sb->maxlen;
      while (sb->len + n > nlen)
        nlen += SBINCREMENT;
      sb->buffer = (char*)realloc(sb->buffer, nlen);
      sb->maxlen = nlen;
    }
}

static void
sbadd1(SB *sb, char c)
{
  sbgrow(sb, 1);
  if (sb->buffer)
    sb->buffer[sb->len++] = c;
}

static void
sbaddn(SB *sb, const char *s, int n)
{
  sbgrow(sb, n);
  if (sb->buffer && s && n)
    memcpy(sb->buffer + sb->len, s, n);
  else if (sb->buffer && n)
    sbfree(sb);
  sb->len += n;
}

static void
sbaddsf(SB *sb, char *s)
{
  if (s)
    sbaddn(sb, s, strlen(s));
  else
    sbfree(sb);
  if (s)
    free((void*)s);
}

static void
sbslash(SB *sb)
{
  int i;
  if (sb->buffer && sb->len)
    for(i=0; i<sb->len; i++)
      if (sb->buffer[i]=='\\')
        sb->buffer[i]='/';
}

static int
sbpush(lua_State *L, SB *sb)
{
  sbslash(sb);
  lua_pushlstring(L, sb->buffer, sb->len);
  sbfree(sb);
  return 1;
}

static int
sbsetpush(lua_State *L,  SB *sb, const char *s)
{
  sbfree(sb);
  lua_pushstring(L, s);
  return 1;
}

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

int l_fstat(lua_State *L) {
  const char * fname = luaL_checkstring(L, 1);
  int file=0;
  if((file=open(fname,O_RDONLY)) < -1)
    return 0;
  struct stat fileStat;
  if(fstat(file,&fileStat) < 0)    
    return 0;
  lua_pushnumber(L, (double) fileStat.st_mtime);
  lua_pushnumber(L, (double) fileStat.st_atime);
  lua_pushnumber(L, (double) fileStat.st_ctime);
  return 3;
}

static int l_dirp(lua_State *L) {
  const char *s = luaL_checkstring(L, 1);
  struct stat buf;
  if ((stat(s,&buf)==0) && (buf.st_mode & S_IFDIR))
    lua_pushboolean(L, 1);
  else
    lua_pushboolean(L, 0);
  return 1;
}

static int l_filep(lua_State *L) {
  const char *s = luaL_checkstring(L, 1);
  struct stat buf;
  if ((stat(s,&buf) < 0) || (buf.st_mode & S_IFDIR))
    lua_pushboolean(L, 0);
  else
    lua_pushboolean(L, 1);
  return 1;
}

static int  l_dirname(lua_State *L) {
  const char *fname = luaL_checkstring(L, 1);
  const char *s = fname;
  const char *p = 0;
  SB sb; 
  sbinit(&sb);
  while (*s) {
    if (s[0]=='/' && s[1] && s[1]!='/')
      p = s;
    s++;
  }
  if (!p) {
    if (fname[0]=='/')
      return sbsetpush(L, &sb, fname);
    else
      return sbsetpush(L, &sb, ".");
  }
  s = fname;
  do {
    sbadd1(&sb, *s++);
  } while (s<p);
  return sbpush(L, &sb);
}

static int l_basename(lua_State *L) {
  const char *fname = luaL_checkstring(L, 1);
  const char *suffix = luaL_optstring(L, 2, 0);
  int sl;
  const char *s, *p;
  SB sb;
  sbinit(&sb);
  /* Position p after last nontrivial slash */
  s = p = fname;
  while (*s) {
    if (s[0]=='/' && s[1] && s[1]!='/')
      p = s + 1;
    s++;
  }
  /* Copy into buffer */
  while (*p && *p!='/')
    sbadd1(&sb, *p++);
  /* Process suffix */
  if (suffix==0 || suffix[0]==0)
    return sbpush(L, &sb);
  if (suffix[0]=='.')
    suffix += 1;
  if (suffix[0]==0)
    return sbpush(L, &sb);
  sl = strlen(suffix);
  if (sb.len > sl) {
    s =  sb.buffer + sb.len - (sl + 1);
    if (s[0]=='.' && strncmp(s+1,suffix, sl)==0)
      sb.len = s - sb.buffer;
  }
  return sbpush(L, &sb);
}

static int l_pwd(lua_State *L) {
  const char *s;
  SB sb;
  sbinit(&sb);
  sbgrow(&sb, PATH_MAX); 
  s = getwd(sb.buffer);
  if (! s)
    return sbsetpush(L, &sb, ".");
  sb.len += strlen(s);
  return sbpush(L, &sb);
}

static int l_dir(lua_State *L) {
  int k = 0;
  const char *s = luaL_checkstring(L, 1);
  DIR *dirp;
  struct dirent *d;
  dirp = opendir(s);
  if (dirp) {
    lua_createtable(L, 0, 0);
    while ((d = readdir(dirp))) {
      int n = NAMLEN(d);
      lua_pushlstring(L, d->d_name, n);
      lua_rawseti(L, -2, ++k);
    }
    closedir(dirp);
  } else
    lua_pushnil(L);
  return 1;
}

static int concat_fname(lua_State *L, const char *fname) {
  const char *from = lua_tostring(L, -1);
  const char *s;
  SB sb;
  sbinit(&sb);

  if (fname && fname[0]=='/') 
    sbadd1(&sb, '/');
  else
    sbaddn(&sb, from, strlen(from));
  for (;;) {
    while (fname && fname[0]=='/')
      fname++;
    if (!fname || !fname[0]) {
      sbadd1(&sb, '/');
      while (sb.len > 1 && sb.buffer[sb.len-1]=='/')
        sb.len --;
      return sbpush(L, &sb);
    }
    if (fname[0]=='.') {
      if (fname[1]=='/' || fname[1]==0) {
	fname +=1;
	continue;
      }
      if (fname[1]=='.')
	if (fname[2]=='/' || fname[2]==0) {
	  fname +=2;
          while (sb.len > 0 && sb.buffer[sb.len-1]=='/')
            sb.len --;
          while (sb.len > 0 && sb.buffer[sb.len-1]!='/')
            sb.len --;
	  continue;
	}
    }
    if (sb.len == 0 || sb.buffer[sb.len-1] != '/')
      sbadd1(&sb, '/');
    while (*fname!=0 && *fname!='/')
      sbadd1(&sb, *fname++);
  }
}

static int l_concat(lua_State *L) {
  int i;
  int narg = lua_gettop(L);
  l_pwd(L);
  for (i=1; i<=narg; i++)
    {
      concat_fname(L, luaL_checkstring(L, i));
      lua_remove(L, -2);
    }
  return 1;
}

static const struct luaL_reg routines [] = {
  {"clock", l_clock},
  {"usleep", l_usleep},
  {"fstat", l_fstat},
  {"filep", l_filep},
  {"dirp", l_dirp},
  {"dirname", l_dirname},
  {"basename", l_basename},
  {"concat", l_concat},
  {"dir", l_dir},
  {"pwd", l_pwd},
  {NULL, NULL}
};

int luaopen_libsys(lua_State *L)
{
  luaL_openlib(L, "libsys", routines, 0);
  return 1;
}
