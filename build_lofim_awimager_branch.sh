#!/bin/bash

#Pull in general lofar build config:
BUILD_SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
source $BUILD_SCRIPTS_DIR/CONFIG
source $BUILD_SCRIPTS_DIR/utils.sh

echo "Build scripts are located under $BUILD_SCRIPTS_DIR"

#------------------------------------------------------------------------------

#LOFAR_REV=20986
#CASACORE_REV=21227
REPOROOT=$LOFAR_SRC_ROOT/LOFAR
if [[ -n $UPDATE_REPOS ]]; then
	update_authenticated_svn_repo $REPOROOT $LOFAR_SVN_LOGIN $LOFAR_REV
    cd $REPOROOT
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

cd $REPOROOT
SVN_REV=$(get_git_svnrev)
GIT_HASH=$(get_git_short_hash)
LOFAR_REV="${SVN_REV}_${GIT_HASH}"
LOFAR_TARGET=$ARCHIVE_TARGET/LOFAR_r${LOFAR_REV}
ln -sfn $LOFAR_TARGET $LOFAR_BUILDS_DIR/awimager-latest
#------------------------------------------------------------------------------

source $BUILD_SCRIPTS_DIR/build_lofim.sh

echo 
echo "*** Build completed successfully ***"

