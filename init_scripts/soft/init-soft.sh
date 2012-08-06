#!/bin/bash
#Setup the various environment paths:

stable_software_pathdirs=/opt/soft/pathdirs

export PATH=${stable_software_pathdirs}/bin${PATH:+${PATH}:} 
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${stable_software_pathdirs}/lib 
export PYTHONPATH=${stable_software_pathdirs}/python-packages${PYTHONPATH:+${PYTHONPATH}:} 

#for s in PATH:bin LD_LIBRARY_PATH:lib \
#	PYTHONPATH:python-packages; 
#do
#  path_var=${s%:*} #first half of the list item (before :), e.g. PATH
#  group_dir=${s#*:} #second half of the list item (after :) e.g. bin
#  group_path=$stable_software_pathdirs/$group_dir             #e.g. /opt/soft/bin

#  eval prepath="$"$path_var #Env. variable before alteration, e.g. /usr/bin

  #If group path not in path already; add it:
#  if [[ $prepath != *$group_path* ]]; then 
#    eval postpath=${group_path}${prepath:+:${prepath}} 
#    eval export $path_var=$postpath 
#  fi

#  unset path_var group_dir group_path prepath postpath 
#done

#unset s stable_software_pathdirs

