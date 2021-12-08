#!/usr/bin/env bash

# set max number of open files high to prevent build failures
# (if allowed; this is mostly relevant on the jenkins build hosts
#  where the builds are being run by the root user)
if [[ $EUID -eq 0 ]]; then
    ulimit -n 64000
fi

# osx needs to be hinted to use gnu readlink
READLINK=`which readlink`
if [[ `uname` == 'Darwin' ]]; then
    which greadlink > /dev/null && {
        READLINK=`which greadlink`
    } || {
        echo 'ERROR: GNU coreutils version of readlink is required for Mac. You may use homebrew to install it via: brew install coreutils'
        exit 1
    }
fi

SCRIPT=$($READLINK -f $0)
SCRIPTPATH=$(dirname $SCRIPT)

export GRADLEW=$(pwd)/gradlew
cd $SCRIPTPATH

function build_server {
	$GRADLEW :collab-server:explodedWar
}

function build_eclipse_update_site {
	$GRADLEW install
	pushd collab-eclipse
	$GRADLEW makeEclipsePluginZip
	popd
}

function build_eclipse_gui {
	$GRADLEW install
	pushd collab-eclipse
	$GRADLEW :com.smartbear.collaborator.ui.standalone:buildCustom
	popd
}

function build_server_installer {
	$GRADLEW prepareBinaries || exit 1
    pushd collab-installers
        chmod u+x gradlew
        pushd server-installer
            $GRADLEW media || exit 1
        popd
    popd
}

function build_client_installer {
	$GRADLEW prepareBinaries || exit 1
    pushd collab-eclipse
        $GRADLEW prepareBinaries || exit 1
    popd
    pushd collab-installers
        chmod u+x gradlew
        pushd client-installer
            $GRADLEW media || exit 1
        popd
    popd
}

function build_all {
	build_develop false
}

function build_production {
    build_develop false
}

function build_develop {
    if [ "$1" == "" ]
    then
        echo Starting build job...
        echo "DevMode" param has NOT been set. Default value from the build.gradle will be used.
    else
        echo Starting build job with $1 param...
        echo "DevMode" param has been set. Will use -Pdev=$1 value.
        set "devModeParam=-Pdev=$1"
    fi
    $GRADLEW prepareBinaries $devModeParam || exit  1
    pushd collab-eclipse
        $GRADLEW prepareBinaries || exit  1
    popd
    pushd collab-installers
        $GRADLEW media $devModeParam || exit 1
    popd
}

function clean {
	$GRADLEW clean
	pushd collab-eclipse
	$GRADLEW clean
	popd
}

function test {
	$GRADLEW --info test
}

case $1 in
	'server')
		build_server
		;;
	'server-installer')
		build_server_installer
		;;
	'client-installer')
		build_client_installer
		;;
	'eclipse-update-site')
		build_eclipse_update_site
		;;
	'eclipse-gui')
		build_eclipse_gui
		;;
	'all')
		build_all
		;;
    'production')
        build_production
        ;;
	'clean')
		clean
		;;
    'develop')
		build_develop
		;;
	'test')
		test
		;;
	*)
		echo 'Wrong parameter'
esac
