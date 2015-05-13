#!/bin/bash
# This script is the entrypoint of a CGAL testsuite docker container.
set -e

if [ -z "${CGAL_TEST_PLATFORM}" ]; then
    export CGAL_TEST_PLATFORM="${HOSTNAME}"
    echo "CGAL_TEST_PLATFORM not set. Using HOSTNAME:${HOSTNAME}"
else
    echo "CGAL_TEST_PLATFORM is ${CGAL_TEST_PLATFORM}"
fi

if [ -z "${CGAL_NUMBER_OF_JOBS}" ]; then
    CGAL_NUMBER_OF_JOBS=1
    echo "CGAL_NUMBER_OF_JOBS not set. Defaulting to 1."
else
    echo "CGAL_NUMBER_OF_JOBS is ${CGAL_NUMBER_OF_JOBS}."
fi

# The directory where the release is stored.
CGAL_RELEASE_DIR="/mnt/testsuite/"
# Directory where CGAL sources are stored.
CGAL_SRC_DIR="${CGAL_RELEASE_DIR}src/"
# Directory where CGAL tests are stored.
CGAL_TEST_DIR="${CGAL_RELEASE_DIR}test/"

# The directory where testresults are stored.
CGAL_TESTRESULTS="/mnt/testresults/"
# The actual logfile.
CGAL_LOG_FILE="${CGAL_TESTRESULTS}${CGAL_TEST_PLATFORM}"

# The directory of the build tree. The layout is so convoluted so
# satisfy collect_cgal_testresults_from_cmake.
#
# It assumes the build directory containing CMakeCache.txt,
# include/CGAL/compiler_config.h, etc. to be the parent directory.
CGAL_DIR="/build/src/cmake/platforms/${CGAL_TEST_PLATFORM}/"
CGAL_SRC_BUILD_DIR="${CGAL_DIR}"
CGAL_TEST_BUILD_DIR="/build/src/cmake/platforms/${CGAL_TEST_PLATFORM}/test/"


export CGAL_DIR
export CGAL_TEST_PLATFORM

# Create the binary directories
if [ ! -d "${CGAL_SRC_BUILD_DIR}" ]; then 
    mkdir -p "${CGAL_SRC_BUILD_DIR}"
fi
if [ ! -d "${CGAL_TEST_BUILD_DIR}" ]; then
    mkdir -p "${CGAL_TEST_BUILD_DIR}"
fi

# Build CGAL. The CGAL_CMAKE_FLAGS used here will affect all other
# builds using this binary directory.
cd "${CGAL_SRC_BUILD_DIR}"
cmake -DRUNNING_CGAL_AUTO_TEST=TRUE VERBOSE=1 \
      ${CGAL_CMAKE_FLAGS} "${CGAL_RELEASE_DIR}" 2>&1 | tee "installation.log"
make VERBOSE=ON -k -fMakefile 2>&1 | tee -a "installation.log"

# collect_cgal_testresults_from_cmake expects installation.log in ../../
cp "installation.log" "../installation.log"

# Build and Execute the Tests

# We need to make a copy of the whole test dir because the current
# scripts don't allow out of source builds.
cp -r "${CGAL_TEST_DIR}/." "${CGAL_TEST_BUILD_DIR}"
cd "${CGAL_TEST_BUILD_DIR}"
make -j ${CGAL_NUMBER_OF_JOBS} -k -fmakefile2

# Copy version.h, so thhat collect_cgal_testresults_from_cmake can find it.
mkdir -p "${CGAL_DIR}/include/CGAL"
cp "${CGAL_RELEASE_DIR}/include/CGAL/version.h" "${CGAL_DIR}/include/CGAL/"

./collect_cgal_testresults_from_cmake

# Those are the files generated by collect_cgal_testresults_from_cmake.
cp "results_${CGAL_TESTER}_${CGAL_TEST_PLATFORM}.tar.gz" "results_${CGAL_TESTER}_${CGAL_TEST_PLATFORM}.txt" \
   "${CGAL_TESTRESULTS}/"
