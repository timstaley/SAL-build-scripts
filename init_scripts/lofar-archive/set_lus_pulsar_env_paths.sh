#!/bin/bash
#################################################################
#
# REQUIRED ENVIRONMENT VARIABLES: 
# archive_target_dir  # e.g. =/opt/lofar_archive/2011-11-10
#
# The subdirs expected are then:
# "symlinks/bin", "symlinks/lib", "symlinks/python-packages" 
#
# NB any echos are good for testing, but cause issues with e.g. scp transfers
#
#################################################################

#Setup the various environment paths:

if [[ -z "$archive_target_dir" ]]; then 
  echo "archive_target_dir not set, cannot set lofar package paths."
  echo "Try this instead:"
  echo "source /opt/lofar-stable/init-pulsar.sh"
  set -e
fi

start_dir=`pwd`
PYTHON_VERSION=`python -c "import sys; print sys.version[:3]"`
PULSAR_ROOT=$archive_target_dir/symlinks/pulsar-root

export PATH=${PULSAR_ROOT}/bin:${PATH}
export LD_LIBRARY_PATH=${PULSAR_ROOT}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export PYTHONPATH=${PULSAR_ROOT}/lib/python${PYTHONPATH:+:${PYTHONPATH}} 
export PYTHONPATH=${PULSAR_ROOT}/lib/python${PYTHON_VERSION}/site-packages:${PYTHONPATH}

unset PYTHON_VERSION 
################################################################
#Set LOFARSOFT
cd $PULSAR_ROOT
export LOFARSOFT=`pwd -P`

#################################################################

cd $start_dir
unset start_dir
