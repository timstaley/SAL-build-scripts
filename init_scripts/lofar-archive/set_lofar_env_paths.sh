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
  echo "source /opt/lofar-stable/init-lofar.sh"
  set -e
fi

start_dir=`pwd`

collated_paths_folder=$archive_target_dir/pathdirs
export PATH=${collated_paths_folder}/bin${PATH:+:${PATH}} 
export LD_LIBRARY_PATH=${collated_paths_folder}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} 
export PYTHONPATH=${collated_paths_folder}/python-packages${PYTHONPATH:+:${PYTHONPATH}} 

unset collated_paths_folder
################################################################
#Set LOFARROOT
cd $archive_target_dir/symlinks/lofar-root  
export LOFARROOT=`pwd -P`
mkdir -p $HOME/.lofar
echo "`date` --- $LOFARROOT" >> $HOME/.lofar/builds_used.log

cd $LOFARROOT/../..
echo "`date` --- $LOFARROOT --- `whoami` --- `hostname`" >> lofar_versions_used.log

cd $start_dir

################################################################
#Symlink in the python package paths for PYRAP
python_version=`python -c "import sys; print sys.version[:3]"`
mkdir -p ~/.local/lib/python${python_version}/site-packages
ln -sfn $archive_target_dir/symlinks/python-packages/pyrap.pth ~/.local/lib/python${python_version}/site-packages/pyrap.pth 

#################################################################


unset start_dir
