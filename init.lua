----------------------------------------------------------------------
-- sys - a package that provides simple system (unix) tools
----------------------------------------------------------------------

local os = require 'os'
local io = require 'io'
local paths = require 'paths'

sys = {}

--------------------------------------------------------------------------------
-- load all functions from lib
--------------------------------------------------------------------------------
local _lib = require 'libsys'
for k,v in pairs(_lib) do
   sys[k] = v
end

--------------------------------------------------------------------------------
-- tic/toc (matlab-like) timers
--------------------------------------------------------------------------------
local __t__
function sys.tic()
   __t__ = sys.clock()
end
function sys.toc(verbose)
   local __dt__ = sys.clock() - __t__
   if verbose then print(__dt__) end
   return __dt__
end

--------------------------------------------------------------------------------
-- execute an OS command, but retrieves the result in a string
--------------------------------------------------------------------------------
local function execute(cmd)
   local cmd = cmd .. ' 2>&1'
   local f = io.popen(cmd)
   local s = f:read('*all')
   f:close()
   s = s:gsub('^%s*',''):gsub('%s*$','')
   return s
end
sys.execute = execute

--------------------------------------------------------------------------------
-- execute an OS command, but retrieves the result in a string
-- side effect: file in /tmp
-- this call is typically more robust than the one above (on some systems)
--------------------------------------------------------------------------------
function sys.fexecute(cmd, readwhat)
   local tmpfile = os.tmpname()
   local cmd = cmd .. ' 1>'.. tmpfile..' 2>' .. tmpfile
   os.execute(cmd)
   local file = _G.assert(io.open(tmpfile))
   local s = file:read('*all')
   file:close()
   s = s:gsub('^%s*',''):gsub('%s*$','')
   os.execute('rm ' .. tmpfile)
   return s
end

--------------------------------------------------------------------------------
-- returns the name of the OS in use
-- warning, this method is extremely dumb, and should be replaced by something
-- more reliable
--------------------------------------------------------------------------------
function sys.uname()
   if paths.dirp('C:\\') then
      return 'windows'
   else
      local os = execute('uname -a')
      if os:find('Linux') then
         return 'linux'
      elseif os:find('Darwin') then
         return 'macos'
      else
         return '?'
      end
   end
end
sys.OS = sys.uname()

--------------------------------------------------------------------------------
-- ls (list dir)
--------------------------------------------------------------------------------
sys.ls  = function(d) d = d or ' ' return execute('ls '    ..d) end
sys.ll  = function(d) d = d or ' ' return execute('ls -l ' ..d) end
sys.la  = function(d) d = d or ' ' return execute('ls -a ' ..d) end
sys.lla = function(d) d = d or ' ' return execute('ls -la '..d) end

--------------------------------------------------------------------------------
-- prefix
--------------------------------------------------------------------------------
sys.prefix = execute('which lua'):gsub('//','/'):gsub('/bin/lua\n','')

--------------------------------------------------------------------------------
-- always returns the path of the file running
--------------------------------------------------------------------------------
function sys.fpath()
   local fpath = _G.debug.getinfo(2).source:gsub('@','')
   if fpath:find('/') ~= 1 then fpath = paths.concat(paths.cwd(),fpath) end
   return paths.dirname(fpath),paths.basename(fpath)
end

--------------------------------------------------------------------------------
-- split string based on pattern pat
--------------------------------------------------------------------------------
function sys.split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, last_end)
   while s do
      if s ~= 1 or cap ~= "" then
         _G.table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      _G.table.insert(t, cap)
   end
   return t
end

--------------------------------------------------------------------------------
-- check if a number is NaN
--------------------------------------------------------------------------------
function sys.isNaN(number)
   -- We rely on the property that NaN is the only value that doesn't equal itself.
   return (number ~= number)
end

--------------------------------------------------------------------------------
-- sleep
--------------------------------------------------------------------------------
function sys.sleep(seconds)
   sys.usleep(seconds*1000000)
end

--------------------------------------------------------------------------------
-- colors, can be used to print things in color
--------------------------------------------------------------------------------
sys.COLORS = {none = '\27[0m',
              black = '\27[0;30m',
              red = '\27[0;31m',
              green = '\27[0;32m',
              yellow = '\27[0;33m',
              blue = '\27[0;34m',
              magenta = '\27[0;35m',
              cyan = '\27[0;36m',
              white = '\27[0;37m',
              Black = '\27[1;30m',
              Red = '\27[1;31m',
              Green = '\27[1;32m',
              Yellow = '\27[1;33m',
              Blue = '\27[1;34m',
              Magenta = '\27[1;35m',
              Cyan = '\27[1;36m',
              White = '\27[1;37m',
              _black = '\27[40m',
              _red = '\27[41m',
              _green = '\27[42m',
              _yellow = '\27[43m',
              _blue = '\27[44m',
              _magenta = '\27[45m',
              _cyan = '\27[46m',
              _white = '\27[47m'}

--------------------------------------------------------------------------------
-- backward compat
--------------------------------------------------------------------------------
sys.dirname = paths.dirname
sys.concat = paths.concat

return sys