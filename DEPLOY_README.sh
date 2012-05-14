#!/bin/bash

## Uber script for running a lofar install on a fresh machine
## and / or  Notes to explain the flow:

## NB it is important to run this script using the command:
## bash DEPLOY_README.sh
## rather than
## . DEPLOY_README.sh or source DEPLOT_README.sh
## (Otherwise it may not be able to find the other files)
## The same goes if you run the steps below manually.

BUILD_SCRIPTS_DIR=`dirname ${0}`
BUILD_SCRIPTS_DIR=`cd $BUILD_SCRIPTS_DIR; pwd -P`
. $BUILD_SCRIPTS_DIR/CONFIG

########################################################

## NB, you may also want CASApy, see
## http://casa.nrao.edu/casa_obtaining.shtml

########################################################
# For successful unit testing, you will also need python-xmlrunner:
# https://launchpad.net/ubuntu/+source/python-xmlrunner/1.2-1
########################################################

##Ok, install packages:
## The standard method uses dpkg --set-selections, but that has proven buggy for me (TS, Ubuntu 12.04)
## instead I recommend:
# sudo apt-get install  $(< LOFAR_package_list_Ubuntu_12.04)


########################################################
#DOWNLOAD_LOFAR_DEPS=1 ##Use wget to get the source files

#bash ${BUILD_SCRIPTS_DIR}/grab_install_log4cplus
#bash ${BUILD_SCRIPTS_DIR}/grab_install_wcslib
#bash ${BUILD_SCRIPTS_DIR}/grab_install_pygsl
#bash ${BUILD_SCRIPTS_DIR}/grab_install_psycopg

#bash ${BUILD_SCRIPTS_DIR}/grab_lofar_svn_repos

########################################################



########################################################
#To do - source these paths from CONFIG
mkdir -p ${STABLE_SOFT_DIR}
ln -sn ${BUILD_SCRIPTS_DIR}/init_scripts/soft/init-soft.sh ${STABLE_SOFT_DIR}
ln -sn ${BUILD_SCRIPTS_DIR}/init_scripts/soft/reset-paths.sh ${STABLE_SOFT_DIR}

mkdir -p ${LOFAR_BUILDS_ARCHIVE_DIR}
ln -sn ${BUILD_SCRIPTS_DIR}/init_scripts/lofar-archive/set_lofar_env_paths.sh ${LOFAR_BUILDS_ARCHIVE_DIR}
ln -sn ${BUILD_SCRIPTS_DIR}/init_scripts/lofar-archive/collate_lofar_symlinks.sh ${LOFAR_BUILDS_ARCHIVE_DIR}

########################################################
## Build!
bash ${BUILD_SCRIPTS_DIR}/build_lofar 
########################################################
#Now set up your postgres database.

