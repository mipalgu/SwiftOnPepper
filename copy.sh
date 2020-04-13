#! /bin/sh
set -e

name=mipal-swift-on-pepper-copy

remove() {
    docker rm -f $name
	exit
}

trap remove SIGHUP SIGINT SIGTERM

docker create -ti --name $name mipal-pepper-swift-crosstoolchain-build bash
docker cp $name:/root/src/nao_swift/pepper/ctc-mipal.tar.gz ctc-mipal.tar.gz
docker cp $name:/root/src/nao_swift/pepper/crosstoolchain.tar.gz crosstoolchain.tar.gz
docker cp $name:/root/src/nao_swift/pepper/pepper.tar.gz pepper.tar.gz
remove
