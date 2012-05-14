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

########################################################

## NB, you may also want CASApy, see
## http://casa.nrao.edu/casa_obtaining.shtml

########################################################
# For successful unit testing, you will also need python-xmlrunner:
# https://launchpad.net/ubuntu/+source/python-xmlrunner/1.2-1
########################################################
##NB for comparison, you can get your own package list using 
# dpkg --get-selections

## Required on a fresh Ubuntu install:
#sudo dpkg --set-selections < LOFAR_package_list

## NB it's possible I've still forgotten to list a package or 2, to be sure you could use 
#sudo dpkg --set-selections < full_package_list

## Runs the package install.
#sudo apt-get -u dselect-upgrade 
##(You can safely select "no config" if a 'postfix' config screen comes up)


########################################################
bash ${BUILD_SCRIPTS_DIR}/grab_install_log4cplus
bash ${BUILD_SCRIPTS_DIR}/grab_install_wcslib
bash ${BUILD_SCRIPTS_DIR}/grab_install_pygsl
bash ${BUILD_SCRIPTS_DIR}/grab_install_psycopg

bash ${BUILD_SCRIPTS_DIR}/grab_lofar_svn_repos

########################################################

#To do - source these paths from CONFIG
mkdir -p ${STABLE_SOFT_DIR}
cp ${BUILD_SCRIPTS_DIR}/init_scripts/soft/init-soft.sh ${STABLE_SOFT_DIR}
cp ${BUILD_SCRIPTS_DIR}/init_scripts/soft/reset-paths.sh ${STABLE_SOFT_DIR}

mkdir -p ${LOFAR_BUILDS_ARCHIVE_DIR}
cp ${BUILD_SCRIPTS_DIR}/init_scripts/lofar-archive/set_lofar_env_paths.sh ${LOFAR_BUILDS_ARCHIVE_DIR}
cp ${BUILD_SCRIPTS_DIR}/init_scripts/lofar-archive/collate_lofar_symlinks.sh ${LOFAR_BUILDS_ARCHIVE_DIR}

########################################################
## Build!
bash ${BUILD_SCRIPTS_DIR}/build_lofar 
########################################################
#Now set up your postgres database.

