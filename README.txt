
INSTALL:
$ luarocks --from=http://data.neuflow.org/lua/rocks install sys

USE:
$ lua
> require 'sys'
> for k in pairs(sys) print(k) end  -- gives you all the included functions
dirname
dirp
usleep
ls
prefix
uname
pwd
fstat
COLORS
lla
tic
toc
OS
la
execute
ll
concat
basename
clock
filep
