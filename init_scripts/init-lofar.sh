#!/bin/bash

# Adds a LOFAR build to the environment bin/lib/python paths.
#
# This file should be copied to $LOFAR_BUILDS_DIR as defined in CONFIG.
# The admin should then manually create a symlink 'lofar-build-default' in 
# $LOFAR_BUILDS_DIR which points to the desired default buildset under 
# $$LOFAR_BUILDS_DIR/archive/  (usually the one referenced by 
# the symlink at $LOFAR_BUILDS_DIR/lofar-latest ).
#
# Note that users can define PREF_LOFAR_BUILD before sourcing this,
# if a particular buildset is preferred.

#Setup the various environment paths:
SAL_LOGDIR="$HOME/.salbuilds"
SAL_INIT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
SAL_PYTHON_VERSION=$(python -c "import sys; print sys.version[:3]")

if [[ -z "$PREF_LOFAR_BUILD" ]];
then
    if ! [ -L $SAL_INIT_SCRIPT_DIR/default-build ]; then 
        echo "Please create a default-build pointing symlink, e.g. using"
        echo "ln -sfnv \$(readlink $SAL_INIT_SCRIPT_DIR/lofar-latest) $SAL_INIT_SCRIPT_DIR/default-build"
        return 1
    fi    
    PREF_LOFAR_BUILD=$( cd $SAL_INIT_SCRIPT_DIR/default-build && pwd -P )
fi

export PATH=${PREF_LOFAR_BUILD}/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=${PREF_LOFAR_BUILD}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export PYTHONPATH=${PREF_LOFAR_BUILD}/lib/python${SAL_PYTHON_VERSION}/dist-packages${PYTHONPATH:+:${PYTHONPATH}} 
export LOFARROOT=$PREF_LOFAR_BUILD

#---------------------------------------------------------------------------
#Log which builds used when:
mkdir -p $SAL_LOGDIR
echo "$(date) --- $PREF_LOFAR_BUILD" >> $SAL_LOGDIR/lofar_builds_used.log
echo "$(date) --- $PREF_LOFAR_BUILD --- $(whoami) --- $(hostname)" >> "${SAL_INIT_SCRIPT_DIR}/lofar_builds_used.log"
unset SAL_LOGDIR
unset SAL_INIT_SCRIPT_DIR
unset SAL_PYTHON_VERSION
#---------------------------------------------------------------------------

