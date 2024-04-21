local ffi = require("ffi")
ffi.cdef[[
  typedef struct FILE FILE;
  typedef struct reproc_t reproc_t;
  extern const int REPROC_EINVAL;
  extern const int REPROC_ETIMEDOUT;
  extern const int REPROC_EPIPE;
  extern const int REPROC_ENOMEM;
  extern const int REPROC_EWOULDBLOCK;
  extern const int REPROC_SIGKILL;
  extern const int REPROC_SIGTERM;
  extern const int REPROC_INFINITE;
  extern const int REPROC_DEADLINE;
  typedef enum {
    REPROC_STREAM_IN,
    REPROC_STREAM_OUT,
    REPROC_STREAM_ERR,
  } REPROC_STREAM;
  typedef enum {
    REPROC_REDIRECT_DEFAULT,
    REPROC_REDIRECT_PIPE,
    REPROC_REDIRECT_PARENT,
    REPROC_REDIRECT_DISCARD,
    REPROC_REDIRECT_STDOUT,
    REPROC_REDIRECT_HANDLE,
    REPROC_REDIRECT_FILE,
    REPROC_REDIRECT_PATH,
  } REPROC_REDIRECT;
  typedef enum {
    REPROC_STOP_NOOP,
    REPROC_STOP_WAIT,
    REPROC_STOP_TERMINATE,
    REPROC_STOP_KILL,
  } REPROC_STOP;
  typedef struct reproc_stop_action {
    REPROC_STOP action;
    int timeout;
  } reproc_stop_action;
  typedef struct reproc_stop_actions {
    reproc_stop_action first;
    reproc_stop_action second;
    reproc_stop_action third;
  } reproc_stop_actions;
  typedef int reproc_handle;
  typedef struct reproc_redirect {
    REPROC_REDIRECT type;
    reproc_handle handle;
    FILE *file;
    const char *path;
  } reproc_redirect;
  typedef enum {
    REPROC_ENV_EXTEND,
    REPROC_ENV_EMPTY,
  } REPROC_ENV;
  typedef struct reproc_options {
    const char *working_directory;
    struct {
      REPROC_ENV behavior;
      const char *const *extra;
    } env;
    struct {
      reproc_redirect in;
      reproc_redirect out;
      reproc_redirect err;
      bool parent;
      bool discard;
      FILE *file;
      const char *path;
    } redirect;
    reproc_stop_actions stop;
    int deadline;
    struct {
      const uint8_t *data;
      size_t size;
    } input;
    bool fork;
    bool nonblocking;
  } reproc_options;
  enum {
    REPROC_EVENT_IN = 1 << 0,
    REPROC_EVENT_OUT = 1 << 1,
    REPROC_EVENT_ERR = 1 << 2,
    REPROC_EVENT_EXIT = 1 << 3,
    REPROC_EVENT_DEADLINE = 1 << 4,
  };
  typedef struct reproc_event_source {
    reproc_t *process;
    int interests;
    int events;
  } reproc_event_source;
  typedef struct reproc_sink {
    int (*function)(REPROC_STREAM stream,
                    const uint8_t *buffer,
                    size_t size,
                    void *context);
    void *context;
  } reproc_sink;
  extern const reproc_sink REPROC_SINK_NULL;
  int reproc_drain(reproc_t *process, reproc_sink out, reproc_sink err);
  reproc_sink reproc_sink_string(char **output);
  reproc_sink reproc_sink_discard(void);
  void *reproc_free(void *ptr);
  reproc_t *reproc_new(void);
  int reproc_start(reproc_t *process,
                                 const char *const *argv,
                                 reproc_options options);
  int reproc_pid(reproc_t *process);
  int
  reproc_poll(reproc_event_source *sources, size_t num_sources, int timeout);
  int reproc_read(reproc_t *process,
                                REPROC_STREAM stream,
                                uint8_t *buffer,
                                size_t size);
  int
  reproc_write(reproc_t *process, const uint8_t *buffer, size_t size);
  int reproc_close(reproc_t *process, REPROC_STREAM stream);
  int reproc_wait(reproc_t *process, int timeout);
  int reproc_terminate(reproc_t *process);
  int reproc_kill(reproc_t *process);
  int reproc_stop(reproc_t *process, reproc_stop_actions stop);
  reproc_t *reproc_destroy(reproc_t *process);
  const char *reproc_strerror(int error);
  int reproc_run(const char *const *argv, reproc_options options);
  int reproc_run_ex(const char *const *argv,
                                  reproc_options options,
                                  reproc_sink out,
                                  reproc_sink err);

  void * realloc( void * pointer, size_t memorySize );
  void *memcpy(void *dest, const void *src, size_t count);
  void free(void *ptr);
]]

function load_reproc (path)
  if path ~= nil then
    local reproc = ffi.load(path)
  else
    local datafile = require("datafile")
    local luarocks_opener = require("datafile.openers.luarocks")
    datafile.openers = { luarocks_opener }
    local reproc = ffi.load(datafile.path("libs") .. "/libreproc.so")
    return reproc
  end
  return reproc
end

return load_reproc