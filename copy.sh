#! /bin/sh
set -e

WD=`pwd`
dir=${1:-$WD}
name=mipal-swift-on-pepper-copy

remove() {
    docker rm -f $name
	exit
}

trap remove SIGHUP SIGINT SIGTERM

docker create -ti --name $name mipal-pepper-swift-crosstoolchain-build bash
docker cp $name:/root/src/nao_swift/pepper/ctc-mipal.tar.gz $dir/ctc-mipal.tar.gz
docker cp $name:/root/src/nao_swift/pepper/crosstoolchain.tar.gz $dir/crosstoolchain.tar.gz
docker cp $name:/root/src/nao_swift/pepper/pepper.tar.gz $dir/pepper.tar.gz
remove
