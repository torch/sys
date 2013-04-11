----------------------------------------------------------------------
--
-- Copyright (c) 2011 Clement Farabet
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
----------------------------------------------------------------------
-- description:
--     sys - a package that provides simple system (unix) tools
--
-- ack:
--     the C lib was largely taken from Torch5 (code from Ronan)
--
-- history:
--     March 27, 2011, 9:58PM - creation - Clement Farabet
----------------------------------------------------------------------

require 'os'
require 'io'

local _G = _G
local print = print
local error = error
local require = require
local os = os
local io = io
local pairs = pairs
local ipairs = ipairs

module 'sys'
_lib = require 'libsys'
_G.libsys = nil

--------------------------------------------------------------------------------
-- load all functions from lib
--------------------------------------------------------------------------------
for k,v in pairs(_lib) do
   _G.sys[k] = v
end

--------------------------------------------------------------------------------
-- tic/toc (matlab-like) timers
--------------------------------------------------------------------------------
tic = function()
         __t__ = clock()
      end
toc = function(verbose)
         __dt__ = clock() - __t__
         if verbose then print(__dt__) end
         return __dt__
      end

--------------------------------------------------------------------------------
-- execute an OS command, but retrieves the result in a string
-- side effect: file in /tmp
--------------------------------------------------------------------------------
execute = function(cmd, readwhat)
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

-- TODO: use the following code, which would avoid the side effect.
-- For now it doesnt work though, and I can't explain why.
-- execute = function(cmd)
--              local f = io.popen(cmd, 'r')
--              local s = f:read('*all')
--              f:close()
--              s = s:gsub('^%s*',''):gsub('%s*$','')
--              return s
--           end

--------------------------------------------------------------------------------
-- returns the name of the OS in use
-- warning, this method is extremely dumb, and should be replaced by something
-- more reliable
--------------------------------------------------------------------------------
uname = function()
           if dirp('C:\\') then
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
OS = uname()

--------------------------------------------------------------------------------
-- ls (list dir)
--------------------------------------------------------------------------------
ls  = function(d) d = d or ' ' return execute('ls '    ..d) end
ll  = function(d) d = d or ' ' return execute('ls -l ' ..d) end
la  = function(d) d = d or ' ' return execute('ls -a ' ..d) end
lla = function(d) d = d or ' ' return execute('ls -la '..d) end

--------------------------------------------------------------------------------
-- prefix
--------------------------------------------------------------------------------
prefix = execute('which lua'):gsub('//','/'):gsub('/bin/lua\n','')

--------------------------------------------------------------------------------
-- always returns the path of the file running
--------------------------------------------------------------------------------
function fpath()
   local fpath = _G.debug.getinfo(2).source:gsub('@','')
   if fpath:find('/') ~= 1 then fpath = concat(pwd(),fpath) end
   return dirname(fpath),basename(fpath)
end

--------------------------------------------------------------------------------
-- split string based on pattern pat
--------------------------------------------------------------------------------
function split(str, pat)
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
function isNaN(number)
   -- We rely on the property that NaN is the only value that doesn't equal itself.
   return (number ~= number)
end

--------------------------------------------------------------------------------
-- sleep
--------------------------------------------------------------------------------
function sleep(seconds)
   usleep(seconds*1000000)
end

--------------------------------------------------------------------------------
-- file iterator, in given path
--------------------------------------------------------------------------------
function files(path)
   local d = dir(path)
   local n = 0
   return function()
             n = n + 1
             if (d and n <= #d) then
                return d[n]
             else
                return nil
             end
          end
end

--------------------------------------------------------------------------------
-- colors, can be used to print things in color
--------------------------------------------------------------------------------
if _G.qt and _G.qt.qConsole.captureOutput then
   COLORS = {none = '',
             black = '',
             red = '',
             green = '',
             yellow = '',
             blue = '',
             magenta = '',
             cyan = '',
             white = '',
             Black = '',
             Red = '',
             Green = '',
             Yellow = '',
             Blue = '',
             Magenta = '',
             Cyan = '',
             White = '',
             _black = '',
             _red = '',
             _green = '',
             _yellow = '',
             _blue = '',
             _magenta = '',
             _cyan = '',
             _white = ''}
else
   COLORS = {none = '\27[0m',
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
end
