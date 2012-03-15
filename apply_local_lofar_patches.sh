#!/bin/bash
####################################################################
startdir=`pwd`
BUILD_SCRIPTS_DIR=`dirname ${0}`
BUILD_SCRIPTS_DIR=`cd $BUILD_SCRIPTS_DIR; pwd -P`
source $BUILD_SCRIPTS_DIR/CONFIG
source $BUILD_SCRIPTS_DIR/utils.sh
####################################################################
echo 
echo "**** Applying local patches. *****"

cd $LOFAR_SVNROOT
for patchfile in $PATCHES_GRP_DIR/lofar-patches/*patch
do
    echo $patchfile
    git apply $patchfile
    check_result "LofIm" "git apply $patchfile" $?
done

cd $LUS_SVNROOT
for patchfile in $PATCHES_GRP_DIR/lus-patches/*patch
do
    echo $patchfile
    git apply $patchfile
    check_result "LUS" "git apply $patchfile" $?
done
