#!/bin/bash
####################################################################
# After successfully building the trio casacore / casarest / pyrap,
# we can probably assume they are in a (hopefully) working build state,
# and update the pointers to the active versions. We do that here.
####################################################################
BUILD_SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
source $BUILD_SCRIPTS_DIR/CONFIG
source $BUILD_SCRIPTS_DIR/utils.sh
####################################################################

SYMLINKS=$STABLE_SOFT_DIR/symlinks
#By routing the bin/lib/python subdir symlinks through a single 'active' pointer,
#we make it very easy to manually switch between versions and then re-run the 
#symlink collation script.
#Of course, we have to resolve the 'latest' link to an real build folder first.
ln -sfn $(readlink $STABLE_SOFT_DIR/builds/casacore/casacore-latest) $STABLE_SOFT_DIR/builds/casacore-active
ln -sfn $(readlink $STABLE_SOFT_DIR/builds/casarest/casarest-latest) $STABLE_SOFT_DIR/builds/casarest-active
ln -sfn $(readlink $STABLE_SOFT_DIR/builds/pyrap/pyrap-latest) $STABLE_SOFT_DIR/builds/pyrap-active

#In fact, the following symlinks always point at the 'active' link, 
#and so don't need overwriting - but we create them in case it's a first
#build.
ln -sfn $STABLE_SOFT_DIR/builds/casacore-active/bin $SYMLINKS/bin/casacore
ln -sfn $STABLE_SOFT_DIR/builds/casacore-active/lib $SYMLINKS/lib/casacore

ln -sfn $STABLE_SOFT_DIR/builds/casarest-active/bin $SYMLINKS/bin/casarest
ln -sfn $STABLE_SOFT_DIR/builds/casarest-active/lib $SYMLINKS/lib/casarest

ln -sfn $STABLE_SOFT_DIR/builds/pyrap-active/lib $SYMLINKS/lib/pyrap
ln -sfn $STABLE_SOFT_DIR/builds/pyrap-active/unpacked $SYMLINKS/python-packages/pyrap 
