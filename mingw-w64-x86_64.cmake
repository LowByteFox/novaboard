set(CMAKE_SYSTEM_NAME Windows)
set(TOOLCHAIN_PREFIX x86_64-w64-mingw32)

set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_RC_COMPILER ${TOOLCHAIN_PREFIX}-windres)

if(EXISTS /usr/${TOOLCHAIN_PREFIX})
    set(CMAKE_FIND_ROOT_PATH /usr/${TOOLCHAIN_PREFIX})
elseif(EXISTS /usr/lib/mingw64-toolchain)
    set(CMAKE_FIND_ROOT_PATH /usr/lib/mingw64-toolchain)
else()
    message(FATAL_ERROR "Unable to find mingw toolchain root!")
endif()
