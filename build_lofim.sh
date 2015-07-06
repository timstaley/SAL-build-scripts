echo "*** Building Lofar Offline package... ***"

echo "Regenerating cmake package list:"
bash $REPOROOT/CMake/gen_LofarPackageList_cmake.sh
sleep 0.5
echo "Done."


cd $REPOROOT/..
rm -rf build/
mkdir -p build/gnu_opt
cd build/gnu_opt

#mkdir -p build/gnu_debug
#cd build/gnu_debug

cmake_command="cmake $REPOROOT \
    -DCASACORE_ROOT_DIR=${STABLE_SOFT_DIR}/casalibs/casacore-2.0.1  \
    -DPYRAP_ROOT_DIR=${STABLE_SOFT_DIR}/casalibs/pycasacore-2.0.0-venv/lib/python2.7/site-packages \
    -DCASAREST_ROOT_DIR=${STABLE_SOFT_DIR}/casalibs/casarest-r8765   \
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

