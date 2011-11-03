#!/bin/sh

# Target directory for installation
TARGET=/opt/archive/`date +%F-%H-%M-%S`
echo "Installing into $TARGET."
CASACORE_TARGET=$TARGET/casacore
CASAREST_TARGET=$TARGET/casarest
PYRAP_TARGET=$TARGET/pyrap
PYRAP_PYTHON_TARGET=$PYRAP_TARGET/lib/python2.6/dist-packages
LOFAR_TARGET=$TARGET/LofIm

# Locations of checked-out source
CASACOREROOT=/var/scratch/casacore
CASARESTROOT=/var/scratch/casarest
PYRAPROOT=/var/scratch/pyrap
LOFARROOT=/var/scratch/LOFAR

# LOFARSOFT packages to be built
LOFARPACKAGES="Offline"
#LOFARPACKAGES="pyparameterset BBSControl BBSTools ExpIon pystationresponse pyparmdb MWImager DPPP AOFlagger LofarStMan MSLofar Pipeline"

# Locations of dependencies
WCSLIBROOT=/opt/archive/wcslib/4.8.2
DATADIR=/opt/measures/data

# Pull in some utility functions
. `dirname ${0}`/utils.sh

# Optional command line arguments to specify revision to build.
while getopts lr:s:fd optionName
do
    case $optionName in
        l) LOFAR_REVISION=$OPTARG;;
        c) CASACORE_REVISION=$OPTARG;;
        r) CASAREST_REVISION=$OPTARG;;
        p) PYRAP_REVISION=$OPTARG;;
        \?) exit 1;;
    esac
done

## Update & build casacore
update_source "casacore" $CASACOREROOT $CASACORE_REVISION
CASACORE_VERSION=$VERSION
echo "Configuring casacore"
mkdir -p $CASACOREROOT/build/opt
cd $CASACOREROOT/build/opt
cmake -DCMAKE_INSTALL_PREFIX=$CASACORE_TARGET -DUSE_HDF5=OFF -DWCSLIB_ROOT_DIR=$WCSLIBROOT -DDATA_DIR=$DATADIR $CASACOREROOT
echo "Building casacore."
make -j8
check_result "casacore" "make" $?
echo "Installing casacore."
make install
check_result "casacore" "make install" $?
echo "Built & installed casacore $CASACORE_VERSION."

# Update & build casarest
update_source "casarest" $CASARESTROOT $CASAREST_REVISION
CASAREST_VERSION=$VERSION
echo "Configuring casarest."
mkdir -p $CASARESTROOT/build
cd $CASARESTROOT/build
cmake -DWCSLIB_ROOT_DIR=$WCSLIBROOT -DCASACORE_ROOT_DIR=$CASACORE_TARGET -DCMAKE_INSTALL_PREFIX=$CASAREST_TARGET $CASARESTROOT
echo "Building casarest."
make -j8
check_result "casarest" "make" $?
echo "Installing casarest."
make install
check_result "casarest" "make install" $?
echo "Built & installed casarest $CASAREST_VERSION."

# Update & build pyrap
update_source "pyrap" $PYRAPROOT $PYRAP_REVISION
echo "Building & installing pyrap"
mkdir -p $PYRAP_PYTHON_TARGET
cd $PYRAPROOT
./batchbuild-trunk.py --casacore-root=$CASACORE_TARGET \
    --wcs-root=$WCSLIBROOT \
    --prefix=$PYRAP_TARGET \
    --python-prefix=$PYRAP_PYTHON_TARGET
check_result "pyrap" "batchbuild-trunk" $?

# Update LofIm, insert ASKAP dependencies, and build
update_source "LofIm" $LOFARROOT $LOFAR_REVISION
LOFAR_VERSION=$VERSION

echo "Inserting external ASKAPsoft dependencies."
CLUSTERBUILD=`date --date="yesterday" +%a`
for path in Base/accessors/src \
    Base/askap/src \
    Base/mwcommon/src \
    Base/scimath/src \
    Components/Synthesis/synthesis/src
do
  #lfe001:/opt/LofIm/daily/$CLUSTERBUILD/lofar/LOFAR/CEP/Imager/ASKAPsoft/$path/
  rsync -tvvr --exclude=.svn \
  lhn001:/opt/cep/LofIm/daily/$CLUSTERBUILD/lofar_build/LOFAR/CEP/Imager/ASKAPsoft/$path/ \
  $LOFARROOT/CEP/Imager/ASKAPsoft/$path
done

echo "Configuring LofIm."
mkdir -p $LOFARROOT/build/gnu_opt
cd $LOFARROOT/build/gnu_opt
cmake -DCASACORE_ROOT_DIR=$CASACORE_TARGET \
    -DPYRAP_ROOT_DIR=$PYRAP_TARGET         \
    -DWCSLIB_ROOT_DIR=$WCSLIBROOT          \
    -DCASAREST_ROOT_DIR=$CASAREST_TARGET   \
    -DBUILD_SHARED_LIBS=ON                 \
    -DBUILD_PACKAGES=$LOFARPACKAGES        \
    -DCMAKE_INSTALL_PREFIX=$LOFAR_TARGET   \
    $LOFARROOT
echo "Building LofIm."
make -j8
check_result "LofIm" "make" $?
echo "Installing LofIm."
make install
check_result "LofIm" "make install" $?
echo "Built & installed LofIm $LOFAR_VERSION."

echo "Generating init.sh."
INITFILE=$TARGET/init.sh
cat > $INITFILE <<-END
#wcslib
export LD_LIBRARY_PATH=$WCSLIBROOT/lib\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}
export PATH=$WCSLIBROOT/bin\${PATH:+:\${PATH}}

# casacore
export LD_LIBRARY_PATH=$CASACORE_TARGET/lib\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}
export PATH=$CASACORE_TARGET/bin\${PATH:+:\${PATH}}

# casarest
export LD_LIBRARY_PATH=$CASAREST_TARGET/lib\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}
export PATH=$CASAREST_TARGET/bin\${PATH:+:\${PATH}}

# pyrap
export LD_LIBRARY_PATH=$PYRAP_TARGET/lib\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}
export PYTHONPATH=$PYRAP_PYTHON_TARGET\${PYTHONPATH:+:\${PYTHONPATH}}

# LofIm
. $LOFAR_TARGET/lofarinit.sh
END

# Install this build as the default
ln -sf $INITFILE /opt/archive/init.sh

# Install symlinks for backwards compatibility
ln -sf $CASACORE_TARGET /opt/archive/casacore/default
rm /opt/archive/casarest/default
ln -sf $CASAREST_TARGET /opt/archive/casarest/default
rm /opt/archive/pyrap/default
ln -sf $PYRAP_TARGET /opt/archive/pyrap/default
rm /opt/archive/lofim/default
ln -sf $LOFAR_TARGET /opt/archive/lofim/default

echo "Done."
