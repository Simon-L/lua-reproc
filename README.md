# lua-reproc

Basic FFI wrapper for [reproc](https://github.com/DaanDeMeyer/reproc)

`luarocks install https://github.com/Simon-L/lua-reproc/raw/main/lua-reproc-dev-1.rockspec`

## Usage

Requiring this module returns a function that needs to be called:  
`local reproc = require "reproc"()`  
With no argument, the module tries to load the reproc shared library from the rock's directory. This feature needs `datafile`: `luarocks install datafile`.

You may prefer to point it to libreproc.so at any other location: `local reproc = require "reproc"("path/to/libreproc.so")`, which effectively makes luarocks optional for this module: just grab `src/reproc.lua`, build reproc and let's go.

## Example

`reproc_read.lua` contains an example very closely reproducing the example of the same name in reproc repo.

A basic usage of `reproc_run` is shown below:
```lua
local ffi = require "ffi"
local reproc = require "reproc"()

-- Table wit program and args, adding nil is necessary
local cmd = { "echo", "\"Hello World\"" }
cmd[#cmd+1] = nil

-- #cmd doesn't include nil elements, hence +1
local args = ffi.new("const char*[" .. #cmd+1 .. "]", cmd)
local ret = reproc.reproc_run(args, ffi.new("reproc_options"));

-- check return value
print(ffi.string(reproc.reproc_strerror(ret)))
```