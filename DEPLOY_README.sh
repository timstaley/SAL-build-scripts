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
echo "Enter sudo password (just for apt-get):"
sudo apt-get install  $(< ${BUILD_SCRIPTS_DIR}/package_lists/CASA_package_list_Ubuntu_12.04)


########################################################

#Lofar repos first, for authentication:
bash ${BUILD_SCRIPTS_DIR}/grab_lofar_svn_repos
check_result "Grab libs" "lofar_svn_repos" $?

bash ${BUILD_SCRIPTS_DIR}/grab_install_log4cplus
check_result "Grab libs" "log4cplus" $?
#bash ${BUILD_SCRIPTS_DIR}/grab_install_wcslib
#check_result "Grab libs" "wcslib" $?
bash ${BUILD_SCRIPTS_DIR}/grab_install_pygsl
check_result "Grab libs" "pygsl" $?
bash ${BUILD_SCRIPTS_DIR}/grab_install_psycopg
check_result "Grab libs" "psycopg" $?
bash ${BUILD_SCRIPTS_DIR}/grab_install_monetdb
check_result "Grab libs" "monetdb" $?
bash ${BUILD_SCRIPTS_DIR}/grab_casatools_repos
check_result "Grab libs" "casatools" $?

########################################################



########################################################
mkdir -p ${STABLE_SOFT_DIR}
cp ${BUILD_SCRIPTS_DIR}/init_scripts/init-soft.sh ${STABLE_SOFT_DIR}

########################################################
## Build!
#bash ${BUILD_SCRIPTS_DIR}/BUILD_CASATOOLS.sh
#bash ${BUILD_SCRIPTS_DIR}/BUILD_IMAGING.sh
########################################################
#Now set up your postgres database.

