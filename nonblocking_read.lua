local ffi = require "ffi"
local reproc = require "reproc"()

local process = ffi.new("reproc_t *", nil)
local r = ffi.new("int", reproc.REPROC_ENOMEM)
local cmd = {}
local args = nil
local buffer = ffi.new("uint8_t[128]");
local opts = ffi.new("reproc_options")

process = reproc.reproc_new();
if (process == nil) then
  os.exit(30)
end

local script = [[
for (( i = 0; i < 10; i++ )); do
    a=$(( ( RANDOM % 8 )  + 1 ))
    echo "script -> slept 0.$a"
    sleep 0.$a
done
]]
local f = assert(io.open("demo_script.sh", "w"))
f:write(script)
f:close()

cmd = { "bash", "./demo_script.sh" }
cmd[#cmd+1] = nil
args = ffi.new("const char*[" .. #cmd+1 .. "]", cmd)
opts.nonblocking = true
r = reproc.reproc_start(process, args, opts);

r = reproc.reproc_close(process, reproc.REPROC_STREAM_IN);

r = 0
repeat
  r = reproc.reproc_read(process, reproc.REPROC_STREAM_OUT, buffer, ffi.sizeof(buffer));
  if r == reproc.REPROC_EWOULDBLOCK then
    -- print(ffi.string(reproc.reproc_strerror(r)));
    r = 0
  else
    print("stdout:", ffi.string(buffer));
  end
until r < 0

reproc.reproc_destroy(process);