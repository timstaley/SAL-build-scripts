#!/bin/bash
#################################################################
#
# REQUIRED ENVIRONMENT VARIABLES: 
# archive_target_dir  # e.g. =/opt/lofar_archive/2011-11-10
#
# The subdirs expected are then:
# "symlinks/bin", "symlinks/lib", "symlinks/python-packages" 
#
#
#################################################################

if [[ -z "$archive_target_dir" ]]; then 
  echo "archive_target_dir not set, cannot collate lofar package paths."
  set -e
fi

collated_paths_folder=$archive_target_dir/pathdirs

rm -rf $collated_paths_folder
mkdir -p $collated_paths_folder

for foldername in bin lib python-packages ; 
do
  group_path=$archive_target_dir/symlinks/${foldername}
  collated_subfolder=$collated_paths_folder/${foldername}      
  mkdir -p $collated_subfolder

  #Find all files linked from the bin and lib folders
  #NB double brackets -> C style boolean operators. (requires bash shell!)
  if [[ $foldername == bin || $foldername == lib ]]; then 
    for f in `find -L $group_path/*  -maxdepth 1 -type f`;
    do
#      echo "ln -sfnv $f $collated_subfolder/"
      ln -sfnv $f $collated_subfolder/
    done
    unset f
  fi

#Pythonpath is a special case as we want to symlink folders, not files:
  if [[ $foldername == python-packages ]]; then 
    for f in `find -L $group_path/* -mindepth 1 -maxdepth 1`;
    do
#      echo "ln -sfnv $f $collated_subfolder/"
      ln -sfnv $f $collated_subfolder/
    done
    unset f
  fi
    
  unset group_path collated_subfolder
done

unset foldername collated_paths_folder


