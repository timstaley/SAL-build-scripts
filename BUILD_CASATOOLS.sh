#!/bin/bash
####################################################################
BUILD_SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
source $BUILD_SCRIPTS_DIR/CONFIG
source $BUILD_SCRIPTS_DIR/utils.sh
####################################################################

CASAREST_REV=8760
if [[ -n $UPDATE_REPOS ]]; then
#    update_svn_repo $CASACORE_SVNROOT $CASACORE_REV
    update_svn_repo $CASAREST_SVNROOT $CASAREST_REV
    update_svn_repo $PYRAP_SVNROOT $PYRAP_REV
    cd $PYRAP_SVNROOT
    for patchfile in $PATCHES_GRP_DIR/pyrap-patches/*patch
    do
        echo $patchfile
        git apply $patchfile
        check_result "pyrap" "git apply $patchfile" $?
    done
    echo
	echo "*** Sources updated ***"
fi

#Begin builds:
bash $BUILD_SCRIPTS_DIR/build_casacore
check_result "casacore" "build script" $?
bash $BUILD_SCRIPTS_DIR/build_casarest
check_result "casarest" "build script" $?
bash $BUILD_SCRIPTS_DIR/build_pyrap
check_result "pyrap" "build script" $?

cd $BUILD_SCRIPTS_DIR
bash $BUILD_SCRIPTS_DIR/update_casatools_symlinks.sh
