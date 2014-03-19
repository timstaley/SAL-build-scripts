echo "*** Building Lofar Offline package... ***"

echo "Regenerating cmake package list:"
bash $REPOROOT/CMake/gen_LofarPackageList_cmake.sh
sleep 0.5
echo "Done."


cd $LOFAR_SRC_ROOT
rm -rf build/
mkdir -p build/gnu_opt
cd build/gnu_opt

#mkdir -p build/gnu_debug
#cd build/gnu_debug

cmake_command="cmake $REPOROOT \
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

