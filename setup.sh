#! /bin/sh
set -e

if [ -z "$SETUP_SH_INCLUDED" ]
then
SETUP_SH_INCLUDED=yes

WD=`pwd`
BUILD_DIR="$WD/.build"
SRC_DIR="$BUILD_DIR/src"
CONTEXT_DIR="$BUILD_DIR/context"
DOCKERFILE=$BUILD_DIR/Dockerfile

function platform_name() {
    unameOut=`uname -s`
    case "${unameOut}" in
        Linux*)     machine=linux;;
        Darwin*)    machine=mac;;
        CYGWIN*)    machine=cygwin;;
        MINGW*)     machine=mingw;;
        *)          machine="${unameOut}"
    esac
    echo ${machine}
}

PLATFORM=`platform_name`
PARALLEL=1
SWIFT_VERSION=5.2
SSH_USERNAME=`whoami`
DEBUG=0
KEYFILE=$HOME/.ssh/id_rsa
NAOQI_SDK_TAR=$WD/naoqi-sdk-2.5.5.5-${PLATFORM}64.tar.gz
CROSS_TOOLCHAIN_ZIP=$WD/ctc-linux64-atom-2.5.2.74.zip
PREFIX=/usr/local/pepper

usage() { echo "Usage: $0 [-c <nao_swift tag>] [-j<value>] [-l] [-s <swift-version>]"; }

while getopts "c:dhj:k:ln:p:s:t:u:" o; do
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
        k)
            KEYFILE=${OPTARG}
            ;;
        l)
            LIBCXXFLAG=" -l"
            ;;
        n)
            NAOQI_SDK_TAR=${OPTARG}
            ;;
        p)
            PREFIX=${OPTARG}
            ;;
        s)
	        SWIFT_VERSION=${OPTARG}
	        ;;
        t)
            CROSS_TOOLCHAIN_ZIP=${OPTARG}
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

NAOQI_SDK=`basename "$NAOQI_SDK_TAR" | sed -e "s/.tar.gz//g"`
CROSS_TOOLCHAIN_BASENAME=`basename "$CROSS_TOOLCHAIN_ZIP"`
CROSS_TOOLCHAIN=`echo "$CROSS_TOOLCHAIN_BASENAME" | sed -e "s/.zip//g"`

fi # End SETUP_SH_INCLUDED
