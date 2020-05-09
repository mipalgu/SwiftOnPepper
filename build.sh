#! /bin/sh
set -e

PARALLEL=1
SWIFT_VERSION=5.2
SSH_USERNAME=`whoami`
DEBUG=0

usage() { echo "Usage: $0 [-j<value>] -s <swift-version> -u <ssh_username>"; }

while getopts "j:hls:t:" o; do
    case "${o}" in
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
fi

text=`cd nao_swift && git status | head -n 1`
first_word=`echo "$text" | cut -f 1 -d " " -`
echo "first_word: $first_word"
if [ "$first_word" == "HEAD" ]
then
    tag=`echo "$text" | cut -f 4 -d " " -`
    if [[ "$tag" != "$SWIFT_VERSION" ]]
    then
        echo "ok"
    fi
else
    rm -f $BUILD_DIR/.swift-version
    cd nao_swift && git checkout $SWIFT_VERSION
fi

tar -czf $BUILD_DIR/nao_swift.tar.gz nao_swift
echo "$SWIFT_VERSION" > $BUILD_DIR/.swift-version

docker image build --build-arg SSH_USER="$SSH_USERNAME" --build-arg GIT_USERS_NAME="`git config user.name`" --build-arg GIT_USERS_EMAIL="`git config user.email`" --build-arg SWIFTVER="$SWIFT_VERSION" --build-arg PARALLEL=$PARALLEL --build-arg DEBUG="$DEBUG" -t mipal-pepper-swift-crosstoolchain-build .
