#! /bin/sh
set -e

PARALLEL=1
SWIFT_VERSION=5.2
SSH_USERNAME=`whoami`
DEBUG=0

usage() { echo "Usage: $0 [-j<value>] -s <swift-version> -u <ssh_username>"; }

while getopts "c:hj:ls:t:" o; do
    case "${o}" in
        c)
            CHECKOUT_VERSION=${OPTARG}
            ;;
        d)
            DEBUG=1
            ;;
        h)
            usage
            exit 0
            ;;
        j)
            PARALLEL=${OPTARG}
            ;;
        s)
	        SWIFT_VERSION=${OPTARG}
	        ;;
        u)
            SSH_USERNAME=${OPTARG}
            ;;
        *)
            echo "Invalid argument ${o}"
            usage 1>&2
            exit 1
            ;;
    esac
done

WD=`pwd`
BUILD_DIR="$WD/.build"

mkdir -p $BUILD_DIR
if [[ "$DEBUG" == "1" ]]
then
    cp id_rsa* $BUILD_DIR/
fi

if [ ! -f nao_swift/pepper/build.sh ]
then
    >&2 echo "Make sure you initialise the submodule: 'git submodule update --init --recursive'"
    exit 1
fi

source tags.sh

if [ -z ${CHECKOUT_VERSION+x} ]
then
    CHECKOUT_VERSION=`compute_nearest_tag $SWIFT_VERSION`
fi

current_tag=`fetch_current_tag`
previous_tag=`fetch_previous_tag`
if [[ "$current_tag" == "none" || ("$current_tag" != "$previous_tag") ]]
then
    `cd $WD/nao_swift && git checkout $CHECKOUT_VERSION`
fi

if [[ "$previous_tag" != "$CHECKOUT_VERSION" ]]
then
    rm -f $BUILD_DIR/nao_swift.tar.gz
    tar -czf $BUILD_DIR/nao_swift.tar.gz nao_swift
    echo "$CHECKOUT_VERSION" > $BUILD_DIR/.swift-version
fi

docker image build --build-arg SSH_USER="$SSH_USERNAME" --build-arg GIT_USERS_NAME="`git config user.name`" --build-arg GIT_USERS_EMAIL="`git config user.email`" --build-arg SWIFTVER="$SWIFT_VERSION" --build-arg PARALLEL=$PARALLEL --build-arg DEBUG="$DEBUG" -t mipal-pepper-swift-crosstoolchain-build .
