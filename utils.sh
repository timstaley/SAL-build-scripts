check_result() {
    COMPONENT=${1}
    STEP=${2}
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
    SOURCEDIR=${1}
    REVISION=${2}
    SVN_LOGIN=${3}
    cd $SOURCEDIR
		echo 
		echo
    echo "*** Updating sources at $SOURCEDIR. ***"
    git clean -df
    check_result "$SOURCEDIR update" "clean" $?
    git checkout -f master
	if [ $SVN_LOGIN ];    then
		git svn rebase --username $SVN_LOGIN
	else
		git svn rebase
	fi
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
}

update_git_repo() {
    SOURCEDIR=${1}
#    REVISION=${2}
    cd $SOURCEDIR
		echo 
		echo
    echo "*** Updating repo at $SOURCEDIR. ***"
    git clean -df
    check_result "$SOURCEDIR update" "clean" $?
    git checkout -f master
    check_result "$SOURCEDIR update" "checkout master" $?
    git pull
    check_result "$SOURCEDIR update" "pull" $?
}


get_git_svnrev(){
echo `git svn find-rev HEAD`
}

get_git_short_hash(){
echo `git log --pretty=format:'%h' -n 1`
}
