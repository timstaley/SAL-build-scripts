#!/bin/bash

#Pull in general lofar build config:
BUILD_SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
source $BUILD_SCRIPTS_DIR/CONFIG
source $BUILD_SCRIPTS_DIR/utils.sh

echo "Build scripts are located under $BUILD_SCRIPTS_DIR"

#------------------------------------------------------------------------------

#LOFAR_REV=20986
#CASACORE_REV=21227
if [[ -n $UPDATE_REPOS ]]; then
	update_git_repo $RSM_SVNROOT
	echo
	echo "*** Sources updated ***"
fi

#------------------------------------------------------------------------------
cd $RSM_SVNROOT
GIT_HASH=$(get_git_short_hash)

ARCHIVE_TARGET=$LOFAR_BUILDS_DIR/`date +%F-%H-%M`
BUILD_TARGET=$ARCHIVE_TARGET/rsm_lofar_${GIT_HASH}
#------------------------------------------------------------------------------
#Setup
echo 
echo "*** Creating install directories ***"
mkdir -p $BUILD_TARGET
ln -sfn $BUILD_TARGET $LOFAR_BUILDS_DIR/rsm-latest
cp $BUILD_SCRIPTS_DIR/init_scripts/init-lofar.sh $LOFAR_BUILDS_DIR

#-----------------------------------------------------------------------------
echo "Regenerating cmake package list:"
bash $RSM_SVNROOT/CMake/gen_LofarPackageList_cmake.sh
sleep 0.5
echo "Done."

cd $RSM_SRC_ROOT
rm -rf build/
mkdir -p build/gnu_opt
cd build/gnu_opt

#mkdir -p build/gnu_debug
#cd build/gnu_debug

cmake_command="cmake $LOFAR_SVNROOT \
    -DCASACORE_ROOT_DIR=$(readlink ${STABLE_SOFT_DIR}/builds/casacore-active ) \
    -DCASAREST_ROOT_DIR=$(readlink ${STABLE_SOFT_DIR}/builds/casarest-active )   \
    -DPYRAP_ROOT_DIR=$(readlink ${STABLE_SOFT_DIR}/builds/pyrap-active )         \
    -DWCSLIB_ROOT_DIR=$WCSLIB_ROOT_DIR     \
    -DLOG4CPLUS_ROOT_DIR=$LOG4CPLUS_ROOT_DIR   \
    -DBUILD_SHARED_LIBS=ON                 \
    -DBUILD_PACKAGES=\"LofarFT Offline\"        \
    -DCMAKE_INSTALL_PREFIX=$BUILD_TARGET 	\
	-DUSE_OPENMP=ON	\
"
echo $cmake_command > cmake_command.sh
# Weirdly, this fails if we call it directly as "$cmake_command"
# but running in under a fresh shell works. 
# Scripting in bash sucks sometimes.
bash cmake_command.sh
check_result "RSM lofar" "cmake" $?

make -j$LOFAR_BUILD_NJOBS
check_result "RSM Lofar offline" "make" $?
make install
check_result "RSM Lofar offline" "make install" $?
cd $startdir


echo 
echo "*** Build completed successfully ***"

