FIND_PACKAGE(Torch REQUIRED)

SET(src sys.c)
SET(luasrc init.lua)

ADD_TORCH_PACKAGE(sys "${src}" "${luasrc}" "System")
TARGET_LINK_LIBRARIES(sys luaT TH)
