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
source $BUILD_SCRIPTS_DIR/CONFIG
source $BUILD_SCRIPTS_DIR/utils.sh

########################################################

## NB, you may also want CASApy, see
## http://casa.nrao.edu/casa_obtaining.shtml

########################################################
# For successful unit testing, you will also need python-xmlrunner:
# https://launchpad.net/ubuntu/+source/python-xmlrunner/1.2-1
# (This is in the package list for 12.04)
########################################################

##Ok, install packages:
## The standard method uses dpkg --set-selections, but that has proven buggy for me (TS, Ubuntu 12.04)
## instead I recommend:
sudo apt-get install  $(< LOFAR_package_list_Ubuntu_12.04)


########################################################

bash ${BUILD_SCRIPTS_DIR}/grab_install_log4cplus
check_result "Grab libs" "log4cplus" $?
bash ${BUILD_SCRIPTS_DIR}/grab_install_wcslib
check_result "Grab libs" "wcslib" $?
bash ${BUILD_SCRIPTS_DIR}/grab_install_pygsl
check_result "Grab libs" "pygsl" $?
bash ${BUILD_SCRIPTS_DIR}/grab_install_psycopg
check_result "Grab libs" "psycopg" $?
bash ${BUILD_SCRIPTS_DIR}/grab_install_monetdb
check_result "Grab libs" "monetdb" $?
bash ${BUILD_SCRIPTS_DIR}/grab_lofar_svn_repos
check_result "Grab libs" "lofar_svn_repos" $?

########################################################



########################################################
mkdir -p ${STABLE_SOFT_DIR}
ln -sn ${BUILD_SCRIPTS_DIR}/init_scripts/soft/init-soft.sh ${STABLE_SOFT_DIR}
ln -sn ${BUILD_SCRIPTS_DIR}/init_scripts/soft/reset-paths.sh ${STABLE_SOFT_DIR}

mkdir -p ${LOFAR_BUILDS_ARCHIVE_DIR}
ln -sn ${BUILD_SCRIPTS_DIR}/init_scripts/lofar-archive/set_lofar_pipeline_env_paths.sh ${LOFAR_BUILDS_ARCHIVE_DIR}
ln -sn ${BUILD_SCRIPTS_DIR}/init_scripts/lofar-archive/collate_lofar_symlinks.sh ${LOFAR_BUILDS_ARCHIVE_DIR}

########################################################
## Build!
#bash ${BUILD_SCRIPTS_DIR}/BUILD_ALL.sh
########################################################
#Now set up your postgres database.

