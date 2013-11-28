##Check that the most recent command returned a zero exit code. If not, print error and exit
check_result() {
    COMPONENT=${1} #General name for current task
    STEP=${2} #Name of specific task in current task
    RESULT=${3}
    if [ $RESULT -ne 0 ]
    then
        message="$STEP failed: returned value $RESULT"
        echo
        echo "**** ERROR: $COMPONENT: $message ****"
        exit 1
    fi
}

update_svn_repo() {
    SOURCEDIR=${1} #path to svn repo
    REVISION=${2} #revision to check out (optional, defaults to HEAD)
    cd $SOURCEDIR
		echo 
		echo
    echo "*** Updating sources at $SOURCEDIR. ***"
    git_update_startdir=$(pwd)
    cd $SOURCEDIR
    git clean -df
    check_result "$SOURCEDIR update" "clean" $?
    git checkout -f master
    git svn rebase
    check_result "$SOURCEDIR update" "svn rebase" $?
    if [ $REVISION ];    then
    	echo "*** Checking out $REVISION. *** "
			GIT_HASH=`git svn find-rev r$REVISION`
			if [[ -z $GIT_HASH ]]; then
				echo 
				echo 
				echo "**** ERROR: rev $REVISION not found at $SOURCEDIR$ ****"
				exit
			fi
      git checkout $GIT_HASH
	    check_result "$SOURCEDIR update" "rev change" $?
			unset GIT_HASH
    fi
    cd "$git_update_startdir"
    unset git_update_startdir
}

update_authenticated_svn_repo() {
    SOURCEDIR=${1} #path to svn repo
    SVN_LOGIN=${2} #login username
    REVISION=${3} #revision to check out (optional, defaults to HEAD)
    cd $SOURCEDIR
		echo 
		echo
    echo "*** Updating sources at $SOURCEDIR. ***"
    git_update_startdir=$(pwd)
    cd $SOURCEDIR
    git clean -df
    check_result "$SOURCEDIR update" "clean" $?
    git checkout -f master
    git svn rebase --username $SVN_LOGIN
    check_result "$SOURCEDIR update" "svn rebase" $?
    if [ $REVISION ];    then
    	echo "*** Checking out r$REVISION. *** "
			GIT_HASH=`git svn find-rev r$REVISION`
			if [[ -z $GIT_HASH ]]; then
				echo 
				echo 
				echo "**** ERROR: rev $REVISION not found at $SOURCEDIR$ ****"
				exit
			fi
      git checkout $GIT_HASH
	    check_result "$SOURCEDIR update" "rev change" $?
			unset GIT_HASH
    fi
    cd "$git_update_startdir"
    unset git_update_startdir
}


update_git_repo() {
    SOURCEDIR=${1} #path to git repo
    BRANCH=${2} #branch to check out
    cd $SOURCEDIR
		echo 
		echo
    echo "*** Updating repo at $SOURCEDIR. ***"
    git_update_startdir=$(pwd)
    cd $SOURCEDIR
    git clean -df
    check_result "$SOURCEDIR update" "clean" $?

    if [ $BRANCH ];    then
        git checkout -f $BRANCH
    else
        git checkout -f master
    fi
    check_result "$SOURCEDIR update" "checkout $BRANCH" $?
    git pull
    check_result "$SOURCEDIR update" "pull" $?
    cd "$git_update_startdir"
    unset git_update_startdir
}


#Get svn revision number for git-svn repository in current working directory
get_git_svnrev(){
echo `git svn find-rev HEAD` 
}

#Get short version of SHA1 hash for git repository in current working directory
get_git_short_hash(){
echo `git log --pretty=format:'%h' -n 1`
}

#Some python packages want to be installed via a .pth file.
#This is a pain for continuous deployment, since you can't simply add the .pth to the PYTHONPATH environment variable.
#But, we can unpack the .pth contents to a destination of our choosing, and then use the results:
unpack_pth_file() {
    pth_file=${1} #path to .pth file.
    target_dir=${2} #e.g. /some/versioned/build/lib/python2.7/site-packages
    mkdir -p "$target_dir"
    #.pth file paths can be absolute, or relative to the .pth file.
    #To deal with both cases, we cd to the same directory as the .pth file
    #Carefully ensuring that our path parameters updated accordingly.
    #Make target dir an absolute path:
    target_dir=$(cd ${target_dir} && pwd -P) 
    unpack_pth_file_startdir="$(pwd)"
    cd $(dirname ${pth_file})
    pth_file=$(basename ${pth_file})
#    echo "PWD: $(pwd)"
    for word in $(<$pth_file); do
        if [[ ${word: -4} == ".egg" && -d ${word} ]]; then
#            echo "${word} is a valid egg dir"
            eggdir=${word}
            for pkgdir in $(find -L $eggdir/* -mindepth 0 -maxdepth 0 -type d); do
                if [[ $(basename $pkgdir) != EGG-INFO ]] ; then
#                    echo "Found '$(basename $pkgdir)' in $pkgdir"
                    cp -r "$pkgdir" "$target_dir"
                fi 
            done
        fi
    done
    cd "${unpack_pth_file_startdir}"
}



