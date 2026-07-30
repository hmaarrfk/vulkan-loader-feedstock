#!/bin/sh

mkdir build
cd build

# Vulkan ICD and layer manifests in conda environments are installed under `$PREFIX/share/vulkan`.
cmake ${CMAKE_ARGS} -GNinja \
  -DFALLBACK_DATA_DIRS="${PREFIX}/share:/usr/local/share:/usr/share" \
  ..

cmake --build . --config Release
cmake --build . --config Release --target install
