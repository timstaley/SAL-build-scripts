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

#cd $CASAREST_SVNROOT
#for patchfile in $PATCHES_GRP_DIR/casarest-patches/*patch
#do
#    echo $patchfile
#    git apply $patchfile
#    check_result "casarest" "git apply $patchfile" $?
#done

cd $PYRAP_SVNROOT
for patchfile in $PATCHES_GRP_DIR/pyrap-patches/*patch
do
    echo $patchfile
    git apply $patchfile
    check_result "pyrap" "git apply $patchfile" $?
done


cd $LOFAR_SVNROOT
for patchfile in $PATCHES_GRP_DIR/lofar-patches/*patch
do
    echo $patchfile
    git apply $patchfile
    check_result "LofIm" "git apply $patchfile" $?
done

#cd $LUS_SVNROOT
#for patchfile in $PATCHES_GRP_DIR/lus-patches/*patch
#do
#    echo $patchfile
#    git apply $patchfile
#    check_result "LUS" "git apply $patchfile" $?
#done
