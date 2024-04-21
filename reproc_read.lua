local ffi = require "ffi"
local reproc = require "reproc"()

local process = ffi.new("reproc_t *", nil)
local output = ffi.new("char *", nil)
local size = ffi.new("size_t", 0)
local r = ffi.new("int", reproc.REPROC_ENOMEM)
local cmd = {}
local args = nil

process = reproc.reproc_new();
if (process == nil) then
  goto finish;
end

-- `reproc_start` takes a child process instance (`reproc_t`), argv and
-- a set of options including the working directory and environment of the
-- child process. If the working directory is `NULL` the working directory of
-- the parent process is used. If the environment is `NULL`, the environment
-- of the parent process is used.
-- const char *args[] = { "echo", "Hello, world!", NULL };
cmd = { "echo", "Hello, world!" }
cmd[#cmd+1] = nil
args = ffi.new("const char*[" .. #cmd+1 .. "]", cmd)
r = reproc.reproc_start(process, args, ffi.new("reproc_options"));

-- On failure, reproc's API functions return a negative `errno` (POSIX) or
-- `GetLastError` (Windows) style error code. To check against common error
-- codes, reproc provides cross platform constants such as `REPROC_EPIPE` and
-- `REPROC_ETIMEDOUT`.
if (r < 0) then
  goto finish;
end

-- Close the stdin stream since we're not going to write any input to the
-- child process.
r = reproc.reproc_close(process, reproc.REPROC_STREAM_IN);
if (r < 0) then
  goto finish;
end

-- Read the entire output of the child process. I've found this pattern to be
-- the most readable when reading the entire output of a child process. The
-- while loop keeps running until an error occurs in `reproc_read` (the child
-- process closing its output stream is also reported as an error).
while true do
  local buffer = ffi.new("uint8_t[4096]");
  r = reproc.reproc_read(process, reproc.REPROC_STREAM_OUT, buffer, ffi.sizeof(buffer));
  if (r < 0) then
    break;
  end
  
  -- On success, `reproc_read` returns the amount of bytes read.
  local bytes_read = ffi.new("size_t", ffi.cast("size_t", r));
  
  -- Increase the size of `output` to make sure it can hold the new output.
  -- This is definitely not the most performant way to grow a buffer so keep
  -- that in mind. Add 1 to size to leave space for the NUL terminator which
  -- isn't included in `output_size`.
  local result = ffi.new("char*", ffi.C.realloc(output, size + bytes_read + 1))
  if (result == NULL) then
    r = reproc.REPROC_ENOMEM;
    goto finish;
  end
  
  output = result;
  
  -- Copy new data into `output`.
  ffi.C.memcpy(output + size, buffer, bytes_read);
  output[size + bytes_read] = 0;
  size = size + bytes_read;
end

-- Check that the while loop stopped because the output stream of the child
-- process was closed and not because of any other error.
if (r ~= reproc.REPROC_EPIPE) then
 goto finish;
end
-- 
print(ffi.string(output));

-- Wait for the process to exit. This should always be done since some systems
-- (POSIX) don't clean up system resources allocated to a child process until
-- the parent process explicitly waits for it after it has exited.
r = reproc.reproc_wait(process, reproc.REPROC_INFINITE);
if (r < 0) then
 goto finish;
end

::finish::
ffi.C.free(output);

-- Clean up all the resources allocated to the child process (including the
-- memory allocated by `reproc_new`). Unless custom stop actions are passed to
-- `reproc_start`, `reproc_destroy` will first wait indefinitely for the child
-- process to exit.
reproc.reproc_destroy(process);
-- 
if (r < 0) then
 print(ffi.string(reproc.reproc_strerror(r)));
end
