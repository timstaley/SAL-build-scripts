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
	update_authenticated_svn_repo $LOFAR_SVNROOT $LOFAR_SVN_LOGIN $LOFAR_REV
    cd $LOFAR_SVNROOT
    for patchfile in $PATCHES_GRP_DIR/lofar-patches/*patch
    do
        echo $patchfile
        git apply $patchfile
        check_result "LofIm" "git apply $patchfile" $?
    done
	echo
	echo "*** Sources updated ***"
fi

#------------------------------------------------------------------------------
#Setup
echo 
echo "*** Creating install directories ***"
ARCHIVE_TARGET=$LOFAR_BUILDS_DIR/`date +%F-%H-%M`
echo "Target: ${ARCHIVE_TARGET}"
mkdir -p $ARCHIVE_TARGET

#Make a pointer to the archive directory, so that other build scripts can find it at a later date.

SYMLINKS=$ARCHIVE_TARGET/symlinks
#make directory structure:
mkdir -p $SYMLINKS/bin
mkdir -p $SYMLINKS/lib
mkdir -p $SYMLINKS/python-packages

#------------------------------------------------------------------------------

echo "*** Building Lofar Offline package... ***"

cd $LOFAR_SVNROOT

SVN_REV=$(get_git_svnrev)
GIT_HASH=$(get_git_short_hash)
LOFAR_REV="${SVN_REV}_${GIT_HASH}"
LOFAR_TARGET=$ARCHIVE_TARGET/LOFAR_r${LOFAR_REV}

ln -sfn $LOFAR_TARGET $LOFAR_BUILDS_DIR/lofar-latest


echo "Regenerating cmake package list:"
bash $LOFAR_SVNROOT/CMake/gen_LofarPackageList_cmake.sh
sleep 0.5
echo "Done."

#Put the symlinks in place first, 
#so if the build fails we can manually fix it and they're ready to go.

#ln -sfn $LOFAR_TARGET $SYMLINKS/lofar-root #for setting $LOFARROOT
#ln -sfn $LOFAR_TARGET/bin $SYMLINKS/bin/lofar
#ln -sfn $LOFAR_TARGET/lib $SYMLINKS/lib/lofar
#ln -sfn $LOFAR_TARGET/lib/python${LOFAR_PYTHON_VERSION}/dist-packages/ $SYMLINKS/python-packages/lofar

cd $LOFAR_SRC_ROOT
rm -rf build/
mkdir -p build/gnu_opt
cd build/gnu_opt

#mkdir -p build/gnu_debug
#cd build/gnu_debug

cmake_command="cmake $LOFAR_SVNROOT \
    -DCASACORE_ROOT_DIR=$(readlink ${STABLE_SOFT_DIR}/builds/casacore-active ) \
    -DPYRAP_ROOT_DIR=$(readlink ${STABLE_SOFT_DIR}/builds/pyrap-active )         \
    -DCASAREST_ROOT_DIR=$(readlink ${STABLE_SOFT_DIR}/builds/casarest-active)   \
    -DLOG4CPLUS_ROOT_DIR=$LOG4CPLUS_ROOT_DIR   \
    -DBUILD_SHARED_LIBS=ON                 \
    -DBUILD_PACKAGES=\"LofarFT Offline\"        \
    -DCMAKE_INSTALL_PREFIX=$LOFAR_TARGET 	\
	-DUSE_OPENMP=ON	\
"
echo $cmake_command > cmake_command.sh
# Weirdly, this fails if we call it directly as "$cmake_command"
# but running in under a fresh shell works. 
# Scripting in bash sucks sometimes.
bash cmake_command.sh
check_result "lofar" "cmake" $?

make -j$LOFAR_BUILD_NJOBS
check_result "Lofar offline" "make" $?
make install
check_result "Lofar offline" "make install" $?
cd $startdir


echo 
echo "*** Build completed successfully ***"

