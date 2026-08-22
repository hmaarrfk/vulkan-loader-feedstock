#!/bin/sh

mkdir build
cd build

# Vulkan ICD and layer manifests in conda environments are installed under
# `$PREFIX/share/vulkan`, which the loader does not search by default.
# Ref: https://github.com/conda-forge/vulkan-tools-feedstock/pull/34#issuecomment-5126080861
#
# FALLBACK_DATA_DIRS on its own is not enough.  The loader only consults it when
# XDG_DATA_DIRS is unset or empty:
#
#     if (NULL == xdg_data_dirs || '\0' == xdg_data_dirs[0]) {
#         xdg_data_dirs = FALLBACK_DATA_DIRS;
#     }                                              -- loader/loader.c
#
# so it is ignored in any desktop session, which always sets XDG_DATA_DIRS.  It
# is still worth keeping for headless/container use, where XDG_DATA_DIRS is
# commonly unset.
#
# SYSCONFDIR, by contrast, is appended to the manifest search path
# unconditionally.  Leaving the loader's own `SYSCONFDIR` cache variable empty
# makes CMakeLists.txt use CMAKE_INSTALL_FULL_SYSCONFDIR *and* additionally
# define EXTRASYSCONFDIR="/etc", so pointing CMAKE_INSTALL_SYSCONFDIR at
# `$PREFIX/share` gets `$PREFIX/share/vulkan/{icd.d,*layer.d}` searched while
# keeping `/etc/vulkan/...` (used by, among others, the NVIDIA .run installer).
# Nothing is installed into sysconfdir, so this only affects the compiled-in
# search path.
cmake ${CMAKE_ARGS} -GNinja \
  -DCMAKE_INSTALL_SYSCONFDIR="${PREFIX}/share" \
  -DFALLBACK_DATA_DIRS="${PREFIX}/share:/usr/local/share:/usr/share" \
  ..

cmake --build . --config Release
cmake --build . --config Release --target install
