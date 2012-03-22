#!/bin/bash

#Pull in general lofar build config:
BUILD_SCRIPTS_DIR=`dirname ${0}`
BUILD_SCRIPTS_DIR=`cd $BUILD_SCRIPTS_DIR; pwd -P`
source $BUILD_SCRIPTS_DIR/CONFIG
source $BUILD_SCRIPTS_DIR/utils.sh

echo "Build scripts are located under $BUILD_SCRIPTS_DIR"

#------------------------------------------------------------------------------
#Update?
update_repos="true"
#unset update_repos #(false)

#LOFAR_REV=20457

if [[ -n $update_repos ]]; then
	update_source $CASACORE_SVNROOT $CASACORE_REV
	update_source $CASAREST_SVNROOT $CASAREST_REV
	update_source $PYRAP_SVNROOT $PYRAP_REV
	update_source $LOFAR_SVNROOT $LOFAR_REV
	update_source $TKP_SVNROOT $TKP_REV
	update_source $LUS_SVNROOT $LUS_REV
	bash apply_local_lofar_patches.sh
	echo
	echo "*** Sources updated ***"
fi

#------------------------------------------------------------------------------
#Check ASKAP components have been pulled into the LOFAR source tree:
echo "*** Inserting external ASKAPsoft dependencies. ***"

for path in Base/accessors/src \
    Base/askap/src \
    Base/mwcommon/src \
    Base/scimath/src \
    Components/Synthesis/synthesis/src
do
  rsync -tvvr --exclude=.svn \
  $ASKAP_SRC_DIR/$path/ \
  $LOFAR_SVNROOT/CEP/Imager/ASKAPsoft/$path
	check_result "ASKAPSOFT" "rsync" $?
done

#------------------------------------------------------------------------------
#Setup
echo 
echo "*** Creating install directories ***"
TARGET=$LOFAR_BUILDS_ARCHIVE_DIR/`date +%F-%H-%M`
echo "Target: ${TARGET}"

#Make a pointer to the archive directory, so that other build scripts can find it at a later date.
ln -sfn $TARGET $ARCHIVE_LATEST_DIR_LINK 

SYMLINKS=$TARGET/symlinks
#make directory structure:
mkdir -p $SYMLINKS/bin
mkdir -p $SYMLINKS/lib
mkdir -p $SYMLINKS/python-packages

#------------------------------------------------------------------------------
#Create imaging /tkp pipeline init file
echo "Generating init-lofar.sh."
INITFILE=$TARGET/init-lofar.sh
cat > $INITFILE <<-END
archive_target_dir=$TARGET
source $LOFAR_BUILDS_ARCHIVE_DIR/set_lofar_pipeline_env_paths.sh
unset archive_target_dir #because we need to "source" this file.
END

#------------------------------------------------------------------------------
#Create pulsar tools init file
echo "Generating init-pulsar.sh."
INITFILE=$TARGET/init-pulsar.sh
cat > $INITFILE <<-END
archive_target_dir=$TARGET
source $LOFAR_BUILDS_ARCHIVE_DIR/set_lus_pulsar_env_paths.sh
unset archive_target_dir #because we need to "source" this file.
END

#------------------------------------------------------------------------------
#Create path collation file, in case the build doesn't complete and we run it manually:
echo "Generating collate_paths.sh"
LOFAR_TARGET=$TARGET/LOFAR_r${LOFAR_REV}
COLLATE_SCRIPT=$TARGET/collate_paths.sh
cat > $COLLATE_SCRIPT <<-END
export archive_target_dir=$TARGET
bash $LOFAR_BUILDS_ARCHIVE_DIR/collate_lofar_symlinks.sh
unset archive_target_dir    #in case we "source" this file
END

#------------------------------------------------------------------------------

#Begin builds:
bash $BUILD_SCRIPTS_DIR/build_casacore
check_result "casacore" "build script" $?
bash $BUILD_SCRIPTS_DIR/build_pyrap
check_result "pyrap" "build script" $?
bash $BUILD_SCRIPTS_DIR/build_casarest
check_result "casarest" "build script" $?
bash $BUILD_SCRIPTS_DIR/build_lofar
check_result "lofar" "build script" $?
bash $BUILD_SCRIPTS_DIR/build_tkp
check_result "tkp" "build script" $?
bash $BUILD_SCRIPTS_DIR/build_lus
check_result "lus" "build script" $?

bash $COLLATE_SCRIPT


