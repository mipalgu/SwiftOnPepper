#! /bin/sh

PARALLEL=1
SWIFT_VERSION=5.2

usage() { echo "Usage: $0 [-j<value>] -s <swift-version>"; }

while getopts "j:hls:t:" o; do
    case "${o}" in
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
        *)
            echo "Invalid argument ${o}"
            usage 1>&2
            exit 1
            ;;
    esac
done

docker image build --build-arg SSH_USER=`whoami` --build-arg GIT_USERS_NAME="`git config user.name`" --build-arg GIT_USERS_EMAIL="`git config user.email`" --build-arg SWIFTVER="$SWIFT_VERSION" --build-arg PARALLEL=$PARALLEL -t mipal-pepper-swift-crosstoolchain-build .
