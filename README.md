# Lua *system* package

## Dependencies
Torch7 (www.torch.ch)

## Install
```
$ luarocks install sys
```

## Use
```
$ torch
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
```

### sys.COLORS
If you'd like print in colours, follow the following snippets of code. Let start by listing the available colours
```
$ torch
> for k in pairs(sys.COLORS) do print(k) end
```
Then, we can generate a shortcut `c = sys.COLORS` and use it within a `print`
```
> c = sys.COLORS
> print(c.magenta .. 'This ' .. c.red .. 'is ' .. c.yellow .. 'a ' .. c.green .. 'rainbow' .. c.cyan .. '!')
```
