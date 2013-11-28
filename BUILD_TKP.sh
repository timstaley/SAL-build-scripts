#!/bin/bash
####################################################################
BRANCH_TO_BUILD=$1
if [[ -z "$BRANCH_TO_BUILD" ]]; then
    BRANCH_TO_BUILD=master
fi

startdir=`pwd`
BUILD_SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
source $BUILD_SCRIPTS_DIR/CONFIG
source $BUILD_SCRIPTS_DIR/utils.sh

#------------------------------------------------------------------------------
#Setup
echo 
echo "*** Creating install directories ***"
ARCHIVE_TARGET=$TKP_BUILDS_DIR/${BRANCH_TO_BUILD}-builds/`date +%F-%H-%M`
echo "Target: ${ARCHIVE_TARGET}"
mkdir -p $ARCHIVE_TARGET

echo "Installing into $ARCHIVE_TARGET"

#------------------------------------------------------------------------------
if [[ -n $UPDATE_REPOS ]]; then
	update_git_repo $TKP_SVNROOT/tkp $BRANCH_TO_BUILD
	echo
	echo "*** Sources updated ***"
fi
#------------------------------------------------------------------------------

echo 
echo "**** Building TKP... **** "

#Within the archive folder, we create a subfolder which tags the build with its SHA hash:
cd $TKP_SVNROOT/tkp
TKP_SHA=$(get_git_short_hash)
BUILD_TARGET=${ARCHIVE_TARGET}/tkp_${TKP_SHA}
echo "TKP SHA tagged build target is $BUILD_TARGET"

ln -sfn $BUILD_TARGET $TKP_BUILDS_DIR/${BRANCH_TO_BUILD}-latest
cp $BUILD_SCRIPTS_DIR/init_scripts/tkp/init-script.sh $TKP_BUILDS_DIR

#----------------------------------------------------------------------------
#Build and install TKP libs

rm -rf $TKP_SVNROOT/tkp/build 
mkdir $TKP_SVNROOT/tkp/build
cd $TKP_SVNROOT/tkp/build

cmake_command="cmake $TKP_SVNROOT/tkp -DCMAKE_INSTALL_PREFIX=${BUILD_TARGET} 
		-DTKP_DEVELOP=1 
		-DWCSLIB_ROOT_DIR=$WCSLIB_ROOT_DIR
		-DPYTHON_PACKAGES_DIR=${BUILD_TARGET}/python-packages"
echo $cmake_command > cmake_command.sh
bash cmake_command.sh
check_result "tkp" "cmake" $?

make -j$LOFAR_BUILD_NJOBS
check_result "tkp" "build" $?
make install
check_result "tkp" "install" $?
 
#ln -sfnv $BUILD_TARGET $TARGET/tkp-root

#Symlink the catalogs into the installed folder, 
#so you can easily run a database init:
#cd $TARGET/tkp-root/database/catalog
#ln -sfnv $TKP_CATALOGS/NVSS-all_strip.csv nvss/nvss.csv
#ln -sfnv $TKP_CATALOGS/WENSS-all_strip.csv wenss/wenss.csv
#ln -sfnv $TKP_CATALOGS/VLSS-all_strip.csv vlss/vlss.csv

#----------------------------------------------------------------------------
#------------------------------------------------------------------------------

