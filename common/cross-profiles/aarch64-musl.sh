# Cross build profile for ARMv8.

XBPS_TARGET_MACHINE="aarch64-musl"
XBPS_CROSS_TRIPLET="aarch64-linux-musl"
XBPS_CROSS_CFLAGS="-march=armv8-a"
XBPS_CROSS_CXXFLAGS="$XBPS_CROSS_CFLAGS"
