cmake_minimum_required(VERSION 3.28)
project(lua-reproc)

set(BUILD_SHARED_LIBS ON)

set(REPROC_INSTALL OFF)
add_subdirectory(reproc)

install(DIRECTORY ${reproc_BINARY_DIR}/reproc/lib/ DESTINATION ${CMAKE_CURRENT_LIST_DIR}/libs)
install(FILES src/reproc.lua DESTINATION ${INST_LUADIR})
