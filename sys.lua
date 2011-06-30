----------------------------------------------------------------------
--
-- Copyright (c) 2010 Clement Farabet
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
--     the C lib was largely taken from Torch5
--
-- history: 
--     March 27, 2011, 9:58PM - creation
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
toc = function() 
         __dt__ = clock() - __t__
         tic()
         print(__dt__)
         return __dt__ 
      end

--------------------------------------------------------------------------------
-- execute an OS command, but retrieves the result in a string
-- side effect: creates a file in /tmp/
--------------------------------------------------------------------------------
execute = function(cmd)
             local tmpfile = '/tmp/lua.os.execute.out'
             local cmd = cmd .. ' 1>'.. tmpfile..' 2>' .. tmpfile
             os.execute(cmd)
             local file = io.open(tmpfile)
             local str = file:read('*all')
             file:close()
             str:gsub('\n$','')
             os.execute('rm ' .. tmpfile)
             return str
          end

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
ls = function() return execute 'ls' end
ll = function() return execute 'ls -l' end
la = function() return execute 'ls -a' end
lla = function() return execute 'ls -la' end

--------------------------------------------------------------------------------
-- prefix
--------------------------------------------------------------------------------
prefix = execute('which lua'):gsub('/bin/lua\n','')

--------------------------------------------------------------------------------
-- sleep
--------------------------------------------------------------------------------
function sleep(seconds)
   usleep(seconds*1000000)
end

--------------------------------------------------------------------------------
-- colors, can be used to print things in color
--------------------------------------------------------------------------------
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
