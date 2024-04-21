package = "lua-reproc"
version = "dev-1"
source = {
   url = "gitrec://github.com/Simon-L/lua-reproc",
   branch = "main"
}
description = {
   homepage = "https://github.com/Simon-L/lua-reproc",
   license = "MIT license"
}
build = {
  type = "cmake",
  variables = {
    CFLAGS="$(CFLAGS)",
    LIBFLAG="$(LIBFLAG)",
    LUA_LIBDIR="$(LUA_LIBDIR)",
    LUA_BINDIR="$(LUA_BINDIR)",
    LUA_INCDIR="$(LUA_INCDIR)",
    LUA="$(LUA)",
    INST_PREFIX="$(PREFIX)",
    INST_BINDIR="$(BINDIR)",
    INST_LIBDIR="$(LIBDIR)",
    INST_LUADIR="$(LUADIR)",
    INST_CONFDIR="$(CONFDIR)",
  },
  copy_directories = {"libs"}
}
