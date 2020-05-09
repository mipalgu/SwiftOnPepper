#! /bin/sh
set -e

PARALLEL=1
SWIFT_VERSION=5.2
SSH_USERNAME=`whoami`
DEBUG=0

usage() { echo "Usage: $0 [-c <nao_swift tag>] [-j<value>] [-l] -s <swift-version> -u <ssh_username>"; }

while getopts "c:dhj:ls:t:u:" o; do
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
        l)
            LIBCXXFLAG=" -l"
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
    git submodule update --init --recursive
    git submodule foreach --recursive 'git fetch --tags'
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

rm -f $BUILD_DIR/Dockerfile.out
cp $WD/Dockerfile.in Dockerfile
echo "" >> Dockerfile

if [[ "$DEBUG" == 1 ]]
then
    while read p; do
        first_word=`echo "$p" | cut -f 1 -d " " -`
        second_word=`echo "$p" | cut -f 2 -d " " -`
        if [[ "$first_word" == "source" ]]
        then
            echo "RUN cd /root/src/nao_swift/pepper && \\" >> $WD/Dockerfile
            echo "    export SWIFTENV_ROOT="\$SWIFTENV_ROOT_ARG" && \\" >> $WD/Dockerfile
            echo "    export PATH="\$SWIFTENV_ROOT/bin:\$PATH" && \\" >> $WD/Dockerfile
            echo "    eval "\$\(swiftenv init -\)" && \\" >> $WD/Dockerfile
            echo "    ./$second_word -j$PARALLEL$LIBCXXFLAG -s $SWIFT_VERSION" >> $WD/Dockerfile
        fi
    done <$WD/nao_swift/pepper/build.sh
else
    echo "RUN cd /root/src/nao_swift/pepper && \\" >> $WD/Dockerfile
    echo "    export SWIFTENV_ROOT="\$SWIFTENV_ROOT_ARG" && \\" >> $WD/Dockerfile
    echo "    export PATH="\$SWIFTENV_ROOT/bin:\$PATH" && \\" >> $WD/Dockerfile
    echo "    eval "\$\(swiftenv init -\)" && \\" >> $WD/Dockerfile
    echo "    ./build.sh -j$PARALLEL$LIBCXXFLAG -s $SWIFT_VERSION" >> $WD/Dockerfile
fi

docker image build --build-arg SSH_USER="$SSH_USERNAME" --build-arg GIT_USERS_NAME="`git config user.name`" --build-arg GIT_USERS_EMAIL="`git config user.email`" --build-arg SWIFTVER="$SWIFT_VERSION" --build-arg PARALLEL=$PARALLEL --build-arg DEBUG="$DEBUG" -t mipal-pepper-swift-crosstoolchain-build .
