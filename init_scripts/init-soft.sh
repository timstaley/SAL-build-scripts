#!/bin/bash

# Adds a stable software buildset to the environment bin/lib/python paths.
#
# This file should be copied to $STABLE_SOFT_DIR as defined in CONFIG.
# The admin should then manually create a symlink 'default-buildset' in 
# $STABLE_SOFT_DIR which points to the desired default buildset under 
# $STABLE_SOFT_DIR/symlinks/archive/  (usually the one referenced by 
# the symlink at $STABLE_SOFT_DIR/symlinks/buildset-latest ).
#
# Note that users can define PREF_SOFT_BUILD before sourcing this,
# if a particular buildset is preferred.

SAL_LOGDIR="$HOME/.salbuilds"

INIT_SCRIPT_STARTDIR=$(pwd)

if [[ -z "$PREF_SOFT_BUILD" ]];
then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
    if ! [ -L $SCRIPT_DIR/default-buildset ]; then 
        echo "Please create a default-buildset pointing symlink, e.g. using"
        echo "ln -sfnv $(readlink symlinks/buildset-latest) default-buildset"
        return 1
    fi    
    PREF_SOFT_BUILD=$( cd $SCRIPT_DIR/default-buildset && pwd -P )
fi

export PATH=${PATH:+${PATH}:}${PREF_SOFT_BUILD}/bin 
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${PREF_SOFT_BUILD}/lib 
export PYTHONPATH=${PYTHONPATH:+${PYTHONPATH}:}${PREF_SOFT_BUILD}/python-packages 

#---------------------------------------------------------------------------
#Log which builds used when:
mkdir -p $SAL_LOGDIR
echo "$(date) --- $PREF_SOFT_BUILD" >> $SAL_LOGDIR/soft_buildsets_used.log
cd $SCRIPT_DIR
echo "$(date) --- $PREF_SOFT_BUILD --- $(whoami) --- $(hostname)" >> soft_buildsets_used.log
unset SAL_LOGDIR
#---------------------------------------------------------------------------
cd "$INIT_SCRIPT_STARTDIR"
unset INIT_SCRIPT_STARTDIR
