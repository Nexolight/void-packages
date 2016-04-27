# Cross build profile for MIPS32 BE soft float.

XBPS_TARGET_MACHINE="mips-musl"
XBPS_CROSS_TRIPLET="mips-linux-musl"
XBPS_CROSS_CFLAGS="-mtune=mips32r2 -mabi=32 -msoft-float"
XBPS_CROSS_CXXFLAGS="$XBPS_CROSS_CFLAGS"
