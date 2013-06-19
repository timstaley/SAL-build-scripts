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

INIT_SCRIPT_STARTDIR=$(pwd)

if [[ -z "$PREF_LOFAR_BUILD" ]];
then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
    PREF_LOFAR_BUILD=$( cd $SCRIPT_DIR/default-build && pwd -P )
fi

export PATH=${PATH:+${PATH}:}${PREF_LOFAR_BUILD}/bin 
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${PREF_LOFAR_BUILD}/lib 
export PYTHONPATH=${PYTHONPATH:+${PYTHONPATH}:}${PREF_LOFAR_BUILD}/python-packages 
export LOFARROOT=$PREF_LOFAR_BUILD

#---------------------------------------------------------------------------
#Log which builds used when:
mkdir -p $SAL_LOGDIR
echo "$(date) --- $PREF_LOFAR_BUILD" >> $SAL_LOGDIR/lofar_builds_used.log
cd $SCRIPT_DIR
echo "$(date) --- $PREF_LOFAR_BUILD --- $(whoami) --- $(hostname)" >> lofar_builds_used.log
unset SAL_LOGDIR
#---------------------------------------------------------------------------
cd "$INIT_SCRIPT_STARTDIR"
unset INIT_SCRIPT_STARTDIR
