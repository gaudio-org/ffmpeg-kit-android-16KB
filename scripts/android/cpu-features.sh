#!/bin/bash

# Source the function file to get required functions
source "$(dirname "$0")/function-android.sh"

# Fix CMakeLists.txt after download
sed -i '' 's/cmake_minimum_required(VERSION 3.0)/cmake_minimum_required(VERSION 3.5)/' "${BASEDIR}/src/cpu-features/CMakeLists.txt"

# Disable BUILD_TESTING to avoid googletest CMake version issues
sed -i '' 's/if(BUILD_TESTING)/if(FALSE)/' "${BASEDIR}/src/cpu-features/CMakeLists.txt"

# Use system CMake explicitly instead of NDK CMake
SYSTEM_CMAKE=$(which cmake)

# Get the cmake command from android_ndk_cmake function but replace the cmake path
CMAKE_CMD=$(android_ndk_cmake | sed "s|${ANDROID_SDK_ROOT}/cmake/[^/]*/bin/cmake|${SYSTEM_CMAKE}|g")

# Execute the modified cmake command
eval ${CMAKE_CMD} || return 1

make -C "$(get_cmake_build_directory)" || return 1

make -C "$(get_cmake_build_directory)" install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_cpufeatures_package_config "0.8.0" || return 1