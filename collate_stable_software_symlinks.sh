#!/bin/bash
###############################################
#Collect list of files listed in bin/lib/python-packages subdirs of various 
#packages, symlink them all into one place for easy path addition:
##############################################
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
source $SCRIPT_DIR/../../CONFIG

collated_paths_folder=$STABLE_SOFT_DIR/symlinks/archive/`date +%F-%H-%M`
rm -rf $collated_paths_folder
mkdir -p $collated_paths_folder

ln -sfn $collated_paths_folder $STABLE_SOFT_DIR/symlinks/buildset-latest


for foldername in bin lib python-packages ; 
do
  group_path=$STABLE_SOFT_DIR/symlinks/${foldername}
  collated_subfolder=$collated_paths_folder/${foldername}      
  mkdir -p $collated_subfolder

  #Find all files linked from the bin and lib folders
  #NB double brackets -> C style boolean operators. (requires bash shell!)
  if [[ $foldername == bin || $foldername == lib ]]; then 
    for f in `find -L $group_path/*  -maxdepth 1 -type f`;
    do
#      echo "was ln -sfnv $f $collated_subfolder/"
      filename=$(basename $f)
      filedir=$(dirname  $f)
      realfilename=$(cd $filedir && pwd -P)/$filename
#      echo "is ln -sfnv $realfilename $collated_subfolder/"
      ln -sn $realfilename $collated_subfolder/
    done
    unset f
  fi

#Pythonpath is a special case as we want to symlink folders, not files:
  if [[ $foldername == python-packages ]]; then 
    for d in `find -L $group_path/* -mindepth 1 -maxdepth 1 -type d`;
    do
#      echo "was ln -sfnv $d $collated_subfolder/"
      realdir=$(cd $d && pwd -P)
#      echo "is ln -sfnv $realdir $collated_subfolder/"
      ln -sn $realdir $collated_subfolder/
    done
    unset d
  fi
    
  unset group_path collated_subfolder
done

unset foldername collated_paths_folder
echo "***********************************************************************"
echo "Symlinks collected. Latest buildset is always referenced by:"
echo "$STABLE_SOFT_DIR/symlinks/buildset-latest"
echo "You may wish to update your default buildset symlink, using the command:"
echo "ln -sfn \$(readlink $STABLE_SOFT_DIR/symlinks/buildset-latest) $STABLE_SOFT_DIR/software-buildset-default"
echo "***********************************************************************"


