#!/bin/bash
#Setup the various environment paths:

if [[ -z "$stable_software_pathdirs" ]];
then
    stable_software_pathdirs=/opt/share/soft/pathdirs
fi

export PATH=${PATH:+${PATH}:}${stable_software_pathdirs}/bin 
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${stable_software_pathdirs}/lib 
export PYTHONPATH=${PYTHONPATH:+${PYTHONPATH}:}${stable_software_pathdirs}/python-packages 


