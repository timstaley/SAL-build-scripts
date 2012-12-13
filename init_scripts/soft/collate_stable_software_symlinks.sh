#!/bin/bash
#Setup the various environment paths:

stable_software_path=/opt/soft
collated_paths_folder=$stable_software_path/symlinks/archive/`date +%F-%H-%M`

#rm -rf $collated_paths_folder
mkdir -p $collated_paths_folder

for foldername in bin lib python-packages ; 
do
  group_path=$stable_software_path/symlinks/${foldername}
  collated_subfolder=$collated_paths_folder/${foldername}      
  mkdir -p $collated_subfolder

  #Find all files linked from the bin and lib folders
  #NB double brackets -> C style boolean operators. (requires bash shell!)
  if [[ $foldername == bin || $foldername == lib ]]; then 
    for f in `find -L $group_path/*  -maxdepth 1 -type f`;
    do
#      echo "ln -sfnv $f $collated_subfolder/"
      ln -sn $f $collated_subfolder/
    done
    unset f
  fi

#Pythonpath is a special case as we want to symlink folders, not files:
  if [[ $foldername == python-packages ]]; then 
    for f in `find -L $group_path/* -mindepth 1 -maxdepth 1 -type d`;
    do
#      echo "ln -sfnv $f $collated_subfolder/"
      ln -sn $f $collated_subfolder/
    done
    unset f
  fi
    
  unset group_path collated_subfolder
done

unset foldername collated_paths_folder


